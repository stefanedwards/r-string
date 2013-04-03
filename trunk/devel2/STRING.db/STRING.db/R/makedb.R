#' Makes sqlite database for organism
#' 
#' @param tax.id String with taxonomy id, e.g. 9913 for cattle.
#' @param flatfile.fn Path to input flatfile from \code{\link{extract.flatfile}} or \code{\link{index.flatfile}}.
#' @param sqlite.fn Path to resulting sqlite db file.
#' @param organism List matching an organism entry in \code{\link{organisms}}. 
#'    If \code{NULL}, it will be pulled from \code{\link{organisms}}.
#' @param string.v Value to put in meta-table for key \code{STRING-db}.
#' @export
#' @return Live connection to sqlite database.
#' @note Will remove any prior file with same name as \code{sqlite.fn}.
make.sqlite <- function(tax.id, flatfile.fn, sqlite.fn, organism=NULL, string.v=NULL) {
  tax.id <- as.character(tax.id)
  if (is.null(organism)) organism <- organisms[[tax.id]]   # organisms specified in `organisms.R`.
  if (is.null(organism)) stop(paste('Could not fetch any organism specifics for',tax.id,'from `organisms`.'))
  
  require(RSQLite)
  
  message(" * removing any previous sqlite-files...")
  unlink(sqlite.fn)
  
  message(" * new sqlite-file created: ", sqlite.fn)
  conn <- dbConnect(dbDriver('SQLite'), sqlite.fn)
  
  meta <- vector('character')
  meta['Created'] <- date()
  if (!is.null(string.v)) meta['STRING-db'] <- string.v
  meta['primary'] <- organism$primary
  #meta[organism$primary] <- 'TRUE'
  meta['Organism'] <- organism$long
  meta['Built by'] <-  as.character(packageVersion('STRING.db'))
  meta['DB Schema'] <- 0.2 
    ## 0.1 was on emphasis on primary encoding, e.g. geneids and ppi.
    ## 0.2 is more flexible, as the table naming is dependant on encoding.
  
  dbWriteTable(conn, 'meta', data.frame(key=names(meta), value=unlist(meta), stringsAsFactors=FALSE), append=TRUE, overwrite=FALSE, row.names=FALSE)
  
  # Read raw data
  message(" * reading raw ppi data from flatfile ", flatfile.fn, "...")
  ppi <- read.table(flatfile.fn, header=FALSE, col.names=c('id1','id2','score'), as.is=TRUE)
  message(" * writing primary ppi to sqlite...")
  write.ppi.table(conn, ppi, organism$primary)
 
 
  ## Write meta table
  message(" * finishing with the database...")
  
  #if (!is.null(organism$map2entrez)) {
  #  message(" * mapping extra entrez encoding...\n")
  #  ppi.ens <- organism$map2entrez(ppi)
  #  if (ppi.ens != FALSE) {
  #    message(" * got entrez, will try to write it...\n")
  #    write.ppi.table(conn, ppi.ens, 'entrez')
  #    meta['entrez'] <- 'TRUE'
  #    if (!is.null(attr(ppi.ens, 'meta'))) 
  #      dbWriteTable(conn, 'meta', attr(ppi.ens, 'meta'), append=TRUE, overwrite=FALSE, row.names=FALSE)
  #  }
  #}
  
  
  return(conn)
}

#' @export
make.entrez.table <- function(conn, ppi, func) {
  message(" * mapping extra entrez encoding...")
  ppi.ens <- func(ppi)
  if (length(ppi.ens) != 1) {#(ppi.ens != FALSE) {
    message(" * got entrez, will try to write it...")
    write.ppi.table(conn, ppi.ens, 'entrez')
    if (!is.null(attr(ppi.ens, 'meta'))) 
      dbWriteTable(conn, 'meta', attr(ppi.ens, 'meta'), append=TRUE, overwrite=FALSE, row.names=FALSE)
  }
}

#' Writes ppi-data.frame to database.
#' 
#' Maps the gene/protein names to an integer id (if necessary).
#' @param conn Live connection to database.
#' @param ppi Data.frame with three columns, id1, id2 and score.
#' @param encoding String naming the encoding (e.g. entrez or ensembl).
write.ppi.table <- function(conn, ppi, encoding) {
  encoding <- tolower(encoding)
  if (grepl('.', encoding, fixed=TRUE)) stop('`encoding` must not include period (.)!')
  
  if (all(is.integer(ppi$id1)) & all(is.integer(ppi$id2))) {
    dbWriteTable(conn, encoding, ppi, row.names=FALSE, overwrite=TRUE)
  } else {
    # Get list of protein ids.
    prot.ids <- unique(c(ppi$id1, ppi$id2))
    prot.ids <- structure(1:length(prot.ids), .Names=prot.ids)
    # data.frame of same structure for dbWriteTable
    prot.mat <- data.frame(id=prot.ids, gene=names(prot.ids))
    
    # Mask ppi table with integer ids
    ppi.mask <- ppi
    ppi.mask$id1 <- prot.ids[ppi.mask$id1]
    ppi.mask$id2 <- prot.ids[ppi.mask$id2]
    
    # Insert ids
    dbSendQuery(conn, sprintf('CREATE TABLE %s_ids (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, gene TEXT UNIQUE);', encoding))
    dbWriteTable(conn, paste(encoding, '_ids', sep=''), prot.mat, row.names=FALSE, overwrite=FALSE, append=TRUE)
    
    # Insert ppi
    dbWriteTable(conn, encoding, ppi.mask, row.names=FALSE, overwrite=TRUE)
  }
  # Create indices on ppi-table.
  dbSendQuery(conn, sprintf('CREATE INDEX `IDX_%s_id1` ON `%s` (`id1`);', encoding, encoding))
  #dbSendQuery(conn, 'CREATE UNIQUE INDEX `IDX_ppi` ON `ppi` (`id1`,`id2`);')
  dbSendQuery(conn, sprintf('CREATE INDEX `IDX_%s_score` ON `%s` (`score`);', encoding, encoding))
  dbSendQuery(conn, 'INSERT INTO meta (`key`,`value`) VALUES (?, "TRUE");', data.frame(encoding))
}

#' Creates a data-object with a given variable name.
#' 
#' Uses \code{\link{makeCache}} to make a data-object with all PPI's,
#' and saves the object with a given variable name into an environment.
#' @param conn Live connection to database.
#' @param encoding String naming the encoding (e.g. entrez or ensembl).
#' @param cutoff Score cut-off; only retrieves ppi with scores larger than or equal to.
#' @param var.name The variable named that the object is assigned to.
#' @param envir Environment where the object is saved. Defaults to \code{\link[base:environment]{new.env()}}.
#' @return Environement \code{envir} with the data object.
#' @export
#' @seealso \code{\link{makeCache}}.
cacheObject <- function(conn, encoding, cutoff, var.name, envir=new.env()) {
  res <- makeCache(conn, encoding=encoding, cutoff=cutoff)
  assign(var.name, res, envir=envir)
  return(envir)
}

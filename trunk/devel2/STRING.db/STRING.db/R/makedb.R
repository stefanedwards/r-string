#' Makes sqlite database for organism
#' 
#' @param tax.id String with taxonomy id, e.g. 9913 for cattle.
#' @param flatfile.fn Path to input flatfile from \code{\link{extract.flatfile}} or \code{\link{index.flatfile}}.
#' @param sqlite.fn Path to resulting sqlite db file.
#' @param organism List matching an organism entry in \code{\link{organisms}}. 
#'    If \code{NULL}, it will be pulled from \code{\link{organisms}}.
# @param src.dir Path to location where organism specific flatfiles are.
# @param dest.dir Path to where resulting sqlite db file should be placed.
#' @return Live connection to sqlite database.
#' @note Will remove any prior file with same name as \code{sqlite.fn}.
make.sqlite <- function(tax.id, flatfile.fn, sqlite.fn, organism=NULL) {
  tax.id <- as.character(tax.id)
  if (is.null(organism)) organism <- organisms[[tax.id]] 
  if (is.null(organism)) stop(paste('Could not fetch any organism specifics for',tax.id,'from `organisms`.'))
  
  require(RSQLite)
  
  unlink(sqlite.fn)
  
  conn <- dbConnect(dbDriver('SQLite'), sqlite.fn)
  meta <- vector('character')
  
  meta['Created'] <- date()
  meta['STRING-db'] <- 'Err...'
  meta['primary'] <- organism$primary
  meta[organism$primary] <- '1'
  meta['Organism'] <- organism$long
  meta['DB Schema'] <- 0.2 
    ## 0.1 was on emphasis on primary encoding, e.g. geneids and ppi.
    ## 0.2 is more flexible, as the table naming is dependant on encoding.
  
  # Read raw data
  ppi <- read.table(flatfile.fn, header=FALSE, col.names=c('id1','id2','score'), as.is=TRUE)
  write.ppi.table(conn, ppi, organism$primary)
  
  if (!is.null(organism$ens2eg)) {
    ppi.ens <- organism$ens2eg(ppi)
    write.ppi.table(conn, ppi.ens, 'entrez')
    meta['entrez'] <- '1'
    if (!is.null(attr(ppi.ens, 'meta'))) 
      dbWriteTable(conn, 'meta', attr(ppi.ens, 'meta'), append=TRUE, overwrite=FALSE, row.names=FALSE)
  }
  
  ## Write meta table
  dbWriteTable(conn, 'meta', data.frame(key=names(meta), value=meta), append=TRUE, overwrite=FALSE, row.names=FALSE)
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
}

make.cache <- function(conn, encoding, cutoff) {
  all.names <- getNames(conn, encoding)
  res <- getPPI(conn, proteins=all.names, cutoff=cutoff, encoding=encoding, as.list=TRUE, simplify=FALSE)
  return(res)
}
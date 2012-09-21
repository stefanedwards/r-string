#############################
## Functions that the organism packages would use.
#############################

# methods from AnnDbObj-lowAPI.R in AnnotationDbi
#' Generic function for keeping sqlite-connection alive.
#' 
#' @param x An environment that contains the variable of same name as function.
#' @return The contents of the variable.
#' @examples
#' datacache <- new.env(hash=TRUE, parent=emptyenv())
#' 
#' dbfile <- 'my file'
#' assign('dbfile', dbfile, envir=datacache)
#' dbconn <- 'my live connection, but you would replace with e.g. dbConnect(...).'
#' assign('dbconn', dbconn, envir=datacache)
dbconn <- function(x) get('dbconn', envir=x)
#' @rdname dbconn
#' @inheritParams dbconn
dbfile <- function(x) get('dbfile', envir=x)


#' Known gene/protein encodings/identifiers
#' 
#' In these packages, we call the type of identifier for an biological entity \sQuote{encodings}.
#' E.g. Entrez, Ensembl or Refseq are examples of encodings.
known.encodings <- c('ensembl','entrez','refseq')

#' Generic function for retrieving meta-data from organism data packages.
#'
#' @param conn Database connection to STRING.db-sqlite database.
#' @param key Character vector of which keys to retrieve; use sqlite syntax for wildcards (e.g. % to match all characters). Defaults to retrieve all keys.
#' @return List with entries named by the key; return value is reduced to character vector if only one key is retrieved.
# @author Stefan McKinnon Edwards \email{stefan.hoj-edwards@@agrsci.dk}
#' @seealso \code{\link{STRING.db}}
getMeta <- function(conn, key='%') {
  stop('getMeta is not implemented')
  #dbReadTable(conn, 'meta')
  #res <- dbGetQuery(conn, 'SELECT * FROM meta WHERE meta LIKE ?;', data.frame(key))
  #res$meta = factor(res$meta)
  #if (nlevels(res$meta) == 1)
  #  return(res$value)
  #return(split(res$value, res$meta))
}


#' Generic function for retrieving the protein-protein interaction data from organism data packages.
#' 
#' @param conn Database connection to STRING.db-sqlite database.
#' @param proteins Character vector of gene/protein identifiers that are requested. 
#' @param cutoff Score cut-off; only retrieves ppi with scores larger than or equal to.
#' @param encoding String of which encoding \code{proteins} is set in.
#' @param as.list Logical, restructure result to a list, see Value.
#' @param simplify Logical, should function only return a character vector of all interaction partners? Overrules \code{as.list}.
#' @return For \code{as.list} as \code{FALSE}, data.frame of three columns (\code{g1}, \code{g2}, \code{score}).
#'         For \code{as.list} as \code{TRUE}, list with entries named by \code{g1} containing all mappings in \code{g2}. \code{score} is lost.
#'         If \code{simplify} is \code{TRUE}, \code{as.list} is overruled and the returned value is a character vector.
#' @author Stefan McKinnon Edwards \email{stefan.hoj-edwards@@agrsci.dk}
#' @seealso \code{\link{known.encodings}}, \code{\link{STRING.db}}, \code{\link{getNames}}
#' @export
getPPI <- function(conn, proteins, cutoff, encoding, as.list, simplify) {
  stop('getPPI is not implemented.')
#   encoding <- tolower(encoding)
#   if (!encoding %in% .known.encodings) stop('Could not recognize encoding. See ::.known.encodings.')
#   #tbl <- dbGetQuery(conn, "SELECT value FROM meta WHERE meta = ?;", encoding)
#   tbl <- .getMeta(conn, encoding)
#   if (length(tbl) == 0) stop('There does not exist any mappings for the given encoding.')  
#   
#   if (encoding == .getMeta(conn, 'Primary encoding')) {
#     sql <- sprintf('SELECT `g1`.`gene` as `g1`, `g2`.`gene` as `g2`, `ppi`.`score` FROM geneids as g1
#     INNER JOIN %s as ppi ON ppi.id1 = g1.id
#                    inner join geneids as g2 on g2.id=ppi.id2
#                    where g1.gene = @g and ppi.score >= @s;', .getMeta(conn, 'Primary PPI'))
#   } else {
#     sql <- sprintf('SELECT `id1` as `g1`, `id2` as `g2`, `score` as `score` FROM %s WHERE `id` = @g AND `score` >= @s', tbl)
#   }
#   res <- dbGetQuery(conn, sql, list(g=proteins, s=cutoff))
#   
#   # Three different return options
#   if (simplify)
#     return(unique(res[,2]))
#   if (as.list)
#     return(split(res[,2], as.factor(res[,1])))
#   return(res)
  
}

#' Generic function for reading all saved gene/protein names of the primary type.
#' 
#' \code{getNames.x.y} are database schema dependant functions for doing the actual work.
#' 
#' @param conn Database connection to STRING.db-sqlite database.
#' @param encoding String of which encoding \code{proteins} is set in. Defaults to primary encoding.
#' @param filter Character for filtering which names to retrieve; uses sqlite i.e. use \sQuote{\%} for any length wildcard, \sQuote{_} for single character wildcard.
# @author Stefan McKinnon Edwards \email{stefan.hoj-edwards@@agrsci.dk}
#' @return data.frame with one column.
#' @export
getNames <- function(conn, encoding=NULL, filter=NULL) {
  db.schema <- getMeta(conn, 'DB Schema')
  stopifnot(length(db.schema) == 1)
  
  gn <- get(paste('getNames',db.schema))
  return(gn(conn, encoding=encoding, filter=filter))
}
#' @rdname getNames
#' @inheritParams getNames
getNames.0.1 <- function(conn, encoding, filter) {
  if (is.null(filter)) {
    return(dbReadTable(conn, 'geneids', row.names='id'))
  } else {
    return(dbGetQuery(conn, 'SELECT gene FROM geneids WHERE gene LIKE ?;', data.frame(filter)))
  }
}
#' @rdname getNames
#' @inheritParams getNames
getNames.0.2 <- function(conn, encoding, filter) {
  has.enc <- getMeta(conn, encoding)
  
  tbl.id <- paste(encoding, '_ids', sep='')
  if (!tbl.id %in% dbListTables(conn)) {
    # Read ids directly from ppi-table
    if (is.null(filter)) {
      return(dbGetQuery(conn, sprintf('SELECT DISTINCT id1 FROM %s ORDER BY id1;', encoding)))
    } else {
      return(dbGetQuery(conn, sprintf('SELECT DISTINCT id1 FROM %s WHERE id1 LIKE ? ORDER BY id1;', encoding), data.frame(filter)))
    }
  } else {
    # Read ids from id table
    if (is.null(filter)) {
      return(dbReadTable(conn, tbl.id, row.names='id'))
    } else {
      res <- dbGetQuery(conn, sprintf('SELECT id, gene FROM %s WHERE gene LIKE ? ORDER BY gene;', encoding), data.frame(filter))
      return(data.frame(res$gene, row.names=res$id, stringsAsFactors=FALSE))
    }    
  }
}
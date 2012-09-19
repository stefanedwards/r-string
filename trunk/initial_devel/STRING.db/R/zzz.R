# STRING database interface
# Documentation with `roxygen2`.
#'
#' Interface package for organism protein-protein-interaction data packages
#' from STRING-db.org.
#' 
#' NB! This package neither developed nor maintained by the authors of STRING.
#'
#' @name  STRING.db-package
#' @aliases  STRING.db
#' @docType  package
#' @title STRING database interface.
#' @author  Stefan McKinnon Edwards  \email{stefan.hoj-edwards@@agrsci.dk}
#' @references
#' \url{http://code.google.com/p/r-string/}
#' @keywords  package
#' @seealso  \code{\link{getMeta}}, \code{\link{getPPI}}
#' @examples
#' library(RSQLite)
#' 
#' ## Crude example of the data we expect to find in the organism data packages. ##
#' conn <- dbConnect(dbDriver('SQLite'), ':memory:')
#' meta <- data.frame(meta=c('ensembl','Primary encoding','Primary PPI','name','bla','bla','dude'), value=c('ppi','ensembl','ppi','lolcat','chezburger','rainbow','greg'))
#' dbWriteTable(conn, 'meta', meta, row.names=FALSE, overwrite=TRUE)
#' 
#' geneid <- data.frame(id=1:4, gene=letters[1:4])
#' dbWriteTable(conn, 'geneids', geneid, row.names=FALSE, overwrite=TRUE)
#'
#' ppi <- data.frame(id1=c(rep(1, 3), rep(2, 2), rep(3,3), rep(4,2)), id2=c(2,3,4, 1,3, 1,2,4, 1,3), score=c(950, 900, 700,  950, 900,  900, 900, 700,  700, 700))
#' dbWriteTable(conn, 'ppi', ppi, row.names=FALSE, overwrite=TRUE)
#'
#' ## Example of fetching meta data. ##
#' .getMeta(conn, '%')
#' .getMeta(conn, 'name')
#'
#' ## Example of retrieving PPI data. ## 
#' .getPPI(conn, 'a', cutoff=0, encoding='ensembl', as.list=FALSE, simplify=FALSE)  # Here, we are cheating with the encoding...
#' 
#' dbDisconnect(conn)
NULL

library(RSQLite)

#' Known gene/protein encodings, i.e. type of identifiers such as Ensembl or Entrez.
#' @name known.encodings
#' @aliases .known.encodings
#' @export .known.encodings
.known.encodings <- c('ensembl','entrez','refseq')

#' Generic function for retrieving meta-data from organism data packages.
#'
#' @param conn Database connection to STRING.db-sqlite database.
#' @param key Character vector of which keys to retrieve; use sqlite syntax for wildcards (e.g. % to match all characters). Defaults to retrieve all keys.
#' @return List with entries named by the key; return value is reduced to character vector if only one key is retrieved.
#' @author Stefan McKinnon Edwards \email{stefan.hoj-edwards@@agrsci.dk}
#' @name getMeta
#' @aliases .getMeta
#' @export .getMeta
#' @seealso \code{\link{STRING.db}}
.getMeta <- function(conn, key='%') {
  #dbReadTable(conn, 'meta')
  res <- dbGetQuery(conn, 'SELECT * FROM meta WHERE meta LIKE ?;', data.frame(key))
  res$meta = factor(res$meta)
  if (nlevels(res$meta) == 1)
    return(res$value)
  return(split(res$value, res$meta))
}


#' Generic function for retrieving the protein-protein interaction data from organism data packages.
#' 
#' @param conn Database connection to STRING.db-sqlite database.
#' @param proteins Character vector of gene/protein identifiers that are requested. 
#' @param cutoff Score cut-off; only retrieves ppi with scores larger than or equal to.
#' @param encoding Character vector of which encoding \code{proteins} is set in.
#' @param as.list Logical, restructure result to a list, see Value.
#' @param simplify Logical, should function only return a character vector of all interaction partners? Overrules \code{as.list}.
#' @return For \code{as.list} as \code{FALSE}, data.frame of three columns (\code{g1}, \code{g2}, \code{score}).
#'         For \code{as.list} as \code{TRUE}, list with entries named by \code{g1} containing all mappings in \code{g2}. \code{score} is lost.
#'         If \code{simplify} is \code{TRUE}, \code{as.list} is overruled and the returned value is a character vector.
#' @author Stefan McKinnon Edwards \email{stefan.hoj-edwards@@agrsci.dk}
#' @name getPPI
#' @aliases .getPPI
#' @export  .getPPI
#' @seealso \code{\link{known.encodings}}, \code{\link{STRING.db}}
.getPPI <- function(conn, proteins, cutoff, encoding, as.list, simplify) {
  encoding <- tolower(encoding)
  if (!encoding %in% .known.encodings) stop('Could not recognize encoding. See ::.known.encodings.')
  #tbl <- dbGetQuery(conn, "SELECT value FROM meta WHERE meta = ?;", encoding)
  tbl <- .getMeta(conn, encoding)
  if (length(tbl) == 0) stop('There does not exist any mappings for the given encoding.')  
  
  if (encoding == .getMeta(conn, 'Primary encoding')) {
  sql <- sprintf('SELECT `g1`.`gene` as `g1`, `g2`.`gene` as `g2`, `ppi`.`score` FROM geneids as g1
    INNER JOIN %s as ppi ON ppi.id1 = g1.id
    inner join geneids as g2 on g2.id=ppi.id2
    where g1.gene = @g and ppi.score >= @s;', .getMeta(conn, 'Primary PPI'))
  } else {
    sql <- sprintf('SELECT `id1` as `g1`, `id2` as `g2`, `score` as `score` FROM %s WHERE `id` = @g AND `score` >= @s', tbl)
  }
  res <- dbGetQuery(conn, sql, list(g=proteins, s=cutoff))
  
  # Three different return options
  if (simplify)
    return(unique(res[,2]))
  if (as.list)
    return(split(res[,2], as.factor(res[,1])))
  return(res)
  
}

#' Generic function for reading all saved gene/protein names of the primary type.
#' 
#' @param conn Database connection to STRING.db-sqlite database.
#' @param filter Character for filtering which names to retrieve; uses sqlite i.e. use '%' for any length wildcard, '_' for single character wildcard.
#' @author Stefan McKinnon Edwards \email{stefan.hoj-edwards@@agrsci.dk}
#' @return data.frame with one column.
#' @name getNames
#' @aliases .getNames
#' @export .getNames
.getNames <- function(conn, filter=NULL) {
  if (is.null(filter)) {
    return(dbReadTable(conn, 'geneids', row.names='id'))
  } else {
    return(dbGetQuery(conn, 'SELECT gene FROM geneids WHERE gene LIKE ?;', data.frame(filter)))
  }
}
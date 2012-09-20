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

NULL

require(RSQLite)
require(STRING.db)

.db_name <- system.file('protein.links.v9.0.9913.sqlite3', package='STRING.Bt.db')
.conn = dbConnect(dbDriver('SQLite'), .db_name)


STRING.Bt.Meta <- function(key = '%') {
  STRING.db:::.getMeta(.conn, key=key)
}

STRING.Bt.PPI <- function(proteins, cutoff=900, as.list=FALSE, simplify=FALSE) {
  STRING.db:::.getPPI(.conn, proteins=proteins, cutoff=cutoff, encoding="ensembl", as.list=as.list, simplify=simplify)
}

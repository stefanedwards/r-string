# STRING database interface
# Documentation with `roxygen2`.
#'
#' Interface package for organism protein-protein-interaction data packages
#' from STRING-db.org.
#' 
#' NB! This package neither developed nor maintained by the authors of STRING.
#'
#' @name  {package-name}-package
#' @aliases  {package-name}
#' @docType  package
#' @title STRING database interface.
#' @author  Stefan McKinnon Edwards  \email{stefan.hoj-edwards@@agrsci.dk}
#' @references
#' \url{http://code.google.com/p/r-string/}
#' @keywords  package
NULL



#require(RSQLite)
#require(STRING.db)

datacache <- new.env(hash=TRUE, parent=emptyenv())

# methods from AnnDbObj-lowAPI.R in AnnotationDbi
#setMethod("dbconn", "environment", function(x) get("dbconn", envir=x))
#setMethod("dbfile", "environment", function(x) get("dbfile", envir=x))
dbconn <- function(x) get('dbconn', envir=x)
dbfile <- function(x) get('dbfile', envir=x)

# and we continue on our own
STRING.{organism-shortname}_dbconn <- function() dbconn(datacache)
STRING.{organism-shortname}_dbfile <- function() dbfile(datacache)

STRING.{organism-shortname}_organism <- '{organism-longname}'

.onLoad <- function(libname, pkgname) {
  require(RSQLite)
  dbfile <- system.file('extdata','{dbfile}', package=pkgname, lib.loc=libname, mustWork=TRUE)
  assign("dbfile", dbfile, envir=datacache)
  
  dbconn <- dbConnect(dbDriver('SQLite'), dbfile)
  assign("dbconn", dbconn, envir=datacache)
}

.onUnload <- function(libpath) {
  dbDisconnect(STRING.Bt_dbconn())
}

#' Retrieve metadata on the compiled data.
#' 
#' Query for all or specific values of the metadata.
#' @param key Character vector of keys; supports sqlite's wildcards (% for any number of any characters, _ for single character wildcard). Defaults to retrieve all meta data.
#' @return List with entries named by the key; return value is reduced to character vector if only one key is retrieved.
#' @author Stefan McKinnon Edwards \email{stefan.hoj-edwards@@agrsci.dk}
#' @export
# @examples
# STRING.{organism-shortname}.Meta('Primary encoding')
# STRING.{organism-shortname}.Meta('entrez%')
STRING.{organism-shortname}.Meta <- function(key = '%') {
  .getMeta(dbconn(datacache), key=key)
}

#' Retrieve protein-protein interactions.
#' 
#' @param proteins Character vector of gene/protein names to query for.
#' @param cutoff Integer, only retrieves interaction that scores larger than or equal to the cutoff value. Range 1-999.
#' @param as.list Logical, restructure result to a list, see Value.
#' @param simplify Logical, should function only return a character vector of all interaction partners? Overrules \code{as.list}.
#' @return For \code{as.list} as \code{FALSE}, data.frame of three columns (\code{g1}, \code{g2}, \code{score}).
#'         For \code{as.list} as \code{TRUE}, list with entries named by \code{g1} containing all mappings in \code{g2}. \code{score} is lost.
#'         If \code{simplify} is \code{TRUE}, \code{as.list} is overruled and the returned value is a character vector.
#' @author Stefan McKinnon Edwards \email{stefan.hoj-edwards@@agrsci.dk}
#' @export
# @example STRING.Bt.PPI('ENSBTAP00000000017')
STRING.{organism-shortname}.PPI <- function(proteins, cutoff=900, as.list=FALSE, simplify=FALSE) {
  STRING.db::getPPI(dbconn(datacache), proteins=proteins, cutoff=cutoff, encoding="{primary-encoding}", as.list=as.list, simplify=simplify)
}


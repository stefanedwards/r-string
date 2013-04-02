# STRING database interface
# Documentation with `roxygen2`.
#'
#' Datapackage for protein-protein interactions for {organism-longname} .
#' 
#' This package contains the data for protein-protein interaction for {organism-longname}
#' from STRING-db.org.
#' 
#' Functions of interest:
#' \enumerate{
#'  \item \code{\link{STRING.{organism-shortname}.PPI}}
#'  \item \code{\link{STRING.{organism-shortname}.Meta}}
#'  \item \code{\link{STRING.{organism-shortname}.Names}}
#'  {rd-datapackages}
#' }
#' 
#' This package uses the interface package \pkg{\link[STRING.db]{STRING.db}}, 
#' which should have been installed alongside with this.
#' 
#' @note
#' This package neither developed nor maintained by the authors of STRING-db!
#' 
#' @name  {package-name}-package
#' @aliases  {package-name}
#' @docType  package
#' @title STRING database interface.
#' @author  Stefan McKinnon Edwards  \email{stefan.hoj-edwards@@agrsci.dk}
#' @references
#'   Project website - \url{http://code.google.com/p/r-string/}
#'   \enumerate{
#'     \item Damian Szklarczyk, Andrea Franceschini, Michael Kuhn, Milan Simonovic, Alexander Roth, Pablo Minguez, Tobias Doerks, Manuel Stark, Jean Muller, Peer Bork, Lars J. Jensen, and Christian von Mering 
#'     \bold{The STRING database in 2011: functional interaction networks of proteins, globally integrated and scored.}
#'     \emph{Nucleic Acids Res.} 2011 Jan;39(Database issue):D561-8. Epub 2010 Nov 2.
#'     \url{http://nar.oxfordjournals.org/content/39/suppl_1/D561.long}
#'
#'     \item Lars J. Jensen, Michael Kuhn, Manuel Stark, Samuel Chaffron, Chris Creevey, Jean Muller, Tobias Doerks, Philippe Julien, Alexander Roth, Milan Simonovic, Peer Bork, and Christian von Mering
#'     \bold{STRING 8 - a global view on proteins and their functional interactions in 630 organisms}
#'     \emph{Nucleic Acids Res.} 2009 Jan;37(Database issue):D412-6. Epub 2008 Oct 21.
#'     \url{http://nar.oxfordjournals.org/content/37/suppl_1/D412.long}
#'
#'     \item  Christian von Mering, Lars J. Jensen, Michael Kuhn, Samuel Chaffron, Tobias Doerks, Beate Kruger, Berend Snel and Peer Bork
#'     \bold{STRING 7 - recent developments in the integration and prediction of protein interactions}
#'     \emph{Nucleic Acids Res.} 2007 Jan;35(Database issue):D358-62. Epub 2006 Nov 10.
#'     \url{http://nar.oxfordjournals.org/content/35/suppl_1/D358.long}
#'   }
#' @keywords  package
#' @examples
#' # Inspect meta data:
#' STRING.{organism-shortname}.Meta()
#' # What is primary encoding?
#' STRING.{organism-shortname}.Meta('primary')
#' # Do we cover entrez?
#' STRING.{organism-shortname}.Meta('entrez', as.bool=TRUE)
#' 
#' # Lets take a look at some of the proteins:
#' proteins <- STRING.{organism-shortname}.Names()[1:10,1]
#' ppi <- STRING.{organism-shortname}.PPI(proteins)
NULL


datacache <- new.env(hash=TRUE, parent=emptyenv())


dbconn <- function(x) get('dbconn', envir=x)
dbfile <- function(x) get('dbfile', envir=x)

#' Direct access to package DB
#' 
#' Some convenience functions for getting a connection to the behind-the-scene database or just the file name.
#' @return \code{STRING.{organism-shortname}_dbconn}: The active connection to the sqlite file.
#'      \code{STRING.{organism-shortname}_dbfile}: Path to the file.
#' @export
#' @seealso \code{\link{STRING.{organism-shortname}.Meta}}, \link[DBI:dbSendQuery]{dbSendQuery}
#' @examples
#' # Path to sqlite database file:
#' STRING.{organism-shortname}_dbfile()
STRING.{organism-shortname}_dbconn <- function() dbconn(datacache)
#' @rdname STRING.{organism-shortname}_dbconn
#' @export
STRING.{organism-shortname}_dbfile <- function() dbfile(datacache)

STRING.{organism-shortname}_organism <- '{organism-longname}'

.onLoad <- function(libname, pkgname) {
  #require(RSQLite)
  dbfile <- system.file('extdata','{dbfile}', package=pkgname, lib.loc=libname, mustWork=TRUE)
  assign("dbfile", dbfile, envir=datacache)
  
  dbconn <- DBI::dbConnect(DBI::dbDriver('SQLite'), dbfile)
  assign("dbconn", dbconn, envir=datacache)
}

.onUnload <- function(libpath) {
  dbDisconnect(STRING.{organism-shortname}_dbconn())
}

#' Retrieve metadata on the compiled data.
#' 
#' Query for all or specific values of the metadata.
#' @param key Character vector of keys; supports sqlite's wildcards (% for any number of any characters, _ for single character wildcard). Defaults to retrieve all meta data.
#' @param as.bool Coerce result into logical. Useful if requesting known keys.
#' @return List with entries named by the key; return value is reduced to character vector if only one key is retrieved.
#' @author Stefan McKinnon Edwards \email{stefan.hoj-edwards@@agrsci.dk}
#' @seealso \code{\link[STRING.{organism-shortname}_dbconn]{dbconn}}
#' @export
# @examples
# STRING.{organism-shortname}.Meta('Primary encoding')
# STRING.{organism-shortname}.Meta('entrez%')
STRING.{organism-shortname}.Meta <- function(key = '%', as.bool=FALSE) {
  STRING.db:::getMeta(dbconn(datacache), key=key)
}

#' Retrieve protein-protein interactions.
#' 
#' @param proteins Character vector of gene/protein names to query for.
#' @param cutoff Integer, only retrieves interaction that scores larger than or equal to the cutoff value. Range 1-999.
#' @param encoding String of which encoding \code{proteins} is set in.
#' @param as.list Logical, restructure result to a list, see Value.
#' @param simplify Logical, should function only return a character vector of all interaction partners? Overrules \code{as.list}.
#' @return For \code{as.list} as \code{FALSE}, data.frame of three columns (\code{g1}, \code{g2}, \code{score}).
#'         For \code{as.list} as \code{TRUE}, list with entries named by \code{g1} containing all mappings in \code{g2}. \code{score} is lost.
#'         If \code{simplify} is \code{TRUE}, \code{as.list} is overruled and the returned value is a character vector.
#' @author Stefan McKinnon Edwards \email{stefan.hoj-edwards@@agrsci.dk}
#' @seealso \code{\link{STRING.{organism-shortname}.Names}}, \code{\link{STRING.{organism-shortname}.Table}}
#' @export
# @example STRING.Bt.PPI('ENSBTAP00000000017')
STRING.{organism-shortname}.PPI <- function(proteins, cutoff=900, encoding="{primary-encoding}", as.list=FALSE, simplify=FALSE) {
  STRING.db::getPPI(dbconn(datacache), proteins=proteins, cutoff=cutoff, encoding=encoding, as.list=as.list, simplify=simplify)
}


#' Retrieve all protein/gene names.
#' 
#' @param encoding String of which encoding \code{proteins} is set in. Defaults to primary encoding.
#' @param filter Character for filtering which names to retrieve; uses sqlite i.e. use \sQuote{\%} for any length wildcard, \sQuote{_} for single character wildcard.
#'        Default \code{NULL} for no filtering, i.e. retrieve all names.
# @author Stefan McKinnon Edwards \email{stefan.hoj-edwards@@agrsci.dk}
#' @return data.frame with one column.
#' @seealso \code{\link{STRING.{organism-shortname}.PPI}}, \code{\link{STRING.{organism-shortname}.Table}}
#' @export
STRING.{organism-shortname}.Names <- function(encoding="{primary-encoding}", filter=NULL) {
  STRING.db::getNames(conn=dbconn(datacache), encoding=encoding, filter=filter)
}

#' Retrieve all protein-protein interactions
#' 
#' @param encoding String of which encoding \code{proteins} is set in. Defaults to primary encoding.
#'        Default \code{NULL} for no filtering, i.e. retrieve all names.
# @author Stefan McKinnon Edwards \email{stefan.hoj-edwards@@agrsci.dk}
#' @return data.frame with three columns.
#' @seealso \code{\link{STRING.{organism-shortname}.Names}}, \code{\link{STRING.{organism-shortname}.PPI}}
#' @export
STRING.{organism-shortname}.Table <- function(encoding="{primary-encoding}") {
  STRING.db::getAllLinks(conn=dbconn(datacache), encoding=encoding)
}

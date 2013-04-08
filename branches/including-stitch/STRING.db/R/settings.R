#############################
## Settings for filenames and urls
#############################

#' Auxiliary function: Formats version numbers to include one digit.
#' 
#' @param d Integer/numeric value to format.
#' @return String, rounded to 1 digit.
#' @export
fmt.v <- function(d) sprintf('%.1f', d)

#' Auxiliary functions: Opens any file as connection
#' 
#' Determines based on extension, whether the file should be 
#' opened with \code{file}, \code{gzfile} or \code{bzfile}.
#' @param fn Filename
#' @param open Mode for opening file (r, w, rb, etc.). Defaults to 'r'.
#' @param ... Additional arguments passed to \code{file}, \code{gzfile} or \code{bzfile}.
#' @return Connection to file.
opener <- function(fn, open='r', ...) {
  if (substr(fn, nchar(fn)-2, 40) == '.gz') 
    return(gzfile(fn, open=open, ...))
  if (substr(fn, nchar(fn)-2, 40) == 'bz2')
    return(bzfile(fn, open=open, ...))
  return(file(fn, open=open, ...))
}

string.db.fn <- '%s.%s.sqlite3'

#' Latest registred version of STRING-db.
#' @export
Latest.STRING.version <- 9.05

#' Settings for downloading data from STRING website.
#' 
#' Returns filenames and urls for download flatfile and for indexes and such.
#' @param version Numeric value of STRING version.
#' @return List with six elements:
#'   \describe{
#'     \item{\code{url}}{Full url for downloading filename.}
#'     \item{\code{fn}}{Basename of url.}
#'     \item{\code{fn.base}}{ Basename of file, excluding .txt.gz extension.}
#'     \item{\code{index.fn}}{Filename of text-index.}
#'     \item{\code{idx.fn}}{Filename of binary (.RData) index.}
#'     \item{\code{org.fn}}{Function that returns filename for organism data rom flatfile. Requires one argument.}
#'   }
#' @export
www.settings <- function(version) {
  v <- fmt.v(version)

  res <- list()

  if (version == 9.05) {
    res$url <- 'http://string-db.org/newstring_download' 
  } else if (version == 9) {
    res$url <- 'http://string90.embl.de/newstring_download'
  } else if (version == 8.3) {
    res$url <- 'http://string83.embl.de/newstring_download'
  } else if (version == 8.2) {
    res$url <- 'http://string82.embl.de/newstring_download'
  }
  if (version > 8) {
    fn.base <- sprintf('protein.links.v%s', version)
    res$fn.base <- fn.base
    res$fn <- paste(fn.base, '.txt.gz', sep='')
  }

  res$url <- paste(res$url, res$fn, sep='/')
  res$index.fn <- paste(res$fn.base, 'index', sep='.')
  res$idx.fn <- paste(res$fn.base, 'idx', sep='.')

  res$org.fn <- function(tax.id) paste(fn.base, tax.id, 'tab', sep='.')


  if (length(res) != 6) stop(paste('Could resolve urls and filenames for STRING version', v, '.', sep=''))

  return(res)
}


#' Function for mapping ensembl to entrez
#' 
#' Takes all names in id1 in ensembl and maps them to entrez, and likewise for id2. 
#' This may give a  ``row explosion'' as it is quite likeli that one identifier maps to several others.
#' In this case, if 'a':c('b','c') and 'a'->'A1,A2', 'b'->'B1,B2', 'c'->NULL then,
#' 'A1':c('B1','B2'),'A2':c('B1','B2').
#' 
#' @param ppi data.frame with three columns, id1, id2 and score. First two columns must be character vectors of the names.
#' @param db Name of BioC annotation package for mapping, e.g. org.Bt.eg.db.
#' @param keytype Name of BioC keytype, e.g. \code{ENSEMBLPROT}, see \code{\link[AnnotationDbi:AnnotationDb-class]{cols}}.
#' @param cols Name of destination keytype, e.g. \code{ENTREZID}.
#' @return New data.frame with same names and type, but with the two first columns replaced with entrez identifiers.
#' @author  Stefan McKinnon Edwards  \email{stefan.hoj-edwards@@agrsci.dk}
#' @export
ens2eg <- function(ppi, db, keytype, cols) {
  .stringAsFactors <- getOption('stringAsFactors')
  options(stringAsFactors=FALSE)
  require(db, character.only=TRUE)
  
  #ens2ent <- AnnotationFuncs::translate(ppi[,1:2], get(obj), return.list=FALSE)
  #ens2ent$from <- as.character(ens2ent$from)
  #ens2ent$to <- as.integer(ens2ent$to)
  
  k <- unique(c(ppi[,1], ppi[,2]))
  ens2ent <- select(get(db), keys=k, keytype=keytype, cols=cols)
  ens2ent <- ens2ent[!is.na(ens2ent[,2]),]
  ens2ent$ENTREZID <- as.integer(ens2ent$ENTREZID)
  
  
  ppi.entrez <- merge(ppi, ens2ent, by.x='id1', by.y=keytype, all.x=FALSE, all.y=FALSE) #ENSBTAP00000000230
  ppi.entrez$id1 <- NULL
  names(ppi.entrez)[names(ppi.entrez) == cols] <- 'id1'
  
  
  ppi.entrez <- merge(ppi.entrez, ens2ent, by.x='id2', by.y=keytype, all.x=FALSE, all.y=FALSE) #ENSBTAP00000000230
  ppi.entrez$id2 <- NULL # 5702 5871
  names(ppi.entrez)[names(ppi.entrez) == cols] <- 'id2'
  
  attr(ppi.entrez, 'meta') <- data.frame(meta=c('entrez version','entrez source'), 
                                         value=c(as.character(packageVersion(db)), db) )
  
  options(stringAsFactors=.stringAsFactors)
  return(ppi.entrez)
}

#' Auxiliary function: Forcing vectors into logical.
#' 
#' If a vector or list is zero-length, then it will always return FALSE.
#' Otherwise, it applies \code{as.logical} to the argument.
#' @return Argument coerced to boolean/logical vector/list.
#' @param x Vector or list.
#' @examples
#' STRING.db:::as.bool(c(TRUE, FALSE, 'TRUE', 'FALSE', '0', '1', 0, 1))
#' STRING.db:::as.bool(list(TRUE, FALSE, 'TRUE', 'FALSE', '0', '1', 0, 1))
as.bool <- function(x) {
  if (length(x) == 0)
    return(FALSE)
  return(as.logical(x))
}

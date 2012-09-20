#settings


#' Formats version numbers to include one digit.
#' 
#' @return String, rounded to 1 digit.
fmt.v <- function(d) sprintf('%.1f', d)


#string.version <- 9.0
# define string templates to use with sprintf.
#string.fn <- 'protein.links.v%.1f.txt.gz'
#string.url <- 'http://string-db.org/newstring_download/%s'
string.tax.fn <- '%s.%s.tab'  # {protein.links.v.9.0}.{9606}.tab'
string.db.fn <- '%s.%s.sqlite3'


#' Settings for downloading data from STRING website
#' 
#' String templates are resolved using \code{sprintf}.
www.settings <- list(
  `9.0`=list(url='http://string-db.org/newstring_download/%s', fn='protein.links.v%.1f.txt.gz')
  )
www.settings <- function(version) 
  v <- fmt.v(version)

  if (is.null(w.s)) stop(paste('Could resolve urls and filenames for STRING version', v, '.', sep=''))

  res <- list()

  if (version == 9) {
    res$url <- 'http://string-db.org/newstring_download/%s' 
  }
  if (version > 8) {
    res$fn <- sprintf('protein.links.v%.1f.txt.gz', version)
  }
  if (length(res) != 2) stop(paste('Could resolve urls and filenames for STRING version', v, '.', sep=''))

  return(res)
}

#############################
## Organism specific settings
#############################
organisms <- list()
organisms$'9913' <- list(short='Bt', long='Bos taurus', primary='ensembl', map2entrez=make.ens2eg('org.Bt.eg.db','org.Bt.egENSEMBLPROT2EG'))
organisms$'9913' <- list(short='Hs', long='Homo sapiens', primary='ensembl', map2entrez=make.ens2eg('org.Hs.eg.db','org.Hs.egENSEMBLPROT2EG'))

fpaste <- function(...) paste(..., sep='.')

## automatic rewriting variables
#string.fn <- sprintf(string.fn, string.version)
#string.url <- sprintf(string.url, string.fn)
#string.fn.base <- sub('\\.txt\\.(gz|bz2)','',string.fn)

#string.index.fn <- fpaste(string.fn.base, 'index')

#' Function for mapping ensembl to entrez
#' 
#' Takes all names in id1 in ensembl and maps them to entrez, and likewise for id2. 
#' This may give a  ``row explosion'' as it is quite likeli that one identifier maps to several others.
#' In this case, if 'a':c('b','c') and 'a'->'A1,A2', 'b'->'B1,B2', 'c'->NULL then,
#' 'A1':c('B1','B2'),'A2':c('B1','B2').
#' 
#' @param ppi data.frame with three columns, id1, id2 and score. First two columns must be character vectors of the names.
#' @param db Name of BioC annotation package for mapping, e.g. org.Bt.eg.db.
#' @param obj Name of BioC map, e.g. org.Bt.egENSEMBLPROT2EG.
#' @return New data.frame with same names and type, but with the two first columns replaced with entrez identifiers.
#' @author  Stefan McKinnon Edwards  \email{stefan.hoj-edwards@@agrsci.dk}
ens2eg <- function(ppi, db, obj) {
  .stringAsFactors <- getOption(stringAsFactors)
  options(stringAsFactors=FALSE)
  require(AnnorationFuncs)
  require(db, character.only=TRUE)
  
  ens2ent <- AnnotationFuncs::translate(ppi[,1:2], get(obj), return.list=FALSE)
  ens2ent$from <- as.character(ens2ent$from)
  ens2ent$to <- as.integer(ens2ent$to)
  
  ppi.entrez <- merge(ppi, ens2ent, by.x='id1', by.y='from', all.x=FALSE, all.y=FALSE) #ENSBTAP00000000230
  ppi.entrez$id1 <- NULL
  names(ppi.entrez)[names(ppi.entrez) == 'to'] <- 'id1'
  
  
  ppi.entrez <- merge(ppi.entrez, ens2ent, by.x='id2', by.y='from', all.x=FALSE, all.y=FALSE) #ENSBTAP00000000230
  ppi.entrez$id2 <- NULL # 5702 5871
  names(ppi.entrez)[names(ppi.entrez) == 'to'] <- 'id2'
  
  attr(ppi.entrez, 'meta') <- data.frame(meta='entrez version', value=read.dcf(system.file('DESCRIPTION',package=org.settings$db), 'Version'))
    
  options(stringAsFactors=.stringAsFactors)
  return(ppi.entrez)
}
#' @rdname ens2eg
#' @inheritParams ens2eg
make.ens2eg <- function(db, obj) {
  return(function(ppi) ens2eg(ppi, db, obj))
}

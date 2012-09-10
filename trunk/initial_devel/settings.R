#settings

string.version <- 9.0
# define string templates to use with sprintf.
string.fn <- 'protein.links.v%.1f.txt.gz'
string.url <- 'http://string-db.org/newstring_download/%s'
string.tax.fn <- '%s.%s.tab'  # {protein.links.v.9.0}.{9606}.tab'
string.db.fn <- '%s.%s.sqlite3'

## settings for organisms
organisms <- list()
organisms$'9913' <- list(short='Bt', db='org.Bt.eg.db', conn='org.Bt.eg_dbconn', ens2eg='org.Bt.egENSEMBLPROT2EG', has.entrez=TRUE)
organisms$'9606' <- list(short='Hs', db='org.Hs.eg.db', conn='org.Hs.eg_dbconn', ens2eg='org.Hs.egENSEMBLPROT2EG',has.entrez=TRUE)


# some auxillary functions  
string.f.opener <- function(fn) {
  if (substr(string.fn, nchar(string.fn)-2, 40) == '.gz') 
    return(gzfile(fn, open='r'))
  if (substr(string.fn, nchar(string.fn)-2, 40) == 'bz2')
    return(bzfile(fn, open='r'))
}

fpaste <- function(...) paste(..., sep='.')

## automatic rewriting variables
string.fn <- sprintf(string.fn, string.version)
string.url <- sprintf(string.url, string.fn)
string.fn.base <- sub('\\.txt\\.(gz|bz2)','',string.fn)

string.index.fn <- fpaste(string.fn.base, 'index')


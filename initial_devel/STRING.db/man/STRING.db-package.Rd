\docType{package}
\name{STRING.db-package}
\alias{STRING.db}
\alias{STRING.db-package}
\title{STRING database interface.}
\description{
  Interface package for organism
  protein-protein-interaction data packages from
  STRING-db.org.
}
\details{
  NB! This package neither developed nor maintained by the
  authors of STRING.
}
\examples{
library(RSQLite)

## Crude example of the data we expect to find in the organism data packages. ##
conn <- dbConnect(dbDriver('SQLite'), ':memory:')
meta <- data.frame(meta=c('ensembl','Primary encoding','Primary PPI','name','bla','bla','dude'), value=c('ppi','ensembl','ppi','lolcat','chezburger','rainbow','greg'))
dbWriteTable(conn, 'meta', meta, row.names=FALSE, overwrite=TRUE)

geneid <- data.frame(id=1:4, gene=letters[1:4])
dbWriteTable(conn, 'geneids', geneid, row.names=FALSE, overwrite=TRUE)

ppi <- data.frame(id1=c(rep(1, 3), rep(2, 2), rep(3,3), rep(4,2)), id2=c(2,3,4, 1,3, 1,2,4, 1,3), score=c(950, 900, 700,  950, 900,  900, 900, 700,  700, 700))
dbWriteTable(conn, 'ppi', ppi, row.names=FALSE, overwrite=TRUE)

## Example of fetching meta data. ##
STRING.db:::.getMeta(conn, '\%')
STRING.db:::.getMeta(conn, 'name')

## Example of retrieving PPI data. ##
STRING.db:::.getPPI(conn, 'a', cutoff=0, encoding='ensembl', as.list=FALSE, simplify=FALSE)  # Here, we are cheating with the encoding...

dbDisconnect(conn)
}
\author{
  Stefan McKinnon Edwards
  \email{stefan.hoj-edwards@agrsci.dk}
}
\references{
  \url{http://code.google.com/p/r-string/}
}
\seealso{
  \code{\link{getMeta}}, \code{\link{getPPI}}
}
\keyword{package}


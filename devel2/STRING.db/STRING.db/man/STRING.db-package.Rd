\docType{package}
\name{STRING.db-package}
\alias{STRING.db}
\alias{STRING.db-package}
\title{STRING-db creation utility and database interface package}
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

destdir <- 'test'
\dontrun{
  # To download the entire STRING flatfile from the web.
  fn <- download.flatfile(9.0, destdir)
  taxonomies <- c('9913','9606')
  res <- index.flatfile(fn, destdir, taxonomies)
}

# We however do it with the example data set.
fn <- system.file('extdata','example.data.txt', package='STRING.db', mustWork=TRUE)
taxonomies <- c('001','002','003')
org.fn <- function(taxo) paste('test',taxo,'tab',sep='.')
idx.fn <- 'text.idx'
index.fn <- 'test.index'
res <- index.flatfile(fn, destdir, taxonomies, org.fn, idx.fn, index.fn)

for (taxo in taxonomies) {
  makePackage(taxo, res$fn[taxo], STRING.db::Latest.STRING.version)
}
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


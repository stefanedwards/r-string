\name{example.data}
\alias{example.data}
\docType{data}
\title{Imaginary example of protein.links flatfile.}
\description{This is a small imaginary example of the data found in protein.links.
    The taxonomy ids and protein ids have no correlation with the real world.
}
\format{Space-tabulated text file with three columns, id1, id2 and score.}
\source{From the bottomth of the coffee cupth.}
\examples{
destdir <- tempdir()
fn <- system.file('extdata','example.data.txt', package='STRING.db')
taxonomies <- c('001','002','003')
org.fn <- function(taxo) paste('test',taxo,'tab',sep='.')
idx.fn <- 'text.idx'
index.fn <- 'test.index'
res <- index.flatfile(fn, destdir, taxonomies, org.fn, idx.fn, index.fn)

\dontrun{
# Proceed perhaps with creation of package?
taxo <- '001'
nm <- makePackage(tax.id=taxo, flatfile.fn=res$fn[taxo], string.v=0, cutoffs=c(800,900,950), organism=STRING.db:::organisms[[taxo]])
}
}
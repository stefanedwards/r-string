\name{make.sqlite}
\alias{make.sqlite}
\title{Makes sqlite database for organism}
\usage{
  make.sqlite(tax.id, flatfile.fn, sqlite.fn,
    organism = NULL, src.dir = ".", dest.dir = ".")
}
\arguments{
  \item{tax.id}{String with taxonomy id, e.g. 9913 for
  cattle.}

  \item{flatfile.fn}{Filename of input flatfile from
  \code{\link{extract.flatfile}} or
  \code{\link{index.flatfile}}.}

  \item{sqlite.fn}{Filename of resulting sqlite db file.}

  \item{organism}{List matching an organism entry in
  \code{\link{organisms}}.  If \code{NULL}, it will be
  pulled from \code{\link{organisms}}.}

  \item{src.dir}{Path to location where organism specific
  flatfiles are.}

  \item{dest.dir}{Path to where resulting sqlite db file
  should be placed.}
}
\description{
  Makes sqlite database for organism
}


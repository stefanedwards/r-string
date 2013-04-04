\name{make.sqlite}
\alias{make.sqlite}
\title{Makes sqlite database for organism}
\usage{
  make.sqlite(tax.id, flatfile.fn, sqlite.fn,
    organism = NULL, string.v = NULL)
}
\arguments{
  \item{tax.id}{String with taxonomy id, e.g. 9913 for
  cattle.}

  \item{flatfile.fn}{Path to input flatfile from
  \code{\link{extract.flatfile}} or
  \code{\link{index.flatfile}}.}

  \item{sqlite.fn}{Path to resulting sqlite db file.}

  \item{organism}{List matching an organism entry in
  \code{\link{organisms}}.  If \code{NULL}, it will be
  pulled from \code{\link{organisms}}.}

  \item{string.v}{Value to put in meta-table for key
  \code{STRING-db}.}
}
\value{
  Live connection to sqlite database.
}
\description{
  Makes sqlite database for organism
}
\note{
  Will remove any prior file with same name as
  \code{sqlite.fn}.
}


\name{makePackage}
\alias{makePackage}
\title{Compiles a datapackage for a specified organism.}
\usage{
  makePackage(tax.id, flatfile.fn, string.v,
    cutoffs = c(800, 900, 950), organism = NULL,
    package.name = NULL)
}
\arguments{
  \item{tax.id}{String with taxonomy id, e.g. 9913 for
  cattle.}

  \item{flatfile.fn}{Path to input flatfile from
  \code{\link{extract.flatfile}} or
  \code{\link{index.flatfile}}.}

  \item{string.v}{Version of STRING-db.}

  \item{cutoffs}{Integer vector of cutoff values for
  pre-packaged datafiles.}

  \item{organism}{List-object specifying organism settings.
  If \code{NULL}, it is pulled from
  \code{\link{organisms}}.}

  \item{package.name}{Name of package that will be created.
  Defaults to STRING.[abbr].db.}
}
\description{
  Takes the extracted data by
  \code{\link{index.flatfile}} or
  \code{\link{extract.flatfile}} and compiles it into a
  ready-to-use package for R.
}


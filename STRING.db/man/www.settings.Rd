\name{www.settings}
\alias{www.settings}
\title{Settings for downloading data from STRING website.}
\usage{
  www.settings(version)
}
\arguments{
  \item{version}{Numeric value of STRING version.}
}
\value{
  List with six elements: \describe{ \item{\code{url}}{Full
  url for downloading filename.} \item{\code{fn}}{Basename
  of url.} \item{\code{fn.base}}{ Basename of file,
  excluding .txt.gz extension.}
  \item{\code{index.fn}}{Filename of text-index.}
  \item{\code{idx.fn}}{Filename of binary (.RData) index.}
  \item{\code{org.fn}}{Function that returns filename for
  organism data rom flatfile. Requires one argument.} }
}
\description{
  Returns filenames and urls for download flatfile and for
  indexes and such.
}


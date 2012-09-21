\name{index.flatfile}
\alias{extract.flatfile}
\alias{index.flatfile}
\title{Indexes and extracts the protein.links flatfile.}
\usage{
  index.flatfile(fn, destdir = ".", taxonomies = NULL,
    org.fn = NULL, idx.fn = NULL, index.fn = NULL)

  extract.flatfile(fn, destdir = ".", taxonomies = NULL,
    org.fn = NULL, idx = NULL)
}
\arguments{
  \item{fn}{Filename of flatfile, relative to destdir, or
  list result from \code{\link{www.settings}}, in which
  case the remaining relevant arguments should be left out,
  or they will overrule contents of \code{fn}.}

  \item{destdir}{Directory (relative or absolut) for input
  and output files.}

  \item{taxonomies}{Character vector of the tax ids to
  extract.  If \code{NULL}, nothing is extracted.}

  \item{org.fn}{Filename function for making filenames for
  organism sections; recieves tax id as argument.}

  \item{idx.fn}{String with filename relative to dest dir
  for binary index.}

  \item{index.fn}{String with filename relative to dest dir
  for text index.}

  \item{idx}{Integer vector named by tax id necessary for
  extraction (see note) or filename where it can be loaded
  from.  Could be result from \code{\link{index.flatfile}}.
  If \code{NULL} and \code{fn} is list, filename of index
  is extracted and loaded.}
}
\value{
  List: \code{index} Integer vector with index of all tax
  ids, \code{found} Logical vector matching which tax ids
  in \code{taxonomies} were found and \code{fn} Character
  vector of paths to organism flatfiles.
}
\description{
  Uses tax id in column 1 to distinguish new section and
  outputs the corresponding line number.

  Extracts organism sections from protein.links flatfile.
}
\note{
  For \code{extract.flatfile}, the index \code{idx} should
  not only cover the tax ids of interest, but also the
  subsequent tax id in the list!  The tax ids in the index
  must also be ordered in same order as found in the
  protein.links flatfile.
}
\section{Side effects}{
  Will create a new file in \code{destdir} for each found
  tax id in \code{taxonomies}, as well as two index-files
  (binary and ordinary .RData-type, but with .idx
  extension.)
}


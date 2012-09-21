\name{opener}
\alias{opener}
\title{Auxiliary functions: Opens any file as connection}
\usage{
  opener(fn, open = "r", ...)
}
\arguments{
  \item{fn}{Filename}

  \item{open}{Mode for opening file (r, w, rb, etc.).
  Defaults to 'r'.}

  \item{...}{Additional arguments passed to \code{file},
  \code{gzfile} or \code{bzfile}.}
}
\value{
  Connection to file.
}
\description{
  Determines based on extension, whether the file should be
  opened with \code{file}, \code{gzfile} or \code{bzfile}.
}


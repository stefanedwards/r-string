\name{download.flatfile}
\alias{download.flatfile}
\title{Downloads the protein.links flatfile from internets.}
\usage{
  download.flatfile(version, destdir = ".")
}
\arguments{
  \item{version}{Integer or numeric of STRING version.}

  \item{destdir}{Destination directory for file.}
}
\value{
  Logical for success.
}
\description{
  Downloads the gzipped file to working directory.
  Destination directory is created if not exists.
}


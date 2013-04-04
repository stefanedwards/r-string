\name{write.ppi.table}
\alias{write.ppi.table}
\title{Writes ppi-data.frame to database.}
\usage{
  write.ppi.table(conn, ppi, encoding)
}
\arguments{
  \item{conn}{Live connection to database.}

  \item{ppi}{Data.frame with three columns, id1, id2 and
  score.}

  \item{encoding}{String naming the encoding (e.g. entrez
  or ensembl).}
}
\description{
  Maps the gene/protein names to an integer id (if
  necessary).
}


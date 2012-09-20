\name{getPPI}
\alias{getPPI}
\title{Generic function for retrieving the protein-protein interaction data from organism data packages.}
\usage{
  getPPI(conn, proteins, cutoff, encoding, as.list,
    simplify)
}
\arguments{
  \item{conn}{Database connection to STRING.db-sqlite
  database.}

  \item{proteins}{Character vector of gene/protein
  identifiers that are requested.}

  \item{cutoff}{Score cut-off; only retrieves ppi with
  scores larger than or equal to.}

  \item{encoding}{Character vector of which encoding
  \code{proteins} is set in.}

  \item{as.list}{Logical, restructure result to a list, see
  Value.}

  \item{simplify}{Logical, should function only return a
  character vector of all interaction partners? Overrules
  \code{as.list}.}
}
\value{
  For \code{as.list} as \code{FALSE}, data.frame of three
  columns (\code{g1}, \code{g2}, \code{score}).  For
  \code{as.list} as \code{TRUE}, list with entries named by
  \code{g1} containing all mappings in \code{g2}.
  \code{score} is lost.  If \code{simplify} is \code{TRUE},
  \code{as.list} is overruled and the returned value is a
  character vector.
}
\description{
  Generic function for retrieving the protein-protein
  interaction data from organism data packages.
}
\author{
  Stefan McKinnon Edwards
  \email{stefan.hoj-edwards@agrsci.dk}
}
\seealso{
  \code{\link{known.encodings}}, \code{\link{STRING.db}}
}


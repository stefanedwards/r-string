\name{makeCache}
\alias{makeCache}
\title{Prepares a data object with all data.}
\usage{
  makeCache(conn, encoding, cutoff)
}
\arguments{
  \item{conn}{Live connection to database.}

  \item{encoding}{String naming the encoding (e.g. entrez
  or ensembl).}

  \item{cutoff}{Score cut-off; only retrieves ppi with
  scores larger than or equal to.}
}
\value{
  List with names as id1 and elements as id2.
}
\description{
  Prepares a data object with all data.
}
\seealso{
  \code{\link{cacheObject}}.
}


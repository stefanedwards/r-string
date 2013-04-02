\name{getAllLinks}
\alias{getAllLinks}
\alias{getAllLinks.0.2}
\title{Generic function for getting all protein-protein links}
\usage{
  getAllLinks(conn, encoding, cutoff)

  getAllLinks.0.2(conn, encoding, cutoff)
}
\arguments{
  \item{conn}{Database connection to STRING.db-sqlite
  database.}

  \item{encoding}{String of which encoding \code{proteins}
  is set in. Defaults to primary encoding.}

  \item{cutoff}{Cut-off of score, i.e. get all links with
  score greater than or equal to.}
}
\value{
  data.frame with three columns.
}
\description{
  \code{getAllLinks.x.y} are database schema dependant
  functions for doing the actual work.
}
\seealso{
  \link{getNames}, \link{getPPI}
}


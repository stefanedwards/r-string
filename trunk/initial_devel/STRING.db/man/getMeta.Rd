\name{getMeta}
\alias{.getMeta}
\alias{getMeta}
\title{Generic function for retrieving meta-data from organism data packages.}
\usage{
  .getMeta(conn, key = "\%")
}
\arguments{
  \item{conn}{Database connection to STRING.db-sqlite
  database.}

  \item{key}{Character vector of which keys to retrieve;
  use sqlite syntax for wildcards (e.g. % to match all
  characters). Defaults to retrieve all keys.}
}
\value{
  List with entries named by the key; return value is
  reduced to character vector if only one key is retrieved.
}
\description{
  Generic function for retrieving meta-data from organism
  data packages.
}
\author{
  Stefan McKinnon Edwards
  \email{stefan.hoj-edwards@agrsci.dk}
}
\seealso{
  \code{\link{STRING.db}}
}


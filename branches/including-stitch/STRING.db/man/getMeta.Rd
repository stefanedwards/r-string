\name{getMeta}
\alias{getMeta}
\alias{getMeta.0.2}
\title{Generic function for retrieving meta-data from organism data packages.}
\usage{
  getMeta(conn, key = "\%", as.bool = FALSE)

  getMeta.0.2(conn, key)
}
\arguments{
  \item{conn}{Database connection to STRING.db-sqlite
  database.}

  \item{key}{Character vector of which keys to retrieve;
  use sqlite syntax for wildcards (e.g. % to match all
  characters). Defaults to retrieve all keys.}

  \item{as.bool}{Coerce result into logical. Useful if
  requesting known keys.}
}
\value{
  List with entries named by the key; return value is
  reduced to character vector if only one key is retrieved.
}
\description{
  Generic function for retrieving meta-data from organism
  data packages.
}
\seealso{
  \code{\link{STRING.db}}
}


\name{getNames}
\alias{getNames}
\alias{getNames.0.1}
\alias{getNames.0.2}
\title{Generic function for reading all saved gene/protein names of the primary type.}
\usage{
  getNames(conn, encoding = NULL, filter = NULL)

  getNames.0.1(conn, encoding, filter)

  getNames.0.2(conn, encoding, filter)
}
\arguments{
  \item{conn}{Database connection to STRING.db-sqlite
  database.}

  \item{encoding}{String of which encoding \code{proteins}
  is set in. Defaults to primary encoding.}

  \item{filter}{Character for filtering which names to
  retrieve; uses sqlite i.e. use \sQuote{\%} for any length
  wildcard, \sQuote{_} for single character wildcard.}
}
\value{
  data.frame with one column.
}
\description{
  \code{getNames.x.y} are database schema dependant
  functions for doing the actual work.
}


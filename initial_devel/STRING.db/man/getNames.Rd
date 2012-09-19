\name{getNames}
\alias{.getNames}
\alias{getNames}
\title{Generic function for reading all saved gene/protein names of the primary type.}
\usage{
  .getNames(conn, filter = NULL)
}
\arguments{
  \item{conn}{Database connection to STRING.db-sqlite
  database.}

  \item{filter}{Character for filtering which names to
  retrieve; uses sqlite i.e. use '%' for any length
  wildcard, '_' for single character wildcard.}
}
\value{
  data.frame with one column.
}
\description{
  Generic function for reading all saved gene/protein names
  of the primary type.
}
\author{
  Stefan McKinnon Edwards
  \email{stefan.hoj-edwards@agrsci.dk}
}


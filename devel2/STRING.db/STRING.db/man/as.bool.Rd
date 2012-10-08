\name{as.bool}
\alias{as.bool}
\title{Auxiliary function: Forcing vectors into logical.}
\usage{
  as.bool(x)
}
\arguments{
  \item{x}{Vector or list.}
}
\value{
  Argument coerced to boolean/logical vector/list.
}
\description{
  If a vector or list is zero-length, then it will always
  return FALSE. Otherwise, it applies \code{as.logical} to
  the argument.
}
\examples{
STRING.db:::as.bool(c(TRUE, FALSE, 'TRUE', 'FALSE', '0', '1', 0, 1))
STRING.db:::as.bool(list(TRUE, FALSE, 'TRUE', 'FALSE', '0', '1', 0, 1))
}


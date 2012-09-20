\name{dbconn}
\alias{dbconn}
\alias{dbfile}
\title{Generic function for keeping sqlite-connection alive.}
\usage{
  dbconn(x)

  dbfile(x)
}
\arguments{
  \item{x}{An environment that contains the variable of
  same name as function.}
}
\value{
  The contents of the variable.
}
\description{
  Generic function for keeping sqlite-connection alive.
}
\examples{
datacache <- new.env(hash=TRUE, parent=emptyenv())

dbfile <- 'my file'
assign('dbfile', dbfile, envir=datacache)
dbconn <- 'my live connection, but you would replace with e.g. dbConnect(...).'
assign('dbconn', dbconn, envir=datacache)
}


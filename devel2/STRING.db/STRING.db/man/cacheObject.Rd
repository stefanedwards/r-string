\name{cacheObject}
\alias{cacheObject}
\title{Creates a data-object with a given variable name.}
\usage{
  cacheObject(conn, encoding, cutoff, var.name,
    envir = new.env())
}
\arguments{
  \item{conn}{Live connection to database.}

  \item{encoding}{String naming the encoding (e.g. entrez
  or ensembl).}

  \item{cutoff}{Score cut-off; only retrieves ppi with
  scores larger than or equal to.}

  \item{var.name}{The variable named that the object is
  assigned to.}

  \item{envir}{Environment where the object is saved.
  Defaults to \code{\link[base:environment]{new.env()}}.}
}
\value{
  Environement \code{envir} with the data object.
}
\description{
  Uses \code{\link{makeCache}} to make a data-object with
  all PPI's, and saves the object with a given variable
  name into an environment.
}
\seealso{
  \code{\link{makeCache}}.
}


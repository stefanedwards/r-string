\name{ens2eg}
\alias{ens2eg}
\title{Function for mapping ensembl to entrez}
\usage{
  ens2eg(ppi, db, obj)
}
\arguments{
  \item{ppi}{data.frame with three columns, id1, id2 and
  score. First two columns must be character vectors of the
  names.}

  \item{db}{Name of BioC annotation package for mapping,
  e.g. org.Bt.eg.db.}

  \item{obj}{Name of BioC map, e.g.
  org.Bt.egENSEMBLPROT2EG.}
}
\value{
  New data.frame with same names and type, but with the two
  first columns replaced with entrez identifiers.
}
\description{
  Takes all names in id1 in ensembl and maps them to
  entrez, and likewise for id2. This may give a ``row
  explosion'' as it is quite likeli that one identifier
  maps to several others. In this case, if 'a':c('b','c')
  and 'a'->'A1,A2', 'b'->'B1,B2', 'c'->NULL then,
  'A1':c('B1','B2'),'A2':c('B1','B2').
}
\author{
  Stefan McKinnon Edwards
  \email{stefan.hoj-edwards@agrsci.dk}
}


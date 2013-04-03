#!/opt/ghpc/bin/Rscript --vanilla
#PBS -l walltime=12:00:00
#PBS -N Build.STRING
#PBS -j oe


setwd(Sys.getenv('PBS_O_WORKDIR', '.'))

install.packages('STRING.db', repos=NULL)
library(STRING.db)


string.v <- 9.05
settings <- www.settings(string.v)
taxonomies <- c('9913','9606')
destdir <- '.'
org.fn <- sapply(taxonomies, settings$org.fn)
if (!all(file.exists(org.fn))) {
  if (!file.exists(settings$fn))   download.flatfile(string.v)
  if (!file.exists(settings$idx.fn)) {
    res <- index.flatfile(settings, destdir, taxonomies)
  } else {
    res <- extract.flatfile(settings, destdir, taxonomies)
  }
}

#for (taxo in taxonomies) {
taxo <- '9913'
  organism <- STRING.db:::organisms[[taxo]]
  organism$ens2eg <- organism$map2entrez
  nm <- makePackage(taxo, settings$org.fn(taxo), string.v=string.v, organism=organism)

  conn <- dbConnect(dbDriver('SQLite'), file.path(nm, 'inst/extdata', sprintf(STRING.db:::string.db.fn, 'STRING',organism$short)))
  ppi <- STRING.db::getAllLinks(conn, 'ensembl')
  STRING.db:::make.entrez.table(conn, ppi, organism$map2entrez)
  
  install.packages(nm, repos=NULL, INSTALL_opts=c('--resave-data', '--build'))
#}

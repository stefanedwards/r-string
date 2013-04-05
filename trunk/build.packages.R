#!/opt/ghpc/bin/Rscript --vanilla
#PBS -l walltime=12:00:00
#PBS -N Build.STRING
#PBS -j oe

library(STRING.db)

setwd(Sys.getenv('PBS_O_WORKDIR', '.'))

string.v <- 9.05
settings <- www.settings(string.v)
#taxonomies <- c('9913','9606')
taxonomies <- '7227'
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

for (taxo in taxonomies) {
  nm <- makePackage(taxo, settings$org.fn(taxo), string.v)
  conn <- dbConnect(dbDriver('SQLite'), file.path(nm, 'inst/extdata', sprintf(STRING.db:::string.db.fn, 'STRING', STRING.db:::organisms[[taxo]]$short)))
  ppi <- STRING.db::getAllLinks(conn, 'ensembl')
  STRING.db:::make.entrez.table(conn, ppi, STRING.db:::organisms[[taxo]]$map2entrez)
}

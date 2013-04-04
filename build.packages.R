#!/opt/ghpc/bin/Rscript --vanilla
#PBS -l walltime=12:00:00
#PBS -N Build.STRING
#PBS -j oe

library(STRING.db)

setwd(Sys.getenv('PBS_O_WORKDIR', '.'))

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

for (taxo in taxonomies) {
  makePackage(taxo, settings$org.fn(taxo), string.v)
}

#!/opt/ghpc/bin/Rscript --vanilla 
#PBS -j oe
#PBS -l walltime=04:00:00
### Testing the application of STRING.db

setwd(Sys.getenv('PBS_O_WORKDIR', '.'))

install.packages(normalizePath('STRING.db'), repos=NULL, type='source')
library(STRING.db)

taxonomies <- c(9606,9913)
settings <- www.settings(STRING.db::Latest.STRING.version)
print('Testing index.flatfile.')
#res <- index.flatfile(settings, taxonomies=taxonomies)

print('Testing extract.flatfile.')
res <- extract.flatfile(settings, taxonomies=taxonomies)

print(res)
for (taxo in taxonomies) {
  makePackage(taxo, res$fn[taxo], STRING.db::Latest.STRING.version)
}


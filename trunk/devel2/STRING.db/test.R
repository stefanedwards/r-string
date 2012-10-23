### Testing the application of STRING.db

install.packages(normalizePath('STRING.db'), repos=NULL, type='source')
library(STRING.db)

taxonomies <- c(9606,9913)
settings <- www.settings(STRING.db::Latest.STRING.version)
res <- index.flatfile(settings, taxonomies=taxonomies)
#for (taxo in taxonomies) {
#  makePackage(taxo, res$fn[taxo], STRING.db::Latest.STRING.version)
#}


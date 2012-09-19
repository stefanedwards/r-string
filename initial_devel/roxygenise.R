library(roxygen2)

roxygenise('STRING.db', roclets=c('namespace','rd'))
roxygenise('STRING.Bt.db', roclets=c('namespace','rd'))
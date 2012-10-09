########################
## Script to setup a new data package with STRING.db.
########################

install.packages(normalizePath('../STRING.db/STRING.db'), repos=NULL, type='source')
library(STRING.db)
library(tools)
library(roxygen2)

fn <- system.file('extdata','example.data.txt', package='STRING.db', mustWork=TRUE)

package.name <- 'STRING.T1.db'
destdir <- 'data'
taxonomies <- '001' #c('001','002','003','004')
taxo <- '001'
org.fn <- function(taxo) paste('test',taxo,'tab',sep='.')
idx.fn <- 'text.idx'
index.fn <- 'test.index'
encoding <- 'ensembl'

organisms <- list()
organisms$`001` <- list(short='T1', long='Test organism 1', primary=encoding)
organisms$`002` <- list(short='T2', long='Test organism 2', primary=encoding)
organisms$`003` <- list(short='T3', long='Test organism 3', primary=encoding)

res <- index.flatfile(fn, destdir, taxonomies, org.fn, idx.fn, index.fn)

dir.create(package.name)
subdirs <- c('R','inst/extdata', 'man', 'data')
sapply(subdirs, function(x) dir.create(file.path(package.name, x), recursive=TRUE))

## Create database
conn <- make.sqlite(taxo, res$fn[taxo], sqlite.fn=file.path(package.name, 'inst/extdata', sprintf(STRING.db:::string.db.fn, 'STRING',organisms[[taxo]]$short)), organism=organisms[[taxo]], string.v='Not string!')

## two data objects
cache1 <- 'T1.900.PPI'
res <- cacheObject(conn, encoding=encoding, cutoff=900, var.name=cache1)

for (n in ls(res)) 
  save(list=n, file=file.path(package.name, 'data', paste(n, '.RData', sep='')), envir=res)

# make text files
templates <- matrix(ncol=2, byrow=TRUE, dimnames=list(NULL, c('source','dest')),
                    data=c('DESCRIPTION.tpl','DESCRIPTION',
                           'all.funcs.R', 'R/all.funcs.R'))
## add scripts!

replacements <- matrix(ncol=2, byrow=TRUE, dimnames=list(NULL, c('pattern','replacement')),
                       data=c('{collate}',"'all.funcs.R",
                              '{package-version}','0.1.0',
                              '{package-date}', format(Sys.time(), "%Y-%m-%d"),
                              '{package-name}', package.name,
                              '{organism-longname}', organisms[[taxo]]$long,
                              '{organism-shortname}', organisms[[taxo]]$short,
                              '{dbfile}', sprintf(STRING.db:::string.db.fn, 'STRING',organisms[[taxo]]$short),
                              '{primary-encoding}', organisms[[taxo]]$primary
                              ))

for (i in 1:nrow(templates)) {
  tpl <- readLines(templates[i,1])
  tpl <- paste(tpl, collapse='\n')
  for (j in 1:nrow(replacements)) {
    tpl <- gsub(replacements[j,1], replacements[j,2], tpl, fixed=TRUE)
  }
  writeLines(tpl, file.path(package.name, templates[i,2]))
}


#package.skeleton(name=package.name )
roxygenise(package.name, roclets=c('namespace','rd'))
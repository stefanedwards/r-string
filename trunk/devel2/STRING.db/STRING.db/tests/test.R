#############################
## Test STRING.db
#############################

### Essentially, this is the example from example.data.
### It tries to open the example data file, extract the taxonomies and creates sqlite-files from it.
fn <- system.file('extdata','example.data.txt', package='STRING.db', mustWork=TRUE)
#
#fn <- "C:/Projects/r-string/devel2/STRING.db/STRING.db/inst/extdata/example.data.txt"
dest.dir <- 'test'
taxonomies <- c('001','002','003')
org.fn <- function(taxo) paste('test',taxo,'tab',sep='.')
idx.fn <- 'text.idx'
index.fn <- 'test.index'
res <- index.flatfile(fn, destdir, taxonomies, org.fn, idx.fn, index.fn)
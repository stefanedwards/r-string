#############################
## Test STRING.db
#############################

require(STRING.db)
require(RUnit)

### Essentially, this is the example from example.data.
### It tries to open the example data file, extract the taxonomies and creates sqlite-files from it.
fn <- system.file('extdata','example.data.txt', package='STRING.db', mustWork=TRUE)
#
#fn <- "C:/Projects/r-string/devel2/STRING.db/STRING.db/inst/extdata/example.data.txt"
#fn <- "/home/stefan/Repos/r-string/devel2/STRING.db/STRING.db/inst/extdata/example.data.txt"
destdir <- 'test'
taxonomies <- c('001','002','003','004')
org.fn <- function(taxo) paste('test',taxo,'tab',sep='.')
idx.fn <- 'text.idx'
index.fn <- 'test.index'
res <- index.flatfile(fn, destdir, taxonomies, org.fn, idx.fn, index.fn)
encoding <- 'ensembl'

## hard coded correct results; use `dump(small.ppi, '')` to get this representation.
ex.data <- list()
ex.data$`001` <- structure(list(V1 = c("A01", "A01", "A01", "A01", "A02", "A02", "A02", "A03", "A03", "A03", "A04", "A04", "A05", "A05"), 
                                V2 = c("A02", "A03", "A04", "A05", "A01", "A03", "A05", "A01", "A02", "A04", "A01", "A03", "A01", "A02"), 
                                V3 = c(950L, 950L, 899L, 450L, 950L, 890L, 300L, 950L, 890L, 789L, 899L, 789L, 450L, 300L)), 
                           .Names = c("V1", "V2", "V3"), class = "data.frame", row.names = c(NA, -14L))
ex.data$`002` <- structure(list(V1 = c("B01", "B01", "B01", "B02", "B02", "B02", "B03", "B03", "B03", "B04", "B04", "B04"), 
                                V2 = c("B02", "B03", "B04", "B01", "B03", "B04", "B01", "B02", "B04", "B01", "B02", "B03"), 
                                V3 = c(989L, 989L, 922L, 989L, 975L, 921L, 989L, 975L, 935L, 922L, 921L, 935L)), 
                           .Names = c("V1", "V2", "V3"), class = "data.frame", row.names = c(NA, -12L))
ex.data$`003` <- data.frame(V1=c('C01','C01','C02','C03'), V2=c('C02','C03','C01','C01'), V3=c(750, 899, 750, 899), stringsAsFactors=FALSE)

for (taxo in names(ex.data)) {
  small.ppi <- read.table(res$fn[taxo], header=FALSE, colClasses=c('character','character','integer'))
  checkEquals(small.ppi, ex.data[[taxo]], msg=paste('Check failed on', taxo, 'in round 1.'))
}
# Re-do tests, but first use extract to make the files:
res2 <- extract.flatfile(fn, destdir, taxonomies=taxonomies, org.fn=org.fn, idx=res$index)
for (taxo in names(ex.data)) {
  small.ppi <- read.table(res2$fn[taxo], header=FALSE, colClasses=c('character','character','integer'))
  checkEquals(small.ppi, ex.data[[taxo]], msg=paste('Check failed on', taxo, 'in round 2.'))
}


cat('Indexing and extracting example data worked.')
cat('Proceeding to create and test databases.')

# Define organism specific settings. This is minimal example.
organisms <- list()
organisms$`001` <- list(short='T1', long='Test organism 1', primary=encoding)
organisms$`002` <- list(short='T2', long='Test organism 2', primary=encoding)
organisms$`003` <- list(short='T3', long='Test organism 3', primary=encoding)

gene.names <- list()
gene.names$`001` <- paste('A0', 1:5, sep='')
gene.names$`002` <- paste('B0', 1:4, sep='')
gene.names$`003` <- paste('C0', 1:3, sep='')

test.data <- lapply(ex.data, function(x) structure(x[x$V3 >= 800,], .Names=c('id1','id2','score') , row.names=1:sum(x$V3 >= 800))  )

for (taxo in names(organisms)) {
  cat('Testing creating and use of database using tax id', taxo)
  conn <- make.sqlite(taxo, res2$fn[taxo], file.path(destdir, sprintf(string.db.fn, 'STRING', organisms[[taxo]]$short)), string.v='Not string!') ## argument `organism` is pulled from `organisms` if not given.
  checkEquals(getMeta(conn, 'STRING-db'), 'Not string!')
  
  all.metas <- getMeta(conn)
  checkEquals(length(all.metas), 6)
  checkEquals(as.bool(all.metas$ensembl), TRUE)
  
  checkEquals(getNames(conn, encoding)$gene, gene.names[[taxo]])
  
  true.ppi <- test.data[[taxo]]
  get.ppi <- getPPI(conn, unique(true.ppi$id1), 800, encoding=encoding, as.list=FALSE, simplify=FALSE)
  checkEquals(true.ppi, get.ppi)

  get.ppi <- getPPI(conn, unique(true.ppi$id1), 800, encoding=encoding, as.list=TRUE, simplify=FALSE)
  checkEquals(length(get.ppi), length(unique(true.ppi$id1)))
  
  get.ppi <- getPPI(conn, unique(true.ppi$id1), 800, encoding=encoding, as.list=TRUE, simplify=TRUE)
  checkEquals(length(get.ppi), length(unique(true.ppi$id2)))
}

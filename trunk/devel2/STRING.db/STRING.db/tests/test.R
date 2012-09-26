#############################
## Test STRING.db
#############################

### Essentially, this is the example from example.data.
### It tries to open the example data file, extract the taxonomies and creates sqlite-files from it.
fn <- system.file('extdata','example.data.txt', package='STRING.db', mustWork=TRUE)
#
#fn <- "C:/Projects/r-string/devel2/STRING.db/STRING.db/inst/extdata/example.data.txt"
fn <- "/home/stefan/Repos/r-string/devel2/STRING.db/STRING.db/inst/extdata/example.data.txt"
destdir <- 'test'
taxonomies <- c('001','002','003','004')
org.fn <- function(taxo) paste('test',taxo,'tab',sep='.')
idx.fn <- 'text.idx'
index.fn <- 'test.index'
res <- index.flatfile(fn, destdir, taxonomies, org.fn, idx.fn, index.fn)

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
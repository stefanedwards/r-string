#!/opt/ghpc/bin/Rscript --vanilla
#PBS -j oe

library(RSQLite)
drv <- dbDriver('SQLite')

setwd(Sys.getenv('PBS_O_WORKDIR'), '.')  # for the sake of qsub

source('settings.R')

taxonomies <- c(9606, 9913, 10090)

## read table 
taxo <- '9913'
ppi.fn <- sprintf(string.tax.fn, string.fn.base, taxo)

ppi <- read.table(ppi.fn, header=FALSE, col.names=c('id1','id2','score'), as.is=TRUE)

prot.ids <- unique(c(ppi$id1, ppi$id2))
#prot.ids <- matrix(1:length(prot.ids), ncol=1, dimnames=list(prot.ids, 'id'))
prot.ids <- structure(1:length(prot.ids), .Names=prot.ids)
prot.mat <- data.frame(id=prot.ids, gene=names(prot.ids))

# mask ppi table with integer ids
ppi.mask <- ppi
ppi.mask$id1 <- prot.ids[ppi.mask$id1]
ppi.mask$id2 <- prot.ids[ppi.mask$id2]

conn <- dbConnect(drv, sprintf(string.db.fn, string.fn.base, taxo))
dbWriteTable(conn, 'ppi', ppi.mask, row.names=FALSE,overwrite=TRUE)
dbSendQuery(conn, 'CREATE INDEX `IDX_ppi_id1` ON `ppi` (`id1`);')
dbSendQuery(conn, 'CREATE UNIQUE INDEX `IDX_ppi` ON `ppi` (`id1`,`id2`);')
dbSendQuery(conn, 'CREATE INDEX `IDX_ppi_score` ON `ppi` (`score`);')

dbSendQuery(conn, 'CREATE TABLE `geneid` (`id` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, `gene` TEXT UNIQUE);')
dbWriteTable(conn, 'geneids', prot.mat, row.names=FALSE, overwrite=TRUE)

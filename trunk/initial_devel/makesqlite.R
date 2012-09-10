#!/opt/ghpc/bin/Rscript --vanilla
#PBS -j oe

options(stringsAsFactors=FALSE)

library(RSQLite)
library(AnnotationFuncs)
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
dbWriteTable(conn, 'geneids', prot.mat, row.names=FALSE, overwrite=FALSE, append=TRUE)

dbSendQuery(conn, 'CREATE TABLE `meta` (`meta` TEXT, `value` TEXT);')
dbSendQuery(conn, 'CREATE INDEX `IDX_meta` ON `meta` (`meta`);')

## Insert meta data

org.settings <- organisms[[taxo]]
if (!is.null(org.settings)) {
  if (org.settings$has.entrez == TRUE & !is.null(org.settings$db) & !is.null(org.settings$ens2eg)) {
    dbSendQuery(conn, 'CREATE TABLE `entrez_ppi` (`id1` INTEGER NOT NULL, `id2` INTEGER NOT NULL, `score` INTEGER NOT NULL); ')
    require(org.settings$db, character.only=TRUE)
    ens2ent <- AnnotationFuncs::translate(prot.mat$gene, get(org.settings$ens2eg), return.list=FALSE)
    ens2ent$from <- as.character(ens2ent$from)
    ens2ent$to <- as.integer(ens2ent$to)
    
    ppi.entrez <- merge(ppi, ens2ent, by.x='id1', by.y='from', all.x=FALSE, all.y=FALSE) #ENSBTAP00000000230
    ppi.entrez$id1 <- NULL
    names(ppi.entrez)[names(ppi.entrez) == 'to'] <- 'id1'

    
    ppi.entrez <- merge(ppi.entrez, ens2ent, by.x='id2', by.y='from', all.x=FALSE, all.y=FALSE) #ENSBTAP00000000230
    ppi.entrez$id2 <- NULL # 5702 5871
    names(ppi.entrez)[names(ppi.entrez) == 'to'] <- 'id2'
    
    dbWriteTable(conn, 'entrez_ppi', ppi.entrez, row.names=FALSE, overwrite=FALSE, append=TRUE)
    dbSendQuery(conn, 'CREATE INDEX `IDX_entrez_ppi_id1` ON `entrez_ppi` (`id1`); ')
    dbSendQuery(conn, 'CREATE INDEX `IDX_entrez_ppi_score` ON `entrez_ppi` (`score`);')
  }
}
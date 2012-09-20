#!/opt/ghpc/bin/Rscript --vanilla
#PBS -j oe

options(stringsAsFactors=FALSE)
print(date())

library(RSQLite)
library(AnnotationFuncs)
drv <- dbDriver('SQLite')

setwd(Sys.getenv('PBS_O_WORKDIR', '.'))  # for the sake of qsub

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

unlink(sprintf(string.db.fn, string.fn.base, taxo))
conn <- dbConnect(drv, sprintf(string.db.fn, string.fn.base, taxo))
null <- dbWriteTable(conn, 'ppi', ppi.mask, row.names=FALSE,overwrite=TRUE)
null <- dbSendQuery(conn, 'CREATE INDEX `IDX_ppi_id1` ON `ppi` (`id1`);')
null <- dbSendQuery(conn, 'CREATE UNIQUE INDEX `IDX_ppi` ON `ppi` (`id1`,`id2`);')
null <- dbSendQuery(conn, 'CREATE INDEX `IDX_ppi_score` ON `ppi` (`score`);')

null <- dbSendQuery(conn, 'CREATE TABLE `geneids` (`id` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, `gene` TEXT UNIQUE);')
null <- dbWriteTable(conn, 'geneids', prot.mat, row.names=FALSE, overwrite=FALSE, append=TRUE)

null <- dbSendQuery(conn, 'CREATE TABLE `meta` (`meta` TEXT, `value` TEXT);')
null <- dbSendQuery(conn, 'CREATE INDEX `IDX_meta` ON `meta` (`meta`);')

## Insert meta data
meta <- c('Created',date(),
          'STRING-db', string.version,
          'Primary PPI','ppi')
null <- dbWriteTable(conn, 'meta', as.data.frame(matrix(meta, ncol=2, byrow=TRUE)), row.names=FALSE, overwrite=FALSE, append=TRUE)

null <- sapply(dbListResults(conn), dbClearResult)

ppi.900 <- ppi[ppi$score >= 900,]
STRING.Bt.900 <- split(ppi.900$id2, as.factor(ppi.900$id1))


print('Loading entrez.')

org.settings <- organisms[[taxo]]
if (!is.null(org.settings)) {
  meta <- c('Primary encoding', org.settings$primary, 
            org.settings$primary, 'ppi')  # maps `ensembl` to ppi.

  if (org.settings$has.entrez == TRUE & !is.null(org.settings$db) & !is.null(org.settings$ens2eg)) {
    require(org.settings$db, character.only=TRUE)
    dbSendQuery(conn, 'CREATE TABLE `entrez_ppi` (`id1` INTEGER NOT NULL, `id2` INTEGER NOT NULL, `score` INTEGER NOT NULL); ')
    
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
    
    meta <- c(meta,
              'entrez', 'entrez_ppi',
              'entrez version', read.dcf(system.file('DESCRIPTION',package=org.settings$db), 'Version')
              )
    
    ppi.entrez.900 <- ppi.entrez[ppi.entrez$score >= 900,]
    STRING.Bt.eg.900 <- split(ppi.entrez.900$id2, as.factor(ppi.entrez.900$id1))
  }
  dbWriteTable(conn, 'meta', as.data.frame(matrix(meta, ncol=2, byrow=TRUE)), row.names=FALSE, overwrite=FALSE, append=TRUE)
}

print(paste('Done building db', date()))

## Create files for package...

caches <- c('STRING.Bt.900', 'STRING.Bt.eg.900')
caches <- caches[caches %in% ls()]
save(list=caches , file='protein.links.v9.0.9913.Rdata')
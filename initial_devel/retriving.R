library(RSQLite)

.known.encodings <- c('ensembl','entrez','refseq')

## generic functions --> generic package
.getMeta <- function(conn) {
  dbReadTable(conn, 'meta')
}

.getPPI <- function(conn, proteins, cutoff, encoding, as.list) {
  encoding <- tolower(encoding)
  if (!encoding %in% .known.encodings) stop('Could not recognize encoding. See ::.known.encodings.')
  tbl <- dbGetQuery(conn, "SELECT value FROM meta WHERE meta = ?;", encoding)
  if (nrow(tbl) == 0) stop('There does not exist any mappings for the given encoding.')  
  
  sql <- sprintf('SELECT `g1`.`gene` as `g1`, `g2`.`gene` as `g2`, `ppi`.`score` FROM geneid as g1
    INNER JOIN %s as ppi ON ppi.id1 = g1.id
    inner join geneid as g2 on g2.id=ppi.id2
    where g1.gene = @g ;', tbl[1,1])
  res <- dbGetQuery(.conn, sql, list(g=proteins, s=cutoff))
  
  if (as.list) {
    return(tapply(res[,2], list(as.factor(res[,1])), c))
  } else {
    retun(res)
  }  
}
## organism specific functions --> organism data package
## here for Bos taurus
.db_name <- 'STRING.v.9.0.9913.sqlite3'
.conn = dbConnect(dbDriver('SQLite'), .db_name)

STRING.Bt.meta <- function() {
  .getMeta(.conn)
}

STRING.Bt.ppi <- function(proteins, cutoff=900, as.list=FALSE) {
  .getPPI(.conn, proteins=proteins, cutoff=cutoff, encoding="ensembl", as.list=as.list)
}

## also write function for creating a data-package.
makePPI <- function(cutoff) {
  res <- dbGetQuery(.conn, 'SELECT `g1`.`gene` as `g1`, `g2`.`gene` as `g2`, `ppi`.`score` FROM geneid as g1
    INNER JOIN ppi ON ppi.id1 = g1.id
    inner join geneid as g2 on g2.id=ppi.id2
    where score >= ? ;', cutoff)
  return(tapply(res[,2], list(as.factor(res[,1])), c))
}
STRING.Bt.900 <- makePPI(900)

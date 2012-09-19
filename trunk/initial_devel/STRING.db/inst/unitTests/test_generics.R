options(stringsAsFactors=FALSE)

test_interface <- function() {
  require(RSQLite)
  drv <- dbDriver('SQLite')
  ## create in-memory database with constructed data.
  conn <- dbConnect(drv, ':memory:')

  ### Test Meta data
  ## Setup data
  meta <- data.frame(meta=c('ensembl','Primary encoding','Primary PPI','name','bla','bla','dude'), value=c('ppi','ensembl','ppi','lolcat','chezburger','rainbow','greg'))
  dbWriteTable(conn, 'meta', meta, row.names=FALSE, overwrite=TRUE)

  ## Start testing
  res <- list(bla=c('chezburger','rainbow'), dude='greg', ensembl='ppi', name='lolcat', `Primary encoding`='ensembl', `Primary PPI`='ppi')  # order of these are important.
  #checkEquals(.getMeta(conn), res, msg='Checks return of all meta data.', check.names=FALSE, check.attributes=FALSE)
  current <- .getMeta(conn)
  for (n in names(res)) {
    checkEquals(current[n], res[n])
  }
  
  checkEquals(.getMeta(conn, 'name'), res$name, msg='Checks return of `name` key from meta data.')
  
  
  ### Test PPI
  ## Setup data
  geneid <- data.frame(id=1:4, gene=letters[1:4])
  dbWriteTable(conn, 'geneids', geneid, row.names=FALSE, overwrite=TRUE)

  ppi <- data.frame(id1=c(rep(1, 3), rep(2, 2), rep(3,3), rep(4,2)), id2=c(2,3,4, 1,3, 1,2,4, 1,3), score=c(950, 900, 700,  950, 900,  900, 900, 700,  700, 700))
  dbWriteTable(conn, 'ppi', ppi, row.names=FALSE, overwrite=TRUE)

  ## Start testing
  #checkEquals(.getPPI(conn, proteins=c('a','b','c'), cutoff=900, encoding='ensembl', as.list=TRUE, simplify=FALSE), list(a=c('b','c'), b=c('a','c'), c=c('a','b')))
  current <- .getPPI(conn, proteins=c('a','b','c'), cutoff=900, encoding='ensembl', as.list=TRUE, simplify=FALSE)
  res <- list(a=c('b','c'), b=c('a','c'), c=c('a','b'))
  for (n in names(res)) {
    checkEquals(current[n], res[n])
  }
  

  res <- structure(ppi[ppi$score >= 900,], .Names=c('g1','g2','score'))
  res$g1 <- with(res, geneid$gene[g1])
  res$g2 <- with(res, geneid$gene[g2])  
  checkEquals(.getPPI(conn, proteins=c('a','b','c'), cutoff=900, encoding='ensembl', as.list=FALSE, simplify=FALSE), res, check.attributes=FALSE)
  
  checkEquals(.getPPI(conn, proteins=c('a','b','c'), cutoff=900, encoding='ensembl', as.list=FALSE, simplify=TRUE), c('b','c','a'))
  
  checkEquals(.getNames(conn), data.frame(gene=c('a','b','c','d')), check.attributes=FALSE)
  checkEquals(.getNames(conn, 'a%'), data.frame(gene='a'))
  
  dbDisconnect(conn)
} 


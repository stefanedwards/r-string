#!/opt/ghpc/bin/Rscript --vanilla

setwd(Sys.getenv('PBS_O_WORKDIR'), '.')


ppi.fn.base <- 'protein.links.v9.0'
ppi.fn <- paste(ppi.fn.base, 'txt.gz', sep='.')
ppi.f.opener <- function(fn) gzfile(fn, open='r')

#taxonomies <- c(882, 883) # c(9913,9606,10090)
taxonomies <- c(9606, 9913, 10090)
taxonomies <- c(882,1140)


# read ppi-file and report line numbers
ppi.index.fn <- paste(ppi.fn.base, 'index', sep='.')
has.index <- file.exists(ppi.index.fn)

taxonomies <- as.character(sort(as.integer(taxonomies)))

if (!has.index) {
  ppi.index.f <- file(ppi.index.fn, open='wt')
  ppi.f <- ppi.f.opener(ppi.fn)
  line.no <- 1
  null <- readLines(ppi.f, n=1)
  last.taxo <- ''
  wi <- 1
  while (length(input <- readLines(ppi.f, n=60000)) > 0) { 
    taxo.ids <- substr(input, 1, regexpr('.', input, fixed=TRUE)-1)
    taxos <- unique(taxo.ids)
    taxo.counts <- table(taxo.ids)
    j <- 1
   
    for (taxo in taxos) {
      if (taxo != last.taxo) {
        cat(taxo, line.no, file=ppi.index.f, sep='\t', fill=TRUE)
        last.taxo = taxo
      }
      
      if (taxo %in% taxonomies) {
        n.taxo <- nchar(as.character(taxo))        
        columns <- strsplit(input[j:(j+taxo.counts[taxo]-1)], ' ', fixed=TRUE)
        columns <- do.call(rbind, lapply(columns, function(x) 
          c(substr(x[1], n.taxo+2, 300), substr(x[2], n.taxo+2, 300), x[3]))
        )
        
        write.table(columns, paste(ppi.fn.base, taxo, 'txt', sep='.'), append=TRUE, row.names=FALSE, col.names=FALSE, quote=FALSE, sep=' ')
        #f <- file(paste(ppi.fn.base, taxo, 'txt', sep='.'), open='at')
        #writeLines(input[j:(j+taxo.counts[taxo]-1)], f)
        #print(paste(input[j], input[j+taxo.counts[taxo]-1], sep=' -- '))
        #close(f)
      }

      line.no <- line.no + taxo.counts[taxo]
      j <- j + taxo.counts[taxo]
    }
    
    if (line.no > 2*10**6) break
    print(wi)
    wi <- wi + 1
  }
  close(ppi.f)
  close(ppi.index.f)

} else {

  ppi.f <- ppi.f.opener(ppi.fn)
  ppi.index <- read.table(ppi.index.fn, header=FALSE, colClasses=c('character','integer'), sep='\t', col.names=c('taxid','line'))
  ppi.index <- structure(ppi.index$line, .Names=ppi.index$taxid)
  line.no <- 0
  
  for (taxo in as.character(taxonomies)) {
    line.1 <- ppi.index[taxo]
    line.n <- ppi.index[which(names(ppi.index) == taxo)+1]
    if (is.na(line.1)) {
      message(paste('Could not find',taxo,'in index.'))
    }
    if (is.na(line.n)) line.n <- -1
   
    ppi <- read.table(ppi.f, skip=line.1 - line.no, nrows=line.n-line.1, col.names=c('id1','id2','score'), as.is=TRUE)
    line.no <- line.n

    n.taxo <- nchar(as.character(taxo))
    taxo.ids <- substr(ppi$id1, 1, n.taxo)
    ppi <- ppi[taxo.ids == as.character(taxo),]
    tmp <- cbind(substr(ppi$id1, n.taxo+2, 300), substr(ppi$id2, n.taxo+2, 300), ppi$score)

    write.table(tmp,  paste(ppi.fn.base, taxo, 'txt', sep='.'), quote=FALSE, sep='\t', row.names=FALSE, col.names=FALSE)

  }
  close(ppi.f)
}
  

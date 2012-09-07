

ppi.fn.base <- 'protein.links.v9.0'
ppi.fn <- paste(ppi.fn.base, 'txt.bz2', sep='.')
ppi.f.opener <- function(fn) bzfile(fn, open='r')

taxonomies <- c(882, 883) # c(9913,9606,10090)

# read ppi-file and report line numbers
ppi.index.fn <- paste(ppi.fn.base, 'index', sep='.')
ppi.f <- ppi.f.opener(ppi.fn)
ppi.index.f <- file(ppi.index.fn, open='wt')

taxonomies <- as.character(taxonomies)

readLines(ppi.f, n=1) # read first line
last.taxo <- ''
line.no <- 1
wi <- 1
while (length(input <- readLines(ppi.f, n=60000)) > 0) { 
  taxo.ids <- substr(input, 1, regexpr('.', input, fixed=TRUE)-1)
  taxos <- unique(taxo.ids)
  taxo.counts <- table(taxo.ids)
  j <- 1
  
  #if (taxo.counts[1] != 60000) break
  
  for (taxo in taxos) {
    if (taxo != last.taxo) {
      cat(taxo, line.no, file=ppi.index.f, sep='\t', fill=TRUE)
      last.taxo = taxo
    }
    
    if (taxo %in% taxonomies) {
      f <- file(paste(ppi.fn.base, taxo, 'txt', sep='.'), open='at')
      writeLines(input[j:(j+taxo.counts[taxo]-1)], f)
      close(f)
    }
    
    line.no <- line.no + taxo.counts[taxo]
    j <- j + taxo.counts[taxo]
  }
  
  if (line.no > 1.2*10**6) break
  print(wi)
  wi <- wi + 1
}
close(ppi.f)
close(ppi.index.f)
       
  
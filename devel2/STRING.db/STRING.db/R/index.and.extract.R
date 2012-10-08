#' Downloads the protein.links flatfile from internets.
#' 
#' Downloads the gzipped file to working directory.
#' Destination directory is created if not exists.
#' @param version Integer or numeric of STRING version.
#' @param destdir Destination directory for file.
#' @return Logical for success.
# @author  Stefan McKinnon Edwards  \email{stefan.hoj-edwards@@agrsci.dk}
download.flatfile <- function(version, destdir='.') {
  ws <- www.settings(version)
  
  if (!file.exists(destdir)) dir.create(destdir)
  
  status <- download.file(ws$url, destfile=file.path(destdir, ws$fn))
  return(status == 0)
}

#' Indexes and extracts the protein.links flatfile.
#' 
#' Uses tax id in column 1 to distinguish new section and outputs the corresponding line number.
#' @param fn Filename of flatfile, relative to destdir, or list result from \code{\link{www.settings}}, 
#'    in which case the remaining relevant arguments should be left out, or they will overrule contents of \code{fn}.
#' @param destdir Directory (relative or absolut) for input and output files.
#' @param taxonomies Character vector of the tax ids to extract. 
#'    If \code{NULL}, nothing is extracted.
#' @param org.fn Filename function for making filenames for organism sections; 
#'    recieves tax id as argument.
#' @param idx.fn String with filename relative to dest dir for binary index.
#' @param index.fn String with filename relative to dest dir for text index.
#' @return \code{index.flatfile} - List: \code{index} Integer vector with index of all tax ids, 
#'    \code{found} Logical vector matching which tax ids in \code{taxonomies} were found
#'    and \code{fn} Character vector of absolute paths to organism flatfiles.
#' @section Side effects: 
#'    Will create a new file in \code{destdir} for each found tax id in \code{taxonomies},
#'    as well as two index-files (binary and ordinary .RData-type, but with .idx extension.)
#' @export
index.flatfile <- function(fn, destdir='.', taxonomies=NULL, org.fn=NULL, idx.fn=NULL, index.fn=NULL) {
  #.stringAsFactors <- getOption('stringsAsFactors')
  #options(stringsAsFactors=FALSE)
  if (is.list(fn)) {
    org.fn <- ifelse(is.null(org.fn), fn$org.fn, org.fn)
    idx.fn <- ifelse(is.null(idx.fn), fn$idx.fn, idx.fn)
    index.fn <- ifelse(is.null(index.fn), fn$index.fn, index.fn)
    fn <- fn$fn
  }
  stopifnot(!is.null(fn), !is.null(idx.fn), !is.null(index.fn), !(!is.null(taxonomies) & is.null(org.fn)) ) 
  
  if (!is.null(taxonomies)) taxonomies <- taxonomies[order(as.integer(taxonomies))]

  ## Re-path filenames
  fn <- normalizePath(fn)
  
  dir.create(destdir, showWarnings=FALSE)
  prev.wd <- setwd(destdir)
  taxo.fn <- sapply(taxonomies, org.fn)

  
  ## Open connections for input file and index file.
  ppi.f <- opener(fn)
  index.f <- opener(index.fn, 'wt')
  
  ## Start reading and initialize
  last.taxo <- ''
  line.no <- 1  # Total line count
  null <- readLines(ppi.f, n=1)
  idx <- vector('integer')  # for binary dataset
  found.tax <- structure(rep(FALSE, length(taxonomies)), .Names=taxonomies)

  # Main loop for reading
  while (length(input <- readLines(ppi.f, n=60000)) > 0) {
    taxo.ids <- substr(input, 1, regexpr('.', input, fixed=TRUE)-1)  # Extract tax.ids
    taxos <- unique(taxo.ids)
    taxo.counts <- table(taxo.ids)
    
    j <- 1 # Line counter for input-section
    # Iterate over found tax ids
    for (taxo in taxos) {
      if (taxo != last.taxo) {
        # Write line for new tax id to index.
        cat(taxo, line.no, file=index.f, sep='\t', fill=TRUE)
        idx[taxo] <- line.no
        last.taxo <- taxo
      }
      
      if (taxo %in% taxonomies) {
        n.taxo <- nchar(as.character(taxo)) # Length of tax id string.
        # Splits into list; 1 element per line
        columns <- strsplit(input[j:(j+taxo.counts[taxo]-1)], ' ', fixed=TRUE) 
        # Re-merges into character matrix after stripping tax id.
        columns <- do.call(rbind, lapply(columns, function(x) 
          c(substr(x[1], n.taxo+2, 300), substr(x[2], n.taxo+2, 300), x[3]))
        )
        # Appends columns to organism file.
        write.table(columns, file=taxo.fn[taxo], append=TRUE, 
                    row.names=FALSE, col.names=FALSE, quote=FALSE, sep='\t')
        # Make a note that we found the tax id.
        found.tax[taxo] <- TRUE
      }
      line.no <- line.no + taxo.counts[taxo]
      j <- j + taxo.counts[taxo]
    }
    
  }
  
  # Clean up
  close(ppi.f)
  close(index.f)

  taxo.fn <- sapply(taxo.fn, normalizePath, mustWork=FALSE)
  
  
  save(idx, file=idx.fn)
  
  setwd(prev.wd)
  return(list(index=idx, found=found.tax, fn=taxo.fn))
}

#' Extracts organism sections from protein.links flatfile.
#' 
#'
#' @rdname index.flatfile
#' @inheritParams index.flatfile
#' @param idx Integer vector named by tax id necessary for extraction (see note) or filename where it can be loaded from. 
#'    Could be result from \code{\link{index.flatfile}}.
#'    If \code{NULL} and \code{fn} is list, filename of index is extracted and loaded.
#' @return \code{extract.flatfile} - List with elements \code{fn} character vector of absolute paths to organism specific flatfiles.
#' @note For \code{extract.flatfile}, the index \code{idx} should not only cover the tax ids of interest, 
#'    but also the subsequent tax id in the list!
#'    The tax ids in the index must also be ordered in same order as found in the protein.links flatfile.
#' @export
extract.flatfile <- function(fn, destdir='.', taxonomies, org.fn=NULL, idx=NULL) {
  if (is.list(fn)) {
    org.fn <- ifelse(is.null(org.fn), fn$org.fn, org.fn)
    idx.fn <- ifelse(is.null(idx.fn), fn$idx.fn, idx.fn)
    fn <- fn$fn
  }
  stopifnot(!is.null(fn), !is.null(idx.fn), !is.null(taxonomies), !is.null(org.fn))
  
  taxonomies <- taxonomies[order(as.integer(taxonomies))]
  fn <- normalizePath(fn, mustWork=TRUE)
  prev.wd <- setwd(destdir)

  taxo.fn <- sapply(taxonomies, org.fn)
  found.tax <- structure(rep(FALSE, length(taxonomies)), .Names=taxonomies)  
  
  # Checks whether `idx` is not an integer vector and therefore needs to be loaded from file.
  if (!(is.integer(idx) | is.numeric(idx))) {
    idx <- file.path(destdir, idx)
    if (grepl('.*\\.idx',idx)) {
      load(idx)
    } else {
      idx <- read.table(idx, header=FALSE, sep='\t', quote='', 
                        col.names=c('taxid','line'), colClasses=c('character','integer'))
      idx <- structure(idx$line, .Names=idx$taxid)
    }
  }
  
  # Open input connection
  ppi.f <- opener(fn)
  
  # Initialise and read
  line.no <- 0
  for (taxo in as.character(taxonomies)) {
    line.1 <- idx[taxo]  # First line of this 
    line.n <- idx[which(names(idx) == taxo)+1]  # Last line + 1 of organism section.
    if (is.na(line.1)) {
      message(paste('Could not find',taxo,'in index.'))
      next
    }
    if (is.na(line.n)) line.n <- -1  # Defaults to remaining 
    
    ppi <- read.table(ppi.f, skip=line.1 - line.no, nrows=line.n-line.1, col.names=c('id1','id2','score'), as.is=TRUE)
    line.no <- line.n
    
    n.taxo <- nchar(as.character(taxo))
    taxo.ids <- substr(ppi$id1, 1, n.taxo)
    ppi <- ppi[taxo.ids == as.character(taxo),]
    tmp <- cbind(substr(ppi$id1, n.taxo+2, 300), substr(ppi$id2, n.taxo+2, 300), ppi$score)
    
    write.table(tmp, file=taxo.fn[taxo], 
                quote=FALSE, sep='\t', row.names=FALSE, col.names=FALSE)
  }

  taxo.fn <- sapply(taxo.fn, normalizePath, mustWork=FALSE)
  setwd(prev.wd)
  
  return(list(fn=taxo.fn))
}


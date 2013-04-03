#' Compiles a datapackage for a specified organism.
#' 
#' Takes the extracted data by \code{\link{index.flatfile}} or \code{\link{extract.flatfile}}
#' and compiles it into a ready-to-use package for R.
#' @param tax.id String with taxonomy id, e.g. 9913 for cattle.
#' @param flatfile.fn Path to input flatfile from \code{\link{extract.flatfile}} or \code{\link{index.flatfile}}.
#' @param string.v Version of STRING-db.
#' @param cutoffs Integer vector of cutoff values for pre-packaged datafiles.
#' @param organism List-object specifying organism settings. 
#'        If \code{NULL}, it is pulled from \code{\link{organisms}}.
#' @param package.name Name of package that will be created. Defaults to STRING.[abbr].db.
#' @export
makePackage <- function(tax.id, flatfile.fn, string.v, cutoffs=c(800,900,950), organism=NULL, package.name=NULL) {
  require(roxygen2)
  tax.id <- as.character(tax.id)
  if (is.null(organism)) organism <- organisms[[tax.id]]   # organisms specified in `organisms.R`.
  if (is.null(organism)) stop(paste('Could not fetch any organism specifics for',tax.id,'from `organisms`.'))
  
  if (is.null(package.name)) package.name <- paste('STRING',organism$short, 'db', sep='.')
  
  # Create directories
  dir.create(package.name)
  subdirs <- c('R','inst/extdata', 'man', 'data')
  sapply(subdirs, function(x) dir.create(file.path(package.name, x), recursive=TRUE))
  
  # Make Database
  conn <- make.sqlite(tax.id, flatfile.fn, sqlite.fn=file.path(package.name, 'inst/extdata', sprintf(STRING.db:::string.db.fn, 'STRING',organism$short)), organism=organism, string.v=string.v)

  # Make data-files
  for (cutoff in cutoffs) {
    cache <- paste(organism$short, cutoff, 'PPI', sep='.')
    res <- cacheObject(conn, encoding=organism$primary, cutoff=cutoff, var.name=cache)
    save(list=cache, file=file.path(package.name, 'data', paste(cache, '.RData', sep='')), envir=res)
  }

  # make script files
  templates <- matrix(ncol=2, byrow=TRUE, dimnames=list(NULL, c('source','dest')),
                      data=c('DESCRIPTION.tpl','DESCRIPTION',
                             'all.funcs.R', 'R/all.funcs.R',
                             'CIT8.tpl', 'inst/CITATION'))
  templates[,1] <- sapply(templates[,1], function(f) system.file('extdata',f, package='STRING.db', mustWork=TRUE))
  #templates <- rbind(templates, cbind('data.Rd',paste(organism$short, cutoffs, 'PPI', sep='.')))
  replacements <- matrix(ncol=2, byrow=TRUE, dimnames=list(NULL, c('pattern','replacement')),
                         data=c('{collate}',"'all.funcs.R'",
                                '{package-version}',packageDescription("STRING.db")[['Version']],
                                '{package-date}', format(Sys.time(), "%Y-%m-%d"),
                                '{package-name}', package.name,
                                '{organism-longname}', organism$long,
                                '{organism-shortname}', organism$short,
                                '{dbfile}', sprintf(STRING.db:::string.db.fn, 'STRING',organism$short),
                                '{primary-encoding}', organism$primary,
                                '{rd-datapackages}', paste("#'  \\item \\code{\\link{", organism$short, '.', cutoffs, '.PPI', '}}', sep='', collapse='\n')
                         ))
  
  for (i in 1:nrow(templates)) {
    tpl <- readLines(templates[i,1])
    tpl <- paste(tpl, collapse='\n')
    for (j in 1:nrow(replacements)) {
      tpl <- gsub(replacements[j,1], replacements[j,2], tpl, fixed=TRUE)
    }
    writeLines(tpl, file.path(package.name, templates[i,2]))
  }
  ## Repeat for data-packages.
  for (cutoff in cutoffs) {
    tpl <- readLines(system.file('extdata', 'data.Rd', package='STRING.db', mustWork=TRUE))
    tpl <- paste(tpl, collapse='\n')
    for (j in 1:nrow(replacements)) {
      tpl <- gsub(replacements[j,1], replacements[j,2], tpl, fixed=TRUE)
    }
    tpl <- gsub('{data-name}', paste(organism$short, cutoff, 'PPI', sep='.'), tpl, fixed=TRUE)
    tpl <- gsub('{cutoff}', cutoff, tpl, fixed=TRUE)
    writeLines(tpl, file.path(package.name, 'man', paste(organism$short, cutoff, 'PPI.Rd', sep='.')))
  }
  
  roxygenise(package.name, roclets=c('namespace','rd'))
  ## add two imports to namespace
  #nmsp <- file(file.path(package.name,'NAMESPACE'), 'at')
  #writeLines(c('import(DBI)','import(RSQLite)'), nmsp)
  #close(nmsp)

  return(package.name)
}



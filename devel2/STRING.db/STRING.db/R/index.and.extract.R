#' Downloads the protein.links flatfile from internets.
#' 
#' Downloads the gzipped file to working directory.
#' Destination directory is created if not exists.
#' @param version Integer or numeric of STRING version.
#' @param destdir Destination directory for file.
#' @return Logical for success.
#' @author  Stefan McKinnon Edwards  \email{stefan.hoj-edwards@@agrsci.dk}
download.flatfile <- function(version, destdir='.') {
  ws <- www.settings(version)
  
  if (!file.exists(destdir)) dir.create(destdir)
  
  fn <- sprintf(w.s$fn, fmt.v(version))
  
  download.file(sprintf(w.s$url, sprintf(w.s)))
}
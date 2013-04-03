#############################
## Organism specific settings
#############################
#' Organism specifications
#' 
#' @format List-of-lists. Each entry has following \emph{mandatory} entries; examples are for cattle (\emph{Bos taurus}):
#'    \describe{
#'      \item{short}{Short name for the organism (`Bt')}
#'      \item{long}{Full(-ish) name for organism (`Bos taurus')}
#'      \item{primary}{Name of encoding, e.g. `ensembl' or `entrez'.}
#'    }
#'    Optional entries for additional functionality:
#'    \describe{
#'      \item{map2entrez}{Function that maps the primary protein-names to \emph{entrez} gene identifers.}
#'    }
#' @section Mapping functions:
#'    All mapping functions should recieves one argument, a data.frame with three columns (`id1', `id2` and `score').
#'    The function should return a data.frame of same structure (i.e. 2 x character and 1 integer column),
#'    where the names have been mapped from the primary identifier to specified encoding.
#'    Loading packages etc. should be taken care of by the function.
#'    To use BioC annotation packages to map to/from entrez, see \code{\link{ens2eg}}.
organisms <- list()
organisms$'001' <- list(short='T1', long='Test organism 1', primary='test')
organisms$'002' <- list(short='T2', long='Test organism 2', primary='test')
organisms$'003' <- list(short='T3', long='Test organism 3', primary='test')
organisms$'9606' <- list(short='Hs', long='Homo sapiens', primary='ensembl', map2entrez=function(ppi) ens2eg(ppi, 'org.Hs.eg.db', keytype='ENSEMBLPROT2', cols='ENTREZID'))
organisms$'9913' <- list(short='Bt', long='Bos taurus', primary='ensembl', map2entrez=function(ppi) ens2eg(ppi, 'org.Bt.eg.db', keytype='ENSEMBLPROT2', cols='ENTREZID'))

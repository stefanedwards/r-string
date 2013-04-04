#############################
## Functions that the organism packages would use.
#############################

# methods from AnnDbObj-lowAPI.R in AnnotationDbi
#' Generic function for keeping sqlite-connection alive.
#' 
#' @param x An environment that contains the variable of same name as function.
#' @return The contents of the variable.
#' @examples
#' datacache <- new.env(hash=TRUE, parent=emptyenv())
#' 
#' dbfile <- 'my file'
#' assign('dbfile', dbfile, envir=datacache)
#' dbconn <- 'my live connection, but you would replace with e.g. dbConnect(...).'
#' assign('dbconn', dbconn, envir=datacache)
dbconn <- function(x) get('dbconn', envir=x)
#' @rdname dbconn
#' @inheritParams dbconn
dbfile <- function(x) get('dbfile', envir=x)


#' Known gene/protein encodings/identifiers
#' 
#' In these packages, we call the type of identifier for an biological entity \sQuote{encodings}.
#' E.g. Entrez, Ensembl or Refseq are examples of encodings.
known.encodings <- c('ensembl','entrez','refseq')


#' Get db schema version
#' 
#' @param conn Database connection to STRING.db-sqlite database.
#' @return Numeric value of DB schema version.
getDBSchema <- function(conn) {
  res <- dbReadTable(conn, 'meta')
  row <- which(res == 'DB Schema')
  if (length(row) < 1) stop('Cannot figure the DB Schema in sqlite-file.')
  db.schema <- as.numeric(res[row,2])
  return(db.schema)
}

#' Generic function for retrieving meta-data from organism data packages.
#'
#' @param conn Database connection to STRING.db-sqlite database.
#' @param key Character vector of which keys to retrieve; use sqlite syntax for wildcards (e.g. % to match all characters). Defaults to retrieve all keys.
#' @param as.bool Coerce result into logical. Useful if requesting known keys.
#' @return List with entries named by the key; return value is reduced to character vector if only one key is retrieved.
# @author Stefan McKinnon Edwards \email{stefan.hoj-edwards@@agrsci.dk}
#' @seealso \code{\link{STRING.db}}
#' @export
getMeta <- function(conn, key='%', as.bool=FALSE) {
  #stop('getMeta is not implemented')
  db.schema <- getDBSchema(conn)
  if (db.schema == 0.1) {
    res <- dbGetQuery(conn, 'SELECT * FROM meta WHERE meta LIKE ?;', data.frame(key))
    res$meta = factor(res$meta)
    if (nlevels(res$meta) == 1)
      return(res$value)
    return(split(res$value, res$meta))
  } else if (db.schema >= 0.2) {
    res <- getMeta.0.2(conn, key)
    if (as.bool) res <- as.bool(res)
    return(res)
  }
}
#' @rdname getMeta
#' @inheritParams getMeta
getMeta.0.2 <- function(conn, key) {
  res <- dbGetQuery(conn, 'SELECT * FROM meta where key LIKE ?;', data.frame(key))
  res$key = factor(res$key)
  if (nlevels(res$key) == 1)
    return(res$value)
  return(split(res$value, res$key))  
}



#' Generic function for retrieving the protein-protein interaction data from organism data packages.
#' 
#' @param conn Database connection to STRING.db-sqlite database.
#' @param proteins Character vector of gene/protein identifiers that are requested. 
#' @param cutoff Score cut-off; only retrieves ppi with scores larger than or equal to.
#' @param encoding String of which encoding \code{proteins} is set in.
#' @param as.list Logical, restructure result to a list, see Value.
#' @param simplify Logical, should function only return a character vector of all interaction partners? Overrules \code{as.list}.
#' @return For \code{as.list} as \code{FALSE}, data.frame of three columns (\code{g1}, \code{g2}, \code{score}).
#'         For \code{as.list} as \code{TRUE}, list with entries named by \code{g1} containing all mappings in \code{g2}. \code{score} is lost.
#'         If \code{simplify} is \code{TRUE}, \code{as.list} is overruled and the returned value is a character vector.
#' @author Stefan McKinnon Edwards \email{stefan.hoj-edwards@@agrsci.dk}
#' @seealso \code{\link{known.encodings}}, \code{\link{STRING.db}}, \code{\link{getNames}}, \code{\link{getAllLinks}}
#' @export
getPPI <- function(conn, proteins, cutoff, encoding, as.list, simplify) {
  db.schema <- getDBSchema(conn)
  if (db.schema == 0.1) {
    res <- getPPI.0.1(conn, proteins, cutoff, encoding, as.list, simplify)
  } else if (db.schema >= 0.2) {
    res <- getPPI.0.2(conn, proteins, cutoff, encoding, as.list, simplify)
  }
  return(res)
}
#' @rdname getPPI
#' @inheritParams getPPI
getPPI.0.1 <- function(conn, proteins, cutoff, encoding, as.list, simplify) {
  encoding <- tolower(encoding)
  if (!encoding %in% known.encodings) stop('Could not recognize encoding. See ::.known.encodings.')
  #tbl <- dbGetQuery(conn, "SELECT value FROM meta WHERE meta = ?;", encoding)
  tbl <- getMeta(conn, encoding)
  if (length(tbl) == 0) stop('There does not exist any mappings for the given encoding.')  
  
  if (encoding == getMeta(conn, 'Primary encoding')) {
    sql <- sprintf('SELECT `g1`.`gene` as `g1`, `g2`.`gene` as `g2`, `ppi`.`score` FROM geneids as g1
    INNER JOIN %s as ppi ON ppi.id1 = g1.id
                   inner join geneids as g2 on g2.id=ppi.id2
                   where g1.gene = @g and ppi.score >= @s;', getMeta(conn, 'Primary PPI'))
  } else {
    sql <- sprintf('SELECT `id1` as `g1`, `id2` as `g2`, `score` as `score` FROM %s WHERE `id` = @g AND `score` >= @s', tbl)
  }
  res <- dbGetQuery(conn, sql, list(g=proteins, s=cutoff))
  
  # Three different return options
  if (simplify)
    return(unique(res[,2]))
  if (as.list)
    return(split(res[,2], as.factor(res[,1])))
  return(res)
}
#' @rdname getPPI
#' @inheritParams getPPI
getPPI.0.2 <- function(conn, proteins, cutoff, encoding, as.list, simplify) {
  has.enc <- getMeta(conn, encoding, as.bool=TRUE)
  if (has.enc != TRUE) stop(paste('Encoding `', encoding, '` is not listed in meta-table.', sep=''))
  
  encoding <- tolower(encoding)
  
  tbl.id <- paste(encoding, '_ids', sep='')
  if (!tbl.id %in% dbListTables(conn)) {
    # Read ppi directly from table
    sql <- sprintf('SELECT id1, id2, score FROM %s WHERE score >= @score AND id1 = @id1 ORDER BY id1;', encoding)
  } else {
    sql <- sprintf('SELECT g1.gene as id1, g2.gene as id2, score FROM %1$s INNER JOIN %2$s AS g1 ON g1.id=id1 INNER JOIN %2$s AS g2 ON g2.id=id2 WHERE score >= @score AND g1.gene = @id1 ORDER BY id1;', encoding, tbl.id)
  }
  res <- dbGetQuery(conn, sql, data.frame(score=cutoff, id1=proteins))
  
  if (simplify)
    return(unique(res$id2))
  if (as.list)
    return(split(res$id2, as.factor(res$id1)))
  return(res)
}

#' Generic function for reading all saved gene/protein names of the primary type.
#' 
#' \code{getNames.x.y} are database schema dependant functions for doing the actual work.
#' 
#' @param conn Database connection to STRING.db-sqlite database.
#' @param encoding String of which encoding \code{proteins} is set in. Defaults to primary encoding.
#' @param filter Character for filtering which names to retrieve; uses sqlite i.e. use \sQuote{\%} for any length wildcard, \sQuote{_} for single character wildcard.
# @author Stefan McKinnon Edwards \email{stefan.hoj-edwards@@agrsci.dk}
#' @return data.frame with one column.
#' @seealso \link{getPPI}, \link{getAllLinks}
#' @export
getNames <- function(conn, encoding, filter=NULL) {
  db.schema <- getDBSchema(conn)
  if (db.schema == 0.1) {
    res <- getNames.0.1(conn, encoding, filter)
  } else if (db.schema >= 0.2) {
    res <- getNames.0.2(conn, encoding, filter)
  }
  
  return(res)
}
#' @rdname getNames
#' @inheritParams getNames
getNames.0.1 <- function(conn, encoding, filter) {
  if (is.null(filter)) {
    return(dbReadTable(conn, 'geneids', row.names='id'))
  } else {
    return(dbGetQuery(conn, 'SELECT gene FROM geneids WHERE gene LIKE ?;', data.frame(filter)))
  }
}
#' @rdname getNames
#' @inheritParams getNames
getNames.0.2 <- function(conn, encoding, filter) {
  has.enc <- getMeta(conn, encoding, as.bool=TRUE)
  if (has.enc != TRUE) stop(paste('Encoding `', encoding, '` is not listed in meta-table.', sep=''))
  
  tbl.id <- paste(encoding, '_ids', sep='')
  if (!tbl.id %in% dbListTables(conn)) {
    # Read ids directly from ppi-table
    if (is.null(filter)) {
      return(dbGetQuery(conn, sprintf('SELECT DISTINCT id1 FROM %s ORDER BY id1;', encoding)))
    } else {
      return(dbGetQuery(conn, sprintf('SELECT DISTINCT id1 FROM %s WHERE id1 LIKE ? ORDER BY id1;', encoding), data.frame(filter)))
    }
  } else {
    # Read ids from id table
    if (is.null(filter)) {
      return(dbReadTable(conn, tbl.id, row.names='id'))
    } else {
      res <- dbGetQuery(conn, sprintf('SELECT id, gene FROM %s WHERE gene LIKE ? ORDER BY gene;', encoding), data.frame(filter))
      return(data.frame(res$gene, row.names=res$id, stringsAsFactors=FALSE))
    }    
  }
}

#' Generic function for getting all protein-protein links
#' 
#' \code{getAllLinks.x.y} are database schema dependant functions for doing the actual work.
#' 
#' @param conn Database connection to STRING.db-sqlite database.
#' @param encoding String of which encoding \code{proteins} is set in. Defaults to primary encoding.
# @author Stefan McKinnon Edwards \email{stefan.hoj-edwards@@agrsci.dk}
#' @param cutoff Cut-off of score, i.e. get all links with score greater than or equal to.
#' @return data.frame with three columns.
#' @seealso \link{getNames}, \link{getPPI}
#' @export
getAllLinks <- function(conn, encoding, cutoff=0) {
  db.schema <- getDBSchema(conn)
  if (db.schema >= 0.2) {
    res <- getAllLinks.0.2(conn, encoding, cutoff)
  } else {
    stop('This function is not supported in this database schema.')
  }
  return(res)
}
#' @rdname getAllLinks
#' @inheritParams getAllLinks
getAllLinks.0.2 <- function(conn, encoding, cutoff) {
  has.enc <- getMeta(conn, encoding, as.bool=TRUE)
  if (has.enc != TRUE) stop(paste('Encoding `', encoding, '` is not listed in meta-table.', sep=''))

  tbl.id <- paste(encoding, '_ids', sep='')
  if (!tbl.id %in% dbListTables(conn)) {
    sql <- sprintf('SELECT id1, id2, score FROM %s WHERE score >= @score ORDER BY id1, id2;', encoding)
  } else {
    sql <- sprintf('SELECT g1.gene as id1, g2.gene as id2, score FROM %1$s INNER JOIN %2$s AS g1 ON g1.id=id1 INNER JOIN %2$s AS g2 ON g2.id=id2 WHERE score >= @score ORDER BY id1, id2;', encoding, tbl.id)
  }
  
  res <- dbGetQuery(conn, sql, data.frame(score=cutoff))
  
  return(res)
}

#' Prepares a data object with all data.
#' 
#' @param conn Live connection to database.
#' @param encoding String naming the encoding (e.g. entrez or ensembl).
#' @param cutoff Score cut-off; only retrieves ppi with scores larger than or equal to.
#' @return List with names as id1 and elements as id2.
#' @export
#' @seealso \code{\link{cacheObject}}.
makeCache <- function(conn, encoding, cutoff) {
  if (getDBSchema(conn) < 0.2) stop('makeCache not support by DB schema < 0.2!')
  
  has.enc <- getMeta(conn, encoding, as.bool=TRUE)
  if (has.enc != TRUE) stop(paste('Encoding `', encoding, '` is not listed in meta-table.', sep=''))
  
  
  
  tbl.id <- paste(encoding, '_ids', sep='')
  if (!tbl.id %in% dbListTables(conn)) {
    sql <- sprintf('SELECT id1, id2 FROM %s WHERE score >= @score ORDER BY id1, id2;', encoding)
  } else {
    sql <- sprintf('SELECT g1.gene as id1, g2.gene as id2 FROM %1$s INNER JOIN %2$s AS g1 ON g1.id=id1 INNER JOIN %2$s AS g2 ON g2.id=id2 WHERE score >= @score ORDER BY id1, id2;', encoding, tbl.id)
  }

  res <- dbGetQuery(conn, sql, data.frame(score=cutoff))
  
  return(split(res$id2, as.factor(res$id1)))
}
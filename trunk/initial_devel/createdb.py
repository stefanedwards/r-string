#!/usr/bin/python3
####################################
## Creates a sqlite3 db with the ppi-tabular flatfile for a specific organism.
## Also loads with some ensembl-entrez mappings if applicable from bioconductor data packages.
## Author: Stefan McKinnon H\oj-Edwards <sme@iysik.com>
## Date: Sept. 2012
####################################
import os
import sys
import sqlite3
import time
import re
from collections import defaultdict
from itertools import product

import settings
from Path import Path

taxid = 9913

sql_create_tmp_ppi = '''CREATE TEMPORARY TABLE `tmp_ppi` (`id1` INTEGER NOT NULL, `id2` INTEGER NOT NULL, `score` INTEGER NOT NULL);'''
sql_index_tmp_ppi = '''CREATE INDEX `IDX_tmpppi_id1` ON `tmp_ppi` (`id1`); CREATE INDEX `IDX_tmpppi_id2` ON `tmp_ppi` (`id2`);'''
sql_create_geneid = '''CREATE TABLE `geneid` (`id` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, `gene` TEXT UNIQUE);'''
sql_index_geneid = ''#'''CREATE INDEX
sql_create_meta = '''CREATE TABLE `meta` (`meta` TEXT, `value` TEXT);'''
sql_index_meta = '''CREATE INDEX `IDX_meta` ON `meta` (`meta`);'''
sql_create_ppi = '''CREATE TABLE `ppi` (`id1` INTEGER NOT NULL, `id2` INTEGER NOT NULL, `score` INTEGER NOT NULL);'''
sql_index_ppi = '''CREATE INDEX `IDX_ppi_id1` ON `ppi` (`id1`); CREATE UNIQUE INDEX `IDX_ppi` ON `ppi` (`id1`,`id2`); CREATE INDEX `IDX_ppi_score` ON `ppi` (`score`);'''
sql_create_tables = [sql_create_tmp_ppi, sql_index_tmp_ppi, sql_create_geneid, sql_index_geneid, sql_create_meta, sql_index_meta, sql_create_ppi, sql_index_ppi]
sql_create_entrez_ppi = '''CREATE TABLE `entrez_ppi` (`id1` INTEGER NOT NULL, `id2` INTEGER NOT NULL, `score` INTEGER NOT NULL); '''
sql_index_entrez_ppi =  '''CREATE INDEX `IDX_entrez_ppi_id1` ON `entrez_ppi` (`id1`); '''
#sql_index_entrez_ppi += '''CREATE UNIQUE INDEX `IDX_entrez_ppi` ON `entrez_ppi` (`id1`,`id2`);'''
sql_index_entrez_ppi += '''CREATE INDEX `IDX_entrez_ppi_score` ON `entrez_ppi` (`score`);'''


db_fn = Path(settings.sqlite_db_tpl.format(taxid))
if db_fn.exists:
  os.remove(db_fn)

conn = sqlite3.connect(db_fn)
cur = conn.cursor()
# Create tables:
cur.execute('BEGIN TRANSACTION;')
cur.executescript(''.join(sql_create_tables))
conn.commit()

# Load some meta data
cur.execute('BEGIN TRANSACTION;')
cur.executemany('INSERT INTO `meta` (`meta`, `value`) VALUES (?, ?);', \
            [('Created',time.strftime('%a %b %d %H:%M:%S %Y')), \
             ('STRING-db', settings.STRING_version),
             ('Primary encoding',settings.taxonomies[taxid]['primary encoding']),
             (settings.taxonomies[taxid]['primary encoding'],1),
             (settings.taxonomies[taxid]['primary encoding']+'_tbl','ppi')])
conn.commit()

# Enter ppi data.
with open(settings.links_tbl_tpl.format(taxid), 'r') as inp:
  last_id1 = None
  cur.execute('BEGIN TRANSACTION;')
  for line in inp:
    id1, id2, score = line.split(' ')
    cur.execute('INSERT INTO `tmp_ppi` (`id1`, `id2`, `score`) VALUES (?, ?, ?);', (id1, id2, score.rstrip()))
    if id1 != last_id1:
      cur.execute('INSERT INTO `geneid` (`gene`) VALUES (?);', (id1, ))
      last_id1 = id1
  conn.commit()
  
  #SELECT `id2` FROM `tmp_ppi` LEFT JOIN `geneid` ON `geneid`.`gene`=`tmp_ppi`.`id2` WHERE `id2` IS NULL LIMIT 10;
  
  # fetch newly create gene ids.
  res = cur.execute('SELECT `id`, `gene` FROM geneid;')
  ids = {r[1]:r[0] for r in res if r is not None}

  inp.seek(0)
  cur.execute('BEGIN TRANSACTION;')
  for line in inp:
    id1, id2, score = line.split(' ')
    null = cur.execute('INSERT INTO ppi (`id1`, `id2`, `score`) VALUES (?,?,?);', ( ids[id1], ids[id2], int(score.rstrip()) ))
  conn.commit()


orgconn = sqlite3.connect(settings.R_package_path.join(settings.taxonomies[taxid]['bioc'],settings.taxonomies[taxid]['db']))
orgcur = orgconn.cursor()
res = orgcur.execute('SELECT `prot_id`,`gene_id` FROM `ensembl_prot` INNER JOIN genes USING (`_id`);')
ens2eg = defaultdict(list)
for r in res:
  ens2eg[r[0]].append(r[1])
#{r[1]:r[0] for r in res if r is not None}

cur.executescript(sql_create_entrez_ppi + sql_index_entrez_ppi)

with open(settings.links_tbl_tpl.format(taxid), 'r') as inp:
  cur.execute('BEGIN TRANSACTION;')
  for line in inp:
    id1, id2, score = line.split(' ')
    null = cur.executemany('INSERT INTO entrez_ppi (`id1`, `id2`, `score`) VALUES (?,?,?);', product( ens2eg[id1], ens2eg[id2], [int(score)] ) )
  conn.commit()

with open(settings.R_package_path.join(settings.taxonomies[taxid]['bioc'],'DESCRIPTION')) as inp:
  desc = inp.read()
  vers = re.findall('^Version: (.*)$', desc, re.MULTILINE)
  built = re.findall('^Built: (.*)$', desc, re.MULTILINE)

cur.execute('INSERT INTO `meta` (`meta`, `value`) VALUES (?, ?);', ('entrez',1))
cur.execute('INSERT INTO `meta` (`meta`, `value`) VALUES (?, ?);', ('entrez_tbl','entrez_ppi'))
cur.execute('INSERT INTO `meta` (`meta`, `value`) VALUES (?, ?);', ('ens2entrez',settings.taxonomies[taxid]['bioc']))
cur.execute('INSERT INTO `meta` (`meta`, `value`) VALUES (?, ?);', ('ens2entrez_version',vers))
cur.execute('INSERT INTO `meta` (`meta`, `value`) VALUES (?, ?);', ('ens2entrez_built',built))  
  
settings.print_time('Script stopped at')  
# Update ppi table with newly mapped geneids
#cur.execute('BEGIN TRANSACTION;')
#cur.execute('INSERT INTO `ppi` (`id1`,`id2`,`score`) \
#  SELECT `g1`.`id` as `id1`, `g2`.`id` as `id2`, `tmp_ppi`.`score` as `score` FROM `tmp_ppi` \
#  INNER JOIN `geneid` as `g1` ON `g1`.`gene`=`tmp_ppi`.`id1` \
#  INNER JOIN `geneid` as `g2` ON `g2`.`gene`=`tmp_ppi`.`id2`;')
#conn.commit()

#select `g1`.`gene` as `g1`, `g2`.`gene` as `g2`, `ppi`.`score` FROM geneid as g1
#  INNER JOIN ppi ON ppi.id1 = g1.id
#  inner join geneid as g2 on g2.id=ppi.id2
#  where g1.gene = 'ENSBTAP00000000005';



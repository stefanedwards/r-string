import time
from Path import Path

def print_time(prepend, **kwargs):
  print(prepend, time.strftime('%a %b %d %H:%M:%S %Y'), **kwargs)
 
print_time('Script started')

STRING_version = '9.0'
links_url = 'http://string-db.org/newstring_download/protein.links.v9.0.txt.gz'
links_fn_gz = 'protein.links.v9.0.txt.gz'
links_fn_bz2 = 'protein.links.v9.0.txt.bz2'
links_idx_fn = 'protein.links.v9.0.idx'
links_ind_fn = 'protein.links.v9.0.index'
detailed = 'http://string-db.org/newstring_download/protein.links.detailed.v9.0.txt.gz'
taxdmp_url = ''
taxdmp_fn = 'taxdmp.zip'
links_tbl_tpl = 'protein.links.v9.0.{}'
sqlite_db_tpl = 'STRING.v.9.0.{}.sqlite3'

R_package_path = Path('/home/stefan/R/i686-pc-linux-gnu-library/2.14')
taxonomies = dict()
taxonomies[9606] = {'short':'Hs', 'bioc':'org.Hs.eg.db', 'db':'extdata/org.Hs.eg.sqlite', 'primary encoding':'ensembl'}  # Human
taxonomies[9913] = {'short':'Bt', 'bioc':'org.Bt.eg.db', 'db':'extdata/org.Bt.eg.sqlite', 'primary encoding':'ensembl'}  # Bos taurus
taxonomies[10090] = {'short':'Mm', 'bioc':'org.Mm.eg.db', 'db':'extdata/org.Mm.eg.sqlite', 'primary encoding':'ensembl'}  # Mouse
#BioC db packages version: R_package_path / taxonomies[taxid]['bioc'] / DESCRIPTION $ Version
import time

print('Script started', time.strftime('%a %b %d %H:%M:%S %Y'))

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

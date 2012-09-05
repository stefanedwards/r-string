#!/usr/bin/python
####################################
## Indices STRING-db.org links datafile after organism.
## Author: Stefan McKinnon H\oj-Edwards <sme@iysik.com>
## Date: Sept. 2012
####################################
from gzip import GzipFile
from bz2 import BZ2File
import os
import settings
import pickle

# Repack to bz2 if necessary;
# Can be achieved by simply issuing command:
# gunzip -c -d protein.links.v9.0.txt.gz | bzip2 -z > protein.links.v9.0.txt.bz2
if not os.path.exists(settings.links_fn_bz2):
  with GzipFile(settings.links_fn_gz) as inp, BZ2File(settings.links_fn_bz2, 'w') as out:
    for l in inp:
      out.write(l)

organisms = dict()  
last_org = None
jump = 100000
with BZ2File(settings.links_fn_bz2) as inp:
  while True:
    line = inp.readline()  # first line contains column names
    position = inp.tell()
    line = inp.readline()
    if len(line) == 0:
      break
    org, rest = line.split(b'.', 1)
    if org != last_org:
      # step back again and read line by line until we find the new organism.
      inp.seek(position-jump, 0)
      line = inp.readline()
      while True:
        position = inp.tell()
        line = inp.readline()
        org, rest = line.split(b'.', 1)
        if org != last_org:
          organisms[org] = position
          last_org = org
          break
    inp.seek(jump, 1)
    if inp.tell() > 30000000: # first organism ends somewhere 'just' before 23759324.
      break
  
with open(settings.links_index_fn, 'w') as out:
  pickle.dump(organisms, out, protocol=2)

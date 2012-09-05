#!/usr/bin/python3
####################################
## Extracts all interactions for a given species from STRING-db links-flatfile.
## Author: Stefan McKinnon H\oj-Edwards <sme@iysik.com>
## Date: Sept. 2012
####################################
import sys
import os
import pickle
from bz2 import BZ2File

import settings

extract_taxids = [8090, 9606, 9031]

## we assume that the entries in the links-flatfile are in increasing order by the id, so we merely sort the list:
extract_taxids.sort()

### Load index file
with open(settings.links_idx_fn, 'rb') as inp:
  organisms = pickle.load(inp)
## Quick test that all taxids are found in the indexing:
all_there = [organisms[t] for t in extract_taxids]

inp = BZ2File(settings.links_fn_bz2)
i = 0
if True:
#with BZ2File(settings.links_fn_bz2) as inp:
  for taxid in extract_taxids:
    out = open(settings.links_tbl_tpl.format(taxid), 'w') 
    inp.seek(organisms[taxid], 0)
    stax = '{}.'.format(taxid).encode()
    while True:
      ens1, ens2, score = inp.readline().split(b' ')
      if not ens1.startswith(stax):
        break
      print(ens1[len(stax):], ens2[len(stax):], score, end='', sep=' ', file=out)  # score is suffixed with newline.
    
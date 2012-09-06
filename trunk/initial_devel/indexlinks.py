#!/usr/bin/python3
####################################
## Indexes STRING-db.org links datafile after organism.
## Author: Stefan McKinnon H\oj-Edwards <sme@iysik.com>
## Date: Sept. 2012
####################################
import sys
import os
import pickle
from gzip import GzipFile
from bz2 import BZ2File
from zipfile import ZipFile
import time

import settings

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
filesize = os.path.getsize(settings.links_fn_bz2) * 8.095 # 8 is an approximation of compression rate
cur_step = -1
next_step = 0
start = time.clock()
tid = 0
with BZ2File(settings.links_fn_bz2) as inp, ZipFile(settings.taxdmp_fn) as zz, zz.open('names.dmp') as fname, open(settings.links_ind_fn, 'w') as out:
  while True:
    line = inp.readline()  # first line contains column names
    position = inp.tell()
    
    step = round(position/filesize, 2)
    if step > cur_step and step >= next_step:
      print(step*100, '%', ' elapsed time: ', round((time.clock()-start)/60.0, 2), ' minutes', sep='')
      cur_step = step
      next_step += 0.01
    
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
          ## This is where we find the actual position
          organisms[int(org)] = position
          last_org = org
          org = int(org)
          while org > tid:
            tid, tname, rest = ( s.strip() for s in fname.readline().split(b'|', 2) )
            tid = int(tid)
          while True:
            tid, tname, rest = ( s.strip() for s in fname.readline().split(b'|', 2) )
            tid = int(tid)            
            if org == tid:
              print(tid, tname, position, sep='\t', end='\n', file=out)
            else:
              break
          break
    inp.seek(jump, 1)
    #if inp.tell() > 62 * 10**6: #18*10**8:
    #  break
    if tid > 10000:
      break

print('Stopped at position',position,'after',round((time.clock()-start)/60.0, 2), 'minutes.')
#print('True compression rate:', round(position/(filesize/8.095), 2))

with open(settings.links_idx_fn, 'wb') as out:
  pickle.dump(organisms, out, protocol=2)

# I considered placing the binary and tabular index in a zip file, kinda fancy,
# but the tabular file would be corrupted if the zip-file was not closed properly.
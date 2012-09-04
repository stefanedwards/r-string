#!/bin/bash

GZ_FILE = 'protein.links.v9.0.txt'

wget http://string-db.org/newstring_download/$GZ_FILE.gz
gunzip -c -d $GZ_FILE.gz | bzip2 -z > $GZ_FILE.bz2


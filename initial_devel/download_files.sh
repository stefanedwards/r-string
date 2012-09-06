#!/bin/bash
#PBS -l walltime=03:00:00
#PBS -j oe

opts=''
## Sometimes the script is run with the qsub-system, so we add some flavours.
if [ -n $PBS_O_WORKDIR ]; then
cd $PBS_O_WORKDIR
opts='-nv'
fi
GZ_FILE='protein.links.v9.0.txt'

echo Fetching $GZ_FILE

if [ ! -f $GZ_FILE.gz ]; then
  wget $opts http://string-db.org/newstring_download/$GZ_FILE.gz
fi

gunzip -c -d $GZ_FILE.gz | bzip2 -z > $GZ_FILE.bz2


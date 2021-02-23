#!/bin/sh 

# set machine
if [[ -d /scratch1 ]] ; then
  machine=hera
elif [[ -d /lfs4 ]] ; then
  machine=jet
else
  echo "machine not found!"
fi

# checkout nclvx branch and copy files to directory above
git clone -b exp/nclvx gerrit:FV3_ESRL nclvx
mv nclvx/* ../
/bin/rm -fr nclvx

# copy all* files from <machine>_xml
mv ../${machine}_xml/all* ./




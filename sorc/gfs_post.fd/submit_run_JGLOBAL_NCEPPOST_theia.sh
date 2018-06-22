#!/bin/bash

run=${1:-gfs}
bdate=${2:-2018041600}
edate=${2:-2018041600}
export allfhr=${3:-"003"}

#Input Data
#export COMINP=/u/Wen.Meng/ptmp/prfv3rt1
export COMINP=/scratch3/NCEPDEV/ovp/Wen.Meng/prfv3test

#Working directory
tmp=/scratch3/NCEPDEV/stmp2/$USER/nceppost
mkdir -p $tmp/ecf
diroutp=$tmp/outputs
mkdir -p $diroutp

#UPP location
export svndir=`pwd`

while [[ $bdate -le $edate ]]; do
   yyyymmdd=`echo $bdate | cut -c1-8`
   sed -e "s|CURRENTDATE|$bdate|" \
       -e "s|STDDIR|$diroutp|" \
       -e "s|RRR|$run|" \
      run_JGLOBAL_NCEPPOST_theia >$tmp/ecf/run_JGLOBAL_NCEPPOST_${run}.$bdate
   qsub $tmp/ecf/run_JGLOBAL_NCEPPOST_${run}.$bdate
   bdate=`ndate +24 $bdate`
done

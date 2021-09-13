#!/bin/sh

### archive chem ICs

icdir=/scratch1/BMC/gsd-fv3/rtruns/FV3-Chem/FV3ICS

#for year in 2021 2020; do
#  for month in `seq -f %02g 12 -1 1`; do
#    for day in `seq -f %02g 31 -1 1`; do
#      if [ -d ${icdir}/${year}${month}${day}00 ]; then
#        ./archive_ics384_args.ksh ${year}${month}${day}00 C384
#      fi
#    done
#  done
#done
#
year=2019
for month in `seq -f %02g 12 -1 6`; do
  for day in `seq -f %02g 31 -1 1`; do
    if [ -d ${icdir}/${year}${month}${day}00 ]; then
      ./archive_ics384_args.ksh ${year}${month}${day}00 C384
    fi
  done
done


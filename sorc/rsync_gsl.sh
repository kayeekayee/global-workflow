#!/bin/sh

##
##  this script copies over GSL changes not in ufs-community/ufs-weather-model repository
##
for dir in ufs_model.fd ufs_utils.fd; do
  if [[ -d ${dir}_gsl ]]; then
    echo "syncing ${dir}_gsl...."
    rsync -avx ${dir}_gsl/ ${dir}/       
  fi
done


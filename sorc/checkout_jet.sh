#!/bin/sh
#set -xue
set -x

while getopts "om:" option; do
 case $option in
  o)
   echo "Received -o flag for optional checkout of operational-only codes"
   checkout_gtg="YES"
   checkout_wafs="YES"
   ;;
  m)
   echo "Received -m flag with argument, will check out ufs-weather-model hash $OPTARG instead of default"
   ufs_model_hash=$OPTARG
   ;;
  :)
   echo "option -$OPTARG needs an argument"
   ;;
  *)
   echo "invalid option -$OPTARG, exiting..."
   exit
   ;;
 esac
done

topdir=$(pwd)
logdir="${topdir}/logs"
mkdir -p ${logdir}

echo ufs-weather-model checkout ...
if [[ ! -d ufs_model.fd ]] ; then
    #JKHgit clone https://github.com/ufs-community/ufs-weather-model ufs_model.fd >> ${logdir}/checkout-ufs_model.log 2>&1
    git clone https://github.com/NOAA-GSL/ufs-weather-model ufs_model.fd >> ${logdir}/checkout-ufs_model.log 2>&1
    cd ufs_model.fd
    #JKH  24Feb22 branch, a2a6a22b865d471a2814712ea80bef946d30bd2d
    git checkout ${ufs_model_hash:-global-24Feb2022}
    git submodule update --init --recursive
    cd ${topdir}
    if [[ -d ufs_model.fd_gsl ]]; then
        rsync -avx ufs_model.fd_gsl/ ufs_model.fd/        ## copy over GSL changes not in UFS repository
    fi
else
    echo 'Skip.  Directory ufs_model.fd already exists.'
fi 

#JKHecho gsi checkout ...
#JKHif [[ ! -d gsi.fd ]] ; then
#JKH    rm -f ${logdir}/checkout-gsi.log
#JKH    git clone --recursive https://github.com/NOAA-EMC/GSI.git gsi.fd >> ${logdir}/checkout-gsi.log 2>&1
#JKH    cd gsi.fd
#JKH    git checkout a62dec6
#JKH    git submodule update
#JKH    cd ${topdir}
#JKHelse
#JKH    echo 'Skip.  Directory gsi.fd already exists.'
#JKHfi
#JKH
#JKHecho gldas checkout ...
#JKHif [[ ! -d gldas.fd ]] ; then
#JKH    rm -f ${logdir}/checkout-gldas.log
#JKH    git clone https://github.com/NOAA-EMC/GLDAS.git gldas.fd >> ${logdir}/checkout-gldas.fd.log 2>&1
#JKH    cd gldas.fd
#JKH    git checkout gldas_gfsv16_release.v.1.28.0
#JKH    cd ${topdir}
#JKHelse
#JKH    echo 'Skip.  Directory gldas.fd already exists.'
#JKHfi

echo ufs_utils checkout ...
if [[ ! -d ufs_utils.fd ]] ; then
    rm -f ${logdir}/checkout-ufs_utils.log
    git clone --recursive https://github.com/ufs-community/UFS_UTILS.git ufs_utils.fd >> ${logdir}/checkout-ufs_utils.fd.log 2>&1
    cd ufs_utils.fd
    git checkout 26cd024
    cd ${topdir}
    if [[ -d ufs_utils.fd_gsl ]]; then
        rsync -avx ufs_utils.fd_gsl/ ufs_utils.fd/        ## copy over GSL changes not in UFS_UTILS repository
    fi
else
    echo 'Skip.  Directory ufs_utils.fd already exists.'
fi

echo UPP checkout ...
if [[ ! -d gfs_post.fd ]] ; then
    rm -f ${logdir}/checkout-gfs_post.log
    git clone https://github.com/NOAA-EMC/UPP.git gfs_post.fd >> ${logdir}/checkout-gfs_post.log 2>&1
    cd gfs_post.fd
    git checkout c939eae
    git submodule update --init CMakeModules
    ################################################################################
    # checkout_gtg
    ## yes: The gtg code at NCAR private repository is available for ops. GFS only.
    #       Only approved persons/groups have access permission.
    ## no:  No need to check out gtg code for general GFS users.
    ################################################################################
    checkout_gtg=${checkout_gtg:-"NO"}
    if [[ ${checkout_gtg} == "YES" ]] ; then
      ./manage_externals/checkout_externals
      cp sorc/post_gtg.fd/*F90 sorc/ncep_post.fd/.
      cp sorc/post_gtg.fd/gtg.config.gfs parm/gtg.config.gfs
    fi
    cd ${topdir}
    if [[ -d gfs_post.fd_gsl ]]; then
        rsync -avx gfs_post.fd_gsl/ gfs_post.fd/        ## copy over GSL changes not in UPP repository
    fi
else
    echo 'Skip.  Directory gfs_post.fd already exists.'
fi

checkout_wafs=${checkout_wafs:-"NO"}
if [[ ${checkout_wafs} == "YES" ]] ; then
  echo EMC_gfs_wafs checkout ...
  if [[ ! -d gfs_wafs.fd ]] ; then
    rm -f ${logdir}/checkout-gfs_wafs.log
    git clone --recursive https://github.com/NOAA-EMC/EMC_gfs_wafs.git gfs_wafs.fd >> ${logdir}/checkout-gfs_wafs.log 2>&1
    cd gfs_wafs.fd
    git checkout c2a29a67d9432b4d6fba99eac7797b81d05202b6
    cd ${topdir}
  else
    echo 'Skip.  Directory gfs_wafs.fd already exists.'
  fi
fi

echo EMC_verif-global checkout ...
if [[ ! -d verif-global.fd ]] ; then
    rm -f ${logdir}/checkout-verif-global.log
    git clone --recursive https://github.com/NOAA-EMC/EMC_verif-global.git verif-global.fd >> ${logdir}/checkout-verif-global.log 2>&1
    cd verif-global.fd
    git checkout verif_global_v2.8.0
    cd ${topdir}
else
    echo 'Skip. Directory verif-global.fd already exist.'
fi

#JKHecho aeroconv checkout ...
#JKHif [[ ! -d aeroconv.fd ]] ; then
#JKH    rm -f ${logdir}/checkout-aero.log
#JKH    git clone https://github.com/NCAR/aeroconv aeroconv.fd >> ${logdir}/checkout-aero.log 2>&1
#JKH    cd aeroconv.fd
#JKH    git checkout 24f6ddc
#JKH    cd ${topdir}
#JKH    ./aero_extract.sh
#JKHelse
#JKH    echo 'Skip.  Directory aeroconv.fd already exists.'
#JKHfi

echo nclvx checkout ...
wfmdir=../FV3GFSwfm
cd $wfmdir

if [[ ! -d nclvx ]]; then
    rm -f ${logdir}/checkout-nclvx.log
    git clone -b realtime/nclvx gerrit:FV3_ESRL nclvx >> ${logdir}/checkout-nclvx.log 2>&1
else
    echo 'Skip.  Directory nclvx already exists.'
fi

exit 0

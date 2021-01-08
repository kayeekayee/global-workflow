#!/bin/sh
#set -xue
set -x

while getopts "oc" option;
do
 case $option in
  o)
   echo "Received -o flag for optional checkout of GTG, will check out GTG with EMC_post"
   checkout_gtg="YES"
   ;;
  c)
   echo "Received -c flag, check out ufs-weather-model develop branch with CCPP physics"  
   run_ccpp="YES"
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
echo $topdir

echo fv3gfs checkout ...
if [[ ! -d fv3gfs.fd ]] ; then
    rm -f ${topdir}/checkout-fv3gfs.log
    #JKHgit clone https://github.com/ufs-community/ufs-weather-model fv3gfs.fd >> ${topdir}/checkout-fv3gfs.log 2>&1
    #JKHcd fv3gfs.fd
    if [ ${run_ccpp:-"NO"} = "NO" ]; then
        git clone https://github.com/ufs-community/ufs-weather-model fv3gfs.fd >> ${topdir}/checkout-fv3gfs.log 2>&1
        cd fv3gfs.fd
        git checkout GFS.v16.0.14
    else
        git clone --recursive -b gsl/develop https://github.com/NOAA-GSL/ufs-weather-model ufs-weather-model_18dec_57a8258  >> ${topdir}/checkout-fv3gfs.log
g 2>&1
        cd ufs-weather-model_18dec_57a8258
        git checkout 57a825847f51e18705faf5216e93c4ddbb1307a7
        #git checkout b771e5be7e35eaea5ee7f762d644afccab019ed3
    fi
    git submodule update --init --recursive
    cd ${topdir}
    ln -fs ufs-weather-model_18dec_57a8258 fv3gfs.fd 
    rsync -ax fv3gfs.fd_gsl/ fv3gfs.fd/        ## copy over changes not in FV3 repository
else
    echo 'Skip.  Directory fv3gfs.fd already exists.'
fi

#JKHecho gsi checkout ...
#JKHif [[ ! -d gsi.fd ]] ; then
#JKH    rm -f ${topdir}/checkout-gsi.log
#JKH    git clone --recursive https://github.com/NOAA-EMC/GSI.git gsi.fd >> ${topdir}/checkout-gsi.log 2>&1
#JKH    cd gsi.fd
#JKH    git checkout gfsda.v16.0.0
#JKH    git submodule update
#JKH    cd ${topdir}
#JKHelse
#JKH    echo 'Skip.  Directory gsi.fd already exists.'
#JKHfi
#JKH
#JKHecho gldas checkout ...
#JKHif [[ ! -d gldas.fd ]] ; then
#JKH    rm -f ${topdir}/checkout-gldas.log
#JKH    git clone https://github.com/NOAA-EMC/GLDAS.git gldas.fd >> ${topdir}/checkout-gldas.fd.log 2>&1
#JKH    cd gldas.fd
#JKH    git checkout gldas_gfsv16_release.v1.12.0
#JKH    cd ${topdir}
#JKHelse
#JKH    echo 'Skip.  Directory gldas.fd already exists.'
#JKHfi

echo ufs_utils checkout ...
if [[ ! -d ufs_utils.fd ]] ; then
    rm -f ${topdir}/checkout-ufs_utils.log
    git clone https://github.com/NOAA-EMC/UFS_UTILS.git ufs_utils.fd >> ${topdir}/checkout-ufs_utils.fd.log 2>&1
    cd ufs_utils.fd
    git checkout ops-gfsv16.0.0
    cd ${topdir}
    rsync -ax ufs_utils.fd_gsl/ ufs_utils.fd/        ## copy over changes not in UFS_UTILS repository
else
    echo 'Skip.  Directory ufs_utils.fd already exists.'
fi

echo EMC_post checkout ...
if [[ ! -d gfs_post.fd ]] ; then
    rm -f ${topdir}/checkout-gfs_post.log
    git clone https://github.com/NOAA-EMC/EMC_post.git gfs_post.fd >> ${topdir}/checkout-gfs_post.log 2>&1
    cd gfs_post.fd
    git checkout upp_gfsv16_release.v1.1.1
    ################################################################################
    # checkout_gtg
    ## yes: The gtg code at NCAR private repository is available for ops. GFS only.
    #       Only approved persons/groups have access permission.
    ## no:  No need to check out gtg code for general GFS users.
    ################################################################################
    checkout_gtg=${checkout_gtg:-"NO"}
    if [[ ${checkout_gtg} == "YES" ]] ; then
      ./manage_externals/checkout_externals
      cp sorc/post_gtg.fd/*f90 sorc/ncep_post.fd/.
      cp sorc/post_gtg.fd/gtg.config.gfs parm/gtg.config.gfs
    fi
    cd ${topdir}
    rsync -ax gfs_post.fd_gsl/ gfs_post.fd/        ## copy over GSL changes not in EMC_post repository
else
    echo 'Skip.  Directory gfs_post.fd already exists.'
fi

#JKHecho EMC_gfs_wafs checkout ...
#JKHif [[ ! -d gfs_wafs.fd ]] ; then
#JKH    rm -f ${topdir}/checkout-gfs_wafs.log
#JKH    git clone --recursive https://github.com/NOAA-EMC/EMC_gfs_wafs.git gfs_wafs.fd >> ${topdir}/checkout-gfs_wafs.log 2>&1
#JKH    cd gfs_wafs.fd
#JKH    git checkout gfs_wafs.v6.0.17
#JKH    cd ${topdir}
#JKHelse
#JKH    echo 'Skip.  Directory gfs_wafs.fd already exists.'
#JKHfi

echo EMC_verif-global checkout ...
if [[ ! -d verif-global.fd ]] ; then
    rm -f ${topdir}/checkout-verif-global.log
    git clone --recursive https://github.com/NOAA-EMC/EMC_verif-global.git verif-global.fd >> ${topdir}/checkout-verif-global.log 2>&1
    cd verif-global.fd
    git checkout verif_global_v1.11.0
    cd ${topdir}
else
    echo 'Skip. Directory verif-global.fd already exist.'
fi

echo aeroconv checkout ...
if [[ ! -d aeroconv.fd ]] ; then
    rm -f ${topdir}/checkout-aero.log
    git clone https://github.com/NCAR/aeroconv aeroconv.fd >> ${topdir}/checkout-aero.log 2>&1
    cd aeroconv.fd
    git checkout 24f6ddc
    cd ${topdir}
    ./aero_extract.sh
else
    echo 'Skip.  Directory aeroconv.fd already exists.'
fi

exit 0

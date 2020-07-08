#!/bin/sh
set -xue

topdir=$(pwd)
echo $topdir

#JKHecho fv3gfs_emc checkout ...
#JKHif [[ ! -d fv3gfs_emc.fd ]] ; then
#JKH    rm -f ${topdir}/checkout-fv3gfs_emc.log
#JKH    #git clone https://github.com/ufs-community/ufs-weather-model fv3gfs_emc.fd >> ${topdir}/checkout-fv3gfs_emc.log 2>&1
#JKH    git clone https://github.com/DusanJovic-NOAA/ufs-weather-model fv3gfs_emc.fd >> ${topdir}/checkout-fv3gfs_emc.log 2>&1
#JKH    cd fv3gfs_emc.fd
#JKH    git checkout orion_gfs.v16
#JKH    git submodule update --init --recursive
#JKH    cd ${topdir}
#JKHelse
#JKH    echo 'Skip.  Directory fv3gfs_emc.fd already exists.'
#JKHfi

echo fv3gfs_ccpp checkout ...
if [[ ! -d fv3gfs_ccpp.fd ]] ; then
    rm -f ${topdir}/checkout-fv3gfs_ccpp.log
    git clone --recursive -b gsd/develop https://github.com/NOAA-GSD/ufs-weather-model  fv3gfs_ccpp.fd >> ${topdir}/checkout-fv3gfs_ccpp.log 2>&1
    cd fv3gfs_ccpp.fd
    git checkout 27a8a079baeb436873fc102128feef4ee6625d46
    git submodule sync
    git submodule update --init --recursive
    cd ${topdir}
    ln -fs fv3gfs_ccpp.fd fv3gfs.fd
else
    echo 'Skip.  Directory fv3gfs_ccpp.fd already exists.'
fi

echo gsi checkout ...
if [[ ! -d gsi.fd ]] ; then
    rm -f ${topdir}/checkout-gsi.log
    git clone --recursive https://github.com/NOAA-EMC/GSI.git gsi.fd >> ${topdir}/checkout-gsi.log 2>&1
    cd gsi.fd
    git checkout release/gfsda.v16.0.0
    git submodule update
    cd ${topdir}
else
    echo 'Skip.  Directory gsi.fd already exists.'
fi

echo gldas checkout ...
if [[ ! -d gldas.fd ]] ; then
    rm -f ${topdir}/checkout-gldas.log
    git clone https://github.com/NOAA-EMC/GLDAS.git gldas.fd >> ${topdir}/checkout-gldas.fd.log 2>&1
    cd gldas.fd
    #git checkout gldas_gfsv16_release.v1.2.0
    git checkout feature/orion_port
    cd ${topdir}
else
    echo 'Skip.  Directory gldas.fd already exists.'
fi

echo ufs_utils checkout ...
if [[ ! -d ufs_utils.fd ]] ; then
    rm -f ${topdir}/checkout-ufs_utils.log
    #git clone https://github.com/NOAA-EMC/UFS_UTILS.git ufs_utils.fd >> ${topdir}/checkout-ufs_utils.fd.log 2>&1
    git clone --recursive https://github.com/GeorgeGayno-NOAA/UFS_UTILS.git ufs_utils.fd >> ${topdir}/checkout-ufs_utils.fd.log 2>&1
    cd ufs_utils.fd
    #git checkout release/ops-gfsv16 
    git checkout feature/orion
    cd ${topdir}
else
    echo 'Skip.  Directory ufs_utils.fd already exists.'
fi

echo EMC_post checkout ...
if [[ ! -d gfs_post.fd ]] ; then
    rm -f ${topdir}/checkout-gfs_post.log
    git clone https://github.com/NOAA-EMC/EMC_post.git gfs_post.fd >> ${topdir}/checkout-gfs_post.log 2>&1
    cd gfs_post.fd
    git checkout upp_gfsv16_release.v1.0.9
    cd ${topdir}
else
    echo 'Skip.  Directory gfs_post.fd already exists.'
fi

echo EMC_gfs_wafs checkout ...
if [[ ! -d gfs_wafs.fd ]] ; then
    rm -f ${topdir}/checkout-gfs_wafs.log
    git clone --recursive https://github.com/NOAA-EMC/EMC_gfs_wafs.git gfs_wafs.fd >> ${topdir}/checkout-gfs_wafs.log 2>&1
    cd gfs_wafs.fd
    git checkout gfs_wafs.v5.0.11
    cd ${topdir}
else
    echo 'Skip.  Directory gfs_wafs.fd already exists.'
fi

echo EMC_verif-global checkout ...
if [[ ! -d verif-global.fd ]] ; then
    rm -f ${topdir}/checkout-verif-global.log
    git clone --recursive https://github.com/NOAA-EMC/EMC_verif-global.git verif-global.fd >> ${topdir}/checkout-verif-global.log 2>&1
    cd verif-global.fd
    git checkout verif_global_v1.8.1
    cd ${topdir}
else
    echo 'Skip. Directory verif-global.fd already exist.'
fi

echo aeroconv checkout ...
if [[ ! -d aeroconv.fd ]] ; then
    rm -f ${topdir}/checkout-aero.log
    git clone https://github.com/NCAR/aeroconv aeroconv.fd >> ${topdir}/checkout-aero.log 2>&1
    cd aeroconv.fd
    git checkout b830a6c
else
    echo 'Skip.  Directory aeroconv.fd already exists.'
fi

exit 0

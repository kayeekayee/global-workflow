#!/bin/sh
set -xu

topdir=$(pwd)
echo $topdir

echo fv3gfs checkout ...
if [[ ! -d fv3gfs.fd ]] ; then
    rm -f ${topdir}/checkout-fv3gfs.log
    git clone --recursive gerrit:EMC_FV3GFS-GSDCHEM >> ${topdir}/checkout-fv3gfs.log 2>&1
    ln -sf EMC_FV3GFS-GSDCHEM fv3gfs.fd 
    #git checkout gfs.v16_PhysicsUpdate
    #git submodule update --init --recursive
    cd ${topdir}
else
    echo 'Skip.  Directory fv3gfs.fd already exists.'
fi

echo gsi checkout ...
if [[ ! -d gsi.fd ]] ; then
    rm -f ${topdir}/checkout-gsi.log
    git clone --recursive https://github.com/NOAA-EMC/GSI.git gsi.fd >> ${topdir}/checkout-gsi.log 2>&1
    cd gsi.fd
    git checkout release/gfsda.v16.0.0
    git submodule update
    cd ${topdir}
    rsync -ax gsi.fd_chem/ gsi.fd/
else
    echo 'Skip.  Directory gsi.fd already exists.'
fi


echo ufs_utils checkout ...
if [[ ! -d ufs_utils.fd ]] ; then
    rm -f ${topdir}/checkout-ufs_utils.log
    git clone --recursive https://github.com/NOAA-EMC/UFS_UTILS.git ufs_utils.fd >> ${topdir}/checkout-ufs_utils.fd.log 2>&1
    cd ufs_utils.fd
    git checkout 7371edaf3b7c94b5557c254296e1d17a68f7c5b1
    cd ${topdir}
else
    echo 'Skip.  Directory ufs_utils.fd already exists.'
fi

echo EMC_post checkout ...
if [[ ! -d gfs_post.fd ]] ; then
    rm -f ${topdir}/checkout-gfs_post.log
    git clone --recursive https://github.com/NOAA-EMC/EMC_post.git gfs_post.fd >> ${topdir}/checkout-gfs_post.log 2>&1
    #git clone --recursive gerrit:EMC_post_gtg gfs_post.fd >> ${topdir}/checkout-gfs_post.log 2>&1
    cd gfs_post.fd
    git checkout ba7e59b290c8149ff1c2fee98d01e99e4ef92ee6
    #git checkout ncep_post.v8.0.27e
    #git checkout ncep_post_gtg.v1.0.6c
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
    git clone --recursive gerrit:EMC_verif-global verif-global.fd >> ${topdir}/checkout-verif-global.log 2>&1
    cd verif-global.fd
    git checkout verif_global_v1.2.2
    cd ${topdir}
else
    echo 'Skip. Directory verif-global.fd already exist.'
fi

exit 0

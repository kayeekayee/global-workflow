#!/bin/bash

###############################################################
# Source relevant configs
configs="base"
for config in $configs; do
    . $EXPDIR/config.${config}
    status=$?
    [[ $status -ne 0 ]] && exit $status
done

# initialize
AERO_DIR=${HOMEgfs}/sorc/aeroconv.fd
module purge
module load intel/18.0.5.274
module load impi/2018.4.274
module load hdf5/1.10.4
module load netcdf/4.6.1
module load udunits/2.1.24
module load ncl/6.5.0
module use -a /contrib/anaconda/modulefiles
module load anaconda/2.0.1

export LD_PRELOAD=$AERO_DIR/thirdparty/lib/libjpeg.so
export PATH=$AERO_DIR/thirdparty/bin:$PATH
export LD_LIBRARY_PATH=$AERO_DIR/thirdparty/lib:$AERO_DIR/thirdparty/lib64:$LD_LIBRARY_PATH
export PYTHONPATH=$AERO_DIR/thirdparty/lib/python2.7/site-packages:$PYTHONPATH

#
echo
echo "FIXfv3 = $FIXfv3"
echo "CDATE = $CDATE"
echo "CDUMP = $CDUMP"
echo "CASE = $CASE"
echo "AERO_DIR = $AERO_DIR"
echo "FV3ICS_DIR = $FV3ICS_DIR"
echo

# Temporary runtime directory
export DATA="$DATAROOT/aerofv3ic$$"
[[ -d $DATA ]] && rm -rf $DATA
mkdir -p $DATA/INPUT
cd $DATA
echo entering $DATA....

export OUTDIR="$ICSDIR/$CDATE/$CDUMP/$CASE/INPUT"

# link files
ln -sf ${AERO_DIR}/thirdparty 
ln -sf ${FV3ICS_DIR}/gfs_ctrl.nc INPUT       
ln -sf ${FV3ICS_DIR}/gfs_data.tile1.nc INPUT 
ln -sf ${FV3ICS_DIR}/gfs_data.tile2.nc INPUT 
ln -sf ${FV3ICS_DIR}/gfs_data.tile3.nc INPUT 
ln -sf ${FV3ICS_DIR}/gfs_data.tile4.nc INPUT 
ln -sf ${FV3ICS_DIR}/gfs_data.tile5.nc INPUT 
ln -sf ${FV3ICS_DIR}/gfs_data.tile6.nc INPUT 
ln -sf ${FIXfv3}/${CASE}/${CASE}_grid_spec.tile1.nc INPUT/grid_spec.tile1.nc
ln -sf ${FIXfv3}/${CASE}/${CASE}_grid_spec.tile2.nc INPUT/grid_spec.tile2.nc
ln -sf ${FIXfv3}/${CASE}/${CASE}_grid_spec.tile3.nc INPUT/grid_spec.tile3.nc
ln -sf ${FIXfv3}/${CASE}/${CASE}_grid_spec.tile4.nc INPUT/grid_spec.tile4.nc
ln -sf ${FIXfv3}/${CASE}/${CASE}_grid_spec.tile5.nc INPUT/grid_spec.tile5.nc
ln -sf ${FIXfv3}/${CASE}/${CASE}_grid_spec.tile6.nc INPUT/grid_spec.tile6.nc
ln -sf ${AERO_DIR}/INPUT/QNWFA_QNIFA_SIGMA_MONTHLY.dat.nc INPUT

cp ${AERO_DIR}/int2nc_to_nggps_ic_* ./ 

yyyymmdd=`echo $CDATE | cut -c1-8`
./int2nc_to_nggps_ic_batch.sh $yyyymmdd

# Move output data
echo "copying updated files to $FV3ICS_DIR...."
cp -p $DATA/OUTPUT/gfs*nc $FV3ICS_DIR

###############################################################
# Force Exit out cleanly
if [ ${KEEPDATA:-"NO"} = "NO" ] ; then rm -rf $DATA ; fi
#exit 0

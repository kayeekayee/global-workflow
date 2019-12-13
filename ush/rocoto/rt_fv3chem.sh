USER=rtfim
COMROT=/scratch1/BMC/gsd-fv3/rtruns/FV3-Chem/FV3GFSrun       ## default COMROT directory
EXPDIR=/scratch1/BMC/gsd-fv3/rtruns/FV3-Chem/FV3GFSwfm       ## default EXPDIR directory
PTMP=/scratch1/BMC/gsd-fv3/NCEPDEV/stmp3/$USER                       ## default PTMP directory
STMP=/scratch1/BMC/gsd-fv3/NCEPDEV/stmp4/$USER                       ## default STMP directory
GITDIR=/scratch1/BMC/gsd-fv3/rtruns/FV3-Chem/

#    ICSDIR is assumed to be under $COMROT/FV3ICS

PSLOT=rt_fv3gfs_chem_test_test
IDATE=2019100100
EDATE=2029092000
RESDET=384               ## 96 192 384 768

./setup_expt_fcstonly.py --pslot $PSLOT  \
       --gfs_cyc 2 --idate $IDATE --edate $EDATE \
       --configdir $GITDIR/parm/config \
       --res $RESDET --comrot $COMROT --expdir $EXPDIR

#for running chgres, forecast, and post 
./setup_workflow_fcstonly_gsd.py --expdir $EXPDIR/$PSLOT


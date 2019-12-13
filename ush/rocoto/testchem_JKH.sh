USER=Judy.K.Henderson
COMROT=/scratch1/BMC/gsd-fv3-dev/$USER/test/comrot ## default COMROT directory
EXPDIR=/scratch1/BMC/gsd-fv3-dev/$USER/test/expdir    ## default EXPDIR directory
PTMP=/scratch1/BMC/gsd-fv3-dev/NCEPDEV/stmp4/$USER                          ## default PTMP directory
STMP=/scratch1/BMC/gsd-fv3-dev/NCEPDEV/stmp3/$USER                          ## default STMP directory
GITDIR=/scratch1/BMC/gsd-fv3-dev/Judy.K.Henderson/test/testchem

#    ICSDIR is assumed to be under $COMROT/FV3ICS


PSLOT=test_fv3chem
IDATE=2019092000
EDATE=2019092000
RESDET=384               ## 96 192 384 768

./setup_expt_fcstonly.py --pslot $PSLOT  \
       --gfs_cyc 2 --idate $IDATE --edate $EDATE \
       --configdir $GITDIR/parm/config \
       --res $RESDET --comrot $COMROT --expdir $EXPDIR

#for running chgres, forecast, and post 
./setup_workflow_fcstonly_gsd.py --expdir $EXPDIR/$PSLOT


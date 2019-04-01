USER=Kate.Zhang
COMROT=/scratch4/BMC/fim/NCEPDEV/global/noscrub/$USER/fv3gfs/comrot ## default COMROT directory
EXPDIR=/scratch4/BMC/fim/NCEPDEV/global/save/$USER/fv3gfs/expdir    ## default EXPDIR directory
PTMP=/scratch4/BMC/fim/NCEPDEV/stmp4/$USER                          ## default PTMP directory
STMP=/scratch4/BMC/fim/NCEPDEV/stmp3/$USER                          ## default STMP directory
GITDIR=/scratch4/BMC/fim/lzhang/EMC_FV3/new/FV3_ESRL
#ICSDIR=/scratch4/BMC/fim/NCEPDEV/global/noscrub/$USER/fv3gfs/comrot/FV3ICS/
#    ICSDIR is assumed to be under $COMROT/FV3ICS


PSLOT=TC384_real_fv3_chem
IDATE=2019022700
EDATE=2019022700
#IDATE=2016100300
#EDATE=2016100300

./setup_expt_fcstonly.py --pslot $PSLOT  \
       --gfs_cyc 2 --idate $IDATE --edate $EDATE \
       --configdir $GITDIR/parm/config \
       --res 384 --comrot $COMROT --expdir $EXPDIR


   #add resolution parameter if running other than C192
#       --res 768 --comrot $COMROT --expdir $EXPDIR


#for running chgres, forecast, and post 
./setup_workflow_fcstonly_gsd.py --expdir $EXPDIR/$PSLOT


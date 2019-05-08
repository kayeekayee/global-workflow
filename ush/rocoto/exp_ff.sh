USER=Judy.K.Henderson
COMROT=/scratch4/BMC/fim/NCEPDEV/global/noscrub/$USER/fv3gfs/comrot ## default COMROT directory
EXPDIR=/scratch4/BMC/fim/NCEPDEV/global/save/$USER/fv3gfs/expdir    ## default EXPDIR directory
PTMP=/scratch4/BMC/fim/NCEPDEV/stmp4/$USER                          ## default PTMP directory
STMP=/scratch4/BMC/fim/NCEPDEV/stmp3/$USER                          ## default STMP directory
GITDIR=/home/Judy.K.Henderson/scratch/git_local/gerrit_master_05Mar19_595d44c

#    ICSDIR is assumed to be under $COMROT/FV3ICS
#         create link $COMROT/FV3ICS to point to /scratch4/BMC/rtfim/rtruns/FV3GFS/FV3ICS


PSLOT=slurm_beta
IDATE=2019032000
EDATE=2019032000
RESDET=384               ## 96 192 384 768

./setup_expt_fcstonly.py --pslot $PSLOT  \
       --gfs_cyc 2 --idate $IDATE --edate $EDATE \
       --configdir $GITDIR/parm/config \
       --res $RESDET --comrot $COMROT --expdir $EXPDIR

#for running chgres, forecast, and post 
./setup_workflow_fcstonly_gsd.py --expdir $EXPDIR/$PSLOT


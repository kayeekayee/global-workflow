USER=rtfim
GITDIR=/lfs4/BMC/gsd-fv3-dev/rtruns/UFS-CAMsuite_jet            ## where your git checkout is located
COMROT=$GITDIR/FV3GFSrun                                      ## default COMROT directory
EXPDIR=$GITDIR/FV3GFSwfm                                      ## default EXPDIR directory
ICSDIR=/lfs4/BMC/gsd-fv3-dev/rtruns/FV3ICS_L127/

PSLOT=rt_ufscam_l127
IDATE=2022032600
EDATE=2022032600
RESDET=768               ## 96 192 384 768

### gfs_cyc 1  00Z only;  gfs_cyc 2  00Z and 12Z

python3 ./setup_expt.py forecast-only --pslot $PSLOT  --gfs_cyc 1 \
       --idate $IDATE --edate $EDATE --resdet $RESDET \
       --comrot $COMROT --expdir $EXPDIR --icsdir $ICSDIR

./setup_workflow_fcstonly_gsl_ics.py --expdir $EXPDIR/$PSLOT

# call jobs/rocoto/arch_gsl.sh for gfsarch task
sed -i "s/arch.sh/arch_gsl.sh/" $EXPDIR/$PSLOT/$PSLOT.xml

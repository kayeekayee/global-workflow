USER=Judy.K.Henderson
GITDIR=/home/rtfim/GFSv17p8_HFIP                                 ## where your git checkout is located
COMROT=$GITDIR/FV3GFSrun                                         ## default COMROT directory
EXPDIR=$GITDIR/FV3GFSwfm                                         ## default EXPDIR directory
ICSDIR=/lfs1/BMC/gsd-fv3-test/rtfim/FV3ICS_L127/

PSLOT=v17_p8_gf_mynn
IDATE=2022082000
EDATE=2022082000
RESDET=768               ## 96 192 384 768

### gfs_cyc 1  00Z only;  gfs_cyc 2  00Z and 12Z

python3 ./setup_expt.py forecast-only --pslot $PSLOT  --gfs_cyc 1 \
       --idate $IDATE --edate $EDATE --resdet $RESDET \
       --comrot $COMROT --expdir $EXPDIR --icsdir $ICSDIR

./setup_workflow_fcstonly_gsl.py --expdir $EXPDIR/$PSLOT

## call jobs/rocoto/makeinit_link.sh for init task
sed -i "s/init.sh/makeinit_link.sh/" $EXPDIR/$PSLOT/$PSLOT.xml
# call jobs/rocoto/arch_gsl.sh for gfsarch task
sed -i "s/arch.sh/arch_gsl.sh/" $EXPDIR/$PSLOT/$PSLOT.xml



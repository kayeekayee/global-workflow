# How to run global-workflow on hera using singularity

These are the steps you need to do to run GFS v16b workflow using rocoto

## Getting the image

First you need to get a copy of the docker image for the global-workflow
   
    docker pull dshawul/gfs-gnu

Then, convert the docker image to singularity image using

    singularity pull docker://dshawul/gfs-gnu

You can't do these steps directly on hera so you will have to do it on your laptop
and copy the singularity image to hera.

## Sandbox

We will extract the singularity image to a "sandbox" as it is more convienient
and faster to run and work with. The sandbox is a regular directory with all contents
of the image.

    singularity build --sandbox workflow gfs-gnu_latest.sif

The directory `workflow` contains the contents of the image, and you can find global-workflow
under `workflow/opt/global-workflow`. You can setup a test case and run forecast using
this directory in place of the raw singularity image.

## Setting environement variables

This particular image uses GNU compilers and MPICH library so we will load modules that
will work with it. Moreover, we need to set environement variables needed for running
the workflow. Here is the content of my `set_environment.sh` script I use for this purpose

    #!/bin/tcsh
    
    set COLON=':'
    setenv GFS_FIX_DIR "/scratch1/NCEPDEV/global/glopara/fix"
    setenv GFS_IMG_DIR "/scratch2/BMC/gsd-hpcs/NCEPDEV/stmp3/Daniel.Abdi/containers/workflow"
    setenv GFS_NPE_NODE_MAX 24
    setenv GFS_SING_CMD "singularity exec --bind $GFS_FIX_DIR$COLON/fix $GFS_IMG_DIR run_bash_command"
    setenv GFS_DAEMON_RUN "$GFS_IMG_DIR/opt/global-workflow/cloud/scripts/run_sing_job.sh"
    setenv GFS_DAEMON_KILL "$GFS_IMG_DIR/opt/global-workflow/cloud/scripts/kill_sing_job.sh"
    
    module use /scratch2/BMC/gsd-hpcs/bass/modulefiles/ 
    module use /scratch2/BMC/gsd-hpcs/dlibs/modulefiles/ 
    
    module purge
    module load rocoto
    module load hpss
    module load gcc/9.3.0
    module load mpich/3.3a2

Then we source this script
   
    source ./set_environment.sh

## Setting up a test case

To setup a test case, we follow the same procedure as the one used without containers.
We write a script to set paths for EXPDIR, COMROT etc. Here is an example script for the C48 test case
Make sure to use dates after 2019092700 to get compatible initial conditions with GFSV16

    BASE=/scratch2/BMC/gsd-hpcs/NCEPDEV             ## Make sure you have access to the base directory
    COMROT=$BASE/global/noscrub/$USER/fv3gfs/comrot ## default COMROT directory
    EXPDIR=$BASE/global/save/$USER/fv3gfs/expdir    ## default EXPDIR directory
    PTMP=$BASE/stmp2/$USER                          ## default PTMP directory
    STMP=$BASE/stmp4/$USER                          ## default STMP directory
    HOMEDIR=$BASE/global/$USER                      ## default HOMEDIR directory
    ACCOUNT=gsd-hpcs                                ## default ACCOUNT
    
    GITDIR=$GFS_IMG_DIR/opt/global-workflow
    #GITDIR=/opt/global-workflow
    #    ICSDIR is assumed to be under $COMROT/FV3ICS
    #         create link $COMROT/FV3ICS to point to /scratch4/BMC/rtfim/rtruns/FV3ICS
    
    
    PSLOT=c48
    IDATE=2019092700
    EDATE=2019092700
    RESDET=48               ## 96 192 384 768
    GFSCYCLE=2
    
    
    ./setup_expt_fcstonly.py --pslot $PSLOT  \
           --gfs_cyc $GFSCYCLE --idate $IDATE --edate $EDATE \
           --configdir $GITDIR/parm/config \
           --res $RESDET --comrot $COMROT --expdir $EXPDIR \
           --homedir $HOMEDIR --ptmp $PTMP --stmp $STMP --account $ACCOUNT
    
    
    #for running chgres, forecast, and post 
    ./setup_workflow_fcstonly.py --expdir $EXPDIR/$PSLOT

Note that the `GITDIR` variable points to the location of our sandbox for the singularity image.
Save this script as c48.sh under `$GFS_IMG_DIR/opt/global-workflow/ush/rocoto`.

## Generating the test case directories and setting up a run

Run the c48.sh script to generate the directories and scripts needed for running the C48 workflow.
Under our experiment directory, we find a bunch of scripts sourced during the run.
We will modify a couple of them to fit our needs

### config.base

Set LEVS to 65 instead of 128. The new default of LEVS=128 does not work properly for some reason

    export LEVS=65

You can set the hours of forecast and write interval, e.g. for 3 hrs fcst 

    export FHMAX_GFS_00=3
    export FHMAX_GFS_06=3
    export FHMAX_GFS_12=3
    export FHMAX_GFS_18=3
   
    export FHOUT_GFS=3

Comment out or set to .false. the inline postprocessing option
   
    export WRITE_DOPOST=".false."

Set to NO wave processing, and optionally gldas
 
    export DO_GLDAS=NO
    export DO_WAVE=NO

### config.fv3

Here is where you control the number of mpi ranks and threads for your test case
if you so wish. Usually leave it to default.

Just as an example, to run C48 with as low as 6 mpi ranks, modify as follows

    export layout_x=1
    export layout_y=1
    export layout_x_gfs=1
    export layout_y_gfs=1

To use just 1 mpi rank for writing output

    export WRITE_GROUP=1
    export WRTTASK_PER_GROUP=1
    export WRITE_GROUP_GFS=1
    export WRTTASK_PER_GROUP_GFS=1

### config.fcst

There is a variable defined here for `io_layout` that you may need to turn off.
If you made changes to `config.fv3` as shown above you need to comment out

    #export io_layout=4,4

otherwise, you will get an error message

    Cubic: cubed-sphere domain layout(1) must be divided by io_layout(1)

### config.post

We don't have the HWRF coefficient files needed by post (CRTM one's don't work) so
we need to turn off

    GOESF=NO

### the rocoto xml file, c48.xml

If necessary, edit lines like below to modify the number of nodes, processors per node, threads per process

    <!ENTITY RESOURCES_FCST_GFS "<nodes>1:ppn=40:tpp=1</nodes>">

## Running the test case

Now that the test case is setup we can run different steps of the workflow using rocoto.
There is no difference between running GFS on hera with or without containers

For a forecast only run, make sure you have FV3ICS directory under $COMROT.

To run specific steps of the workflow, run rocotoboot under the $EXPDIR as follows

    rocotoboot -v 10 -w c48.xml -d c48.db -c all -t gfsgetic
    rocotoboot -v 10 -w c48.xml -d c48.db -c all -t gfsfv3ic
    rocotoboot -v 10 -w c48.xml -d c48.db -c all -t gfsfcst
    rocotoboot -v 10 -w c48.xml -d c48.db -c all -t gfspost001

Log files for your runs are stored under $COMROT/c48/logs, so you can investigate there
if something goes wrong.

This is the log files you should be seeing for each step

gfsgetic.log

    Waiting for job to finish.
    [connecting to hpsscore1.fairmont.rdhpcs.noaa.gov/1217]
    ******************************************************************
    *   Welcome to the NESCC High Performance Storage System         *
    *                                                                *
    *   Current HPSS version: 7.5.3                                  *
    *                                                                *
    *                                                                *
    *       Please Submit Helpdesk Request to                        *
    *        rdhpcs.hpss.help@noaa.gov                               *
    *                                                                *
    *  Announcements:                                                *
    ******************************************************************
    Username: Daniel.Abdi  UID: 20429  Acct: 20429(20429) Copies: 1 COS: 0 Firewall: off [hsi.6.3.0.p1-hgs Thu May 7 04:17:49 UTC 2020] 
    /NCEPPROD/hpssprod/runhistory/rh2019/201909/20190927:
    -rw-r--r--    1 nwprod    prod     294403269120 Sep 29  2019 gpfs_dell1_nco_ops_com_gfs_prod_gfs.20190927_00.gfs_nemsioa.tar
    0
    Job finished.
    + tail -1 /home/Daniel.Abdi/.output.log
    + exit 0
    + rc=0
    + [ 0 -ne 0 ] 
    + run_command htar -xvf /NCEPPROD/hpssprod/runhistory/rh2019/201909/20190927/gpfs_dell1_nco_ops_com_gfs_prod_gfs.20190927_00.gfs_nemsioa.tar ./gfs.20190927/00/gfs.t00z.atmanl.nemsio ./gfs.20190927/00/gfs.t00z.sfcanl.nemsio
    Waiting for job to finish.
    [connecting to hpsscore1.fairmont.rdhpcs.noaa.gov/1217]
    HTAR: x ./gfs.20190927/00/gfs.t00z.atmanl.nemsio, 15779010324 bytes, 30818381 media blocks
    HTAR: x ./gfs.20190927/00/gfs.t00z.sfcanl.nemsio, 1170221688 bytes, 2285591 media blocks
    HTAR: Extract complete for /NCEPPROD/hpssprod/runhistory/rh2019/201909/20190927/gpfs_dell1_nco_ops_com_gfs_prod_gfs.20190927_00.gfs_nemsioa.tar, 2 files. total bytes read: 16949233664 in 60.130 seconds (281.875 MB/s ) wallclock/user/sys: 60.452 0.129 26.704 seconds 
    HTAR: HTAR SUCCESSFUL
    0
    Job finished.
    + tail -1 /home/Daniel.Abdi/.output.log
    + exit 0

gfsfv3ic.log

     - CALCULATE LIQUID PORTION OF TOTAL SOIL MOISTURE.
     - CALCULATE LIQUID PORTION OF TOTAL SOIL MOISTURE AF.
     - COMPLETED INTERP
     - READ INPUT NSST DATA IN NEMSIO FORMAT
     - READ FILE HEADER
     - READ DATA RECORDS
     - CHANGE NSST FILE RESOLUTION FROM         3072  X         1536
                                     TO           48  X           48
     - INTERPOLATE NSST DATA FIELDS USING BILINEAR METHOD.
     - WRITE FV3 SURFACE AND NSST DATA TO NETCDF FILE
    
    
         ENDING DATE-TIME    NOV 23,2020  13:07:35.979  328  MON   2459177
         PROGRAM GLOBAL_CHGRES HAS ENDED.
    * . * . * . * . * . * . * . * . * . * . * . * . * . * . * . * . * . * . * . * .
    *****************RESOURCE STATISTICS*******************************
    The total amount of wall time                        = 3.793132
    The total amount of time in user mode                = 8.179971
    The total amount of time in sys mode                 = 0.923933
    The maximum resident set size (KB)                   = 1597836
    Number of page faults without I/O activity           = 14731
    Number of page faults with I/O activity              = 0
    Number of times filesystem performed INPUT           = 4632
    Number of times filesystem performed OUTPUT          = 1416
    Number of Voluntary Context Switches                 = 612
    Number of InVoluntary Context Switches               = 62
    *****************END OF RESOURCE STATISTICS*************************
    
    
    real    0m4.345s
    user    0m8.523s
    sys 0m1.028s
    0
    Job finished.
    + tail -1 /home/Daniel.Abdi/.output.log
    + exit 0

gfsfcst.log

        for cosz calculations: nswr,deltim,deltsw,dtswh =           8   450.00000000000000        3600.0000000000000        1.0000000000000000        anginc,nstp =   3.2724923474893676E-002           8
     PASS: fcstRUN phase 1, na =           16  time is    23.085373163223267     
     in fcst run phase 2, na=          16
     PASS: fcstRUN phase 2, na =           16  time is    9.1283919811248779     
     PASS: fcstRUN phase 1, na =           17  time is    17.059847116470337     
     in fcst run phase 2, na=          17
     PASS: fcstRUN phase 2, na =           17  time is   0.40154480934143066     
     PASS: fcstRUN phase 1, na =           18  time is    16.689498424530029     
     in fcst run phase 2, na=          18
     PASS: fcstRUN phase 2, na =           18  time is   0.23376321792602539     
     PASS: fcstRUN phase 1, na =           19  time is    16.897874832153320     
     in fcst run phase 2, na=          19
     PASS: fcstRUN phase 2, na =           19  time is   0.15502095222473145     
     PASS: fcstRUN phase 1, na =           20  time is    16.954673290252686     
     in fcst run phase 2, na=          20
     PASS: fcstRUN phase 2, na =           20  time is   0.14250063896179199     
     PASS: fcstRUN phase 1, na =           21  time is    17.018886566162109     
     in fcst run phase 2, na=          21
     PASS: fcstRUN phase 2, na =           21  time is   0.30644726753234863     
     PASS: fcstRUN phase 1, na =           22  time is    16.814398765563965     
     in fcst run phase 2, na=          22
     PASS: fcstRUN phase 2, na =           22  time is   0.24240088462829590     
     PASS: fcstRUN phase 1, na =           23  time is    16.737110853195190     
     in fcst run phase 2, na=          23
     ---isec,seconds       10800       10800
      gfs diags time since last bucket empty:    3.0000000000000000      hrs  
     PASS: fcstRUN phase 2, na =           23  time is   0.17914342880249023     
     aft fldbdlregrid,na=          24  time=   3.5223660469055176                0
     fv3_cap,aft mdladv,na=          24  time=   20.457410573959351     
     fv3_cap,end integrate,na=          24  time=   471.39387845993042     
     aft fldbdlregrid,na=          24  time=   422.78654265403748                6
     in write grid comp, nf_hours=           3
     in wrt run, nf_hours=           3           0           0 nseconds_num=           0           1  FBCount=           3  cfhour=003
     ichunk2d,jchunk2d         192          96
     ichunk3d,jchunk3d,kchunk3d         192          96          64
     netcdf      Write Time is    4.29897 at Fcst   03:00
     ichunk2d,jchunk2d         192          96
     ichunk3d,jchunk3d,kchunk3d         192          96          64

gfspost.log

     654:11032712:d=2019092700:CAPE:90-0 mb above ground:anl:
     655:11044861:d=2019092700:CIN:90-0 mb above ground:anl:
     656:11058611:d=2019092700:CAPE:255-0 mb above ground:anl:
     657:11071538:d=2019092700:CIN:255-0 mb above ground:anl:
     658:11080255:d=2019092700:PLPL:255-0 mb above ground:anl:
     659:11105786:d=2019092700:LAND:surface:anl:
     660:11107689:d=2019092700:ICEC:surface:anl:
     661:11109907:d=2019092700:ICETMP:surface:anl:
     662:11115881:d=2019092700:UGRD:PV=2e-06 (Km^2/kg/s) surface:anl:
     663:11130452:d=2019092700:VGRD:PV=2e-06 (Km^2/kg/s) surface:anl:
     664:11145044:d=2019092700:TMP:PV=2e-06 (Km^2/kg/s) surface:anl:
     665:11159385:d=2019092700:HGT:PV=2e-06 (Km^2/kg/s) surface:anl:
     666:11176516:d=2019092700:PRES:PV=2e-06 (Km^2/kg/s) surface:anl:
     667:11194534:d=2019092700:VWSH:PV=2e-06 (Km^2/kg/s) surface:anl:
     668:11206287:d=2019092700:UGRD:PV=-2e-06 (Km^2/kg/s) surface:anl:
     669:11216479:d=2019092700:VGRD:PV=-2e-06 (Km^2/kg/s) surface:anl:
     670:11230804:d=2019092700:TMP:PV=-2e-06 (Km^2/kg/s) surface:anl:
     671:11244804:d=2019092700:HGT:PV=-2e-06 (Km^2/kg/s) surface:anl:
     672:11261641:d=2019092700:PRES:PV=-2e-06 (Km^2/kg/s) surface:anl:
     673:11279528:d=2019092700:VWSH:PV=-2e-06 (Km^2/kg/s) surface:anl:
     119.926 + err=0 
     119.926 + export err
     119.926 + err_chk
     postcheck completed cleanly


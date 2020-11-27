# How to run global-workflow on AWS using singularity

Here we describe how to run the global-workflow on AWS using ParallelCluster -- an HPC cluster management tool.
ParallelCluster needs to be installed on your local machine following [these instructions](https://docs.aws.amazon.com/parallelcluster/latest/ug/install).
It is also recommended to install and configure the [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html) as well
to facilitate copying data to/from s3 for your instances.

## Setup

Once you install the above two tools, you can then modify the configuration files they produce according to your needs

Contents my `~/.aws/configure` file show I am using us east coast region 1.

    [default]
    output = json
    region = us-east-1

Contens of `~/.parallelcluster/configure`

    [aws]
    aws_region_name = us-east-1
    
    [global]
    update_check = true
    sanity_check = true
    cluster_template = default
    
    [aliases]
    ssh = ssh {CFN_USER}@{MASTER_IP} {ARGS}
    
    [cluster default]
    key_name = daniel-key
    base_os = ubuntu1604
    scheduler = slurm
    max_queue_size = 30
    maintain_initial_size = true
    vpc_settings = default
    master_instance_type = c5n.18xlarge
    compute_instance_type = c5n.18xlarge
    master_root_volume_size = 100
    compute_root_volume_size = 100
    placement = cluster
    placement_group = DYNAMIC
    fsx_settings = ncepprod
    disable_hyperthreading = true
    tags = {"noaa:lineoffice":"oar","noaa:programoffice":"50-37-0000","noaa:fismaid":"NOAA3500","noaa:environment":"dev","noaa:taskorder":"0044-0001AC","noaa:oar:gsl:projectid":"2020-09-ATD-HPCB"}
    
    [vpc default]
    vpc_id = vpc-09fdd078bfb55f7ba
    master_subnet_id = subnet-010d4fe54e66b6ed2
    use_public_ips = false
    
    [fsx ncepprod]
    shared_dir = /NCEPPROD
    storage_capacity = 1200
    imported_file_chunk_size = 1024
    export_path = s3://fv3-bucket/.
    import_path = s3://fv3-bucket

So I am launching the parallel cluster in the same region as aws-config with the following details: Centos OS with slurm as the job scheduler,
c5n.18xlarge instances for both login and compute nodes. You may want to use a cheaper instance for the login node. For this run, I am using 80 GB storage for
both master and compute nodes. Also loading data from S3 to a lustre file system. This has the "fix" files of ~160 GB in size, and an HPSS tar file
we will use for this example.

Ok now let us create our cluster with the following command. It will take some time initialize your cluster so have patience.

    $ pcluster create mycluster
    Beginning cluster creation for cluster: mycluster
    Creating stack named: parallelcluster-mycluster
    Status: parallelcluster-mycluster - CREATE_COMPLETE                             
    ClusterUser: ubuntu
    MasterPrivateIP: 137.75.88.119

Then we can login to the master node via ssh using the IP of the master node

    $ ssh -i "daniel-key.pem" ubuntu@137.75.88.119
    The authenticity of host '137.75.88.119 (137.75.88.119)' can't be established.
    ECDSA key fingerprint is SHA256:M/ci9yqmswheXpMQaW6mapSiNalb+MECxkhJjkBncbk.
    Are you sure you want to continue connecting (yes/no)? yes
    Warning: Permanently added '137.75.88.119' (ECDSA) to the list of known hosts.
    Welcome to Ubuntu 16.04.6 LTS (GNU/Linux 4.4.0-1102-aws x86_64)
    
     * Documentation:  https://help.ubuntu.com
     * Management:     https://landscape.canonical.com
     * Support:        https://ubuntu.com/advantage
    
     * Introducing self-healing high availability clustering for MicroK8s!
       Super simple, hardened and opinionated Kubernetes for production.
    
         https://microk8s.io/high-availability
    
    167 packages can be updated.
    129 updates are security updates.
    
    
    Last login: Tue Feb 25 20:55:00 2020 from 3.80.175.15
    ubuntu@ip-137-75-88-119:~$ 

You can also use `pcluster ssh mycluster` to login to the master node. 
Lets quickly checkout what we have. 

Our lustre file system mapped to `/NCEPPROD` have these files

    $ ls /NCEPPROD/
    C384.tar.gz  C768.tar.gz  C96.tar.gz  fix  hpssprod  install-centos.sh  install-ubuntu.sh

These modules are available

    $ module avail
    -------------------------------------------------------------------------------------- /usr/share/modules/versions ---------------------------------------------------------------------------------------
    3.2.10
    
    ------------------------------------------------------------------------------------- /usr/share/modules/modulefiles -------------------------------------------------------------------------------------
    dot                        libfabric-aws/1.9.0amzn1.1 module-info                null                       use.own
    intelmpi/2019.6.166        module-git                 modules                    openmpi/4.0.2

Lmod is already installed and we can see we have intelmpi pre-installed. Also openmpi/4.0.2 is availble.
For our containers we use either intel MPI for the intel builds, and MPICH for the GNU builds. So if we use GNU built
containers we have to install MPICH ourselves.

Slurm is already on the system too

    $ sinfo
	PARTITION AVAIL  TIMELIMIT  NODES  STATE NODELIST
	compute*     up   infinite      0    n/a 

Then we install rocoto and singularity using install-centos.sh script under `/NCEPPROD`.
Note that singularity is installed in our home directory so that all compute nodes can access it.

    $ cp /NCEPPROD/install-ubuntu.sh .
    $ ./install-ubuntu.sh

Then we source `~/.bashrc` to get singularity and rocoto

    $ source ~/.bashrc
    $ singularity --version
    singularity version 3.7.0+2-gdf720ce
    $ rocotostat --version
    Rocoto Version 1.3.3-SNAPSHOT

Next we pull gfs-intel image and extract it directly to a sandbox.

	$ singularity build --fix-perms --sandbox workflow docker://dshawul/gfs-intel
    INFO:    Starting build...
    Getting image source signatures
    Copying blob 8a29a15cefae done  
    Copying blob c47cc7dae6c5 done  
    Copying blob 98565af2df26 done  
    Copying blob dd568378b851 done  
    Copying blob 1226a1f50203 done  
    Copying blob e2c2126e917e done  
    Copying blob 8d8fa78f492b done  
    Copying blob 3680b35dc554 done  
    Copying blob 6e889b5ba04b done  
    Copying blob 9a3055655ec2 done  
    Copying blob a1d2baafe809 done  
    Copying blob d60d395b8ba4 done  
    Copying blob f8f4050a55b7 done  
    Copying blob f2210489435e done  
    Copying blob 34507e14a159 done  
    Copying blob 30aa79ffc0b0 done  
    Copying blob e5311b806dd2 done  
    Copying blob ea71b7e00304 done  
    Copying blob 420a7509c8f4 done  
    Copying blob 480fe9243c48 done  
    Copying blob 88547b4ce90b done  
    Copying blob 42ed73aa658d done  
    Copying blob 3a7c22e1235d done  
    Copying blob 6eb26ae2b473 done  
    Copying blob fbe80c61b42e done  
    Copying blob 9626f6fa47fb done  
    Copying blob c350b0591032 done  
    Copying blob ecdb24ceed23 done  
    Copying blob d2d8819448cc done  
    Copying blob 6188ef01328c done  
    Copying blob 2a5577cd3abb done  
    Copying config 1d42834623 done  
    Writing manifest to image destination
    Storing signatures
    2020/11/26 00:11:34  info unpack layer: sha256:8a29a15cefaeccf6545f7ecf11298f9672d2f0cdaf9e357a95133ac3ad3e1f07
    2020/11/26 00:11:34  warn rootless{usr/bin/newgidmap} ignoring (usually) harmless EPERM on setxattr "security.capability"
    2020/11/26 00:11:34  warn rootless{usr/bin/newuidmap} ignoring (usually) harmless EPERM on setxattr "security.capability"
    2020/11/26 00:11:34  warn rootless{usr/bin/ping} ignoring (usually) harmless EPERM on setxattr "security.capability"
    2020/11/26 00:11:36  warn rootless{usr/sbin/arping} ignoring (usually) harmless EPERM on setxattr "security.capability"
    2020/11/26 00:11:36  warn rootless{usr/sbin/clockdiff} ignoring (usually) harmless EPERM on setxattr "security.capability"
    2020/11/26 00:11:36  info unpack layer: sha256:c47cc7dae6c5a2ca0943b28539c9f4a5efbbd6d8fc1db897c9fd50ed89e91aa5
    2020/11/26 00:11:41  warn rootless{usr/libexec/openssh/ssh-keysign} ignoring (usually) harmless EPERM on setxattr "user.rootlesscontainers"
    2020/11/26 00:11:45  info unpack layer: sha256:98565af2df261b0ed1331e44d92354481abcd08637fe1119007b78edcf7e5c4b
    2020/11/26 00:11:45  info unpack layer: sha256:dd568378b851a9c40a5d249aeeb89a6b09ca9ec90caf2b60f067ab0ffce94472
    2020/11/26 00:11:45  info unpack layer: sha256:1226a1f502035dd49e0200cc4ea90cf4cdd5c455d8ad57c7f949ca39c80c2c44
    2020/11/26 00:11:45  info unpack layer: sha256:e2c2126e917e4e6b4112a0ab8c6b50bec712bfb67b02a4b5e01702072d600cdd
    2020/11/26 00:11:45  info unpack layer: sha256:8d8fa78f492b5e783d6f9270ab908ad720fa4dab3b611583646e35a159bcc96b
    2020/11/26 00:11:45  info unpack layer: sha256:3680b35dc55422ede6f35d9cf625673707152f8a2c1c887252385ad06a7411fb
    2020/11/26 00:11:45  info unpack layer: sha256:6e889b5ba04b4ded06fa9eab97f21cbc08dcfbb35400ee28d1ed02ab08280afa
    2020/11/26 00:11:46  info unpack layer: sha256:9a3055655ec218072786d336f778a94a55fdc47e9e6dbc65501db9b0fc3f5c4f
    2020/11/26 00:11:51  info unpack layer: sha256:a1d2baafe809c89e253a01c869e3d795d84dda5aa2f1f33418ead557616b05df
    2020/11/26 00:11:51  info unpack layer: sha256:d60d395b8ba44226ad3c21456d343711d0e8b4e2cc149ae46af6df5f7ecc67a9
    2020/11/26 00:11:51  info unpack layer: sha256:f8f4050a55b72882aebd6e80b8633d401da8e820e83f58a180eca7adefcb4a66
    2020/11/26 00:12:51  info unpack layer: sha256:f2210489435e1d29707898483736872525aed87a2b5a43d303fffcd790ac598a
    2020/11/26 00:12:51  info unpack layer: sha256:34507e14a159138f0877beec4021962a6f1b5a7b7d938dc77f78128464f01359
    2020/11/26 00:12:51  info unpack layer: sha256:30aa79ffc0b0771e51ba6d7d117897a82fc652aedd4bf3fbd398b6918cc4fbe4
    2020/11/26 00:12:51  info unpack layer: sha256:e5311b806dd2b10af1d569d51a26f8a46a81b1a691eb8a1a8018be6db02f82b7
    2020/11/26 00:12:59  info unpack layer: sha256:ea71b7e00304b3a7803c8f842a3a9f1ba0e49b3112f007b7958a8de02098c783
    2020/11/26 00:13:02  info unpack layer: sha256:420a7509c8f4b656e89cb03e0aa087807f9d52b09de367f032cd3f213d2340a8
    2020/11/26 00:13:02  info unpack layer: sha256:480fe9243c48913d104d8a68d6ec33fe4773bf571302adf247ef12e2629ed5f5
    2020/11/26 00:13:04  info unpack layer: sha256:88547b4ce90b31ab0afec2c3d56a67c62422d30f8d88037529440d0671f469fb
    2020/11/26 00:13:04  info unpack layer: sha256:42ed73aa658d52a55830a74534dd1d60123865997df49ee858c71222829c33ee
    2020/11/26 00:13:04  info unpack layer: sha256:3a7c22e1235d505fbe7a1999e0399d499c3e76ef0f68782e4c1e0c3dbbe050d1
    2020/11/26 00:14:00  info unpack layer: sha256:6eb26ae2b47380cd7bef539005ca58a528d0c876c8bd7b0df5d61986551d7995
    2020/11/26 00:14:00  info unpack layer: sha256:fbe80c61b42e64760941cd1fb4292c6f6c37876ecf57af2d4f834d06dca3cd60
    2020/11/26 00:14:00  info unpack layer: sha256:9626f6fa47fbcedd783e3baa17948c9c3ca4e6417529b6ede46aa0424d60240a
    2020/11/26 00:14:00  info unpack layer: sha256:c350b059103247a09a2cf4eda73b35aee9948e9a18a2cfaf8df83c113659bdbb
    2020/11/26 00:14:00  info unpack layer: sha256:ecdb24ceed2382e6b6c4cd9b71682ef9fb47e1f74376191adbda60c419df84b6
    2020/11/26 00:14:00  info unpack layer: sha256:d2d8819448cc3b5c4beb142fba832d061f5e02b6636cfefec478fb7dee1bf720
    2020/11/26 00:14:00  info unpack layer: sha256:6188ef01328c3ca1b18fe535362ca3f7594c6d8c351418516c55650d2a418089
    2020/11/26 00:14:00  info unpack layer: sha256:2a5577cd3abb7a3096901a872f36084e44c19ff5d3913da074f8a364bbfcd311
    WARNING: The --fix-perms option modifies the filesystem permissions on the resulting container.
    INFO:    Creating sandbox directory...
    INFO:    Build complete: workflow

Clean singulairty cache to save space

    $ singularity cache clean

You will find the sandbox named `workflow` in the current directory

    $ ls
    go  install-ubuntu.sh  opt  rocoto  tmp  workflow

We will load the intelmpi module we need

    $ module load intelmpi
    $ module list
    Currently Loaded Modulefiles:
      1) intelmpi/2019.6.166


## Quick forecast run using C96 on one node

If you are only interested in running global-workflow, skip to the next section.
The C96 test case is available on our Lustre file system

    $ tar -xvf /NCEPPROD/C96.tar.gz 
    $ ls
    C96  go  install-ubuntu.sh  opt  rocoto  tmp  workflow 

Lets switch to the C96 directory, and see what we have

    $ cd C96
    $ ls
    aerosol.dat                             co2historicaldata_2015.txt  global_mxsnoalb.uariz.t126.384.190.rg.grb        global_tg3clim.2.6x1.5.grb               nems.configure
    C96                                     co2historicaldata_2016.txt  global_o3prdlos.f77                              global_vegfrac.0.144.decpercent.grb      RESTART
    CFSR.SEAICE.1982.2012.monthly.clim.grb  data_table                  global_shdmax.0.144x0.144.grb                    global_vegtype.igbp.t126.384.190.rg.grb  RTGSST.1982.2012.monthly.clim.grb
    cleanup_for_next_test.sh                diag_table                  global_shdmin.0.144x0.144.grb                    global_zorclim.1x1.grb                   run_linux.sh
    co2historicaldata_2010.txt              field_table                 global_slope.1x1.grb                             INPUT                                    seaice_newland.grb
    co2historicaldata_2011.txt              fv3.exe                     global_snoclim.1.875.grb                         input_ccpp.nml                           sfc_emissivity_idx.txt
    co2historicaldata_2012.txt              global_albedo4.1x1.grb      global_snowfree_albedo.bosu.t126.384.190.rg.grb  input_ipd.nml                            solarconstant_noaa_an.txt
    co2historicaldata_2013.txt              global_glacier.2x2.grb      global_soilmgldas.t126.384.190.grb               input.nml
    co2historicaldata_2014.txt              global_maxice.2x2.grb       global_soiltype.statsgo.t126.384.190.rg.grb      model_configure

The quickest way to run this test case is to run it inside the container, since the case needs only one node

    $ singularity shell ../workflow/
    Singularity> source /opt/setup.linux.intel 

    Singularity> export OMP_NUM_THREADS=1
    Singularity> export I_MPI_SHM_LMT=shm
    Singularity> mpirun --prepend-rank -n 6 /opt/global-workflow/exec/global_fv3gfs.x 

    [0] 
    [0] 
    [0] * . * . * . * . * . * . * . * . * . * . * . * . * . * . * . * . * . * . * . * . 
    [0]      PROGRAM NEMS (root) Wed Nov 25 16:44:17 UTC 2020 r845c887776c6 https://github.com/NOAA-EMC/NEMS HAS BEGUN. COMPILED 2020330.00     ORG: NEMS
    [0]      STARTING DATE-TIME  NOV 26,2020  01:35:23.848  331  THU   2459180
    
    
    [0]      ENDING DATE-TIME    NOV 26,2020  01:39:10.766  331  THU   2459180
    [0]      PROGRAM nems      HAS ENDED.
    [0] * . * . * . * . * . * . * . * . * . * . * . * . * . * . * . * . * . * . * . * . 
    [0] *****************RESOURCE STATISTICS*******************************
    [0] The total amount of wall time                        = 83.342699
    [0] The total amount of time in user mode                = 76.076000
    [0] The total amount of time in sys mode                 = 1.276000
    [0] The maximum resident set size (KB)                   = 923696
    [0] Number of page faults without I/O activity           = 909855
    [0] Number of page faults with I/O activity              = 0
    [0] Number of times filesystem performed INPUT           = 0
    [0] Number of times filesystem performed OUTPUT          = 383232
    [0] Number of Voluntary Context Switches                 = 543
    [0] Number of InVoluntary Context Switches               = 71
    [0] *****************END OF RESOURCE STATISTICS*************************

We can run the same problem from outside the container using the intempi on the host as follows

    $ export OMP_NUM_THREADS=1
    $ export I_MPI_SHM_LMT=shm
    $ mpirun --prepend-rank -n 6 singularity exec ../workflow run_bash_command /opt/global-workflow/exec/global_fv3gfs.x

    [0]      ENDING DATE-TIME    NOV 26,2020  01:49:51.141  331  THU   2459180
    [0]      PROGRAM nems      HAS ENDED.
    [0] * . * . * . * . * . * . * . * . * . * . * . * . * . * . * . * . * . * . * . * . 
    [0] *****************RESOURCE STATISTICS*******************************
    [0] The total amount of wall time                        = 83.079855
    [0] The total amount of time in user mode                = 76.432000
    [0] The total amount of time in sys mode                 = 1.172000
    [0] The maximum resident set size (KB)                   = 923668
    [0] Number of page faults without I/O activity           = 861472
    [0] Number of page faults with I/O activity              = 0
    [0] Number of times filesystem performed INPUT           = 0
    [0] Number of times filesystem performed OUTPUT          = 383232
    [0] Number of Voluntary Context Switches                 = 341
    [0] Number of InVoluntary Context Switches               = 77
    [0] *****************END OF RESOURCE STATISTICS*************************

So there is no performance difference by running multiple copies of the container.

## Running the workflow

We can use the sandbox we created to create test cases to run such as C48.
Most of the steps for running the workflow are the same as the one without a container.

First we create the directory where our runs are stored
Also symlink `/bin/bash` to `/bin/sh` as global-workflow needdds this.
On the AWS ubuntu nodes `/bin/sh` is symlinked to `/bin/dash` instead.

    $ mkdir RUNS
    $ sudo ln -sf /bin/bash /bin/sh

Then we need to set some environment variables 
    
    $ touch set_environement.sh aws_fix.sh
    $ chmod +x set_environement.sh aws_fix.sh

Then copy and paste this into `set_environement.sh`

    #!/bin/tcsh

    COLON=':'
    export GFS_NCEPPROD="/NCEPPROD"
    export GFS_FIX_DIR="${GFS_NCEPPROD}/fix"
    export GFS_IMG_DIR="${HOME}/workflow"
    export GFS_NPE_NODE_MAX=18
    export GFS_SING_CMD="singularity exec --bind $GFS_FIX_DIR$COLON/fix $GFS_IMG_DIR run_bash_command"
    export GFS_DAEMON_RUN="$GFS_IMG_DIR/opt/global-workflow/cloud/scripts/run_sing_job.sh"
    export GFS_DAEMON_KILL="$GFS_IMG_DIR/opt/global-workflow/cloud/scripts/kill_sing_job.sh"
    export GFS_ADD_SCRIPT=". $HOME/aws_fix.sh"

and the below into `aws_fix.sh`

    #!/bin/bash

    #symlink bash to sh on compute nodes
    sudo ln -sf /bin/bash /bin/sh
    
    #set I_MPI_SHM_LMT
    export I_MPI_SHM_LMT=shm
    
    #unset SLURM variables (need to investigate why this is needed)
    for i in $( compgen -v | grep SLURM ) ; do
        unset $i
    done

The `aws_fix.sh` is a script we use to handle the quirks of AWS such as: the need to set `I_MPI_SHM_LMT`
when running on one node, and also for the need to unset variables SLURM defines for reasons I don't understand
fully. In any case you can use this script, to handle changes you want to make to compute nodes.

Then we source the script

    $ source set_environement.sh
    $ printenv | grep GFS
    GFS_NPE_NODE_MAX=18
    GFS_NCEPPROD=/NCEPPROD
    GFS_FIX_DIR=/NCEPPROD/fix
    GFS_IMG_DIR=/home/ubuntu/workflow
    GFS_DAEMON_RUN=/home/ubuntu/workflow/opt/global-workflow/cloud/scripts/run_sing_job.sh
    GFS_ADD_SCRIPT=sudo ln -sf /bin/bash /bin/sh; [ $SLURM_NNODES -eq 1 ] && export I_MPI_SHM_LMT=shm; unset $( compgen -v | grep SLURM )
    GFS_DAEMON_KILL=/home/ubuntu/workflow/opt/global-workflow/cloud/scripts/kill_sing_job.sh
    GFS_SING_CMD=singularity exec --bind /NCEPPROD/fix:/fix /home/ubuntu/workflow run_bash_command

The `global-workflow` is located under the `/opt` directory.

    $ cd ~/workflow/opt/global-workflow

For running `getic` step of workflow we will use emulator for hpcc.

    $ ./cloud/scripts/link_hpss.sh ~/opt/bin

This will make available `hsi` and `htar` commands of HPSS.
We have a tar file under `/NCEPPROD/hpssprod` that we will use to demonstrate `getic` step.
At this point we have `rocoto`, `slurm` and `hpss` on the host which is all we need
to run workflow.

To prepare a test case, We switch to the `ush/rocoto` directory

    $ cd ush/rocoto
    $ touch c48.sh
    $ chmod +x c48.sh

Copy and paste this text into the script

    BASE=$HOME/RUNS                                 ## Make sure you have access to the base directory
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

Run the script to generate test case
   
    $ ./c48.sh

    SDATE = 2019-09-27 00:00:00
    EDATE = 2019-09-27 00:00:00
    
    EDITED:  /home/ubuntu/RUNS/global/save/ubuntu/fv3gfs/expdir/c48/config.base as per user input.
    DEFAULT: /home/ubuntu/RUNS/global/save/ubuntu/fv3gfs/expdir/c48/config.base.default is for reference only.
    Please verify and delete the default file before proceeding.
    
    sourcing config.getic
    sourcing config.fv3ic
    sourcing config.waveinit
    sourcing config.waveprep
    sourcing config.fcst
    sourcing config.post
    sourcing config.wavepostsbs
    sourcing config.wavegempak
    sourcing config.waveawipsbulls
    sourcing config.waveawipsgridded
    sourcing config.wafs
    sourcing config.wafsgrib2
    sourcing config.wafsblending
    sourcing config.wafsgcip
    sourcing config.wafsgrib20p25
    sourcing config.wafsblending0p25
    sourcing config.vrfy
    /home/ubuntu/RUNS/global/save/ubuntu/fv3gfs/expdir/c48/config.vrfy: line 163: compath.py: command not found
    sourcing config.metp
    sourcing config.arch

Now our directories are setup under $HOME/RUNS. Lets goto the EXPDIR and edit some config files
At this point you may want to create aliases for the EXPDIR and COMROT which we will be using a lot

    $ alias cdexp="cd $HOME/RUNS/global/save/$USER/fv3gfs/expdir"
    $ alias cdcom="cd $HOME/RUNS/global/noscrub/$USER/fv3gfs/comrot"
    $ cdexp
    $ ls
    c48
    $ cd c48
    $ ls
    c48.crontab      config.arch          config.base.nco.static  config.efcs  config.fcst    config.gldas    config.prep       config.wafsblending      config.wave              config.wavepostsbs
    c48.xml          config.awips         config.earc             config.eobs  config.fv3     config.metp     config.prepbufr   config.wafsblending0p25  config.waveawipsbulls    config.waveprep
    config.anal      config.base          config.ecen             config.epos  config.fv3ic   config.nsst     config.resources  config.wafsgcip          config.waveawipsgridded
    config.analcalc  config.base.default  config.echgres          config.esfc  config.gempak  config.post     config.vrfy       config.wafsgrib2         config.wavegempak
    config.analdiag  config.base.emc.dyn  config.ediag            config.eupd  config.getic   config.postsnd  config.wafs       config.wafsgrib20p25     config.waveinit

Then we edit some of the config files for our C48 run

### config.base

Set LEVS to 65 instead of 128. The new default of LEVS=128 does not work properly for some reason

    export LEVS=65

You can set the hours of forecast and write interval, e.g. for 3 hrs fcst 

    export FHMAX_GFS_00=3
    export FHMAX_GFS_06=3
    export FHMAX_GFS_12=3
    export FHMAX_GFS_18=3

Comment out or set to .false. the inline postprocessing option.
This is needed because the Linux binaries for FV3 ( and on Orion too I believe) are built
without inline post-processing. The same post-processing code is available in global-workflow so nothing missed.
   
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

### config.post

We don't have the HWRF coefficient files needed by post (CRTM one's don't work) so
we need to turn off

    GOESF=NO

### the rocoto xml file, c48.xml

If necessary, edit lines like below to modify the number of nodes, processors per node, threads per process

    <!ENTITY RESOURCES_FCST_GFS "<nodes>1:ppn=18</nodes>">

Also we need to set the partition to compute

    <!ENTITY QUEUE_ARCH "compute">
    <!ENTITY PARTITION_ARCH "compute">

### Fixing rocoto issue on AWS

AWS doesn't like the memory limit rocoto puts on jobs.
Compute nodes have by default UNLIMITED memory on AWS.

    $ scontrol show config | grep MemPerNode
    DefMemPerNode           = UNLIMITED
    MaxMemPerNode           = UNLIMITED

So we are going to temporarily disable mem limits rocoto sets

    $ vi ~/rocoto/lib/workflowmgr/slurmbatchsystem.rb

Comment out lines 257-275
   
         # when :memory
         #   m=/^([\.\d]+)([\D]*)$/.match(value)
         #   amount=m[1].to_f
         #   units=m[2]
         #   case units
         #     when /^B|b/
         #       amount=(amount / 1024.0 / 1024.0).ceil
         #     when /^K|k/
         #     amount=(amount / 1024.0).ceil
         #     when /^M|m/
         #       amount=amount.ceil
         #     when /^G|g/
         #       amount=(amount * 1024.0).ceil
         #     when nil
         #     amount=(amount / 1024.0 / 1024.0).ceil
         #   end
         #   if amount > 0
         #     input += "#SBATCH --mem=#{amount}\n"
         #   end

### Executing workflow steps

#### First step `fv3getic`

Now we are ready to execute some workflow steps
Lets boot up the first step `getic`

    $ rocotoboot -v 10 -w c48.xml -d c48.dl -c all -t gfsgetic
    Booting task 'gfsgetic' for cycle '201909270000' will activate cycle '201909270000' for the first time.
    This may trigger submission of other tasks for cycle '201909270000' in addition to 'gfsgetic'
    Are you sure you want to boot 'gfsgetic' for cycle '201909270000' ? (y/n) y
    11/26/20 03:34:31 UTC :: c48.xml :: Submitting gfsgetic using sbatch < /tmp/sbatch.in20201126-17632-17vigxy with input
    {{
    #! /bin/sh
    #SBATCH --job-name=c48_gfsgetic_00
    #SBATCH --account=gsd-hpcs
    #SBATCH --qos=batch
    #SBATCH --partition=compute
    #SBATCH --nodes=1-1
    #SBATCH --tasks-per-node=1
    #SBATCH -t 06:00:00
    #SBATCH -o /home/ubuntu/RUNS/global/noscrub/ubuntu/fv3gfs/comrot/c48/logs/2019092700/gfsgetic.log
    #SBATCH --export=ALL
    #SBATCH --comment=7d6167bf0384fbdbaabe3f234e4db2fc
    export RUN_ENVIR='emc'
    export HOMEgfs='/opt/global-workflow'
    export EXPDIR='/home/ubuntu/RUNS/global/save/ubuntu/fv3gfs/expdir/c48'
    export CDATE='2019092700'
    export CDUMP='gfs'
    export PDY='20190927'
    export cyc='00'
    $GFS_DAEMON_RUN; $GFS_SING_CMD /opt/global-workflow/jobs/rocoto/getic.sh; EXCODE=$?; $GFS_DAEMON_KILL; exit $EXCODE;
    }}
    task 'gfsgetic' for cycle '201909270000' has been booted

Our job is successfully submitted to slurm. If we do an `squeue` immediately afterwards
we will see that our compute node is DOWN or DRAINED. It takes AWS time to launch a compute node

    $ squeue
           JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
               2   compute c48_gfsg   ubuntu PD       0:00      1 (Nodes required for job are DOWN, DRAINED or reserved for jobs in higher priority partitions)

After a while the job will execute

    $ squeue
           JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
               2   compute c48_gfsg   ubuntu  R       0:02      1 ip-137-75-88-121

Once the job finishes, you should see something like below in the log file

    $ cdcom
    $ ls
    c48  FV3ICS

So it has created the FV3ICS direcotry and extracted files from the HPSS tar ball

    $ ls FV3ICS/2019092700/gfs/gfs.20190927/00/
    gfs.t00z.atmanl.nemsio  gfs.t00z.sfcanl.nemsio

Looking into the log file, you should see something like below towards the end.

    $ vi c48/logs/2019092700/gfsgetic.log

    + tarball=/NCEPPROD/hpssprod/runhistory/rh2019/201909/20190927/gpfs_dell1_nco_ops_com_gfs_prod_gfs.20190927_00.gfs_nemsioa.tar
    + [ LINUX '=' WCOSS_C ]
    + [ 1 -ne 0 ]
    + command . /opt/global-workflow/cloud/scripts/run_on_host.sh
    + run_command hsi ls -l /NCEPPROD/hpssprod/runhistory/rh2019/201909/20190927/gpfs_dell1_nco_ops_com_gfs_prod_gfs.20190927_00.gfs_nemsioa.tar
    Waiting for job to finish.
    -rwxr-xr-x 1 root root 12342151880 Nov 25 19:38 /NCEPPROD/hpssprod/runhistory/rh2019/201909/20190927/gpfs_dell1_nco_ops_com_gfs_prod_gfs.20190927_00.gfs_nemsioa.tar
    0
    Job finished.
    + tail -1 /home/ubuntu/.output.log
    + exit 0
    + rc=0
    + [ 0 -ne 0 ]
    + run_command htar -xvf /NCEPPROD/hpssprod/runhistory/rh2019/201909/20190927/gpfs_dell1_nco_ops_com_gfs_prod_gfs.20190927_00.gfs_nemsioa.tar ./gfs.20190927/00/gfs.t00z.atmanl.nemsio ./gfs.20190927/00/gfs.t00z.sfcanl.nemsio
    Waiting for job to finish.
    exec tar  -xvf /NCEPPROD/hpssprod/runhistory/rh2019/201909/20190927/gpfs_dell1_nco_ops_com_gfs_prod_gfs.20190927_00.gfs_nemsioa.tar ./gfs.20190927/00/gfs.t00z.atmanl.nemsio ./gfs.20190927/00/gfs.t00z.sfcanl.nemsio
    ./gfs.20190927/00/gfs.t00z.atmanl.nemsio
    ./gfs.20190927/00/gfs.t00z.sfcanl.nemsio
    0
    Job finished.
    + tail -1 /home/ubuntu/.output.log
    + exit 0
    l+ rc=0
    + [ 0 -ne 0 ]
    + [ 2019092700 -le 2019061118 ]
    + [ 0 -ne 0 ]
    + [ 2019092700 -le 2019061118 ]
    + exit 0

Now we have successfully completed the first step

#### Second step `gfsfv3ic`

This is the step where the global fields are interpolated onto our grid using the program CHGRES.

    $ cdexp
    $ cd c48
    $ rocotoboot -v 10 -w c48.xml -d c48.dl -c all -t gfsfv3ic
    11/26/20 04:03:48 UTC :: c48.xml :: Submitting gfsfv3ic using sbatch < /tmp/sbatch.in20201126-18819-1mcn60r with input
    {{
    #! /bin/sh
    #SBATCH --job-name=c48_gfsfv3ic_00
    #SBATCH --account=gsd-hpcs
    #SBATCH --qos=batch
    #SBATCH --nodes=1-1
    #SBATCH --tasks-per-node=1
    #SBATCH -t 00:30:00
    #SBATCH -o /home/ubuntu/RUNS/global/noscrub/ubuntu/fv3gfs/comrot/c48/logs/2019092700/gfsfv3ic.log
    #SBATCH --export=ALL
    #SBATCH --comment=c27537f59a2fb8899a06b4c21d9a8da3
    export RUN_ENVIR='emc'
    export HOMEgfs='/opt/global-workflow'
    export EXPDIR='/home/ubuntu/RUNS/global/save/ubuntu/fv3gfs/expdir/c48'
    export CDATE='2019092700'
    export CDUMP='gfs'
    export PDY='20190927'
    export cyc='00'
    $GFS_DAEMON_RUN; $GFS_SING_CMD /opt/global-workflow/jobs/rocoto/fv3ic.sh; EXCODE=$?; $GFS_DAEMON_KILL; exit $EXCODE;
    }}
    task 'gfsfv3ic' for cycle '201909270000' has been booted

This will complete after a while and you should see something like below in the log file

    $ cdcom
    $ cd c48

     - SET FACSF WITH EXTERNAL DATA OVER LAND
     - SET FACWF WITH EXTERNAL DATA OVER LAND
     - SET MAX SNOW ALBEDO WITH EXTERNAL DATA.
     - RESCALE SOIL MOISTURE FOR NEW SOIL TYPE.
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
    
    
         ENDING DATE-TIME    NOV 26,2020  04:09:00.167  331  THU   2459180
         PROGRAM GLOBAL_CHGRES HAS ENDED.
    * . * . * . * . * . * . * . * . * . * . * . * . * . * . * . * . * . * . * . * .
    *****************RESOURCE STATISTICS*******************************
    The total amount of wall time                        = 4.747173
    The total amount of time in user mode                = 18.620000
    The total amount of time in sys mode                 = 1.880000
    The maximum resident set size (KB)                   = 1581280
    Number of page faults without I/O activity           = 810370
    Number of page faults with I/O activity              = 0
    Number of times filesystem performed INPUT           = 392
    Number of times filesystem performed OUTPUT          = 1368
    Number of Voluntary Context Switches                 = 316
    Number of InVoluntary Context Switches               = 128
    *****************END OF RESOURCE STATISTICS*************************
    
    18.92user 1.91system 0:05.11elapsed 407%CPU (0avgtext+0avgdata 1581280maxresident)k
    392inputs+1392outputs (0major+824245minor)pagefaults 0swaps
    0
    Job finished.
    + tail -1 /home/ubuntu/.output.log
    + exit 0

Now you should see the interpolated fields under 

    $ ls c48/gfs.20190927/00/atmos/INPUT/
    gfs_ctrl.nc        gfs_data.tile2.nc  gfs_data.tile4.nc  gfs_data.tile6.nc  sfc_data.tile2.nc  sfc_data.tile4.nc  sfc_data.tile6.nc
    gfs_data.tile1.nc  gfs_data.tile3.nc  gfs_data.tile5.nc  sfc_data.tile1.nc  sfc_data.tile3.nc  sfc_data.tile5.nc

#### Third step `gfsfcst`

Now we do the forecast step. This is the first step that is an MPI job.

    $ rocotoboot -v 10 -w c48.xml -d c48.dl -c all -t gfsfcst
    11/26/20 04:32:57 UTC :: c48.xml :: Submitting gfsfcst using sbatch < /tmp/sbatch.in20201126-20390-17k8kr0 with input
    {{
    #! /bin/sh
    #SBATCH --job-name=c48_gfsfcst_00
    #SBATCH --account=gsd-hpcs
    #SBATCH --qos=batch
    #SBATCH --nodes=1-1
    #SBATCH --tasks-per-node=18
    #SBATCH -t 08:00:00
    #SBATCH -o /home/ubuntu/RUNS/global/noscrub/ubuntu/fv3gfs/comrot/c48/logs/2019092700/gfsfcst.log
    #SBATCH --export=ALL
    #SBATCH --comment=f5435ffad5494067eed152d2b884a486
    export RUN_ENVIR='emc'
    export HOMEgfs='/opt/global-workflow'
    export EXPDIR='/home/ubuntu/RUNS/global/save/ubuntu/fv3gfs/expdir/c48'
    export CDATE='2019092700'
    export CDUMP='gfs'
    export PDY='20190927'
    export cyc='00'
    $GFS_DAEMON_RUN; $GFS_SING_CMD /opt/global-workflow/jobs/rocoto/fcst.sh; EXCODE=$?; $GFS_DAEMON_KILL; exit $EXCODE;
    }}
    task 'gfsfcst' for cycle '201909270000' has been booted

Check status

    $ squeue
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
                4   compute c48_gfsf   ubuntu  R       0:03      1 ip-137-75-88-116

The log file shoud show something like

     ichunk2d,jchunk2d         192          96
     ichunk3d,jchunk3d,kchunk3d         192          96          64
     netcdf      Write Time is    0.24260 at Fcst   03:00
     total            Write Time is    1.50021 at Fcst   03:00
     fv3_cap,aft mdladv,na=          24  time=   30.5971260070801
    
    
         ENDING DATE-TIME    NOV 27,2020  04:24:12.922  332  FRI   2459181
         PROGRAM nems      HAS ENDED.
    * . * . * . * . * . * . * . * . * . * . * . * . * . * . * . * . * . * . * . * .
    *****************RESOURCE STATISTICS*******************************
    The total amount of wall time                        = 44.461008
    The total amount of time in user mode                = 43.296000
    The total amount of time in sys mode                 = 0.612000
    The maximum resident set size (KB)                   = 591768
    Number of page faults without I/O activity           = 460109
    Number of page faults with I/O activity              = 1
    Number of times filesystem performed INPUT           = 0
    Number of times filesystem performed OUTPUT          = 17128
    Number of Voluntary Context Switches                 = 680
    Number of InVoluntary Context Switches               = 56
    *****************END OF RESOURCE STATISTICS*************************
    
    0
    Job finished.
    50.802 + tail -1 /home/ubuntu/.output.log
    50.810 + exit 0
    50.810 + ERR=0
    50.810 + export ERR
    50.810 + err=0

Unless you are curious, you can skip this paragraph and move to the post-processing step.
We can also rerun this step with multiple nodes by undoing the changes we made to `config.fv3`,
and changing `c48.xml` to use 5 nodes for the forecast instead of 1.
The forecast will then use 5 nodes (18 cores each), but it results in about 3x slower time.
This is because the C48 problem is tiny, and we are not using EFA

         ENDING DATE-TIME    NOV 27,2020  19:27:52.155  332  FRI   2459181
         PROGRAM nems      HAS ENDED.
    * . * . * . * . * . * . * . * . * . * . * . * . * . * . * . * . * . * . * . * . 
    *****************RESOURCE STATISTICS*******************************
    The total amount of wall time                        = 336.159343
    The total amount of time in user mode                = 116.240000
    The total amount of time in sys mode                 = 0.532000
    The maximum resident set size (KB)                   = 449424
    Number of page faults without I/O activity           = 305960
    Number of page faults with I/O activity              = 0
    Number of times filesystem performed INPUT           = 0
    Number of times filesystem performed OUTPUT          = 3808
    Number of Voluntary Context Switches                 = 689
    Number of InVoluntary Context Switches               = 11328
    *****************END OF RESOURCE STATISTICS*************************

#### Fourth step `gfspost`

This requires 4 nodes to process.

    $ rocotoboot -v 10 -w c48.xml -d c48.dl -c all -t gfspost001
    11/27/20 18:12:38 UTC :: c48.xml :: Slurm accounting storage is disabled
    11/27/20 18:12:38 UTC :: c48.xml :: Submitting gfspost001 using sbatch < /tmp/sbatch.in20201127-59780-1x21vmh with input
    {{
    #! /bin/sh
    #SBATCH --job-name=c48_gfspost001_00
    #SBATCH --account=gsd-hpcs
    #SBATCH --qos=batch
    #SBATCH --nodes=4-4
    #SBATCH --tasks-per-node=12
    #SBATCH -t 06:00:00
    #SBATCH -o /home/ubuntu/RUNS/global/noscrub/ubuntu/fv3gfs/comrot/c48/logs/2019092700/gfspost001.log
    #SBATCH --export=ALL
    #SBATCH --comment=2efd462ad5f9a2fb7aac3551e52c471d
    export RUN_ENVIR='emc'
    export HOMEgfs='/opt/global-workflow'
    export EXPDIR='/home/ubuntu/RUNS/global/save/ubuntu/fv3gfs/expdir/c48'
    export CDATE='2019092700'
    export CDUMP='gfs'
    export PDY='20190927'
    export cyc='00'
    export FHRGRP='001'
    export FHRLST='f000_f003_f006_f009'
    export ROTDIR='/home/ubuntu/RUNS/global/noscrub/ubuntu/fv3gfs/comrot/c48'
    $GFS_ADD_SCRIPT; $GFS_DAEMON_RUN; $GFS_SING_CMD /opt/global-workflow/jobs/rocoto/post.sh; EXCODE=$?; $GFS_DAEMON_KILL; exit $EXCODE;
    }}
    task 'gfspost001' for cycle '201909270000' has been booted

Checking status

    $ squeue
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
                5   compute c48_gfsp   ubuntu  R       2:56      4 ip-137-75-88-[100-102,116]

Log file should show something like below

    18:2513983:d=2019092700:TMP:PV=-1e-06 (Km^2/kg/s) surface:3 hour fcst:
    19:2657180:d=2019092700:HGT:PV=-1e-06 (Km^2/kg/s) surface:3 hour fcst:
    20:2834388:d=2019092700:PRES:PV=-1e-06 (Km^2/kg/s) surface:3 hour fcst:
    21:3011289:d=2019092700:VWSH:PV=-1e-06 (Km^2/kg/s) surface:3 hour fcst:
    22:3112100:d=2019092700:UGRD:PV=1.5e-06 (Km^2/kg/s) surface:3 hour fcst:
    23:3251125:d=2019092700:VGRD:PV=1.5e-06 (Km^2/kg/s) surface:3 hour fcst:
    24:3391175:d=2019092700:TMP:PV=1.5e-06 (Km^2/kg/s) surface:3 hour fcst:
    25:3532760:d=2019092700:HGT:PV=1.5e-06 (Km^2/kg/s) surface:3 hour fcst:
    26:3709323:d=2019092700:PRES:PV=1.5e-06 (Km^2/kg/s) surface:3 hour fcst:
    27:3879934:d=2019092700:VWSH:PV=1.5e-06 (Km^2/kg/s) surface:3 hour fcst:
    28:3982911:d=2019092700:UGRD:PV=-1.5e-06 (Km^2/kg/s) surface:3 hour fcst:
    29:4118917:d=2019092700:VGRD:PV=-1.5e-06 (Km^2/kg/s) surface:3 hour fcst:
    30:4255133:d=2019092700:TMP:PV=-1.5e-06 (Km^2/kg/s) surface:3 hour fcst:
    31:4390598:d=2019092700:HGT:PV=-1.5e-06 (Km^2/kg/s) surface:3 hour fcst:
    32:4562183:d=2019092700:PRES:PV=-1.5e-06 (Km^2/kg/s) surface:3 hour fcst:
    33:4731342:d=2019092700:VWSH:PV=-1.5e-06 (Km^2/kg/s) surface:3 hour fcst:
    0 + err=0
    0 + export err
    0 + err_chk
    postcheck completed cleanly
    0 + mv pgb2bfile_003_24_0p5.new pgb2bfile_003_24_0p5

Post processed files should be in your COMROT directory
    
    $ cdcom
    $ ls c48/gfs.20190927/00/atmos/
    gfs.t00z.atmf000.nc        gfs.t00z.master.grb2if003     gfs.t00z.pgrb2.0p50.f003      gfs.t00z.pgrb2b.0p25.f000.idx  gfs.t00z.pgrb2b.1p00.f000      gfs.t00z.sfluxgrbf000.grib2.idx
    gfs.t00z.atmf003.nc        gfs.t00z.pgrb2.0p25.f000      gfs.t00z.pgrb2.0p50.f003.idx  gfs.t00z.pgrb2b.0p25.f003      gfs.t00z.pgrb2b.1p00.f000.idx  gfs.t00z.sfluxgrbf003.grib2
    gfs.t00z.logf000.txt       gfs.t00z.pgrb2.0p25.f000.idx  gfs.t00z.pgrb2.1p00.f000      gfs.t00z.pgrb2b.0p25.f003.idx  gfs.t00z.pgrb2b.1p00.f003      gfs.t00z.sfluxgrbf003.grib2.idx
    gfs.t00z.logf003.txt       gfs.t00z.pgrb2.0p25.f003      gfs.t00z.pgrb2.1p00.f000.idx  gfs.t00z.pgrb2b.0p50.f000      gfs.t00z.pgrb2b.1p00.f003.idx  INPUT
    gfs.t00z.master.grb2f000   gfs.t00z.pgrb2.0p25.f003.idx  gfs.t00z.pgrb2.1p00.f003      gfs.t00z.pgrb2b.0p50.f000.idx  gfs.t00z.sfcf000.nc
    gfs.t00z.master.grb2f003   gfs.t00z.pgrb2.0p50.f000      gfs.t00z.pgrb2.1p00.f003.idx  gfs.t00z.pgrb2b.0p50.f003      gfs.t00z.sfcf003.nc
    gfs.t00z.master.grb2if000  gfs.t00z.pgrb2.0p50.f000.idx  gfs.t00z.pgrb2b.0p25.f000     gfs.t00z.pgrb2b.0p50.f003.idx  gfs.t00z.sfluxgrbf000.grib2

#### Cleanup

To stop our compute fleet using pcluster
    
    $ pcluster stop mycluster
     Stopping compute fleet : mycluster

If you don't need the cluster anymore, you can delete it

    $ pcluster delete mycluster
    Deleting: mycluster
    Status: DELETE_FAILEDer-mycluster - DELETE_FAILED                               
    Cluster did not delete successfully. Run 'pcluster delete mycluster' again

This usually doesn't delete everything for me, so I have to go to AWS console and delete it in CloudFormation
while retaining root policies I have.

## Testing the GNU container

The steps for running the GNU are the same except that we need
to install mpich ourselves.

    $ cd ~
    $ cp /NCEPPROD/intall_mpich.sh .
    $ ./install_mpich.sh

Then we pull the GNU version of the image

    $ singularity build --fix-perms --sandbox workflow docker://dshawul/gfs-gnu

Apparently the GNU container does not need the `aws_fix` we did for the intel compiler.
The file only contains symlinking bash to sh

    #!/bin/bash

    #symlink bash to sh on compute nodes
    sudo ln -sf /bin/bash /bin/sh

Why the Intel container needs unsetting of SLURM variables need to be investigated and fixed.
Results for the forecast using GNU are two times slower than using intels

         ENDING DATE-TIME    NOV 28,2020  17:09:28.605  333  SAT   2459182
         PROGRAM nems      HAS ENDED.
    * . * . * . * . * . * . * . * . * . * . * . * . * . * . * . * . * . * . * . * .
    *****************RESOURCE STATISTICS*******************************
    The total amount of wall time                        = 117.331577
    The total amount of time in user mode                = 96.376000
    The total amount of time in sys mode                 = 1.136000
    The maximum resident set size (KB)                   = 526916
    Number of page faults without I/O activity           = 525992
    Number of page faults with I/O activity              = 3
    Number of times filesystem performed INPUT           = 41528
    Number of times filesystem performed OUTPUT          = 16944
    Number of Voluntary Context Switches                 = 1110
    Number of InVoluntary Context Switches               = 647
    *****************END OF RESOURCE STATISTICS*************************

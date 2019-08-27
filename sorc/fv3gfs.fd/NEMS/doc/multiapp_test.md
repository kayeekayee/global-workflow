Multi-App Regression Test {#multiapp_test}
=========================

When the NEMS has to be updated, the applications that use NEMS must
be tested before any change can be accepted into the repository
master.  Each application can be tested individually with the
[NEMSCompsetRun](running)
and must be tested on each platform that the app supports.  The
combination of app, platform, and compset explodes quickly as it is
multiplicative.  For this reason, a multi-app test system was written
on top of the 
[NEMSCompsetRun](running.)

This page will describe the features of the multi-app test system, and
how to run it for typical situations.

Two Use Cases
-------------

The `multi-app-test.sh` script is run two different ways: one for the
commit process, and another for nightly tests.  Two accounts take part
in this: a personal account, for repository work, and a role account
for the test execution.  This process does not start until after NEMS
and app branches have been created by developers who are ready for it
to be tested.  You could consider that "step 0" of the below processes.

For the NEMS commit process:

1. `web_init` --- initialize a website that will show results.  Run by
the account that owns the website (role or personal).

2. `make_branches` --- copy the app and NEMS branches, creating
temporary branches to support the test.  These are created in the
application and NEMS central git repositories.  This is done by the
personal account.

3. `checkout` --- checks out the temporary branches on disk.  Run by
the personal account on each NOAA machine.

4. `test` --- copy the checkout directory and execute the test.  Run
by the role account on each NOAA machine.

5. `push` --- copy the test directory log files to the checkout
directory and push them to the temporary test branches in git.  Run by
the personal account on each NOAA machine.

6. `deliver` --- copy the test directory log files to a website.  Send
emails if requested.  Run by the account that owns the website (role
or personal) on each NOAA machine.

7. `master` --- merge the temporary branches to the masters of all
apps and components.

8. `delete_branches` --- delete the temporary branches

Potentially, this can be used to test branches without pushing to
master by skipping step 7, `master`.

The nightly test is similar, but it omits all steps related to
commits, and does not initialize the webpage:

1. `checkout` --- checks out the temporary branches on disk.  Run by
the personal account on each NOAA machine.

2. `test` --- copy the checkout directory and execute the test.  Run
by the role account on each NOAA machine.

3. `deliver` --- copy the test directory log files to a website.  Send
emails if requested.  Run by the account that owns the website (role
or personal) on each NOAA machine.

The `multi-app-test.sh` script has three other run modes that are used
on occasion when manual intervention is needed.

* `delete_and_make_branches` --- Creates the test branches, as per
`make_branches`, but deletes the branch if it already exists.  Run by
the personal account.

* `resume_test` --- resumes a failed test.  This is run by the role
account for one app on one platform after any manual intervention in
app tests is completed.

* `dump` --- prints the script configuration information to stdout without
doing anything else.

The `multi-app-test.sh` Script
------------------------------

The multi-app test system resides in the
`NEMS/tests/multi-app-test.sh` script, plus some configuration
`*.input` files in the same directory.  The script is written in POSIX
sh and contains thorough documentation on how its internal
implementation works.  This page explains the interface; we will not
discuss implementation details beyond what is needed to understand the
features.

The script requires configuration files, sent to the stdin of the script:

    cat apps.def commit.def | multi-app-test.sh ... arguments ...
    - or -
    cat apps.def nightly.def | multi-app-test.sh ... arguments ...

Arguments to the script specify an alphanumeric identifier of the
test, the platform on which the script should run, the stage of the
test process to execute, and details about that action.  The `test_id`
is simply used to avoid clashing with other tests that may be running
in the same accounts.

    ... | multi-app-test.sh test_id platform stage ... more stuff ...

Configuration Files
-------------------

The configuration files are sent to the stdin stream of the
`multi-app-test.sh` script.  They describe the known platforms, disk
locations, apps, repository locations, and which apps are run on which
platforms (among other things).  Presently, the relevant
configuration is in three files:

* `NEMS/tests/apps.def` --- list of apps, platforms, platform
  configuration details, and which apps should be tested on which
  platform.  This is used for all executions of `multi-app-test.sh`.

* `NEMS/tests/nightly.def` --- List of webpage locations, names of the
  accounts that will run the test, and some logic to disable
  committing changes.  This is used for the nightly test.

* `NEMS/tests/commit.def` --- List of webpage locations, names of the
  accounts that will run the test, and branch names for the commit
  logic.  This is used for executing the NEMS commit process, or for
  testing a branch without committing.

An extremely abbreviated version of these files will be shown and
described below.

### The `apps.def` File

The `apps.def` file looks like this, but most of the platforms, apps, etc. are
omitted for brevity:

    PLATFORM theia          NAME Theia
    PLATFORM gaea           NAME GAEA C3
    ...
    APP NEMSfv3gfs      COMPSETS -f
    APP FV3-MOM6-CICE5  COMPSETS -f
    ...
    APP NEMSfv3gfs      URL gerrit:NEMSfv3gfs
    APP FV3-MOM6-CICE5  URL gerrit:EMC_FV3-MOM6-CICE5
    ...
    ON theia            SCRUB /scratch4/NCEPDEV/nems/scrub/$username
    ON gaea             SCRUB $( ls -1d /lustre/f1/*/$username | head -1 )
    ...
    ON gaea             APPS NEMSfv3gfs
    ON theia            APPS NEMSfv3gfs NEMSGSM HYCOM-GSM-CICE WW3-FV3 WW3-ATM FV3-MOM6-CICE5
    ...
    ON gaea             EXTRA_ARGS --platform gaea.c3

Meanings of these lines:

`PLATFORM platform_name NAME human-readable name` --- defines a platform and gives a name for it, suitable for websites.  This line must be specified for each platform.

`APP NEMSfv3gfs COMPSETS -f` --- defines an app and gives the
NEMSCompsetRun arguments needed to request the relevant compsets.  This line must be specified for each app.

`APP NEMSfv3gfs URL gerrit:NEMSfv3gfs` --- gives the URL of the Git
repository for an app.  This line must be specified for each app.

`ON theia SCRUB /scratch4/NCEPDEV/nems/scrub/$username` --- the shell expression that generates the path to a scrub area.  This line must be specified for each platform.

`ON theia APPS NEMSfv3gfs NEMSGSM HYCOM-GSM-CICE WW3-FV3 WW3-ATM
FV3-MOM6-CICE5` --- the apps to test on the specified platform.  This line must be specified for each platform.

`ON gaea EXTRA_ARGS --platform gaea.c3` --- any extra arguments needed to NEMSCompsetRun to correctly run on this platform.  This line is optional.

### The `commit.def` File

The `commit.def` file looks like this, but most platforms are removed here for brevity:

    ON theia          WEBPAGE jetscp.rdhpcs.noaa.gov:/lfs3/projects/hfv3gfs/emc.nemspara/web/nems-commit/dell-produtil/
    ON gaea           WEBPAGE jetscp.rdhpcs.noaa.gov:/lfs3/projects/hfv3gfs/emc.nemspara/web/nems-commit/dell-produtil/
    ...
    USER ACCOUNT IS Samuel.Trahan
    ROLE ACCOUNT IS emc.nemspara

    NEMS   BRANCH IS dell-produtil
    APP    BRANCH IS dell-produtil-commit

    APP NEMSfv3gfs       CHECKOUT dell-produtil
    MASTER BRANCH IS master

`ON theia WEBPAGE
jetscp.rdhpcs.noaa.gov:/lfs3/projects/hfv3gfs/emc.nemspara/web/nems-commit/dell-produtil/`
--- Specifies the argument to rsync to transfer webpage content.  This
can be a local directory, if the "webpage" is a local disk location.  This must be specified for each platform.

`USER ACCOUNT IS Samuel.Trahan` --- specifies the name of the personal
account that will run Git commands.  This is used for filesystem
paths, to find flag files and status files.

`ROLE ACCOUNT IS emc.nemspara` --- specifies the name of the role
account that will execute the test.  This is used for filesystem
paths, to find flag files and status files.

`NEMS BRANCH IS dell-produtil` --- the name of the branch in the NEMS
Git repository that we're testing for a commit.

`APP BRANCH IS dell-produtil-commit` --- the name of the temporary
branch to make in each app for committing log files and updating the
NEMS submodule.  This is only specified once; it is the same for all apps.

`APP NEMSfv3gfs CHECKOUT dell-produtil` --- if needed, the name of the
branch to copy to make the temporary app branch.  If an app does not
have this line, then the "master" branch will be copied.

`MASTER BRANCH IS master` --- the name of the Git "master" branch.
You should never change this unless you're specifically testing the
commit process code.

### The `nightly.def` File

    ON theia          WEBPAGE samuel.trahan@dmzgw.ncep.noaa.gov:/home/www/emc/htdocs/projects/rt
    ON gaea           WEBPAGE samuel.trahan@dmzgw.ncep.noaa.gov:/home/www/emc/htdocs/projects/rt
    ...
    USER ACCOUNT IS Samuel.Trahan
    ROLE ACCOUNT IS emc.nemspara

    NEMS   BRANCH IS default

The lines have the same meaning as the `checkout.def` file.  Note that
nearly all of the lines related to branch names are gone.  The only
that remains is:

`NEMS BRANCH IS default` --- this special value for "NEMS BRANCH"
tells the script to use whatever is in the "NEMS" submodule of each
app.

Executing the NEMS Commit Process Using `multi-app-test.sh`
-----------------------------------------------------------

An overview of this process is given at the top of this page.  Here,
we go into detail.  We're going to test a NEMS commit in a NEMS branch
called, "blah" where the NEMSfv3gfs app has a corresponding "fv3-blah"
branch with changes that must go in at the same time.  The test will
be run by emc.nemspara, and the repo work will be done by
user "Somebody.Else"

In this list of instructions, you should assume the action is to be
performed only once, on one NOAA machine, unless the instruction
explicitly says otherwise.

### Notes on Running `multi-app-test.sh`

Furthermore, when running the `multi-app-test.sh`, you will need to
disconnect it from a terminal, which will be shown again in later
steps:

    nohup sh -c 'cat apps.def commit.def | ./multi-app-test.sh ... arguments ...'

This is a workaround for problems in git and ssh.  Those commands act
differently if they have a terminal and may break.  The `nohup`
command is usually sufficient to get them to stop using the terminal.

If `nohup`'s output is the terminal then `nohup` will place its output
in `nohup.out`.  You can set a new location by redirecting stdout and
stderr to another file:

    nohup sh -c 'cat ... | ./multi-app-test.sh ... ' > some-file.log 2>&1
    nohup sh -c 'cat ... | ./multi-app-test.sh ... ' >& some-file.log

### Determining if `multi-app-test.sh` Succeeded

Any stages that run for each app will have this message on success.

    Zero exit status for all jobs.

If something fails, the prior lines will tell you which app failed and
where its log file resides.

Four stages do not run all apps, and will have error messages directly
in the output of `multi-app-test.sh`.  Those stages are: `dump`,
`web_init`, `resume_test`, and `master`.  For those stages,
`multi-app-test.sh` will exit with status 0 on success and 1 on
failure.

Here are the steps:

1. Decide on an ID for the test, hereafter referred to as `<ID>`.  This
should be a three-to-four-character alphanumeric code.  It is used to
differentiate between your test and any other tests that are running.
The official nightly test uses "ngt", so don't use that.

2. User Somebody.Else checks out the NEMS branch on disk on any NOAA
machine:

    git clone -b whatever gerrit:NEMS
    cd NEMS

3. User Somebody.Else update the branch names and website locations in
`tests/commit.def`.  Update the user account too.  The result will
look something like this:

    ON tujet WEBPAGE /lfs3/projects/hfv3gfs/emc.nemspara/web/nems-commit/blah
    ... update other ON...WEBPAGE lines ...
    USER ACCOUNT IS Somebody.Else
    ROLE ACCOUNT IS emc.nemspara
    NEMS BRANCH IS blah
    APP BRANCH IS blah-commit
    APP NEMSfv3gfs CHECKOUT fv3-blah
    MASTER BRANCH IS master

4. User Somebody.Else commits the changes to `commit.def` and pushes
them to the remote `blah` branch.

5. User Somebody.Else makes the branches.  Suppose we're on Theia.
Then the command would be:

    cd tests/
    nohup sh -c 'cat apps.def commit.def | ./multi-app-test.sh <ID> theia make_branches'

6. The owner of the website makes the web directory.  This may be
either emc.nemspara or Somebody.Else.  Note that `nohup` is not necessary
here:

    cd tests/
    cat apps.def commit.def | ./multi-app-test.sh <ID> theia web_init

7. On each NOAA machine, user Somebody.Else checks out a clean copy of
the NEMS "blah" branch on each of the NOAA machines.  At present,
there are seven machines: WCOSS Phase 1, WCOSS Phase 2, WCOSS Cray, WCOSS Phase
3 (Dell), Jet, Gaea, and Theia.

    git clone -b whatever gerrit:blah-test
    cd NEMS

8. On each NOAA machine, user Somebody.Else checks out the relevant
branch of each app using the "checkout" stage.  Here, replace
`<PLATFORM>` with the platform on which the command is being run:

    cd NEMS/tests
    nohup sh -c 'cat apps.def commit.def | ./multi-app-test.sh <ID> <PLATFORM> checkout'

9. On each NOAA machine, user emc.nemspara runs the test.  The log
file cannot be `nohup.out` because Somebody.Else owns the directory.
We have to redirect the output somewhere else:

    cd NEMS/tests
    nohup sh -c 'cat apps.def commit.def | ./multi-app-test.sh <ID> <PLATFORM> test' > ~/test.log 2>&1

   If you're using tcsh, then the command is:

       cd NEMS/tests
       nohup sh -c 'cat apps.def commit.def | ./multi-app-test.sh <ID> <PLATFORM> test' >& ~/test.log

   NOTE!!! For 'slurm' tests (on Jet and Theia), before running you have to load module slurm in separate
   window from moab/torque  tests, where module slurm must not be loaded.

10. On each NOAA machine, user Somebody.Else pushes the log files to
the temporary test branches:

    cd NEMS/tests
    nohup sh -c 'cat apps.def commit.def | ./multi-app-test.sh <ID> <PLATFORM> push'

11. On each NOAA machine, the owner of the website updates the website
with results.  If this is run by emc.nemspara, then the log file
cannot be `nohup.out` because Somebody.Else owns the `NEMS/tests`
directory.  We would have to redirect the log file elsewhere in that case:

    cd NEMS/tests
    nohup sh -c 'cat apps.def commit.def | ./multi-app-test.sh <ID> <PLATFORM> deliver' > ~/deliver.log 2>&1

   If you're using tcsh, then the command is:

       cd NEMS/tests
       nohup sh -c 'cat apps.def commit.def | ./multi-app-test.sh <ID> <PLATFORM> deliver' >& ~/deliver.log

12. Relevant individuals read through the logs and website to decide
whether the commit should be made.

13. The NEMS code manager sends a commit announcement to the NEMS
announcement list, with a specified time and date of the commit.

14. All rejoice at the announcement and eagerly await the date and
time of the commit.

15. Someone prepares a text file with the commit message.  This
message will be attached to the commit to NEMS and the apps, so it
should be all-encompassing.

16. User Somebody.Else pushes to masters of all apps and NEMS.  For
this step to work, user Somebody.Else must have the ability to push to
all masters directly, bypassing Gerrit Code Review or other
protections.

    cd NEMS/tests
    nohup sh -c 'cat apps.def commit.def | ./multi-app-test.sh <ID> <PLATFORM> master /path/to/file/with/commit/message'

17. On each NOAA machine, user Somebody.Else deletes
the temporary test branches:

    cd NEMS/tests
    nohup sh -c 'cat apps.def commit.def | ./multi-app-test.sh <ID> <PLATFORM> delete_branches'

18. If needed, also delete the development branches for this commit.


Executing the NEMS Nightly Test Using `multi-app-test.sh`
---------------------------------------------------------

Realistically, this would be started automatically via CRON or some
similar process.  It is an (extremely) simplified version of the
commit process and runs off of `nightly.def` instead of `commit.def`.
As before, `Somebody.Else` is a personal account with git repository
access and `emc.nemspara` is the role account used to actually run the
tests.

1. Decide on an ID for the test, hereafter referred to as `<ID>`.
This should be a three-to-four-character alphanumeric code.  It is
used to differentiate between your test and any other tests that are
running.  The official nightly test uses "ngt", so don't use that
unless you are running the official nightly test.

2. On each NOAA machine, user Somebody.Else checks out the relevant
branch of each app using the "checkout" stage.  Here, replace
`<PLATFORM>` with the platform on which the command is being run:

    cd NEMS/tests
    nohup sh -c 'cat apps.def nightly.def | ./multi-app-test.sh <ID> <PLATFORM> checkout'

3. On each NOAA machine, user emc.nemspara runs the test.  The log
file cannot be `nohup.out` because Somebody.Else owns the directory.
We have to redirect the output somewhere else:

    cd NEMS/tests
    nohup sh -c 'cat apps.def nightly.def | ./multi-app-test.sh <ID> <PLATFORM> test' > ~/test.log 2>&1

   If you're using tcsh, then the command is:

       cd NEMS/tests
       nohup sh -c 'cat apps.def nightly.def | ./multi-app-test.sh <ID> <PLATFORM> test' >& ~/test.log

4. On each NOAA machine, the owner of the website updates the website
with results.  If this is run by emc.nemspara, then the log file
cannot be `nohup.out` because Somebody.Else owns the `NEMS/tests`
directory.  We would have to redirect the log file elsewhere in that case:

    cd NEMS/tests
    nohup sh -c 'cat apps.def nightly.def | ./multi-app-test.sh <ID> <PLATFORM> test' > ~/test.log 2>&1

   If you're using tcsh, then the command is:

       cd NEMS/tests
       nohup sh -c 'cat apps.def nightly.def | ./multi-app-test.sh <ID> <PLATFORM> test' >& ~/test.log

5. Wait a day.

6. Go to step 2.

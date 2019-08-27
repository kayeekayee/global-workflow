Notes for NEMS Code Managers {#code-manager-notes}
============================

This page serves as a "notebook" for keeping information needed for
personnel to manage the NEMS code.  It is mainly targetted to the NEMS
Code Manager, but may be of use to other code managers as well.

NEMS Compset Data Locations
---------------------------

The NEMS compset data, also known as regression test data, is stored
in specific locations on each NOAA machine.  There is a directory
structure like so:

* /path/to/RT
  * /path/to/RT/app-name
    * /path/to/RT/app-name/branch-20190919
    * /path/to/RT/app-name/branch-20191223
    * /path/to/RT/app-name/another-branch-20190918
  * /path/to/RT/another-app
    * /path/to/RT/app-name/branch-20190825

If the branch name in the filename is "trunk," then it is actually for
the "master" branch.  The "trunk" directory name was retained for
continuity after the transition to Subversion in 2018.

The "RT" directory is in these locations:

| Machine       | Directory                                                            |
| ------------- | -------------------------------------------------------------------- |
| WCOSS Phase 1 | `/nems/noscrub/emc.nemspara/RT`                                      |
| WCOSS Phase 2 | `/nems/noscrub/emc.nemspara/RT`                                      |
| WCOSS Cray    | `/gpfs/hps3/emc/nems/noscrub/emc.nemspara/RT`                        |
| WCOSS Phase 3 | `/gpfs/dell2/emc/modeling/noscrub/emc.nemspara/RT`                   |
| Jet           | `/lfs3/projects/hfv3gfs/emc.nemspara/RT`                             |
| Theia         | `/scratch4/NCEPDEV/nems/noscrub/emc.nemspara/RT`                     |
| GAEA          | `/lustre/f1/pdata/ncep_shared/emc.nemspara/RT`                       |

The GAEA directory is simply a mirror of the contents of the WCOSS
Cray directory because those machines get identical results.  Thus,
the files are copied via a relay through Jet.

    emc.nemspara@jet> mkdir -p /lfs3/projects/hfv3gfs/emc.nemspara/wcoss-NEMSfv3gfs-YYYYMMDDHH
    emc.nemspara@surge> cd /gpfs/hps3/emc/nems/noscrub/emc.nemspara/RT/NEMSfv3gfs/trunk-YYYYMMDDHH
    emc.nemspara@surge> rsync -arv . jetscp.rdhpcs.noaa.gov:/lfs3/projects/hfv3gfs/emc.nemspara/wcoss-NEMSfv3gfs-YYYYMMDDHH/.
    emc.nemspara@gaea> mkdir -p /lustre/f1/pdata/ncep_shared/emc.nemspara/RT/trunk-YYYYMMDDHH
    emc.nemspara@gaea> cd /lustre/f1/pdata/ncep_shared/emc.nemspara/RT/trunk-YYYYMMDDHH
    emc.nemspara@gaea> rsync -arv jetscp.rdhpcs.noaa.gov:/lfs3/projects/hfv3gfs/emc.nemspara/wcoss-NEMSfv3gfs-YYYYMMDDHH/. .

Potentially, a relay through HPSS or Theia would work as well.  Jet is
used because it is generally the most reliable transfer method.  From
WCOSS, jetscp is frequently faster than Theia or HPSS because the
dedicated network line between WCOSS and Theia/HPSS is often clogged.
Transfers from WCOSS to Jet go through a different route.

Critical NEMS Crontabs
----------------------

There are eight crontabs for NEMS: four for nemspara, and four for a
personal account with git and website access.  These can be found in
the NEMS repository under `tests/nightly/cron/`.  Note that all WCOSS
cron jobs are launched from one part of WCOSS to all others via ssh.
Presently, this is done from WCOSS Phase 1.  It could be moved to any
other part of WCOSS that has CRON.

The cron jobs fall under six categories.  Example lines are shown in
this list.

1. Create the directory for log files, otherwise the other commands
cannot even start.  Note that the personal account and role account
will have different directories for the log file.  We refer to both
areas as `/path/to/log/dir` for brevity.

    3 0 * * * mkdir -p /path/to/log/dir

2. Check out the repository for the nightly test.  This is done only
by the personal account.

    00 16 * * * /path/to/NEMS/tests/nightly/run-from-wcoss.sh wcoss1  checkout > /path/to/log/dir/checkout-wcoss-phase1.log 2>&1

3. Run the nightly test.
Only nemspara runs this.

    26 17 * * * /path/to/NEMS/tests/nightly/run-from-wcoss.sh wcoss1 test > /path/to/log/dir/test-wcoss-phase1.log 2>&1

4. Transfer the website to a directory on Jet via jetscp.  This is
done only by nemspara.  Note that it happens hourly.  That is required
because the tests may finish at any time.

    47 * * * * /path/to/NEMS/tests/nightly/run-from-wcoss.sh wcoss1 deliver > /path/to/log/dir/deliver-wcoss-phase1.log 2>&1

5. Transfer the website directory from Jet to the
`dmzgw.ncep.noaa.gov` website back-end.  This is done by the account
that has access to the dmzgw.  This may be an entirely different
account than the two that maintain the test.

    # Jet only!
    13 * * * * rsync -arv /path/to/jet/web/dir/. username@dmzgw.ncep.noaa.gov:/home/www/emc/htdocs/projects/rt/. > /path/to/log/dir/nightly-rt-web-transfer.log 2>&1

6. Send emails, if desired.  Presently there are two cron jobs for
these.  One only sends an email if there are failures, and that email
goes to all application code managers.  The other always sends an
email, even if nothing failed, and that goes only to the NEMS code
manager.

    # Only send failure emails:
    5 6 * * * /path/to/NEMS/tests/nightly/email-rt.pl -e User.1@noaa.gov,User.2@noaa.gov,...  /path/to/jet/web/dir/*/*/*.txt > /path/to/log/dir/nightly-rt-web-transfer.log/path/to/log/dir/nightly-test-email-selective.log

    # Send all emails.  Note "-a" is now the first argument to the script:
    5 18 * * * /path/to/NEMS/tests/nightly/email-rt.pl -a -e Use.1r@noaa.gov /path/to/jet/web/dir/*/*/*.txt > /path/to/log/dir/nightly-rt-web-transfer.log/path/to/log/dir/nightly-test-email-selective.log


Generating the NEMS Documentation Webpage
-----------------------------------------

The NEMS documentation can be found here:

* http://www.emc.ncep.noaa.gov/projects/nems-doc

It is generated from the contents of the `doc/` directory within the
NEMS repository.  This is the process for updating that documentation.

1. Get a copy
of NEMS

    git clone gerrit:NEMS
    cd NEMS/doc

2. In the `Makefile` file, edit the "TARGET ?=" line for the current
platform so it will transfer under your account.  It should point to a
test area, rather than the final one.

    TARGET ?= samuel.trahan@dmzgw.ncep.noaa.gov:/home/www/emc/htdocs/projects/nems-sample/.

3. Make sure any local changes are committed and pushed to the origin.
This is needed to ensure the hash at the top of the webpage and the
documentation contents matches the repository copy:

    git add ...
    git rm ...
    git commit ...
    git push ...

4. Generate the webpage
in the local directory:

    make doc

5. Copy the webpage to the
destination directory:

    make deliver

6. Go to your web browser and make sure the webpage looks how you want
it to.  In the example path in step 2, that would be:

> http://www.emc.ncep.noaa.gov/projects/nems-sample

7. If needed, edit the documentation and redo steps 2-6 until you like what you see.

8. Move the webpage to
the final location:

    ssh username@dmzgw.ncep.noaa.gov # or emcrzdm
    cd /home/www/emc/htdocs/projects
    rm -rf nems-doc
    mv nems-sample nems-doc

Getting NEMS Access
-------------------

To run the NEMS multi-app regression tests, you need access to all
VLAB and github repositories for all apps, NEMS, FMS, components, and
NCEPLIBS-pyprodutil.

To have access to the "nems" project and "emc.nemspara":

1. Use the AIM webpage to get "nems" and "emc-nems" access.  The
"emc.nems" group is the equivalent of "nems" on HPSS.

2. The user's WCOSS account must be updated for "nems" and
"emc.nemsparasudo" access.  In EMC this is handled by Mary Hart.

3. Submit tickets to rdhpcs.jet.help@noaa.gov,
rdhpcs.theia.help@noaa.gov, and *FIXME: what is the GAEA helpdesk?*
asking for emc.nemspara sudo access.

4. Most likely, the "nems" group access will NOT be correctly
propagated from AIM to GAEA, and possibly Jet or Theia.  You will need
to submit tickets for that.

5. In theory, you can get access to the "NEMS" group on the emc
website by emailing the NCWCP helpdesk.  In practice, tickets to that
helpdesk are ignored.
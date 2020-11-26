#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
DEST=${1:-/usr/bin}

ln -sf ${DIR}/slurm/sbatch $DEST/sbatch
ln -sf ${DIR}/slurm/scancel $DEST/scancel
ln -sf ${DIR}/slurm/squeue $DEST/squeue
ln -sf ${DIR}/slurm/sacct $DEST/sacct
ln -sf ${DIR}/slurm/sinfo $DEST/sinfo
ln -sf ${DIR}/slurm/srun $DEST/srun

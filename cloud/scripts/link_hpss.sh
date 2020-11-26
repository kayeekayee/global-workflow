#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
DEST=${1:-/usr/bin}

ln -sf ${DIR}/hpss/hsi $DEST/hsi
ln -sf ${DIR}/hpss/htar $DEST/htar

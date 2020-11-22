#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

ln -sf ${DIR}/hpss/hsi /usr/bin/hsi
ln -sf ${DIR}/hpss/htar /usr/bin/htar

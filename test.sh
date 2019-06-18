#!/bin/bash -ex

set -e

cd $(dirname "${BASH_SOURCE[0]}")

PYTHON=python3
if $($PYTHON -m fades -V >/dev/null); then
    PYTHON="fades -r requirements.txt -x python"
fi

$PYTHON -m pytest --ignore=geonode $@
exit $?

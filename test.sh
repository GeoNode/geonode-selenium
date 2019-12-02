#!/bin/sh -ex

set -e

cd $(dirname $(realpath "$0"))

PYTHON=python3
if $($PYTHON -m fades -V >/dev/null); then
    PYTHON="fades -r requirements.txt -x python"
fi

$PYTHON -m pytest --ignore=geonode $@
exit $?

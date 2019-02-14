#!/bin/bash -ex

set -e

PYTHON=python3
if $($PYTHON -m fades -V >/dev/null); then
    PYTHON="fades -r requirements.txt -x"
fi

$PYTHON pytest $@
exit $?

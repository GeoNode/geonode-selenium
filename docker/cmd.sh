#!/bin/sh -ex

set -e

cd /app  # needed?
PATH=$PATH:$(pwd)/bin
. venv/bin/activate
for i in {1..60}; do
    curl --fail -s -o /dev/null http://nginx && exec ./test.sh "$@"
    sleep 10
done
exit 1


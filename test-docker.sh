#!/bin/bash -ex

set -e

if [ -z "$GEONODE_REPOSITORY" ]; then
    GEONODE_REPOSITORY="geonode"
fi

for i in {1..3}; do
    cd "$GEONODE_REPOSITORY/scripts/spcgeonode/"
    docker-compose -f docker-compose.yml down --volumes
    docker-compose -f docker-compose.yml up -d --build django geoserver postgres nginx
    cd -

    sleep 10 # avoid curl false positives
    set +e
    curl -s --fail \
         --retry 30 --retry-delay 10 --retry-connrefused \
         http://127.0.0.1/ >/dev/null
    code=$?
    set -e
    if [ $code == 0 ]; then
        ./test.sh
        exit $?
    fi
done
exit 125 # git bisect skip

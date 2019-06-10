#!/bin/bash -ex

set -e

set -a
: "${HTTP_HOST:=127.0.0.1}"
: "${HTTP_PORT:=8080}"
: "${GEONODE_REPOSITORY:=geonode}"
: "${COMPOSE_OPTS:=--build}"
set +a

cd $(dirname "${BASH_SOURCE[0]}")
for i in {1..3}; do

    log=$(docker inspect -f '{{.LogPath}}' django4geonode 2> /dev/null)
    sudo truncate -s 0 $log

    cd "$GEONODE_REPOSITORY/"
    docker-compose -f docker-compose.yml -f docker-compose.override.localhost.yml down --volumes
    docker-compose -f docker-compose.yml -f docker-compose.override.localhost.yml up -d $COMPOSE_OPTS
    cd -

    for i in {1..60}; do
        if [ $(docker logs --tail 10 django4geonode 2>&1 | grep -c "getting INI configuration from /usr/src/app/uwsgi.ini") -ne 0 ]; then
            ./test.sh "$@"
            exit $?
        fi
        sleep 10
    done
done
exit 125 # git bisect skip

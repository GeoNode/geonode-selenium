#!/bin/bash -ex

set -e

set -a
: "${GEONODE_REPOSITORY:=geonode}"
: "${COMPOSE_OPTS:=--build}"
: "${GEONODE_USER:=admin}"
: "${GEONODE_PASS:=admin}"
: "${GEONODE_URL=http://localhost}"
set +a

cd $(dirname "${BASH_SOURCE[0]}")
for i in {1..3}; do
    cd "$GEONODE_REPOSITORY/"
    docker-compose \
        -f docker-compose.yml \
        -f docker-compose.override.localhost.yml \
        down --volumes --remove-orphans
    docker-compose \
        -f docker-compose.yml \
        -f docker-compose.override.localhost.yml \
        up -d $COMPOSE_OPTS
    cd -

    for i in {1..60}; do
        if docker logs --tail 10 django4geonode |& grep "getting INI configuration from /usr/src/app/uwsgi.ini"; then
            ./test.sh "$@"
            exit $?
        fi
        sleep 10
    done
done
exit 125 # git bisect skip

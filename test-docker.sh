#!/bin/bash -ex

set -e

export HTTP_HOST=127.0.0.1
export HTTP_PORT=8080
cd $(dirname "${BASH_SOURCE[0]}")

if [ -z "$GEONODE_REPOSITORY" ]; then
    GEONODE_REPOSITORY="geonode"
fi
if [ -z "$COMPOSE_OPTS" ]; then
    COMPOSE_OPTS="--build"
fi

for i in {1..3}; do
    cd "$GEONODE_REPOSITORY/scripts/spcgeonode/"
    docker-compose -f docker-compose.yml down --volumes
    docker-compose -f docker-compose.yml up -d $COMPOSE_OPTS \
        django geoserver postgres nginx \
        celery celerybeat celerycam rabbitmq
    cd -

    for i in {1..60}; do
        containers=$(docker ps -q \
                     --filter label=com.docker.compose.project=spcgeonode \
                     --filter health=unhealthy \
                     --filter health=starting)
        if [ -z "$containers" ]; then
            ./test.sh "$@"
            exit $?
        fi
        sleep 10
    done
done
exit 125 # git bisect skip

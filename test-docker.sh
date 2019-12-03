#!/bin/sh -ex

set -e

set -a
HTTP_HOST=nginx
HTTP_PORT=80
: "${GEONODE_REPOSITORY:=geonode}"
: "${COMPOSE_OPTS:=--build}"
set +a

cd $(dirname $(realpath "$0"))
docker-compose -f docker/compose-test.yml build
cd "$GEONODE_REPOSITORY/scripts/spcgeonode/"
for i in $(seq 1 3); do
    checks=$(grep -r 'healthcheck:' docker-compose.yml | wc -l)
    docker-compose -f docker-compose.yml down --volumes --remove-orphans
    docker-compose -f docker-compose.yml up -d $COMPOSE_OPTS \
        django geoserver postgres nginx \
        celery celerybeat celerycam rabbitmq

    for j in $(seq 1 60); do
        containers=$(docker ps -q \
                     --filter label=com.docker.compose.project=spcgeonode \
                     --filter health=healthy | wc -l)
        if [ "$containers" -eq "$checks" ]; then
            exec docker-compose -f $OLDPWD/docker/compose-test.yml run geonode-selenium sh cmd.sh "$@"
        fi
        sleep 10
    done
done
exit 125 # git bisect skip

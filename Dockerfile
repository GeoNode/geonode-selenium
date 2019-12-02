FROM python:3.7-alpine

WORKDIR /app
ADD /test *.sh *.txt *.ini docker/cmd.sh ./

RUN apk add --no-cache \
        firefox-esr curl \
        build-base libffi-dev openssl-dev && \
    python3 -m venv venv && \
    . venv/bin/activate && \
    pip install -r requirements.txt && \
    tag=v0.24.0 && \
    mkdir -p bin data && \
    wget https://github.com/mozilla/geckodriver/releases/download/$tag/geckodriver-$tag-linux64.tar.gz -O- | tar zx -C bin && \
    wget https://download.osgeo.org/geotiff/samples/made_up/ntf_nord.tif -P data

ENV GEONODE_URL=http://nginx
CMD ["sh", "/app/cmd.sh"]

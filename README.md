# geonode-selenium

Testing GeoNode with Selenium.

# Requirements

Mandatory:
 - Python 3
 - A browser supported by Selenium (Firefox is used by default)

Optional:
 - GeoNode sourcecode (required by run-docker.sh)
 - fades (to automatically manage virtualenvs)

# Setup

## Dependencies

If using virtualenv:

```bash
$ python3 -m venv venv
$ source venv/bin/activate
$ pip install -r requirements.txt
```

If using fades:

```bash
$ pip3 install --user fades
```

## Data

```bash
$ wget https://download.osgeo.org/geotiff/samples/spot/chicago/UTM2GTIF.TIF -P data
```

# Usage

If GeoNode is running:

```bash
$ ./test.sh
```

If GeoNode is not running (warning: it could delete existing Docker volumes created by SPCgeonode):
```bash
$ git clone https://github.com/GeoNode/geonode.git
$ ./test-docker.sh
```

Set `GEONODE_REPOSITORY` to specify a different path.

## Find the commit that introduced a bug

```bash
$ git checkout -b new-test
$ # write a new test or extend an existing one
$ cd geonode/
$ export GEONODE_REPOSITORY=$(pwd)
$ git bisect start
$ git bisect bad
$ git bisect good $COMMIT
$ git bisect run ../test-docker.sh
```

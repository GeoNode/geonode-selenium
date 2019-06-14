# geonode-selenium

Testing [GeoNode](http://geonode.org/) with [Selenium](https://www.seleniumhq.org/).

# Requirements

Mandatory:
 - [Python 3](https://www.python.org/)
 - A browser supported by a [Selenium WebDriver](https://www.seleniumhq.org/projects/webdriver/) (Firefox is used by default)

Optional:
 - [Docker](https://www.docker.com/) (required by `test-docker.sh`)
 - [GeoNode sourcecode](https://github.com/GeoNode/geonode) (required by `test-docker.sh`)
 - [fades](https://github.com/PyAr/fades) (to automatically manage virtualenvs)

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

## Selenium WebDriver (Gecko)

```bash
$ tag=v0.24.0
$ wget https://github.com/mozilla/geckodriver/releases/download/$tag/geckodriver-$tag-linux64.tar.gz -O- |
      tar zx -C $HOME/bin
```

Other releases are available from: https://github.com/mozilla/geckodriver/releases/latest

## Data

```bash
$ wget https://download.osgeo.org/geotiff/samples/made_up/ntf_nord.tif -P data
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

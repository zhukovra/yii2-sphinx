#!/bin/sh -e
SCRIPT=$(readlink -f "$0")
CWD=$(dirname "$SCRIPT")

if [ "$SPHINX_VERSION" = "3" ]; then
    # download and extract sphinx
    DISTR=sphinx-3.0.1-7fec4f6-linux-amd64
    wget http://sphinxsearch.com/files/$DISTR.tar.gz
    tar xf $DISTR.tar.gz
    sudo cp $DISTR/bin/* /usr/bin
else
    # install sphinx from http://sphinxsearch.com/downloads/release/
    wget http://sphinxsearch.com/files/sphinxsearch_2.2.11-release-1~trusty_amd64.deb
    sudo dpkg -i sphinxsearch_2.2.11-release-1~trusty_amd64.deb
fi

# make dir that is used in sphinx config
mkdir -p sphinx
sed -i s\~SPHINX_BASE_DIR~$PWD/sphinx~g $CWD/../sphinx.conf

# Setup source database
mysql -D yiitest -u travis < $CWD/../source.sql

# setup test Sphinx indexes:
indexer --config $CWD/../sphinx.conf --all

# run searchd:
searchd --config $CWD/../sphinx.conf

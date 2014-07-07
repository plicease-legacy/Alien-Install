#!/bin/sh

export PREFIX=$HOME/opt/libfoo/1.00
mkdir -p $PREFIX/src
cp t/libfoo/libfoo-1.00.tar.gz $PREFIX/src
cd $PREFIX/src
tar xf libfoo-1.00.tar.gz && \
cd libfoo-1.00 && \
./configure --prefix=$PREFIX && \
make && \
make install

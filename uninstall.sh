#!/bin/sh -ex

prefix=$1
if [ "$prefix" = "" ]; then
  prefix=`opam config var prefix`
fi

odir=$prefix/lib
rm -f $odir/pkgconfig/solo5-libc.pc
rm -rf $odir/solo5-libc
rm -rf $prefix/include/solo5-libc

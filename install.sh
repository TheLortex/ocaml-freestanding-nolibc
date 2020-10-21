#!/bin/sh -ex

prefix=${1:-$PREFIX}
if [ "$prefix" = "" ]; then
    prefix=`opam config var prefix`
fi
DESTINC=${prefix}/include/solo5-libc
DESTLIB=${prefix}/lib/solo5-libc
mkdir -p ${DESTINC} ${DESTLIB}

# "nolibc"
cp -r nolibc/include/* ${DESTINC}
cp nolibc/libnolibc.a ${DESTLIB}

# Openlibm
cp -r openlibm/include/*  ${DESTINC}
cp openlibm/src/*h ${DESTINC}
cp openlibm/libopenlibm.a ${DESTLIB}/libm.a

# META: ocamlfind and other build utilities test for existance ${DESTLIB}/META
# when figuring out whether a library is installed
touch ${DESTLIB}/META

# pkg-config
mkdir -p ${prefix}/lib/pkgconfig
cp solo5-libc.pc ${prefix}/lib/pkgconfig/solo5-libc.pc

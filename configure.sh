#!/bin/sh

export PKG_CONFIG_PATH=$(opam config var prefix)/lib/pkgconfig

FREESTANDING_CFLAGS="$(pkg-config --cflags solo5-headers)"

cat <<EOM >Makeconf
FREESTANDING_CFLAGS=${FREESTANDING_CFLAGS}
NOLIBC_SYSDEP_OBJS=sysdeps_solo5.o
EOM

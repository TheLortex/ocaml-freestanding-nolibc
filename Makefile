.PHONY: all clean install uninstall 

include Makeconf

all: openlibm/libopenlibm.a nolibc/libnolibc.a ocaml-freestanding-nolibc.pc 

TOP=$(abspath .)
FREESTANDING_CFLAGS=$(MAKECONF_CFLAGS) -I$(TOP)/nolibc/include -include _freestanding/overrides.h

openlibm/libopenlibm.a:
	$(MAKE) -C openlibm "CFLAGS=$(FREESTANDING_CFLAGS)" libopenlibm.a

NOLIBC_SYSDEP_OBJS=sysdeps_solo5.o
NOLIBC_CFLAGS=$(FREESTANDING_CFLAGS) -I$(TOP)/openlibm/src -I$(TOP)/openlibm/include
nolibc/libnolibc.a:
	$(MAKE) -C nolibc \
	    "FREESTANDING_CFLAGS=$(NOLIBC_CFLAGS)" \
	    "SYSDEP_OBJS=$(NOLIBC_SYSDEP_OBJS)"


DESTDIR ?=
PREFIX := $(MAKECONF_PREFIX)
D := $(DESTDIR)$(PREFIX)
DESTINC := $(D)/include/ocaml-freestanding-nolibc
DESTLIB := $(D)/lib/ocaml-freestanding-nolibc
DESTPKG := $(D)/lib/pkgconfig

SYS := $(shell uname -s)
ifeq ($(SYS),OpenBSD)
# XXX: Needs build-time depext on coreutils in opam files.
INSTALL := ginstall -p
else
INSTALL := install -p
endif

install: all
	$(INSTALL) -d $(DESTINC)
	$(INSTALL) -d $(DESTLIB)
# nolibc
	cd nolibc/include && \
	    find . -type d -exec $(INSTALL) -d \
	    "$(DESTINC)/{}" \;
	cd nolibc/include && \
	    find . -type f -name \*.h -exec $(INSTALL) -m 0644 \
	    "{}" "$(DESTINC)/{}" \;
	$(INSTALL) -m 0644 nolibc/libnolibc.a $(DESTLIB)
# openlibm
	cd openlibm/include && \
	    find . -type d -exec $(INSTALL) -d \
	    "$(DESTINC)/{}" \;
	cd openlibm/include && \
	    find . -type f -name \*.h -exec $(INSTALL) -m 0644 \
	    "{}" "$(DESTINC)/{}" \;
	cd openlibm/src && \
	    find . -type d -exec $(INSTALL) -d \
	    "$(DESTINC)/{}" \;
	cd openlibm/src && \
	    find . -type f -name \*.h -exec $(INSTALL) -m 0644 \
	    "{}" "$(DESTINC)/{}" \;
	$(INSTALL) -m 0644 openlibm/libopenlibm.a $(DESTLIB)/libm.a
# META: ocamlfind and other build utilities test for existance ${DESTLIB}/META
# when figuring out whether a library is installed
	touch $(DESTLIB)/META
# pkg-config
	$(INSTALL) -d $(DESTPKG)
	$(INSTALL) -m 0644 ocaml-freestanding-nolibc.pc $(DESTPKG)
# flags
	echo "-I$(DESTINC) -include _freestanding/overrides.h" > $(DESTLIB)/cflags
	echo "-L$(DESTLIB) -lnolibc -lm" > $(DESTLIB)/libs

uninstall: all
	rm -rf $(DESTINC)
	rm -rf $(DESTLIB)
	rm -f  $(DESTPKG)/ocaml-freestanding-nolibc.pc


clean:
	$(MAKE) -C openlibm clean
	$(MAKE) -C nolibc \
	    "FREESTANDING_CFLAGS=$(NOLIBC_CFLAGS)" \
	    "SYSDEP_OBJS=$(NOLIBC_SYSDEP_OBJS)" \
	    clean
	$(RM) Makeconf

.PHONY: all clean install uninstall 

include Makeconf

FREESTANDING_LIBS=openlibm/libopenlibm.a nolibc/libnolibc.a

all: $(FREESTANDING_LIBS) solo5-libc.pc 

Makeconf:
	./configure.sh

TOP=$(abspath .)
FREESTANDING_CFLAGS+=-I$(TOP)/nolibc/include -include _freestanding/overrides.h

openlibm/libopenlibm.a:
	$(MAKE) -C openlibm "CFLAGS=$(FREESTANDING_CFLAGS)" libopenlibm.a


NOLIBC_CFLAGS=$(FREESTANDING_CFLAGS) -I$(TOP)/openlibm/src -I$(TOP)/openlibm/include
nolibc/libnolibc.a:
	$(MAKE) -C nolibc \
	    "FREESTANDING_CFLAGS=$(NOLIBC_CFLAGS)" \
	    "SYSDEP_OBJS=$(NOLIBC_SYSDEP_OBJS)"

install: all
	./install.sh

uninstall: all
	./uninstall.sh

clean:
	$(MAKE) -C openlibm clean
	$(MAKE) -C nolibc \
	    "FREESTANDING_CFLAGS=$(NOLIBC_CFLAGS)" \
	    "SYSDEP_OBJS=$(NOLIBC_SYSDEP_OBJS)" \
	    clean
	$(RM) Makeconf

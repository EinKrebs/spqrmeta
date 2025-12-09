# configurable variables
PG_CONFIG = pg_config
RST2HTML = rst2html

# load version
include spqrmeta.control
EXT_VERSION = $(patsubst '%',%,$(default_version))
DISTNAME = spqrmeta-$(EXT_VERSION)

# module description
MODULE_big = spqrmeta
EXTENSION = $(MODULE_big)

DOCS = spqrmeta.html
EXTRA_CLEAN = spqrmeta.html

REGRESS_OPTS = --inputdir=test

# different vars for extension and plain module

Regress_noext = test_init_noext test_int8_murmur test_string_murmur test_string_city32 test_string_varlen_city32 test_int8_city32
Regress_ext   = test_init_ext   test_int8_murmur test_string_murmur test_string_city32 test_string_varlen_city32 test_int8_city32

Data_ext = sql/spqrmeta--1.0.sql

# Work around PGXS deficiencies - switch variables based on
# whether extensions are supported.
PgMajor = $(if $(MAJORVERSION),$(MAJORVERSION),15)
PgHaveExt = $(if $(filter 8.% 9.0,$(PgMajor)),ext)
DATA = $(Data_$(PgHaveExt))
REGRESS = $(Regress_$(PgHaveExt))


# launch PGXS
PGXS = $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)

install: $(DOCS)

test: install
	make installcheck || { filterdiff --format=unified regression.diffs | less; exit 1; }

ack:
	cp results/*.out test/expected/

tags:
	cscope -I . -b -f .cscope.out src/*.c

%.s: %.c
	$(CC) -S -fverbose-asm -o - $< $(CFLAGS) $(CPPFLAGS) | cleanasm > $@

html: spqrmeta.html

spqrmeta.html: README.rst
	$(RST2HTML) $< > $@

deb:
	rm -f debian/control
	make -f debian/rules debian/control
	debuild -uc -us -b

debclean: clean
	$(MAKE) -f debian/rules realclean
	rm -f lib* spqrmeta.so* spqrmeta.a
	rm -rf .deps

tgz:
	git archive --prefix=$(DISTNAME)/ HEAD | gzip -9 > $(DISTNAME).tar.gz


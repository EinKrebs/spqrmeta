# configurable variables
PG_CONFIG = pg_config
RST2HTML = rst2html

# load version
include spqrmeta.control
EXT_VERSION = $(patsubst '%',%,$(default_version))
DISTNAME = spqrmeta-$(EXT_VERSION)

# module description
EXTENSION = spqrmeta

DOCS = spqrmeta.html
EXTRA_CLEAN = spqrmeta.html
NO_INSTALL = true

# different vars for extension and plain module

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

html: spqrmeta.html

spqrmeta.html: README.rst
	$(RST2HTML) $< > $@

deb:
	rm -f debian/control
	make -f debian/rules debian/control
	debuild -uc -us -b

debclean: clean
	$(MAKE) -f debian/rules realclean
	rm -rf .deps

tgz:
	git archive --prefix=$(DISTNAME)/ HEAD | gzip -9 > $(DISTNAME).tar.gz


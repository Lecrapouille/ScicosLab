.PHONY: default byt bin binary all
.PHONY: contribs scilex-lib
.PHONY: clean distclean
.PHONY: man manclean tests
.PHONY: install postinstall uninstall autoinstall
.PHONY: cvsclean
.PHONY: tarbindist

default: bin

byt bin:
	@if test -f .binary; then \
		config/findpath; \
		(cd scripts; make); \
	else \
	   $(MAKE) all; \
	fi && \
	echo "Done"

#SCIDIR=.
include Path.incl
include Makefile.incl

all:: bin/scilex

contribs:
	cd contrib; $(MAKE) $(MFLAGS) all;

# Add the object files that are used to compile Scilex @JAVAC_PATH@ 
include Makefile.OBJ

include config/Makefile.linux

distclean::
	$(RM) bin/scilex

SUBDIRS = scripts macros imp intersci tcl examples contrib

scilex-lib::
	@case '${MFLAGS}' in *[ik]*) set +e;; esac; \
	cd routines; echo "making all in routines..."; \
		$(MAKE) $(MFLAGS) all;

scilex-lib::
	@cd pvm3; echo "making all in pvm3..."; $(MAKE) $(MFLAGS) "CC=$(CC)";


javasci_disabled::
	@cd routines/Javasci; echo "making all in routines/Javasci..."; $(MAKE) $(MFLAGS) ;

all::
	@case '${MFLAGS}' in *[ik]*) set +e;; esac; \
	for i in $(SUBDIRS) ;\
	do \
		(cd $$i ; echo "making all in $$i..."; \
			$(MAKE) $(MFLAGS) all); \
	done

all:: man

distclean::
	@case '${MFLAGS}' in *[ik]*) set +e;; esac; \
	for i in routines $(SUBDIRS) man;\
	do \
		(cd $$i ; echo "making distclean in $$i..."; \
			$(MAKE) $(MFLAGS)  distclean); \
	done

distclean::
	@cd pvm3; echo "making distclean in pvm3..."; \
	$(MAKE) $(MFLAGS) super_distclean;


distclean::
	@cd maple; echo "making distclean in maple..."; \
	$(MAKE) $(MFLAGS) distclean;

javasci_disabled::
	@cd routines/Javasci; echo "making distclean in routines/Javasci..."; \
	$(MAKE) $(MFLAGS) distclean;

clean::
	@case '${MFLAGS}' in *[ik]*) set +e;; esac; \
	for i in routines $(SUBDIRS) man;\
	do \
		(cd $$i ; echo "making clean in $$i..."; \
			$(MAKE) $(MFLAGS)  clean); \
	done

man::
	@case '${MFLAGS}' in *[ik]*) set +e;; esac; \
	for i in man;\
	do \
		(cd $$i ; echo "making man in $$i..."; \
			$(MAKE) $(MFLAGS) man); \
	done


manclean:
	@case '${MFLAGS}' in *[ik]*) set +e;; esac; \
	for i in man;\
	do \
		(cd $$i ; echo "making manclean in $$i..."; \
			$(MAKE) $(MFLAGS) manclean); \
	done

tests:
	@echo "Type \"make tests\" in $(SCIDIR)/tests directory "
	@echo "  to test the  distribution"

distclean::
	$(RM) config.cache config.log config.status .binary foo.f foo.o \
	conftest conftest.c so_locations


#-------------------------------------------------
# installation
# Scilab is installed in $(PREFIX)/lib/SCIBASE
# with links in $(PREFIX)/bin/
# PREFIX is set by in configure --prefix= option
# -----------------------------------------------

# SCIBASE for scilab binaries generation
SCIBASE=scicoslab-svn
PREFIX=/usr

INSTPVMBINDISTFILES = \
	pvm3/Readme \
	pvm3/lib/pvm \
	pvm3/lib/pvmd \
	pvm3/lib/pvmtmparch \
	pvm3/lib/pvmgetarch \
	pvm3/lib/LINUXX86_64/pvmd3 \
	pvm3/lib/LINUXX86_64/pvmgs \
	pvm3/lib/LINUXX86_64/pvm \
	pvm3/bin/LINUXX86_64/*

INSTBINDISTFILES = \
	.pvmd.conf \
	ACKNOWLEDGEMENTS \
	CHANGES \
	Makefile \
	Makefile.OBJ \
	Makefile.incl \
	Makemex \
	Path.incl \
	README_Unix \
	configure \
	libtool \
	license.txt \
	licence.txt \
	scilab.quit \
	scilab.star \
	X11_defaults \
	bin \
	libs \
	config \
	contrib \
	demos \
	examples \
	imp/NperiPos.ps \
	imp/giffonts \
	macros \
	man \
	maple \
	routines/*.h \
	routines/Make.lib \
	routines/default/FCreate \
	routines/default/Flist \
	routines/default/README \
	routines/default/fundef \
	routines/default/*.c \
	routines/default/*.f \
	routines/default/*.h \
	routines/f2c/*.h \
	routines/graphics/*.h \
	routines/interf/*.h \
	routines/intersci/sparse.h \
	routines/menusX/*.h \
	routines/scicos/*.h \
	routines/scicos/sundials/*.h \
	routines/scicos/sundials/LICENSE \
	routines/sparse/*.h \
	routines/os_specific/*.h \
	routines/xsci/*.h \
	scripts \
	tcl \
	util

DOCNAME=$(SCIBASE)

install:
	@echo "make a tar of files to be installed"
	@if test `pwd`/..  != $(PREFIX)/lib ; then \
	  install -d $(PREFIX)/lib/$(SCIBASE); \
	   ( for file in $(INSTBINDISTFILES) $(INSTPVMBINDISTFILES); do tar cf - --exclude=.svn $${file}  | (cd $(PREFIX)/lib/$(SCIBASE); tar xf -); done); \
	 fi
	@echo "tar file extracted in $(PREFIX)/lib/$(SCIBASE)"
	@echo "make postinstall with PREFIX=$(PREFIX) performed"
	@if test `pwd`/..  != $(PREFIX)/lib ; then \
	  (cd $(PREFIX)/lib/$(SCIBASE);touch .binary; make postinstall PREFIX=$(PREFIX) ) \
	fi
	@echo "postinstall done"
	@install -d $(PREFIX)/share/doc/$(DOCNAME)/
	@install ACKNOWLEDGEMENTS CHANGES README_Unix config/Version.incl \
		licence.txt license.txt  $(PREFIX)/share/doc/$(DOCNAME)
	@install -d $(PREFIX)/bin
	@$(RM)  $(PREFIX)/bin/scilab
	@ln -fs $(PREFIX)/lib/$(SCIBASE)/bin/scilab $(PREFIX)/bin/scilab
	@$(RM)  $(PREFIX)/bin/intersci
	@ln -fs $(PREFIX)/lib/$(SCIBASE)/bin/intersci $(PREFIX)/bin/intersci
	@$(RM)  $(PREFIX)/bin/intersci-n
	@ln -fs $(PREFIX)/lib/$(SCIBASE)/bin/intersci-n $(PREFIX)/bin/intersci-n
	@echo done

tarbindist:
	@echo -n "build $(SCIBASE)-bin.tar "
	@$(RM) -r /tmp/$(SCIBASE);
	@install -d /tmp/$(SCIBASE); \
		( for file in $(INSTBINDISTFILES) $(INSTPVMBINDISTFILES) $(INSTPVMBINDISTFILES1); do tar cf - --exclude=.svn $${file}  | (cd /tmp/$(SCIBASE); tar xf -); done); \
		(cd /tmp/$(SCIBASE);touch .binary;make postinstall PREFIX=/tmp/$(SCIBASE) DESTDIR="" > /dev/null )
	@echo -n "..."
	@strip /tmp/$(SCIBASE)/bin/scilex
	@cd /tmp/$(SCIBASE)/examples; make distclean > /dev/null
	@tar cf $(SCIBASE)-bin.tar -C /tmp/ $(SCIBASE)
	@echo "done"

# DESTDIR is the final destination of the file
# it can be different from $(PREFIX)/lib
# when we use package builders for rpm or deb files

DESTDIR=$(PREFIX)/lib

postinstall:
	@echo "creating Path.incl SCIDIR=$(DESTDIR)/$(SCIBASE)"
	@echo "SCIDIR=$(DESTDIR)/$(SCIBASE)"  > Path.incl
	@cd scripts; make  > /dev/null
	@cd examples ; make distclean > /dev/null
	@find man -name "*.xml" -print0 | xargs -0 $(RM)
	@strip bin/scilex;

uninstall:
	$(RM) -r $(PREFIX)/$(SCIBASE)
	$(RM) $(PREFIX)/bin/scilab
	$(RM) $(PREFIX)/bin/intersci
	$(RM) $(PREFIX)/bin/intersci-n

cvsclean::
	@$(RM) -f -r geci xless wless xmetanet routines/comm routines/libcomm
	@cd man; $(RM) -f -r arma comm control dcd elementary fileio functions graphics gui identification linear metanet nonlinear polynomials programming pvm robust scicos signal sound strings tdcs time-date tclsci translation utilities maxplus

# clean and run auto install
# windows stuffs

autoinstall:
	@$(RM) -f bin/Atlas.spec bin/dold bin/f77-linux bin/minfopr bin/scilink
	@$(RM) -f bin/scilex bin/translator bin/translator_mac bin/XML2Modelica
	@$(RM) -f bin/XML2Modelica_mac bin/zterm
	@\cp bin/cscilex.exe bin/scilex.exe
	@/home/jpc/.wine/drive_c/Program\ Files/Inno\ Setup\ 5/ISCC.exe scilab.iss

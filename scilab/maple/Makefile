SHELL = /bin/sh

include ../Makefile.incl

# If necessary, change the path of Maple below
MAPLE = maple
# If necessary, change the path of Scilab below
SCIDIR= /usr/local/lib/scilab

tests:
	$(MAPLE) < examples.mpl > examples.out
	$(SCIDIR)/util/scidem $(SCIDIR) examples.tst examples.dia

clean::
	$(RM) foo*.o foo*.lo libfoo* examples.out examples.dia loader.sce Makelib

distclean::
	$(RM) foo* examples.out examples.dia

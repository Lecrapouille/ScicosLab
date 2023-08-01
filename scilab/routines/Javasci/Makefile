#--------------------------------------------------------

SHELL = /bin/sh
SCIDIR=../..
SCIDIR1=..\..

LIBRARY= $(SCIDIR)/bin/libjavasci.@SONAME@

# include ../../Makefile.incl
# include ../../Makefile.OBJ

all:: class lib 

lib :
	$(MAKE) $(MFLAGS) -f Makelib 

class::	
	@cd classes;$(MAKE) $(MFLAGS) all;cd ..

clean::
	$(MAKE) $(MFLAGS) -f Makelib clean 

distclean::
	$(MAKE) $(MFLAGS) -f Makelib distclean 



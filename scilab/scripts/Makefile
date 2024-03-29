SHELL = /bin/sh

include ../Path.incl
include ../Makefile.incl

# it is important here to keep relative pathnames 
# for make install to work with package builders 

IP = ../Path.incl

SBIN = ../bin
UTIL = ../util

BPROGRAMS = $(SBIN)/Blatexpr $(SBIN)/Blatexpr2 \
	$(SBIN)/Blatexprs $(SBIN)/Blpr $(SBIN)/BEpsf \
	$(UTIL)/Blatdoc $(UTIL)/Blatdocs

PROGRAMS = $(SBIN)/scilab $(BPROGRAMS)

all:: $(PROGRAMS)

CYGDRIVE= -e "s+/cygdrive/\([a-zA-Z]*\)/+\1:/+g" 
SED_CYGDRIVE= 

$(SBIN)/scilab: scilab-gtk.g $(IP) 
	@$(RM) $(SBIN)/scilab
	@sed -e "s+SCILAB_DIRECTORY+$(SCIDIR)+" $(SED_CYGDRIVE) \
	-e "s+SCILABGS+sh+" scilab-gtk.g > scilab;
	@cp scilab $(SBIN)
	@chmod 775 $(SBIN)/scilab
	@$(RM) scilab
	@echo $(SBIN)/scilab created


$(SBIN)/Blatexpr: Blatexpr.g $(IP)
	@$(RM) $(SBIN)/Blatexpr
	@sed -e "s+SCILAB_DIRECTORY+$(SCIDIR)+" Blatexpr.g > Blatexpr;
	@cp Blatexpr $(SBIN)
	@chmod 775 $(SBIN)/Blatexpr
	@$(RM) Blatexpr
	@echo $(SBIN)/Blatexpr created

$(SBIN)/BEpsf: BEpsf.g $(IP)
	@$(RM) $(SBIN)/BEpsf
	@sed -e "s+SCILAB_DIRECTORY+$(SCIDIR)+" BEpsf.g > BEpsf;
	@cp BEpsf $(SBIN)
	@chmod 775 $(SBIN)/BEpsf
	@$(RM) BEpsf
	@echo $(SBIN)/BEpsf created

$(SBIN)/Blatexpr2: Blatexpr2.g $(IP)
	@$(RM) $(SBIN)/Blatexpr2
	@sed -e "s+SCILAB_DIRECTORY+$(SCIDIR)+" Blatexpr2.g > Blatexpr2;
	@cp Blatexpr2 $(SBIN)
	@chmod 775 $(SBIN)/Blatexpr2
	@$(RM) Blatexpr2
	@echo $(SBIN)/Blatexpr2 created

$(SBIN)/Blatexprs: Blatexprs.g $(IP)
	@$(RM) $(SBIN)/Blatexprs
	@sed -e "s+SCILAB_DIRECTORY+$(SCIDIR)+" Blatexprs.g > Blatexprs;
	@cp Blatexprs $(SBIN)
	@chmod 775 $(SBIN)/Blatexprs
	@$(RM) Blatexprs
	@echo $(SBIN)/Blatexprs created

$(SBIN)/Blpr: Blpr.g $(IP)
	@$(RM) $(SBIN)/Blpr
	@sed -e "s+SCILAB_DIRECTORY+$(SCIDIR)+" Blpr.g > Blpr;
	@cp Blpr $(SBIN)
	@chmod 775 $(SBIN)/Blpr
	@$(RM) Blpr
	@echo $(SBIN)/Blpr created

$(UTIL)/Blatdoc: Blatdoc.g $(IP)
	@$(RM) $(UTIL)/Blatdoc
	@sed -e "s+SCILAB_DIRECTORY+$(SCIDIR)+" Blatdoc.g > Blatdoc;
	@cp Blatdoc $(UTIL)
	@chmod 775 $(UTIL)/Blatdoc
	@$(RM) Blatdoc
	@echo $(UTIL)/Blatdoc created

$(UTIL)/Blatdocs: Blatdocs.g $(IP)
	@$(RM) $(UTIL)/Blatdocs
	@sed -e "s+SCILAB_DIRECTORY+$(SCIDIR)+" Blatdocs.g > Blatdocs;
	@cp Blatdocs $(UTIL)
	@chmod 775 $(UTIL)/Blatdocs
	@$(RM) Blatdocs
	@echo $(UTIL)/Blatdocs created

distclean::
	@$(RM) $(PROGRAMS) 

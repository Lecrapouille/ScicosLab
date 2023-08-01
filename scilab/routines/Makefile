SHELL = /bin/sh

include ../Makefile.incl

SCIDIRS = graphics calelm blas  control default integ interf intersci \
	lapack slicot arpack \
	metanet optim poly signal sparse os_specific system system2 console\
	menusX scicos fileio dcd randlib slicot arpack wintools\
	gd int maxplus gtksci  tclsci pvm gzvt2 \
        expatsci


SUBDIRS = $(XAW_LOCAL_SUBDIR) $(DLD_SUBDIR) $(SCIDIRS) 

all clean distclean f2cclean ::
	@case '${MFLAGS}' in *[ik]*) set +e;; esac; \
	for i in $(SUBDIRS) ;\
	do \
		(cd $$i && echo "making $@ in src/$$i " && \
		$(MAKE) $(MFLAGS) $@ ); \
	   	IER=$$? &&\
	   	case $$IER in\
	    	0) ;;\
	    	*) echo "Cannot make $@ in sub directory $$d";\
	       	  exit $$IER;;\
	   	esac;\
	done

distclean::
	@case '${MFLAGS}' in *[ik]*) set +e;; esac; \
	for i in X11 dld ;\
	do \
		(cd $$i ; echo "making distclean in routines/$$i..."; \
		$(MAKE) $(MFLAGS)  distclean); \
	done

######################################################################
#                                                                    #
#                           ScicosLab                                #
#                                                                    #
#          Pierre Weis, INRIA Rocquencourt                           #
#                                                                    #
#  Copyright 2010-2011,                                              #
#  Institut National de Recherche en Informatique et en Automatique. #
#  All rights reserved.                                              #
#                                                                    #
#  This file is distributed under the terms of the Q Public License. #
#                                                                    #
######################################################################

# $Id: Caml.mk 4782 2012-02-29 16:32:11Z weis $

# This Makefile defines generic rules to compile various kinds of Caml source
# files and to automatically handle their dependencies.

# This Makefile also defines two entries:
# - clean (to clean up the compiled files)
# - depend (to recompute the dependency order).

# This Makefile should be included at the end of the Makefile that handles a
# set of Caml files (to build a library or an application).
# Simpy write at the end of your Makefile:
# include path_to_Caml.mk/Caml.mk

.PHONY: default all bin byt clean clean-all clean-spurious configure depend test

# Main targets
all: byt bin

# Generic clean up
EXT_TO_CLEAN=.cm* .o .a .annot .output .obj .lib

clean::
	@for EXT in $(EXT_TO_CLEAN); do\
	  find . -name "*$$EXT" -exec $(RM) "{}" \; ;\
	done

SPURIOUS_EXT_TO_CLEAN=*~ .*~ a.out .\#*

clean-spurious:
	@for EXT in $(SPURIOUS_EXT_TO_CLEAN); do\
	  find . -name "$$EXT" -exec $(RM) "{}" \; ;\
	done

clean-all::
	$(MAKE) clean &&\
	$(MAKE) clean-spurious &&\
	$(RM) $(CAML_GENERATED_FILES) &&\
	$(MAKE) depend

configure:: cleandir

# Rebuilding dependencies
depend:: $(CAML_FILES)
	$(CAML_DEP) $(CAML_INCLUDES) $(CAML_FILES) > .depend

# Compilation rules
.SUFFIXES:
.SUFFIXES: .cmx .cmxa .cmo .cmi .cma .ml .mli .mll .mly .mlin .mliin

.ml.cmo:
	$(CAML_BYT) -c $<
.mli.cmi:
	$(CAML_BYT) -c $<

.ml.cmx:
	$(CAML_BIN) -c $<

.mll.ml:
	$(CAML_LEX) $<

.mly.ml:
	$(CAML_YAC) $<

.mly.mli:
	$(CAML_YAC) $<

.mlin.ml:
	$(RM) $@ &&\
	$(HTMLCCONF) -i $< -o $@

.mliin.mli:
	$(RM) $@ &&\
	$(HTMLCCONF) -i $< -o $@

include .depend

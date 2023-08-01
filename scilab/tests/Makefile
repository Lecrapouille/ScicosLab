SHELL=/bin/sh
SCIDIR=..
.SUFFIXES: .dia .tst .vl

include $(SCIDIR)/Makefile.incl

all:: info

info:
	@echo "Type \"make tests\" in tests directory"
	@echo "  to test the  distribution"
	@echo " SEE THE README FILE (IMPORTANT) "

tests:
	$(SCIDIR)/bin/scilab -nwni -nb -f maketests.sce

clean ::
	@echo "Cleaning in tests"
	@$(RM) *.dia tmp.* get_examples.log *.graph so_locations
	@$(RM) foo* test.wav one_man.tst test_macro_exec asave results *.bin
	@$(RM) -r .libs libintertest.o libintertest.s* libintertest.la
	@$(RM) -r *.so *.la libintertest.lo addinter.o addinter.lo
	@$(RM) -f externals.o

distclean:: clean

FFLAGS = $(FC_OPTIONS) $(FC_PICFLAGS)

OBJSF = externals.o

linktest : $(OBJSF)

externals.o: externals.f
	$(FC) $(FFLAGS) -c externals.f  -o externals.o

TESTS= algebra.dia arma.dia  auto.dia    basiclink.dia \
	   binary.dia  breakpoints.dia    bvode.dia \
	   call.dia    calpol.dia    clause.dia    cmp.dia \
	   comand.dia    comment.dia    dassldasrt.dia \
	   date.dia    dcd.dia    display.dia    errcatch.dia \
	   feval.dia    fptr.dia \
	   fscanfMat.dia    function.dia    global.dia \
	   grand.dia    grandb.dia    gsort.dia    hypermat.dia\
	   intops.dia     listextraction.dia \
	   listinsertion.dia    lsparse.dia    lstops.dia \
	   lstops.dia    macro.dia    matelm.dia    matimp.dia \
	   matode.dia    matops.dia    matopt.dia    matsys.dia \
	   maxi.dia    metanet.dia    mfprintf.dia    mfscanf.dia \
	   msprintf.dia    msscanf.dia    norm.dia \
	   odedc.dia    odedi.dia    opcode.dia    pause.dia \
	   polelm.dia    polops.dia    pvm.dia \
	   resume.dia    saveload.dia    scicos.dia  scilab.dia \
	   slicot.dia    sound.dia    sparse.dia  specfun.dia \
	   sprintf.dia    sscanf.dia    strelm.dia \
	   trycatch.dia   parse.dia    TCL_SetGet.dia \
	   filesassocation.dia    isequalbitwise.dia

# enable independant run tests -j can be used here

tests-indep: $(TESTS)

.tst.dia:
	@echo "running test $<  "
	@$(SCIDIR)/bin/scilab -nwni -nb -e "scitest('$<',%f,%t);quit"


.tst.vl :
	@echo -n "valgrind $*: "
	@setenv G_DEBUG gc-friendly; setenv G_SLICE always-malloc;valgrind \
		--suppressions=valgrind.supp --leak-check=full \
		../bin/scilex -nw -e "exec('$*.tst');quit" >& $*.vl
	@echo  " $*.vl"

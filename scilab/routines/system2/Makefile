SHELL = /bin/sh

SCIDIR=../..
SCIDIR1=..\..

LIBRARY = $(SCIDIR)/libs/system2.a

OBJSC = intmacr2tree.o 

OBJSF = fmttyp.o formatnumber.o getfun.o chkvar.o\
	btof.o btofm.o ftob.o \
	bschur.o bjac.o bintg.o bj2.o bydot.o boptim.o bgety.o bgetx.o \
	badd.o bresid.o bfeval.o bresd.o bjacd.o \
	cvwm.o cvdm.o atome.o iseye.o \
	matz.o matc.o matzs.o \
	expsum.o termf.o bsurf.o bsurfd.o tradsl.o \
	dldsp.o istrue.o isnum.o namstr.o basnms.o cmplxt.o \
	intstr.o extlarg.o bcol.o bsolv.o bjsolv.o \
	blsqrsolv.o bjlsqrsolv.o \
	bydot2.o bint2d.o bint3d.o testformat.o formatbug.o

include ../../Makefile.incl

CFLAGS = $(CC_OPTIONS)
FFLAGS = $(FC_OPTIONS)

include ../Make.lib

badd.o: ../stack.h ../callinter.h
bcol.o: ../stack.h ../callinter.h
bfeval.o: ../stack.h ../callinter.h
bgetx.o: ../stack.h ../callinter.h
bgety.o: ../stack.h ../callinter.h
bint2d.o: ../stack.h ../callinter.h
bint3d.o: ../stack.h ../callinter.h
bintg.o: ../stack.h ../callinter.h
bj2.o: ../stack.h ../callinter.h
bjac.o: ../stack.h ../callinter.h
bjacd.o: ../stack.h ../callinter.h
bjlsqrsolv.o: ../stack.h ../callinter.h
bjsolv.o: ../stack.h ../callinter.h
blsqrsolv.o: ../stack.h ../callinter.h
boptim.o: ../stack.h ../callinter.h
bresd.o: ../stack.h ../callinter.h
bresid.o: ../stack.h ../callinter.h
bschur.o: ../stack.h ../callinter.h
bsolv.o: ../stack.h ../callinter.h
bsurf.o: ../stack.h ../callinter.h
bsurfd.o: ../stack.h ../callinter.h
btof.o: ../stack.h
btofm.o: ../stack.h
bydot.o: ../stack.h ../callinter.h
bydot2.o: ../stack.h ../callinter.h
extlarg.o: ../stack.h
ftob.o: ../stack.h
getfun.o: ../stack.h
istrue.o: ../stack.h
matc.o: ../stack.h
matz.o: ../stack.h
matzs.o: ../stack.h
namstr.o: ../stack.h
rwstack.o: ../stack.h
tradsl.o: ../stack.h
intmacr2tree.o: ../stack-c.h

formatnumber.o : formatnumber.f 
	@echo "compiling $<  Wall (no optimize)"
	@$(FC) $(FC_OPTIONS1) -c formatnumber.f -o formatnumber.o


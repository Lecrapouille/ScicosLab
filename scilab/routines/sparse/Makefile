SHELL = /bin/sh

SCIDIR=../..
SCIDIR1=..\..

LIBRARY = $(SCIDIR)/libs/sparse.a


OBJSC = lu.o spBuild.o spFortran.o spSolve.o spAllocate.o spFactor.o \
	spOutput.o spUtils.o mspelm.o

OBJSF = lspops.o spelm.o spops.o \
	dperm.o iperm.o  dspasp.o dspssp.o \
	wspasp.o wspssp.o isort1.o dspmsp.o wspmsp.o \
	dspms.o dsmsp.o wspms.o wsmsp.o dspt.o wspt.o \
	dspxsp.o wspxsp.o dspxs.o wspxs.o dspe2.o wspe2.o \
	dspcle.o wspcle.o dspisp.o  dspis.o wspisp.o wspis.o\
	dsposp.o dspos.o dsosp.o wsposp.o wspos.o wsosp.o \
	sz2ptr.o findl.o dcompa.o wcompa.o lcompa.o\
	dspcsp.o wspcsp.o \
	lspt.o lspcsp.o lspe2.o lspisp.o lspis.o lsosp.o lspos.o \
	lsposp.o lspasp.o lspxsp.o\
	dful2sp.o wful2sp.o lful2sp.o dspful.o wspful.o lspful.o \
	dij2sp.o wij2sp.o lij2sp.o dspmax.o dspmin.o \
	dspmat.o wspmat.o lspmat.o sp2col.o spsort.o spord.o wperm.o \
	spcho1.o spcho2.o blkslv.o blkfct.o inpnv.o symfct.o ordmmd.o \
	blkfc1.o spind.o spcompack.o \
	intreadmps.o rdmps1.o rdmpsz.o spreshape.o spt.o spextr.o spextr1.o \
	spif.o spifp.o sputil.o spif1b.o spisp.o

OBJS =  $(OBJSF) $(OBJSC)

include ../../Makefile.incl

CFLAGS = $(CC_OPTIONS)
FFLAGS = $(FC_OPTIONS)

include ../Make.lib

lu.o: lu.c spConfig.h spmatrix.h spDefs.h ../machine.h
mspelm.o: mspelm.c ../stack-c.h ../graphics/Math.h ../machine.h \
	../graphics/Graphics.h ../stack-def.h ../interf/stack1.h \
	../interf/stack2.h ../interf/stack3.h ../calelm/calelm.h
spAllocate.o: spAllocate.c spConfig.h spmatrix.h spDefs.h
spBuild.o: spBuild.c spConfig.h spmatrix.h spDefs.h
spFactor.o: spFactor.c spConfig.h spmatrix.h spDefs.h
spFortran.o: spFortran.c spConfig.h spmatrix.h spDefs.h ../machine.h
spOutput.o: spOutput.c spConfig.h spmatrix.h spDefs.h
spSolve.o: spSolve.c spConfig.h spmatrix.h spDefs.h
spUtils.o: spUtils.c spConfig.h spmatrix.h spDefs.h

lspops.o:      ../stack.h
spelm.o:      ../stack.h
spops.o:       ../stack.h
rdmps1.o: ../stack.h


# according to compiler, do not optimize the following files

intreadmps.o: intreadmps.f
	@echo "compiling $<  Wall (no optimize)"
	@$(FC) $(FC_OPTIONS1) -c intreadmps.f -o intreadmps.o


#
# Id: Makefile,v 1.1.1.1 2004/04/26 15:36:59 stochopt Exp $
#

PVMDIR		=	$(PVM_ROOT)

#CC			=	cc
#CFLOPTS	=	-g

PVMOPTS		=	CC=$(CC) CFLOPTS=$(CFLOPTS) PVMDIR=$(PVMDIR)

default: local

install:
	$(PVMDIR)/lib/aimk $(PVMOPTS) install
	@ ctags -w *.c *.h &

local:
	$(PVMDIR)/lib/aimk $(PVMOPTS) local
	@ ctags -w *.c *.h &

objs:
	$(PVMDIR)/lib/aimk $(PVMOPTS) objs

again:
	$(PVMDIR)/lib/aimk $(PVMOPTS) again

clean:
	$(PVMDIR)/lib/aimk clean

veryclean:
	$(PVMDIR)/lib/aimk veryclean


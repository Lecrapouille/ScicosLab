SHELL = /bin/sh
SCIDIR=../..

LIBRARY = $(SCIDIR)/libs/graphics.a

OBJSC = periGtk.o periPos.o periFig.o  periGif.o Xcall.o Xcall1.o \
	GetProperty.o BuildObjects.o CloneObjects.o DestroyObjects.o \
	DrawObjects.o SetProperty.o HandleManagement.o InitObjects.o \
	Interaction.o Contour.o Plo3d.o Math.o Axes.o Champ.o Plo2d.o \
	Plo2d1.o Plo2d2.o Plo2d3.o Plo2d4.o Plo2dEch.o Rec.o Gray.o \
	Alloc.o FeC.o RecLoad.o RecSave.o Tests.o Actions.o Events.o\
	gsort.o qsort.o nues1.o Format.o w_rottext.o\
	dr1Call.o sciCall.o Plo2dn.o Plo3dn.o

OBJSF = 

include ../../Makefile.incl

CFLAGS = $(CC_OPTIONS) $(XFLAGS) $(TK_INC_PATH) $(TCL_INC_PATH) 
CFLAGS1 = $(CC_OPTIONS1) $(XFLAGS) $(TK_INC_PATH) $(TCL_INC_PATH) 
FFLAGS = $(FC_OPTIONS)

include ../Make.lib

# with gcc compiler, do not inline "floor" function in "Format.c"

Format.o: Format.c
	@echo "compiling $<  Wall "	
	@$(CC) $(CFLAGS)  -c $< -o $@

# do not optimize periX11.c on darwin

periX11darwin.o: periX11darwin.c
	@echo "compiling $<  Wall "
	@$(CC) $(CFLAGS1) -c $< -o $@

#--- dependencies generated with gcc -MM  ----
Actions.o: Actions.c Math.h ../machine.h ../config.h \
 ../os_specific/sci_mem_alloc.h Graphics.h GetProperty.h \
 ObjectStructure.h ../wsci/wgnuplib.h HandleManagement.h SetProperty.h \
 DrawObjects.h ../sparse/spConfig.h bcg.h PloEch.h
Alloc.o: Alloc.c Math.h ../machine.h ../config.h \
 ../os_specific/sci_mem_alloc.h Graphics.h ../os_specific/win_mem_alloc.h
Axes.o: Axes.c Math.h ../machine.h ../config.h \
 ../os_specific/sci_mem_alloc.h Graphics.h PloEch.h \
 ../os_specific/win_mem_alloc.h GetProperty.h ObjectStructure.h \
 ../wsci/wgnuplib.h HandleManagement.h DrawObjects.h ../sparse/spConfig.h \
 bcg.h
BuildObjects.o: BuildObjects.c Math.h ../machine.h ../config.h \
 ../os_specific/sci_mem_alloc.h Graphics.h BuildObjects.h \
 ObjectStructure.h ../wsci/wgnuplib.h HandleManagement.h GetProperty.h \
 InitObjects.h DestroyObjects.h bcg.h SetProperty.h \
 ../os_specific/win_mem_alloc.h
Champ.o: Champ.c Math.h ../machine.h ../config.h \
 ../os_specific/sci_mem_alloc.h Graphics.h PloEch.h GetProperty.h \
 ObjectStructure.h ../wsci/wgnuplib.h HandleManagement.h SetProperty.h \
 DrawObjects.h ../sparse/spConfig.h bcg.h BuildObjects.h \
 ../os_specific/win_mem_alloc.h
CloneObjects.o: CloneObjects.c CloneObjects.h ObjectStructure.h \
 ../wsci/wgnuplib.h Math.h ../machine.h ../config.h \
 ../os_specific/sci_mem_alloc.h Graphics.h HandleManagement.h \
 GetProperty.h BuildObjects.h bcg.h SetProperty.h \
 ../os_specific/win_mem_alloc.h
Contour.o: Contour.c Math.h ../machine.h ../config.h \
 ../os_specific/sci_mem_alloc.h Graphics.h PloEch.h GetProperty.h \
 ObjectStructure.h ../wsci/wgnuplib.h HandleManagement.h
DestroyObjects.o: DestroyObjects.c DestroyObjects.h ObjectStructure.h \
 ../wsci/wgnuplib.h Math.h ../machine.h ../config.h \
 ../os_specific/sci_mem_alloc.h Graphics.h HandleManagement.h \
 GetProperty.h DrawObjects.h ../sparse/spConfig.h bcg.h PloEch.h \
 SetProperty.h Interaction.h ../os_specific/win_mem_alloc.h
dr1Call.o: dr1Call.c Math.h ../machine.h ../config.h \
 ../os_specific/sci_mem_alloc.h Graphics.h
DrawObjects.o: DrawObjects.c DrawObjects.h ObjectStructure.h \
 ../wsci/wgnuplib.h Math.h ../machine.h ../config.h \
 ../os_specific/sci_mem_alloc.h Graphics.h HandleManagement.h \
 ../sparse/spConfig.h bcg.h PloEch.h GetProperty.h SetProperty.h \
 BuildObjects.h DestroyObjects.h ../os_specific/win_mem_alloc.h
Events.o: Events.c bcg.h ../machine.h ../config.h ObjectStructure.h \
 ../wsci/wgnuplib.h Math.h ../os_specific/sci_mem_alloc.h Graphics.h \
 Events.h
FeC.o: FeC.c Math.h ../machine.h ../config.h \
 ../os_specific/sci_mem_alloc.h Graphics.h GetProperty.h \
 ObjectStructure.h ../wsci/wgnuplib.h HandleManagement.h SetProperty.h \
 BuildObjects.h DrawObjects.h ../sparse/spConfig.h bcg.h PloEch.h
Format.o: Format.c Math.h ../machine.h ../config.h \
 ../os_specific/sci_mem_alloc.h Graphics.h
GetProperty.o: GetProperty.c Math.h ../machine.h ../config.h \
 ../os_specific/sci_mem_alloc.h Graphics.h GetProperty.h \
 ObjectStructure.h ../wsci/wgnuplib.h HandleManagement.h bcg.h \
 BuildObjects.h SetProperty.h DrawObjects.h ../sparse/spConfig.h PloEch.h \
 ../os_specific/win_mem_alloc.h
Gray.o: Gray.c Math.h ../machine.h ../config.h \
 ../os_specific/sci_mem_alloc.h Graphics.h PloEch.h GetProperty.h \
 ObjectStructure.h ../wsci/wgnuplib.h HandleManagement.h SetProperty.h \
 DrawObjects.h ../sparse/spConfig.h bcg.h BuildObjects.h \
 ../os_specific/win_mem_alloc.h
gsort.o: gsort.c Math.h ../machine.h ../config.h \
 ../os_specific/sci_mem_alloc.h Graphics.h ../os_specific/men_Sutils.h \
 ../os_specific/../machine.h
HandleManagement.o: HandleManagement.c HandleManagement.h \
 ObjectStructure.h ../wsci/wgnuplib.h Math.h ../machine.h ../config.h \
 ../os_specific/sci_mem_alloc.h Graphics.h GetProperty.h bcg.h \
 ../os_specific/win_mem_alloc.h
InitObjects.o: InitObjects.c InitObjects.h ObjectStructure.h \
 ../wsci/wgnuplib.h Math.h ../machine.h ../config.h \
 ../os_specific/sci_mem_alloc.h Graphics.h HandleManagement.h \
 SetProperty.h GetProperty.h bcg.h PloEch.h \
 ../os_specific/win_mem_alloc.h
Interaction.o: Interaction.c Interaction.h ObjectStructure.h \
 ../wsci/wgnuplib.h Math.h ../machine.h ../config.h \
 ../os_specific/sci_mem_alloc.h Graphics.h HandleManagement.h \
 SetProperty.h GetProperty.h DrawObjects.h ../sparse/spConfig.h bcg.h \
 PloEch.h ../stack-c.h ../graphics/Math.h ../stack-def.h ../machine.h \
 ../interf/stack1.h ../interf/stack2.h ../interf/stack3.h \
 ../os_specific/win_mem_alloc.h
Math.o: Math.c Math.h ../machine.h ../config.h \
 ../os_specific/sci_mem_alloc.h Graphics.h ../sparse/spConfig.h
nues1.o: nues1.c ../machine.h ../config.h Math.h \
 ../os_specific/sci_mem_alloc.h Graphics.h
periFig.o: periFig.c ../machine.h ../config.h Math.h \
 ../os_specific/sci_mem_alloc.h Graphics.h periFig.h color.h bcg.h \
 ObjectStructure.h ../wsci/wgnuplib.h ../os_specific/win_mem_alloc.h
periGif.o: periGif.c ../os_specific/win_mem_alloc.h Math.h ../machine.h \
 ../config.h ../os_specific/sci_mem_alloc.h Graphics.h periGif.h color.h \
 ../gd/gd.h ../gd/../machine.h bcg.h ObjectStructure.h ../wsci/wgnuplib.h
periPos.o: periPos.c ../machine.h ../config.h Math.h \
 ../os_specific/sci_mem_alloc.h Graphics.h periPos.h color.h bcg.h \
 ObjectStructure.h ../wsci/wgnuplib.h ../os_specific/win_mem_alloc.h
periWin.o: periWin.c ../wsci/wresource.h ../wsci/resource.h \
 ../wsci/wcommon.h ../wsci/../graphics/Math.h \
 ../wsci/../graphics/../machine.h ../wsci/../graphics/../config.h \
 ../wsci/../graphics/../os_specific/sci_mem_alloc.h \
 ../wsci/../graphics/Graphics.h ../wsci/../graphics/bcg.h \
 ../wsci/../graphics/ObjectStructure.h \
 ../wsci/../graphics/../wsci/wgnuplib.h ../wsci/../graphics/Math.h \
 ../wsci/wgraph.h ../wsci/../version.h ../wsci/../config.h \
 ../wsci/wresource.h ../wsci/wcommon.h ../wsci/../graphics/scigraphic.h \
 ../wsci/../graphics/../graphics/bcg.h ../wsci/../graphics/Graphics.h \
 ../wsci/../graphics/DestroyObjects.h \
 ../wsci/../graphics/HandleManagement.h ../wsci/../graphics/GetProperty.h \
 ../wsci/../graphics/DrawObjects.h \
 ../wsci/../graphics/../sparse/spConfig.h ../wsci/../graphics/bcg.h \
 ../wsci/../graphics/PloEch.h ../wsci/Events.h ../wsci/wtext.h \
 ../wsci/resource.h Events.h bcg.h periWin.h ../version.h color.h \
 Graphics.h scigraphic.h ../machine.h ../wsci/GetOS.h \
 ../os_specific/win_mem_alloc.h
Plo2d1.o: Plo2d1.c Math.h ../machine.h ../config.h \
 ../os_specific/sci_mem_alloc.h Graphics.h PloEch.h
Plo2d2.o: Plo2d2.c Math.h ../machine.h ../config.h \
 ../os_specific/sci_mem_alloc.h Graphics.h PloEch.h
Plo2d3.o: Plo2d3.c Math.h ../machine.h ../config.h \
 ../os_specific/sci_mem_alloc.h Graphics.h PloEch.h GetProperty.h \
 ObjectStructure.h ../wsci/wgnuplib.h HandleManagement.h
Plo2d4.o: Plo2d4.c Math.h ../machine.h ../config.h \
 ../os_specific/sci_mem_alloc.h Graphics.h PloEch.h
Plo2d.o: Plo2d.c Math.h ../machine.h ../config.h \
 ../os_specific/sci_mem_alloc.h Graphics.h PloEch.h ../sparse/spConfig.h \
 GetProperty.h ObjectStructure.h ../wsci/wgnuplib.h HandleManagement.h \
 DrawObjects.h bcg.h ../os_specific/win_mem_alloc.h
Plo2dEch.o: Plo2dEch.c Math.h ../machine.h ../config.h \
 ../os_specific/sci_mem_alloc.h Graphics.h PloEch.h GetProperty.h \
 ObjectStructure.h ../wsci/wgnuplib.h HandleManagement.h SetProperty.h \
 BuildObjects.h Interaction.h DrawObjects.h ../sparse/spConfig.h bcg.h \
 ../os_specific/win_mem_alloc.h
Plo2dn.o: Plo2dn.c Math.h ../machine.h ../config.h \
 ../os_specific/sci_mem_alloc.h Graphics.h PloEch.h ../sparse/spConfig.h \
 SetProperty.h ObjectStructure.h ../wsci/wgnuplib.h HandleManagement.h \
 GetProperty.h InitObjects.h DrawObjects.h bcg.h BuildObjects.h \
 ../os_specific/win_mem_alloc.h
Plo3d.o: Plo3d.c Math.h ../machine.h ../config.h \
 ../os_specific/sci_mem_alloc.h Graphics.h PloEch.h GetProperty.h \
 ObjectStructure.h ../wsci/wgnuplib.h HandleManagement.h SetProperty.h \
 DrawObjects.h ../sparse/spConfig.h bcg.h ../os_specific/win_mem_alloc.h
Plo3dn.o: Plo3dn.c Math.h ../machine.h ../config.h \
 ../os_specific/sci_mem_alloc.h Graphics.h PloEch.h SetProperty.h \
 ObjectStructure.h ../wsci/wgnuplib.h HandleManagement.h GetProperty.h \
 InitObjects.h DrawObjects.h ../sparse/spConfig.h bcg.h BuildObjects.h \
 ../os_specific/win_mem_alloc.h
qsort.o: qsort.c ../machine.h ../config.h qsort-int.c qsort-double.c \
 qsort-string.c
Rec.o: Rec.c Math.h ../machine.h ../config.h \
 ../os_specific/sci_mem_alloc.h Graphics.h Rec.h PloEch.h \
 ../os_specific/win_mem_alloc.h
RecLoad.o: RecLoad.c ../xdr/rpc/types.h ../xdr/rpc/xdr.h Math.h \
 ../machine.h ../config.h ../os_specific/sci_mem_alloc.h Graphics.h Rec.h \
 ../os_specific/win_mem_alloc.h
RecSave.o: RecSave.c Math.h ../machine.h ../config.h \
 ../os_specific/sci_mem_alloc.h Graphics.h Rec.h ../xdr/rpc/types.h \
 ../xdr/rpc/xdr.h
sciCall.o: sciCall.c SetProperty.h ObjectStructure.h ../wsci/wgnuplib.h \
 Math.h ../machine.h ../config.h ../os_specific/sci_mem_alloc.h \
 Graphics.h HandleManagement.h GetProperty.h DrawObjects.h \
 ../sparse/spConfig.h bcg.h PloEch.h BuildObjects.h InitObjects.h \
 ../os_specific/win_mem_alloc.h
SetProperty.o: SetProperty.c SetProperty.h ObjectStructure.h \
 ../wsci/wgnuplib.h Math.h ../machine.h ../config.h \
 ../os_specific/sci_mem_alloc.h Graphics.h HandleManagement.h \
 GetProperty.h InitObjects.h bcg.h DrawObjects.h ../sparse/spConfig.h \
 PloEch.h BuildObjects.h ../os_specific/win_mem_alloc.h
Tests.o: Tests.c Math.h ../machine.h ../config.h \
 ../os_specific/sci_mem_alloc.h Graphics.h
w_rottext.o: w_rottext.c
Xcall1.o: Xcall1.c ObjectStructure.h ../wsci/wgnuplib.h Math.h \
 ../machine.h ../config.h ../os_specific/sci_mem_alloc.h Graphics.h \
 GetProperty.h HandleManagement.h SetProperty.h \
 ../os_specific/win_mem_alloc.h PloEch.h
Xcall.o: Xcall.c Math.h ../machine.h ../config.h \
 ../os_specific/sci_mem_alloc.h Graphics.h periWin.h periPos.h periFig.h \
 periGif.h

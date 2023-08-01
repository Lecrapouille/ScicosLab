SHELL = /bin/sh
SCIDIR=../..
SCIDIR1=..\..

LIBRARY = $(SCIDIR)/libs/wsci.a

OBJSC1 = printf.o FilesAssociations.o GetOS.o SciEnv.o WinConsole.o \
	DDE.o interfdde.o registry.o FindScilab.o clipboard.o wmcopydata.o \
	wtext.o wmenu.o wprinter.o wgraph.o winmain.o \
	wgmenu.o wstatbar.o gvwprn.o wmprint.o wmtex.o

OBJSC2 =readwin.o wtloop.o misc.o \
	command.o readcons.o x_zzledt.o ScilabXloop.o \
	ihmcolor.o TextToPrint.o FigureToPrint.o \
	TextWindows.o Toolbar.o GraphWindows.o MenuWindows.o \
	FilesAssociationBox.o AboutBox.o Splashscreen.o MessageBoxNewGraphicMode.o \
	WndParentGraphProc.o WndGraphProc.o WndConsoleParentProc.o WndConsoleTextProc.o \
	Transparency.o DragnDrop.o KeyEvents.o MouseEvents.o Events.o ExportBmpEmf.o \
	FigureToFile.o ExportBox.o CriticalSectionGraphicWindow.o

OBJSC = $(OBJSC1) $(OBJSC2)
OBJSF =

include ../../Makefile.incl

CFLAGS = $(CC_OPTIONS)
FFLAGS = $(FC_OPTIONS)

include ../Make.lib

RESOURCES= Rscilab.o

all	:: $(RESOURCES)

all	:: cscilex.o wscilex.o

Rscilab.o: Rscilab-ming.rc wresource.h
	@echo ressource compilation $*.o
	@$(RC) Rscilab-ming.rc Rscilab.o

#=================== lpr ===========================

all:: ../../bin/lpr.exe

../../bin/lpr.exe 	: lpr.o
	@echo Creation of $@
	@$(CC) -mconsole -o $@  lpr.o  $(RESOURCES)

lpr.o : gvwprn.c

#==================== dumpext =========================

all:: ../../bin/dumpexts.exe

../../bin/dumpexts.exe 	:  winDumpExts.o
	@echo Creation of $@
	@$(CC) -mconsole -o $@  winDumpExts.o

#==================== wevu =========================

all:: ../../bin/wevu.exe

../../bin/wevu.exe 	:  ./evu/evpr.o ./evu/evpp.o ./evu/evpa.o ./evu/wevu.o
	@echo Creation of $@
	@$(CC) -mconsole -o $@  evpr.o evpp.o evpa.o wevu.o

Rscilab-ming.rc : icons/3DROT.ico \
	icons/ARROW.ico \
	icons/BIN.ICO \
	icons/CHDIR.ico \
	icons/CIRCLE.ico \
	icons/CONSOLE.ico \
	icons/COPY.ico \
	icons/COSF.ICO \
	icons/COS.ICO \
	icons/DEM.ICO \
	icons/DOUBLEARROW.ico \
	icons/exit24.ico \
	icons/fonts.ico \
	icons/GED.ico \
	icons/Graph.ICO \
	icons/HELP.ico \
	icons/LINE.ico \
	icons/metanet24.ico \
	icons/NEW.ico \
	icons/OPEN.ico \
	icons/PASTE.ico \
	icons/PICKER.ico \
	icons/POLYLINE.ico \
	icons/PRINT.ico \
	icons/puffin.ico \
	icons/RECTANGLE.ico \
	icons/SAVE.ico \
	icons/SAV.ICO \
	icons/SCE.ICO \
	icons/scicos24.ico \
	icons/scicos96.ico \
	icons/SCI.ICO \
	icons/scilab24.ico \
	icons/scilab.ico \
	icons/scilab-k.ico \
	icons/TEXT.ICO \
	icons/TST.ICO \
	icons/UNZOOM.ico \
	icons/VIDE.ICO \
	icons/ZOOM.ico

#==================== dependencies generated via gcc -MMD

AboutBox.o: AboutBox.c AboutBox.h wgnuplib.h resource.h Messages.h \
 Warnings.h Errors.h ../version.h ../config.h \
 ../os_specific/win_mem_alloc.h

clipboard.o: clipboard.c clipboard.h wcommon.h ../graphics/Math.h \
 ../graphics/../machine.h ../graphics/../config.h \
 ../graphics/../os_specific/sci_mem_alloc.h ../graphics/Graphics.h \
 ../graphics/bcg.h ../graphics/ObjectStructure.h \
 ../graphics/../wsci/wgnuplib.h ../graphics/Math.h ../stack-c.h \
 ../graphics/Math.h ../stack-def.h ../machine.h ../interf/stack1.h \
 ../interf/stack2.h ../interf/stack3.h Messages.h Warnings.h Errors.h \
 wgnuplib.h ../os_specific/win_mem_alloc.h

command.o: command.c wcommon.h ../graphics/Math.h \
 ../graphics/../machine.h ../graphics/../config.h \
 ../graphics/../os_specific/sci_mem_alloc.h ../graphics/Graphics.h \
 ../graphics/bcg.h ../graphics/ObjectStructure.h \
 ../graphics/../wsci/wgnuplib.h ../graphics/Math.h Messages.h Warnings.h \
 Errors.h ../os_specific/win_mem_alloc.h

CriticalSectionGraphicWindow.o: CriticalSectionGraphicWindow.c \
 CriticalSectionGraphicWindow.h

cscilex.o: cscilex.c ../os_specific/win_mem_alloc.h

DDE.o: DDE.c DDE.h

DragnDrop.o: DragnDrop.c DragnDrop.h wgnuplib.h resource.h Messages.h \
 Warnings.h Errors.h ../version.h ../config.h \
 ../os_specific/win_mem_alloc.h

Events.o: Events.c Events.h wcommon.h ../graphics/Math.h \
 ../graphics/../machine.h ../graphics/../config.h \
 ../graphics/../os_specific/sci_mem_alloc.h ../graphics/Graphics.h \
 ../graphics/bcg.h ../graphics/ObjectStructure.h \
 ../graphics/../wsci/wgnuplib.h ../graphics/Math.h MouseEvents.h \
 KeyEvents.h

ExportBmpEmf.o: ExportBmpEmf.c ExportBmpEmf.h wgnuplib.h resource.h \
 Messages.h Warnings.h Errors.h ../version.h ../config.h \
 ../os_specific/win_mem_alloc.h wresource.h ../graphics/bcg.h \
 ../graphics/../machine.h ../graphics/../config.h \
 ../graphics/ObjectStructure.h ../graphics/../wsci/wgnuplib.h \
 ../graphics/Math.h ../graphics/../os_specific/sci_mem_alloc.h \
 ../graphics/Graphics.h

ExportBox.o: ExportBox.c ExportBox.h wgraph.h ../version.h ../config.h \
 wresource.h wcommon.h ../graphics/Math.h ../graphics/../machine.h \
 ../graphics/../config.h ../graphics/../os_specific/sci_mem_alloc.h \
 ../graphics/Graphics.h ../graphics/bcg.h ../graphics/ObjectStructure.h \
 ../graphics/../wsci/wgnuplib.h ../graphics/Math.h \
 ../graphics/scigraphic.h ../graphics/../graphics/bcg.h \
 ../graphics/Graphics.h ../graphics/DestroyObjects.h \
 ../graphics/HandleManagement.h ../graphics/GetProperty.h \
 ../graphics/DrawObjects.h ../graphics/../sparse/spConfig.h \
 ../graphics/bcg.h ../graphics/PloEch.h Events.h wgnuplib.h Messages.h \
 Warnings.h Errors.h ../os_specific/win_mem_alloc.h

FigureToFile.o: FigureToFile.c FigureToFile.h ../machine.h ../config.h \
 ../stack-c.h ../graphics/Math.h ../graphics/../machine.h \
 ../graphics/../os_specific/sci_mem_alloc.h ../graphics/Graphics.h \
 ../stack-def.h ../machine.h ../interf/stack1.h ../interf/stack2.h \
 ../interf/stack3.h ../version.h ../graphics/scigraphic.h \
 ../graphics/../graphics/bcg.h ../graphics/../graphics/../machine.h \
 ../graphics/../graphics/ObjectStructure.h \
 ../graphics/../graphics/../wsci/wgnuplib.h \
 ../graphics/../graphics/Math.h ../graphics/Graphics.h wgraph.h \
 wresource.h wcommon.h ../graphics/Math.h ../graphics/bcg.h \
 ../graphics/DestroyObjects.h ../graphics/ObjectStructure.h \
 ../graphics/HandleManagement.h ../graphics/GetProperty.h \
 ../graphics/DrawObjects.h ../graphics/Math.h \
 ../graphics/../sparse/spConfig.h ../graphics/bcg.h ../graphics/PloEch.h \
 Events.h wgnuplib.h Messages.h Warnings.h Errors.h \
 ../os_specific/win_mem_alloc.h

FigureToPrint.o: FigureToPrint.c FigureToPrint.h ../machine.h ../config.h \
 ../stack-c.h ../graphics/Math.h ../graphics/../machine.h \
 ../graphics/../os_specific/sci_mem_alloc.h ../graphics/Graphics.h \
 ../stack-def.h ../machine.h ../interf/stack1.h ../interf/stack2.h \
 ../interf/stack3.h ../version.h ../graphics/scigraphic.h \
 ../graphics/../graphics/bcg.h ../graphics/../graphics/../machine.h \
 ../graphics/../graphics/ObjectStructure.h \
 ../graphics/../graphics/../wsci/wgnuplib.h \
 ../graphics/../graphics/Math.h ../graphics/Graphics.h wgraph.h \
 wresource.h wcommon.h ../graphics/Math.h ../graphics/bcg.h \
 ../graphics/DestroyObjects.h ../graphics/ObjectStructure.h \
 ../graphics/HandleManagement.h ../graphics/GetProperty.h \
 ../graphics/DrawObjects.h ../graphics/Math.h \
 ../graphics/../sparse/spConfig.h ../graphics/bcg.h ../graphics/PloEch.h \
 Events.h Messages.h Warnings.h Errors.h ../os_specific/win_mem_alloc.h

FilesAssociationBox.o: FilesAssociationBox.c FilesAssociationBox.h \
 wgnuplib.h resource.h ../os_specific/win_mem_alloc.h ../version.h \
 ../config.h

FilesAssociations.o: FilesAssociations.c FilesAssociations.h ../version.h \
 ../config.h wcommon.h ../graphics/Math.h ../graphics/../machine.h \
 ../graphics/../config.h ../graphics/../os_specific/sci_mem_alloc.h \
 ../graphics/Graphics.h ../graphics/bcg.h ../graphics/ObjectStructure.h \
 ../graphics/../wsci/wgnuplib.h ../graphics/Math.h Messages.h Warnings.h \
 Errors.h ../os_specific/win_mem_alloc.h

FindScilab.o: FindScilab.c FindScilab.h ../version.h ../config.h \
 Messages.h Warnings.h Errors.h wcommon.h ../graphics/Math.h \
 ../graphics/../machine.h ../graphics/../config.h \
 ../graphics/../os_specific/sci_mem_alloc.h ../graphics/Graphics.h \
 ../graphics/bcg.h ../graphics/ObjectStructure.h \
 ../graphics/../wsci/wgnuplib.h ../graphics/Math.h resource.h \
 ../os_specific/win_mem_alloc.h

GetOS.o: GetOS.c GetOS.h

GraphWindows.o: GraphWindows.c GraphWindows.h wgnuplib.h Messages.h \
 Warnings.h Errors.h ../os_specific/win_mem_alloc.h

gvwprn.o: gvwprn.c wresource.h wcommon.h ../graphics/Math.h \
 ../graphics/../machine.h ../graphics/../config.h \
 ../graphics/../os_specific/sci_mem_alloc.h ../graphics/Graphics.h \
 ../graphics/bcg.h ../graphics/ObjectStructure.h \
 ../graphics/../wsci/wgnuplib.h ../graphics/Math.h Messages.h Warnings.h \
 Errors.h ../os_specific/win_mem_alloc.h
ihmcolor.o: ihmcolor.c ihmcolor.h ../machine.h ../config.h ../stack-c.h \
 ../graphics/Math.h ../graphics/../machine.h \
 ../graphics/../os_specific/sci_mem_alloc.h ../graphics/Graphics.h \
 ../stack-def.h ../machine.h ../interf/stack1.h ../interf/stack2.h \
 ../interf/stack3.h ../version.h wgnuplib.h \
 ../os_specific/win_mem_alloc.h
interfdde.o: interfdde.c interfdde.h wcommon.h ../graphics/Math.h \
 ../graphics/../machine.h ../graphics/../config.h \
 ../graphics/../os_specific/sci_mem_alloc.h ../graphics/Graphics.h \
 ../graphics/bcg.h ../graphics/ObjectStructure.h \
 ../graphics/../wsci/wgnuplib.h ../graphics/Math.h ../stack-c.h \
 ../graphics/Math.h ../stack-def.h ../machine.h ../interf/stack1.h \
 ../interf/stack2.h ../interf/stack3.h DDE.h Messages.h Warnings.h \
 Errors.h ../os_specific/win_mem_alloc.h
KeyEvents.o: KeyEvents.c KeyEvents.h wcommon.h ../graphics/Math.h \
 ../graphics/../machine.h ../graphics/../config.h \
 ../graphics/../os_specific/sci_mem_alloc.h ../graphics/Graphics.h \
 ../graphics/bcg.h ../graphics/ObjectStructure.h \
 ../graphics/../wsci/wgnuplib.h ../graphics/Math.h
lpr.o: lpr.c
MenuWindows.o: MenuWindows.c MenuWindows.h wgnuplib.h Messages.h \
 Warnings.h Errors.h ../os_specific/win_mem_alloc.h
MessageBoxNewGraphicMode.o: MessageBoxNewGraphicMode.c \
 MessageBoxNewGraphicMode.h wgnuplib.h resource.h Messages.h Warnings.h \
 Errors.h ../version.h ../config.h ../os_specific/win_mem_alloc.h
misc.o: misc.c wresource.h wcommon.h ../graphics/Math.h \
 ../graphics/../machine.h ../graphics/../config.h \
 ../graphics/../os_specific/sci_mem_alloc.h ../graphics/Graphics.h \
 ../graphics/bcg.h ../graphics/ObjectStructure.h \
 ../graphics/../wsci/wgnuplib.h ../graphics/Math.h Messages.h Warnings.h \
 Errors.h ../os_specific/win_mem_alloc.h
MouseEvents.o: MouseEvents.c MouseEvents.h wcommon.h ../graphics/Math.h \
 ../graphics/../machine.h ../graphics/../config.h \
 ../graphics/../os_specific/sci_mem_alloc.h ../graphics/Graphics.h \
 ../graphics/bcg.h ../graphics/ObjectStructure.h \
 ../graphics/../wsci/wgnuplib.h ../graphics/Math.h
printf.o: printf.c ../version.h ../config.h wgnuplib.h winmain.h \
 wcommon.h ../graphics/Math.h ../graphics/../machine.h \
 ../graphics/../config.h ../graphics/../os_specific/sci_mem_alloc.h \
 ../graphics/Graphics.h ../graphics/bcg.h ../graphics/ObjectStructure.h \
 ../graphics/../wsci/wgnuplib.h ../graphics/Math.h FilesAssociations.h \
 SciEnv.h GetOS.h printf.h ../machine.h Messages.h Warnings.h Errors.h
readcons.o: readcons.c readline.c wcommon.h ../graphics/Math.h \
 ../graphics/../machine.h ../graphics/../config.h \
 ../graphics/../os_specific/sci_mem_alloc.h ../graphics/Graphics.h \
 ../graphics/bcg.h ../graphics/ObjectStructure.h \
 ../graphics/../wsci/wgnuplib.h ../graphics/Math.h printf.h ../machine.h \
 wtext.h wresource.h resource.h ../version.h ../config.h
readwin.o: readwin.c readline.c wcommon.h ../graphics/Math.h \
 ../graphics/../machine.h ../graphics/../config.h \
 ../graphics/../os_specific/sci_mem_alloc.h ../graphics/Graphics.h \
 ../graphics/bcg.h ../graphics/ObjectStructure.h \
 ../graphics/../wsci/wgnuplib.h ../graphics/Math.h printf.h ../machine.h \
 wtext.h wresource.h resource.h ../version.h ../config.h
registry.o: registry.c registry.h ../stack-c.h ../graphics/Math.h \
 ../graphics/../machine.h ../graphics/../config.h \
 ../graphics/../os_specific/sci_mem_alloc.h ../graphics/Graphics.h \
 ../stack-def.h ../machine.h ../interf/stack1.h ../interf/stack2.h \
 ../interf/stack3.h ../version.h ../config.h ../graphics/bcg.h \
 ../graphics/ObjectStructure.h ../graphics/../wsci/wgnuplib.h \
 ../graphics/Math.h Messages.h Warnings.h Errors.h \
 ../os_specific/win_mem_alloc.h wresource.h
SciEnv.o: SciEnv.c SciEnv.h ../version.h ../config.h wcommon.h \
 ../graphics/Math.h ../graphics/../machine.h ../graphics/../config.h \
 ../graphics/../os_specific/sci_mem_alloc.h ../graphics/Graphics.h \
 ../graphics/bcg.h ../graphics/ObjectStructure.h \
 ../graphics/../wsci/wgnuplib.h ../graphics/Math.h FilesAssociations.h \
 GetOS.h Messages.h Warnings.h Errors.h ../os_specific/win_mem_alloc.h
ScilabXloop.o: ScilabXloop.c wresource.h wcommon.h ../graphics/Math.h \
 ../graphics/../machine.h ../graphics/../config.h \
 ../graphics/../os_specific/sci_mem_alloc.h ../graphics/Graphics.h \
 ../graphics/bcg.h ../graphics/ObjectStructure.h \
 ../graphics/../wsci/wgnuplib.h ../graphics/Math.h ../machine.h \
 Messages.h Warnings.h Errors.h
Splashscreen.o: Splashscreen.c Splashscreen.h wgnuplib.h resource.h \
 Messages.h Warnings.h Errors.h ../version.h ../config.h \
 ../os_specific/win_mem_alloc.h
TextToPrint.o: TextToPrint.c TextToPrint.h ../machine.h ../config.h \
 ../stack-c.h ../graphics/Math.h ../graphics/../machine.h \
 ../graphics/../os_specific/sci_mem_alloc.h ../graphics/Graphics.h \
 ../stack-def.h ../machine.h ../interf/stack1.h ../interf/stack2.h \
 ../interf/stack3.h ../version.h wgnuplib.h Messages.h Warnings.h \
 Errors.h ../os_specific/win_mem_alloc.h
TextWindows.o: TextWindows.c TextWindows.h wgnuplib.h Messages.h \
 Warnings.h Errors.h ../os_specific/win_mem_alloc.h
Toolbar.o: Toolbar.c Toolbar.h ../machine.h ../config.h ../stack-c.h \
 ../graphics/Math.h ../graphics/../machine.h \
 ../graphics/../os_specific/sci_mem_alloc.h ../graphics/Graphics.h \
 ../stack-def.h ../machine.h ../interf/stack1.h ../interf/stack2.h \
 ../interf/stack3.h ../version.h wgnuplib.h resource.h \
 ../graphics/scigraphic.h ../graphics/../graphics/bcg.h \
 ../graphics/../graphics/../machine.h \
 ../graphics/../graphics/ObjectStructure.h \
 ../graphics/../graphics/../wsci/wgnuplib.h \
 ../graphics/../graphics/Math.h ../graphics/Graphics.h wgraph.h \
 wresource.h wcommon.h ../graphics/Math.h ../graphics/bcg.h \
 ../graphics/DestroyObjects.h ../graphics/ObjectStructure.h \
 ../graphics/HandleManagement.h ../graphics/GetProperty.h \
 ../graphics/DrawObjects.h ../graphics/Math.h \
 ../graphics/../sparse/spConfig.h ../graphics/bcg.h ../graphics/PloEch.h \
 Events.h Messages.h Warnings.h Errors.h ../os_specific/win_mem_alloc.h
Transparency.o: Transparency.c Transparency.h wgnuplib.h resource.h \
 Messages.h Warnings.h Errors.h ../version.h ../config.h GetOS.h \
 ../os_specific/win_mem_alloc.h

./evu/evpr.o: ./evu/evpr.c ./evu/evu.h
./evu/evpa.o: ./evu/evpa.c ./evu/evu.h
./evu/evpp.o: ./evu/evpp.c ./evu/evu.h
./evu/wevu.o: ./evu/wevu.c ./evu/evu.h

wgmenu.o: wgmenu.c wgmenu.h wresource.h wcommon.h ../graphics/Math.h \
 ../graphics/../machine.h ../graphics/../config.h \
 ../graphics/../os_specific/sci_mem_alloc.h ../graphics/Graphics.h \
 ../graphics/bcg.h ../graphics/ObjectStructure.h \
 ../graphics/../wsci/wgnuplib.h ../graphics/Math.h ../graphics/Graphics.h \
 ../os_specific/men_Sutils.h ../os_specific/../machine.h Messages.h \
 Warnings.h Errors.h ../os_specific/win_mem_alloc.h
wgraph.o: wgraph.c wgraph.h ../version.h ../config.h wresource.h \
 wcommon.h ../graphics/Math.h ../graphics/../machine.h \
 ../graphics/../config.h ../graphics/../os_specific/sci_mem_alloc.h \
 ../graphics/Graphics.h ../graphics/bcg.h ../graphics/ObjectStructure.h \
 ../graphics/../wsci/wgnuplib.h ../graphics/Math.h \
 ../graphics/scigraphic.h ../graphics/../graphics/bcg.h \
 ../graphics/Graphics.h ../graphics/DestroyObjects.h \
 ../graphics/HandleManagement.h ../graphics/GetProperty.h \
 ../graphics/DrawObjects.h ../graphics/../sparse/spConfig.h \
 ../graphics/bcg.h ../graphics/PloEch.h Events.h resource.h \
 ../graphics/Events.h Messages.h Warnings.h Errors.h ../stack-c.h \
 ../graphics/Math.h ../stack-def.h ../machine.h ../interf/stack1.h \
 ../interf/stack2.h ../interf/stack3.h ../os_specific/win_mem_alloc.h
WinConsole.o: WinConsole.c WinConsole.h ../version.h ../config.h \
 Messages.h Warnings.h Errors.h
winDumpExts.o: winDumpExts.c
winmain.o: winmain.c winmain.h ../version.h ../config.h wcommon.h \
 ../graphics/Math.h ../graphics/../machine.h ../graphics/../config.h \
 ../graphics/../os_specific/sci_mem_alloc.h ../graphics/Graphics.h \
 ../graphics/bcg.h ../graphics/ObjectStructure.h \
 ../graphics/../wsci/wgnuplib.h ../graphics/Math.h FilesAssociations.h \
 SciEnv.h GetOS.h WinConsole.h wtext.h wresource.h resource.h Messages.h \
 Warnings.h Errors.h GraphWindows.h wgnuplib.h MenuWindows.h \
 ../os_specific/win_mem_alloc.h
wmcopydata.o: wmcopydata.c wmcopydata.h Messages.h Warnings.h Errors.h
wmenu.o: wmenu.c wmenu.h wresource.h wcommon.h ../graphics/Math.h \
 ../graphics/../machine.h ../graphics/../config.h \
 ../graphics/../os_specific/sci_mem_alloc.h ../graphics/Graphics.h \
 ../graphics/bcg.h ../graphics/ObjectStructure.h \
 ../graphics/../wsci/wgnuplib.h ../graphics/Math.h wtext.h resource.h \
 ../version.h ../config.h Messages.h Warnings.h Errors.h \
 ../os_specific/win_mem_alloc.h
wmprint.o: wmprint.c ../machine.h ../config.h Messages.h Warnings.h \
 Errors.h
wmtex.o: wmtex.c ../machine.h ../config.h wcommon.h ../graphics/Math.h \
 ../graphics/../machine.h ../graphics/../os_specific/sci_mem_alloc.h \
 ../graphics/Graphics.h ../graphics/bcg.h ../graphics/ObjectStructure.h \
 ../graphics/../wsci/wgnuplib.h ../graphics/Math.h Messages.h Warnings.h \
 Errors.h
WndConsoleParentProc.o: WndConsoleParentProc.c WndConsoleParentProc.h \
 wgnuplib.h resource.h Messages.h Warnings.h Errors.h ../version.h \
 ../config.h ../os_specific/win_mem_alloc.h wresource.h wtext.h wcommon.h \
 ../graphics/Math.h ../graphics/../machine.h ../graphics/../config.h \
 ../graphics/../os_specific/sci_mem_alloc.h ../graphics/Graphics.h \
 ../graphics/bcg.h ../graphics/ObjectStructure.h \
 ../graphics/../wsci/wgnuplib.h ../graphics/Math.h
WndConsoleTextProc.o: WndConsoleTextProc.c WndConsoleTextProc.h \
 wgnuplib.h resource.h Messages.h Warnings.h Errors.h ../version.h \
 ../config.h ../machine.h ../os_specific/win_mem_alloc.h wresource.h
WndGraphProc.o: WndGraphProc.c WndGraphProc.h wgnuplib.h resource.h \
 Messages.h Warnings.h Errors.h ../version.h ../config.h \
 ../os_specific/win_mem_alloc.h wresource.h ../graphics/bcg.h \
 ../graphics/../machine.h ../graphics/../config.h \
 ../graphics/ObjectStructure.h ../graphics/../wsci/wgnuplib.h \
 ../graphics/Math.h ../graphics/../os_specific/sci_mem_alloc.h \
 ../graphics/Graphics.h
WndParentGraphProc.o: WndParentGraphProc.c WndParentGraphProc.h \
 wgnuplib.h resource.h Messages.h Warnings.h Errors.h ../version.h \
 ../config.h ../os_specific/win_mem_alloc.h wresource.h ../graphics/bcg.h \
 ../graphics/../machine.h ../graphics/../config.h \
 ../graphics/ObjectStructure.h ../graphics/../wsci/wgnuplib.h \
 ../graphics/Math.h ../graphics/../os_specific/sci_mem_alloc.h \
 ../graphics/Graphics.h
wprinter.o: wprinter.c wresource.h wcommon.h ../graphics/Math.h \
 ../graphics/../machine.h ../graphics/../config.h \
 ../graphics/../os_specific/sci_mem_alloc.h ../graphics/Graphics.h \
 ../graphics/bcg.h ../graphics/ObjectStructure.h \
 ../graphics/../wsci/wgnuplib.h ../graphics/Math.h
wscilex.o: wscilex.c
wstatbar.o: wstatbar.c Messages.h Warnings.h Errors.h
wtext.o: wtext.c wtext.h wresource.h resource.h wcommon.h \
 ../graphics/Math.h ../graphics/../machine.h ../graphics/../config.h \
 ../graphics/../os_specific/sci_mem_alloc.h ../graphics/Graphics.h \
 ../graphics/bcg.h ../graphics/ObjectStructure.h \
 ../graphics/../wsci/wgnuplib.h ../graphics/Math.h ../version.h \
 ../config.h wmcopydata.h WinConsole.h Messages.h Warnings.h Errors.h \
 ../stack-c.h ../graphics/Math.h ../stack-def.h ../machine.h \
 ../interf/stack1.h ../interf/stack2.h ../interf/stack3.h \
 ../os_specific/win_mem_alloc.h
wtloop.o: wtloop.c wresource.h wcommon.h ../graphics/Math.h \
 ../graphics/../machine.h ../graphics/../config.h \
 ../graphics/../os_specific/sci_mem_alloc.h ../graphics/Graphics.h \
 ../graphics/bcg.h ../graphics/ObjectStructure.h \
 ../graphics/../wsci/wgnuplib.h ../graphics/Math.h \
 ../os_specific/Os_specific.h ../os_specific/../machine.h ../stack-c.h \
 ../graphics/Math.h ../stack-def.h ../machine.h ../interf/stack1.h \
 ../interf/stack2.h ../interf/stack3.h Messages.h Warnings.h Errors.h
x_zzledt.o: x_zzledt.c ../os_specific/win_mem_alloc.h wcommon.h \
 ../graphics/Math.h ../graphics/../machine.h ../graphics/../config.h \
 ../graphics/../os_specific/sci_mem_alloc.h ../graphics/Graphics.h \
 ../graphics/bcg.h ../graphics/ObjectStructure.h \
 ../graphics/../wsci/wgnuplib.h ../graphics/Math.h wtext.h wresource.h \
 resource.h ../version.h ../config.h
AboutBox.o: AboutBox.c AboutBox.h wgnuplib.h resource.h Messages.h \
 Warnings.h Errors.h ../version.h ../config.h \
 ../os_specific/win_mem_alloc.h
clipboard.o: clipboard.c clipboard.h wcommon.h ../graphics/Math.h \
 ../graphics/../machine.h ../graphics/../config.h \
 ../graphics/../os_specific/sci_mem_alloc.h ../graphics/Graphics.h \
 ../graphics/bcg.h ../graphics/ObjectStructure.h \
 ../graphics/../wsci/wgnuplib.h ../graphics/Math.h ../stack-c.h \
 ../graphics/Math.h ../stack-def.h ../machine.h ../interf/stack1.h \
 ../interf/stack2.h ../interf/stack3.h Messages.h Warnings.h Errors.h \
 wgnuplib.h ../os_specific/win_mem_alloc.h
command.o: command.c wcommon.h ../graphics/Math.h \
 ../graphics/../machine.h ../graphics/../config.h \
 ../graphics/../os_specific/sci_mem_alloc.h ../graphics/Graphics.h \
 ../graphics/bcg.h ../graphics/ObjectStructure.h \
 ../graphics/../wsci/wgnuplib.h ../graphics/Math.h Messages.h Warnings.h \
 Errors.h ../os_specific/win_mem_alloc.h
CriticalSectionGraphicWindow.o: CriticalSectionGraphicWindow.c \
 CriticalSectionGraphicWindow.h
cscilex.o: cscilex.c ../os_specific/win_mem_alloc.h
DDE.o: DDE.c DDE.h
DragnDrop.o: DragnDrop.c DragnDrop.h wgnuplib.h resource.h Messages.h \
 Warnings.h Errors.h ../version.h ../config.h \
 ../os_specific/win_mem_alloc.h
Events.o: Events.c Events.h wcommon.h ../graphics/Math.h \
 ../graphics/../machine.h ../graphics/../config.h \
 ../graphics/../os_specific/sci_mem_alloc.h ../graphics/Graphics.h \
 ../graphics/bcg.h ../graphics/ObjectStructure.h \
 ../graphics/../wsci/wgnuplib.h ../graphics/Math.h MouseEvents.h \
 KeyEvents.h
ExportBmpEmf.o: ExportBmpEmf.c ExportBmpEmf.h wgnuplib.h resource.h \
 Messages.h Warnings.h Errors.h ../version.h ../config.h \
 ../os_specific/win_mem_alloc.h wresource.h ../graphics/bcg.h \
 ../graphics/../machine.h ../graphics/../config.h \
 ../graphics/ObjectStructure.h ../graphics/../wsci/wgnuplib.h \
 ../graphics/Math.h ../graphics/../os_specific/sci_mem_alloc.h \
 ../graphics/Graphics.h
ExportBox.o: ExportBox.c ExportBox.h wgraph.h ../version.h ../config.h \
 wresource.h wcommon.h ../graphics/Math.h ../graphics/../machine.h \
 ../graphics/../config.h ../graphics/../os_specific/sci_mem_alloc.h \
 ../graphics/Graphics.h ../graphics/bcg.h ../graphics/ObjectStructure.h \
 ../graphics/../wsci/wgnuplib.h ../graphics/Math.h \
 ../graphics/scigraphic.h ../graphics/../graphics/bcg.h \
 ../graphics/Graphics.h ../graphics/DestroyObjects.h \
 ../graphics/HandleManagement.h ../graphics/GetProperty.h \
 ../graphics/DrawObjects.h ../graphics/../sparse/spConfig.h \
 ../graphics/bcg.h ../graphics/PloEch.h Events.h wgnuplib.h Messages.h \
 Warnings.h Errors.h ../os_specific/win_mem_alloc.h
FigureToFile.o: FigureToFile.c FigureToFile.h ../machine.h ../config.h \
 ../stack-c.h ../graphics/Math.h ../graphics/../machine.h \
 ../graphics/../os_specific/sci_mem_alloc.h ../graphics/Graphics.h \
 ../stack-def.h ../machine.h ../interf/stack1.h ../interf/stack2.h \
 ../interf/stack3.h ../version.h ../graphics/scigraphic.h \
 ../graphics/../graphics/bcg.h ../graphics/../graphics/../machine.h \
 ../graphics/../graphics/ObjectStructure.h \
 ../graphics/../graphics/../wsci/wgnuplib.h \
 ../graphics/../graphics/Math.h ../graphics/Graphics.h wgraph.h \
 wresource.h wcommon.h ../graphics/Math.h ../graphics/bcg.h \
 ../graphics/DestroyObjects.h ../graphics/ObjectStructure.h \
 ../graphics/HandleManagement.h ../graphics/GetProperty.h \
 ../graphics/DrawObjects.h ../graphics/Math.h \
 ../graphics/../sparse/spConfig.h ../graphics/bcg.h ../graphics/PloEch.h \
 Events.h wgnuplib.h Messages.h Warnings.h Errors.h \
 ../os_specific/win_mem_alloc.h
FigureToPrint.o: FigureToPrint.c FigureToPrint.h ../machine.h ../config.h \
 ../stack-c.h ../graphics/Math.h ../graphics/../machine.h \
 ../graphics/../os_specific/sci_mem_alloc.h ../graphics/Graphics.h \
 ../stack-def.h ../machine.h ../interf/stack1.h ../interf/stack2.h \
 ../interf/stack3.h ../version.h ../graphics/scigraphic.h \
 ../graphics/../graphics/bcg.h ../graphics/../graphics/../machine.h \
 ../graphics/../graphics/ObjectStructure.h \
 ../graphics/../graphics/../wsci/wgnuplib.h \
 ../graphics/../graphics/Math.h ../graphics/Graphics.h wgraph.h \
 wresource.h wcommon.h ../graphics/Math.h ../graphics/bcg.h \
 ../graphics/DestroyObjects.h ../graphics/ObjectStructure.h \
 ../graphics/HandleManagement.h ../graphics/GetProperty.h \
 ../graphics/DrawObjects.h ../graphics/Math.h \
 ../graphics/../sparse/spConfig.h ../graphics/bcg.h ../graphics/PloEch.h \
 Events.h Messages.h Warnings.h Errors.h ../os_specific/win_mem_alloc.h
FilesAssociationBox.o: FilesAssociationBox.c FilesAssociationBox.h \
 wgnuplib.h resource.h ../os_specific/win_mem_alloc.h ../version.h \
 ../config.h
FilesAssociations.o: FilesAssociations.c FilesAssociations.h ../version.h \
 ../config.h wcommon.h ../graphics/Math.h ../graphics/../machine.h \
 ../graphics/../config.h ../graphics/../os_specific/sci_mem_alloc.h \
 ../graphics/Graphics.h ../graphics/bcg.h ../graphics/ObjectStructure.h \
 ../graphics/../wsci/wgnuplib.h ../graphics/Math.h Messages.h Warnings.h \
 Errors.h ../os_specific/win_mem_alloc.h
FindScilab.o: FindScilab.c FindScilab.h ../version.h ../config.h \
 Messages.h Warnings.h Errors.h wcommon.h ../graphics/Math.h \
 ../graphics/../machine.h ../graphics/../config.h \
 ../graphics/../os_specific/sci_mem_alloc.h ../graphics/Graphics.h \
 ../graphics/bcg.h ../graphics/ObjectStructure.h \
 ../graphics/../wsci/wgnuplib.h ../graphics/Math.h resource.h \
 ../os_specific/win_mem_alloc.h
GetOS.o: GetOS.c GetOS.h
GraphWindows.o: GraphWindows.c GraphWindows.h wgnuplib.h Messages.h \
 Warnings.h Errors.h ../os_specific/win_mem_alloc.h
gvwprn.o: gvwprn.c wresource.h wcommon.h ../graphics/Math.h \
 ../graphics/../machine.h ../graphics/../config.h \
 ../graphics/../os_specific/sci_mem_alloc.h ../graphics/Graphics.h \
 ../graphics/bcg.h ../graphics/ObjectStructure.h \
 ../graphics/../wsci/wgnuplib.h ../graphics/Math.h Messages.h Warnings.h \
 Errors.h ../os_specific/win_mem_alloc.h
ihmcolor.o: ihmcolor.c ihmcolor.h ../machine.h ../config.h ../stack-c.h \
 ../graphics/Math.h ../graphics/../machine.h \
 ../graphics/../os_specific/sci_mem_alloc.h ../graphics/Graphics.h \
 ../stack-def.h ../machine.h ../interf/stack1.h ../interf/stack2.h \
 ../interf/stack3.h ../version.h wgnuplib.h \
 ../os_specific/win_mem_alloc.h
interfdde.o: interfdde.c interfdde.h wcommon.h ../graphics/Math.h \
 ../graphics/../machine.h ../graphics/../config.h \
 ../graphics/../os_specific/sci_mem_alloc.h ../graphics/Graphics.h \
 ../graphics/bcg.h ../graphics/ObjectStructure.h \
 ../graphics/../wsci/wgnuplib.h ../graphics/Math.h ../stack-c.h \
 ../graphics/Math.h ../stack-def.h ../machine.h ../interf/stack1.h \
 ../interf/stack2.h ../interf/stack3.h DDE.h Messages.h Warnings.h \
 Errors.h ../os_specific/win_mem_alloc.h
KeyEvents.o: KeyEvents.c KeyEvents.h wcommon.h ../graphics/Math.h \
 ../graphics/../machine.h ../graphics/../config.h \
 ../graphics/../os_specific/sci_mem_alloc.h ../graphics/Graphics.h \
 ../graphics/bcg.h ../graphics/ObjectStructure.h \
 ../graphics/../wsci/wgnuplib.h ../graphics/Math.h
lpr.o: lpr.c
MenuWindows.o: MenuWindows.c MenuWindows.h wgnuplib.h Messages.h \
 Warnings.h Errors.h ../os_specific/win_mem_alloc.h
MessageBoxNewGraphicMode.o: MessageBoxNewGraphicMode.c \
 MessageBoxNewGraphicMode.h wgnuplib.h resource.h Messages.h Warnings.h \
 Errors.h ../version.h ../config.h ../os_specific/win_mem_alloc.h
misc.o: misc.c wresource.h wcommon.h ../graphics/Math.h \
 ../graphics/../machine.h ../graphics/../config.h \
 ../graphics/../os_specific/sci_mem_alloc.h ../graphics/Graphics.h \
 ../graphics/bcg.h ../graphics/ObjectStructure.h \
 ../graphics/../wsci/wgnuplib.h ../graphics/Math.h Messages.h Warnings.h \
 Errors.h ../os_specific/win_mem_alloc.h
MouseEvents.o: MouseEvents.c MouseEvents.h wcommon.h ../graphics/Math.h \
 ../graphics/../machine.h ../graphics/../config.h \
 ../graphics/../os_specific/sci_mem_alloc.h ../graphics/Graphics.h \
 ../graphics/bcg.h ../graphics/ObjectStructure.h \
 ../graphics/../wsci/wgnuplib.h ../graphics/Math.h
printf.o: printf.c ../version.h ../config.h wgnuplib.h winmain.h \
 wcommon.h ../graphics/Math.h ../graphics/../machine.h \
 ../graphics/../config.h ../graphics/../os_specific/sci_mem_alloc.h \
 ../graphics/Graphics.h ../graphics/bcg.h ../graphics/ObjectStructure.h \
 ../graphics/../wsci/wgnuplib.h ../graphics/Math.h FilesAssociations.h \
 SciEnv.h GetOS.h printf.h ../machine.h Messages.h Warnings.h Errors.h
readcons.o: readcons.c readline.c wcommon.h ../graphics/Math.h \
 ../graphics/../machine.h ../graphics/../config.h \
 ../graphics/../os_specific/sci_mem_alloc.h ../graphics/Graphics.h \
 ../graphics/bcg.h ../graphics/ObjectStructure.h \
 ../graphics/../wsci/wgnuplib.h ../graphics/Math.h printf.h ../machine.h \
 wtext.h wresource.h resource.h ../version.h ../config.h
readwin.o: readwin.c readline.c wcommon.h ../graphics/Math.h \
 ../graphics/../machine.h ../graphics/../config.h \
 ../graphics/../os_specific/sci_mem_alloc.h ../graphics/Graphics.h \
 ../graphics/bcg.h ../graphics/ObjectStructure.h \
 ../graphics/../wsci/wgnuplib.h ../graphics/Math.h printf.h ../machine.h \
 wtext.h wresource.h resource.h ../version.h ../config.h
registry.o: registry.c registry.h ../stack-c.h ../graphics/Math.h \
 ../graphics/../machine.h ../graphics/../config.h \
 ../graphics/../os_specific/sci_mem_alloc.h ../graphics/Graphics.h \
 ../stack-def.h ../machine.h ../interf/stack1.h ../interf/stack2.h \
 ../interf/stack3.h ../version.h ../config.h ../graphics/bcg.h \
 ../graphics/ObjectStructure.h ../graphics/../wsci/wgnuplib.h \
 ../graphics/Math.h Messages.h Warnings.h Errors.h \
 ../os_specific/win_mem_alloc.h wresource.h
SciEnv.o: SciEnv.c SciEnv.h ../version.h ../config.h wcommon.h \
 ../graphics/Math.h ../graphics/../machine.h ../graphics/../config.h \
 ../graphics/../os_specific/sci_mem_alloc.h ../graphics/Graphics.h \
 ../graphics/bcg.h ../graphics/ObjectStructure.h \
 ../graphics/../wsci/wgnuplib.h ../graphics/Math.h FilesAssociations.h \
 GetOS.h Messages.h Warnings.h Errors.h ../os_specific/win_mem_alloc.h
ScilabXloop.o: ScilabXloop.c wresource.h wcommon.h ../graphics/Math.h \
 ../graphics/../machine.h ../graphics/../config.h \
 ../graphics/../os_specific/sci_mem_alloc.h ../graphics/Graphics.h \
 ../graphics/bcg.h ../graphics/ObjectStructure.h \
 ../graphics/../wsci/wgnuplib.h ../graphics/Math.h ../machine.h \
 Messages.h Warnings.h Errors.h
Splashscreen.o: Splashscreen.c Splashscreen.h wgnuplib.h resource.h \
 Messages.h Warnings.h Errors.h ../version.h ../config.h \
 ../os_specific/win_mem_alloc.h
TextToPrint.o: TextToPrint.c TextToPrint.h ../machine.h ../config.h \
 ../stack-c.h ../graphics/Math.h ../graphics/../machine.h \
 ../graphics/../os_specific/sci_mem_alloc.h ../graphics/Graphics.h \
 ../stack-def.h ../machine.h ../interf/stack1.h ../interf/stack2.h \
 ../interf/stack3.h ../version.h wgnuplib.h Messages.h Warnings.h \
 Errors.h ../os_specific/win_mem_alloc.h
TextWindows.o: TextWindows.c TextWindows.h wgnuplib.h Messages.h \
 Warnings.h Errors.h ../os_specific/win_mem_alloc.h
Toolbar.o: Toolbar.c Toolbar.h ../machine.h ../config.h ../stack-c.h \
 ../graphics/Math.h ../graphics/../machine.h \
 ../graphics/../os_specific/sci_mem_alloc.h ../graphics/Graphics.h \
 ../stack-def.h ../machine.h ../interf/stack1.h ../interf/stack2.h \
 ../interf/stack3.h ../version.h wgnuplib.h resource.h \
 ../graphics/scigraphic.h ../graphics/../graphics/bcg.h \
 ../graphics/../graphics/../machine.h \
 ../graphics/../graphics/ObjectStructure.h \
 ../graphics/../graphics/../wsci/wgnuplib.h \
 ../graphics/../graphics/Math.h ../graphics/Graphics.h wgraph.h \
 wresource.h wcommon.h ../graphics/Math.h ../graphics/bcg.h \
 ../graphics/DestroyObjects.h ../graphics/ObjectStructure.h \
 ../graphics/HandleManagement.h ../graphics/GetProperty.h \
 ../graphics/DrawObjects.h ../graphics/Math.h \
 ../graphics/../sparse/spConfig.h ../graphics/bcg.h ../graphics/PloEch.h \
 Events.h Messages.h Warnings.h Errors.h ../os_specific/win_mem_alloc.h
Transparency.o: Transparency.c Transparency.h wgnuplib.h resource.h \
 Messages.h Warnings.h Errors.h ../version.h ../config.h GetOS.h \
 ../os_specific/win_mem_alloc.h
wgmenu.o: wgmenu.c wgmenu.h wresource.h wcommon.h ../graphics/Math.h \
 ../graphics/../machine.h ../graphics/../config.h \
 ../graphics/../os_specific/sci_mem_alloc.h ../graphics/Graphics.h \
 ../graphics/bcg.h ../graphics/ObjectStructure.h \
 ../graphics/../wsci/wgnuplib.h ../graphics/Math.h ../graphics/Graphics.h \
 ../os_specific/men_Sutils.h ../os_specific/../machine.h Messages.h \
 Warnings.h Errors.h ../os_specific/win_mem_alloc.h
wgraph.o: wgraph.c wgraph.h ../version.h ../config.h wresource.h \
 wcommon.h ../graphics/Math.h ../graphics/../machine.h \
 ../graphics/../config.h ../graphics/../os_specific/sci_mem_alloc.h \
 ../graphics/Graphics.h ../graphics/bcg.h ../graphics/ObjectStructure.h \
 ../graphics/../wsci/wgnuplib.h ../graphics/Math.h \
 ../graphics/scigraphic.h ../graphics/../graphics/bcg.h \
 ../graphics/Graphics.h ../graphics/DestroyObjects.h \
 ../graphics/HandleManagement.h ../graphics/GetProperty.h \
 ../graphics/DrawObjects.h ../graphics/../sparse/spConfig.h \
 ../graphics/bcg.h ../graphics/PloEch.h Events.h resource.h \
 ../graphics/Events.h Messages.h Warnings.h Errors.h ../stack-c.h \
 ../graphics/Math.h ../stack-def.h ../machine.h ../interf/stack1.h \
 ../interf/stack2.h ../interf/stack3.h ../os_specific/win_mem_alloc.h
WinConsole.o: WinConsole.c WinConsole.h ../version.h ../config.h \
 Messages.h Warnings.h Errors.h
winDumpExts.o: winDumpExts.c
winmain.o: winmain.c winmain.h ../version.h ../config.h wcommon.h \
 ../graphics/Math.h ../graphics/../machine.h ../graphics/../config.h \
 ../graphics/../os_specific/sci_mem_alloc.h ../graphics/Graphics.h \
 ../graphics/bcg.h ../graphics/ObjectStructure.h \
 ../graphics/../wsci/wgnuplib.h ../graphics/Math.h FilesAssociations.h \
 SciEnv.h GetOS.h WinConsole.h wtext.h wresource.h resource.h Messages.h \
 Warnings.h Errors.h GraphWindows.h wgnuplib.h MenuWindows.h \
 ../os_specific/win_mem_alloc.h
wmcopydata.o: wmcopydata.c wmcopydata.h Messages.h Warnings.h Errors.h
wmenu.o: wmenu.c wmenu.h wresource.h wcommon.h ../graphics/Math.h \
 ../graphics/../machine.h ../graphics/../config.h \
 ../graphics/../os_specific/sci_mem_alloc.h ../graphics/Graphics.h \
 ../graphics/bcg.h ../graphics/ObjectStructure.h \
 ../graphics/../wsci/wgnuplib.h ../graphics/Math.h wtext.h resource.h \
 ../version.h ../config.h Messages.h Warnings.h Errors.h \
 ../os_specific/win_mem_alloc.h
wmprint.o: wmprint.c ../machine.h ../config.h Messages.h Warnings.h \
 Errors.h
wmtex.o: wmtex.c ../machine.h ../config.h wcommon.h ../graphics/Math.h \
 ../graphics/../machine.h ../graphics/../os_specific/sci_mem_alloc.h \
 ../graphics/Graphics.h ../graphics/bcg.h ../graphics/ObjectStructure.h \
 ../graphics/../wsci/wgnuplib.h ../graphics/Math.h Messages.h Warnings.h \
 Errors.h
WndConsoleParentProc.o: WndConsoleParentProc.c WndConsoleParentProc.h \
 wgnuplib.h resource.h Messages.h Warnings.h Errors.h ../version.h \
 ../config.h ../os_specific/win_mem_alloc.h wresource.h wtext.h wcommon.h \
 ../graphics/Math.h ../graphics/../machine.h ../graphics/../config.h \
 ../graphics/../os_specific/sci_mem_alloc.h ../graphics/Graphics.h \
 ../graphics/bcg.h ../graphics/ObjectStructure.h \
 ../graphics/../wsci/wgnuplib.h ../graphics/Math.h
WndConsoleTextProc.o: WndConsoleTextProc.c WndConsoleTextProc.h \
 wgnuplib.h resource.h Messages.h Warnings.h Errors.h ../version.h \
 ../config.h ../machine.h ../os_specific/win_mem_alloc.h wresource.h
WndGraphProc.o: WndGraphProc.c WndGraphProc.h wgnuplib.h resource.h \
 Messages.h Warnings.h Errors.h ../version.h ../config.h \
 ../os_specific/win_mem_alloc.h wresource.h ../graphics/bcg.h \
 ../graphics/../machine.h ../graphics/../config.h \
 ../graphics/ObjectStructure.h ../graphics/../wsci/wgnuplib.h \
 ../graphics/Math.h ../graphics/../os_specific/sci_mem_alloc.h \
 ../graphics/Graphics.h
WndParentGraphProc.o: WndParentGraphProc.c WndParentGraphProc.h \
 wgnuplib.h resource.h Messages.h Warnings.h Errors.h ../version.h \
 ../config.h ../os_specific/win_mem_alloc.h wresource.h ../graphics/bcg.h \
 ../graphics/../machine.h ../graphics/../config.h \
 ../graphics/ObjectStructure.h ../graphics/../wsci/wgnuplib.h \
 ../graphics/Math.h ../graphics/../os_specific/sci_mem_alloc.h \
 ../graphics/Graphics.h
wprinter.o: wprinter.c wresource.h wcommon.h ../graphics/Math.h \
 ../graphics/../machine.h ../graphics/../config.h \
 ../graphics/../os_specific/sci_mem_alloc.h ../graphics/Graphics.h \
 ../graphics/bcg.h ../graphics/ObjectStructure.h \
 ../graphics/../wsci/wgnuplib.h ../graphics/Math.h
wscilex.o: wscilex.c
wstatbar.o: wstatbar.c Messages.h Warnings.h Errors.h
wtext.o: wtext.c wtext.h wresource.h resource.h wcommon.h \
 ../graphics/Math.h ../graphics/../machine.h ../graphics/../config.h \
 ../graphics/../os_specific/sci_mem_alloc.h ../graphics/Graphics.h \
 ../graphics/bcg.h ../graphics/ObjectStructure.h \
 ../graphics/../wsci/wgnuplib.h ../graphics/Math.h ../version.h \
 ../config.h wmcopydata.h WinConsole.h Messages.h Warnings.h Errors.h \
 ../stack-c.h ../graphics/Math.h ../stack-def.h ../machine.h \
 ../interf/stack1.h ../interf/stack2.h ../interf/stack3.h \
 ../os_specific/win_mem_alloc.h
wtloop.o: wtloop.c wresource.h wcommon.h ../graphics/Math.h \
 ../graphics/../machine.h ../graphics/../config.h \
 ../graphics/../os_specific/sci_mem_alloc.h ../graphics/Graphics.h \
 ../graphics/bcg.h ../graphics/ObjectStructure.h \
 ../graphics/../wsci/wgnuplib.h ../graphics/Math.h \
 ../os_specific/Os_specific.h ../os_specific/../machine.h ../stack-c.h \
 ../graphics/Math.h ../stack-def.h ../machine.h ../interf/stack1.h \
 ../interf/stack2.h ../interf/stack3.h Messages.h Warnings.h Errors.h
x_zzledt.o: x_zzledt.c ../os_specific/win_mem_alloc.h wcommon.h \
 ../graphics/Math.h ../graphics/../machine.h ../graphics/../config.h \
 ../graphics/../os_specific/sci_mem_alloc.h ../graphics/Graphics.h \
 ../graphics/bcg.h ../graphics/ObjectStructure.h \
 ../graphics/../wsci/wgnuplib.h ../graphics/Math.h wtext.h wresource.h \
 resource.h ../version.h ../config.h

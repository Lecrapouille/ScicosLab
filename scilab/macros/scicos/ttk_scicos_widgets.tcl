## ttk_scicos_widgets : a set of tcl/ttk widgets
## author : Alan Layec, xx/08/09

set BWpath [file dirname "$env(SCIPATH)/tcl/bwidget-1.9.13"]
if {[lsearch $auto_path $BWpath]==-1} {
  set auto_path [linsert $auto_path 0 $BWpath]
}
package require BWidget 1.9.13
lappend ::auto_path [file dirname  "$env(SCIPATH)/tcl/bwidget-1.9.13"]
namespace inscope :: package require BWidget

global Gifpath
set Gifpath "$env(SCIPATH)/macros/scicos/scicos_doc/man/gif_icons"

package require Tk
package require Ttk

# Mopeninit : open a file InfIle and update widget
# $pane.text.
#
# Inputs w : Id of the toplevel window of the blk editor
#        InFile : path and and name of the file to open
#
proc Mopeninit {w InFile max_l max_h} {
  set openf $InFile
  $w.mf.note.txt.text delete 1.0 end
  set fid [open $openf r]
  while {![eof $fid]} {
   $w.mf.note.txt.text insert end [read $fid 1000]
  }
  close $fid
  $w.mf.note.txt.text delete {end -1c}
  $w.mf.note.txt.text mark set insert 1.0
  UpdateTextsz $w.mf.note.txt.text $max_l $max_h
  UpdateText $w $w.mf.note.txt
}

# MopeninitGetinfo : open a file InfIle and update widget
# $w.text.
#
# Inputs w : Id of the toplevel window of the blk editor
#        InFile : path and and name of the file to open
#
# AL,1/08/09 : TOBEREVIEWED with popup menu
#
proc MopeninitGetinfo {w InFile} {
  set openf $InFile
  $w.text delete 1.0 end
  set fid [open $openf r]
  while {![eof $fid]} {
   $w.text insert end [read $fid 1000]
  }
  close $fid
  $w.text delete {end -1c}
  $w.text mark set insert 1.0
}

# Msaveinit : write a file InFilewinId from widget
# $pane.text.
#
# Inputs w : Id of the toplevel window of the blk editor
#        InFile : path and and name of the file to open
#        winId : the Tcl/Tk SciGui WinId
#
proc Msaveinit {w InFile winId} {
 set dirdd $InFile$winId
 set openf $dirdd
 set f [open $openf w]
 puts $f [$w.mf.note.txt.text get 1.0 {end -1c}]
 close $f
}


# Msave : save the content of the buffer widget $pane.text.
# in a file provided by tk_getSaveFile
#
# Inputs w : Id of the toplevel window of the blk editor
#
proc Msave {w} {
 set dirdd [tk_getSaveFile -parent $w]
 if {$dirdd != ""} {
   set openf $dirdd
   set f [open $openf w]
   puts $f [$w.mf.note.txt.text get 1.0 {end -1c}]
   close $f
 }
}

# ToCos : save the content of the buffer widget $pane.text.
# in the file OutFilewinId
#
# Inputs w : Id of the toplevel window of the blk editor
#        InFile : path and and name of the file to open
#        OutFile : path and and name of the file to write
#        winId : the Tcl/Tk SciGui WinId
#
proc ToCos {w InFile OutFile winId typ} {
 set dirdd $OutFile$winId
 set openf $dirdd

 set f [open $openf w]
 puts $f [$w.mf.note.txt.text get 1.0 {end -1c}]
 close $f
 ## save ps and dim TCL global vars
 set tt [wm geometry $w]
 set numx -1
 set numy -1
 set edtwidth -1
 set edtheight -1
 regexp -- {([0-9]+)x([0-9]+)\+([0-9]+)\+([0-9]+)} $tt -> \
    edtwidth edtheight numx numy
 if { $typ=="context" } {
   global numxctxt
   global numyctxt
   global ledtxctxt
   global ledtyctxt
   set numxctxt $numx
   set numyctxt $numy
   set ledtxctxt $edtwidth
   set ledtyctxt $edtheight
 }
 if { $typ=="icon" } {
   global numxicon
   global numyicon
   set numxicon $numx
   set numyicon $numy
 }
 if { $typ=="palette" } {
   global numxpal
   global numypal
   set numxpal $numx
   set numypal $numy
 }
 if { $typ=="scsminfo" } {
   global numxscsmi
   global numyscsmi
   set numxscsmi $numx
   set numyscsmi $numy
 }
 if { $typ=="standarddoc" } {
   global numxstddoc
   global numystddoc
   set numxstddoc $numx
   set numystddoc $numy
 }
 if { $typ=="debugblock" } {
   global numxdgblk
   global numydgblk
   set numxdgblk $numx
   set numydgblk $numy
 }
 if { $typ=="Scifunc-1" || $typ=="Scifunc-0" || \
              $typ=="Scifunc-2" || $typ=="Scifunc-3" || \
              $typ=="Scifunc-4" || $typ=="Scifunc-5" || \
              $typ=="Scifunc-6" || $typ=="Scifunc5" } {
   global numxsciblk
   global numysciblk
   set numxsciblk $numx
   set numysciblk $numy
 }
 if { $typ=="Cfunc" } {
   global numxcblk
   global numycblk
   set numxcblk $numx
   set numycblk $numy
 }
 if { $typ=="Ffunc" } {
   global numxfblk
   global numyfblk
   set numxfblk $numx
   set numyfblk $numy
 }
 if { $typ=="ModelicaClass" } {
   global numxmblk
   global numymblk
   set numxmblk $numx
   set numymblk $numy
 }
 regsub -all -- \' $InFile \'\' InFile
 regsub -all -- \' $OutFile \'\' OutFile
 ScilabEval "str_out=ToCos('$InFile','$OutFile','$winId');"
}

# Mquit : close the windows of the buffer : write
# the content of the buffer widget $pane.text in the file
# OutFilewinId
#
# Inputs w : Id of the toplevel window of the blk editor
#        InFile : path and and name of the file to open
#        OutFile : path and and name of the file to write
#        winId : the Tcl/Tk SciGui WinId
#
proc Mquit {w InFile OutFile winId typ} {
 set dirdd $OutFile$winId
 set openf $dirdd
 
 set f [open $openf w]
 puts $f [$w.mf.note.txt.text get 1.0 {end -1c}]
 close $f
 regsub -all -- \' $InFile \'\' InFile
 regsub -all -- \' $OutFile \'\' OutFile
 ScilabEval "Quit=Mquit('$InFile','$OutFile','$winId');"
}

# launch the scicos message aboutscicos
proc AboutHelp { } {
 ScilabEval "do_aboutscicos;"
}

# launch the scicos help browser
proc CosHelp { } {
 ScilabEval "help(\'whatis_scicos\');"
}

# Man page of the Context
proc ContextHelp { } {
 ScilabEval "help(\'Context\');"
}

# Man page of the Debug block
proc DebugHelp { } {
 ScilabEval "help(\'DEBUG_SCICOS\');"
}

# Man page for Modelica
proc ModHelp { } {
 ScilabEval "help(\'MBLOCK\');"
}

# Man page
proc ScsHelp { help } {
 eval "ScilabEval help(\'$help\')"
}

# tk_choose
proc TkChoices {nitems numx numy typ HelpFile clos} {
 global sciGUITable
 global Gifpath

 ## default tk parameters
 global fontsz
 global fonttyp
 global fontstyle1
 global fontstyle2
 global fontstyle3
 global fontstyle
 global TkTheme

 ## default activated toolbars
 global with_tool
 global with_tool_tk
 global with_but

 ## default color for menus
 global activback
 global activfor
 global activbrd

 ## set defaul theme
 ttk::setTheme $TkTheme

 ## look inside the sciGUITable to retrieve te Id of the editor
 set create 1
 foreach winId2 $sciGUITable(win,id) {
   if { [sciGUIGetType $winId2]=="CosChoose" } {
     set create 0; break;
   }
 }

 if { $clos==1 } {
   if { $create==0 } {
     ## get window path
     set w [sciGUIName $winId2]

     ## save the x,y top left coord
     set numxx -1
     set numyy -1
     set width -1
     set height -1
     set t [wm geometry $w]
     regexp -- {([0-9]+)x([0-9]+)\+([0-9]+)\+([0-9]+)} $t -> \
       width height numxx numyy

     if { $typ=="IDfont" } {
       global numxidfont
       global numyidfont
       set numxidfont $numxx
       set numyidfont $numyy
     } else {
       global numxchoose
       global numychoose
       set numxchoose $numxx
       set numychoose $numyy
     }

     ## destroy the window
     sciGUIDestroy $winId2

   }
 } else {
   ## create the window if it doesn't exist
   if { $create==1 } {
     set winId2 [sciGUICreate -1 "CosChoose"]
     set w [sciGUIName $winId2]
     ## compute the top/left position of the window
     if { $numx== -1 } {
       set nnumx [winfo pointerx .]
       set nnumx [ expr $nnumx - 120 ]
       set nnumy [winfo pointery .]
       set nnumy [ expr $nnumy - 5 ]
       wm geometry $w +$nnumx+$nnumy
       #update idletasks
       #set nnumx [ expr $nnumx - [winfo width $w]/2]
     } else {
       set nnumx $numx
       set nnumy $numy
       wm geometry $w +$nnumx+$nnumy
     }

     if { $typ=="IDfont" } {
       set titlewin "Scicos ID font definitions"
     } else {
       set titlewin "Dialog"
     }

     ## redefine a style for combox
     ttk::style configure Ma.TCombobox
     ttk::style map Ma.TCombobox \
       -foreground {{readonly focus} #ffffff} \
       -fieldbackground {{readonly focus} #4a6984 readonly white} \
       -background {active #eeebe7 pressed #eeebe7}

     set width_need 170

     ## main frame
     ttk::frame $w.mf
     pack $w.mf -expand yes -fill both

     ## help message
     set head [GetMsg $HelpFile]
     ttk::label $w.mf.msg -anchor center -text $head
     pack $w.mf.msg -expand yes -fill both -padx 1m -pady 2m

     ## top frame
     ttk::frame $w.mf.top -relief groove -padding [list 0 1m 1m 3m]
     pack $w.mf.top -expand yes -fill both -padx 1m -pady [list 1m 1m]

     ##
     set n ""
     set sep " "
     for {set i 1} {$i <= $nitems} {incr i} {
       set f f$i
       set n $n$f$sep
     }

     foreach i $n {
       ttk::frame $w.mf.top.$i
       pack $w.mf.top.$i -padx [list 1 1] -pady [list 1m 2m] -fill x -expand yes
       ttk::label $w.mf.top.$i.l -anchor w -padding [list 1m 0 1m 0] -wraplength 260
       pack $w.mf.top.$i.l -fill x -expand no -side left
       ttk::combobox $w.mf.top.$i.c -state readonly -takefocus 1 -style Ma.TCombobox 
       pack $w.mf.top.$i.c -fill x -expand yes -side right

       grid $w.mf.top.$i.l -in $w.mf.top.$i -row 0  -column 0 -sticky ew
       grid $w.mf.top.$i.c -in $w.mf.top.$i -row 0  -column 1 -sticky nsew
       grid rowconfigure $w.mf.top.$i 0 -weight 0
       grid columnconfigure $w.mf.top.$i 1 -weight 1

       bind $w.mf.top.$i.c <Key-Return>  {focus [tk_focusNext %W]}
     }

     ## update label and combobox
     foreach i $n {
       global label_$i;
       global c_$i
       global index_$i
       ## inform label
       set l label_$i
       eval "set l $$l"
       $w.mf.top.$i.l config -text $l
       set copie_l $l
       append copie_l "   "
       set cur_need [font measure TkDefaultFont -displayof $w.mf.top.$i.l $copie_l]
       if {$cur_need>$width_need} {set width_need $cur_need}
       ## inform combo
       set c c_$i
       set m ""
       eval "set c_val $$c"
       for {set j 1} {$j <= $c_val} {incr j} {
         set val c_$i$j
         eval "global $val;lappend m $$val"
       }
       set curi index_$i
       eval "set curi $$curi"
       $w.mf.top.$i.c configure -value $m
       $w.mf.top.$i.c current $curi
     }
     if {$width_need > 260} { set width_need 270 }
     foreach i $n { grid columnconfigure $w.mf.top.$i 0 -weight 0 -minsize $width_need }

     ## bottom frame
     ttk::frame $w.mf.bot
     pack $w.mf.bot -expand no -fill x
     ttk::button $w.mf.bot.button1 -text OK -command "GetComboIndex $w $nitems;set done 1" -default active
     ttk::button $w.mf.bot.button2 -text Cancel -command "set done 2"
     pack $w.mf.bot.button1 -side right -padx 1m -pady [list 0 1m]
     pack $w.mf.bot.button2 -side left -padx 1m -pady [list 0 1m]
     bind $w.mf.bot.button1 <Key-Return> "GetComboIndex $w $nitems;set done 1"

     ## setfont
     setfont $w

     ## define initial title
     wm title $w $titlewin

     ## change behavior of the exit button
     wm protocol $w WM_DELETE_WINDOW "set done 2"

     ## add an icon for title bar
     wm iconphoto $w [image create photo -file "$Gifpath/puffin-gtk48.gif"]

     ## patch for windows themes
     if {$TkTheme=="xpnative"} {
       wm attributes $w -toolwindow 1
     }
     if {$TkTheme=="winnative"} {
       wm attributes $w -toolwindow 1
     }
     if {$TkTheme=="vista"} {
       wm attributes $w -toolwindow 1
     }

     ## special bind to take the focus in ScicosLab
     bind $w <<GraphTakeFocus>> "wm attributes $w -topmost 1; focus -force $w;wm attributes $w -topmost 0"

     ##force the focus
     focus -force $w

     ## initial done
     set done 0

     tkwait variable done
   }
 }
}

## get index in the frame top
proc GetComboIndex {w nitems} {
  set n ""
  set sep " "
  for {set i 1} {$i <= $nitems} {incr i} {
    set f f$i
    set n $n$f$sep
   }

   set j 1
   foreach i $n {
      global x$j
      set x$j [$w.mf.top.$i.c current]
      incr j
   }
}

# tk_getvalue
proc TkGetValue {max_l max_h nitems lmax InFile OutFile HelpFile numx numy typ clos} {
 global sciGUITable
 global Gifpath

 ## default tk parameters
 global fontsz
 global fonttyp
 global fontstyle1
 global fontstyle2
 global fontstyle3
 global fontstyle
 global TkTheme

 ## default activated toolbars
 global with_tool
 global with_tool_tk
 global with_but
 global with_xml

 ## default color for menus
 global activback
 global activfor
 global activbrd

 ## set defaul theme
 ttk::setTheme $TkTheme

 ## number of undo/redo
 global undo
 global redo

 ## look inside the sciGUITable to retrieve te Id of the editor
 set create 1
 foreach winId2 $sciGUITable(win,id) {
   if { [sciGUIGetType $winId2]=="CosGetValue" } {
     set create 0; break;
   }
 }

 if { $clos==1 } {
   if { $create==0 } {
     ## get window path
     set w [sciGUIName $winId2]

     ## save the x,y top left coord
     set t [wm geometry $w]
     set numxx -1
     set numyy -1
     set width -1
     set height -1
     regexp -- {([0-9]+)x([0-9]+)\+([0-9]+)\+([0-9]+)} $t -> \
       width height numxx numyy

     if { $typ=="Setup_Scicos" } {
       global numxsetup
       global numysetup
       set numxsetup $numxx
       set numysetup $numyy
     ## TODO Cdgen
     } else {
       global numxgetvalue
       global numygetvalue
       set numxgetvalue $numxx
       set numygetvalue $numyy
     }

     ## destroy the window
     sciGUIDestroy $winId2

   }
 } else {
 ## create the window if it doesn't exist
 if { $create==1 } {
   set winId2 [sciGUICreate -1 "CosGetValue"]
   set w [sciGUIName $winId2]
   ## compute the top/left position of the window
   if { $numx== -1 } {
     set nnumx [winfo pointerx .]
     set nnumx [ expr $nnumx - 120 ]
     set nnumy [winfo pointery .]
     set nnumy [ expr $nnumy - 5 ]
     wm geometry $w +$nnumx+$nnumy
     #update idletasks
     #set nnumx [ expr $nnumx - [winfo width $w]/2]
   } else {
     set nnumx $numx
     set nnumy $numy
      wm geometry $w +$nnumx+$nnumy
   }

   if { $typ=="Setup_Scicos" } {
     set titlewin "Scicos Simulator Parameters"
   } elseif { $typ=="Rename" } {
     set titlewin "Rename"
   } elseif { $typ=="Setup_CodeGen" } {
     set titlewin "Set Code Generation Properties"
   } elseif { $typ=="Resize_block" } {
     set titlewin "Set Block Size"
   } elseif { $typ=="Resize_link" } {
     set titlewin "Set Link Properties"
   } elseif { $typ=="Ident_block" } {
     set titlewin "Set Block Identification"
   } elseif { $typ=="Ident_link" } {
     set titlewin "Set Link Identification"
   } elseif { $typ=="Label_block" } {
     set titlewin "Set Block Label"
   } elseif { $typ=="Grid" } {
     set titlewin "Set Grid Parameters"
   } elseif { $typ=="scicos_debug" } {
     set titlewin "Set Debug Level"
   ## TODO Cdgen
   } else {
     set titlewin "Set Block properties"
   }

   ## define a title for modifed flag
   global is_edited
   set is_edited 0
   set edited " \\\[edited\\\]"
   set sep "\""
   set newtitle $sep$titlewin$edited$sep
   bind $w <<ChangeTitle>> "global is_edited;set is_edited 1;wm title $w $newtitle"

   ## menu
   GetMenu $w
   $w.menubar.file entryconfigure 0 -command "GetEntry $w $nitems;set done 1"
   $w.menubar.file entryconfigure 5 -command "set done 2"

   ## add entry in help menu
   if { $typ!="" && $typ!="Rename" && \
        $typ!="Setup_CodeGen" && $typ!="Resize_block" && \
        $typ!="Resize_link" && $typ!="Ident_block" && \
        $typ!="Ident_link" && $typ!="Label_block" && \
        $typ!="Grid"} {
     set sep " "
     set txt "Help"

     $w.menubar.help entryconfigure 2 -label $typ$sep$txt \
        -command "ScsHelp $typ;set done 3" \
        -compound left -image [image create photo -file "$Gifpath/sblock.gif"]

     $w.menubar.help add separator

     $w.menubar.help add command -label "About Scicos" \
        -command "AboutHelp;set done 3" \
        -compound left -image [image create photo -file "$Gifpath/none.gif"]
   }

   ## add entry in setting menu
   $w.menubar.view delete 2 3

   set with_xml 0
   $w.menubar.view add checkbutton -label "Show XML panel" \
      -offvalue 0 -onvalue 1 -variable with_xml -command "xmlpane $with_xml $w"

   global switchd
   set switchd $with_xml
   proc xmlpane {with_xml w} {
     global switchd
     if $switchd {
       $w.mf.note add $w.mf.note.txt
       set switchd 0
     } else {
       $w.mf.note hide 1
       set switchd 1
     }
   }

   $w.menubar.view add separator

   $w.menubar.view add command -label "Increase size" \
      -command "Mincfont $w" \
      -compound left -image [image create photo -file "$Gifpath/none.gif"] \
      -accelerator Ctrl++
   proc Mincfont {w} {
     global fontsz
     set fontsz [expr {$fontsz + 1}]
     setfont $w
   }

   $w.menubar.view add command -label "Decrease size" \
      -command "Mdecfont $w" \
      -compound left -image [image create photo -file "$Gifpath/none.gif"] \
      -accelerator Ctrl+-
   proc Mdecfont {w} {
     global fontsz
     set fontsz [expr {$fontsz - 1}]
     setfont $w
   }

   ## menu Popup
   GetMpopup $w

   ## toolbar
   GetToolbar $w
   $w.toolbar.button1 configure -command "GetEntry $w $nitems;set done 1"
   $w.toolbar.button2 configure -command "set done 2"

   ## un separator
   ttk::separator $w.sep1

   ## toolbar
   GetTkToolbar $w

   ## un separator
   ttk::separator $w.sep2

   ## main frame
   ttk::frame $w.mf
   pack $w.mf -fill both

   ## help message
   set head [GetMsg $HelpFile]
#    label $w.mf.msg -text $head -bg white
   label $w.mf.msg -text $head -bg white -wraplength 4i -justify left

   # bind $w.mf.msg <<ChangeFont>> {%W configure -font [list $fonttyp $fontsz $fontstyle]}

   ## pane
   ttk::notebook $w.mf.note
   ttk::notebook::enableTraversal $w.mf.note

   ## pane for entries
   GetFrameEntry $w $nitems $lmax

   ## update
   set n ""
   set sep " "
   for {set i 1} {$i <= $nitems} {incr i} {
     set f f$i
     set n $n$f$sep
   }

   set f $w.mf.note.msg

   set width_need 0
   foreach i $n {
     global label_$i; global init_$i;
     set e init_$i; set l label_$i
     eval "set e $$e"; eval "set l $$l"
     $f.$i.label config -text $l
     set copie_l $l
     append copie_l "   "
     set cur_need [font measure TkDefaultFont -displayof $f.$i.label $copie_l]
     if {$cur_need>$width_need} {set width_need $cur_need}
     $f.$i.e.entry insert 0 $e
     # history
     global hist_$i; global ind_$i
     set hist_$i [list $e]
     set ind_$i 0
   }
   ## adjust label width
   if {$width_need > 260} {
     set width_need 270
   }
   foreach i $n {
     grid columnconfigure $f.$i 0 -weight 0 -minsize $width_need
   }

   ## Set pane title
   if { $typ!="" } {
     $w.mf.note add $w.mf.note.msg -text $typ
   } else {
     $w.mf.note add $w.mf.note.msg -text "Getvalue" -underline 0
   }


   ## pane for text
   GetFrameText $w $max_l $max_h
   $w.mf.note.txt.text configure -height 1
   $w.mf.note.txt.text configure -width 1
   $w.mf.note add $w.mf.note.txt -text "XML"

   bind $w.mf.note.txt.text <3> "focus -force %W;UpdateTextNoButtons $w $w.mf.note.txt;PopupNoButtons $w %X %Y;focus %W"
   foreach x [bind Text] {
     bind $w.mf.note.txt.text $x "UpdateTextNoButtons $w $w.mf.note.txt"
     bind $w.mf.note.txt.text <Control-Key-plus> "Mincfont $w"
     bind $w.mf.note.txt.text <Control-Key-minus> "Mdecfont $w"
   }
   bind $w.mf.note.txt.text <KeyPress> "UpdateTextNoButtons $w $w.mf.note.txt"
   bind $w.mf.note.txt.text <KeyRelease> "UpdateTextNoButtons $w $w.mf.note.txt"
   bind $w.mf.note.txt.text <ButtonPress> "UpdateTextNoButtons $w $w.mf.note.txt"
   bind $w.mf.note.txt.text <ButtonRelease> "UpdateTextNoButtons $w $w.mf.note.txt"
   bind $w.mf.note.txt.text <<SelectAll>> [bind Text <Control-Key-slash>]
   bind $w.mf.note.txt.text <<DeSelect>> [bind Text <Control-Key-backslash>]
   bind $w.mf.note.txt.text <<ChangeFont>> {%W configure -font [list $fonttyp $fontsz $fontstyle]}
   bind Text <Control-a> [bind Text <Control-Key-slash>]
   bind Text <Control-c> [bind Text <<Copy>>]
   bind Text <Control-x> {}
   bind Text <Control-v> {}
   bind Text <Control-z> {}
   bind Text <Control-Shift-z> {}

   ## buttons
   GetButtons $w
   $w.mf.buttons.ok configure -command "GetEntry $w $nitems;set done 1"
   $w.mf.buttons.dismiss configure -command "GetEntry $w $nitems;set done 2"
   if { $typ!="" && $typ!="Rename" && \
        $typ!="Setup_CodeGen" && $typ!="Resize_block" && \
        $typ!="Resize_link" && $typ!="Ident_block" && \
        $typ!="Ident_link" && $typ!="Label_block" && \
        $typ!="Grid"} {
     $w.mf.buttons.help configure -command "ScsHelp $typ;set done 3"
     balloon $w.mf.buttons.help "$typ Help"
   } else {
     $w.mf.buttons.help configure -command "CosHelp;set done 3"
   }
   bind $w.mf.buttons.ok <Key-Return> "GetEntry $w $nitems;set done 1"

   ## configure menubar
   $w configure -menu $w.menubar

   ## grid packer
   grid $w.toolbar -sticky ew
   grid $w.sep1 -sticky ew
   grid $w.tk_toolbar -sticky ew
   grid $w.sep2 -sticky ew
   grid $w.mf.msg -sticky ew
   grid $w.mf.note -sticky nsew -padx 1m -pady 1m
   grid $w.mf -sticky nsew -ipadx 1m
   grid $w.mf.buttons -sticky ew

   grid rowconfigure $w $w.mf -weight 2
   grid columnconfigure $w $w.mf -weight 2

   grid rowconfigure $w.mf $w.mf.msg -weight 0
   grid columnconfigure $w.mf $w.mf.msg -weight 1

   grid rowconfigure $w.mf $w.mf.note -weight 1
   grid columnconfigure $w.mf $w.mf.note -weight 1

   grid rowconfigure $w.mf $w.mf.buttons -weight 0
   grid columnconfigure $w.mf $w.mf.buttons -weight 1

   global cur_height
   global cur_width

   set cur_height 0
   set cur_width 0

   proc BindPane {w nitems max_l max_h} {
     global cur_height
     global cur_width
     set undo 0
     set redo 0
     set cur [$w.mf.note index current]

     ## xml pane
     if {$cur==1} {
       ## save the geometry
       set new_height [winfo height $w]
       set new_width [winfo width $w]
       set x x
       if {$cur_height>10} { wm geometry $w $cur_width$x$cur_height }
       set cur_height $new_height
       set cur_width $new_width

       ## focus on text widget
       focus -force $w.mf.note.txt.text

       ## update menus and buttons states
       UpdateTextNoButtons $w $w.mf.note.txt
       $w.toolbar.button5 state disabled
       $w.toolbar.button6 configure -command "CopyNoButtons $w"
       #$w.toolbar.button4 configure -command "MopenText $w $w.mf.note.txt.text $max_l $max_h"
       $w.toolbar.button3 state disabled
       $w.toolbar.button4 state disabled
       $w.menubar.file entryconfigure 2 -state disabled
       $w.menubar.file entryconfigure 3 -state disabled

       ## generate xml text
       CreateXml $w $w.mf.note.txt.text $max_l $max_h
       setfont $w

       $w.toolbar.button6 state disabled
       $w.toolbar.button5 state disabled
       $w.toolbar.button7 state disabled
       $w.toolbar.button8 state disabled
       $w.toolbar.button9 state disabled
       $w.menubar.edit entryconfigure 0 -state disabled
       $w.menubar.edit entryconfigure 1 -command "CopyNoButtons $w"
       $w.menubar.edit entryconfigure 2 -state disabled
       $w.menubar.edit entryconfigure 4 -command "SelectNoButtons $w"
       $w.menubar.edit entryconfigure 5 -command "UnSelectNoButtons $w"
       $w.menubar.edit entryconfigure 7 -state disabled
       $w.menubar.edit entryconfigure 8 -state disabled
       $w.popupMenu entryconfigure 1 -command "CopyNoButtons $w"
       $w.popupMenu entryconfigure 4 -command "SelectNoButtons $w"
       $w.popupMenu entryconfigure 5 -command "UnSelectNoButtons $w"

       ## should be removed
       $w.popupMenu entryconfigure 1 -state disabled
       $w.menubar.edit entryconfigure 1 -state disabled
     ## entry pane
     } else {
       ## save the geometry
       set new_height [winfo height $w]
       set new_width [winfo width $w]
       set x x
       if {$cur_height>10} { wm geometry $w $cur_width$x$cur_height }
       set cur_height $new_height
       set cur_width $new_width

       ## get xml text
       #GetXml $w $w.mf.note.txt.text

       ## update menus and buttons states
       UpdateButtons $w $undo $redo
       $w.menubar.file entryconfigure 2 -command "GetEntry $w $nitems;set done 5" -state normal
       $w.menubar.file entryconfigure 3 -command "GetEntry $w $nitems;set done 4" -state normal
       $w.toolbar.button3 state {!disabled !selected}
       $w.toolbar.button4 state {!disabled !selected}
       $w.toolbar.button3 configure -command "GetEntry $w $nitems;set done 5"
       $w.toolbar.button4 configure -command "GetEntry $w $nitems;set done 4"
       $w.toolbar.button6 configure -command "Copy $w"
       $w.menubar.edit entryconfigure 4 -command "Select $w"
       $w.menubar.edit entryconfigure 5 -command "UnSelect $w"
       $w.popupMenu entryconfigure 4 -command "Select $w"
       $w.popupMenu entryconfigure 5 -command "UnSelect $w"
       $w.popupMenu entryconfigure 1 -command "Copy $w"
     }
  }

   ## bind for Notebook
   bind $w.mf.note <<NotebookTabChanged>> "BindPane $w $nitems $max_l $max_h;"

   ## look at for state of toolbar
   tool $with_tool $w
   tktool $with_tool_tk $w
   butbar $with_but $w
   xmlpane $with_xml $w
   ActivB1B2B3 $w $fontstyle1 $fontstyle2 $fontstyle3
   setfont $w

   ## Generate event of theme combobox (for windows)
   event generate $w.tk_toolbar.combo2 <<ComboboxSelected>>

   ## define initial title
   wm title $w $titlewin

   ## change behavior of the exit button
   wm protocol $w WM_DELETE_WINDOW "GetEntry $w $nitems;set done 2"

   ## add an icon for title bar
   wm iconphoto $w -default [image create photo -file "$Gifpath/puffin-gtk48.gif"]

   ## patch for windows themes
   if {$TkTheme=="xpnative"} {
     wm attributes $w -toolwindow 1
   }
   if {$TkTheme=="winnative"} {
     wm attributes $w -toolwindow 1
   }
   if {$TkTheme=="vista"} {
     wm attributes $w -toolwindow 1
   }

   ## special bind to take the focus in ScicosLab
   bind $w <<GraphTakeFocus>> "wm attributes $w -topmost 1; focus -force $w;wm attributes $w -topmost 0"

   ## initial done
   set done 0

   if { $clos==0 } {
     ## focus on the first entry
     focus -force $w.mf.note.msg.f1.e.entry

     tkwait variable done
   }

  } else {

    ## reentry case
    set w [sciGUIName $winId2]

    set cur [$w.mf.note index current]

    if {$cur==0} {
      ## help message
      set head [GetMsg $HelpFile]

      ## disable update of titlex for that time
      #$w.mf.msg configure -text $head

      ## update
      set n ""
      set sep " "
      for {set i 1} {$i <= $nitems} {incr i} {
        set f f$i
        set n $n$f$sep
      }

      set f $w.mf.note.msg

      set width_need 0
      foreach i $n {
        ## disable update of label for that time
        #global label_$i
        #set l label_$i
        #eval "set l $$l"
        #$f.$i.label config -text $l
        #set copie_l $l
        #append copie_l "   "
        #set cur_need [font measure TkDefaultFont -displayof $f.$i.label $copie_l]
        #if {$cur_need>$width_need} {set width_need $cur_need}

        global init_$i;
        set e init_$i;
        eval "set e $$e";
        $f.$i.e.entry delete 0 end
        $f.$i.e.entry insert 0 $e
        # history
        global hist_$i; global ind_$i
        set hist_$i [list $e]
        set ind_$i 0
      }
      global is_edited
      if $is_edited {
        event generate $w <<ChangeTitle>>
      }
    }

    if { $clos==0 } {
      tkwait variable done
    }

  }
 }
}

## get values of entries in the panel
proc GetEntry {w nitems} {
  global parentwin
  set parentwin $w
  set n ""
  set sep " "
  for {set i 1} {$i <= $nitems} {incr i} {
    set f f$i
    set n $n$f$sep
   }
   set f $w.mf.note.msg
   set j 1
   foreach i $n {
      global x$j
      set x$j [$f.$i.e.entry get]
      incr j
   }
}

## hilite an entry
proc HiliteEntry { item } {
 global sciGUITable

 set create 1
 foreach winId2 $sciGUITable(win,id) {
   if { [sciGUIGetType $winId2]=="CosGetValue" } {
     set create 0; break;
   }
 }

 if { $create==0 } {
   ## get the path of the form getvalue
   set w [sciGUIName $winId2]

   ## change the current pane if needed
   set cur [$w.mf.note index current]
   if {$cur!=0} {$w.mf.note select 0}

   # By prepending another name ("Emergency") followed by a dot onto an existing style,
   # you are implicitly creating a new style derived from the existing one.
   # So in this example, our new style will have exactly the same options as a regular
   # button except for the indicated differences...
   # http://www.tkdocs.com/tutorial/styles.html
   ttk::style configure Hilite.TEntry -fieldbackground red

   ## focus on the required entry
   $w.mf.note.msg.f$item.e.entry configure -style Hilite.TEntry
   focus $w.mf.note.msg.f$item.e.entry
 }

}

## unhilite an entry
proc UnHiliteEntry { item } {
 global sciGUITable

 set create 1
 foreach winId2 $sciGUITable(win,id) {
   if { [sciGUIGetType $winId2]=="CosGetValue" } {
     set create 0; break;
   }
 }

 if { $create==0 } {
   ## get the path of the form getvalue
   set w [sciGUIName $winId2]

   ## focus on the required entry
   $w.mf.note.msg.f$item.e.entry configure -style TEntry
   focus -force $w
   focus $w.mf.note.msg.f$item.e.entry
 }

}

# ScsTxtEdit : main procedure of the text editor
#
# Inputs InFile : path and and name of the file to open
#        OutFile : path and and name of the file to write
#        max_h/max_l : display size of the buffer
#        numx/numy : the initial position of windows
#        clos : a flag to close the window
#
proc ScsTxtEdit {InFile OutFile max_l max_h HelpFile max_ll max_hh ledtx ledty numx numy typ clos} {

 global sciGUITable
 global Gifpath
 global fontsz
 global fonttyp
 global fontstyle1
 global fontstyle2
 global fontstyle3
 global fontstyle
 global TkTheme

 ## default toolbars
 global with_tool
 global with_tool_tk
 global with_but

 ## default color for menus
 global activback
 global activfor
 global activbrd

 ## set defaul theme
 ttk::setTheme $TkTheme

 ## number of undo/redo
 global undo
 global redo
 set undo 0
 set redo 0

 ## look inside the sciGUITable to retrieve te Id of the editor
 set create 1
 foreach winId2 $sciGUITable(win,id) {
   if { [sciGUIGetType $winId2]=="CosTxtEditor" } {
     set create 0; break;
   }
 }

 if { $clos==1 } {
   if { $create==0 } {
     set w [sciGUIName $winId2]
     sciGUIDestroy $winId2
   }
 } else {
 ## create the window if it doesn't exist
 if { $create==1 } {
   set winId2 [sciGUICreate -1 "CosTxtEditor"]
   set w [sciGUIName $winId2]
   ## compute the top/left position of the window
   if { $numx== -1 } {
     set nnumx [winfo pointerx .]
     set nnumx [ expr $nnumx - 120 ]
     set nnumy [winfo pointery .]
     set nnumy [ expr $nnumy - 5 ]
     #update idletasks
     #set nnumx [ expr $nnumx - [winfo width $w]/2]
   } else {
     set nnumx $numx
     set nnumy $numy
   }
   wm geometry $w +$nnumx+$nnumy

   ## set title
   if { $typ=="context" } {
     set titlewin "Context"
   } elseif { $typ=="icon" } {
     set titlewin "Icon"
   } elseif { $typ=="palette" } {
     set titlewin "Palette editor"
   } elseif { $typ=="Cfunc" } {
     set titlewin "C function"
   } elseif { $typ=="Ffunc" } {
     set titlewin "Fortran function"
   } elseif { $typ=="ModelicaClass" } {
     set titlewin "Modelica class"
   } elseif { $typ=="scsminfo" } {
     set titlewin "Diagram Information"
   } elseif { $typ=="standarddoc" } {
     set titlewin "Standard Block Documentation"
   } elseif { $typ=="debugblock" } {
     set titlewin "Block debug"
   } elseif { $typ=="Scifunc-1" || $typ=="Scifunc-0" || \
              $typ=="Scifunc-2" || $typ=="Scifunc-3" || \
              $typ=="Scifunc-4" || $typ=="Scifunc-5" || \
              $typ=="Scifunc-6" || $typ=="Scifunc5" } {
     set titlewin "ScicosLab block"
   } else {
     set titlewin "Block Editor ($winId2)"
   }

   ## define a title for modifed flag
   set edited " \\\[edited\\\]"
   set sep "\""
   set newtitle $sep$titlewin$edited$sep
   bind $w <<ChangeTitle>> "wm title $w $newtitle"

   ## menu
   GetMenu $w
   $w.menubar.file entryconfigure 0 -command "ToCos $w $InFile $OutFile $winId2 $typ;set done 1"
   $w.menubar.file entryconfigure 2 -command "Msave $w;set done 1"
   $w.menubar.file entryconfigure 3 -command "MopenText $w $w.mf.note.txt.text $max_l $max_h;set done 1"
   $w.menubar.file entryconfigure 5 -command "Mquit $w $InFile $OutFile $winId2 $typ;set done 2"

   ##edit
   $w.menubar.edit add separator
   $w.menubar.edit add command -label "Go to line" \
         -command "focus $w.mf.note.txt.statbar2" \
         -accelerator "Ctrl+g"
   $w.menubar.edit add separator
   $w.menubar.edit add command -label "Find" \
         -command "focus $w.mf.note.txt.statbar5" \
         -accelerator "Ctrl+f"
   $w.menubar.edit add command -label "Find Next" \
         -command "event generate $w.mf.note.txt.statbar5 <<Key-Return>>" \
         -accelerator "F3"
   $w.menubar.edit add command -label "Find Prev" \
         -command "event generate $w.mf.note.txt.statbar5 <<ShiftF3>>" \
         -accelerator "Shift+F3"
   
   if { $typ=="context" } {
     $w.menubar.help entryconfigure 2 -label "Context Help" \
        -command "ContextHelp;set done 3" \
        -compound left -image [image create photo -file "$Gifpath/sblock.gif"]

     $w.menubar.help add separator

     $w.menubar.help add command -label "About Scicos" \
        -command "AboutHelp;set done 3" \
        -compound left -image [image create photo -file "$Gifpath/none.gif"]

   } elseif { $typ=="debugblock" } {
     $w.menubar.help entryconfigure 2 -label "Scicos Debug Help" \
        -command "DebugHelp;set done 3" \
        -compound left -image [image create photo -file "$Gifpath/sblock.gif"]

     $w.menubar.help add separator

     $w.menubar.help add command -label "About Scicos" \
        -command "AboutHelp;set done 3" \
        -compound left -image [image create photo -file "$Gifpath/none.gif"]

   } elseif { $typ=="ModelicaClass" } {
     $w.menubar.help entryconfigure 2 -label "Modelica Help" \
        -command "ModHelp;set done 3" \
        -compound left -image [image create photo -file "$Gifpath/sblock.gif"]

     $w.menubar.help add separator

     $w.menubar.help add command -label "About Scicos" \
        -command "AboutHelp;set done 3" \
        -compound left -image [image create photo -file "$Gifpath/none.gif"]
   }

   ## menu Popup
   GetMpopup $w

   ## toolbar
   GetToolbar $w
   $w.toolbar.button1 configure -command "ToCos $w $InFile $OutFile $winId2 $typ;set done 1"
   $w.toolbar.button2 configure -command "Mquit $w $InFile $OutFile $winId2 $typ;set done 2"
   $w.toolbar.button3 configure -command "Msave $w;set done 1"
   $w.toolbar.button4 configure -command "MopenText $w $w.mf.note.txt.text $max_l $max_h;set done 1"

   ## un separator
   ttk::separator $w.sep1

   ## toolbar
   GetTkToolbar $w

   ## un separator
   ttk::separator $w.sep2

   ## main frame
   ttk::frame $w.mf
   pack $w.mf -fill both

   ## help message
   set head [GetMsg $HelpFile]
   label $w.mf.msg -text $head -bg white -wraplength 4i -justify left
#    ttk::label $w.mf.msg -text $head -anchor c

   # bind $w.mf.msg <<ChangeFont>> {%W configure -font [list $fonttyp $fontsz $fontstyle]}

   ## buttons
   GetButtons $w
   $w.mf.buttons.ok configure -command "ToCos $w $InFile $OutFile $winId2 $typ;set done 1"
   $w.mf.buttons.dismiss configure -command "Mquit $w $InFile $OutFile $winId2 $typ;set done 2"
   if { $typ=="context" } {
     $w.mf.buttons.help configure -command "ContextHelp;set done 3"
     balloon $w.mf.buttons.help "Context Help"
   } elseif { $typ=="debugblock" } {
     $w.mf.buttons.help configure -command "DebugHelp;set done 3"
     balloon $w.mf.buttons.help "Debug Help"
   } elseif { $typ=="ModelicaClass" } {
     $w.mf.buttons.help configure -command "ModHelp;set done 3"
     balloon $w.mf.buttons.help "Modelica Help"
   } else {
     $w.mf.buttons.help configure -command "CosHelp;set done 3"
     balloon $w.mf.buttons.help "Help"
   }
   bind $w.mf.buttons.ok <Key-Return> "ToCos $w $InFile $OutFile $winId2 $typ;set done 1"

   ## configure menubar
   $w configure -menu $w.menubar

   ## set dim of the window
   if { $ledtx != -1 } {
      #geometry $w ${ledtx}x${ledty}
   }

   ## pane
   ttk::notebook $w.mf.note
   ttk::notebook::enableTraversal $w.mf.note

   ## pane text
   GetFrameText $w $max_l $max_h

   if { $typ=="Scifunc-1" } {
     $w.mf.note add $w.mf.note.txt -text "- flag 1 -"
   } elseif { $typ=="Scifunc-0" } {
     $w.mf.note add $w.mf.note.txt -text "- flag 0 -"
   } elseif { $typ=="Scifunc-2" } {
     $w.mf.note add $w.mf.note.txt -text "- flag 2 -"
   } elseif { $typ=="Scifunc-3" } {
     $w.mf.note add $w.mf.note.txt -text "- flag 3 -"
   } elseif { $typ=="Scifunc-4" } {
     $w.mf.note add $w.mf.note.txt -text "- flag 4 -"
   } elseif { $typ=="Scifunc-5" } {
     $w.mf.note add $w.mf.note.txt -text "- flag 5 -"
   } elseif { $typ=="Scifunc-6" } {
     $w.mf.note add $w.mf.note.txt -text "- flag 6 -"
   } else {
      $w.mf.note add $w.mf.note.txt -text $titlewin
   }

   ## grid packer
   grid $w.toolbar -sticky ew
   grid $w.sep1 -sticky ew
   grid $w.tk_toolbar -sticky ew
   grid $w.sep2 -sticky ew
   grid $w.mf.msg -sticky nsew
   grid $w.mf.note -sticky nsew -padx 1m -pady 1m
   grid $w.mf -sticky nsew -ipadx 1m
   grid $w.mf.buttons -sticky ew
   grid rowconfigure $w $w.mf -weight 2
   grid columnconfigure $w $w.mf -weight 2
   grid rowconfigure $w.mf $w.mf.note -weight 3
   grid columnconfigure $w.mf $w.mf.note -weight 3

   ## initial import of buffer
   Mopeninit $w $InFile $max_l $max_h
   Msaveinit $w $InFile $winId2

   ## initial state of the editor buffer
   $w.mf.note.txt.text edit modified false
   $w.mf.note.txt.text edit reset

   ## define initial title
   wm title $w $titlewin

   ## change behavior of the exit button
   wm protocol $w WM_DELETE_WINDOW "Mquit $w $InFile $OutFile $winId2 $typ;set done 2"

   ## focus on the text widget
   focus -force $w.mf.note.txt.text
   UpdateText $w $w.mf.note.txt

   ## update current state of the toolbars
   tool $with_tool $w
   tktool $with_tool_tk $w
   butbar $with_but $w
   ActivB1B2B3 $w $fontstyle1 $fontstyle2 $fontstyle3
   setfont $w

   ## add an icon for title bar
   wm iconphoto $w [image create photo -file "$Gifpath/puffin-gtk48.gif"]

   ## patch for windows themes
   if {$TkTheme=="xpnative"} {
     wm attributes $w -toolwindow 1
   }
   if {$TkTheme=="winnative"} {
     wm attributes $w -toolwindow 1
   }
   if {$TkTheme=="vista"} {
     wm attributes $w -toolwindow 1
   }

   ## special bind to take the focus in ScicosLab
   bind $w <<GraphTakeFocus>> "wm attributes $w -topmost 1; focus -force $w;wm attributes $w -topmost 0"

   set done 0

   tkwait variable done
  }
 }
}

## procedure balloon
## origin http://wiki.tcl.tk/1109
proc balloon {w help} {
  bind $w <Any-Enter> "after 2000 [list balloon:show %W [list $help]]"
  bind $w <Any-Leave> "destroy %W.balloon"
  bind $w <KeyPress> "destroy %W.balloon"
  bind $w <ButtonPress> "destroy %W.balloon"
}
proc balloon:show {w arg} {
  if {[eval winfo containing  [winfo pointerxy .]]!=$w} {return}
  set top $w.balloon
  catch {destroy $top}
  toplevel $top -bd 1 -bg black
  wm overrideredirect $top 1
  if {[string equal [tk windowingsystem] aqua]}  {
      ::tk::unsupported::MacWindowStyle style $top help none
  }
  pack [message $top.txt -aspect 10000 -bg lightblue \
          -font fixed -text $arg -padx 2]
  set wmx [winfo pointerx $w]
  set wmy [expr [winfo rooty $w]+[winfo height $w]]
  wm geometry $top \
     [winfo reqwidth $top.txt]x[winfo reqheight $top.txt]+$wmx+$wmy
  raise $top
}

# GetInfo : main procedure of the GetInfo window
#
# Inputs InFile : path and and name of the file to open
#        max_h/max_l : display size of the buffer
#        numx/numy : the initial position of windows
#
proc GetInfo {InFile max_l max_h numx numy } {

  global Gifpath
  global TkTheme

  set winId2 [sciGUICreate -1 "GetInfo"]
  set w [sciGUIName $winId2]
  wm title $w "GetInfo ($winId2)"

   ## compute the top/left position of the window
  ttk::frame $w.top
  text $w.top.text \
     -background white \
     -width $max_l\
     -height $max_h \
     -yscrollcommand "$w.top.scroll set"
  ttk::scrollbar $w.top.scroll -command "$w.top.text yview"
  pack $w.top.scroll -side right -fill y
  pack $w.top.text -expand yes -fill both
  # pack  $w.top -fill both -expand yes -padx [list 4 0]
  grid $w.top -row 0 -sticky nsew -padx [list 1m 1m] -pady [list 1m 1m]

  ttk::frame $w.bot
  ttk::button $w.bot.quit -text Close -command "sciGUIDestroy $winId2" -default active
  pack $w.bot.quit -side left -expand 0 -fill x
  # pack $w.bot -side bottom -expand 0 -fill both
  grid $w.bot -row 1 -sticky nsew -padx [list 1m 1m] -pady [list 0 1m]

  grid rowconfigure $w 0 -weight 1
  grid columnconfigure $w 0 -weight 1

  ## compute the top/left position of the window
  if { $numx== -1 } {
    set nnumx [winfo pointerx .]
    set nnumx [ expr $nnumx - 120 ]
    #update idletasks
    #set nnumx [ expr $nnumx - [winfo width $w]/2]
  } else {
    set nnumx $numx
  }
  if { $numy== -1 } {
    set nnumy [winfo pointery .]
    set nnumy [ expr $nnumy - 5 ]
  } else {
    set nnumy $numy
  }
  wm geometry $w +$nnumx+$nnumy

  ttk::setTheme $TkTheme

  ## initial import of buffer
  MopeninitGetinfo $w.top $InFile

  $w.top.text configure -state disabled

  ## add an icon for title bar
  wm iconphoto $w [image create photo -file "$Gifpath/puffin-gtk48.gif"]

  ## patch for windows themes
  if {$TkTheme=="xpnative"} {
    wm attributes $w -toolwindow 1
  }
  if {$TkTheme=="winnative"} {
    wm attributes $w -toolwindow 1
  }
  if {$TkTheme=="vista"} {
    wm attributes $w -toolwindow 1
  }

}

# ClosScsTxtEdit : main procedure to close the text editor
#
proc ClosScsTxtEdit {} {
 ## look inside the sciGUITable to retrieve te Id of the editor
 global sciGUITable
 foreach winId2 $sciGUITable(win,id) {
   if { [sciGUIGetType $winId2]=="CosTxtEditor" } {
     sciGUIDestroy $winId2
   }
 }
}

proc setfont {w} {

  global fonttyp
  global fontsz
  global fontstyle1
  global fontstyle2
  global fontstyle3

  set fontstyles $fontstyle3$fontstyle2$fontstyle1

  global fontstyle
  set fontstyle "normal"

  if { $fontstyles=="000" } {
    set fontstyle "normal"
  } elseif { $fontstyles=="001" } {
    set fontstyle "bold"
  } elseif { $fontstyles=="010" } {
    set fontstyle "italic"
  } elseif { $fontstyles=="011" } {
    set fontstyle "bold italic"
  } elseif { $fontstyles=="100" } {
    set fontstyle "underline"
  } elseif { $fontstyles=="101" } {
    set fontstyle "underline bold"
  } elseif { $fontstyles=="110" } {
    set fontstyle "underline italic"
  } elseif { $fontstyles=="111" } {
    set fontstyle "underline bold italic"
  }

  ## generate event <<ChangeFont>>
  ## for all children of mf
  proc callchildren {w} {
    foreach i [winfo children $w] {
      event generate $i <<ChangeFont>>
      callchildren $i
    }
  }
  callchildren $w.mf

}

## compute number of lines
## max character per lines
proc UpdateTextsz {txt max_l max_h} {

  set n [$txt index "insert"]
  set lc [split $n .]
  set l_str [lindex $lc 0]
  set max_col 0

  for {set i 0} {$i < $l_str} {incr i} {
    set n [$txt search "\n" $i.0]
    set lc [split $n .]
    set c_str [lindex $lc 1]
    if {$c_str>$max_col} {set max_col $c_str}
  }

  set cur_h [$txt cget -height]
  set cur_l [$txt cget -width]

  if {$cur_h<$l_str} {
    if {$l_str>=$max_h} {
      $txt configure -height [expr $max_h]
    } else {
      $txt configure -height [expr $l_str]
    }
  }

  if {$cur_l<$max_col} {
    if {$max_col>=$max_l} {
      $txt configure -width [expr $max_l]
    } else {
      $txt configure -width [expr $max_col]
    }
  }
}

# MopenText : open a file from  tk_getOpenFile and update
#             a widget Tk text widget
#
# Inputs w : Id of the toplevel window of the blk editor
#        txt : the target Tk text widget
#
proc MopenText {w txt max_l max_h} {
  set dirdd [tk_getOpenFile -parent $w]
  if {$dirdd != ""} {
    set openf $dirdd
    $txt delete 1.0 end
    set fid [open $openf r]
    while {![eof $fid]} {
     $txt insert end [read $fid 1000]
    }
    close $fid

    ## update size of the text widget
    UpdateTextsz $txt $max_l $max_h

    ## update cursor index
    $txt mark set insert 1.0

    ## update buttons and statbar
    UpdateText $w $w.mf.note.txt
  }
}

## get the xml text
proc GetXml {w txt} {
  set full_content [$txt dump 1.0 end]
  set length [llength $full_content]
  for {set i 0} {$i < $length} {incr i} {
    switch [lindex $full_content $i] {
      text {
            incr i
            }
      tagon {
             incr i
            }
      tagoff {
              incr i
            }
    }
  }

}

## generate a xml text
proc CreateXml {w txt max_l max_h} {

  global fonttyp
  global fontsz
  global fontstyle2
  global fontstyle3

  set version "scicos4.4"
  set blknam "BLK_tcl"
  set typ "?"
  set sz "1"
  set widget "entry"

  ## initial state of the editor buffer
  set ismodified [$txt edit modified]
  if {!$ismodified} {
    bind $txt <<Modified>> {}
  }

  ## define tag
  $txt tag configure normal -font "\"$fonttyp\" $fontsz normal"
  $txt tag configure bold   -font "\"$fonttyp\" $fontsz bold"
  $txt tag configure rouge  -foreground DarkRed -font "\"$fonttyp\" $fontsz normal"
  $txt tag configure vert   -foreground DarkGreen -font "\"$fonttyp\" $fontsz normal"
  $txt tag configure bleu   -foreground DarkBlue -font "\"$fonttyp\" $fontsz normal"

  $txt tag configure titlex -foreground DarkGrey -font "\"$fonttyp\" $fontsz normal"
  $txt tag configure lab    -foreground Grey -font "\"$fonttyp\" $fontsz normal"
  $txt tag configure value  -font "\"$fonttyp\" $fontsz normal"

  $txt tag configure blknam  -foreground DarkRed -font "\"$fonttyp\" $fontsz normal"
  $txt tag configure version -foreground DarkRed -font "\"$fonttyp\" $fontsz normal"
  $txt tag configure typ     -foreground DarkRed -font "\"$fonttyp\" $fontsz normal"
  $txt tag configure siz     -foreground DarkRed -font "\"$fonttyp\" $fontsz normal"
  $txt tag configure wid     -foreground DarkRed -font "\"$fonttyp\" $fontsz normal"

#   $txt tag bind bold <1> "$txt configure -state disable"
#   $txt tag bind normal <1> "$txt configure -state disable"
#   $txt tag bind vert <1> "$txt configure -state disable"
#   $txt tag bind titlex <1> "$txt configure -state disable"
#   $txt tag bind lab <1> "$txt configure -state disable"
#   $txt tag bind value <1> "$txt configure -state normal"
#   $txt tag bind blknam <1> "$txt configure -state disable"
#   $txt tag bind version <1> "$txt configure -state disable"
#   $txt tag bind typ <1> "$txt configure -state disable"
#   $txt tag bind siz <1> "$txt configure -state disable"
#   $txt tag bind wid <1> "$txt configure -state disable"

  ## delete all text in the widget
  $txt delete 1.0 end

  $txt insert end "<?xml" bold
  $txt insert end " version=\"1.0\" encoding=\"ISO-8859-1\"" normal
  $txt insert end "?>" bold
  $txt insert end "\n\n" normal
  $txt insert end "<ScicosExprs " bold
  $txt insert end "Name=\"" vert
  $txt insert end $blknam blknam
  $txt insert end "\" version=\"" vert
  $txt insert end $version version
  $txt insert end "\"" vert
  $txt insert end ">" bold
  $txt insert end "\n" normal
  $txt insert end "<titlex>\n" bold
  $txt insert end [$w.mf.msg cget -text] titlex
  $txt insert end "\n</titlex>\n\n" bold

  set j 0
  foreach i [winfo children $w.mf.note.msg] {

    incr j
    global typ_f$j
    set t typ_f$j
    eval "set t $$t"

    $txt insert end "<Exprs_item " bold
    $txt insert end "type=\"" vert
    $txt insert end [lindex $t 0] typ
    $txt insert end "\" size=\"" vert
    $txt insert end [lindex $t 1] siz
    $txt insert end "\" widget=\"" vert
    $txt insert end $widget wid
    $txt insert end "\"" vert
    $txt insert end ">\n" bold

    $txt insert end "<Exprs_label>\n" bold
    $txt insert end [$i.label cget -text] lab
    $txt insert end "\n</Exprs_label>\n" bold

    $txt insert end "<Exprs_value>\n" bold
    $txt insert end [$i.e.entry get] value
    $txt insert end "\n</Exprs_value>\n" bold

    $txt insert end "</Exprs_item>\n\n" bold
  }
  $txt insert end "</ScicosExprs>" bold

  ## update size of the widget text
  UpdateTextsz $txt $max_l $max_h

  ##update cursor index
  $txt mark set insert 1.0

  ## update buttons and statbar
  UpdateText $w $w.mf.note.txt

  ## initial state of the editor buffer
  if {$ismodified==0} {
    $txt edit modified false
    $txt edit reset
    bind $txt <<Modified>> "UpdateText $w $w.mf.note.txt; event generate $w <<ChangeTitle>>"
  }

  $txt configure -state disable

}

proc UpdateTextNoButtons {w txt} {
  updatePos $txt
}

proc UpdateText {w txt} {
  global undo;global redo;
  set undo 1;set redo 1
  UpdateButtons $w $undo $redo
  updatePos $txt
}

proc updatePos {w} {
  set n [$w.text index "insert"]
  set lc [split $n .]
  set l_str [lindex $lc 0]
  set c_str [lindex $lc 1]
  set c_str [expr $c_str + 1]
  
  $w.statbar2 delete 0 end
  $w.statbar2 insert 0 $l_str

  $w.statbar3 configure -text " Col: $c_str "
}

proc Select {w} {
  global undo;global redo;
  set txt [focus -displayof $w]
  event generate $txt <<SelectAll>>
  UpdateButtons $w $undo $redo
}
proc SelectNoButtons {w} {
  global undo;global redo;
  set txt [focus -displayof $w]
  event generate $txt <<SelectAll>>
}
proc UnSelect {w} {
  global undo;global redo;
  set txt [focus -displayof $w]
  event generate $txt <<DeSelect>>
  UpdateButtons $w $undo $redo
}
proc UnSelectNoButtons {w} {
  global undo;global redo;
  set txt [focus -displayof $w]
  event generate $txt <<DeSelect>>
}
proc Cut {w} {
  global redo;
  set undo 1
  set txt [focus -displayof $w]
  event generate $txt <<Cut>>
  event generate $w <<ChangeTitle>>
  UpdateButtons $w $undo $redo
}
proc CopyNoButtons {w} {
  global undo;global redo;
  set txt [focus -displayof $w]
  event generate $txt <<Copy>>
}
proc Copy {w} {
  global undo;global redo;
  set txt [focus -displayof $w]
  event generate $txt <<Copy>>
  UpdateButtons $w $undo $redo
}
proc Paste {w} {
  global redo;
  set undo 1
  set txt [focus -lastfor $w]
  event generate $txt <<Paste>>
  event generate $w <<ChangeTitle>>
  UpdateButtons $w $undo $redo
}
proc Undo {w} {
  global redo
  global undo
  set txt [focus -displayof $w]
  event generate $txt <<Undo>>
#     incr redo
#     incr undo -1
  UpdateButtons $w $undo $redo
}
proc Redo {w} {
  global redo
  global undo
  set txt [focus -displayof $w]
  event generate $txt <<Redo>>
  UpdateButtons $w $undo $redo
}
proc UndoEntry {w e i} {
  ## update history
  global hist_$i
  global ind_$i
  set f $w.mf.note.msg
  eval "set hist hist_$i"
  eval "set ind ind_$i"
  eval "set curind $$ind"
  eval "set lenh \[expr \[llength $$hist\] - 1 \]"

  if {$curind != 0} {
    eval "set ind_$i \[expr $$ind - 1 \]"
    eval "set ind ind_$i"
    eval "set lasth \[lindex $$hist $$ind\]"
    $f.$i.e.entry delete 0 end
    $f.$i.e.entry insert 0 $lasth
  }

  UpdateEntry $w $e $i
}

proc RedoEntry {w e i} {
  global undo;global redo;
  ##TODO if necessary
  UpdateButtons $w $undo $redo
}

proc UpdateEntry {w e i} {
  global undo
  global redo

  set redo 0

  global hist_$i
  global ind_$i
  set f $w.mf.note.msg
  eval "set hist hist_$i"
  eval "set ind ind_$i"
  eval "set lenh \[expr \[llength $$hist\] - 1 \]"
  #eval "set lasth \[lindex $$hist $lenh\]"
  eval "set lasth \[lindex $$hist $$ind\]"
  if {$lasth != [$e get]} {
    ## change title
    event generate $w <<ChangeTitle>>
    ## update history
    lappend hist_$i [$e get]
    incr ind_$i
  }

  eval "set curind $$ind"
  if {$curind != 0} {
    set undo 1
  } else {
    set undo 0
  }

  UpdateButtons $w $undo $redo
}

proc PopupNoButtons {w X Y} {
  $w.popupMenu entryconfigure 0 -state disabled
  $w.popupMenu entryconfigure 1 -state disabled
  $w.popupMenu entryconfigure 2 -state disabled
  $w.popupMenu entryconfigure 7 -state disabled
  $w.popupMenu entryconfigure 8 -state disabled

  $w.popupMenu entryconfigure 5 -state normal
  $w.menubar.edit entryconfigure 5 -state normal

  tk_popup $w.popupMenu $X $Y
}

proc Popup {w X Y} {
  global undo
  global redo
  if {$undo==0} {
    $w.popupMenu entryconfigure 7 -state disabled
  } else {
    $w.popupMenu entryconfigure 7 -state normal
  }
  if {$redo==0} {
    $w.popupMenu entryconfigure 8 -state disabled
  } else {
    $w.popupMenu entryconfigure 8 -state normal
  }
  set txt [focus -displayof $w]
  if {[catch {$txt index sel.first}]} {
    $w.popupMenu entryconfigure 0 -state disabled
    $w.popupMenu entryconfigure 1 -state disabled
    $w.popupMenu entryconfigure 2 -state normal
    $w.popupMenu entryconfigure 5 -state disabled
  } else {
    $w.popupMenu entryconfigure 0 -state normal
    $w.popupMenu entryconfigure 1 -state normal
    $w.popupMenu entryconfigure 2 -state normal
    $w.popupMenu entryconfigure 5 -state normal
  }

  tk_popup $w.popupMenu $X $Y
}

proc UpdateButtons {w undo redo} {
  if {$undo==0} {
    $w.toolbar.button8 state disabled
    $w.menubar.edit entryconfigure 7 -state disabled
  } else {
    $w.toolbar.button8 state {!disabled !selected}
    $w.menubar.edit entryconfigure 7 -state normal
  }
  if {$redo==0} {
    $w.toolbar.button9 state disabled
    $w.menubar.edit entryconfigure 8 -state disabled
  } else {
    $w.toolbar.button9 state {!disabled !selected}
    $w.menubar.edit entryconfigure 8 -state normal
  }

  if {[catch {selection get -displayof $w -selection CLIPBOARD -type STRING} data]} {
    $w.menubar.edit entryconfigure 2 -state disabled
    $w.toolbar.button7 state disabled
  } else {
    $w.menubar.edit entryconfigure 2 -state normal
    $w.toolbar.button7 state {!disabled !selected}
  }

  set txt [focus -displayof $w]
  if {[catch {$txt index sel.first}]} {
    $w.menubar.edit entryconfigure 0 -state disabled
    $w.menubar.edit entryconfigure 1 -state disabled
    $w.menubar.edit entryconfigure 5 -state disabled
    $w.toolbar.button5 state disabled
    $w.toolbar.button6 state disabled
  } else {
    $w.menubar.edit entryconfigure 0 -state normal
    $w.menubar.edit entryconfigure 1 -state normal
    $w.menubar.edit entryconfigure 5 -state normal
    $w.toolbar.button5 state {!disabled !selected}
    $w.toolbar.button6 state {!disabled !selected}
  }
}

## toolbar
proc GetToolbar { w } {
  global Gifpath

  set t [frame $w.toolbar -relief flat]
  ttk::frame $t.tearoff -cursor fleur
  ttk::separator $t.tearoff.to -orient vertical
  ttk::separator $t.tearoff.to2 -orient vertical
  pack $t.tearoff.to -fill y -expand 1 -padx 2 -side left
  pack $t.tearoff.to2 -fill y -expand 1 -side left
  ttk::frame $t.contents
  grid $t.tearoff $t.contents -sticky nsew
  grid columnconfigure $t $t.contents -weight 1
  grid columnconfigure $t.contents 1000 -weight 1
  bind $t.tearoff     <B1-Motion> [list tearoff1 $w $t %X %Y]
  bind $t.tearoff.to  <B1-Motion> [list tearoff1 $w $t %X %Y]
  bind $t.tearoff.to2 <B1-Motion> [list tearoff1 $w $t %X %Y]
  proc tearoff1 {w t x y} {
    if {[string match $t* [winfo containing $x $y]]} {
      return
    }
    grid remove $t
    grid remove $t.tearoff
    wm manage $t
    wm protocol $t WM_DELETE_WINDOW [list untearoff1 $w $t]
    grid remove $w.sep1
    $w.menubar.view.tools entryconfigure 0 -state disabled
  }
  proc untearoff1 {w t} {
    wm forget $t
    grid $t.tearoff
    grid $t
    grid $w.sep1
    $w.menubar.view.tools entryconfigure 0 -state normal
  }

  ttk::button $t.button1 -image [image create photo -file "$Gifpath/check.gif"] -takefocus 0 -style Toolbutton
  balloon $t.button1 "Commit"
  ttk::button $t.button2 -image [image create photo -file "$Gifpath/exit.gif"] -takefocus 0 -style Toolbutton
  balloon $t.button2 "Cancel"
  ttk::frame $t.tearoff1
  ttk::separator $t.tearoff1.to -orient vertical
  pack $t.tearoff1.to -fill y -expand 1 -padx 2 -side left
  ttk::button $t.button3 -image [Bitmap::get save] -takefocus 0 -style Toolbutton
  balloon $t.button3 "Save As File"
  ttk::button $t.button4 -image [Bitmap::get open] -takefocus 0 -style Toolbutton
  balloon $t.button4 "Load File"
  ttk::frame $t.tearoff2
  ttk::separator $t.tearoff2.to -orient vertical
  pack $t.tearoff2.to -fill y -expand 1 -padx 2 -side left
  ttk::button $t.button5 -image [Bitmap::get cut] \
                         -command "Cut $w" -state disabled -takefocus 0 -style Toolbutton
  balloon $t.button5 "Cut"
  ttk::button $t.button6 -image [Bitmap::get copy] \
                         -command "Copy $w" -state disabled -takefocus 0 -style Toolbutton
  balloon $t.button6 "Copy"
  ttk::button $t.button7 -image [Bitmap::get paste] \
                         -command "Paste $w" -takefocus 0 -style Toolbutton
  balloon $t.button7 "Paste"
  ttk::frame $t.tearoff3
  ttk::separator $t.tearoff3.to -orient vertical
  pack $t.tearoff3.to -fill y -expand 1 -padx 2 -side left
  ttk::button $t.button8 -image [Bitmap::get undo]\
                         -command "Undo $w" -state disabled -takefocus 0 -style Toolbutton
  balloon $t.button8 "Undo"
  ttk::button $t.button9 -image [Bitmap::get redo] \
                         -command "Redo $w" -state disabled -takefocus 0 -style Toolbutton
  balloon $t.button9 "Redo"
  ttk::frame $t.tearoff4
  ttk::separator $t.tearoff4.to -orient vertical
  pack $t.tearoff4.to -fill y -expand 1 -padx 2 -side left
  ttk::button $t.button10 -image [image create photo -file "$Gifpath/help.gif"] \
                          -command "B3 $w $t.button3" -takefocus 0 -style Toolbutton
  balloon $t.button10 "Help"
  grid $t.button1 $t.button2 $t.tearoff1 \
       $t.button3 $t.button4 $t.tearoff2 \
       $t.button5 $t.button6 $t.button7 $t.tearoff3 \
       $t.button8 $t.button9 $t.tearoff4 \
       -in $t.contents -padx 0 -sticky nsew
}

## pane for text
proc GetFrameText {w max_l max_h} {
     global fonttyp
     global fontsz
     global fontstyle

     ttk::frame $w.mf.note.txt
     set f $w.mf.note.txt

     ## set a line bar
     ttk::frame $w.mf.note.txt.f -width 13
     pack $f.f -side left -fill y

     ## text widget
     text $f.text \
       -background white \
       -undo 1 \
       -font [list $fonttyp $fontsz] \
       -width $max_l \
       -height $max_h \
       -yscrollcommand "$w.mf.note.txt.scroll set" \
       -bd 0 \
       -relief flat \
       -padx 1m

     ## set status bar
     set n [$f.text index "insert"]
     set lc [split $n .]
     set l_str [lindex $lc 0]
     set c_str [lindex $lc 1]
     set c_str [expr $c_str + 1]

     ttk::frame $f.statbar

     ttk::frame $f.statbar_left
     ttk::label $f.statbar1 -text "Line: "
     ttk::entry $f.statbar2 -width 4
     $f.statbar2 insert 0 $l_str
     ttk::label $f.statbar3 -text " Col: $c_str "
     grid $f.statbar1 $f.statbar2 $f.statbar3 -in $f.statbar_left -padx 0 -sticky nsw
     ttk::frame $f.statbar_right
     ttk::label $f.statbar4 -text "Find: "
     ttk::entry $f.statbar5 -width 12
     grid $f.statbar4 $f.statbar5 -in $f.statbar_right -padx 0 -sticky nse
     ttk::frame $f.statbar_middle

     grid $f.statbar_left -in $f.statbar -row 0 -column 0 -sticky w
     grid $f.statbar_middle -in $f.statbar -row 0 -column 1 -sticky we
     grid $f.statbar_right -in $f.statbar -row 0 -column 2 -sticky e -padx [list 0 0.5m]

     grid columnconfigure $f.statbar 1 -weight 10

     #ttk::label $f.statbar -relief sunken -anchor w -text " Line: $l_str Col: $c_str"
     pack $f.statbar -side bottom -fill x -pady [list 1m 1m]

     bind $f.statbar2 <<Key-Return>> "gotoline $w %W"
     proc gotoline {w WW} {set l_str [$WW get];
                           $w.mf.note.txt.text mark set insert $l_str.0;
                           $w.mf.note.txt.text see $l_str.0;
                           focus $w.mf.note.txt.text;}
     bind $f.statbar2 <Key-Return> "event generate $w.mf.note.txt.statbar2 <<Key-Return>>"
     bind $f.statbar2 <FocusIn> "$w.mf.note.txt.statbar2 selection range 0 end"

     bind $f.statbar5 <<Key-Return>> "findnext $w %W"
     proc findnext {w WW} {set l_str [$WW get];
                           if {$l_str==""} {
                             bell
                             return
                           } else {
                             set rsel [$w.mf.note.txt.text tag ranges sel]
                           }
                           if {$rsel!=""} {
                             $w.mf.note.txt.text mark set insert [lindex $rsel 1]
                           }
                           set res [$w.mf.note.txt.text search -forward -count varName $l_str insert]
                           if {$res==""} {
                             bell
                             return
                           }
                           set lc [split $res .]
                           set l_str [lindex $lc 0]
                           set c_str [lindex $lc 1]
                           set c_str [expr $c_str + $varName]
                           $w.mf.note.txt.text tag remove sel 1.0 end
                           $w.mf.note.txt.text tag add sel $res $l_str.$c_str
                           $w.mf.note.txt.text mark set insert $res
                           $w.mf.note.txt.text see $l_str.$c_str
                           focus $w.mf.note.txt.text
                          }
     bind $f.statbar5 <Key-Return> "event generate $w.mf.note.txt.statbar5 <<Key-Return>>"
     bind $f.statbar5 <Key-F3> "event generate $w.mf.note.txt.statbar5 <<Key-Return>>"
     bind $f.statbar5 <<ShiftF3>> "findprev $w %W"
     proc findprev {w WW} {set l_str [$WW get];
                           if {$l_str==""} {
                             bell
                             return
                           } else {
                             set rsel [$w.mf.note.txt.text tag ranges sel]
                           }
                           if {$rsel!=""} {
                             $w.mf.note.txt.text mark set insert [lindex $rsel 0]
                           }
                           set res [$w.mf.note.txt.text search -backward -count varName $l_str insert]
                           if {$res==""} {
                             bell
                             return
                           }
                           set lc [split $res .]
                           set l_str [lindex $lc 0]
                           set c_str [lindex $lc 1]
                           set c_str [expr $c_str + $varName]
                           $w.mf.note.txt.text tag remove sel 1.0 end
                           $w.mf.note.txt.text tag add sel $res $l_str.$c_str
                           $w.mf.note.txt.text mark set insert $res
                           $w.mf.note.txt.text see $l_str.$c_str
                           focus $w.mf.note.txt.text
                          }
     catch {bind $f.statbar5 <XF86_Switch_VT_3> "event generate $w.mf.note.txt.statbar5 <<ShiftF3>>"}
     bind $f.statbar5 <FocusIn> "$w.mf.note.txt.statbar5 selection range 0 end"

     ## set scroll bar
     ttk::scrollbar $f.scroll -command "$w.mf.note.txt.text yview"
     pack $f.scroll -side right -fill y

     ## pack text widget
     pack $f.text -expand yes -fill both

     bind $w.mf.note.txt.text <3> "focus -force %W;UpdateText $w $w.mf.note.txt;Popup $w %X %Y;focus %W"
     foreach x [bind Text] {
       bind $f.text $x "UpdateText $w $w.mf.note.txt"
     }     
     bind $f.text <Control-Key-plus> "Mincfont $w"
     bind $f.text <Control-Key-minus> "Mdecfont $w"
     bind $f.text <KeyPress> "UpdateText $w $w.mf.note.txt"
     bind $f.text <KeyRelease> "UpdateText $w $w.mf.note.txt"
     bind $f.text <ButtonPress> "UpdateText $w $w.mf.note.txt"
     bind $f.text <ButtonRelease> "UpdateText $w $w.mf.note.txt"
     bind $f.text <<SelectAll>> [bind Text <Control-Key-slash>]
     bind $f.text <<DeSelect>> [bind Text <Control-Key-backslash>]
     bind $f.text <<ChangeFont>> {%W configure -font [list $fonttyp $fontsz $fontstyle]}
     bind $f.text <<Modified>> "UpdateText $w $w.mf.note.txt; event generate $w <<ChangeTitle>>"
     bind Text <Control-a> [bind Text <Control-Key-slash>]
     bind Text <Control-c> [bind Text <<Copy>>]
     bind Text <Control-x> [bind Text <<Cut>>]
     bind Text <Control-v> [bind Text <<Paste>>]
     bind Text <Control-z> [bind Text <<Undo>>]
     bind Text <Control-Shift-z> [bind Text <<Redo>>]
     bind $f.text <Control-f> "focus $w.mf.note.txt.statbar5"
     bind $f.text <Control-g> "focus $w.mf.note.txt.statbar2"
     bind $f.text <Key-F3> "event generate $w.mf.note.txt.statbar5 <<Key-Return>>"
     catch {bind $f.text <XF86_Switch_VT_3> "event generate $w.mf.note.txt.statbar5 <<ShiftF3>>"}
}

## toolbar Tk
proc GetTkToolbar { w } {
   global Gifpath

   set t [frame $w.tk_toolbar -relief flat]
   ttk::frame $t.tearoff -cursor fleur
   ttk::separator $t.tearoff.to -orient vertical
   ttk::separator $t.tearoff.to2 -orient vertical
   pack $t.tearoff.to -fill y -expand 1 -padx 2 -side left
   pack $t.tearoff.to2 -fill y -expand 1 -side left
   ttk::frame $t.contents
   grid $t.tearoff $t.contents -sticky nsew
   grid columnconfigure $t $t.contents -weight 1
   grid columnconfigure $t.contents 1000 -weight 1
   bind $t.tearoff     <B1-Motion> [list tearoff $w $t %X %Y]
   bind $t.tearoff.to  <B1-Motion> [list tearoff $w $t %X %Y]
   bind $t.tearoff.to2 <B1-Motion> [list tearoff $w $t %X %Y]
   proc tearoff {w t x y} {
     if {[string match $t* [winfo containing $x $y]]} {
       return
     }
     grid remove $t
     grid remove $t.tearoff
     wm manage $t
     wm protocol $t WM_DELETE_WINDOW [list untearoff $w $t]
     grid remove $w.sep2
     $w.menubar.view.tools entryconfigure 1 -state disabled
   }
   proc untearoff {w t} {
     wm forget $t
     grid $t.tearoff
     grid $t
     grid $w.sep2
     $w.menubar.view.tools entryconfigure 1 -state normal
   }
   ttk::button $t.button1 -width 2 -command "B1 $w $w.tk_toolbar.button1" -takefocus 0 \
                          -image [image create photo -file "$Gifpath/bold.gif"] -style Toolbutton
   ttk::button $t.button2 -width 2 -command "B2 $w $w.tk_toolbar.button2" -takefocus 0 \
                          -image [image create photo -file "$Gifpath/italic.gif"] -style Toolbutton
   ttk::button $t.button3 -text "B3" -width 2 -command "B3 $w $w.tk_toolbar.button3" -takefocus 0 -style Toolbutton
   balloon $t.button1 "Bold"
   balloon $t.button2 "Italic"
   balloon $t.button3 "Underline"

   proc B1 {w but} {
    global fontstyle1
    if [$but instate {!selected}] {
      $but state {pressed selected}
      set fontstyle1 "1"
    } else {
      set fontstyle1 "0"
      $but state {!pressed !selected}
    }
     setfont $w
   }
   proc B2 {w but} {
     global fontstyle2
     if [$but instate {!selected}] {
       $but state {pressed selected}
       set fontstyle2 "1"
     } else {
       set fontstyle2 "0"
      $but state {!pressed !selected}
     }
     setfont $w
   }
   proc B3 {w but} {
     global fontstyle3
     if [$but instate {!selected}] {
       $but state {pressed selected}
       set fontstyle3 "1"
     } else {
       $but state {!pressed !selected}
       set fontstyle3 "0"
     }
     setfont $w
   }

   ttk::frame $t.tearoff2
   ttk::separator $t.tearoff2.to -orient vertical
   pack $t.tearoff2.to -fill y -expand 1 -padx 1 -side left
   ttk::combobox $t.combo -value [lsort [font families]] -state readonly \
                       -textvariable fonttyp -width 13 -takefocus 0
   balloon $t.combo "Fonts type"
   bind $t.combo <<ComboboxSelected>> [list changeFont $w $t.combo]
   proc changeFont {w combo} {
     global fonttyp
     set fonttyp [$combo get]
     setfont $w
   }
   set i 2
   set val [list 1]
   while {$i < 73} {
       lappend val $i
       incr i 1
   }
   ttk::combobox $t.combosz -value $val -state readonly \
                          -textvariable fontsz -width 5 -takefocus 0
   balloon $t.combosz "Fonts size"
   bind $t.combosz <<ComboboxSelected>> [list changeSz $w $t.combosz]
   proc changeSz {w combo} {
     global fontsz
     set fontsz [$combo get]
     setfont $w
   }

   ttk::label $t.lab -text "  Theme :"
   ttk::combobox $t.combo2 -value [lsort [ttk::themes]] -state readonly \
                           -textvariable TkTheme -width 10 -takefocus 0
   balloon $t.combo2 "Tk theme"
   bind $t.combo2 <<ComboboxSelected>> [list changeTheme $w $t.combo2]
   ## typ specify if its a getvalue panel set 1
   ## else set 0
   proc changeTheme {w combo} {
     ttk::setTheme [$combo get]
   }
   grid $t.button1 $t.button2 $t.combo $t.combosz $t.tearoff2 $t.combo2 -in $t.contents -padx 1 -sticky nsew
}

## initial activation for font type selector buttons
proc ActivB1B2B3 {w fontstyle1 fontstyle2 fontstyle3} {
  set t $w.tk_toolbar
  if {$fontstyle1} {
    $t.button1 state {pressed selected}
  } else {
    $t.button1 state {!pressed !selected}
  }
  if {$fontstyle2} {
    $t.button2 state {pressed selected}
  } else {
    $t.button2 state {!pressed !selected}
  }
  if {$fontstyle3} {
    $t.button3 state {pressed selected}
  } else {
    $t.button3 state {!pressed !selected}
  }
}

## buttons
proc GetButtons { w } {
  ttk::frame $w.mf.buttons
  ttk::button $w.mf.buttons.dismiss -text Cancel
  balloon $w.mf.buttons.dismiss "Cancel"
  ttk::button $w.mf.buttons.ok -text OK -default active
  balloon $w.mf.buttons.ok "Commit"
  ttk::button $w.mf.buttons.help -text Help
  balloon $w.mf.buttons.help "Help"

  pack $w.mf.buttons.dismiss -side right -padx 1m -pady [list 0 1m]
  pack $w.mf.buttons.ok -side right -padx 1m -pady [list 0 1m]
  pack $w.mf.buttons.help -side left -padx 1m -pady [list 0 1m]
  ## ordering
  raise $w.mf.buttons.dismiss  $w.mf.buttons.ok
}

## menu
proc GetMenu { w } {

   global Gifpath
   global with_tool
   global with_tool_tk
   global with_but
   global activback
   global activfor
   global activbrd

   menu $w.menubar -tearoff 0

   ## menu file
   menu $w.menubar.file -tearoff 0 -bd 1 \
     -activebackground $activback -activeforeground $activfor \
     -activeborderwidth $activbrd
   $w.menubar add cascade -label "File" -menu $w.menubar.file -underline 0

   $w.menubar.file add command -label "Commit" \
      -compound left -image [image create photo -file "$Gifpath/check.gif"]
   $w.menubar.file add separator
   $w.menubar.file add command -label "Save as File" \
      -compound left -image [Bitmap::get save]
   $w.menubar.file add command -label "Load File" \
      -compound left -image [Bitmap::get open]
   $w.menubar.file add separator
   $w.menubar.file add command -label "Exit" \
      -compound left -image [image create photo -file "$Gifpath/exit.gif"]

  ## menu edit
  menu $w.menubar.edit -tearoff 0 -bd 1 \
    -activebackground $activback -activeforeground $activfor \
    -activeborderwidth $activbrd
  $w.menubar add cascade -label "Edit" -menu $w.menubar.edit -underline 0

  $w.menubar.edit add command -compound left \
     -image [Bitmap::get cut] -label "Cut" -accelerator "Ctrl+x" -command "Cut $w" -state disabled
  $w.menubar.edit add command -compound left \
      -image [Bitmap::get copy] -label "Copy" -accelerator "Ctrl+c" -command "Copy $w" -state disabled
  $w.menubar.edit add command -compound left \
      -image [Bitmap::get paste] -label "Paste" -accelerator "Ctrl+v" -command "Paste $w"
  $w.menubar.edit add separator
  $w.menubar.edit add command -compound left \
      -image [Bitmap::get opmove] -label "Select All" -accelerator "Ctrl+a" -command "Select $w"
  $w.menubar.edit add command -compound left \
      -image [Bitmap::get oplink] -label "Deselect" -command "UnSelect $w" -state disabled
  $w.menubar.edit add separator
  $w.menubar.edit add command -compound left \
    -image [Bitmap::get undo] -label "Undo" -accelerator "Ctrl+z" -command "Undo $w" -state disabled
  $w.menubar.edit add command -compound left \
    -image [Bitmap::get redo] -label "Redo" -accelerator "Shift+Ctrl+z" -command "Redo $w" -state disabled

  ## menu Setting
  menu $w.menubar.view -tearoff 0 -bd 1 \
    -activebackground $activback -activeforeground $activfor \
    -activeborderwidth $activbrd
  $w.menubar add cascade -label "Setting" -menu $w.menubar.view -underline 0

    ## menu view.toolbars
    menu $w.menubar.view.tools -tearoff 0 -bd 1 \
      -activebackground $activback -activeforeground $activfor \
      -activeborderwidth $activbrd
    $w.menubar.view add cascade -label "Toolbars" -menu $w.menubar.view.tools \
      -compound left -image [image create photo -file "$Gifpath/none.gif"] 

    $w.menubar.view.tools add checkbutton -label "Toolbar" \
      -offvalue 0 -onvalue 1 -variable with_tool -command "tool $with_tool $w"
    global switcha
    set switcha $with_tool
    proc tool {with_tool w} {
      global switcha
      if $switcha {
        grid $w.toolbar.tearoff
        grid $w.toolbar
        grid $w.sep1
        set switcha 0
      } else {
        grid remove $w.toolbar
        grid $w.sep1
        set switcha 1
      }
    }

    $w.menubar.view.tools add checkbutton -label "Tk Toolbar" \
      -offvalue 0 -onvalue 1 -variable with_tool_tk -command "tktool $with_tool_tk $w"
    global switchb
    set switchb $with_tool_tk
    proc tktool {with_tool_tk w} {
      global switchb
      if $switchb {
        grid $w.tk_toolbar.tearoff
        grid $w.tk_toolbar
        grid $w.sep2
        set switchb 0
      } else {
        grid remove $w.tk_toolbar
        grid remove $w.sep2
        set switchb 1
      }
    }
    $w.menubar.view.tools add checkbutton -label "Buttonbar" \
      -offvalue 0 -onvalue 1 -variable with_but -command "butbar $with_but $w"
    global switchc
    set switchc $with_but
    proc butbar {with_but w} {
      global switchc
      if $switchc {
        grid $w.mf.buttons
        set switchc 0
      } else {
        grid remove $w.mf.buttons
        set switchc 1
      }
    }

   $w.menubar.view add separator

   $w.menubar.view add command -label "Increase size" \
      -command "Mincfont $w" \
      -compound left -image [image create photo -file "$Gifpath/none.gif"] \
      -accelerator Ctrl++
   proc Mincfont {w} {
     global fontsz
     set fontsz [expr {$fontsz + 1}]
     setfont $w
   }

   $w.menubar.view add command -label "Decrease size" \
      -command "Mdecfont $w" \
      -compound left -image [image create photo -file "$Gifpath/none.gif"] \
      -accelerator Ctrl+-
   proc Mdecfont {w} {
     global fontsz
     set fontsz [expr {$fontsz - 1}]
     setfont $w
   }
   bind $w <Control-Key-plus> "Mincfont $w"
   bind $w <Control-Key-minus> "Mdecfont $w"

  ## menu help
  menu $w.menubar.help -tearoff 0 -bd 1 \
    -activebackground $activback -activeforeground $activfor \
    -activeborderwidth $activbrd
  $w.menubar add cascade -label "?" -menu $w.menubar.help -underline 0

  $w.menubar.help add command -label "Scicos Help" \
     -command "CosHelp;set done 3" \
     -compound left -image [image create photo -file "$Gifpath/help.gif"]

  $w.menubar.help add separator

  $w.menubar.help add command -label "About Scicos" \
     -command "AboutHelp;set done 3" \
     -compound left -image [image create photo -file "$Gifpath/none.gif"]
}

## menu popup
proc GetMpopup { w } {

  global activback
  global activfor
  global activbrd

  set m [menu $w.popupMenu -tearoff 0 -bd 1 \
    -activebackground $activback -activeforeground $activfor -activeborderwidth $activbrd]

  $m add command -compound left \
    -image [Bitmap::get cut] -label "Cut" -accelerator "Ctrl+x" -command "Cut $w" -state disabled
  $m add command -compound left \
    -image [Bitmap::get copy] -label "Copy" -accelerator "Ctrl+c" -command "Copy $w" -state disabled
  $m add command -compound left \
    -image [Bitmap::get paste] -label "Paste" -accelerator "Ctrl+v" -command "Paste $w"
  $m add separator
  $m add command -compound left \
    -image [Bitmap::get opmove] -label "Select All" -accelerator "Ctrl+a" -command "Select $w"
  $m add command -compound left \
    -image [Bitmap::get oplink] -label "Deselect" -command "UnSelect $w" -state disabled
  $m add separator
  $m add command -compound left \
    -image [Bitmap::get undo] -label "Undo" -accelerator "Ctrl+z" -command "Undo $w" -state disabled
  $m add command -compound left \
    -image [Bitmap::get redo] -label "Redo" -accelerator "Shift+Ctrl+z" -command "Redo $w" -state disabled
}

## pane for entries
proc GetFrameEntry {w nitems lmax} {
  global fontsz
  global fonttyp
  global fontstyle

   set n ""
   set sep " "
   for {set i 1} {$i <= $nitems} {incr i} {
     set f f$i
     set n $n$f$sep
   }

   ## new style for horizontal scrollbar for entries
   ttk::style configure mini.TScrollbar -width 7 -arrowsize 7
   ttk::style layout Horizontal.mini.TScrollbar [ttk::style layout Horizontal.TScrollbar]

   ttk::frame $w.mf.note.msg
   set f $w.mf.note.msg

   ## add a scroolbar when needed
   proc controle {value k} {
     set ll [string length $value]
     if {$ll>36} {
       grid $k
     } else {
       grid remove $k
     }
     return 1
   }

   foreach i $n {
     ttk::frame $f.$i
     pack $f.$i -padx [list 1 4] -pady [list 3 1] -fill x -expand yes

     ttk::frame $f.$i.e
     pack $f.$i.e -fill x -expand yes

     ttk::entry $f.$i.e.entry -width 35 -xscrollcommand "$f.$i.e.scroll set" \
                              -font [list $fonttyp $fontsz] \
                              -validate all -validatecommand "controle %P $f.$i.e.scroll"

     ttk::scrollbar $f.$i.e.scroll -orient horiz -style mini.TScrollbar -command "$f.$i.e.entry xview"

     grid $f.$i.e.entry -in $f.$i.e -row 0  -column 0 -sticky nsew
     grid $f.$i.e.scroll -in $f.$i.e -row 1 -column 0 -sticky new
     grid remove $f.$i.e.scroll

     ttk::label $f.$i.label -anchor w -wraplength 260

     grid $f.$i.label -in $f.$i -row 0  -column 0 -sticky ew
     grid $f.$i.e -in $f.$i -row 0  -column 1 -sticky nsew

     grid rowconfigure $f.$i.e 0 -weight 0
     grid columnconfigure $f.$i.e 0 -weight 1

     grid rowconfigure $f.$i 0 -weight 0
     grid columnconfigure $f.$i 0 -weight 0
     grid columnconfigure $f.$i 1 -weight 1

     foreach x [bind TEntry] {
       bind $f.$i.e.entry $x "UpdateEntry $w %W $i"
       bind $f.$i.e.entry <<SelectAll>> [bind TEntry <Control-Key-slash>]
       bind $f.$i.e.entry <<DeSelect>> [bind TEntry <Control-Key-backslash>]
     }
     bind $f.$i.e.entry <3> "UpdateEntry $w %W $i;focus -force %W;Popup $w %X %Y;focus %W"
     bind $f.$i.e.entry <Key-Return>  {focus [tk_focusNext %W]}
     bind $f.$i.e.entry <KeyRelease> "UpdateEntry $w %W $i"
     bind $f.$i.e.entry <<Undo>> "UndoEntry $w %W $i"
     bind $f.$i.e.entry <Control-z> [bind $f.$i.e.entry <<Undo>>]
     bind $f.$i.e.entry <<Redo>> "RedoEntry $w %W $i"
     bind $f.$i.e.entry <Shift-Control-z> [bind $f.$i.e.entry <<Redo>>]

     bind $f.$i.e.entry <<ChangeFont>> {
      %W configure -font [list $fonttyp $fontsz $fontstyle]
     }
   }

   ## redefine control-a for TEntry class
   bind TEntry <Control-a> [bind TEntry <Control-Key-slash>]

}

## help message
proc GetMsg { HelpFile } {
  set openf $HelpFile
  set fp [open $openf r]
  set head [read $fp]
  close $fp
  set records [split $head "\n"]
  set lrec [llength $records]
  incr lrec -1
  if {$lrec>=0} {
    set newrec [lindex $records 0]
    set newrec [lindex $records 0]
    for {set i 1} {$i<$lrec} {incr i} {
      append newrec "\n" [lindex $records $i]
    }
  } else {
    set newrec ""
  }
  return $newrec
}

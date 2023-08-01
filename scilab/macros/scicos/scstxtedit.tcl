## scstxtedit_tk : a tcl/tk text editor for Scicos
## author : Alan Layec, xx/xx/08
## 11/07/08 : implements current position of cursor (Line,Col)
##            to improve debugging

# Mopeninit : open a file InfIle and update widget
# $w.text.
#
# Inputs w : Id of the toplevel window of the blk editor
#        InFile : path and and name of the file to open
#
proc Mopeninit {w InFile} {
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
# $w.text.
#
# Inputs w : Id of the toplevel window of the blk editor
#        InFile : path and and name of the file to open
#        winId : the Tcl/Tk SciGui WinId
#
proc Msaveinit {w InFile winId} {
 set dirdd $InFile$winId
 set openf $dirdd
 set f [open $openf w]
 puts $f [$w.text get 1.0 {end -1c}]
 close $f
}

# Mopen : open a file from  tk_getOpenFile and update
# widget $w.text.
#
# Inputs w : Id of the toplevel window of the blk editor
#        winId : the Tcl/Tk SciGui WinId
#
proc Mopen {w winId typ} {
  set dirdd [tk_getOpenFile]
  if {$dirdd != ""} {
    set openf $dirdd
    $w.text delete 1.0 end
    set fid [open $openf r]
    while {![eof $fid]} {
     $w.text insert end [read $fid 1000]
    }
    close $fid
    $w.text mark set insert 1.0
    ScilabEval "Mopen('$dirdd','$winId');"
  }
}

# Msave : save the content of the buffer widget $w.text.
# in a file provided by tk_getSaveFile
#
# Inputs w : Id of the toplevel window of the blk editor
#
proc Msave {w} {
 set dirdd [tk_getSaveFile]
 if {$dirdd != ""} {
   set openf $dirdd
   set f [open $openf w]
   puts $f [$w.text get 1.0 {end -1c}]
   close $f
 }
}

# ToCos : save the content of the buffer widget $w.text.
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
 puts $f [$w.text get 1.0 {end -1c}]
 close $f
 ## save ps and dim TCL global vars
 if { $typ=="context" } {
   global numxctxt
   global numyctxt
   global ledtxctxt
   global ledtyctxt
   set numxctxt [winfo x $w]
   set numyctxt [winfo y $w]
   set ledtxctxt [winfo width $w]
   set ledtyctxt [winfo height $w]
 }
 if { $typ=="icon" } {
   global numxicon
   global numyicon
   set numxicon [winfo x $w]
   set numyicon [winfo y $w]
 }
 if { $typ=="palette" } {
   global numxpal
   global numypal
   set numxpal [winfo x $w]
   set numypal [winfo y $w]
 }
 if { $typ=="scsminfo" } {
   global numxscsmi
   global numyscsmi
   set numxscsmi [winfo x $w]
   set numyscsmi [winfo y $w]
 }
 if { $typ=="standarddoc" } {
   global numxstddoc
   global numystddoc
   set numxstddoc [winfo x $w]
   set numystddoc [winfo y $w]
 }
 if { $typ=="debugblock" } {
   global numxdgblk
   global numydgblk
   set numxdgblk [winfo x $w]
   set numydgblk [winfo y $w]
 }
 ScilabEval "str_out=ToCos('$InFile','$OutFile','$winId');"
}

# Mquit : close the windows of the buffer : write
# the content of the buffer widget $w.text in the file
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
 puts $f [$w.text get 1.0 {end -1c}]
 close $f
 ScilabEval "Quit=Mquit('$InFile','$OutFile','$winId');"
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

# updatePos : Update the current position of the cursor in
#             the status bar
# Input : w : Id of the toplevel window of the blk editor
proc updatePos {w} {
  set n [$w.text index "insert"]
  set lc [split $n .]
  set l_str [lindex $lc 0]
  set c_str [lindex $lc 1]
  set c_str [expr $c_str + 1]

  $w.statbar configure -text " Line: $l_str Col: $c_str"
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
 ## look inside the sciGUITable to retrieve te Id of the editor
 global sciGUITable
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
 ## create the window if it does'nt exist
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
     wm title $w "Context"
   } elseif { $typ=="icon" } {
     wm title $w "Icon"
   } elseif { $typ=="palette" } {
     wm title $w "Palette editor"
   } elseif { $typ=="Cfunc" } {
     wm title $w "C function"
   } elseif { $typ=="ModelicaClass" } {
     wm title $w "Modelica class"
   } elseif { $typ=="scsminfo" } {
     wm title $w "Diagram Information"
   } elseif { $typ=="standarddoc" } {
     wm title $w "Standard Block Documentation"
   } elseif { $typ=="debugblock" } {
     wm title $w "Block debug"
   } else {
     wm title $w "Block Editor ($winId2)"
   }

   ## set head
   set openf $HelpFile
   ## $w.text delete 1.0 end
   text $w.msg -width $max_ll -height $max_hh -font {-*-times-*-r-*-*-12}
   ##label $w.msg -wraplength 5i -justify left
   set fid [open $openf r]
   while {![eof $fid]} {
    $w.msg insert end [read $fid 1000]
   }
   close $fid
   pack $w.msg  -fill both

   ## set menu bar
   frame $w.menubar -relief raised -bd 2
   pack  $w.menubar -fill x
   menubutton $w.menubar.file \
     -text Buffer \
     -underline 0 \
     -menu $w.menubar.file.menu
   pack $w.menubar.file -side left
   menu $w.menubar.file.menu -tearoff 0
   $w.menubar.file.menu add command -label "Commit" \
      -command "ToCos $w $InFile $OutFile $winId2 $typ"
   $w.menubar.file.menu add command -label "Save as File" \
      -command "Msave $w"
   $w.menubar.file.menu add command -label "Load File" \
      -command "Mopen $w $winId2 $typ"
   $w.menubar.file.menu add command -label "Exit" \
      -command "Mquit $w $InFile $OutFile $winId2 $typ"

   menubutton $w.menubar.help \
     -text Help \
     -underline 0 \
     -menu $w.menubar.help.menu
   pack $w.menubar.help -side right
   menu $w.menubar.help.menu -tearoff 0
      
   if { $typ=="context" } {
     $w.menubar.help.menu add command -label "Context Help" \
        -command "ContextHelp"
   } elseif { $typ=="debugblock" } {
     $w.menubar.help.menu add command -label "Scicos Debug Help" \
        -command "DebugHelp"
   }

   $w.menubar.help.menu add command -label "Scicos Help" \
      -command "CosHelp"
      
   ## set text widget
   text $w.text \
     -background white \
     -undo 1 \
     -font {-*-courier-*-r-*-*-12} \
     -width $max_l \
     -height $max_h \
     -yscrollcommand "$w.scroll set"

   ## set status bar
   set n [$w.text index "insert"]
   set lc [split $n .]
   set l_str [lindex $lc 0]
   set c_str [lindex $lc 1]
   set c_str [expr $c_str + 1]

   label $w.statbar -anchor w -text " Line: $l_str Col: $c_str"
   pack  $w.statbar -side bottom -fill x

   ## set scroll bar
   scrollbar $w.scroll -command "$w.text yview"
   pack $w.scroll -side right -fill y

   ## pack text widget
   pack $w.text -expand yes -fill both

   ## set dim of the window
   if { $ledtx != -1 } {
     wm geometry $w ${ledtx}x${ledty}
   }

   ## initial import of buffer
   Mopeninit $w $InFile
   Msaveinit $w $InFile $winId2

   ## initial state of the editor buffer
   $w.text edit modified false
   $w.text edit reset

   ## set the modified flag of the text widget
   if { $typ=="context" } {
     bind $w.text <<Modified>> \
      "wm title $w \"Context (*)\""
   } elseif { $typ=="icon" } {
     bind $w.text <<Modified>> \
      "wm title $w \"Icon (*)\""
   } elseif { $typ=="palette" } {
     bind $w.text <<Modified>> \
      "wm title $w \"Palette editor (*)\""
   } elseif { $typ=="Cfunc" } {
     bind $w.text <<Modified>> \
      "wm title $w \"C function (*)\""
   } elseif { $typ=="ModelicaClass" } {
     bind $w.text <<Modified>> \
      "wm title $w \"Modelica class (*)\""
   } elseif { $typ=="scsminfo" } {
     bind $w.text <<Modified>> \
      "wm title $w \"Diagram Information (*)\""
   } elseif { $typ=="standarddoc" } {
     bind $w.text <<Modified>> \
      "wm title $w \"Standard Block Documentation (*)\""
   } else {
     bind $w.text <<Modified>> \
       "wm title $w \"Scicos TCL/Tk Text Editor ($winId2) -***-\""
   }

   ## bindings for the update of the cursor position
   bind $w.text <KeyPress> \
       "updatePos $w"
   bind $w.text <KeyRelease> \
       "updatePos $w"
   bind $w.text <ButtonPress> \
       "updatePos $w"
   bind $w.text <ButtonRelease> \
       "updatePos $w"

   ## change behavior of the exit button
   wm protocol $w WM_DELETE_WINDOW "Mquit $w $InFile $OutFile $winId2 $typ"
   ## take focus
   focus $w.text
  }
 }
}

# GetInfo : main procedure of the GetInfo window
#
# Inputs InFile : path and and name of the file to open
#        max_h/max_l : display size of the buffer
#        numx/numy : the initial position of windows
#
proc GetInfo {InFile max_l max_h numx numy } {

  set winId2 [sciGUICreate -1 "GetInfo"]
  set w [sciGUIName $winId2]
  wm title $w "GetInfo ($winId2)"

   ## compute the top/left position of the window
  frame $w.top
  text $w.top.text \
     -background white \
     -font {-*-courier-*-r-*-*-12} \
     -width $max_l\
     -height $max_h \
     -yscrollcommand "$w.top.scroll set"
  scrollbar $w.top.scroll -command "$w.top.text yview"
  pack $w.top.scroll -side right -fill y
  pack $w.top.text -expand yes -fill both
  pack  $w.top -fill both

  frame $w.bot -relief raised -borderwidth 2
  button $w.bot.quit -text Close -width 8 -command "sciGUIDestroy $winId2"
  pack $w.bot.quit -side left -padx 4 -expand 0 -fill x -pady 2
  pack $w.bot -side top -expand 0 -fill both

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

  ## initial import of buffer
  Mopeninit $w.top $InFile
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

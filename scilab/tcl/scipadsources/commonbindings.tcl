#  Scipad - programmer's editor and debugger for Scilab
#
#  Copyright (C) 2002 -      INRIA, Matthieu Philippe
#  Copyright (C) 2003-2006 - Weizmann Institute of Science, Enrico Segre
#  Copyright (C) 2004-2015 - Francois Vogel
#
#  Localization files ( in tcl/msg_files/) are copyright of the 
#  individual authors, listed in the header of each file
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
# See the file scipad/license.txt
#

# bindings
bind all <Alt-F> {}
bind all <Alt-E> {}
bind all <Alt-S> {}
bind all <Alt-H> {}

# delete "native" text bindings in the textarea -- we want all text
# manipulation to pass through our procs, so that e.g. colorization and
# edit while debug are correctly treated
#bind Text <Control-h> {backspacetext}
bind Text <Control-k> {}
bind Text <Control-i> {}
bind Text <Control-f> {} ; # avoids selection deletion on find box open

bind Text <KeyPress>  {
                        if {[lsearch $listoftextarea %W] != -1} {
                            if {{%A} != {{}}} {
                                puttext %W %A "replaceallowed"
                            }
                        }
                      }

bind Text <BackSpace> {backspacetext}

bind Text <Return>    {insertnewline %W}

bind Text <Insert>    {toggleinsertreplacemode}

# break prevents from triggering the default Tk
# binding: bind all <Key-Tab> tk::TabToWindow [tk_focusNext %W], which
# is harmful when displaying more than one buffer at the same time
# warning: this binding might be erased by the completion binding
# set later in this file, depending on the user preference (completion
# options menu). Moreover, if the binded script changes, proc
# SetCompletionBinding must be updated accordingly
bind Text <Tab>       {inserttab %W ; break}

bind Text <parenleft>    {if {{%A} != {{}}} {insblinkbrace %W %A}}
bind Text <parenright>   {if {{%A} != {{}}} {insblinkbrace %W %A}}
bind Text <bracketleft>  {if {{%A} != {{}}} {insblinkbrace %W %A}} 
bind Text <bracketright> {if {{%A} != {{}}} {insblinkbrace %W %A}} 
bind Text <braceleft>    {if {{%A} != {{}}} {insblinkbrace %W %A}}
bind Text <braceright>   {if {{%A} != {{}}} {insblinkbrace %W %A}}
bind Text <quotedbl>     {if {{%A} != {{}}} {insblinkquote %W %A}}

bind Text <Up>    {+ setTextAnchor_scipad %W}
bind Text <Down>  {+ setTextAnchor_scipad %W}

if {$Tk86} {
    # in Tk 8.6, the <Left> and <Right> events have been replaced by
    # <<PrevChar>> and <<NextChar>> virtual events
    bind Text <<PrevChar>> {+ setTextAnchor_scipad %W}
    bind Text <<NextChar>> {+ setTextAnchor_scipad %W}
} else {
    bind Text <Left>       {+ setTextAnchor_scipad %W}
    bind Text <Right>      {+ setTextAnchor_scipad %W}
}


bind Text <<Modified>> {changedmodified %W}


bind Text <Double-Button-1> {+ setTextAnchor_scipad %W}


bind Text <ButtonRelease-2> {button2copypaste %W %x %y}


# Added catch {} is here to avoid error popup message in case
# listoffile("$textarea",language) has already been unset in proc byebyeta which
# is called on ctrl-w to close the current buffer
bind $textareacur <KeyRelease> {catch {keyposn %W}}

event delete <<Cut>> <Control-w>
event delete <<Cut>> <Control-x>
event delete <<Cut>> <Control-Key-x>

event delete <<Paste>> <Control-y>
event delete <<Paste>> <Control-Key-y>

# Control-y must not be used for redoing, as it is the case by default in Tk
# Try this:
#   1 make a change in the textarea
#   2 undo
#   3 select something (containing or not the undoed change)
#   4 execute selection in Scilab through control-y
# without the following event deletion, Scipad would first redo
# what was undone at step 2 before launching execselection
# remapping of this <<Redo>> event from ctrl-y to ctrl-Z
# is needed only on Windows (Ctrl-Z is already mapped to
# <<Redo>> on Linux, see tk.tcl)
if {[tk windowingsystem] eq "win32"} {
    event delete <<Redo>> <Control-Key-y> <Control-Lock-Key-Y>
    event add    <<Redo>> <Control-Key-Z> <Control-Lock-Key-z>
}

bind $pad <Control-B> {showwhichfun}

# remove the default bind ctrl-d=delete char
bind Text <Control-d> ""

bind $pad <Control-plus>  {set textfontsize [expr {round($textfontsize*1.11)}]; \
                           set menufontsize [expr {round($menufontsize*1.11)}]; \
                           updatefont all}
bind $pad <Control-minus> {set textfontsize [expr {round($textfontsize*0.9)}]; \
                           set menufontsize [expr {round($menufontsize*0.9)}]; \
                           updatefont all}
bind $pad <Control-MouseWheel> {if {%D<0} { \
                                    event generate %W <Control-minus> \
                                } else { \
                                    event generate %W <Control-plus>  \
                                } \
                               }

bind Text <Button-3>               {showpopup_contextual}
bind Text <Control-Button-3>       {showpopup_options}
bind Text <Shift-Control-Button-3> {showpopup_navigation %W %x %y}

# For Tk 8.5 and above, the behavior on external resize is driven by
# the option -stretch always
# For Tk before 8.5, proc spaceallsasheskeeprelsizes emulates this option
if {!$Tk85} {
    bind $pad <Configure> {if {"%W"=="$pad"} {
                               catch {spaceallsasheskeeprelsizes}
                               }
                          }
}
bind Panedwindow <Double-Button-1> {spacesashesevenly %W}

bind $pad <FocusIn> {checkifanythingchangedondisk %W}

# The following are (unfortunately) platform/os-dependent keysyms
set Shift_Tab {"ISO_Left_Tab" "Shift-Tab"}
set Shift_F1  {"XF86_Switch_VT_1" "Shift-F1"}
set Shift_F3  {"XF86_Switch_VT_3" "Shift-F3"}
set Shift_F8  {"XF86_Switch_VT_8" "Shift-F8"}
set Shift_F9  {"XF86_Switch_VT_9" "Shift-F9"}
set Shift_F11  {"XF86_Switch_VT_11" "Shift-F11" "Shift-SunF36"}
set Shift_F12  {"XF86_Switch_VT_12" "Shift-F12" "Shift-SunF37"}

# warning: this binding might be erased by the completion binding
# set later in this file, depending on the user preference (completion
# options menu). Moreover, if the bound script changes, proc
# SetCompletionBinding must be updated accordingly
pbind Text $Shift_Tab {UnIndentSel ; break}

pbind $pad $Shift_F1 {aboutme}
pbind $pad $Shift_F3 {incsearchprevious}

# bindings for KP_ keys in linux (how come that NumLock on means %s & 16? 
# From http://wiki.tcl.tk/4238, we understand that %s & 8 is expected)
# this is wrapped in a test on tcl_platform(platform) even if this code
# is apparently harmless on Windows (KP_xxx never fires) - Anyway, on Win
# %s & 8 is needed to detect NumLock
if {$tcl_platform(platform) == "unix"} {
    set KeyPadKeys {Home Up Prior Left Right End Down Next Insert Delete}
    foreach k $KeyPadKeys {
        catch {bind all <KP_$k> {if {[expr {%s & 16}] == 0} \
                   {event generate %W <[string range %K 3 end]>}}
               bind all <Control-KP_$k> {if {[expr {%s & 16}] == 0} \
                   {event generate %W <Control-[string range %K 3 end]>}}
          }
    }
}

# the following call sets a binding for the completion popup menu
# it must be sourced after all the possible bindings proposed in the
# options/completion menu that are also present above since it might
# replace bindings previously set e.g. Tab and Shift-Tab
SetCompletionBinding

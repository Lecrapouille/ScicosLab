#  Scipad - programmer's editor and debugger for Scilab
#
#  Copyright (C) 2002 -      INRIA, Matthieu Philippe
#  Copyright (C) 2003-2006 - Weizmann Institute of Science, Enrico Segre
#  Copyright (C) 2004-2011 - Francois Vogel
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

proc tonextbreakpoint_bp {{checkbusyflag 1} {stepmode "nostep"}} {

    # warn the user about duplicate function names, or unterminated functions
    # possibly found in the opened buffers
    # the debugger won't execute in that case
    if {[checkforduplicateorunterminatedfuns]} {return}

    if {[getdbstate] == "ReadyForDebug"} {
        clearscilaberror
        execfile_bp $stepmode
    } elseif {[getdbstate] == "DebugInProgress"} {
        resume_bp $checkbusyflag $stepmode
    } else {
        tk_messageBox -message "Unexpected debug state in proc tonextbreakpoint_bp: please report"
    }
}

proc execfile_bp {{stepmode "nostep"}} {
# return argument: 0=success, -1=fail
    global funnameargs listoftextarea funsinbuffer waitmessage watchvars
    global setbptonreallybreakpointedlinescmd
    global previousstopfun
    global bptsprops
    global prevdbpauselevel initprevdbpauselevel

    if {[isscilabbusy 5]} {return}
    showinfo $waitmessage

    set prevdbpauselevel $initprevdbpauselevel

    # create the setbpt command
    set setbpcomm ""
    foreach ID [getusedIDsfrombptprops] {
        set setbptlinenum [expr {[condloglinetophyslineinfun $bptsprops($ID,funname) $bptsprops($ID,funline)] - 1}]
        set setbpcomm [concat $setbpcomm "setbpt(\"$bptsprops($ID,funname)\",$setbptlinenum);"]
    }

    # exec any non level zero code, i.e. everything that is in a function
    # definition and launch the debug (i.e. run the configured function)
    if {$funnameargs != ""} {

        setdebuggerbusycursor

        # exec all non level zero code from all buffers
        set execresult [execallnonlevelzerocode]

        if {$execresult == -1 || $execresult == 4} {
            # in case execing the file produced an error, or if the code contains
            # a pause or abort statement, restore the cursors
            # and return (the debug must not be launched) - the cleanup has
            # been done in proc canceldebug_bp that has been called by proc
            # scilaberror from execfile
            unsetdebuggerbusycursor
            return $execresult
        }

        # run the debug, i.e. launch the configured function
        set previousstopfun ""
        set setbptonreallybreakpointedlinescmd $setbpcomm
        setdbstate "DebugInProgress"

        # get the initial value of all breakpoints conditions
        saveallconditionsvalues

        # reset all hit counts
        resetallhitcounts

        # no need to call removeautovars at this point, Scilab is always at
        # the main level, thus there is no local variables to remove
        set commnvars [createsetinscishellcomm $watchvars]
        set watchsetcomm [lindex $commnvars 0]
        if {$watchsetcomm != ""} {
            # no need for $visibilitycomm, i.e. [lindex $commnvars 2]
            # because here the shell is still at the --> prompt
            ScilabEval_lt "$watchsetcomm" "seq"
        }
        ScilabEval_lt "$setbpcomm; $funnameargs;" "seq"
        getcallstackfromshell
        evalgenericexpinshell
        updateactivebreakpoint
        checkendofdebug_bp $stepmode
        set execresult 0

    } else {
        # <TODO> .sce case if some day the parser uses pseudocode noops
        set execresult 0
    }

    return $execresult
}

# <TODO> step by step support
# I have no fully satisfactory solution for the time being.
# The heart of the matter with step by step execution is that
# once the execution is stopped there is no way of knowing what is the next
# line of code to execute. Of course, it is usually the next code line in the
# sci file, but this is not necessarily true in for, while, if, and case
# structures. I do not foresee any other remedy than a complete code analysis
# performed in Tcl (!), but this is a huge task I'm not prepared to go into.
# Moreover, all this analysis is already (and surely better) done by the
# Scilab interpreter, therefore the best way would probably be to add a new
# Scilab function that would return the line number of the next instruction to
# be executed. This should not be such a tricky thing to do, drawing inspiration
# e.g. from setbpt, where, whatln and so on. However, despite my repeated
# demands for information about the internals to the Scilab team, I never could
# obtain any documentation nor help on this topic. Hence an elegant solution
# for step execution is still to be achieved. Better than nothing, I
# implemented a brute force approach that basically sets a breakpoint
# everywhere. This works but is obviously sub-optimal.

proc stepbystepinto_bp {{checkbusyflag 1} {rescanbuffers 1}} {
# perform "step into" debug
    stepbystep_bp $checkbusyflag "into" $rescanbuffers
}

proc stepbystepover_bp {{checkbusyflag 1} {rescanbuffers 1}} {
# perform "step over" debug
    stepbystep_bp $checkbusyflag "over" $rescanbuffers
}

proc stepbystepout_bp {{checkbusyflag 1} {rescanbuffers 1}} {
# perform "step out" debug
    stepbystep_bp $checkbusyflag "out" $rescanbuffers
}

proc stepbystep_bp {checkbusyflag stepmode rescanbuffers} {
# set a breakpoint in Scilab on really every line of every function
# of every opened buffer consistently with the current step mode,
# run execution, delete all those breakpoints and restore the
# breakpoints that were really set by the user
    global funnameargs
    global linenumbersranges previousstepscope
    global CurBreakpointedMacros CurBreakpointedLines ; # globality mandatory, and only used while skipping lines (see proc checkendofdebug_bp)

    # warn the user about duplicate function names, or unterminated functions
    # possibly found in the opened buffers
    # the debugger won't execute in that case
    if {[checkforduplicateorunterminatedfuns]} {return}

    if {[getdbstate] == "ReadyForDebug"} {
        # always a busy check - this code part cannot be entered
        # while skipping lines without executable statements
        # (which might occur during step by step)
        if {[isscilabbusy 5]} {return}

        clearscilaberror

#        showwrappercode

        if {$funnameargs != ""} {
            set funname [string range $funnameargs 0 [expr {[string first "(" $funnameargs] - 1}]]
            ScilabEval_lt "setbpt(\"$funname\",1);" "seq"
        } else {
            # <TODO> .sce case if some day the parser uses pseudocode noops
        }

        set execresult [execfile_bp $stepmode]

        # about the || 1 below: the delbpt must be done in any case,
        # i.e. whatever the result of the execfile_bp. If $execresult
        # is -1 there was an error during execfile (syntax error in
        # the buffer, ...), or if $execresult is 4 (pause or abort
        # statement), and the breakpoint set a few lines above
        # must be removed here even if $funnameargs might be empty
        # because the error was in a .sce buffer (that has therefore
        # already been cleaned up from its wrapper, thus an empty
        # $funnameargs). On the other hand (i.e. in the normal case
        # where there is no exec error), the breakpoint set above
        # must also be removed because we're in a step command here
        if {$funnameargs != "" || 1} {
            ScilabEval_lt "delbpt(\"$funname\",1);" "seq"
        } else {
            # <TODO> .sce case if some day the parser uses pseudocode noops
        }

        # hidewrappercode is performed in checkendofdebug_bp

    } elseif {[getdbstate] == "DebugInProgress"} {
        # no busy check to allow to skip lines without code (step by step)
        if {$checkbusyflag} {
            if {[isscilabbusy 5]} {return}
        }
        if {$funnameargs != ""} {

#            showwrappercode

            switch -- $stepmode {
                "into"  {set stepscope "current&ancill"}
                "over"  {set stepscope "currentcontext"}
                "out"   {set stepscope "callingcontext"}
                default {set stepscope "allscilabbuffers" ;# should never happen}
            }
            # because the user can open or close files during debug,
            # getlinenumbersranges must be called at each step
            # however, do it a minima, i.e. not when skipping no code lines
            if {![info exists previousstepscope] || \
                ![info exists linenumbersranges]} {
                foreach {linenumbersranges CurBreakpointedMacros CurBreakpointedLines} \
                        [getlinenumbersranges $stepscope "stepbystep"] {}
            } else {
                if {$rescanbuffers || ($previousstepscope != $stepscope) } {
                    foreach {linenumbersranges CurBreakpointedMacros CurBreakpointedLines} \
                            [getlinenumbersranges $stepscope "stepbystep"] {}
                }
            }
            updatebptcomplexityindicators_bp $CurBreakpointedMacros $CurBreakpointedLines
            set previousstepscope $stepscope
            set cmd $linenumbersranges
            # check Scilab limits in terms of breakpoints
            if {$cmd == "-1"} {
                # abort step-by-step command - do nothing
            } elseif {$cmd == "0"} {
                # execute "Go to next breakpoint" instead
                tonextbreakpoint_bp
            } else {
                # no limit exceeded - go on one step
                regsub -all -- {\(} $cmd "setbpt(" cmdset
                regsub -all -- {\(} $cmd "delbpt(" cmddel
                ScilabEval_lt "$cmdset" "seq"
                # here tricky (but correct) behaviour!!
                # resume_bp calls checkendofdebug_bp that constructs a string
                # containing TCL_EvalStr("Scilab_Eval_lt ... seq"","scipad")
                # this string is itself evaluated by a ScilabEval_lt seq, so the order
                # in queue is first Tcl_EvalStr("Scilab_Eval_lt ... seq"","scipad")
                # queued by checkendofdebug_bp, and second $cmddel queued from here
                # Then Scilab executes the statements one by one: the first item
                # results in queueing at the end what is in the ScilabEval_lt (the ...
                # above) and that's all. Then $cmddel gets executed, and finally
                # the ... get executed
                # Order of execution is therefore $cmddel and, after it only, the
                # contents of proc checkendofdebug_bp
                resume_bp $checkbusyflag $stepmode
                ScilabEval_lt "$cmddel" "seq"
            }

            # hidewrappercode is performed in checkendofdebug_bp

        } else {
            # <TODO> .sce case if some day the parser uses pseudocode noops
        }

    } else {
        tk_messageBox -message "Unexpected debug state in proc stepbystep_bp: please report"
    }
}

proc getlinenumbersranges {stepscope messagetype} {
# get all line numbers ranges of all functions from the given
# step by step scope $stepscope, which can be
#   - allscilabbuffers : functions from all scilab scheme buffers
#   - configuredfoo    : only the function that was selected in the
#                        configure box
#   - currentcontext   : functions listed in the call stack at the
#                        current stop point
#   - callingcontext   : functions listed in the call stack at the
#                        current stop point, except the first one
#   - current&ancill   : userfuns and libfuns called by the function
#                        where the debugger has currently stopped in,
#                        plus functions from "currentcontext" above
#
# line numbers are logical in Scilab-4.1.2, Scilab-Gtk-4.2 and Scicoslab-4.3
# but physical in Scilab-5 and Scicoslab-4.x (x>3)
#
# return value is a list with 3 elements: {item1 n m} where:
#  item1 is normally a single string:
#   ("$fun1",1:max1);("$fun2",1:max2);...;("$funN",1:maxN);
# this format is especially useful when this string is used to set or
# delete breakpoints in all the lines - just use a regsub to replace
# the opening parenthesis by setbpt( or delbpt(
# for libfun ancillaries, max is always 1 such that the output string
# is simplified for these items: ("$libfun1",1)
#  n is the number of currently breakpointed macros
#  m is the number of currently breakpointed lines
#
# in case any Scilab limit is exceeded, item1 is a string containing
# a return code:
#   "0"  : the calling procedure should apply "Go to next breakpoint" instead
#          of the intended (step-by-step) command
#   "-1" : the calling procedure should cancel the current command
#
# in case any Scilab limit is exceeded, this proc displays a message box
# that can be selected by the input parameter $messagetype:
#   "stepbystep" : the user can select between cancelling the debug command
#                  he launched, or jumping to the next breakpoint
#   "break"      : the user has no choice at all, the debug command he
#                  launched cannot be executed
#
# note that this proc provides ranges [1:n], even if in such ranges there are
# lines that it does not make sense to breakpoint (e.g. nocode lines)
# it seems easier and more performant to skip such lines when the debug is
# running, rather than trying to eliminate them from the above range in this
# proc (which is called at each debug step and will check for a potentially
# large number of macros and lines in them)
# drawback: the available low number of breakpoints $ScilabCodeMaxBreakpoints
# is not cleverly used and some of them get wasted

    global ScilabCodeMaxBreakpointedMacros ScilabCodeMaxBreakpoints
    global debugassce
    global callstackfuns callstacklines
    global debugger_fun_ancillaries
    global pad
    global Scilab5 Scicoslab

    set cmd ""
    set nbmacros 0 ; # used to test max number of breakpointed macros
    set nbbreakp 0 ; # used to test max number of breakpoints

    foreach {ta funsinthatta} [getallfunsinalltextareas] {
        if {[lindex $funsinthatta 0] == "0NoFunInBuf"} {
            continue
        }
        foreach {funname funline precfun} $funsinthatta {

            if {![isinstepscope $funname $stepscope]} {
                continue
            } else {
                incr nbmacros
            }

            set curpos [getendfunctionpos $ta $precfun]
            if {$curpos == -1} {
                # should never happen since handled much ealier by checkforduplicateorunterminatedfuns, but...
                tk_messageBox -message "Unexpected missing endfunction in proc getlinenumbersranges: please report"
            }

            # $curpos now contains the index in $ta of the first n of the word
            # endfunction corresponding to $funname

            if {$Scilab5 || $Scicoslab} {
                # last line number is the last physical line in fun, corrected according
                # to the number of continued lines making the first logical line of the
                # function
                scan $precfun "%d." startoffunlineinta
                scan $curpos  "%d." endoffunlineinta
                set offsetline1continued [getnboftaggedcontlinesmakingfunfirstline $ta $precfun]
                set lastlinenumber [expr {$endoffunlineinta - $startoffunlineinta - $offsetline1continued}]
            } else { 
                # for getting the last logical line number, the correct solution is
                # to call whichfun
                # counting continued lines must not be done, despite quicker, because
                # since it counts tags it would also count continued lines pertaining
                # to nested functions, which would mess up the total
                set infun [whichfun $curpos $ta]
                set posoflastlinenumber [lindex $infun 1]
                scan $posoflastlinenumber "%d." lastlinenumber 
            }

            # if the debug occurs on a .sce file wrapped in a function, the
            # last four logical line numbers contain the code added to return
            # local variables to the calling level and should not be
            # breakpointed since they constitute hidden code
            # however, this must not be done for user-defined functions in
            # the case of mixed .sce/.sci files, it must only be done for
            # the wrapper function which is the one that has the
            # endfunction keyword on the last line of the buffer
            # in details: end -1c (last newline) -1l linestart (prev. line)
            # +1c (first n of "endfunction")
            if {$debugassce && \
                [$ta compare $curpos == [$ta index "end -1c -1l linestart + 1c"]]} {
                incr lastlinenumber -4
            }

            # special case of the empty .sce file: there is a function, which is
            # the wrapper, so this part of code is actually entered in
            if {$lastlinenumber == 0} {
                set lastlinenumber 1
            }

            append cmd "(\"$funname\",1:" $lastlinenumber ");"

            incr nbbreakp $lastlinenumber
        }
    }
    # libfun ancillaries of the function where the debugger is currently in
    # note: variable callstackfuns is set by Scilab script FormatWhereForWatch
    if {$stepscope == "current&ancill"} {
        set currentfunction [lindex $callstackfuns 0]
        set taofcurrentfunction [lindex [funnametofunnametafunstart $currentfunction] 1]
        if {$taofcurrentfunction == ""} {
            # the textarea containing the function where the debugger is
            # currently in has been closed previously by the user
            # this probably means that the user does not want to continue
            # stepping in that function, therefore don't open it again!
            # this is obtained simply by doing nothing here, no ancillary
            # is breakpointed (ancillaries of a foo here include foo itself)
            # note: closure of the main file (the one that contains the
            # function to debug) is treated in proc removefuns_bp
        } else {
            set lfanclist [getlistofancillaries $taofcurrentfunction $currentfunction "libfun"]
            foreach libfunanc $lfanclist {
                # don't breakpoint debugger ancillaries
                if {[lsearch -exact $debugger_fun_ancillaries $libfunanc] != -1} {
                    continue
                }
                # check if ancillary is already breakpointed - if it is, then its
                # breakpointed lines range is greater than just the first line
                # -> nothing to do
                # note: escaped quotes mandatory to distinguish "modulo" from
                # "pmodulo" !
                if {[string first "\"$libfunanc\"" $cmd] == -1} {
                    append cmd "(\"$libfunanc\",1);"
                    incr nbbreakp
                    incr nbmacros
                }
            }
        }
    }
    # libfun ancillaries for nested constructs, e.g. pmodulo(modulo()),
    # breakpoint all the ancillaries that show up on the calling line
    # of the upper level function
    if {[llength $callstackfuns] > 1} {
        set callingfunction [lindex $callstackfuns 1]
        set taofcallingfunction [lindex [funnametofunnametafunstart $callingfunction] 1]
        if {$taofcallingfunction == ""} {
            # the textarea containing the upper level function has been
            # closed previously by the user
            # Scipad should still breakpoint the ancillaries of that calling
            # function, the problem is that it cannot know which ancillaries
            # are contained in that function without opening and colorizing
            # the corresponding file that was closed
            # Scipad even cannot breakpoint just the calling function itself
            # because the last line number of that function is not known,
            # therefore the only solution is to do nothing!
            # consequence: when stepping out of the current function, the
            # calling function will be skipped and execution will stop again
            # in the caller of the caller
        } else {
            set callingfuncline [lindex $callstacklines 1]
            # whatever the Scilab environment, $callingfuncline must be logical
            # in order to be provided in getlistofancillaries, therefore convert conditionally
            set callingfuncline [condphyslinetologline $callingfunction $callingfuncline]
            set lfanclist [getlistofancillaries $taofcallingfunction $callingfunction "libfun" $callingfuncline]
            foreach libfunanc $lfanclist {
                # don't breakpoint debugger ancillaries
                if {[lsearch -exact $debugger_fun_ancillaries $libfunanc] != -1} {
                    continue
                }
                # check if ancillary is already breakpointed - if it is, then its
                # breakpointed lines range is greater than just the first line
                # -> nothing to do
                # note: escaped quotes mandatory to distinguish "modulo" from
                # "pmodulo" !
                if {[string first "\"$libfunanc\"" $cmd] == -1} {
                    append cmd "(\"$libfunanc\",1);"
                    incr nbbreakp
                    incr nbmacros
                }
            }
        }
    }

    # From help setbpt: The maximum number of functions with breakpoints
    #                   enabled must be less than 100 and the maximum number
    #                   of breakpoints is set to 1000
    # Check it and ask what to do if any limit is exceeded
    if {$nbmacros >= $ScilabCodeMaxBreakpointedMacros} {
       # number is > 100%
       updatebptcomplexityindicators_bp $nbmacros $nbbreakp
       set mes [concat [mc "You have currently"] $nbmacros [mc "functions in your opened files."] \
                        [mc "Scilab supports a maximum of"] $ScilabCodeMaxBreakpointedMacros \
                        [mc "possible breakpointed functions (see help setbpt)."] ]
       set tit [mc "Too many breakpointed functions"]
       if {$messagetype == "stepbystep"} {
           set mes [concat $mes \
                            [mc "Step-by-step hence cannot be performed."] \
                            [mc "This command will actually run to the next breakpoint."] ]
            set answer [tk_messageBox -message $mes -title $tit \
                            -icon warning -type okcancel -parent $pad]
            switch -- $answer {
                ok     {set cmd "0"}
                cancel {set cmd "-1"}
            }
        } else {
            #$messagetype == "break"
            set mes [concat $mes \
                            [mc "Break hence cannot be performed."] ]
            set answer [tk_messageBox -message $mes -title $tit \
                            -icon warning -type ok -parent $pad]
            set cmd "-1"
        }
        set nbmacros [countallbreakpointedmacros]
    }
    if {$nbbreakp >= $ScilabCodeMaxBreakpoints} {
        # number is > 100%
        updatebptcomplexityindicators_bp $nbmacros $nbbreakp
        set mes [concat [mc "Executing this command would require to set"] $nbbreakp \
                        [mc "breakpoints in your opened files."] \
                        [mc "Scilab supports a maximum of"] $ScilabCodeMaxBreakpoints \
                        [mc "possible breakpoints in Scilab (see help setbpt)."] ]
        set tit [mc "Too many breakpoints"]
        if {$messagetype == "stepbystep"} {
            set mes [concat $mes \
                            [mc "Step-by-step hence cannot be performed."] \
                            [mc "This command will actually run to the next breakpoint."] ]
            set answer [tk_messageBox -message $mes -title $tit \
                            -icon warning -type okcancel -parent $pad]
            switch -- $answer {
                ok     {set cmd "0"}
                cancel {set cmd "-1"}
            }
        } else {
            set mes [concat $mes \
                            [mc "Break hence cannot be performed."] ]
            set answer [tk_messageBox -message $mes -title $tit \
                            -icon warning -type ok -parent $pad]
            set cmd "-1"
        }
        set nbbreakp [countallbreakpointedlines]
    }

    return [list $cmd $nbmacros $nbbreakp]
}

proc isinstepscope {funname stepscope} {
# return true if function name $funname is in step scope $stepscope
# see proc getlinenumbersranges for the available scopes
    global funnameargs
    global callstackfuns
    global debugger_fun_ancillaries

    # the debugger ancillaries cannot be debugged and shouldn't be stepped
    if {[lsearch -exact $debugger_fun_ancillaries $funname] != -1} {
        return false
    }

    if {$stepscope == "allscilabbuffers"} {
        return true

    } elseif {$stepscope == "configuredfoo"} {
        set oppar [expr {[string first "\(" $funnameargs] - 1}]
        set configuredfunname [string range $funnameargs 0 $oppar]
        if {$funname == $configuredfunname} {
            return true
        } else {
            return false
        }

    } elseif {$stepscope == "currentcontext"} {
        # note: variable callstackfuns is set by Scilab script FormatWhereForWatch
        if {[lsearch -exact $callstackfuns $funname] != -1} {
            return true
        } else {
            return false
        }

    } elseif {$stepscope == "callingcontext"} {
        # note: variable callstackfuns is set by Scilab script FormatWhereForWatch
        if {[llength $callstackfuns] > 1} {
            set callcont [lreplace $callstackfuns 0 0]
            if {[lsearch -exact $callcont $funname] != -1} {
                return true
            } else {
                return false
            }
        } else {
            return false
        }

    } elseif {$stepscope == "current&ancill"} {
        # current context plus ancillaries tagged as "userfun"
        # try current context first since looking for ancillaries is slow
        if {[isinstepscope $funname "currentcontext"]} {
            return true
        } else {
            set currentfunction [lindex $callstackfuns 0]
            set taofcurrentfunction [lindex [funnametofunnametafunstart $currentfunction] 1]
            set ufanclist [getlistofancillaries $taofcurrentfunction $currentfunction "userfun"]
            if {[lsearch -exact $ufanclist $funname] != -1} {
                return true
            } else {
                return false
            }
        }

    } else {
        tk_messageBox -message "Unexpected step scope ($stepscope) in proc isinstepscope. Please report."
        return false
    }
}

proc runtocursor_bp {{checkbusyflag 1} {skipbptmode 0}} {
    global cursorfunname cursorfunline

    # no busy check to allow to skip stops at the wrong breakpoint
    if {$checkbusyflag} {
        if {[isscilabbusy 5]} {return}
    }

    # warn the user about duplicate function names, or unterminated functions
    # possibly found in the opened buffers
    # the debugger won't execute in that case
    if {[checkforduplicateorunterminatedfuns]} {return}

    set textarea [gettextareacur]

    # if the cursor is in the wrapper code (.sce files case), move it out
    if {[lsearch [$textarea tag names insert] "db_wrapper"] != -1} {
        set wrapstart [$textarea tag prevrange "db_wrapper" insert]
        set wrapstart [lindex $wrapstart 0]
        $textarea mark set insert "$wrapstart - 1 c"
    }

    set infun [whichfun [$textarea index insert] $textarea]
    if {$infun!=""} {
        if {!$skipbptmode} {
            set cursorfunname [lindex $infun 0]
            # $cursorfunline must be logical or physical depending on the Scilab environment
            # however [lindex $infun 1] always return logical line numbers
            # therefore the call to condloglinetophyslineinfun_*
            # finally, substract 1 since we want to stop before this line and not after
            set cursorfunline [condloglinetophyslineinfun $cursorfunname [lindex $infun 1]]
            set cursorfunline [expr {$cursorfunline - 1}]
            if {$cursorfunline == 0} {
                # cursor is on the function definition line
                set cursorfunline 1
            }
        }
        # setbpt/delbpt line number do not need to be adjusted here to fit the Scilab environment,
        # since this was already conditionally done above in the call to condloglinetophyslineinfun
        set setbpcomm "setbpt(\"$cursorfunname\",$cursorfunline);"
        ScilabEval_lt $setbpcomm "seq"
        tonextbreakpoint_bp $checkbusyflag "runtocur"
        set delbpcomm "delbpt(\"$cursorfunname\",$cursorfunline);"
        ScilabEval_lt $delbpcomm "seq"
    } else {
        showinfo [mc "Cursor must be in a function"]
    }
}

proc iscursorplace_bp {} {
# return true if the current stop occurs at line $cursorfunline of
# function $cursorfunname
# return false otherwise
    global cursorfunname cursorfunline
    global callstackfuns callstacklines
    if {[lindex $callstackfuns 0] == $cursorfunname} {
        # $callstacklines and $cursorfunline are of the same "type" (i.e.
        # both logical or both physical) whatever the Scilab environment,
        # for $callstacklines see function FormatWhereForWatch,
        # for $cursorfunline see proc runtocursor_bp
        if {[expr {[lindex $callstacklines 0] -1}] == $cursorfunline} {
            return true
        }
    }
    return false
}

proc runtoreturnpoint_bp {{checkbusyflag 1} {skipbptmode 0}} {
    global currentfunname
    global currentfunreturnlinesvector

    # no busy check to allow to skip stops at the wrong breakpoint
    if {$checkbusyflag} {
        if {[isscilabbusy 5]} {return}
    }

    # warn the user about duplicate function names, or unterminated functions
    # possibly found in the opened buffers
    # the debugger won't execute in that case
    if {[checkforduplicateorunterminatedfuns]} {return}

    if {!$skipbptmode} {
        buildlistofreturnpoints
    }

    # setbpt/delbpt line number do not need to be adjusted here to fit the Scilab environment,
    # since this was already conditionally done above in the call to buildlistofreturnpoints
    # when $currentfunreturnlinesvector has been created
    set setbpcomm "setbpt(\"$currentfunname\",$currentfunreturnlinesvector);"
    ScilabEval_lt $setbpcomm "seq"
    tonextbreakpoint_bp $checkbusyflag "runtoret"
    set delbpcomm "delbpt(\"$currentfunname\",$currentfunreturnlinesvector);"
    ScilabEval_lt $delbpcomm "seq"
}

proc buildlistofreturnpoints {} {
    global currentfunname currentfunreturnlineslist
    global currentfunreturnlinesvector
    global lastscecodepos
    global funnameargs callstackfuns
    global stoppauselevelatruntoreturnlaunch
    global pad

    # $stoppauselevelatruntoreturnlaunch differs from $prevdbpauselevel in that the latter
    # might change at each stop (including when skipping lines) but the former only receives
    # a value when the user uses the Run to return command - The difference is important
    # only when debugging recursive functions
    set stoppauselevelatruntoreturnlaunch [llength $callstackfuns]

    # retrieve the current function name
    if {[getdbstate] == "ReadyForDebug"} {
        # use the configured function as current function
        set oppar [string first "\(" $funnameargs]
        set currentfunname [string range $funnameargs 0 [expr {$oppar - 1}]]
    } else {
        # [getdbstate] is "DebugInProgress"
        set currentfunname [lindex $callstackfuns 0]
    }

    # build the list of exit points for the current function
    # this includes the line containing the endfunction keyword corresponding
    # to the function declaration line (there can be only one such line in
    # Scilab, no multiple "endfunction" for one "function"), but also possibly
    # multiple "return" and "resume" statements
    # in case the current function is the .sce wrapper, then the debug occurs
    # in the main level part of a .sce file, and there is no endfunction at all
    # this is dealt with a little further below
    set fntafs [funnametofunnametafunstart $currentfunname]
    if {$fntafs == ""} {
        # the function where the debug just stopped is currently not opened
        # in Scipad (perhaps the user closed it manually before)
        set mes [mc "This command cannot succeed if the function where the debug just stopped is not opened in Scipad!"]
        set tit [mc "Cannot run to return point"]
        tk_messageBox -message $mes -icon warning -title $tit -parent $pad
        return
    }
    set currentfunta [lindex $fntafs 1]
    set currentfunstartline [lindex $fntafs 2]
    set currentfunendfunctionpos [getendfunctionpos $currentfunta $currentfunstartline "all_return_points"]
    if {$currentfunendfunctionpos == -1} {
        # should never happen since handled much ealier by checkforduplicateorunterminatedfuns, but...
        tk_messageBox -message "Unexpected missing endfunction in proc buildlistofreturnpoints: please report"
    }
    set currentfunreturnlineslist [list ]
    set currentfunreturnlinesvector {[}
    foreach returnpointpos $currentfunendfunctionpos {
        # if the return point is in the wrapper code (.sce files case),
        # then it is the endfunction keyword of the wrapper
        # in this case the last code line before the end wrapper code must
        # be considered as a return position and not the endfunction of
        # the wrapper
        # <TODO> .sce case if some day the parser uses pseudocode noops
        #        this part should be completely rewritten
        set lastscecodepos "" ; # useful in proc isreturnpoint_bp: if not empty then a .sce file is debugged
        if {[lsearch [$currentfunta tag names $returnpointpos] "db_wrapper"] != -1} {
            set wrapstart [$currentfunta tag prevrange "db_wrapper" $returnpointpos]
            set wrapstart [lindex $wrapstart 0]
            # at this point $wrapstart is the position of the first character
            # tagged with the "db_wrapper" tag. It is always the leading \n
            # of the function return instructions inserted in proc Obtainall_bp
            # the position searched is therefore 1 character to the right
            set wrapstart [$currentfunta index "$wrapstart + 1 c"]
            set lastscecodepos [$currentfunta index "$wrapstart - 1 l"]
            while {[isnocodeline $currentfunta $lastscecodepos]} {
                set lastscecodepos [$currentfunta index "$lastscecodepos - 1 l"]
            }
            set returnpointpos $lastscecodepos
            # save position of the previous line since we'll substract 1 below
            set lastscecodepos [expr {$lastscecodepos - 1}]
        }

        # the correct solution is to call whichfun for each return point found
        # counting continued lines must not be done, despite quicker, because
        # since it counts tags it would also count continued lines pertaining
        # to nested functions, which would mess up the total
        set infun [whichfun [$currentfunta index $returnpointpos] $currentfunta]

        # $logicalline_returnpos must be logical or physical depending on the Scilab environment
        # however [lindex $infun 1] always return logical line numbers
        # therefore the call to condloglinetophyslineinfun
        # finally, substract 1 since we want to stop before this line and not after
        set line_returnpos [condloglinetophyslineinfun [lindex $infun 0] [lindex $infun 1]]
        set line_returnpos [expr {$line_returnpos - 1}]
        lappend currentfunreturnlineslist $line_returnpos
        append currentfunreturnlinesvector $line_returnpos {,}
    }
    set currentfunreturnlinesvector [string range $currentfunreturnlinesvector 0 "end-1"] 
    append currentfunreturnlinesvector {]}
}

proc isreturnpoint_bp {} {
# return true if the current stop occurs at one of the return points of the
# current function, i.e. at one of the lines listed in $currentfunreturnlineslist
# of function $currentfunname, and having stopped at a pause level at most equal
# to the current pause level when the run to return command was launched
# return false otherwise
    global currentfunname currentfunreturnlineslist
    global callstackfuns callstacklines
    global sresRE
    global lastscecodepos
    global displayruntoreturnwarning
    global stoppauselevelatruntoreturnlaunch
    global pad

    set returnpointreached false

    # note <= and not == : with == one would climb the entire stack back to
    # the main level in case of a recursive function when the current stop
    # is already on a return point. With <= one climbs just one level, which
    # is much more intuitive
    if {[llength $callstackfuns] <= $stoppauselevelatruntoreturnlaunch} {
        # current stop is less deep than when the run to return command was launched
        if {[lindex $callstackfuns 0] == $currentfunname} {
            set candidateline [expr {[lindex $callstacklines 0] -1}]
            foreach aline $currentfunreturnlineslist {
                # $aline, $candidateline and $callstacklines are of the same "type"
                # (i.e. both logical or both physical) whatever the Scilab environment
                if {$aline == $candidateline} {
                    set returnpointreached true
                    break
                }
           }
        }
    }

    # check if the line containing the return statement starts by
    # this statement, or if it has other instructions before it
    # the warning shall not be displayed if at least one of the following
    # conditions is true:
    #    . the current stop point is not a return point (i.e. the debug
    #      stopped at a breakpoint set by the user, and this breakpoint
    #      has to be skipped)
    #    . the current stop point is the last code line of the .sce file
    #      currently debugged: this line normally never contains a return
    #      statement, but it is nevertheless the final return point seen
    #      by the user (for this test, it is checked that $lastscecodepos
    #      contains or not the current stop point; for .sci debug,
    #      $lastscecodepos is always empty, thus disabling this check)
    #    . the user has already seen the warning message about his code
    #      style and does not want to see it anymore
    if { $returnpointreached && \
         $lastscecodepos != $candidateline && \
         $displayruntoreturnwarning } {
        set curpos [[gettextareacur] index insert]
        set textline [[gettextareacur] get "$curpos linestart" "$curpos lineend"]
        if {![regexp -- $sresRE $textline]} {
            set mes [concat [mc "Warning!\nThe line where the debugger just stopped contains a return statement (either endfunction, return or resume) but this statement is not the first one on the line."] \
                            [mc "As a consequence the debugger cannot predict if the next debug step will really jump outside of the current function, which is what you just asked the debugger to do."] \
                            [mc "To avoid this unresolvable case, it is recommended to place the return statement alone on its line."] \
                            [mc "Do you want to see this warning again during this Scipad session?"] ]
            set tit [mc "Unresolvable case found while running to return point"]
            set res [tk_messageBox -message $mes -icon warning -title $tit -type yesno -parent $pad]
            if {$res == "no"} {
                set displayruntoreturnwarning false
            }
        }
    }

    return $returnpointreached
}

proc resume_bp {{checkbusyflag 1} {stepmode "nostep"}} {
    global funnameargs waitmessage watchvars
    global callstackfuns previousstopfun
    global curbptta curbptpos

    # no busy check to allow to skip lines without code (step by step)
    if {$checkbusyflag} {
        if {[isscilabbusy 5]} {return}
    }

    # warn the user about duplicate function names, or unterminated functions
    # possibly found in the opened buffers
    # the debugger won't execute in that case
    if {[checkforduplicateorunterminatedfuns]} {return}

    showinfo $waitmessage
    if {$funnameargs != ""} {
        setdebuggerbusycursor
        if {![isnocodeorcondcontline $curbptta $curbptpos]} {
            # the debugger is not currently skipping no code lines
            # save the name of the function in which the debugger stopped before resuming
            set previousstopfun [lindex $callstackfuns 0]
            # save current value so that changes can be detected later
            # and the variable be tagged
            savecurrentwatchvarsvalues
            removeautovars
            set commnvars [createsetinscishellcomm $watchvars]
            set watchsetcomm [lindex $commnvars 0]
            if {$watchsetcomm != ""} {
                set visibilitycomm [lindex $commnvars 2]
                ScilabEval_lt "$visibilitycomm;$watchsetcomm" "seq"
                set returnwithvars [lindex $commnvars 1]
                ScilabEval_lt "$returnwithvars" "seq"
            } else {
                ScilabEval_lt "resume(0)" "seq"
            }
            getcallstackfromshell
            evalgenericexpinshell
        } else {
            # the debugger is currently skipping no code lines
            # the watch variables do not have to be updated
            ScilabEval_lt "resume(0)" "seq"
        }
        updateactivebreakpoint
        checkendofdebug_bp $stepmode
    } else {
        # <TODO> .sce case if some day the parser uses pseudocode noops
    }
}

proc goonwo_bp {} {
    global funnameargs waitmessage

    if {[isscilabbusy 5]} {return}

    # warn the user about duplicate function names, or unterminated functions
    # possibly found in the opened buffers
    # the debugger won't execute in that case
    if {[checkforduplicateorunterminatedfuns]} {return}

    # no test on [getdbstate], this proc can only be called in "DebugInProgress"
    # state (this is set by the debugger state machine in proc setdbmenuentriesstates_bp)

    showinfo $waitmessage
    if {$funnameargs != ""} {
        removeallactive_bp
        removeallbpt_scilab "with_output"
        resume_bp
    } else {
        # <TODO> .sce case if some day the parser uses pseudocode noops
    }
}

proc break_bp {} {
    global funnameargs
    global breakcommandtriggered

    if {[isscilabbusy]} {
        if {$funnameargs != ""} {
            set stepscope "allscilabbuffers"
            set cmd [lindex [getlinenumbersranges $stepscope "break"] 0]
            # check Scilab limits in terms of breakpoints
            if {$cmd == "-1" || $cmd == "0"} {
                # impossible to set the required breakpoints
                # a message box has already been displayed in proc
                # getlinenumbersranges, there is nothing more
                # to do
                return
            } else {
                # no limit exceeded - go on and set them 
                set breakcommandtriggered true
                regsub -all -- {\(} $cmd "setbpt(" cmdset
                regsub -all -- {\(} $cmd "delbpt(" cmddel
                # execute now in a dedicated parser the breakpoint setting,
                # so that the main parser will see them in the not too
                # distant future
                ScilabEval_lt "$cmdset" "sync" "seq"
                # now queue a command in the main parser, in order to remove
                # the breakpoints set for the break command - this is not an
                # issue for future commands since proc checkendofdebug_bp
                # will anyway set breakpoints later on really breakpointed
                # lines
                ScilabEval_lt "$cmddel" "seq"
                # updateactivebreakpoint, getwatchvarfromshell,
                # getcallstackfromshell and evalgenericexpinshell are already
                # queued by the previous command that stucked the script, it's
                # not needed to repeat these commands here
                # indeed this is even true when the break command occurs on a
                # nocode line since the debugger now skips those lines even on
                # a break (see proc checkendofdebug_bp)
            }
        } else {
            # <TODO> .sce case if some day the parser uses pseudocode noops
        }

    } else {
        # note that the activation of the execution of the Break command
        # depends on $sciprompt working correctly - thus can't work in Scilab 5...!
        showinfo [mc "No effect - The debugged file is not stuck"]
    }
}

proc isbreakhit_bp {} {
# return true if the user has triggered the break debug command
# return false otherwise
    global breakcommandtriggered
    return $breakcommandtriggered
}

proc resetbreakhit_bp {} {
# reset the break command flag to false
    global breakcommandtriggered
    set breakcommandtriggered false
}

proc canceldebug_bp {} {
    global funnameargs waitmessage

    if {[isscilabbusy 5]} {return}

    # note: here no checkforduplicateorunterminatedfuns is made because
    # there is one case where a duplicate exists temporarily: when exec-ing
    # the temp buffer containing all the non level zero code (see proc
    # execfile_bp). If this exec fails, then a canceldebug_bp is launched
    # by proc scilaberror, and at this point the temp buffer has not yet
    # been closed, thus a duplicate would be found here
    # anyway, real duplicates should have been detected before the user
    # hits the cancel button

    if {[getdbstate] == "DebugInProgress"} {
        showinfo $waitmessage
        if {$funnameargs != ""} {
            # save current value so that changes can be detected later
            # and the variable be tagged
            savecurrentwatchvarsvalues
            removeautovars
            removeallactive_bp
            ScilabEval_lt "abort" "seq"
            removeallbpt_scilab "with_output"
            getwatchvarfromshell
            getcallstackfromshell
            evalgenericexpinshell
            cleantmpScilabEvalfile
        }
    } else {
        # [getdbstate] is "ReadyForDebug" - nothing to do
    }

    scedebugcleanup_bp 

    # dbstate must be set explicitely to NoDebug here, because
    # scedebugcleanup_bp does nothing for .sci files
    setdbstate "NoDebug"

}

proc hasstoppedinthesamefun {} {
# return true if the current debug stop is in the same function
# as the previous stop was, otherwise return false
    global previousstopfun
    global callstackfuns
    if {[lindex $callstackfuns 0] == $previousstopfun} {
        return true
    } else {
        return false
    }
}

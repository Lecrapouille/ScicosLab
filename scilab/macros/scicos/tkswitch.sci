function block=tkswitch(block,flag)
  blknb=string(curblock())
  if flag==4 then
    cur=%cpr.corinv(curblock())
    if size(cur,'*')==1 then // open widget only if the block 
                             // is in main Scicos editor window
      o=scs_m.objs(cur).graphics.orig;
      sz=scs_m.objs(cur).graphics.sz
      pos=point2pixel(1000,o)
      pos(1)=pos(1)+width2pixel(1000,sz(1)) // widget position 
      geom='wm geometry $w +'+string(pos(1))+'+'+ string(pos(2));
    else
      geom=[]
    end
      titled=block.label
      if titled=='' then titled="TK Manual Switch",end
      tit='wm title $w Switch'+blknb // write block label
      sel=block.ipar

      txt=['set w .vscale'+blknb;
           'set chs'+blknb+' '+string(sel);
           'catch {destroy $w}';
           'toplevel $w';
           tit
           geom
           'wm attributes $w -topmost'
           'radiobutton $w.r1 -text 1 -variable chs'+blknb+' -value 1'
           'radiobutton $w.r2 -text 2  -variable chs'+blknb+' -value 2'
           'label $w.l -text '"'+titled+''"'
           'grid $w.r1 -row 1 -column 0 -sticky w'
           'grid $w.r2 -row 2 -column 0 -sticky w'
           'grid $w.l -row 0 -column 1 -sticky w'
          ];
      TCL_EvalStr(txt) // call TCL interpretor to create widget

  elseif flag==1|flag==6 then // evaluate output during simulation
    TCL_EvalStr('catch {wm attributes .vscale'+blknb+' -topmost 1}')
    if execstr('ch=evstr(TCL_GetVar(''chs''+blknb))','errcatch')>0 then
        ch=block.ipar
    end
    block.outptr(1)=block.inptr(ch)
  end
endfunction

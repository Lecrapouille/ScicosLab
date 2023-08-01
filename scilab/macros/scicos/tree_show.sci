function tree_show(x,titletop)
// Copyright INRIA

 if type(x)<>16&type(x)<>17&type(x)<>15 then
    error("Wrong type; input must be a list.")
 end

tt = ["set BWpath [file dirname '"$env(SCIPATH)/tcl/bwidget-1.9.13'"] "
      "if {[lsearch $auto_path $BWpath]==-1} { set auto_path [linsert $auto_path 0 $BWpath] }" 
      "package require BWidget 1.9.13"
//      'proc ppx {label} {global xmind; set xmind $label;ScilabEval '"%tcl_par=''1'''"}'
//      'proc qqx {label} {global xmind; set xmind $label;ScilabEval '"%tcl_par=''3'''"}'
      'catch {destroy .ss}'
      'toplevel .ss'
      'scrollbar .ss.ysb -command {.ss.t yview}'
      'scrollbar .ss.xsb -command {.ss.t xview} -orient horizontal'
      'Tree .ss.t -xscrollcommand '".ss.xsb set'" -yscrollcommand '".ss.ysb set'" "+...
      " -width 30'
      'grid .ss.t .ss.ysb -sticky nsew'
      ' grid .ss.xsb -sticky ew'
      ' grid rowconfig    .ss 0 -weight 1'
      ' grid columnconfig .ss 0 -weight 1'
     ];

for i=1:size(tt,1)
  TCL_EvalStr(tt(i))
end


if argn(2)>1 then
   tt = 'wm title .ss {'+titletop+'}';
elseif type(x)<>15 then
   v = getfield(1,x);
   tt = 'wm title .ss '+v(1);
else
   tt = 'wm title .ss list';
end

TCL_EvalStr(tt)
Path = 'root'
crlist3(x,Path);

//TCL_EvalStr(' .ss.t bindText <Double-1> {ppx}')
//TCL_EvalStr(' .ss.t bindText <3> {qqx}')
endfunction


function crlist3(x,Path)
  if type(x)==15 then
      II=1:size(x);v=string(II);
  else 
      v=getfield(1,x);
      if type(x)==17 & v(1)=='st' then
         II=3:size(v,'*');
      else
         II=2:size(v,'*');
      end
  end
  for i=II
    path=Path+','+string(i)
    titre=v(i);
    o=getfield(i,x);
    if type(o)==16 |type(o)==17 then
        w=getfield(1,o);
	titre2=titre+' ('+w(1)+')';
	TCL_EvalStr('.ss.t insert end '+Path+' '+path+' -image [Bitmap::get folder] -text {'+titre2+'}')
	crlist3(o,path) //* recursive 
    elseif type(o)==15 then
	titre2=titre;
	TCL_EvalStr('.ss.t insert end '+Path+' '+path+' -image [Bitmap::get folder] -text {'+titre2+'}')
	crlist3(o,path) //** recursive 
    elseif type(o)==13 then
        [in,out,text]=string(o)
        txt='[';
        for ii=1:size(out,'*'), txt=txt+out(1,ii), if ii<>size(out,'*'), txt=txt+',',end,end
        txt=txt+']=function('
        for ii=1:size(in,'*'), txt=txt+in(1,ii), if ii<>size(in,'*'), txt=txt+',',end,end
        txt=txt+')'
	titre2=titre+': '+txt+'';
        TCL_EvalStr('set yy {'+titre2+'}')
        TCL_EvalStr('.ss.t insert end '+Path+' '+path+' -text $yy')
        clear o
    else
        if size(o,'*')>40 then
          tts=typeof(o)+' of size '+sci2exp(size(o))
        else
          tts=sprintf('%s',sci2exp(o))
        end
        titre2=titre+': '+tts  ;
        TCL_EvalStr('set yy {'+titre2+'}')
        TCL_EvalStr('.ss.t insert end '+Path+' '+path+' -text $yy')
    end
  end
  
endfunction


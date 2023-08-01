function [model,ok]=recur_scicos_block_link(o,flag)
// Copyright INRIA
model=o.model;ok=%t;
if or(o.model.sim(1)==['super','csuper','asuper']) then
  obj=o.model.rpar;
  for i=1:size(obj.objs)
    o1=obj.objs(i);
    if typeof(o1)=='Block'
      if (or(o1.model.sim(1)==['super','csuper','asuper'])) then
	[model,ok]=recur_scicos_block_link(o1,flag)
	if ~ok then return; end
      elseif type(o1.model.sim)==15 
	if or(int(o1.model.sim(2)/1000)==[1,2]) then
	  model=o1.model
	  funam=o1.model.sim(1)
	  if ~c_link(funam) then
	    tt=o1.graphics.exprs(2)
	    mputl(tt,TMPDIR+'/'+funam+'.c')
	    ok=buildnewblock(funam,funam,'','',%scicos_libs,TMPDIR,'',%scicos_cflags)
	    if ~ok then return; end
	  end
	end
      end
    end
  end
  if o.model.sim(1)=='asuper' then
    model=o.graphics.exprs(3)
    funam=model.sim(1)
    if ~c_link(funam) then
      tt=o.graphics.exprs(2)
      mputl(tt,TMPDIR+'/'+funam+'.c')
      ok=buildnewblock(funam,funam,'','',%scicos_libs,TMPDIR,'',%scicos_cflags)
      if ~ok then return; end
    end
  end 
elseif or(int(o.model.sim(2)/1000)==[1,2]) then
  model=o.model
  funam=o.model.sim(1)
  if ~c_link(funam) then
    tt=o.graphics.exprs(2)
    mputl(tt,TMPDIR+'/'+funam+'.c')
    ok=buildnewblock(funam,funam,'','',%scicos_libs,TMPDIR,'',%scicos_cflags)
    if ~ok then return; end
  end
end
endfunction

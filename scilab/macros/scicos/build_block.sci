function [model,ok]=build_block(o)
// Copyright INRIA
// build the simulation function associated with the block if necessary
  model=o.model;
  graphics=o.graphics;

  if model.sim(1)=='scifunc' then
    if type(model.sim)==15 then
      if model.sim(2)==5 | model.sim(2)==10005 then
        name=graphics.exprs(1)(1)
        mputl(graphics.exprs(2),TMPDIR+'/scifunc5_tmp.sci');
        execstr('clear '+name);
        getf(TMPDIR+'/scifunc5_tmp.sci','n');
        execstr('model.sim=list('+name+',model.sim(2))')
      else
        if model.ipar==0 then
         message('A scifunc block has not been defined')
         ok=%f; return
       end
       model.sim=list(genmac(model.ipar,size(model.in,'*'),size(model.out,'*')),3)
      end
    else
      if model.ipar==0 then
        message('A scifunc block has not been defined')
        ok=%f; return
      end
      model.sim=list(genmac(model.ipar,size(model.in,'*'),size(model.out,'*')),3)
    end
  elseif type(model.sim)==15 then
    modsim=modulo(model.sim(2),10000)
    if int(modsim/1000)==1 then   //Fortran Block
      funam=model.sim(1)
      if ~c_link(funam) then
	tt=graphics.exprs(2);
	ok=scicos_block_link(funam,tt,'f')
      end
    elseif int(modsim/1000)==2 then   //C Block
      [model,ok]=recur_scicos_block_link(o,'c')
    elseif model.sim(2)==30004 then //modelica generic file type 30004
      //funam=model.sim(1);tt=graphics.exprs(2);
      if type(graphics.exprs)==15 then //compatibility
        funam=model.sim(1);
        tt=graphics.exprs(2);
      else
        funam=model.equations.model
        tt=graphics.exprs.funtxt;
      end
      [dirF,nameF,extF]=fileparts(funam);
      tarpath=pathconvert(TMPDIR+'/Modelica/',%f,%t);
      if (extF=='') then
	funam=tarpath+nameF+'.mo';
	mputl(tt,funam);
      end
    end   
  end
endfunction

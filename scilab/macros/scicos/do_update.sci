function [%cpr,%state0,needcompile,alreadyran,ok]=do_update(%cpr,%state0,needcompile)
//Update an already compiled scicos diagram compilation result according to 
//parameter changes
//! Last update Fady:15 Dec 2008
// Copyright INRIA
ok=%t
select needcompile
 case 0 then  // only parameter changes 
  if size(newparameters)<>0 then
    cor=%cpr.cor
    [%state0,state,sim,ok]=modipar(newparameters,%state0,%cpr.state,%cpr.sim,scs_m,cor,"compile")
    if ~ok then 
      disp("Partial compilation failed. Attempting a full compilation."); 
      needcompile=4; 
      [%cpr,ok]=do_compile(scs_m)
      if ok then
        %state0=%cpr.state
        needcompile=0
      end
    else
      needcompile=0
      %cpr.state=state,%cpr.sim=sim
    end
  end
case 1 then // parameter changes and/or port sizes change
  if size(newparameters)<>0 then
      // update parameters or states
      cor=%cpr.cor
      [%state0,state,sim]=modipar(newparameters,%state0,%cpr.state,%cpr.sim,scs_m,cor)
      %cpr.state=state,%cpr.sim=sim
  end
  //update port sizes.
  // NB: if modelica part block size has been changed, the diagram is recompiled
  bllst=list();
  corinv=%cpr.corinv
  sim=%cpr.sim
  for k=1:size(corinv)
    if type(corinv(k))==1 then //dont take care of modelica blocks 
      if size(corinv(k),'*')==1 then
	bllst(k)=scs_m.objs(corinv(k)).model;
      else
	path=list('objs');
	for l=corinv(k)(1:$-1),
	  path($+1)=l;
	  path($+1)='model';
	  path($+1)='rpar';path($+1)='objs';
	end
	path($+1)=corinv(k)($);
	path($+1)='model';
	bllst(k)=scs_m(path);
      end
    else // modelica block
      elem=corinv(k)(1)
      if size(elem,'*')==1 then
	oo=scs_m.objs(elem);
      else
	ppath=list('objs');
	for l=elem(1:$-1),
	  ppath($+1)=l;
	  ppath($+1)='model';
	  ppath($+1)='rpar';ppath($+1)='objs';
	end
	ppath($+1)=elem($);
	oo=scs_m(ppath);
      end
      if is_modelica_block(oo) then
	//build a fake bllst(k) only for in and out fields
	m=scicos_model();
	m.in=ones(sim.inpptr(k+1)-sim.inpptr(k),1)
	m.out=ones(sim.outptr(k+1)-sim.outptr(k),1)
	bllst(k)=m;
      else  //sampleclk
	disp("Partial compilation failed. Attempting a full compilation.");
	alreadyran=do_terminate();
	[%cpr,ok]=do_compile(scs_m)
	if ok then
	  %state0=%cpr.state
	  needcompile=0;
	  return
	else
          message("compilation failed"),
	  return
	end	
      end
    end
  end
  [ok,bllst]=adjust(bllst,sim('inpptr'),sim('outptr'),sim('inplnk'),..
      sim('outlnk'))
  if ok then
    [lnksz,lnktyp]=lnkptrcomp(bllst,sim('inpptr'),sim('outptr'),...
	sim('inplnk'),sim('outlnk'))
    // assign int32 to boolean type
    bool_index=find(lnktyp(:)==9)
    lnktyp(bool_index(:))=3
    %cpr.state('outtb')=buildouttb(lnksz,lnktyp)
    %state0('outtb')=%cpr.state('outtb')
    needcompile=0

    [%state0,state,sim,ok]=...
         modipar(%cpr.corinv,%state0,%cpr.state,%cpr.sim,scs_m,%cpr.cor,"compile")
    if ~ok then 
      disp("Partial compilation failed. Attempting a full compilation."); 
      needcompile=4; 
      [%cpr,ok]=do_compile(scs_m)
      if ok then
        %state0=%cpr.state
        needcompile=0
      end
      return,
    else
      %cpr.state=state,%cpr.sim=sim
    end
  end

 case 2 then // partial recompilation
  alreadyran=do_terminate()
  [%cpr,ok]=c_pass3(scs_m,%cpr)
  if ok then
    [%state0,state,sim,ok]=...
       modipar(%cpr.corinv,%state0,%cpr.state,%cpr.sim,scs_m,%cpr.cor,"compile")
    if ~ok then 
      disp("Partial compilation failed. Attempting a full compilation."); 
      needcompile=4; 
      [%cpr,ok]=do_compile(scs_m)
      if ok then
        %state0=%cpr.state
        needcompile=0
      end
      return
    else
      %cpr.state=state,%cpr.sim=sim
      %state0=%cpr.state
      needcompile=0; 
      return
    end
  else
    disp("Partial compilation failed. Attempting a full compilation."); 
    needcompile=4; 
    [%cpr,ok]=do_compile(scs_m)
    if ok then
      %state0=%cpr.state
      needcompile=0
    end
  end
 case 4 then  // full compilation
  alreadyran=do_terminate()
  [%cpr,ok]=do_compile(scs_m)
  if ok then
    %state0=%cpr.state
    needcompile=0
  end
end

endfunction

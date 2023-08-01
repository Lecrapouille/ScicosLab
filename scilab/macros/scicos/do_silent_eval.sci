function [scs_m,cpr,needcompile,ok]=do_silent_eval(scs_m,cpr,%scicos_context,%SubSystemEval,flag)
  // This function (re)-evaluates blocks in the scicos data structure scs_m 
  // Copyright INRIA
  // Last Updated 14 Jan 2009 Fady NASSIF
  global %err_mess_eval
  if argn(2)<2 then cpr=list(); end
  if argn(2)<3 then
    if ~exists('%scicos_context') then
      [%scicos_context,ierr]=script2var(scs_m.props.context,struct());
    end
  end
  if argn(2)<4 then
    if ~exists('%SubSystemEval') then
      %SubSystemEval=%f;
    end
  end

  if ~%SubSystemEval then
    %win0_exists=or(winsid()==0)
  end


  if argn(2)<5 then flag='NONXML';end
  ok=%t
  needcompile1=max(2,needcompile)
  %mprt=funcprot()
  funcprot(0) 
  getvalue=setvalue;
  deff('message(txt)','global %err_mess_eval;'+...
		      'if and(txt<>[[];'' '']) then %err_mess_eval=[%err_mess_eval;''In block ''+o.gui+'': ''+txt];end;global %scicos_prob;%scicos_prob=%t');
  global %scicos_prob
  %scicos_prob=%f

  //## overload some functions used in GUI

  deff('[ok,tt]        =  FORTR(funam,tt,i,o)','ok=%t')
  deff('[ok,tt,cancel] =  CFORTR2(funam,tt,i,o)','ok=%t,cancel=%f')
  deff('[ok,tt,cancel,'+...
       'libss,cflags] =  CC4(funam,tt,i,o,libss,cflags)','ok=%t,cancel=%f')
  deff('[ok,tt]        =  CFORTR(funam,tt,i,o)','ok=%t')
  deff('[x,y,ok,gc]    =  edit_curv(x,y,job,tit,gc)','ok=%t')
  deff('[ok,tt,dep_ut] = genfunc1(tt,ni,no,nci,nco,nx,nz,nrp,type_)',...
       'dep_ut=model.dep_ut;ok=%t')
  deff('result         = dialog(labels,valueini)','result=valueini')
  deff('[result,Quit]  = scstxtedit(valueini,v2)','result=valueini,Quit=0')
  deff('[ok,tt]        = MODCOM(funam,tt,vinp,vout,vparam,vparamv,vpprop)',...
       '[dirF,nameF,extF]=fileparts(funam);...
      tarpath=pathconvert(TMPDIR+''/Modelica/'',%f,%t);...
      if (extF=='''')  then,...
         funam1=tarpath+nameF+''.mo'';...
      elseif fileinfo(funam)==[] then,...
         funam1=funam;...
      end;...
      mputl(tt,funam1);')
  %nx=lstsize(scs_m.objs)
  funcprot(%mprt)
  for %kk=1:%nx
    o=scs_m.objs(%kk)
    if typeof(o)=='Block'|(typeof(o)=='Text') then
      if o.gui<>'PAL_f' then
	rpar=o.model.rpar;
	if flag=='XML' then
          graphics=o.graphics;
          sim=o.model.sim;
          ierr=execstr('o='+o.gui+'(""define"",o);','errcatch');
          if ierr<>0 then
            ok=%f;
            if ~%SubSystemEval then
              // if %err_mess_eval<>[] then x_message(%err_mess_eval);end
              clearglobal %err_mess_eval;
              open_win=winsid();// to close the opened windows number 0 
              k=find(open_win==0); // it is openend when evaluating blocks as affiche.
              xdel(open_win(k));
            end
            continue; // return
          end
          //update model compatibility with old csuper blocks
          if lstsize(o.model)<lstsize(scicos_model()) then
            o.model=update_model(o.model);
          end
          o.graphics=graphics;
	end
	model=o.model
	if (model.sim(1)=='super' ...
            | (model.sim(1)=='csuper'& ~isequal(model.ipar,1)) ...
            |(model.sim(1)=='asuper'& flag=='XML') ...
            | (o.gui == 'DSUPER' & flag == 'XML')) then
	  //exclude mask
          sblock=rpar
          context=sblock.props.context
          [scicos_context1,ierr]=script2var(context,%scicos_context)
          if ierr <>0 then
            %now_win=xget('window')
            %err_mess_eval=[%err_mess_eval;'Cannot evaluate a context: '+lasterror()]
            xset('window',%now_win)
          else
            [sblock,%w,needcompile2,ok]=do_silent_eval(sblock,list(),scicos_context1,%t,flag)
            needcompile1=max(needcompile1,needcompile2)
            if ok then
	      o.model.rpar=sblock
	      if flag=='XML' then
		if sim(1)=="asuper" then
                  o.model.sim=sim;
		end
		o.model.in=-1*ones(size(graphics.pin,'*'),1);
		o.model.in2=-2*ones(size(graphics.pin,'*'),1);
		o.model.intyp=-1*ones(1,size(graphics.pin,'*'));
		o.model.out=-1*ones(size(graphics.pout,'*'),1);
		o.model.out2=-2*ones(size(graphics.pout,'*'),1);
		o.model.outtyp=-1*ones(1,size(graphics.pout,'*'));
		o.model.evtin=ones(size(graphics.pein,'*'),1);
		o.model.evtout=ones(size(graphics.peout,'*'),1);
	      end
            else
	      if flag=='XML' then
		// when opening the xml return in case of error else do nothing
		if ~%SubSystemEval then 
		  // if %err_mess_eval<>[] then x_message(%err_mess_eval);end
		  clearglobal %err_mess_eval;
		  open_win=winsid();// to close the opened windows number 0 
		  k=find(open_win==0); // it is openend when evaluating blocks as affiche.
		  xdel(open_win(k));
		end
		ok=%f;continue;// return
	      end
            end
          end
	elseif o.model.sim(1)=='asuper' then
	else
          //should we generate a message here?
          %scicos_prob=%f
          %SB=%SubSystemEval;
          if o.model.sim(1)=='csuper' then %SubSystemEval=%t;end;// compatibility
          ier=execstr('o='+o.gui+'(''set'',o)','errcatch');
          %SubSystemEval=%SB;
          if ier==0& %scicos_prob==%f then
            if flag <>'XML' then
	      needcompile1=max(needcompile1,needcompile); // for scifunc_block
	      model_n=o.model
	      if or(model.blocktype<>model_n.blocktype)|... // type 'c','d','z','l'
		 or(model.dep_ut<>model_n.dep_ut)|...
		 (model.nzcross<>model_n.nzcross)|...
		 (model.nmode<>model_n.nmode) then
		needcompile1=4
	      end
	      if (size(model.in,'*')<>size(model_n.in,'*'))|...
		 (size(model.out,'*')<>size(model_n.out,'*'))|...
		 (size(model.evtin,'*')<>size(model_n.evtin,'*')) then
		//  number of input (evt or regular ) or output  changed
		needcompile1=4
	      end
	      if model.sim=='input'|model.sim=='output' then
		if model.ipar<>model_n.ipar then
		  needcompile1=4
		end
	      end
	      
	      itisanMBLOCK=%f
	      if prod(size(model.sim))>1 then
		if (model.sim(2)==30004) then 
		  itisanMBLOCK=%t
		end
	      end

	      if (prod(size(model.sim))==1 & ~model.equations==list()) | itisanMBLOCK then
		if ~isequal(model.equations.parameters,model_n.equations.parameters) then
		  param_name   = model.equations.parameters(1);
		  param_name_n = model_n.equations.parameters(1);
		  if ~isequal(param_name,param_name_n) then
		    needcompile1=4
		  else
		    for i=1:length(model.equations.parameters(2))
		      if or((model.equations.parameters(2)(i))<>(model_n.equations.parameters(2)(i))) then
			needcompile=0
			XML=TMPDIR+'/'+stripblanks(scs_m.props.title(1))+'_imf_init.xml';
			XML=pathconvert(XML,%f,%t);    
			XMLTMP=TMPDIR+'/'+stripblanks(scs_m.props.title(1))+'_imSim.xml'
			XMLTMP=pathconvert(XMLTMP,%f,%t);
			if MSDOS then 
			  cmnd="del /F "+XML+" "+XMLTMP;
                          if execstr('unix_s(cmnd)','errcatch')<>0 then
			    %err_mess_eval=[%err_mess_eval;'Unable to delete the XML file'];
			  end
			else
			  cmnd="rm -f "+XML+" "+XMLTMP
                          if execstr('unix_s(cmnd)','errcatch')<>0 then
			    %err_mess_eval=[%err_mess_eval;'Unable to delete the XML file'];
			  end
			end
			break;
		      end
		    end
		  end
		end
	      end
	    end
	  else
	    if flag=='XML' then ok=%f;continue;end // return;end
	    if %f & ~isequal(ier,0) then
	      //%err_mess_eval=[%err_mess_eval;'Error in gui '+o.gui+': '+lasterror()]
	      printf("%s\n",['Error in gui '+o.gui';lasterror()])
	    end
	  end
	end
	if flag=='XML' then
	  o.graphics=graphics;
	end
      end
    end
    scs_m.objs(%kk)=o;
  end
  needcompile=needcompile1
  if needcompile==4 then cpr=list(),end
  if ~%SubSystemEval then
    // if %err_mess_eval<>[] then x_message(%err_mess_eval);ok=%f;end
    clearglobal %err_mess_eval;
    if exists('%win0_exists')&(~%win0_exists) then
      open_win=winsid();// to close the opened windows number 0 
      k=find(open_win==0); // it is openend when evaluating blocks as affiche.
      xdel(open_win(k));
    end
  end
endfunction

function model=update_model(model)
  tt="model=scicos_model(";
  xx=getfield(1,o.model)
  for i=2:size(xx,'*')-1
    tt=tt+xx(i)+"=model."+xx(i)+",";
  end
  tt=tt+xx(i+1)+"=model."+xx(i+1)+")";
  execstr(tt);
endfunction

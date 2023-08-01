function [ok,txt]=do_api_save(scs_m) 
// This function save a diagram in API mode 
  
  function txt=do_api_block(o,blk_num)
    // returns text for a spécific block
    // printf("In block api %s\n",o.gui);pause block;
    txt=sprintf('blk = instantiate_block (""%s"");',o.gui);

    expp=o.graphics.exprs;
    ne=size(expp,'*');
    if ne>0 then
      txt($+1)=sprintf('params = struct()');
      names= 'name'+string(1:ne);
      for i=1:ne 
        txt($+1)= 'params.' + names(i) + '= ' +sci2exp(expp(i))
      end
      txt($+1)= 'blk = set_block_parameters (blk, params);';
    end
    if type(o.graphics.gr_i)<>10  then
      cmap=get(sdf(),"color_map");
      if isempty(o.graphics.gr_i(2)) then 
        col=[1,1,1]
      else
        col=cmap( o.graphics.gr_i(2),:);
      end
    else
      col=[1,1,1]
    end
    txt($+1)=sprintf('blk = set_block_bg_color (blk, %s);',sci2exp(col));
    // txt($+1)=sprintf('blk = set_block_fg_color (blk, %s);';
    txt($+1)=sprintf('blk = set_block_nin (blk, %d);', size( o.graphics.pin,'*'));
    txt($+1)=sprintf('blk = set_block_nout (blk, %d);',size( o.graphics.pout,'*'));
    txt($+1)=sprintf('blk = set_block_evtnin (blk, %d);',size( o.graphics.pein,'*'));
    txt($+1)=sprintf('blk = set_block_evtnout (blk, %d);',size( o.graphics.peout,'*'));
    txt($+1)=sprintf('blk = set_block_flip (blk, %d);', bool2s(~o.graphics.flip));
    txt($+1)='blk = set_block_ident (blk,'+sci2exp(o.graphics.id)+')';
    txt($+1)=sprintf('blk = set_block_origin (blk, %s);',sci2exp(o.graphics.orig,0));
    txt($+1)=sprintf('blk = set_block_size (blk, %s);',sci2exp(o.graphics.sz,0));
    txt($+1)=sprintf('blk = set_block_theta (blk, %s);',sci2exp(o.graphics.theta));
    txt($+1)=sprintf('[scsm, block_tag_%d] = add_block (scsm, blk);',blk_num);
  endfunction
  
  function [txt,count]=do_api_model(scs_m,count)
    // returns text coding internal diagram of a super block.
    // and 
    // printf("In api model ");pause model
    count = count+1;
    cmap=get(sdf(),"color_map");    col=scs_m.props.options.Background(1);
    col=cmap( col,:);
    txt1=sprintf('function scsm=subsystem_%d () ',count);
    txt1($+1)= '  ' +sprintf('scsm = instantiate_diagram ();');
    context=scs_m.props.context
    if ~isempty(context) then
      txt1($+1)= '  '+sprintf('scsm = set_model_workspace(scsm,%s)',sci2exp(context,0))
    end
    txt1($+1)= '  '+sprintf('scsm = set_diagram_bg_color (scsm, %s);',sci2exp(col));
    txt1($+1)= '  '+sprintf('scsm = set_diagram_3d (scsm, %d);', bool2s(scs_m.props.options("3D")(1)));
    if length(scs_m.props.wpar) >= 13 then 
      txt1($+1)= '  '+sprintf('scsm = set_diagram_zoom (scsm, %f);',scs_m.props.wpar(13));
    else
      txt1($+1)= '  '+sprintf('scsm = set_diagram_zoom (scsm, 1);');
    end
    
    if size(scs_m.props.wpar,"*")>11 then
       sz=scs_m.props.wpar(9:10);pos=scs_m.props.wpar(11:12);loc=[pos,sz+pos]
    else
       sz=scs_m.props.wpar(1:2);pos=scs_m.props.wpar(5:6);loc=[pos,sz+pos]
    end
    txt1($+1)= '  ' +sprintf('scsm = set_diagram_location (scsm, %s);',sci2exp(loc,0));
    txt1($+1)= '   scsm = set_diagram_name (scsm,' +sci2exp(scs_m.props.title(1),0)+ ')';
    [blocks,head]= do_api_save_rec(scs_m,count);
    txt1=[txt1;'  '+blocks];
    txt1($+1) = 'endfunction';
    txt=[head;txt1];
  endfunction

  function txt=do_api_super_block(o,count,flag,blk_num)
    //
    // printf("In super block %s\n",o.gui);pause super
    txt = [];
    txt($+1)=sprintf('// New block %s ',o.gui);
    txt($+1)=sprintf('blk = instantiate_super_block ();');
    if flag then
      params = struct();
      val=o.graphics.exprs(1);
      expp=o.graphics.exprs(2)(1)
      ne=size(expp,'*');
      if ne>0 then
	txt($+1)=sprintf('params = struct()');
	names= 'name'+string(1:ne);
	for i=1:ne 
	  txt($+1)=sprintf('params.%s.value= '"%s'"',names(i),val(i));
	  txt($+1)=sprintf('params.%s.prompt= '"%s'"',names(i),expp(i));
	end
	txt($+1)= 'blk = set_block_parameters (blk, params);';
      end
    end
    context=scs_m.props.context
    if ~isempty(context) then
      txt($+1)= '  '+sprintf('scsm = set_model_workspace(scsm,%s)',sci2exp(context,0))
    end
    if type(o.graphics.gr_i)<>10 then
      cmap=get(sdf(),"color_map");
      if isempty(o.graphics.gr_i(2)) then 
	col=[1,1,1]
      else
	col=cmap( o.graphics.gr_i(2),:);
      end
    else
      col=[1,1,1]
    end
    txt($+1)=sprintf('blk = set_block_bg_color (blk, %s);',sci2exp(col));
    // txt($+1)=sprintf('blk = set_block_fg_color (blk, %s);',;
    txt($+1)=sprintf('blk = set_block_nin (blk, %d);',size( o.graphics.pin,'*'));
    txt($+1)=sprintf('blk = set_block_nout (blk, %d);',size( o.graphics.pout,'*'));
    txt($+1)=sprintf('blk = set_block_evtnin (blk, %d);',size( o.graphics.pein,'*'));
    txt($+1)=sprintf('blk = set_block_evtnout (blk, %d);',size( o.graphics.peout,'*'));
    txt($+1)=sprintf('blk = set_block_flip (blk, %d);', bool2s(~o.graphics.flip));
    txt($+1)='blk = set_block_ident (blk,'+sci2exp(o.graphics.id)+')';
    txt($+1)=sprintf('blk = set_block_origin (blk, %s);',sci2exp(o.graphics.orig,0));
    txt($+1)=sprintf('blk = set_block_size (blk, %s);',sci2exp(o.graphics.sz,0));
    txt($+1)=sprintf('blk = set_block_theta (blk, %s);',sci2exp(o.graphics.theta));
    txt($+1)=sprintf('tmp_diag = subsystem_%d ()',count);
    if flag then 
      txt($+1)= 'blk = set_block_mask (blk, params, ""?"");';
    end
    txt($+1)= 'blk = fill_super_block (blk, tmp_diag);';
    txt($+1)= sprintf('[scsm, block_tag_%d] = add_block (scsm, blk);',blk_num);
    
  endfunction
  
  function [txt,head]= do_api_save_rec(scs_m,count)
    // 
    txt=[]; head=[];
    ok = %t;
    
    for %kk=1:length(scs_m.objs)
      o=scs_m.objs(%kk)
      if typeof(o) =='Block' | typeof(o) =='Text' then
	if o.gui<>'PAL_f' then
	  // 
	  model=o.model
	  if ((model.sim(1)=='csuper'& model.ipar==1) | (o.gui == 'DSUPER' )) then
	    // 
	    [mtxt,count]=do_api_model(model.rpar,count)
	    head=[head;mtxt];
	    txt=[txt;do_api_super_block(o,count,%t,%kk)];
	  elseif (model.sim(1)=='csuper' | model.sim(1)=='super' |  o.model.sim(1)=='asuper')
	    // 
	    [mtxt,count]=do_api_model(model.rpar,count)
	    head=[head;mtxt];
	    txt=[txt;do_api_super_block(o,count,%f,%kk)];
	  else
	    // a standard block 
	    txt=[txt;do_api_block(o,%kk)];
	  end
	end
      end
    end
    for %kk=1:length(scs_m.objs)
      o=scs_m.objs(%kk)
      if typeof(o) =='Link' then
	bf=o.from(1);pf=o.from(2);
	bt=o.to(1);pt=o.to(2);
	xx=o.xx;yy=o.yy;nsz=size(xx,"*")
	sxx=xx(2:$)-xx(1:$-1);
	sxx=sxx(1:$-1)
	syy=yy(2:$)-yy(1:$-1);
	syy=syy(1:$-1)
	points=[sxx,syy]
	if o.ct(2)==1 then
	  txt($+1)=..
	  sprintf('[scsm,obj_num] = add_explicit_link (scsm, [block_tag_%d, ""%d""], [block_tag_%d, ""%d"" ],%s)',bf,pf,bt,pt,sci2exp(points,0));
	elseif o.ct(2)==-1 then
	  txt($+1)=..
	  sprintf('[scsm,obj_num] = add_event_link (scsm, [block_tag_%d, ""%d""], [block_tag_%d, ""%d""],%s)',bf,pf,bt,pt,sci2exp(points,0));
	else
	  warning('unsupported link type');pause
	end
      end
    end
  endfunction
  // ----------
  
  // main job 
  ok=%t;
  
  txt=do_api_model(scs_m,0);

  last=["if exists(""%nsp"") then function y=struct(); y=hash(10);endfunction;end";
	"scsm = subsystem_1();"; 
	"scsm = set_final_time (scsm, ""40"");";
	"tol = [ ""auto""; ""1e-3""; ""auto""; ""40""; ""0""; ""ode45""; ""auto"" ];";
	"scsm = set_solver_parameters (scsm, tol);";
	"scsm = evaluate_model (scsm);"];
  txt=[txt;last];
endfunction


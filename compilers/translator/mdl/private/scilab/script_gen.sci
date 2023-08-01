function txt = script_gen(scs_m)
    scs_m=cleanup(scs_m)
    scs_m=do_purge(scs_m)
    txt=create_sub(scs_m)

    txt=["txt($+1)=ID+"+"""%blk=instantiate_block(""""SUPER_f"""")"""
         "txt($+1)=ID+"+ """%blk.graphics.gr_i(1)="""" """"""" 
         txt
         "txt($+1)=ID+"+"""%blk=fill_superblock(%blk,scsm0)""" ]
endfunction

function scs_m=cleanup(scs_m)
// in scs_m a block may come after a link connecting it
// we place such links at the end
  norig=lstsize(scs_m.objs)
  for i=1:norig
    o=scs_m.objs(i)
    if typeof(o)=='Link' then
      if o.from(1)>i | o.to(1)>i then
        n=lstsize(scs_m.objs)
        scs_m.objs(n+1)=o  //link info inside the blocks is now 
        scs_m.objs(i)=mlist('Deleted')
        if o.ct(2)>0 then
           scs_m.objs(o.from(1)).graphics.pout(o.from(2))=n+1
           scs_m.objs(o.to(1)).graphics.pin(o.to(2))=n+1
        else
           scs_m.objs(o.from(1)).graphics.peout(o.from(2))=n+1
           scs_m.objs(o.to(1)).graphics.pein(o.to(2))=n+1
        end
      end
    elseif typeof(o)=='Block' &(o.model.sim=='super'| o.model.sim=='csuper'| o.model.sim(1)=='asuper') then
       scs_m.objs(i).model.rpar=cleanup(o.model.rpar)
    end
  end
endfunction

function [txt,inde]=create_sub(scs_m)
  global %ind
  %ind=%ind+1
  inde=%ind
  ID="    "  // Indentation
//X   txt="function scs_m=%subsystem_"+string(%ind)+"()"
  txt($+1)="txt($+1)=ID+"+sci2exp("scsm"+string(inde)+"=instantiate_diagram()")
  txt($+1)="txt($+1)=ID+"+sci2exp("scsm"+string(inde)+"=set_diag_bkgcolor(scsm"+string(inde)+","+string(scs_m.props.options.Background(1))+")",0)
//X  txt($+1)="txt($+1)=ID+"+sci2exp("scsm"+string(inde)+" = set_diag_3D(scsm"+string(inde)+","+sci2exp(scs_m.props.options("3D"))+")",0)
  if size(scs_m.props.wpar,"*")>12 then
    %zoom=scs_m.props.wpar(13)
    sz=scs_m.props.wpar(9:10)
    pos=scs_m.props.wpar(11:12)
    loc = [pos,sz+pos]
    txt($+1)="txt($+1)=ID+"+sci2exp("scsm"+string(inde)+" = set_diagram_location(scsm"+string(inde)+","+sci2exp(loc)+","+string(%zoom)+")",0)
  end
//X  txt($+1)="txt($+1)=ID+"+sci2exp("scsm"+string(inde)+" = set_model_name(scsm"+string(inde)+","+sci2exp(scs_m.props.title)+")",0)
//X  txt($+1)="txt($+1)=ID+"+sci2exp("scsm"+string(inde)+" = set_solver_parameters(scsm"+string(inde)+","+sci2exp(scs_m.props.tol)+")",0)
//X  txt($+1)="txt($+1)=ID+"+sci2exp("scsm"+string(inde)+" = set_final_time(scsm"+string(inde)+","+string(scs_m.props.tf)+")",0)
  txt($+1)="txt($+1)=ID+"+sci2exp("%context=..",0)
  txt=[txt;"txt($+1)=ID+"+sci2exp(sci2exp(scs_m.props.context,0),0)]
  txt($+1)="txt($+1)=ID+"+sci2exp("scsm"+string(inde)+" = set_diagram_context(scsm"+string(inde)+",%context)",0)
  for k=1:lstsize(scs_m.objs)
    o=scs_m.objs(k)
    if typeof(o)=='Block' then
       txt($+1)="txt($+1)=ID+"+sci2exp("%blk"+string(inde)+"=instantiate_block('""+o.gui+"'")",0)
       if type(o.graphics.gr_i)==15 then
         txt($+1)="txt($+1)=ID+"+sci2exp("%blk"+string(inde)+"=set_block_bkgcolor(%blk"+string(inde)+","+sci2exp(o.graphics.gr_i(2))+")",0)
       end

       txt($+1)="txt($+1)=ID+"+sci2exp("%blk"+string(inde)+"=set_block_flip(%blk"+string(inde)+","+sci2exp(o.graphics.flip)+")",0)
       txt($+1)="txt($+1)=ID+"+sci2exp("%blk"+string(inde)+"=set_block_ident(%blk"+string(inde)+","'"+o.graphics.id+"'")",0)
       txt($+1)="txt($+1)=ID+"+sci2exp("%blk"+string(inde)+"=set_block_orig(%blk"+string(inde)+","+sci2exp(o.graphics.orig)+")",0)
       txt($+1)="txt($+1)=ID+"+sci2exp("%blk"+string(inde)+"=set_block_sz(%blk"+string(inde)+","+sci2exp(o.graphics.sz)+")",0)
       txt($+1)="txt($+1)=ID+"+sci2exp("%blk"+string(inde)+"=set_block_theta(%blk"+string(inde)+","+sci2exp(o.graphics.theta)+")",0)
       txt($+1)="txt($+1)=ID+"+sci2exp("%exprs=..",0)
       txt=[txt;"txt($+1)=ID+"+sci2exp(sci2exp(o.graphics.exprs,0),0)]
       txt($+1)="txt($+1)=ID+"+sci2exp("%blk"+string(inde)+"=set_block_parameters(%blk"+string(inde)+",%exprs)",0)

//X       if o.model.sim=='super'| o.model.sim=='csuper'| o.model.sim(1)=='asuper' then
       if o.model.sim=='super' then
         [txt1,inde1]=create_sub(o.model.rpar)
         txt=[txt;txt1]
         txt($+1)="txt($+1)=ID+"+sci2exp("%blk"+string(inde)+"=fill_superblock(%blk"+string(inde)+",scsm"+string(inde1)+")",0)

         txt($+1)="txt($+1)=ID+"+sci2exp("%blk"+string(inde)+"=set_block_evtnin(%blk"+string(inde)+","+string(size(o.graphics.pein,"*"))+")",0)
         txt($+1)="txt($+1)=ID+"+sci2exp("%blk"+string(inde)+"=set_block_evtnout(%blk"+string(inde)+","+string(size(o.graphics.peout,"*"))+")",0)
         if ~isempty(find(o.graphics.in_implicit=="I")) then
           txt($+1)="txt($+1)=ID+"+sci2exp("%blk"+string(inde)+"=set_block_nin(%blk"+string(inde)+","+string(size(o.graphics.pin,"*"))+","+sci2exp(o.graphics.in_implicit)+")")
         else       
           txt($+1)="txt($+1)=ID+"+sci2exp("%blk"+string(inde)+"=set_block_nin(%blk"+string(inde)+","+string(size(o.graphics.pin,"*"))+")")
         end
         if ~isempty(find(o.graphics.out_implicit=="I")) then
           txt($+1)="txt($+1)=ID+"+sci2exp("%blk"+string(inde)+"=set_block_nout(%blk"+string(inde)+","+string(size(o.graphics.pout,"*"))+","+sci2exp(o.graphics.out_implicit)+")")
         else
           txt($+1)="txt($+1)=ID+"+sci2exp("%blk"+string(inde)+"=set_block_nout(%blk"+string(inde)+","+string(size(o.graphics.pout,"*"))+")")
         end

       end
       txt($+1)="txt($+1)=ID+"+sci2exp("[scsm"+string(inde)+",%l] = add_block(scsm"+string(inde)+",%blk"+string(inde)+")",0)
//X       txt($+1)="txt($+1)=ID+"+sci2exp("if ~isequal(%l,"+string(k)+") then pause,end",0)
    elseif typeof(o)=='Link' then
       from=[o.from(1),o.from(2)]
       to=[o.to(1),o.to(2)]
       if o.ct(2)==1 | o.ct(2)==3 then
          txt($+1)="txt($+1)=ID+"+sci2exp("scsm"+string(inde)+" = add_explicit_link(scsm"+string(inde)+","+sci2exp(from)+","+sci2exp(to)+",[])",0)
       elseif o.ct(2)==-1  then
          txt($+1)="txt($+1)=ID+"+sci2exp("scsm"+string(inde)+" = add_event_link(scsm"+string(inde)+","+sci2exp(from)+","+sci2exp(to)+",[])",0)
       elseif o.ct(2)==2 then
          from(3)=o.from(3)
          to(3)=o.to(3)
          txt($+1)="txt($+1)=ID+"+sci2exp("scsm"+string(inde)+" = add_implicit_link(scsm"+string(inde)+","+sci2exp(from)+","+sci2exp(to)+",[])",0)
       else
          error('unknown link type: '+string(ct(2)))
       end
    elseif typeof(o)=='Text' then
       txt($+1)="txt($+1)=ID+"+sci2exp("%blk"+string(inde)+"=instantiate_block('""+o.gui+"'")",0)
       txt($+1)="txt($+1)=ID+"+sci2exp("%blk"+string(inde)+"=set_block_orig(%blk"+string(inde)+","+sci2exp(o.graphics.orig)+")",0)
       txt($+1)="txt($+1)=ID+"+sci2exp("%blk"+string(inde)+"=set_block_sz(%blk"+string(inde)+","+sci2exp(o.graphics.sz)+")",0)
       txt($+1)="txt($+1)=ID+"+sci2exp("%blk"+string(inde)+"=set_block_theta(%blk"+string(inde)+","+sci2exp(o.graphics.theta)+")",0)
       txt($+1)="txt($+1)=ID+"+sci2exp("%exprs=..",0)
       txt=[txt;"txt($+1)=ID+"+sci2exp(sci2exp(o.graphics.exprs,0),0)]
       txt($+1)="txt($+1)=ID+"+sci2exp("%blk"+string(inde)+"=set_block_parameters(%blk"+string(inde)+",%exprs)",0)
       txt($+1)="txt($+1)=ID+"+sci2exp("[scsm"+string(inde)+",%l] = add_block(scsm"+string(inde)+",%blk"+string(inde)+")",0)
//X       txt($+1)="txt($+1)=ID+"+sci2exp("if ~isequal(%l,"+string(k)+") then pause,end",0)

    else
       txt($+1)="txt($+1)=ID+"+sci2exp("%blk"+string(inde)+"=mlist('"Deleted'")",0)
       txt($+1)="txt($+1)=ID+"+sci2exp("[scsm"+string(inde)+",%l] = add_block(scsm"+string(inde)+",%blk"+string(inde)+")",0)
    end
  end
//X  txt($+1)="endfunction"
  txt($+1)="   "
endfunction

function fnamec=translate(mcos)
    load(mcos)
    load("SCI/macros/scicos/lib")
    exec(loadpallibs, 1)
    options=default_options()
    getd("c:/cygwin/home/ramin/MDL/scilab/")
    global %ind
    %ind=-1
    txt=script_gen(scs_m)
    [path,fname,extension]=fileparts(mcos)
    fnamec=fname+".sci"
    host("del "+fnamec)
    write(fnamec,txt,'(a)')    
endfunction

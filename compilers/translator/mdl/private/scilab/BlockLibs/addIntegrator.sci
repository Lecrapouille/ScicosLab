function txt=addIntegrator(txt,para,nin,nout)

    if para.LimitOutput==off then sat="0", else sat="1",end
    maxp=para.UpperSaturationLimit
    minp=para.LowerSaturationLimit
    x0=para.InitialCondition
  if para.ExternalReset=="none" & para.InitialConditionSource=="internal" then  
    txt($+1)=ID+"%blk=instantiate_block('"INTEGRAL_m'")"
    txt($+1)=ID+'%exprs='+sci2exp([x0;"0";sat;maxp;minp],0)
    txt($+1)=ID+"%blk=set_block_parameters(%blk,%exprs)"
  elseif para.ExternalReset=="none" & para.InitialConditionSource=="external" then  

txt($+1)=ID+"%blk=instantiate_block(""SUPER_f"")"
txt($+1)=ID+"%blk.graphics.gr_i(1)="" """
txt($+1)=ID+"scsm0=instantiate_diagram()"
txt($+1)=ID+"scsm0=set_diag_bkgcolor(scsm0,8)"
txt($+1)=ID+"scsm0 = set_diagram_location(scsm0,[423,142,1053,572],1.4)"

txt($+1)=ID+"%blk0=instantiate_block(""IN_f"")"
txt($+1)=ID+"%blk0=set_block_bkgcolor(%blk0,8)"
txt($+1)=ID+"%blk0=set_block_flip(%blk0,%t)"
txt($+1)=ID+"%blk0=set_block_ident(%blk0,''"")"
txt($+1)=ID+"%blk0=set_block_orig(%blk0,[157.704,247.07733])"
txt($+1)=ID+"%blk0=set_block_sz(%blk0,[20,20])"
txt($+1)=ID+"%blk0=set_block_theta(%blk0,0)"
txt($+1)=ID+"%exprs=.."
txt($+1)=ID+"[""1"";""-1"";""-1""]"
txt($+1)=ID+"%blk0=set_block_parameters(%blk0,%exprs)"
txt($+1)=ID+"[scsm0,%l] = add_block(scsm0,%blk0)"
txt($+1)=ID+"%blk0=instantiate_block(""OUT_f"")"
txt($+1)=ID+"%blk0=set_block_bkgcolor(%blk0,8)"
txt($+1)=ID+"%blk0=set_block_flip(%blk0,%t)"
txt($+1)=ID+"%blk0=set_block_ident(%blk0,''"")"
txt($+1)=ID+"%blk0=set_block_orig(%blk0,[374.03733,207.944])"
txt($+1)=ID+"%blk0=set_block_sz(%blk0,[20,20])"
txt($+1)=ID+"%blk0=set_block_theta(%blk0,0)"
txt($+1)=ID+"%exprs=.."
txt($+1)=ID+"""1"""
txt($+1)=ID+"%blk0=set_block_parameters(%blk0,%exprs)"
txt($+1)=ID+"[scsm0,%l] = add_block(scsm0,%blk0)"
txt($+1)=ID+"%blk0=instantiate_block(""INTEGRAL_m"")"

txt($+1)=ID+"%blk0=set_block_nin(%blk0,"+string(2)+")"
txt($+1)=ID+"%blk0=set_block_evtnin(%blk0,"+string(1)+")"

txt($+1)=ID+"%blk0=set_block_bkgcolor(%blk0,8)"
txt($+1)=ID+"%blk0=set_block_flip(%blk0,%t)"
txt($+1)=ID+"%blk0=set_block_ident(%blk0,''"")"
txt($+1)=ID+"%blk0=set_block_orig(%blk0,[280.904,197.944])"
txt($+1)=ID+"%blk0=set_block_sz(%blk0,[40,40])"
txt($+1)=ID+"%blk0=set_block_theta(%blk0,0)"
txt($+1)=ID+"%exprs=.."
txt($+1)=ID+sci2exp([x0;"1";sat;maxp;minp],0)
txt($+1)=ID+"%blk0=set_block_parameters(%blk0,%exprs)"
txt($+1)=ID+"[scsm0,%l] = add_block(scsm0,%blk0)"
txt($+1)=ID+"%blk0=instantiate_block(""IN_f"")"
txt($+1)=ID+"%blk0=set_block_bkgcolor(%blk0,8)"
txt($+1)=ID+"%blk0=set_block_flip(%blk0,%t)"
txt($+1)=ID+"%blk0=set_block_ident(%blk0,''"")"
txt($+1)=ID+"%blk0=set_block_orig(%blk0,[155.504,182.544])"
txt($+1)=ID+"%blk0=set_block_sz(%blk0,[20,20])"
txt($+1)=ID+"%blk0=set_block_theta(%blk0,0)"
txt($+1)=ID+"%exprs=.."
txt($+1)=ID+"[""2"";""-1"";""-1""]"
txt($+1)=ID+"%blk0=set_block_parameters(%blk0,%exprs)"
txt($+1)=ID+"[scsm0,%l] = add_block(scsm0,%blk0)"
txt($+1)=ID+"scsm0 = add_explicit_link(scsm0,[4,1],[3,2],[])"
txt($+1)=ID+"scsm0 = add_explicit_link(scsm0,[3,1],[2,1],[])"
txt($+1)=ID+"scsm0 = add_explicit_link(scsm0,[1,1],[3,1],[])"
txt($+1)=ID+"%blk0=instantiate_block(""EVTGEN_f"")"
txt($+1)=ID+"%blk0=set_block_bkgcolor(%blk0,8)"
txt($+1)=ID+"%blk0=set_block_flip(%blk0,%t)"
txt($+1)=ID+"%blk0=set_block_ident(%blk0,''"")"
txt($+1)=ID+"%blk0=set_block_orig(%blk0,[280.904,299.144])"
txt($+1)=ID+"%blk0=set_block_sz(%blk0,[40,40])"
txt($+1)=ID+"%blk0=set_block_theta(%blk0,0)"
txt($+1)=ID+"%exprs=.."
txt($+1)=ID+"""0"""
txt($+1)=ID+"%blk0=set_block_parameters(%blk0,%exprs)"
txt($+1)=ID+"[scsm0,%l] = add_block(scsm0,%blk0)"
txt($+1)=ID+"scsm0 = add_event_link(scsm0,[8,1],[3,1],[])"
   
txt($+1)=ID+"%blk=fill_superblock(%blk,scsm0)"

  else
    warning('This configuration of Integrator not supported yet.'),
    txt($+1)=ID+"%blk=instantiate_block('"SUPER_f'")"
    txt($+1)=ID+"%blk.graphics.gr_i(1)='" '""
    diagName="Integrator"

   context='//   Integrator'
   paras=getfield(1,para)
   np=size(paras,"*")-2
   for ii=1:np
       context(ii+1)=paras(2+ii)+"="+sci2exp(para(paras(2+ii)),0)
   end

   txt=create_empty_scsm1(txt,nin,nout,context,diagName)
   txt($+1)=ID+"%blk=fill_superblock(%blk,scsm1)"

  end
endfunction


//  elseif para.ExternalReset=="rising" & para.InitialConditionSource=="internal" then
//    txt($+1)=ID+"%blk=instantiate_block('"SUPER_f'")"
//    txt($+1)=ID+"%blk.graphics.gr_i(1)='" '""
////
////    txt($+1)=ID+"scsm1= set_diagram_location(scs_m,[407,151,1037,581],1.4)"
////    txt($+1)=ID+"%blk1=instantiate_block('"INTEGRAL_m'")"
////    txt($+1)=ID+"%blk1=set_block_orig(%blk,[306,202])"
////    txt($+1)=ID+"%blk1=set_block_sz(%blk,[40,40])"
////    txt($+1)=ID+'%exprs='+sci2exp([x0;"0";sat;maxp;minp],0)
////    txt($+1)=ID+'%blk1=set_block_parameters(%blk,%exprs)'
////    txt($+1)=ID+'[scs_m1,%l] = add_block(scs_m1,%blk1)'
////
////    txt($+1)=ID+"%blk1=instantiate_block('"Extract_Activation'")"
////    txt($+1)=ID+"%blk1=set_block_orig(%blk1,[296,285])"
////    txt($+1)=ID+"%blk1=set_block_sz(%blk1,[60,40])"
////    %exprs=..
////    []
////    %blk=set_block_parameters(%blk,%exprs)
////    [scs_m,%l] = add_block(scs_m,%blk)
////    if ~isequal(%l,2) then pause,end
////    scs_m = add_event_link(scs_m,[2,1],[1,1],[])
////    %blk=instantiate_block("CONST_m")
////    %blk=set_block_bkgcolor(%blk,8)
////    %blk=set_block_evtnin(%blk,0)
////    %blk=set_block_evtnout(%blk,0)
////    %blk=set_block_nin(%blk,0)
////    %blk=set_block_nout(%blk,1)
////    %blk=set_block_flip(%blk,%t)
////    %blk=set_block_ident(%blk,'")
////    %blk=set_block_orig(%blk,[196.57067,164.944])
////    %blk=set_block_sz(%blk,[40,40])
////    %blk=set_block_theta(%blk,0)
////    %exprs=..
////    "1"
////    %blk=set_block_parameters(%blk,%exprs)
////    [scs_m,%l] = add_block(scs_m,%blk)
////    if ~isequal(%l,4) then pause,end
////    scs_m = add_explicit_link(scs_m,[4,1],[1,2],[])
////    %blk=instantiate_block("IN_f")
////    %blk=set_block_bkgcolor(%blk,8)
////    %blk=set_block_evtnin(%blk,0)
////    %blk=set_block_evtnout(%blk,0)
////    %blk=set_block_nin(%blk,0)
////    %blk=set_block_nout(%blk,1)
////    %blk=set_block_flip(%blk,%t)
////    %blk=set_block_ident(%blk,'")
////    %blk=set_block_orig(%blk,[176.03733,295.21067])
////    %blk=set_block_sz(%blk,[20,20])
////    %blk=set_block_theta(%blk,0)
////    %exprs=..
////    ["2";"-1";"-1"]
////    %blk=set_block_parameters(%blk,%exprs)
////    [scs_m,%l] = add_block(scs_m,%blk)
////    if ~isequal(%l,6) then pause,end
////    %blk=instantiate_block("IN_f")
////    %blk=set_block_bkgcolor(%blk,8)
////    %blk=set_block_evtnin(%blk,0)
////    %blk=set_block_evtnout(%blk,0)
////    %blk=set_block_nin(%blk,0)
////    %blk=set_block_nout(%blk,1)
////    %blk=set_block_flip(%blk,%t)
////    %blk=set_block_ident(%blk,'")
////    %blk=set_block_orig(%blk,[171.63733,219.01067])
////    %blk=set_block_sz(%blk,[20,20])
////    %blk=set_block_theta(%blk,0)
////    %exprs=..
////    ["1";"-1";"-1"]
////    %blk=set_block_parameters(%blk,%exprs)
////    [scs_m,%l] = add_block(scs_m,%blk)
////    if ~isequal(%l,7) then pause,end
////    scs_m = add_explicit_link(scs_m,[6,1],[2,1],[])
////    scs_m = add_explicit_link(scs_m,[7,1],[1,1],[])
////    %blk=instantiate_block("OUT_f")
////    %blk=set_block_bkgcolor(%blk,8)
////    %blk=set_block_evtnin(%blk,0)
////    %blk=set_block_evtnout(%blk,0)
////    %blk=set_block_nin(%blk,1)
////    %blk=set_block_nout(%blk,0)
////    %blk=set_block_flip(%blk,%t)
////    %blk=set_block_ident(%blk,'")
////    %blk=set_block_orig(%blk,[394.57067,212.344])
////    %blk=set_block_sz(%blk,[20,20])
////    %blk=set_block_theta(%blk,0)
////    %exprs=..
////    "1"
////    %blk=set_block_parameters(%blk,%exprs)
////    [scs_m,%l] = add_block(scs_m,%blk)
////    if ~isequal(%l,10) then pause,end
////    scs_m = add_explicit_link(scs_m,[1,1],[10,1],[])
////
////
////endfunction
////

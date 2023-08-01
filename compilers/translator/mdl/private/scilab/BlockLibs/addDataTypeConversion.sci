function txt=addDataTypeConversion(txt,para,nin,nout)
   OutMin=	para.OutMin  // not supported
   OutMax=	para.OutMax // not supported
   OutDataTypeStr=	para.OutDataTypeStr 
   LockScale=	para.LockScale // not supported
   ConvertRealWorld=	para.ConvertRealWorld // not supported
   RndMeth=	para.RndMeth // not supported
   satur=	para("SaturateOnIntegerOverflow")
   SampleTime=	para.SampleTime

   if isequal(part(OutDataTypeStr,1:7),'Inherit') then
     dtype=-1
   elseif OutDataTypeStr=='double' then
     dtype=1
    elseif OutDataTypeStr=='single' then
     dtype=1
     warning('Switch block: single type not supported, double used.')
   elseif OutDataTypeStr=='int8' then
     dtype=5
   elseif OutDataTypeStr=='uint8' then
     dtype=8
   elseif OutDataTypeStr=='int16' then
     dtype=4
   elseif OutDataTypeStr=='uint16' then
     dtype=7
   elseif OutDataTypeStr=='int32' then
     dtype=3
   elseif OutDataTypeStr=='uint32' then
     dtype=6
   elseif OutDataTypeStr=='boolean' then
     dtype=9
   else
     warning('Switch block: unsupported type, double used.')
     dtype=1
   end


   if isequal(SampleTime,"-1") then
      txt($+1)=ID+"%blk=instantiate_block('"CONVERT'")"
      txt($+1)=ID+'%exprs='+sci2exp(["-1";string(dtype);string(satur)],0)
      txt($+1)=ID+"%blk=set_block_parameters(%blk,%exprs)"
   else
      txt($+1)=ID+"%blk=instantiate_block(""SUPER_f"")"
      txt($+1)=ID+"%blk.graphics.gr_i(1)="" """
      txt($+1)=ID+"scsm0=instantiate_diagram()"
      txt($+1)=ID+"scsm0=set_diag_bkgcolor(scsm0,8)"
      txt($+1)=ID+"scsm0 = set_diagram_location(scsm0,[425,93,1055,573],1.4)"
      txt($+1)=ID+"%context=.."
      txt($+1)=ID+""" """
      txt($+1)=ID+"scsm0 = set_diagram_context(scsm0,%context)"
      txt($+1)=ID+"%blk0=instantiate_block(""IN_f"")"
      txt($+1)=ID+"%blk0=set_block_bkgcolor(%blk0,8)"
      txt($+1)=ID+"%blk0=set_block_flip(%blk0,%t)"
      txt($+1)=ID+"%blk0=set_block_ident(%blk0,''"")"
      txt($+1)=ID+"%blk0=set_block_orig(%blk0,[186.22133,220.21691])"
      txt($+1)=ID+"%blk0=set_block_sz(%blk0,[20,20])"
      txt($+1)=ID+"%blk0=set_block_theta(%blk0,0)"
      txt($+1)=ID+"%exprs=.."
      txt($+1)=ID+"[""1"";""-1"";""-1""]"
      txt($+1)=ID+"%blk0=set_block_parameters(%blk0,%exprs)"
      txt($+1)=ID+"[scsm0,%l] = add_block(scsm0,%blk0)"
      txt($+1)=ID+"%blk0=instantiate_block(""SAMPHOLD_m"")"
      txt($+1)=ID+"%blk0=set_block_bkgcolor(%blk0,8)"
      txt($+1)=ID+"%blk0=set_block_flip(%blk0,%t)"
      txt($+1)=ID+"%blk0=set_block_ident(%blk0,''"")"
      txt($+1)=ID+"%blk0=set_block_orig(%blk0,[254.42133,210.21691])"
      txt($+1)=ID+"%blk0=set_block_sz(%blk0,[40,40])"
      txt($+1)=ID+"%blk0=set_block_theta(%blk0,0)"
      txt($+1)=ID+"%exprs=.."
      txt($+1)=ID+"""-1"""
      txt($+1)=ID+"%blk0=set_block_parameters(%blk0,%exprs)"
      txt($+1)=ID+"[scsm0,%l] = add_block(scsm0,%blk0)"
      txt($+1)=ID+"%blk0=instantiate_block(""SampleCLK"")"
      txt($+1)=ID+"%blk0=set_block_bkgcolor(%blk0,8)"
      txt($+1)=ID+"%blk0=set_block_flip(%blk0,%t)"
      txt($+1)=ID+"%blk0=set_block_ident(%blk0,''"")"
      txt($+1)=ID+"%blk0=set_block_orig(%blk0,[244.42133,299.42509])"
      txt($+1)=ID+"%blk0=set_block_sz(%blk0,[60,40])"
      txt($+1)=ID+"%blk0=set_block_theta(%blk0,0)"
      txt($+1)=ID+"%exprs=.."
      txt($+1)=ID+sci2exp([SampleTime;"0"],0)
      txt($+1)=ID+"%blk0=set_block_parameters(%blk0,%exprs)"
      txt($+1)=ID+"[scsm0,%l] = add_block(scsm0,%blk0)"
      txt($+1)=ID+"%blk0=instantiate_block(""CONVERT"")"
      txt($+1)=ID+"%blk0=set_block_bkgcolor(%blk0,8)"
      txt($+1)=ID+"%blk0=set_block_flip(%blk0,%t)"
      txt($+1)=ID+"%blk0=set_block_ident(%blk0,''"")"
      txt($+1)=ID+"%blk0=set_block_orig(%blk0,[343.15467,210.21691])"
      txt($+1)=ID+"%blk0=set_block_sz(%blk0,[60,40])"
      txt($+1)=ID+"%blk0=set_block_theta(%blk0,0)"
      txt($+1)=ID+"%exprs=.."
      txt($+1)=ID+sci2exp(["-1";string(dtype);string(satur)],0)
      txt($+1)=ID+"%blk0=set_block_parameters(%blk0,%exprs)"
      txt($+1)=ID+"[scsm0,%l] = add_block(scsm0,%blk0)"
      txt($+1)=ID+"%blk0=instantiate_block(""OUT_f"")"
      txt($+1)=ID+"%blk0=set_block_bkgcolor(%blk0,8)"
      txt($+1)=ID+"%blk0=set_block_flip(%blk0,%t)"
      txt($+1)=ID+"%blk0=set_block_ident(%blk0,''"")"
      txt($+1)=ID+"%blk0=set_block_orig(%blk0,[474.42133,220.21691])"
      txt($+1)=ID+"%blk0=set_block_sz(%blk0,[20,20])"
      txt($+1)=ID+"%blk0=set_block_theta(%blk0,0)"
      txt($+1)=ID+"%exprs=.."
      txt($+1)=ID+"""1"""
      txt($+1)=ID+"%blk0=set_block_parameters(%blk0,%exprs)"
      txt($+1)=ID+"[scsm0,%l] = add_block(scsm0,%blk0)"
      txt($+1)=ID+"scsm0 = add_explicit_link(scsm0,[1,1],[2,1],[])"
      txt($+1)=ID+"scsm0 = add_explicit_link(scsm0,[2,1],[4,1],[])"
      txt($+1)=ID+"scsm0 = add_explicit_link(scsm0,[4,1],[5,1],[])"
      txt($+1)=ID+"scsm0 = add_event_link(scsm0,[3,1],[2,1],[])"
         
      txt($+1)=ID+"%blk=fill_superblock(%blk,scsm0)"
   end


endfunction

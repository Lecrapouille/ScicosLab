function txt=addAbs(txt,para,nin,nout)
	OutDataTypeStr=para.OutDataTypeStr
	ZeroCross=para.ZeroCross
	SampleTime=para.SampleTime


       if isequal(part(OutDataTypeStr,1:7),'Inherit') then
         dtype=-1
       elseif OutDataTypeStr=='double' then
         dtype=1
        elseif OutDataTypeStr=='single' then
         dtype=1
         warning('Abs block: single type not supported, double used.')
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
       else
         warning('Abs block: unsupported type.')
         dtype=1
       end


  [st,ierr]=evstr(SampleTime)
 if ierr>0 | st>0 then
   txt($+1)=ID+"%blk=instantiate_block(""SUPER_f"")"
   txt($+1)=ID+"%blk.graphics.gr_i(1)="" """
   txt($+1)=ID+"scsm0=instantiate_diagram()"
   txt($+1)=ID+"scsm0=set_diag_bkgcolor(scsm0,8)"
   txt($+1)=ID+"scsm0 = set_diagram_location(scsm0,[428,124,1058,554],1.4)"
   txt($+1)=ID+"%context=.."
   txt($+1)=ID+""" """
   txt($+1)=ID+"scsm0 = set_diagram_context(scsm0,%context)"
   txt($+1)=ID+"%blk0=instantiate_block(""IN_f"")"
   txt($+1)=ID+"%blk0=set_block_bkgcolor(%blk0,8)"
   txt($+1)=ID+"%blk0=set_block_flip(%blk0,%t)"
   txt($+1)=ID+"%blk0=set_block_ident(%blk0,''"")"
   txt($+1)=ID+"%blk0=set_block_orig(%blk0,[184.83733,219.21067])"
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
   txt($+1)=ID+"%blk0=set_block_orig(%blk0,[453.23733,219.21067])"
   txt($+1)=ID+"%blk0=set_block_sz(%blk0,[20,20])"
   txt($+1)=ID+"%blk0=set_block_theta(%blk0,0)"
   txt($+1)=ID+"%exprs=.."
   txt($+1)=ID+"""1"""
   txt($+1)=ID+"%blk0=set_block_parameters(%blk0,%exprs)"
   txt($+1)=ID+"[scsm0,%l] = add_block(scsm0,%blk0)"
   txt($+1)=ID+"%blk0=instantiate_block(""SAMPHOLD_m"")"
   txt($+1)=ID+"%blk0=set_block_bkgcolor(%blk0,8)"
   txt($+1)=ID+"%blk0=set_block_flip(%blk0,%t)"
   txt($+1)=ID+"%blk0=set_block_ident(%blk0,''"")"
   txt($+1)=ID+"%blk0=set_block_orig(%blk0,[262.57067,209.21067])"
   txt($+1)=ID+"%blk0=set_block_sz(%blk0,[40,40])"
   txt($+1)=ID+"%blk0=set_block_theta(%blk0,0)"
   txt($+1)=ID+"%exprs=.."
   txt($+1)=ID+sci2exp(string(dtype))
   txt($+1)=ID+"%blk0=set_block_parameters(%blk0,%exprs)"
   txt($+1)=ID+"[scsm0,%l] = add_block(scsm0,%blk0)"
   txt($+1)=ID+"%blk0=instantiate_block(""ABS_VALUEi"")"
   txt($+1)=ID+"%blk0=set_block_bkgcolor(%blk0,8)"
   txt($+1)=ID+"%blk0=set_block_flip(%blk0,%t)"
   txt($+1)=ID+"%blk0=set_block_ident(%blk0,''"")"
   txt($+1)=ID+"%blk0=set_block_orig(%blk0,[357.17067,209.21067])"
   txt($+1)=ID+"%blk0=set_block_sz(%blk0,[40,40])"
   txt($+1)=ID+"%blk0=set_block_theta(%blk0,0)"
   txt($+1)=ID+"%exprs=.."
   txt($+1)=ID+sci2exp([sci2exp(ZeroCross)],0)
   txt($+1)=ID+"%blk0=set_block_parameters(%blk0,%exprs)"
   txt($+1)=ID+"[scsm0,%l] = add_block(scsm0,%blk0)"
   txt($+1)=ID+"scsm0 = add_explicit_link(scsm0,[1,1],[3,1],[])"
   txt($+1)=ID+"scsm0 = add_explicit_link(scsm0,[3,1],[4,1],[])"
   txt($+1)=ID+"scsm0 = add_explicit_link(scsm0,[4,1],[2,1],[])"
   txt($+1)=ID+"%blk0=instantiate_block(""SampleCLK"")"
   txt($+1)=ID+"%blk0=set_block_bkgcolor(%blk0,8)"
   txt($+1)=ID+"%blk0=set_block_flip(%blk0,%t)"
   txt($+1)=ID+"%blk0=set_block_ident(%blk0,''"")"
   txt($+1)=ID+"%blk0=set_block_orig(%blk0,[252.57067,301.344])"
   txt($+1)=ID+"%blk0=set_block_sz(%blk0,[60,40])"
   txt($+1)=ID+"%blk0=set_block_theta(%blk0,0)"
   txt($+1)=ID+"%exprs=.."
   txt($+1)=ID++sci2exp([SampleTime;"0"],0)
   txt($+1)=ID+"%blk0=set_block_parameters(%blk0,%exprs)"
   txt($+1)=ID+"[scsm0,%l] = add_block(scsm0,%blk0)"
   txt($+1)=ID+"scsm0 = add_event_link(scsm0,[8,1],[3,1],[])"
      
   txt($+1)=ID+"%blk=fill_superblock(%blk,scsm0)"

  
 else
   txt($+1)=ID+"%blk=instantiate_block('"ABS_VALUEi'")"
   txt($+1)=ID+"%blk=set_block_parameters(%blk,"+..
      sci2exp([sci2exp(ZeroCross)],0)+")"
 end

endfunction

function txt=addToWorkspace(txt,para,nin,nout)

      if para.Decimation~="1" then
         warning("Decimation in display not supported.")
      end

      SampleTime=para.SampleTime

     if para.MaxDataPoints=="%inf" then
         mdat="10000"
     else
         mdat=para.MaxDataPoints
     end

     vname=para.VariableName

[st,ierr]=evstr(SampleTime)
if ierr>0 | st>0 then
  txt($+1)=ID+"%blk=instantiate_block(""SUPER_f"")"
   txt($+1)=ID+"%blk.graphics.gr_i(1)="" """
   txt($+1)=ID+"scsm0=instantiate_diagram()"
   txt($+1)=ID+"scsm0=set_diag_bkgcolor(scsm0,8)"
   txt($+1)=ID+"scsm0 = set_diagram_location(scsm0,[368,162,998,592],1.4)"
   txt($+1)=ID+"%context=.."
   txt($+1)=ID+""" """
   txt($+1)=ID+"scsm0 = set_diagram_context(scsm0,%context)"
   txt($+1)=ID+"%blk0=instantiate_block(""TOWS_c"")"
   txt($+1)=ID+"%blk0=set_block_bkgcolor(%blk0,8)"
   txt($+1)=ID+"%blk0=set_block_flip(%blk0,%t)"
   txt($+1)=ID+"%blk0=set_block_ident(%blk0,''"")"
   txt($+1)=ID+"%blk0=set_block_orig(%blk0,[371.104,217.01067])"
   txt($+1)=ID+"%blk0=set_block_sz(%blk0,[70,40])"
   txt($+1)=ID+"%blk0=set_block_theta(%blk0,0)"
   txt($+1)=ID+"%exprs=.."
   txt($+1)=ID+sci2exp([mdat;vname;"0"],0)
   txt($+1)=ID+"%blk0=set_block_parameters(%blk0,%exprs)"
   txt($+1)=ID+"[scsm0,%l] = add_block(scsm0,%blk0)"
   txt($+1)=ID+"%blk0=instantiate_block(""IN_f"")"
   txt($+1)=ID+"%blk0=set_block_bkgcolor(%blk0,8)"
   txt($+1)=ID+"%blk0=set_block_flip(%blk0,%t)"
   txt($+1)=ID+"%blk0=set_block_ident(%blk0,''"")"
   txt($+1)=ID+"%blk0=set_block_orig(%blk0,[203.17067,227.01067])"
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
   txt($+1)=ID+"%blk0=set_block_orig(%blk0,[283.83733,217.01067])"
   txt($+1)=ID+"%blk0=set_block_sz(%blk0,[40,40])"
   txt($+1)=ID+"%blk0=set_block_theta(%blk0,0)"
   txt($+1)=ID+"%exprs=.."
   txt($+1)=ID+"""1"""
   txt($+1)=ID+"%blk0=set_block_parameters(%blk0,%exprs)"
   txt($+1)=ID+"[scsm0,%l] = add_block(scsm0,%blk0)"
   txt($+1)=ID+"%blk0=instantiate_block(""SampleCLK"")"
   txt($+1)=ID+"%blk0=set_block_bkgcolor(%blk0,8)"
   txt($+1)=ID+"%blk0=set_block_flip(%blk0,%t)"
   txt($+1)=ID+"%blk0=set_block_ident(%blk0,''"")"
   txt($+1)=ID+"%blk0=set_block_orig(%blk0,[341.03733,323.344])"
   txt($+1)=ID+"%blk0=set_block_sz(%blk0,[60,40])"
   txt($+1)=ID+"%blk0=set_block_theta(%blk0,0)"
   txt($+1)=ID+"%exprs=.."
   txt($+1)=ID+"[""1"";""0""]"
   txt($+1)=ID+"%blk0=set_block_parameters(%blk0,%exprs)"
   txt($+1)=ID+"[scsm0,%l] = add_block(scsm0,%blk0)"
   txt($+1)=ID+"scsm0 = add_explicit_link(scsm0,[3,1],[1,1],[])"
   txt($+1)=ID+"scsm0 = add_explicit_link(scsm0,[2,1],[3,1],[])"
   txt($+1)=ID+"%blk0=instantiate_block(""CLKSPLIT_f"")"
   txt($+1)=ID+"%blk0=set_block_bkgcolor(%blk0,8)"
   txt($+1)=ID+"%blk0=set_block_flip(%blk0,%t)"
   txt($+1)=ID+"%blk0=set_block_ident(%blk0,''"")"
   txt($+1)=ID+"%blk0=set_block_orig(%blk0,[371.03733,293.27733])"
   txt($+1)=ID+"%blk0=set_block_sz(%blk0,[0.3333333,0.3333333])"
   txt($+1)=ID+"%blk0=set_block_theta(%blk0,0)"
   txt($+1)=ID+"%exprs=.."
   txt($+1)=ID+"[]"
   txt($+1)=ID+"%blk0=set_block_parameters(%blk0,%exprs)"
   txt($+1)=ID+"[scsm0,%l] = add_block(scsm0,%blk0)"
   txt($+1)=ID+"scsm0 = add_event_link(scsm0,[7,1],[1,1],[])"
   txt($+1)=ID+"scsm0 = add_event_link(scsm0,[7,2],[3,1],[])"
   txt($+1)=ID+"scsm0 = add_event_link(scsm0,[4,1],[7,1],[])"
      
   txt($+1)=ID+"%blk=fill_superblock(%blk,scsm0)"
   
else

   txt($+1)=ID+"%blk=instantiate_block('"TOWS_c'")"
   txt($+1)=ID+'%exprs='+sci2exp([mdat;vname;"1"],0)
   txt($+1)=ID+"%blk=set_block_parameters(%blk,%exprs)"

end
endfunction

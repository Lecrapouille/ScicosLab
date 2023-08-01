function txt=addDiscreteTransferFcn(txt,para,nin,nout)

	SampleTime=para.SampleTime

 [st,ierr]=evstr(SampleTime)
 if ierr>0 | st>0 then
  txt($+1)=ID+"%blk=instantiate_block('"SUPER_f'")"
  txt($+1)=ID+"%blk.graphics.gr_i(1)='" '""
  txt($+1)=ID+"scsm1=instantiate_diagram()"
  txt($+1)=ID+"scsm1 = set_diagram_location(scsm1,[552,284,1182,714],1.4)"
 
  txt($+1)=ID+"%blk1=instantiate_block('"SampleCLK'")"
  txt($+1)=ID+"%blk1=set_block_orig(%blk1,[276,313])"
  txt($+1)=ID+"%blk1=set_block_sz(%blk1,[60,40])"
  txt($+1)=ID+"%exprs="+sci2exp([para.SampleTime;"0"])
  txt($+1)=ID+"%blk1=set_block_parameters(%blk1,%exprs)"
  txt($+1)=ID+"[scsm1,%l] = add_block(scsm1,%blk1)"
       
  txt($+1)=ID+"%blk1=instantiate_block('"IN_f'")"
  txt($+1)=ID+"%blk1=set_block_orig(%blk1,[189,235])"
  txt($+1)=ID+"%blk1=set_block_sz(%blk1,[20,20])"
  txt($+1)=ID+"%exprs=['"1'";'"-1'";'"-1'"]"
  txt($+1)=ID+"%blk1=set_block_parameters(%blk1,%exprs)"
  txt($+1)=ID+"[scsm1,%l] = add_block(scsm1,%blk1)"

  txt($+1)=ID+"%blk1=instantiate_block('"OUT_f'")"
  txt($+1)=ID+"%blk1=set_block_orig(%blk1,[402,235])"
  txt($+1)=ID+"%blk1=set_block_sz(%blk1,[20,20])"
  txt($+1)=ID+"%exprs=['"1'"]"
  txt($+1)=ID+"%blk1=set_block_parameters(%blk1,%exprs)"
  txt($+1)=ID+"[scsm1,%l] = add_block(scsm1,%blk1)"
       

  txt($+1)=ID+"%blk1=instantiate_block('"DLR'")"
  txt($+1)=ID+"%blk1=set_block_orig(%blk1,[287,225])"
  txt($+1)=ID+"%blk1=set_block_sz(%blk1,[40,40])"
  num="poly(mtlb_fliplr("+para.Numerator+"),'"z'",'"coeff'")"
  den="poly(mtlb_fliplr("+para.Denominator+"),'"z'",'"coeff'")"
  txt($+1)=ID+'%exprs='+sci2exp([num,den],0)
  txt($+1)=ID+"%blk1=set_block_parameters(%blk1,%exprs)"
  txt($+1)=ID+"[scsm1,%l] = add_block(scsm1,%blk1)"
       
  txt($+1)=ID+"scsm1 = add_explicit_link(scsm1,[2,1],[4,1],[])"
  txt($+1)=ID+"scsm1 = add_explicit_link(scsm1,[4,1],[3,1],[])"
  txt($+1)=ID+"scsm1 = add_event_link(scsm1,[1,1],[4,1],[])"

  txt($+1)=ID+"%blk=fill_superblock(%blk,scsm1)"

else
   txt($+1)=ID+"%blk=instantiate_block(""SUPER_f"")"
   txt($+1)=ID+"%blk.graphics.gr_i(1)="" """
   txt($+1)=ID+"scsm0=instantiate_diagram()"
   txt($+1)=ID+"scsm0=set_diag_bkgcolor(scsm0,8)"
   txt($+1)=ID+"scsm0 = set_diagram_location(scsm0,[348,111,978,541],1.4)"
   txt($+1)=ID+"%context=.."
   txt($+1)=ID+""" """
   txt($+1)=ID+"scsm0 = set_diagram_context(scsm0,%context)"
   txt($+1)=ID+"%blk0=instantiate_block(""IN_f"")"
   txt($+1)=ID+"%blk0=set_block_bkgcolor(%blk0,8)"
   txt($+1)=ID+"%blk0=set_block_flip(%blk0,%t)"
   txt($+1)=ID+"%blk0=set_block_ident(%blk0,''"")"
   txt($+1)=ID+"%blk0=set_block_orig(%blk0,[167.97067,206.344])"
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
   txt($+1)=ID+"%blk0=set_block_orig(%blk0,[433.43733,206.344])"
   txt($+1)=ID+"%blk0=set_block_sz(%blk0,[20,20])"
   txt($+1)=ID+"%blk0=set_block_theta(%blk0,0)"
   txt($+1)=ID+"%exprs=.."
   txt($+1)=ID+"""1"""
   txt($+1)=ID+"%blk0=set_block_parameters(%blk0,%exprs)"
   txt($+1)=ID+"[scsm0,%l] = add_block(scsm0,%blk0)"
   txt($+1)=ID+"%blk0=instantiate_block(""Extract_Activation"")"
   txt($+1)=ID+"%blk0=set_block_bkgcolor(%blk0,8)"
   txt($+1)=ID+"%blk0=set_block_flip(%blk0,%t)"
   txt($+1)=ID+"%blk0=set_block_ident(%blk0,''"")"
   txt($+1)=ID+"%blk0=set_block_orig(%blk0,[276.63733,276.41067])"
   txt($+1)=ID+"%blk0=set_block_sz(%blk0,[60,40])"
   txt($+1)=ID+"%blk0=set_block_theta(%blk0,0)"
   txt($+1)=ID+"%exprs=.."
   txt($+1)=ID+"[]"
   txt($+1)=ID+"%blk0=set_block_parameters(%blk0,%exprs)"
   txt($+1)=ID+"[scsm0,%l] = add_block(scsm0,%blk0)"
   txt($+1)=ID+"%blk0=instantiate_block(""DLR"")"
   txt($+1)=ID+"%blk0=set_block_bkgcolor(%blk0,8)"
   txt($+1)=ID+"%blk0=set_block_flip(%blk0,%t)"
   txt($+1)=ID+"%blk0=set_block_ident(%blk0,''"")"
   txt($+1)=ID+"%blk0=set_block_orig(%blk0,[281.63733,191.344])"
   txt($+1)=ID+"%blk0=set_block_sz(%blk0,[50,50])"
   txt($+1)=ID+"%blk0=set_block_theta(%blk0,0)"
   num="poly(mtlb_fliplr("+para.Numerator+"),'"z'",'"coeff'")"
   den="poly(mtlb_fliplr("+para.Denominator+"),'"z'",'"coeff'")"
   txt($+1)=ID+'%exprs='+sci2exp([num,den],0)
   txt($+1)=ID+"%blk0=set_block_parameters(%blk0,%exprs)"
   txt($+1)=ID+"[scsm0,%l] = add_block(scsm0,%blk0)"
   txt($+1)=ID+"scsm0 = add_explicit_link(scsm0,[4,1],[2,1],[])"
   txt($+1)=ID+"scsm0 = add_event_link(scsm0,[3,1],[4,1],[])"
   txt($+1)=ID+"%blk0=instantiate_block(""SPLIT_f"")"
   txt($+1)=ID+"%blk0=set_block_bkgcolor(%blk0,8)"
   txt($+1)=ID+"%blk0=set_block_flip(%blk0,%t)"
   txt($+1)=ID+"%blk0=set_block_ident(%blk0,''"")"
   txt($+1)=ID+"%blk0=set_block_orig(%blk0,[220.77067;216.344])"
   txt($+1)=ID+"%blk0=set_block_sz(%blk0,[0.3333333,0.3333333])"
   txt($+1)=ID+"%blk0=set_block_theta(%blk0,0)"
   txt($+1)=ID+"%exprs=.."
   txt($+1)=ID+"[]"
   txt($+1)=ID+"%blk0=set_block_parameters(%blk0,%exprs)"
   txt($+1)=ID+"[scsm0,%l] = add_block(scsm0,%blk0)"
   txt($+1)=ID+"scsm0 = add_explicit_link(scsm0,[7,1],[4,1],[])"
   txt($+1)=ID+"scsm0 = add_explicit_link(scsm0,[7,2],[3,1],[])"
   txt($+1)=ID+"scsm0 = add_explicit_link(scsm0,[1,1],[7,1],[])"
      
   txt($+1)=ID+"%blk=fill_superblock(%blk,scsm0)"
   
   
end


endfunction

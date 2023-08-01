function txt=addSaturate(txt,para,nin,nout)

SampleTime=para.SampleTime
U=para.UpperLimit
L=para.LowerLimit
zcr=para.ZeroCross

  [st,ierr]=evstr(SampleTime)
 if ierr>0 | ~(st==-1) then

txt($+1)=ID+"%blk=instantiate_block(""SUPER_f"")"
txt($+1)=ID+"%blk.graphics.gr_i(1)="" """
txt($+1)=ID+"scsm0=instantiate_diagram()"
txt($+1)=ID+"scsm0=set_diag_bkgcolor(scsm0,8)"
txt($+1)=ID+"scsm0 = set_diagram_location(scsm0,[411,110,1041,540],1.4)"
txt($+1)=ID+"%context=.."
txt($+1)=ID+""" """
txt($+1)=ID+"scsm0 = set_diagram_context(scsm0,%context)"
txt($+1)=ID+"%blk0=instantiate_block(""SATURATION"")"
txt($+1)=ID+"%blk0=set_block_bkgcolor(%blk0,8)"
txt($+1)=ID+"%blk0=set_block_flip(%blk0,%t)"
txt($+1)=ID+"%blk0=set_block_ident(%blk0,''"")"
txt($+1)=ID+"%blk0=set_block_orig(%blk0,[318.304,209.67733])"
txt($+1)=ID+"%blk0=set_block_sz(%blk0,[40,40])"
txt($+1)=ID+"%blk0=set_block_theta(%blk0,0)"
txt($+1)=ID+"%exprs=.."
txt($+1)=ID+sci2exp([U;L;string(zcr)],0)
txt($+1)=ID+"%blk0=set_block_parameters(%blk0,%exprs)"
txt($+1)=ID+"[scsm0,%l] = add_block(scsm0,%blk0)"
txt($+1)=ID+"%blk0=instantiate_block(""IN_f"")"
txt($+1)=ID+"%blk0=set_block_bkgcolor(%blk0,8)"
txt($+1)=ID+"%blk0=set_block_flip(%blk0,%t)"
txt($+1)=ID+"%blk0=set_block_ident(%blk0,''"")"
txt($+1)=ID+"%blk0=set_block_orig(%blk0,[156.97067,219.67733])"
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
txt($+1)=ID+"%blk0=set_block_orig(%blk0,[427.57067,219.67733])"
txt($+1)=ID+"%blk0=set_block_sz(%blk0,[20,20])"
txt($+1)=ID+"%blk0=set_block_theta(%blk0,0)"
txt($+1)=ID+"%exprs=.."
txt($+1)=ID+"""1"""
txt($+1)=ID+"%blk0=set_block_parameters(%blk0,%exprs)"
txt($+1)=ID+"[scsm0,%l] = add_block(scsm0,%blk0)"
txt($+1)=ID+"scsm0 = add_explicit_link(scsm0,[1,1],[3,1],[])"
txt($+1)=ID+"%blk0=instantiate_block(""SAMPHOLD_m"")"
txt($+1)=ID+"%blk0=set_block_bkgcolor(%blk0,8)"
txt($+1)=ID+"%blk0=set_block_flip(%blk0,%t)"
txt($+1)=ID+"%blk0=set_block_ident(%blk0,''"")"
txt($+1)=ID+"%blk0=set_block_orig(%blk0,[224.43733,209.67733])"
txt($+1)=ID+"%blk0=set_block_sz(%blk0,[40,40])"
txt($+1)=ID+"%blk0=set_block_theta(%blk0,0)"
txt($+1)=ID+"%exprs=.."
txt($+1)=ID+"""1"""
txt($+1)=ID+"%blk0=set_block_parameters(%blk0,%exprs)"
txt($+1)=ID+"[scsm0,%l] = add_block(scsm0,%blk0)"
txt($+1)=ID+"scsm0 = add_explicit_link(scsm0,[5,1],[1,1],[])"
txt($+1)=ID+"scsm0 = add_explicit_link(scsm0,[2,1],[5,1],[])"
txt($+1)=ID+"%blk0=instantiate_block(""SampleCLK"")"
txt($+1)=ID+"%blk0=set_block_bkgcolor(%blk0,8)"
txt($+1)=ID+"%blk0=set_block_flip(%blk0,%t)"
txt($+1)=ID+"%blk0=set_block_ident(%blk0,''"")"
txt($+1)=ID+"%blk0=set_block_orig(%blk0,[214.43733,304.27733])"
txt($+1)=ID+"%blk0=set_block_sz(%blk0,[60,40])"
txt($+1)=ID+"%blk0=set_block_theta(%blk0,0)"
txt($+1)=ID+"%exprs=.."
txt($+1)=ID+sci2exp([SampleTime;"0"],0)
txt($+1)=ID+"%blk0=set_block_parameters(%blk0,%exprs)"
txt($+1)=ID+"[scsm0,%l] = add_block(scsm0,%blk0)"
txt($+1)=ID+"scsm0 = add_event_link(scsm0,[8,1],[5,1],[])"
   
txt($+1)=ID+"%blk=fill_superblock(%blk,scsm0)"


  
 else

txt($+1)=ID+"%blk=instantiate_block(""SATURATION"")"
txt($+1)=ID+"%exprs=.."
txt($+1)=ID+sci2exp([U;L;string(zcr)],0)
txt($+1)=ID+"%blk=set_block_parameters(%blk,%exprs)"
 end

endfunction

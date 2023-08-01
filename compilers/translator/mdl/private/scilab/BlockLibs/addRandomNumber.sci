function txt=addRandomNumber(txt,para,nin,nout)

	m=para.Mean 
	v="sqrt("+para.Variance+")" 
	sd="["+para.Seed+",0]" 
	st=para.SampleTime 

if st=="0" then warning("The random block with sampletime 0 does not function."),end

txt($+1)=ID+"%blk=instantiate_block(""SUPER_f"")"
txt($+1)=ID+"%blk.graphics.gr_i(1)="" """
txt($+1)=ID+"scsm0=instantiate_diagram()"
txt($+1)=ID+"scsm0=set_diag_bkgcolor(scsm0,8)"
txt($+1)=ID+"scsm0 = set_diagram_location(scsm0,[398,127,1028,557],1.4)"
txt($+1)=ID+"%context=.."
txt($+1)=ID+""" """
txt($+1)=ID+"scsm0 = set_diagram_context(scsm0,%context)"
txt($+1)=ID+"%blk0=instantiate_block(""RAND_m"")"
txt($+1)=ID+"%blk0=set_block_bkgcolor(%blk0,8)"
txt($+1)=ID+"%blk0=set_block_flip(%blk0,%t)"
txt($+1)=ID+"%blk0=set_block_ident(%blk0,''"")"
txt($+1)=ID+"%blk0=set_block_orig(%blk0,[239.83733,205.27733])"
txt($+1)=ID+"%blk0=set_block_sz(%blk0,[60,40])"
txt($+1)=ID+"%blk0=set_block_theta(%blk0,0)"
txt($+1)=ID+"%exprs=.."
txt($+1)=ID+sci2exp(["1";"1";m;v;sd],0)
txt($+1)=ID+"%blk0=set_block_parameters(%blk0,%exprs)"
txt($+1)=ID+"[scsm0,%l] = add_block(scsm0,%blk0)"
txt($+1)=ID+"%blk0=instantiate_block(""SampleCLK"")"
txt($+1)=ID+"%blk0=set_block_bkgcolor(%blk0,8)"
txt($+1)=ID+"%blk0=set_block_flip(%blk0,%t)"
txt($+1)=ID+"%blk0=set_block_ident(%blk0,''"")"
txt($+1)=ID+"%blk0=set_block_orig(%blk0,[239.83733,294.01067])"
txt($+1)=ID+"%blk0=set_block_sz(%blk0,[60,40])"
txt($+1)=ID+"%blk0=set_block_theta(%blk0,0)"
txt($+1)=ID+"%exprs=.."
txt($+1)=ID+sci2exp([st;"0"],0)
txt($+1)=ID+"%blk0=set_block_parameters(%blk0,%exprs)"
txt($+1)=ID+"[scsm0,%l] = add_block(scsm0,%blk0)"
txt($+1)=ID+"scsm0 = add_event_link(scsm0,[2,1],[1,1],[])"
txt($+1)=ID+"%blk0=instantiate_block(""OUT_f"")"
txt($+1)=ID+"%blk0=set_block_bkgcolor(%blk0,8)"
txt($+1)=ID+"%blk0=set_block_flip(%blk0,%t)"
txt($+1)=ID+"%blk0=set_block_ident(%blk0,''"")"
txt($+1)=ID+"%blk0=set_block_orig(%blk0,[374.03733,215.27733])"
txt($+1)=ID+"%blk0=set_block_sz(%blk0,[20,20])"
txt($+1)=ID+"%blk0=set_block_theta(%blk0,0)"
txt($+1)=ID+"%exprs=.."
txt($+1)=ID+"""1"""
txt($+1)=ID+"%blk0=set_block_parameters(%blk0,%exprs)"
txt($+1)=ID+"[scsm0,%l] = add_block(scsm0,%blk0)"
txt($+1)=ID+"scsm0 = add_explicit_link(scsm0,[1,1],[4,1],[])"
   
txt($+1)=ID+"%blk=fill_superblock(%blk,scsm0)"
  
endfunction

function txt=addMath(txt,para,nin,nout)

  op=para.Operator
  SampleTime=para.SampleTime
  

  if op=="exp" then
    bb="EXPBLK_m"
    exprsz="%e"
  elseif op=="log" then
    bb="LOGBLK_f"
    exprsz="%e"
  elseif op=="10^u" then
    bb="EXPBLK_m"
    exprsz="10"    
  elseif op=="log10" then
    bb="LOGBLK_f"
    exprsz="10"
  elseif op=="reciprocal" then
    bb="LOGBLK_f"
    exprsz=[]
  elseif op=="sqrt" then
    bb="POWBLK_f"
    exprsz="1/2"
  elseif op=="square" then
    bb="POWBLK_f"
    exprsz="2"
  elseif op=="conj" then
    bb="MATZCONJ"
    exprsz=[]
  elseif op=="conj" then
    bb="MATTRAN"
    exprsz=[]
  else
    warning('Math block: '+op+' operation not supported.')
    bb="POWBLK_f"
    exprsz="1"
  end

  [st,ierr]=evstr(SampleTime)
 if ierr>0 | st>=0 then

txt($+1)=ID+"%blk=instantiate_block(""SUPER_f"")"
txt($+1)=ID+"%blk.graphics.gr_i(1)="" """
txt($+1)=ID+"scsm0=instantiate_diagram()"
txt($+1)=ID+"scsm0=set_diag_bkgcolor(scsm0,8)"
txt($+1)=ID+"scsm0 = set_diagram_location(scsm0,[381,81,1011,511],1.4)"

txt($+1)=ID+"%blk0=instantiate_block(""IN_f"")"
txt($+1)=ID+"%blk0=set_block_bkgcolor(%blk0,8)"
txt($+1)=ID+"%blk0=set_block_flip(%blk0,%t)"
txt($+1)=ID+"%blk0=set_block_ident(%blk0,''"")"
txt($+1)=ID+"%blk0=set_block_orig(%blk0,[116.63733,217.744])"
txt($+1)=ID+"%blk0=set_block_sz(%blk0,[20,20])"
txt($+1)=ID+"%blk0=set_block_theta(%blk0,0)"
txt($+1)=ID+"%exprs=.."
txt($+1)=ID+"[""1"";""-1"";""-1""]"
txt($+1)=ID+"%blk0=set_block_parameters(%blk0,%exprs)"
txt($+1)=ID+"[scsm0,%l] = add_block(scsm0,%blk0)"

txt($+1)=ID+"%blk0=instantiate_block(""SampleCLK"")"
txt($+1)=ID+"%blk0=set_block_bkgcolor(%blk0,8)"
txt($+1)=ID+"%blk0=set_block_flip(%blk0,%t)"
txt($+1)=ID+"%blk0=set_block_ident(%blk0,''"")"
txt($+1)=ID+"%blk0=set_block_orig(%blk0,[179.97067,285.21067])"
txt($+1)=ID+"%blk0=set_block_sz(%blk0,[60,40])"
txt($+1)=ID+"%blk0=set_block_theta(%blk0,0)"
txt($+1)=ID+"%exprs=.."
txt($+1)=ID+sci2exp([SampleTime;"0"],0)
txt($+1)=ID+"%blk0=set_block_parameters(%blk0,%exprs)"
txt($+1)=ID+"[scsm0,%l] = add_block(scsm0,%blk0)"
txt($+1)=ID+"%blk0=instantiate_block(""OUT_f"")"
txt($+1)=ID+"%blk0=set_block_bkgcolor(%blk0,8)"
txt($+1)=ID+"%blk0=set_block_flip(%blk0,%t)"
txt($+1)=ID+"%blk0=set_block_ident(%blk0,''"")"
txt($+1)=ID+"%blk0=set_block_orig(%blk0,[372.57067,217.744])"
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
txt($+1)=ID+"%blk0=set_block_orig(%blk0,[189.97067,207.744])"
txt($+1)=ID+"%blk0=set_block_sz(%blk0,[40,40])"
txt($+1)=ID+"%blk0=set_block_theta(%blk0,0)"
txt($+1)=ID+"%exprs=.."
txt($+1)=ID+"""1"""
txt($+1)=ID+"%blk0=set_block_parameters(%blk0,%exprs)"
txt($+1)=ID+"[scsm0,%l] = add_block(scsm0,%blk0)"

txt($+1)=ID+"%blk0=instantiate_block('""+bb+"'")"
txt($+1)=ID+"%blk0=set_block_bkgcolor(%blk0,8)"
txt($+1)=ID+"%blk0=set_block_flip(%blk0,%t)"
txt($+1)=ID+"%blk0=set_block_ident(%blk0,''"")"
txt($+1)=ID+"%blk0=set_block_orig(%blk0,[282.37067,207.744])"
txt($+1)=ID+"%blk0=set_block_sz(%blk0,[40,40])"
txt($+1)=ID+"%blk0=set_block_theta(%blk0,0)"
txt($+1)=ID+"%exprs=.."
txt($+1)=ID+sci2exp(exprsz)
txt($+1)=ID+"%blk0=set_block_parameters(%blk0,%exprs)"
txt($+1)=ID+"[scsm0,%l] = add_block(scsm0,%blk0)"
txt($+1)=ID+"scsm0 = add_explicit_link(scsm0,[1,1],[4,1],[])"
txt($+1)=ID+"scsm0 = add_explicit_link(scsm0,[4,1],[5,1],[])"
txt($+1)=ID+"scsm0 = add_explicit_link(scsm0,[5,1],[3,1],[])"
txt($+1)=ID+"scsm0 = add_event_link(scsm0,[2,1],[4,1],[])"
   
txt($+1)=ID+"%blk=fill_superblock(%blk,scsm0)"

 else

   txt($+1)=ID+"%blk=instantiate_block('""+bb+"'")"
   txt($+1)=ID+"%exprs=.."
   txt($+1)=ID+sci2exp(exprsz)
   txt($+1)=ID+"%blk=set_block_parameters(%blk,%exprs)"

 end

endfunction

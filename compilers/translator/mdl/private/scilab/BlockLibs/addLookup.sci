function txt=addLookup(txt,para,nin,nout)
     x=para.InputValues	    
     if isfield(para,"OutputValues") then //old version
        y=para.OutputValues	
     else
        y=para.Table
     end
     meth=para.LookUpMeth

     if meth== "Interpolation-Extrapolation" then
         SIm=1;Em=1
     elseif meth=="Interpolation-Use End Values" then
         SIm=1;Em=0
     elseif meth=="Use Input Nearest" then     
         SIm=9;Em=0
     elseif meth=="Use Input Below" then     
         SIm=8;Em=0
     elseif meth=="Use Input Above" then     
         SIm=0;Em=0
     else
         warning('Lookup block: Unknown interpolation method '+meth)
         SIm=1;Em=0
     end
     SampleTime=para.SampleTime

    [st,ierr]=evstr(SampleTime)

          if ierr>0 | st>=0 then


txt($+1)=ID+"%blk=instantiate_block(""SUPER_f"")"
txt($+1)=ID+"%blk.graphics.gr_i(1)="" """
txt($+1)=ID+"scsm0=instantiate_diagram()"
txt($+1)=ID+"scsm0=set_diag_bkgcolor(scsm0,8)"
txt($+1)=ID+"scsm0 = set_diagram_location(scsm0,[292,165,922,595],1.4)"

txt($+1)=ID+"%blk0=instantiate_block(""IN_f"")"
txt($+1)=ID+"%blk0=set_block_bkgcolor(%blk0,8)"
txt($+1)=ID+"%blk0=set_block_flip(%blk0,%t)"
txt($+1)=ID+"%blk0=set_block_ident(%blk0,''"")"
txt($+1)=ID+"%blk0=set_block_orig(%blk0,[186.304,191.81067])"
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
txt($+1)=ID+"%blk0=set_block_orig(%blk0,[239.37067,304.27733])"
txt($+1)=ID+"%blk0=set_block_sz(%blk0,[60,40])"
txt($+1)=ID+"%blk0=set_block_theta(%blk0,0)"
txt($+1)=ID+"%exprs=.."
txt($+1)=ID+sci2exp([SampleTime;"0"],0)
txt($+1)=ID+"%blk0=set_block_parameters(%blk0,%exprs)"
txt($+1)=ID+"[scsm0,%l] = add_block(scsm0,%blk0)"
txt($+1)=ID+"%blk0=instantiate_block(""SAMPHOLD_m"")"
txt($+1)=ID+"%blk0=set_block_bkgcolor(%blk0,8)"
txt($+1)=ID+"%blk0=set_block_flip(%blk0,%t)"
txt($+1)=ID+"%blk0=set_block_ident(%blk0,''"")"
txt($+1)=ID+"%blk0=set_block_orig(%blk0,[249.37067,181.81067])"
txt($+1)=ID+"%blk0=set_block_sz(%blk0,[40,40])"
txt($+1)=ID+"%blk0=set_block_theta(%blk0,0)"
txt($+1)=ID+"%exprs=.."
txt($+1)=ID+"""1"""
txt($+1)=ID+"%blk0=set_block_parameters(%blk0,%exprs)"
txt($+1)=ID+"[scsm0,%l] = add_block(scsm0,%blk0)"
txt($+1)=ID+"%blk0=instantiate_block(""LOOKUP_c"")"
txt($+1)=ID+"%blk0=set_block_bkgcolor(%blk0,8)"
txt($+1)=ID+"%blk0=set_block_flip(%blk0,%t)"
txt($+1)=ID+"%blk0=set_block_ident(%blk0,''"")"
txt($+1)=ID+"%blk0=set_block_orig(%blk0,[347.63733,181.81067])"
txt($+1)=ID+"%blk0=set_block_sz(%blk0,[40,40])"
txt($+1)=ID+"%blk0=set_block_theta(%blk0,0)"
txt($+1)=ID+"%exprs=.."
txt($+1)=ID+sci2exp([string(SIm);x;y;string(Em);"n"],0)
txt($+1)=ID+"%blk0=set_block_parameters(%blk0,%exprs)"
txt($+1)=ID+"[scsm0,%l] = add_block(scsm0,%blk0)"
txt($+1)=ID+"%blk0=instantiate_block(""OUT_f"")"
txt($+1)=ID+"%blk0=set_block_bkgcolor(%blk0,8)"
txt($+1)=ID+"%blk0=set_block_flip(%blk0,%t)"
txt($+1)=ID+"%blk0=set_block_ident(%blk0,''"")"
txt($+1)=ID+"%blk0=set_block_orig(%blk0,[448.104,191.81067])"
txt($+1)=ID+"%blk0=set_block_sz(%blk0,[20,20])"
txt($+1)=ID+"%blk0=set_block_theta(%blk0,0)"
txt($+1)=ID+"%exprs=.."
txt($+1)=ID+"""1"""
txt($+1)=ID+"%blk0=set_block_parameters(%blk0,%exprs)"
txt($+1)=ID+"[scsm0,%l] = add_block(scsm0,%blk0)"
txt($+1)=ID+"scsm0 = add_explicit_link(scsm0,[4,1],[5,1],[])"
txt($+1)=ID+"scsm0 = add_explicit_link(scsm0,[3,1],[4,1],[])"
txt($+1)=ID+"scsm0 = add_explicit_link(scsm0,[1,1],[3,1],[])"
txt($+1)=ID+"scsm0 = add_event_link(scsm0,[2,1],[3,1],[])"
   
txt($+1)=ID+"%blk=fill_superblock(%blk,scsm0)"

         else

      txt($+1)=ID+"%blk=instantiate_block('"LOOKUP_c'")"
      txt($+1)=ID+'%exprs='+sci2exp([string(SIm);x;y;string(Em);"n"],0)
      txt($+1)=ID+"%blk=set_block_parameters(%blk,%exprs)"

         end

endfunction

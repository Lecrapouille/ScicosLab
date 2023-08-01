function txt=addCompare_To_Constant(txt,para,nin,nout)

       select para.relop
        case '=='
          Operator=0
        case '~='
          Operator=1
        case '<'
          Operator=2
        case '<='
          Operator=3
        case '>'
          Operator=4
        case '>='
          Operator=5
        end

      const=para.const

      OutDataTypeStr=para.LogicOutDataTypeMode
      if isequal(part(OutDataTypeStr,1:7),'Inherit') then
         dtype=-1
       elseif OutDataTypeStr=='double' then
         dtype=1
        elseif OutDataTypeStr=='single' then
         dtype=1
         warning('Logic block: single type not supported, double used.')
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
         warning('Logic block: unsupported type, double used.')
         dtype=1
       end

       if para.ZeroCross=="on" then
         zcr=1
       elseif para.ZeroCross=="off" then
         zcr=0
       else
         warning('Compare To Constrant: ZeroCrossing flag cannot be determined.'),
         zcr=1
       end

txt($+1)=ID+"%blk=instantiate_block(""SUPER_f"")"
txt($+1)=ID+"%blk.graphics.gr_i(1)="" """
txt($+1)=ID+"scsm0=instantiate_diagram()"
txt($+1)=ID+"scsm0=set_diag_bkgcolor(scsm0,8)"
txt($+1)=ID+"scsm0 = set_diagram_location(scsm0,[297,144,927,574],1.4)"
txt($+1)=ID+"%context=.."
txt($+1)=ID+""" """
txt($+1)=ID+"scsm0 = set_diagram_context(scsm0,%context)"
txt($+1)=ID+"%blk0=instantiate_block(""IN_f"")"
txt($+1)=ID+"%blk0=set_block_bkgcolor(%blk0,8)"
txt($+1)=ID+"%blk0=set_block_flip(%blk0,%t)"
txt($+1)=ID+"%blk0=set_block_ident(%blk0,''"")"
txt($+1)=ID+"%blk0=set_block_orig(%blk0,[169.43733,195.544])"
txt($+1)=ID+"%blk0=set_block_sz(%blk0,[20,20])"
txt($+1)=ID+"%blk0=set_block_theta(%blk0,0)"
txt($+1)=ID+"%exprs=.."
txt($+1)=ID+"[""1"";""-1"";""-1""]"
txt($+1)=ID+"%blk0=set_block_parameters(%blk0,%exprs)"
txt($+1)=ID+"[scsm0,%l] = add_block(scsm0,%blk0)"
txt($+1)=ID+"%blk0=instantiate_block(""CONST_m"")"
txt($+1)=ID+"%blk0=set_block_bkgcolor(%blk0,8)"
txt($+1)=ID+"%blk0=set_block_flip(%blk0,%t)"
txt($+1)=ID+"%blk0=set_block_ident(%blk0,''"")"
txt($+1)=ID+"%blk0=set_block_orig(%blk0,[231.03733,127.544])"
txt($+1)=ID+"%blk0=set_block_sz(%blk0,[40,40])"
txt($+1)=ID+"%blk0=set_block_theta(%blk0,0)"
txt($+1)=ID+"%exprs=.."
txt($+1)=ID+sci2exp(const)
txt($+1)=ID+"%blk0=set_block_parameters(%blk0,%exprs)"
txt($+1)=ID+"[scsm0,%l] = add_block(scsm0,%blk0)"
txt($+1)=ID+"%blk0=instantiate_block(""RELATIONALOP"")"
txt($+1)=ID+"%blk0=set_block_bkgcolor(%blk0,8)"
txt($+1)=ID+"%blk0=set_block_flip(%blk0,%t)"
txt($+1)=ID+"%blk0=set_block_ident(%blk0,''"")"
txt($+1)=ID+"%blk0=set_block_orig(%blk0,[311.704,178.87733])"
txt($+1)=ID+"%blk0=set_block_sz(%blk0,[50,40])"
txt($+1)=ID+"%blk0=set_block_theta(%blk0,0)"
txt($+1)=ID+"%exprs=.."
txt($+1)=ID+sci2exp([string(Operator);string(zcr);string(dtype)],0)
txt($+1)=ID+"%blk0=set_block_parameters(%blk0,%exprs)"
txt($+1)=ID+"[scsm0,%l] = add_block(scsm0,%blk0)"
txt($+1)=ID+"%blk0=instantiate_block(""OUT_f"")"
txt($+1)=ID+"%blk0=set_block_bkgcolor(%blk0,8)"
txt($+1)=ID+"%blk0=set_block_flip(%blk0,%t)"
txt($+1)=ID+"%blk0=set_block_ident(%blk0,''"")"
txt($+1)=ID+"%blk0=set_block_orig(%blk0,[441.504,188.87733])"
txt($+1)=ID+"%blk0=set_block_sz(%blk0,[20,20])"
txt($+1)=ID+"%blk0=set_block_theta(%blk0,0)"
txt($+1)=ID+"%exprs=.."
txt($+1)=ID+"""1"""
txt($+1)=ID+"%blk0=set_block_parameters(%blk0,%exprs)"
txt($+1)=ID+"[scsm0,%l] = add_block(scsm0,%blk0)"
txt($+1)=ID+"scsm0 = add_explicit_link(scsm0,[2,1],[3,2],[])"
txt($+1)=ID+"scsm0 = add_explicit_link(scsm0,[1,1],[3,1],[])"
txt($+1)=ID+"scsm0 = add_explicit_link(scsm0,[3,1],[4,1],[])"
   
txt($+1)=ID+"%blk=fill_superblock(%blk,scsm0)"

endfunction

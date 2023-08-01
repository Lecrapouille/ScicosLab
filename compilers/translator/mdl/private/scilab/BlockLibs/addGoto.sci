function txt=addGoto(txt,para,nin,nout)

      select para.TagVisibility
      case "local"
        tg=1
      case "scoped"
        tg=2
      case "global"
        tg=3
      end

      txt($+1)=ID+"%blk=instantiate_block('"GOTO'")"
      txt($+1)=ID+'%exprs='+sci2exp([sci2exp(para.GotoTag);string(tg);"1"],0)
      txt($+1)=ID+"%blk=set_block_parameters(%blk,%exprs)"
endfunction

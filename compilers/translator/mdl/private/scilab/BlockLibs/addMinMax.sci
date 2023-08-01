function txt=addMinMax(txt,para,nin,nout)


  if ~isequal(para.SampleTime,"-1")|evstr(para.Inputs)>2 then
   warning('Not inherited MinMax block, or more than 2 inputs  not supported yet.')
   txt($+1)=ID+"%blk=instantiate_block('"SUPER_f'")"
   txt($+1)=ID+"%blk.graphics.gr_i(1)='" '""
   diagName="MinMax"

   context='//   MinMax'
   paras=getfield(1,para)
   np=size(paras,"*")-2
   for ii=1:np
       context(ii+1)=paras(2+ii)+"="+sci2exp(para(paras(2+ii)),0)
   end

   txt=create_empty_scsm1(txt,nin,nout,context,diagName)
   txt($+1)=ID+"%blk=fill_superblock(%blk,scsm1)"

  else

      if para.ZeroCross=="on" then zcr='1', else zcr='0',end
      nin=para.Inputs
      if para.Function=="min" then F='1', else F='2', end
 
        txt($+1)=ID+"%blk=instantiate_block('"MAXMIN'")"
        txt($+1)=ID+'%exprs='+sci2exp([F;nin;zcr],0)
        txt($+1)=ID+"%blk=set_block_parameters(%blk,%exprs)"
  end

endfunction

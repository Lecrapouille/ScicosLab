function txt=addLogic(txt,para,nin,nout)

select para.Operator
case 'AND'
  op=0
case 'OR'
  op=1
case 'NAND'
  op=2
case 'NOR'
  op=3
case 'XOR'
  op=4
case 'NXOR'
  op=-1
case 'NOT'
  op=5
end

  if ~isequal(para.SampleTime,"-1") then
   warning('Not inherited Logic block not supported')
   txt($+1)=ID+"%blk=instantiate_block('"SUPER_f'")"
   txt($+1)=ID+"%blk.graphics.gr_i(1)='" '""
   diagName="Logic"

   context='//   Logic'
   paras=getfield(1,para)
   np=size(paras,"*")-2
   for ii=1:np
       context(ii+1)=paras(2+ii)+"="+sci2exp(para(paras(2+ii)),0)
   end

   txt=create_empty_scsm1(txt,nin,nout,context,diagName)
   txt($+1)=ID+"%blk=fill_superblock(%blk,scsm1)"

  elseif op==-1
   warning('NXOR not supported in Logic')
   txt($+1)=ID+"%blk=instantiate_block('"SUPER_f'")"
   txt($+1)=ID+"%blk.graphics.gr_i(1)='" '""
   diagName="Logic"

   context='//   Logic'
   paras=getfield(1,para)
   np=size(paras,"*")-2
   for ii=1:np
       context(ii+1)=paras(2+ii)+"="+sci2exp(para(paras(2+ii)),0)
   end

   txt=create_empty_scsm1(txt,nin,nout,context,diagName)
   txt($+1)=ID+"%blk=fill_superblock(%blk,scsm1)"
  else

      nin=para.Inputs
      if op==5 then nin=1,end

      OutDataTypeStr=para.OutDataTypeStr
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

      txt($+1)=ID+"%blk=instantiate_block('"LOGICAL_OP'")"
      txt($+1)=ID+'%exprs='+sci2exp([string(nin);string(op);string(dtype);"0"],0)
      txt($+1)=ID+"%blk=set_block_parameters(%blk,%exprs)"
  end
endfunction

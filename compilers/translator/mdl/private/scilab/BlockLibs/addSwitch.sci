function txt=addSwitch(txt,para,nin,nout)

crit=strsubst(para.Criteria,' ','')

select crit
case 'u2>=Threshold'
  op=0
case 'u2>Threshold'
  op=1
case 'u2~=0'
  op=2
else
  warning("unsupporte cirterion: "+crit+" in Switch. Use u2>=Threshold.")
  op=0
end


zcr=para.ZeroCross

thresh=para.Threshold
if op==2 then thresh=0,end

  if ~isequal(para.SampleTime,"-1") then
   warning('Not inherited Logic block not supported')
   txt($+1)=ID+"%blk=instantiate_block('"SUPER_f'")"
   txt($+1)=ID+"%blk.graphics.gr_i(1)='" '""
   diagName="Switch"

   context='//   Switch'
   paras=getfield(1,para)
   np=size(paras,"*")-2
   for ii=1:np
       context(ii+1)=paras(2+ii)+"="+sci2exp(para(paras(2+ii)),0)
   end

   txt=create_empty_scsm1(txt,nin,nout,context,diagName)
   txt($+1)=ID+"%blk=fill_superblock(%blk,scsm1)"

  else
      OutDataTypeStr=para.OutDataTypeStr
      if isequal(part(OutDataTypeStr,1:7),'Inherit') then
         dtype=-1
       elseif OutDataTypeStr=='double' then
         dtype=1
        elseif OutDataTypeStr=='single' then
         dtype=1
         warning('Switch block: single type not supported, double used.')
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
         warning('Switch block: unsupported type, double used.')
         dtype=1
       end

      txt($+1)=ID+"%blk=instantiate_block('"SWITCH2_s'")"
      txt($+1)=ID+'%exprs='+sci2exp([string(dtype);string(op);string(thresh);string(zcr)],0)
      txt($+1)=ID+"%blk=set_block_parameters(%blk,%exprs)"
  end
endfunction

function RestoreMask_()
// Copyright INRIA
Cmenu=[];%pt=[];

if size(Select,1)<>1 | curwin<>Select(1,2) then
   return
end
i=Select(1)
o=scs_m.objs(i)
if typeof(o)=='Block' then
   if o.model.sim=='super'  then
     ok=0
     okk=tk_choose([' Proceed ';' Abandon '],..
         ['Restoring mask should not be used if the';..
          'previsouly masked block has been modified,';..
          'or if the block has never been masked.'])
     if okk==1 then ok=1,end

     if ok then
       o.model.sim='csuper'
       o.model.ipar=1 
       o.gui='DSUPER'
//       o.graphics.exprs=[]      
       scs_m_save = scs_m    ;
       scs_m.objs(i)=o;
       nc_save = needcompile ;
       needcompile=4  // this is perhaps too conservative
       enable_undo = %t
       edited=%t
     end
   else
      message('This block is not a super block.')
   end
else
  message('Select a block.')
end
endfunction

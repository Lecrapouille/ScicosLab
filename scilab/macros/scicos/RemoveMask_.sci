function RemoveMask_()
// Copyright INRIA
Cmenu=[];%pt=[];
if size(Select,1)<>1 | curwin<>Select(1,2) then
   return
end
i=Select(1)
o=scs_m.objs(i)
if typeof(o)=='Block' then
   if o.model.sim=='csuper' & isequal(o.model.ipar,1)  then
     //test if there is not a parameter that is not defined
     [%scicos_context1,ierr]=script2var(o.model.rpar.props.context,%scicos_context)
     if ierr==0 then
       [sblock,%w,needcompile2,ok]=do_eval(o.model.rpar,list(),%scicos_context1)
     else
       message(["Error evaluating context:";lasterror()])
       ok=%f
     end

     if ~ok then
        okk=tk_choose(['Proceed';'Abandon'],..
          ['Removing the mask under these conditions';'is not recommended.'])   
        if okk==1 then ok=1,end
     end

     if ok then
       o.model.sim='super'
       o.model.ipar=[] 
       o.gui='SUPER_f'
//       o.graphics.exprs=[]      
       scs_m_save = scs_m    ;
       scs_m.objs(i)=o;
       nc_save = needcompile ;
       needcompile=4  // this is perhaps too conservative
       enable_undo = %t
       edited=%t
     else
       message(['An Error occured while evaluating the subsystem.';
	 'A variable may not be defined.';
	 'The mask will not be remove.']);
     end
   else
      message('This block is not masked.')
   end
else
  message('Select a block.')
end
endfunction

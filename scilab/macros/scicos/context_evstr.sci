function [%vv_list,%ierr_vec,%err_mess,%ok]=context_evstr(%str,%scicos_context,%typ,%flag)
// Copyright INRIA
// Evaluate Scicos Context utility function
 %ok=%t
 %err_mess=[];lasterror();
 %mm=getfield(1,%scicos_context)
 for %mi=%mm(3:$)
   if execstr(%mi+'=%scicos_context(%mi)','errcatch')<>0 then
     %err_mess=lasterror()
     if %err_mess==[] then %err_mess='Error in evaluating '+%mi,end
     %ok=%f
     return
   end
 end
 %nn=prod(size(%str))
 %ierr_vec=zeros(%nn,1)
 %vv_list=list()
 for %kk=1:%nn
   if %typ(2*%kk-1)(1)<>'str' then
     [%vv_list(%kk),%ierr_vec(%kk)]=evstr(%str(%kk));
     %err_mes1=lasterror()
     if %err_mes1<>[] then
       %err_mess(%kk)=%err_mes1;
     else
       %params=GetLitParam('['+%str(%kk)+']')
       %vvhere=setdiff(%params,%mm);
       if %vvhere<>[] then 
	 %err_mess(%kk)='The variable ""'+%vvhere+'"" is not defined in the context'
	 %ok=%f
	 if %flag=='set' then
	   message(%err_mess(%kk))
	 end
       end
     end
   else
     %vv_list(%kk)=%str(%kk);
   end
 end
endfunction

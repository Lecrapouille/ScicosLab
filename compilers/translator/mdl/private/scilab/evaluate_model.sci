function [scs_m,ok]=evaluate_model(scs_m,%scicos_context)
ok=%t
rhs=argn(2)
if rhs<2 then
  %scicos_context=struct()
end
context=scs_m.props.context
[%scicos_context, ierr] = script2var(context, %scicos_context)

    //for backward compatibility for scifunc
    if ierr==0 then
      %mm = getfield(1,%scicos_context)
      for %mi=%mm(3:$)
        ierr = execstr(%mi+'=%scicos_context(%mi)','errcatch')
        if ierr<>0 then
          break; //** in case of error exit
        end
      end
    end
    //end of for backward compatibility for scifunc

    if ierr <>0 then
      ok=%f
      message(['Error occur when evaluating context:'
               lasterror() ]);

    else 
      needcompile=4

      [scs_m,%cpr,needcompile,ok] = do_eval(scs_m, list(),%scicos_context)
      if ~ok then message(["Error during evaluation.";lasterror()]),end
    end
endfunction

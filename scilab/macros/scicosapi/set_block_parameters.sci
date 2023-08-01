function blk = set_block_parameters(blk,params)

xxx=getfield(1,params)
parnames=xxx(3:$)



exprs=[]
for params_name=parnames
  exprs($+1)=params(params_name)
end

//if blk.gui=="TEXT_f" then
  // exprs(1)=evstr(exprs(1))
//end

   blk.graphics.exprs = exprs
endfunction

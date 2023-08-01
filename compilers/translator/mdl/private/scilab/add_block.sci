function [scs_m,obj_num] = add_block(scs_m,blk)
  scs_m.objs($+1) = blk ; //** add the object to the data structure
  obj_num = length(scs_m.objs)

endfunction

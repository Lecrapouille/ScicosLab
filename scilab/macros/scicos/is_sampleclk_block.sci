function r=is_sampleclk_block(o)
// Copyright INRIA
//checks if the block o is a sampleClk block
r=%f
if o.model.sim(1)=='sampleclk' then
  r=%t
end
endfunction

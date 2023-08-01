function [ok]=look_for_text(gh_compound)
// Copyright INRIA
  ok=%f;
  for i=1:size(gh_compound.children,1);
    if gh_compound.children(i).type == "Text" then
      ok=%t;
    elseif gh_compound.children(i).type == "Compound" then
      [ok]=look_for_text(gh_compound.children(i))
    end
    if ok then return, end
  end
endfunction

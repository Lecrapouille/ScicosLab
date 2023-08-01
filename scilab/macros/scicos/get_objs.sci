function k=get_objs(gr_k,l)
// Copyright INRIA
//** semi empirical equation :)
//
// input : gr_k the corresponding index of the
//          not compiled element in the current
//          graphical structure
//
//        l the total number of graphic objects
//        in the current graphical structure
//        size(gh.children.children)
//
// output : k the index of the object in the
//         not compiled scicos structure 
//        (scs_m.objs)
//
  if exists('%scicos_with_grid') then
      k = l - gr_k ; //create a grid in the last children
                     //if %scicos_with_grid exists
  else
    k = l - gr_k + 1;
  end
endfunction

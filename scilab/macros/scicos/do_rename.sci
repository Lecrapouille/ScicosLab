function [scs_m,edited,ok]=do_rename(scs_m,pal_mode,dtitle)
// Copyright INRIA
  ok=%t
  if pal_mode then
    mess='Enter the new palette name'
  else
    mess='Enter the new diagram name'
  end

  %scs_help='Rename'
  //##new = dialog(mess,scs_m.props.title(1))
  [ok,new]=getvalue(mess,"Name",list("str",[1,1]),scs_m.props.title(1))
  //new = new(1)
  if ~ ok then edited=%f;return;end
  if new<>[] then
    if dtitle then
      drawtitle(scs_m.props)     //erase title
      scs_m.props.title(1) = new
      drawtitle(scs_m.props)     //draw title
    else
      scs_m.props.title(1) = new
    end
    edited = %t
  end
endfunction

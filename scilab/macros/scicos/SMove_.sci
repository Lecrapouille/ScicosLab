function SMove_()
// Copyright INRIA
  Cmenu=[]
  SelectSize=size (Select)
  SelectSize=SelectSize(1)
  if Select<>[] then
    if find(Select(:,2)<>curwin)<>[] then
      Select=[]
      Cmenu='SMove'
      return
    end
  end

  [scs_m]=do_move(%pt, scs_m)
  //TODO
  //if  SelectSize == 1
  //else
  //end
  %pt=[]

endfunction

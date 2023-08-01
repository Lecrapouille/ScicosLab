function param=scicos_txtedit(v1,v2,v3,v4,v5)
// Copyright INRIA
// Scicos text editor param structure
  if exists('typ','local')==0 then typ="", end
  if exists('ttitle','local')==0 then ttitle="", end
  if exists('head','local')==0 then head=[], end
  if exists('clos','local')==0 then clos=0, end

  param=mlist(['TxtEdit','typ','title','head','clos'],typ,ttitle,head,clos)
endfunction

function txt=addProduct(txt,para,nin,nout)
  ssign=ascii(para.Inputs)
  np=find(ssign==42);nnp=size(np,'*')
  nm=find(ssign==47);nnm=size(nm,'*')

  if nnp+nnm>1 then
    l=size(ssign,2)
    kill=setdiff(1:l,[np,nm])
    ssign(kill)=[]
    ssign=(ssign==42) - (ssign==47)
// must test Multiplication for different types of products
  elseif nnp==1 then
    ssign=1
  elseif nnm==1 then
    txt($+1)=ID+"%blk=instantiate_block('"INVBLK'")"
    warning('Product with one input. Use inverse block.')
  else
    ssign=evstr(para.Inputs)
  end
  txt($+1)=ID+"%blk=instantiate_block('"PRODUCT'")"
  exprs=sci2exp(ssign,0)
  txt($+1)=ID+"%blk=set_block_parameters(%blk,"+sci2exp(exprs,0)+")"
endfunction

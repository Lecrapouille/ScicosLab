function [ok,titlex,items,init]=load_scs_exprs_xml(fname,name,typ)
// Copyright METALAU - INRIA
//
// Load expression of a get_value dialog box
// in a simple xml format written by save_scs_exprs_xml.
//
// Inputs
//  - fname  : the path and name of the xml file (string)
//  - name   : the name of the scicos obj (string)
//  - typ    : list of the type of the items
//
// Outputs
//  - ok : a variable to say if the xml
//         file has been succesfully written (boolean)
//  - titlex : the title of the dialog box (vector of strings)
//  - items  : the label of the dialog box (vector of strings)
//  - init   : the value of the items (vector of strings)
//
// 28/07/09, A. Layec, Initial Rev

  //## open fname
  err = execstr('tt=mgetl(fname)','errcatch')

  if err<>0 then
    ok=%f
    titlex=[]
    items=[]
    init=[]
    message("File or directory write access denied.")
    return
  end

  //## load xml2cos utilities functions
  xml2cos=xml2cos

  //## get GUI name
  [ok,n_name,n_version]=get_gui_name_version(tt)
  if ~ok then
    message("Error parsing xml. Loading aborted.")
    return
  else
    if name<>n_name then
      ok=%f
      message("GUI name doesn''t match. Loading aborted.")
      return
    end
  end

  //## get GUI items
  [ierr,items,init]=get_gui_items(tt,typ)
  if ierr==1 then
    message("Error parsing xml. Loading aborted.")
    ok=%f
    return
  elseif ierr==2 then
    message("Error parsing xml. Number of items doesn''t Match. Loading aborted.")
    ok=%f
    return
  elseif ierr==3 then
    message("Error parsing xml. Type of items doesn''t Match. Loading aborted.")
    ok=%f
    return
  end

  //## get GUI titlex
  [ok,titlex]=get_gui_titlex(tt)
  if ~ok then
    message("Error parsing xml. Loading aborted.")
    return
  end
endfunction

function [ierr,items,init]=get_gui_items(tt,typ)
//## get and check items of the gui dialog box
  a=[]
  b=[]
  ierr=1
  items=[]
  init=[]

  //## parse
  for i=1:size(tt,'*')
    if strindex(tt(i),'<Exprs_item')<>[] then
      a=[a;i]
    end
    if strindex(tt(i),'</Exprs_item>')<>[] then
      b=[b;i]
    end
  end

  if a==[] | b==[] then return, end

  if lstsize(typ)/2<>size(a,1) | lstsize(typ)/2<>size(b,1) then
    ierr=2
    return
  end

  //## parse Exprs_item
  a_lab=[]; a_val=[];
  b_lab=[]; b_val=[];
  for i=1:lstsize(typ)/2
    for j=a(i):b(i)
      if strindex(tt(j),'<Exprs_label>')<>[] then
        a_lab=[a_lab;j]
      end
      if strindex(tt(j),'</Exprs_label>')<>[] then
        b_lab=[b_lab;j]
      end
      if strindex(tt(j),'<Exprs_value>')<>[] then
        a_val=[a_val;j]
      end
      if strindex(tt(j),'</Exprs_value>')<>[] then
        b_val=[b_val;j]
      end
    end
  end

  if ~isequal(size(a_lab,1),size(b_lab,1),...
              size(a_val,1),size(b_val,1),...
              lstsize(typ)/2) then
    ierr=2
    return
  end

  //## check type
  lst_typ=list()
  for j=a'
    exprs=strsubst(tt(j),'<Exprs_item','')
    exprs=strsubst(exprs,'>','')

    type_ind=strindex(exprs,'type')
    exprs_typ=part(exprs,type_ind(1)+4:length(exprs))
    a_typ=[]; b_typ=[];
    for j=1:length(exprs_typ)
      if part(exprs_typ,j) == '""' then
        if a_typ==[] then
          a_typ=j
        else
          b_typ=j
          break
        end
      end
    end
    exprs_typ=stripblanks(part(exprs_typ,a_typ+1:b_typ-1))
    lst_typ($+1)=exprs_typ

    size_ind=strindex(exprs,'size')
    exprs_siz=part(exprs,size_ind(1)+4:length(exprs))
    a_siz=[]; b_siz=[];
    for j=1:length(exprs_siz)
      if part(exprs_siz,j) == '""' then
        if a_siz==[] then
          a_siz=j
        else
          b_siz=j
          break
        end
      end
    end
    exprs_siz=part(exprs_siz,a_siz+1:b_siz-1)
    lst_typ($+1)=evstr(cos_subst(exprs_siz))
  end

  if ~isequal(typ,lst_typ) then
    ierr=3
    return
  end

  //## get label
  for i=1:size(a_lab,1)
    str_item=''
    for j=a_lab(i)+1:b_lab(i)-1
      str_item=str_item+cos_subst(stripblanks(tt(j)))+' '
    end
    items=[items
           part(str_item,1:length(str_item)-1)]
  end

  //## get value
  for i=1:size(a_val,1)
    str_val=''
    for j=a_val(i)+1:b_val(i)-1
      str_val=str_val+cos_subst(stripblanks(tt(j)))+' '
    end
    init=[init
          part(str_val,1:length(str_val)-1)]
  end

  ierr=0
endfunction

function [ok,titlex]=get_gui_titlex(tt)
//## get titlex of the gui dialog box
  a=[]
  b=[]
  ok=%t
  titlex=[]

  //## parse
  for i=1:size(tt,'*')
    if strindex(tt(i),'<titlex>')<>[] then
      a=i
    end
    if strindex(tt(i),'</titlex>')<>[] then
      b=i
      break
    end
  end

  if a==[] | b==[] then return, end

  for i=a+1:b-1
    //## preservation of indentation from save_scs_exprs_xml
    titlex=[titlex
            cos_subst(part(tt(i),1:length(tt(i))))]
  end
endfunction

function [ok,name,version]=get_gui_name_version(tt)
//## check and get name of the gui dialog box
  a=[]
  b=[]
  ok=%f
  str=[]
  name=[]
  version=[]

  //## parse
  for i=1:size(tt,'*')
    if strindex(tt(i),'<ScicosExprs Name=')<>[] then
      a=i
    end
    if strindex(tt(i),'</ScicosExprs>')<>[] then
      b=i
      break
    end
  end

  if a==[] | b==[] then return, end

  str=strsubst(tt(a),'<ScicosExprs','')
  str=stripblanks(strsubst(str,'>',''))

  ind_name=strindex(str,'Name')
  //ind_name=strindex(name,'name')
  ind_ver=strindex(str,'version')

  if ind_name==[] | ind_ver==[] then return, end

  //## get indicies of attributes
  ind_name=ind_name(1)
  ind_ver=ind_ver($)

  //## get name
  name=strsubst(part(str,1:ind_ver-1),'Name=','')
  //name=strsubst(part(str,1:ind_ver-1),'name=','')
  name=strsubst(name,'""','')
  name=stripblanks(name)

  //## get version
  version=strsubst(part(str,ind_ver:length(str)),'version=','')
  version=strsubst(version,'""','')
  version=stripblanks(version)

  //## remove xml special char
  name=cos_subst(name)
  version=cos_subst(version)

  ok=%t
endfunction

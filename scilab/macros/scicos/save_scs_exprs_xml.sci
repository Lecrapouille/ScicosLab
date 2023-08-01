function [ok]=save_scs_exprs_xml(fname,name,titlex,items,init,typ,widtyp,widopt)
// Copyright METALAU - INRIA
//
// Store expression of a get_value dialog box
// in a simple xml format.
//
// Inputs
//  - fname  : the path and name of the xml file (string)
//  - name   : the name of the scicos obj (string)
//  - titlex : the title of the dialog box (vector of strings)
//  - items  : the label of the dialog box (vector of strings)
//  - init   : the value of the items (vector of strings)
//  - typ    : list of the type of the items
//
// Outputs
//  - ok : a variable to say if the xml
//         file has been succesfully written (boolean)
//
// 28/07/09, A. Layec, Initial Rev

  //## open fname
  [u,err] = mopen(fname,'wb')
  if err<>0 then
    ok=%f
    message("File or directory write access denied")
    return
  end

  //## check rsh/lsh
  [lhs,rhs]=argn(0)
  if rhs<7 then
    widtyp=[]
    widopt=list()
    for i=1:size(items,'*')
      widtyp=[widtyp;'entry']
    end
  end

  //## load cos2xml utilities functions
  cos2xml=cos2xml

  //## head
  tt = ['<?xml version=""1.0"" encoding=""ISO-8859-1""?>'
        ''
        '<ScicosExprs Name=""'+name+'"" version=""'+get_scicos_version()+'"">']

  //## titlex
  tt = [tt
        '<titlex>']
  for i=1:size(titlex,'*')
    tt = [tt
          xml_subst(titlex(i))]
  end
  tt = [tt
        '</titlex>'
        '']

  //## items
  for i=1:size(items,'*')
    tt = [tt
          '<Exprs_item type=""'+typ(2*i-1)+'"" size=""'+xml_subst(sci2exp(typ(2*i)))+'"" widget=""'+widtyp(i)+'"">'
          '<Exprs_label>'
          xml_subst(items(i))
          '</Exprs_label>'
          '<Exprs_value>'
          xml_subst(init(i))
          '</Exprs_value>'
          '</Exprs_item>'
          '']
  end

  //## foot
  tt = [tt
        '</ScicosExprs>']

  mputl(tt,u)

  //##
  file('close',u)

  //##
  ok=%t
endfunction
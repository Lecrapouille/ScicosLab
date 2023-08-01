function [ok,modelicac,translator,xml2modelica]=Modelica_execs()
  ok=%f
  
  
  modelicac=pathconvert(SCI+'/bin/modelicac.exe',%f,%t)         
  translator=pathconvert(SCI+'/bin/translator.exe',%f,%t) 
  xml2modelica=pathconvert(SCI+'/bin/XML2Modelica.exe',%f,%t)
  ok =%t
  
//  
//  OS=getos() 
//  select OS 
//    case 'Windows' then 
//     modelicac=pathconvert(SCI+'/bin/modelicac.exe',%f,%t)         
//     translator=pathconvert(SCI+'/bin/translator.exe',%f,%t) 
//     xml2modelica=pathconvert(SCI+'/bin/XML2Modelica.exe',%f,%t)
//     ok =%t
//   case 'Linux' then 
//    modelicac=pathconvert(SCI+'/bin/modelicac',%f,%t)    
//    translator=pathconvert(SCI+'/bin/translator',%f,%t)
//    xml2modelica=pathconvert(SCI+'/bin/XML2Modelica',%f,%t)
//    ok =%t
//   case 'Darwin' then  // Mac
//    modelicac=pathconvert(SCI+'/bin/modelicac',%f,%t)    
//    translator=pathconvert(SCI+'/bin/translator_mac',%f,%t)
//    xml2modelica=pathconvert(SCI+'/bin/XML2Modelica_mac',%f,%t)
//    ok =%t
//  end
//
//  if ~ok then 
//    x_message(['The Modelica compiler is not available for the '+OS+' operating system'])
//    return
//  end
  
  if strindex(modelicac,' ')<>[] then modelicac='""'+modelicac+'""',end
  if strindex(translator,' ')<>[] then translator='""'+translator+'""',end
  if strindex(xml2modelica,' ')<>[] then xml2modelica='""'+xml2modelica+'""',end

  if (fileinfo(modelicac)==[])    then x_message(['Scilab cannot find the Modelica compiler:';modelicac]);ok=%f;return;end
  if (fileinfo(translator)==[])   then x_message(['Scilab cannot find the Modelica translator:';translator]);ok=%f;return;end
  if (fileinfo(xml2modelica)==[]) then x_message(['Scilab cannot find the XML to modelica convertor:';xml2modelica]);ok=%f;return;end

  endfunction


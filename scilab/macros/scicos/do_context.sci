function [context, ok] = do_context(context)
// Copyright INRIA

// clos = 0;
// //if context==[] then context=' ',end ; //** if the variable is empty put a blank space 
// textmp = context
// 
// while %t do
//    //** open a dialog window ; dialog() it is a wrapper of "x_dialog"
//    // rep = dialog([
// //               'You may enter here scilab instructions to define '   ;
// //               'symbolic parameters used in block definitions using' ;
// //               'Scilab instructions; comments are not allowed.'      ; //** now the comments ARE ALLOWED ! 
// //               ' '                                                   ;
// //               'These instructions are evaluated once confirmed, i.e.,you';
// //               'click on OK, by Eval and every time diagram is loaded. '], context) ;
// 
//     [rep,Quit] = scsedit(textmp,clos);
// 
//     if clos==1 then
//        break;
//     end
// 
//   //** "rep" is a colum vector of strings 
//   if rep==[] | Quit == 1 then //** in case of no entry  
//     ok = %f
//     break;
//   else
//     context = rep //** if some text is typed //**
//     textmp = rep
//     ok = %t
//     clos = 1
//   end
// end

endfunction

function [tree]=sci_sign(tree)
// File generated from sci_PROTO4.g: PLEASE DO NOT EDIT !
// Copyright INRIA
// M2SCI function
// Conversion function for Matlab sign()
// Input: tree = Matlab funcall tree
// Ouput: tree = Scilab equivalent for tree
// V.C.

tree.name="sign"

A=getrhs(tree)
A=convert2double(A)
tree.rhs=Rhs(A)

tree.lhs(1).dims=A.dims
tree.lhs(1).type=A.type
endfunction

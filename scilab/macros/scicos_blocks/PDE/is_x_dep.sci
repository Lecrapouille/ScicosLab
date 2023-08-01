function r=is_x_dep(expr)
   deff('foo()',expr)
   m=macrovar(foo)
   r=~isempty(m(3)=="x")
endfunction
function DisableAllMenus()
// Copyright INRIA
  %ws=intersect(winsid(),[inactive_windows(2);curwin]')
  %men=menus(1)
  for %w=%ws
    for k=2:size(%men,'*')
     unsetmenu(%w,%men(k))
    end  // Suppose here all windows have similar menus
  end
  TCL_EvalStr('catch {.palettes.note.f.t state disabled}')
  TCL_EvalStr('catch {bind .palettes.note.f.t <B1-Motion> '"'"}')
endfunction

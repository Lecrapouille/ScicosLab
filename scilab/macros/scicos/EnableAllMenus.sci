function EnableAllMenus()
// Copyright INRIA
  %ws=intersect(winsid(),[inactive_windows(2);curwin]')
  %men=menus(1)
  for %w=%ws
    In=find
    for k=2:size(%men,'*')
      // This is dangerous because we assume  Main_Scicos_window is the
      // main diagram. This main no longer be true in the future
//      if Main_Scicos_window==%w | %men(k)<>'Simulate' then
//      if Main_Scicos_window==%w  then
	setmenu(%w,%men(k))
//      end
    end  // Suppose here all windows have similar menus
  end
  TCL_EvalStr('catch {.palettes.note.f.t state !disabled}')
  TCL_EvalStr('catch {bind .palettes.note.f.t <B1-Motion> '"MotionTree %W %x %y'"}')
endfunction

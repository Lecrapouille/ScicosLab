function scs_m = set_diagram_bg_color(scs_m,dg_color)
  if size(dg_color,'*') <> 1 then 
    cmap=get(sdf(),"color_map")
    dif=abs(cmap-ones(size(cmap,1),1)*dg_color)*[1;1;1]
    [ju,dg_color]=min(dif);
  end
  scs_m.props.options.Background(1)=dg_color;
endfunction

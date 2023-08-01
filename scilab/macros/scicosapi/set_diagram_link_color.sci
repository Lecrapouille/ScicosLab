function scs_m = set_diagram_link_color(scs_m,colors)
  if size(colors,'c') <> 1 then 
    cmap=get(sdf(),"color_map")
    // cmap=xget("colormap")
    dif=abs(cmap-ones(size(cmap,1),1)*colors(1,:)*[1;1;1]);
    [ju,color1]=min(dif);
    dif=abs(cmap-ones(size(cmap,1),1)*colors(2,:)*[1;1;1]);
    [ju,color2]=min(dif);
    colors=[color1;color2];
  end
  scs_m.props.options.Link=[colors(1),colors(2)];
endfunction

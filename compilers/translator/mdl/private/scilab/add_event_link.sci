function [scs_m,obj_num] = add_event_link(scs_m,from,to,points)

 rhs=argn(2)  
 if rhs<4 then points=[],end

    o1 = scs_m.objs(from(1))
    graphics1=o1.graphics
    orig  = graphics1.orig
    sz    = graphics1.sz
    theta = graphics1.theta
    io    = graphics1.flip
    op    = graphics1.pout
    impi  = graphics1.pin
    cop   = graphics1.peout
    [xout,yout,typout]=getoutputs(o1)

    idx = find(typout==-1)
    xout=xout(idx);    yout=yout(idx);    typout=typout(idx)

    k=from(2)
    xo=xout(k);yo=yout(k);typo=typout(k)

    xxx=rotate([xo;yo],...
               theta*%pi/180,...
               [orig(1)+sz(1)/2;orig(2)+sz(2)/2]);
    xo=xxx(1);
    yo=xxx(2);


    // Check if selected port is already connected and get port type ('in' or 'out')

      port_number=k
      if cop(port_number)<>0 then
          error('Selected port is already connected.')
      end
      typpfrom='out'


    from_node=[from,0]
    xl=xo
    yl=yo

 
    kto = to(1)
    o2 = scs_m.objs(kto);
    graphics2 = o2.graphics;
    orig  = graphics2.orig
    sz    = graphics2.sz
    theta = graphics2.theta
    ip    = graphics2.pin
    impo  = graphics2.pout
    cip   = graphics2.pein
    [xin,yin,typin] = getinputs(o2)

    idx = find(typin==-1)
    xin=xin(idx);    yin=yin(idx);    typin=typin(idx)

      k = to(2)
      xi = xin(k); yi = yin(k); typi = typin(k);

      xxx=rotate([xi;yi],...
                 theta*%pi/180,...
                 [orig(1)+sz(1)/2;orig(2)+sz(2)/2]);
      xi=xxx(1);
      yi=xxx(2);

        port_number = k ;
        if cip(port_number)<>0 then
	   error('Selected port is already connected.')
        end

  clr=default_color(typo)
  typ=typo
  to_node=[to,1]

  xl = [cumsum([xo;points(:,1)]')';xi];  yl = [cumsum([yo;points(:,2)]')';yi]
  lk=scicos_link(xx=xl,yy=yl,ct=[clr,typ],from=from_node,to=to_node)
  if typ==3 then
    lk.thick=[2 2]
  end

  scs_m.objs($+1) = lk ;

  obj_num=length(scs_m.objs)

  //update connected blocks
 
  outin=['out','in']

  scs_m.objs(from_node(1))=mark_prt(scs_m.objs(from_node(1)),from_node(2),outin(from_node(3)+1),typ,obj_num)
  scs_m.objs(to_node(1))=mark_prt(scs_m.objs(to_node(1)),to_node(2),outin(to_node(3)+1),typ,obj_num)

endfunction

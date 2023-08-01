function [scs_m,obj_num] = add_implicit_link(scs_m,from,to,points)
 rhs=argn(2)  
 if rhs<4 then points=[],end
 if size(from,2)<>3 then error("2nd argument must be of size 3."),end
 if size(to,2)<>3 then error("3rd argument must be of size 3."),end

    o1 = scs_m.objs(from(1))
    graphics1=o1.graphics
    orig  = graphics1.orig
    sz    = graphics1.sz
    theta = graphics1.theta
    io    = graphics1.flip
    op    = graphics1.pout
    impi  = graphics1.pin
    cop   = graphics1.peout
    if from(3)==0 then
      [xout,yout,typout]=getoutputs(o1)
      xp=op
    else
      [xout,yout,typout]=getinputs(o1)
      xp=impi
    end

 //   idx = find(typout==2)
 //   xout=xout(idx);    yout=yout(idx);    typout=typout(idx)

    k=from(2)
    xo=xout(k);yo=yout(k);typo=typout(k)

    xxx=rotate([xo;yo],...
               theta*%pi/180,...
               [orig(1)+sz(1)/2;orig(2)+sz(2)/2]);
    xo=xxx(1);
    yo=xxx(2);


    // Check if selected port is already connected and get port type ('in' or 'out')

      port_number=k
      if xp(port_number)<>0 then
          pause,error('Selected port: '+string(k)+' of block '+string(from(1))+' is already connected.')
      end
      typpfrom='out'


    from_node=[from]
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
    if to(3)==1 then
      [xin,yin,typin] = getinputs(o2)
      xp=ip
    else
      [xin,yin,typin] = getoutputs(o2)
      xp=impo
    end

//    idx = find(typin==2)
//    xin=xin(idx);    yin=yin(idx);    typin=typin(idx)

      k = to(2)
      xi = xin(k); yi = yin(k); typi = typin(k);

      xxx=rotate([xi;yi],...
                 theta*%pi/180,...
                 [orig(1)+sz(1)/2;orig(2)+sz(2)/2]);
      xi=xxx(1);
      yi=xxx(2);

        port_number = k ;
        if xp(port_number)<>0 then
	   pause,error('Selected port: '+string(k)+' of block '+string(to(1))+' is already connected.')
        end

  clr=default_color(typo)
  typ=typo
  to_node=[to]

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

function standard_draw_ports(o)
// Copyright INRIA

  nin = size(o.model.in,1);
  nout= size(o.model.out,1);
  inporttype  = o.graphics.in_implicit
  outporttype = o.graphics.out_implicit
  clkin  = size(o.model.evtin,1);
  clkout = size(o.model.evtout,1);

 [orig,sz,orient]=(o.graphics.orig,o.graphics.sz,o.graphics.flip)
 
  // xset('pattern',default_color(0));
  // xset('thickness',1)
  // draw input/output ports
  //------------------------

//** --------- For the implict mode only ----------
//if o.model.sim=='inimpl'  then pause, end
//** -----------------------------------------------
  
  
  if orient then  //standard orientation
    // set port shape
    out1=[ 0  -1
	   1   0
	   0   1
	   0  -1]*diag([xf/7,yf/14])
    
    in1= [-1  -1
	   0   0
	  -1   1
	  -1  -1]*diag([xf/7,yf/14])
    
    out2=[ 0  -1
	   1  -1
	   1   1
	   0   1]*diag([xf/7,yf/14])
    
    in2= [-1  -1
	   0  -1
	   0   1
	  -1   1]*diag([xf/7,yf/14])
    dy=sz(2)/(nout+1)
  
    //** xset('pattern',default_color(1))

    for k=1:nout
    
     if outporttype==[] then
        	xfpoly( out1(:,1)+ones(4,1)*(orig(1)+sz(1)), out1(:,2)+ones(4,1)*(orig(2)+sz(2)-dy*k),default_color(1))
      else
         if outporttype(k)=='E' then
	            xfpoly(out1(:,1)+ones(4,1)*(orig(1)+sz(1)),out1(:,2)+ones(4,1)*(orig(2)+sz(2)-dy*k),default_color(1))
          elseif outporttype(k)=='I' then
	            xpoly(out2(:,1)+ones(4,1)*(orig(1)+sz(1)), out2(:,2)+ones(4,1)*(orig(2)+sz(2)-dy*k),"lines",default_color(1))
          elseif outporttype(k)=='B' then
	  	    xfpoly(out1(:,1)+ones(4,1)*(orig(1)+sz(1)),out1(:,2)+ones(4,1)*(orig(2)+sz(2)-dy*k),default_color(3))
         end
     end
     
    // gh_e = gce();
    // gh_e.thickness = 1 ;
    // gh_e.foreground = default_color(1) 
  
  
    end //** end of for 

    dy=sz(2)/(nin+1)

    for k=1:nin
    
      if inporttype==[] then
          xfpoly(in1(:,1)+ones(4,1)*orig(1), in1(:,2)+ones(4,1)*(orig(2)+sz(2)-dy*k),1)
      else
          if inporttype(k)=='E' then
	             xfpoly(in1(:,1)+ones(4,1)*orig(1), in1(:,2)+ones(4,1)*(orig(2)+sz(2)-dy*k),default_color(1))
          elseif inporttype(k)=='I' then
	             xfpoly(in2(:,1)+ones(4,1)*orig(1), in2(:,2)+ones(4,1)*(orig(2)+sz(2)-dy*k),default_color(1))
          elseif inporttype(k)=='B' then
	             xfpoly(in1(:,1)+ones(4,1)*orig(1), in1(:,2)+ones(4,1)*(orig(2)+sz(2)-dy*k),default_color(3))	
          end
      end

    // gh_e = gce();
    // gh_e.thickness = 1 ;
    // gh_e.foreground = default_color(1) 
    
    
    end //** end of for 
  
  else //tilded orientation
      out1=[0  -1
	   -1   0
	    0   1
	    0  -1]*diag([xf/7,yf/14])
      
      in1= [1  -1
	    0   0
	    1   1
	    1  -1]*diag([xf/7,yf/14])
      
      out2=[0  -1
	   -1  -1
	   -1   1
	    0   1]*diag([xf/7,yf/14])
      
      in2= [1  -1
	    0  -1
	    0   1
	    1   1]*diag([xf/7,yf/14])

      
      dy=sz(2)/(nout+1)
    
      // xset('pattern',default_color(1))
      for k=1:nout
      
         if outporttype==[] then
                xfpoly(out1(:,1)+ones(4,1)*orig(1)-1, out1(:,2)+ones(4,1)*(orig(2)+sz(2)-dy*k),default_color(1))
         else
	            if outporttype(k)=='E' then
	                 xfpoly(out1(:,1)+ones(4,1)*orig(1)-1, out1(:,2)+ones(4,1)*(orig(2)+sz(2)-dy*k),default_color(1))
	            elseif outporttype(k)=='I' then
	                xpoly(out2(:,1)+ones(4,1)*orig(1)-1, out2(:,2)+ones(4,1)*(orig(2)+sz(2)-dy*k),"lines",default_color(1))
	            elseif outporttype(k)=='B' then
 	                 xfpoly(out1(:,1)+ones(4,1)*orig(1)-1, out1(:,2)+ones(4,1)*(orig(2)+sz(2)-dy*k),default_color(3))  
	            end
         end
      
      //gh_e = gce();
      //gh_e.thickness = 1 ;
     // gh_e.foreground = default_color(1) 
      
      end //** end of for 
      
      dy=sz(2)/(nin+1)
      for k=1:nin
          if inporttype==[] then
                xfpoly(in1(:,1)+ones(4,1)*(orig(1)+sz(1))+1, in1(:,2)+ones(4,1)*(orig(2)+sz(2)-dy*k),default_color(1))
          else
	            if inporttype(k)=='E' then
	                 xfpoly(in1(:,1)+ones(4,1)*(orig(1)+sz(1))+1, in1(:,2)+ones(4,1)*(orig(2)+sz(2)-dy*k),default_color(1))
	            elseif inporttype(k)=='I' then
	                 xfpoly(in2(:,1)+ones(4,1)*(orig(1)+sz(1))+1, in2(:,2)+ones(4,1)*(orig(2)+sz(2)-dy*k),default_color(1))
	            elseif inporttype(k)=='B' then
	                 xfpoly(in1(:,1)+ones(4,1)*(orig(1)+sz(1))+1, in1(:,2)+ones(4,1)*(orig(2)+sz(2)-dy*k),default_color(3)) 
	            end
          end
  
      end //** end of for 
      
     // gh_e = gce();
     // gh_e.thickness = 1 ;
     // gh_e.foreground = default_color(1) 

  end
  
  //**----------------------------------------------------------------------------------------------------
  // draw input/output clock ports
  //------------------------
  // set port shape

  out= [-1  0
	 0 -1
	 1  0
	-1  0]*diag([xf/14,yf/7])


  in= [-1  1
        0  0
        1  1
       -1  1]*diag([xf/14,yf/7])


  dx=sz(1)/(clkout+1)
  //** xset('pattern',default_color(-1))
  
  for k=1:clkout
     xfpoly(out(:,1)+ones(4,1)*(orig(1)+k*dx), out(:,2)+ones(4,1)*orig(2),1)
     gh_e = gce();
     // gh_e.thickness = 1 ;
     gh_e.foreground = default_color(-1); //** non so perche' ...
     gh_e.background = default_color(-1); //**      ...  ma funziona :)
     // pause
  end
  
  dx=sz(1)/(clkin+1)
  for k=1:clkin
    xfpoly(in(:,1)+ones(4,1)*(orig(1)+k*dx), in(:,2)+ones(4,1)*(orig(2)+sz(2)),1);
    gh_e = gce();
    // gh_e.thickness = 1 ;
    gh_e.foreground = default_color(-1);
    gh_e.background = default_color(-1);
  end

//** xset('pattern',default_color(0))

endfunction 

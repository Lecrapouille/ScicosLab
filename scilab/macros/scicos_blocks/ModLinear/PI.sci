function [x,y,typ]=PI(job,arg1,arg2)
// Copyright INRIA
// the automatically generated interface block for Modelica PI.mo model
//   - avec un dialogue de saisie de parametre
x=[];y=[];typ=[];
select job
case 'plot' then
  standard_draw(arg1,%f,PI_draw_ports)
case 'getinputs' then
  [x,y,typ]=PI_inputs(arg1)
case 'getoutputs' then
  [x,y,typ]=PI_outputs(arg1)
case 'getorigin' then
  [x,y]=standard_origin(arg1)
case 'set' then
  x=arg1;
  graphics=arg1.graphics;exprs=graphics.exprs
  model=arg1.model;
x=arg1
exprs=x.graphics.exprs
while %t do
  [ok,k,T,exprs]=getvalue(["Set PI block parameters:";"";"k: Gain";"T: Time Constant (s)"],["k";"T"],list("vec",1,"vec",1),exprs)
  if ~ok then break,end
  x.model.equations.parameters(2)=list(k,T)
  x.graphics.exprs=exprs
  break
end
 case 'define' then      
ModelName="PI"
PrametersValue=[]
ParametersName=["k";"T"]
model=scicos_model()                  
Typein=[];Typeout=[];MI=[];MO=[]       
P=[-5,50,2,0;105,50,-2,0]
PortName=["RealInputx";"RealOutputx"]
for i=1:size(P,'r')                                             
  if P(i,3)==1  then  Typein= [Typein; 'E'];MI=[MI;PortName(i)];end
  if P(i,3)==2  then  Typein= [Typein; 'I'];MI=[MI;PortName(i)];end
  if P(i,3)==-1 then  Typeout=[Typeout;'E'];MO=[MO;PortName(i)];end
  if P(i,3)==-2 then  Typeout=[Typeout;'I'];MO=[MO;PortName(i)];end
end
model=scicos_model()
mo=modelica()
model.sim=ModelName;
mo.inputs=MI;
mo.outputs=MO;
model.rpar=PrametersValue;
mo.parameters=list(ParametersName,PrametersValue,zeros(ParametersName));
exprs=["1";"1"]
gr_i=["";"if orient then";"  xpolys(orig(1)+[0.1,0.05;0.1,0.91]*sz(1),orig(2)+[0.89,0.1;0.05,0.1]*sz(2),[3,3])";"  xset(''thickness'',2);";"  xpolys(orig(1)+[0.1;0.1;0.8]*sz(1),orig(2)+[0.1;0.4;0.9]*sz(2),1)";"  xset(''color'',12);";"  xstring(orig(1)+0.47*sz(1),orig(2)+0.43*sz(2),""PI"")";"  xset(''color'',[2,2])";"  xfpolys(orig(1)+[0.1,0.97;0.06,0.86;0.14,0.86;0.1,0.97]*sz(1),orig(2)+[0.97,0.1;0.86,0.14;0.86,0.06;0.97,0.1]*sz(2),[1,1])";"  xset(''thickness'',1);";"  xpolys(orig(1)+[0;0;1;1;0]*sz(1),orig(2)+[1;0;0;1;1]*sz(2),3)";"else";"  xpolys(orig(1)+[0.9,0.95;0.9,0.09]*sz(1),orig(2)+[0.89,0.1;0.05,0.1]*sz(2),[3,3])";"  xset(''thickness'',2);";"  xpolys(orig(1)+[0.9;0.9;0.2]*sz(1),orig(2)+[0.1;0.4;0.9]*sz(2),1)";"  xset(''color'',12);";"  xstring(orig(1)+sz(1)-(0.47*sz(1)),orig(2)+0.43*sz(2),""PI"")";"  xset(''color'',[2,2])";"  xfpolys(orig(1)+[0.9,0.03;0.94,0.14;0.86,0.14;0.9,0.03]*sz(1),orig(2)+[0.97,0.1;0.86,0.14;0.86,0.06;0.97,0.1]*sz(2),[1,1])";"  xset(''thickness'',1);";"  xpolys(orig(1)+[1;1;0;0;1]*sz(1),orig(2)+[1;0;0;1;1]*sz(2),3)";"end"]
model.blocktype='c'                              
model.dep_ut=[%f %t]                               
mo.model=ModelName                                 
model.equations=mo                                 
model.in=ones(size(MI,'*'),1)                    
model.out=ones(size(MO,'*'),1)                   
x=standard_define([2,2],model,exprs,list(gr_i,0))  
x.graphics.in_implicit=Typein;                     
x.graphics.out_implicit=Typeout;                   
end
endfunction
//=========================
function PI_draw_ports(o)
  [orig,sz,orient]=(o.graphics.orig,o.graphics.sz,o.graphics.flip)
  xset('pattern',default_color(0))
  // draw input/output ports
  //------------------------
  // [x_in_Icon,y_in_Icon,type(2=imp_in/-2:imp_out/1=exp_input/-1_exp_output),orientation(degree)]
  P=[-5,50,2,0;105,50,-2,0]

  //============================
  // setting the input/ outputs and direction
  // implicit port: if it's located in the right it's output and while,
  // else black
  // explicit ports:
    
  in=  [-1 -1; 1  0;-1  1; -1 -1; -1 0]*diag([xf/28,yf/28]) ;// left_triangle  
  out= [-1 -1; 1  0;-1  1; -1 -1;  1 0]*diag([xf/28,yf/28]) ;// downward_triangle  
  in2= [-1 -1; 1 -1; 1  1; -1  1; -1 -1; 0 0]*diag([xf/28,yf/28])
  out2=[ 1  1;-1  1;-1 -1;  1 -1;  1  1; 0 0]*diag([xf/28,yf/28])
  
  xset('pattern',default_color(1))           
  xset('thickness',1)   
   
  if orient then
    for i=1:size(P,'r')      
      theta=P(i,4)*%pi/180;
      R=[cos(theta),sin(theta);sin(-theta),cos(theta)];
      
      if P(i,3)==1 then // explicit
	inR=in*R;
	xfpoly(orig(1)+inR(:,1)+P(i,1)*sz(1)/100,orig(2)+inR(:,2)+P(i,2)*sz(2)/100,1)      
      end
      
      if  P(i,3)==-1 then
	outR=out*R;
	xfpoly(orig(1)+outR(:,1)+P(i,1)*sz(1)/100,orig(2)+outR(:,2)+P(i,2)*sz(2)/100,1)      	  
      end  
      
      if P(i,3)==2 then  // deciding the port's color: black, if x<sz(1)/2 else white.
	in2R=in2*R; 			
	xfpoly(orig(1)+in2R(:,1)+P(i,1)*sz(1)/100,orig(2)+  in2R(:,2)+P(i,2)*sz(2)/100,1)	
      end
      
      if P(i,3)==-2 then  // deciding the port's color: black, if x<sz(1)/2 else white.
	out2R=out2*R;
	xpoly(orig(1)+out2R(:,1)+P(i,1)*sz(1)/100,orig(2)+  out2R(:,2)+P(i,2)*sz(2)/100, 'lines',1)	
      end
    end  
  else
    for i=1:size(P,'r')     
      theta=P(i,4)*%pi/180;
      R=[cos(theta),sin(theta);sin(-theta),cos(theta)];
      
      if P(i,3)==1 then // explicit
	inR=in*R;
	xfpoly(orig(1)+sz(1)-inR(:,1)-P(i,1)*sz(1)/100,orig(2)+inR(:,2)+P(i,2)*sz(2)/100,1)      
      end
      if P(i,3)==-1 then // explicit
	outR=out*R;
	xfpoly(orig(1)+sz(1)-outR(:,1)-P(i,1)*sz(1)/100,orig(2)+outR(:,2)+P(i,2)*sz(2)/100,1)      
      end
      
      if P(i,3)==2 then  // deciding the port's color: black, if x<sz(1)/2 else white.
	 in2R=in2*R; 			
          xfpoly(orig(1)+sz(1)-in2R(:,1)-P(i,1)*sz(1)/100,orig(2)+  in2R(:,2)+P(i,2)*sz(2)/100,1)	
      end
      if P(i,3)==-2 then  // deciding the port's color: black, if x<sz(1)/2 else white.
	out2R=out2*R;
	xpoly(orig(1)+sz(1)-out2R(:,1)-P(i,1)*sz(1)/100,orig(2)+  out2R(:,2)+P(i,2)*sz(2)/100, 'lines',1)
      end
    end          
  end
endfunction 
//=========================
function [x,y,typ]=PI_inputs(o)
// Copyright INRIA
  xf=60
  yf=40
  [orig,sz,orient]=(o.graphics.orig,o.graphics.sz,o.graphics.flip)
  //[orig,sz,orient]=o(2)(1:3);
  inp=size(o.model.in,1);clkinp=size(o.model.evtin,1);
  
  // [x_in_Icon,y_in_Icon,type(2=imp/1=exp_input/-1_exp_output),orientation(degree)]
  P=[-5,50,2,0;105,50,-2,0]
  in=  [-1 -1; 1  0;-1  1; -1 -1; -1 0]*diag([xf/28,yf/28]) ;// left_triangle  
  out= [-1 -1; 1  0;-1  1; -1 -1;  1 0]*diag([xf/28,yf/28]) ;// downward_triangle  
  in2= [-1 -1; 1 -1; 1  1; -1  1; -1 -1; 0 0]*diag([xf/28,yf/28])
  out2=[ 1  1;-1  1;-1 -1;  1 -1;  1  1; 0 0]*diag([xf/28,yf/28])
  
  x=[];y=[];typ=[]
  if orient then
    for i=1:size(P,'r')   
      theta=P(i,4)*%pi/180;
      R=[cos(theta),sin(theta);sin(-theta),cos(theta)];
      if (P(i,3))==1 then // explicit_input
	inR=in($,:)*R;
         x=[x,orig(1)+inR(:,1)+P(i,1)*sz(1)/100];
	 y=[y,orig(2)+inR(:,2)+P(i,2)*sz(2)/100];
	 typ=[typ,1];
      end
      if(P(i,3)==2) then  // implicit
	in2R=in2($,:)*R; 
	x=[x,orig(1)+in2R(:,1)+P(i,1)*sz(1)/100];// Black
	y=[y,orig(2)+in2R(:,2)+P(i,2)*sz(2)/100];
	typ=[typ,2];
      end
    end      
  else
    for i=1:size(P,'r')     
      theta=P(i,4)*%pi/180;
     R=[cos(theta),sin(theta);sin(-theta),cos(theta)];
      if (P(i,3))==1 then // explicit_input
	inR=in($,:)*R;
         x=[x,orig(1)+sz(1)-inR(:,1)-P(i,1)*sz(1)/100];
	 y=[y,orig(2)+inR(:,2)+P(i,2)*sz(2)/100];
	 typ=[typ,1];
      end
      if(P(i,3)==2) then  // implicit
	in2R=in2($,:)*R; 
	x=[x,orig(1)+sz(1)-in2R(:,1)-P(i,1)*sz(1)/100];
	y=[y,orig(2)+in2R(:,2)+P(i,2)*sz(2)/100];
	typ=[typ,2];
      end
    end            
  end
  
 
endfunction
//=========================
function [x,y,typ]=PI_outputs(o)
// Copyright INRIA
  xf=60
  yf=40
  [orig,sz,orient]=(o.graphics.orig,o.graphics.sz,o.graphics.flip)
  out=size(o.model.out,1);clkout=size(o.model.evtout,1);
  P=[-5,50,2,0;105,50,-2,0]
 
  in=  [-1 -1; 1  0;-1  1; -1 -1; -1 0]*diag([xf/28,yf/28]) ;// left_triangle  
  out= [-1 -1; 1  0;-1  1; -1 -1;  1 0]*diag([xf/28,yf/28]) ;// downward_triangle  
  in2= [-1 -1; 1 -1; 1  1; -1  1; -1 -1; 0 0]*diag([xf/28,yf/28])
  out2=[ 1  1;-1  1;-1 -1;  1 -1;  1  1; 0 0]*diag([xf/28,yf/28])
  
  x=[];y=[];typ=[];
  if orient then
    for i=1:size(P,'r')     
      theta=P(i,4)*%pi/180;
      R=[cos(theta),sin(theta);sin(-theta),cos(theta)];
      if (P(i,3))==-1 then // explicit_output
	outR=out($,:)*R;
	x=[x,orig(1)+outR(:,1)+P(i,1)*sz(1)/100];
	y=[y,orig(2)+outR(:,2)+P(i,2)*sz(2)/100];
	typ=[typ,1];
      end 
      if(P(i,3)==-2) then  // implicit
	out2R=out2($,:)*R;
	x=[x,orig(1)+out2R(:,1)+P(i,1)*sz(1)/100];
	y=[y,orig(2)+out2R(:,2)+P(i,2)*sz(2)/100];
	typ=[typ,2];		
      end	      
    end      
  else
    for i=1:size(P,'r')     
      theta=P(i,4)*%pi/180;
      R=[cos(theta),sin(theta);sin(-theta),cos(theta)];
      if (P(i,3))==-1 then // explicit_output
	outR=out($,:)*R;
	x=[x,orig(1)+sz(1)-outR(:,1)-P(i,1)*sz(1)/100];
	y=[y,orig(2)+outR(:,2)+P(i,2)*sz(2)/100];
	typ=[typ,1];
      end
      if(P(i,3)==-2) then  // implicit
	out2R=out2($,:)*R;
	x=[x,orig(1)+sz(1)-out2R(:,1)-P(i,1)*sz(1)/100];
	y=[y,orig(2)+out2R(:,2)+P(i,2)*sz(2)/100];
	typ=[typ,2];
      end
    end            
  end
  
endfunction

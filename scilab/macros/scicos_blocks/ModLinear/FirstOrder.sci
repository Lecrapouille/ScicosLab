function [x,y,typ]=FirstOrder(job,arg1,arg2)
// Copyright INRIA
// the automatically generated interface block for Modelica FirstOrder.mo model
//   - avec un dialogue de saisie de parametre
x=[];y=[];typ=[];
select job
case 'plot' then
  standard_draw(arg1,%f,FirstOrder_draw_ports)
case 'getinputs' then
  [x,y,typ]=FirstOrder_inputs(arg1)
case 'getoutputs' then
  [x,y,typ]=FirstOrder_outputs(arg1)
case 'getorigin' then
  [x,y]=standard_origin(arg1)
case 'set' then
  x=arg1;
  graphics=arg1.graphics;exprs=graphics.exprs
  model=arg1.model;
x=arg1
exprs=x.graphics.exprs
while %t do
  [ok,k,T,y_start,exprs]=getvalue(["Set FirstOrder block parameters:";
                                   "";
                                   "k      : Gain: TF(s)=K/(T*s+1)";
                                   "T      : Time Constant";
                                   "y_start: Initial or guess value of output (= state)"],...
                                   ["k";"T";"y_start"],...
                                   list("vec",1,"vec",1,"vec",1),exprs)
  if ~ok then break,end
  x.model.equations.parameters(2)=list(k,T,y_start)
  x.graphics.exprs=exprs
  break
end
 case 'define' then      
ModelName="FirstOrder"
PrametersValue=[1;1;0]
ParametersName=["k";"T";"y_start"]
model=scicos_model()                  
Typein=[];Typeout=[];MI=[];MO=[]       
P=[-5,50,2,0;105,50,2,0]
PortName=["u";"y"]
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
exprs=["1";"1";"0"]
gr_i=["txt=""PT1"";";
      "rectstr=stringbox(txt,orig(1)+0.2*sz(1),orig(2)+0.2*sz(2),0,1,1);";
      "if ~exists(""%zoom"") then %zoom=1, end;";
      "w=(rectstr(1,3)-rectstr(1,2))*%zoom;";
      "h=(rectstr(2,2)-rectstr(2,4))*%zoom;";
      ""
      "xpolys(orig(1)+[0;0;1;1;0]*sz(1),orig(2)+[1;0;0;1;1]*sz(2),3)";
      ""
      "if orient then";
      "  xpolys(orig(1)+[0.1,0.05;0.1,0.91]*sz(1),orig(2)+[0.89,0.1;0.05,0.1]*sz(2),[3,3])";
      "  xpolys(orig(1)+[0.1;0.15;0.2;0.25;0.3;0.35;0.4;0.45;0.5;0.55;0.6;0.65;0.7;0.75;0.8;0.85;0.9]*sz(1),"+...
        "orig(2)+[0.1;0.27445;0.4021;0.4954565;0.56375;0.61375;0.6503;0.67705;0.69665;0.71095;0.72145;0.7291;0.7347;0.7388;0.7418;0.744;0.7456]*sz(2),1)";
      "  xstringb(orig(1)+0.2*sz(1),orig(2)+0.2*sz(2),txt,w,h,""fill"");";
      "  xset(''color'',[2,2]);";
      "  xfpolys(orig(1)+[0.1;0.06;0.14;0.1;0.1]*sz(1),orig(2)+[0.95;0.84;0.84;0.94;0.95]*sz(2),1)";
      "  xfpolys(orig(1)+[0.95;0.84;0.84;0.95]*sz(1),orig(2)+[0.1;0.14;0.06;0.1]*sz(2),1)";
      "else";
      "  xpolys(orig(1)+[0.9,0.05;0.9,0.91]*sz(1),orig(2)+[0.89,0.1;0.05,0.1]*sz(2),[3,3])";
      "  xpolys(orig(1)+[0.9;0.85;0.8;0.75;0.7;0.65;0.6;0.55;0.5;0.45;0.4;0.35;0.3;0.25;0.2;0.15;0.1]*sz(1),"+...
        "orig(2)+[0.1;0.27445;0.4021;0.4954565;0.56375;0.61375;0.6503;0.67705;0.69665;0.71095;0.72145;0.7291;0.7347;0.7388;0.7418;0.744;0.7456]*sz(2),1)";
      "  xstringb(orig(1)+0.2*sz(1),orig(2)+0.2*sz(2),txt,w,h,""fill"");";
      "  xset(''color'',[2,2]);";
      "  xfpolys(orig(1)+[0.9;0.94;0.86;0.9;0.9]*sz(1),orig(2)+[0.95;0.84;0.84;0.94;0.95]*sz(2),1)";
      "  xfpolys(orig(1)+[0.05;0.16;0.16;0.05]*sz(1),orig(2)+[0.1;0.14;0.06;0.1]*sz(2),1)";
      "end"]
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
function FirstOrder_draw_ports(o)
  [orig,sz,orient]=(o.graphics.orig,o.graphics.sz,o.graphics.flip)
  xset('pattern',default_color(0))
  // draw input/output ports
  //------------------------
  // [x_in_Icon,y_in_Icon,type(2=imp_in/-2:imp_out/1=exp_input/-1_exp_output),orientation(degree)]
  P=[-5,50,2,0;105,50,2,0]

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
function [x,y,typ]=FirstOrder_inputs(o)
// Copyright INRIA
  xf=60
  yf=40
  [orig,sz,orient]=(o.graphics.orig,o.graphics.sz,o.graphics.flip)
  //[orig,sz,orient]=o(2)(1:3);
  inp=size(o.model.in,1);clkinp=size(o.model.evtin,1);
  
  // [x_in_Icon,y_in_Icon,type(2=imp/1=exp_input/-1_exp_output),orientation(degree)]
  P=[-5,50,2,0;105,50,2,0]
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
function [x,y,typ]=FirstOrder_outputs(o)
// Copyright INRIA
  xf=60
  yf=40
  [orig,sz,orient]=(o.graphics.orig,o.graphics.sz,o.graphics.flip)
  out=size(o.model.out,1);clkout=size(o.model.evtout,1);
  P=[-5,50,2,0;105,50,2,0]
 
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

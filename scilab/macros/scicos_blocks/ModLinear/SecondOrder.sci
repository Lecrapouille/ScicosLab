function [x,y,typ]=SecondOrder(job,arg1,arg2)
// Copyright INRIA
// the automatically generated interface block for Modelica SecondOrder.mo model
//   - avec un dialogue de saisie de parametre
x=[];y=[];typ=[];
select job
case 'plot' then
  standard_draw(arg1,%f,SecondOrder_draw_ports)
case 'getinputs' then
  [x,y,typ]=SecondOrder_inputs(arg1)
case 'getoutputs' then
  [x,y,typ]=SecondOrder_outputs(arg1)
case 'getorigin' then
  [x,y]=standard_origin(arg1)
case 'set' then
  x=arg1;
  graphics=arg1.graphics;exprs=graphics.exprs
  model=arg1.model;
x=arg1
exprs=x.graphics.exprs
while %t do
  [ok,k,w,D,y_start,yd_start,exprs]=getvalue(["Set SecondOrder block parameters:";"";"k       : Gain:  TF=K/( (s/w)^2+ 2*D*(s/w)+1 )";"w       : Angular frequency";"D       : Damping";"y_start : Initial or guess value of output (= state)";"yd_start: Initial or guess value of derivative"],["k";"w";"D";"y_start";"yd_start"],list("vec",1,"vec",1,"vec",1,"vec",1,"vec",1),exprs)
  if ~ok then break,end
  x.model.equations.parameters(2)=list(k,w,D,y_start,yd_start)
  x.graphics.exprs=exprs
  break
end
 case 'define' then      
ModelName="SecondOrder"
PrametersValue=[1;1;1;0;0]
ParametersName=["k";"w";"D";"y_start";"yd_start"]
model=scicos_model()                  
Typein=[];Typeout=[];MI=[];MO=[]       
P=[-5,50,2,0;105,50,-2,0]
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
exprs=["1";"1";"1";"0";"0"]
gr_i=["";"if orient then";"  xpolys(orig(1)+[0.1,0.05;0.1,0.91]*sz(1),orig(2)+[0.89,0.1;0.05,0.1]*sz(2),[3,3])";"  xset(''color'',12);";
"txt=""PT2"";";
"rectstr=stringbox(txt,orig(1),orig(2)+0.2*sz(2),0,1,1);";
"if ~exists(""%zoom"") then %zoom=1, end;";
"w=(rectstr(1,3)-rectstr(1,2))*%zoom;";
"h=(rectstr(2,2)-rectstr(2,4))*%zoom;";
"xstringb(orig(1)+0.2*sz(1),orig(2)+0.2*sz(2),txt,w,h,""fill"");";
"  xset(''thickness'',2);";"  xset(''color'',[2,2])";"  xfpolys(orig(1)+[0.1,0.97;0.06,0.86;0.14,0.86;0.1,0.97]*sz(1),orig(2)+[0.97,0.1;0.86,0.14;0.86,0.06;0.97,0.1]*sz(2),[1,1])";"  xset(''thickness'',1);";"  xpolys(orig(1)+[0;0;1;1;0]*sz(1),orig(2)+[1;0;0;1;1]*sz(2),3)";"  xpolys(orig(1)+[0.1;0.14;0.18;0.22;0.26;0.3;0.34;0.38;0.42;0.46;0.5;0.54;0.58;0.62;0.66;0.7;0.74;0.78;0.82;0.86;0.9]*sz(1),orig(2)+[0.1;0.15735;0.3025;0.48739;0.66375;0.794;0.85755;0.85245;0.79225;0.7003;0.60275;0.522295;0.473645;0.461855;0.48286;0.52605;0.5778;0.62515;0.6583;0.6725;0.66805]*sz(2),1)";"else";"  xpolys(orig(1)+[0.9,0.95;0.9,0.09]*sz(1),orig(2)+[0.89,0.1;0.05,0.1]*sz(2),[3,3])";"  xset(''color'',12);";
"txt=""PT2"";";
"rectstr=stringbox(txt,orig(1),orig(2)+0.2*sz(2),0,1,1);";
"if ~exists(""%zoom"") then %zoom=1, end;";
"w=(rectstr(1,3)-rectstr(1,2))*%zoom;";
"h=(rectstr(2,2)-rectstr(2,4))*%zoom;";
"xstringb(orig(1)+0.2*sz(1),orig(2)+0.2*sz(2),txt,w,h,""fill"");";
"  xset(''thickness'',2);";"  xset(''color'',[2,2])";"  xfpolys(orig(1)+[0.9,0.03;0.94,0.14;0.86,0.14;0.9,0.03]*sz(1),orig(2)+[0.97,0.1;0.86,0.14;0.86,0.06;0.97,0.1]*sz(2),[1,1])";"  xset(''thickness'',1);";"  xpolys(orig(1)+[1;1;0;0;1]*sz(1),orig(2)+[1;0;0;1;1]*sz(2),3)";"  xpolys(orig(1)+[0.9;0.86;0.82;0.78;0.74;0.7;0.66;0.62;0.58;0.54;0.5;0.46;0.42;0.38;0.34;0.3;0.26;0.22;0.18;0.14;0.1]*sz(1),orig(2)+[0.1;0.15735;0.3025;0.48739;0.66375;0.794;0.85755;0.85245;0.79225;0.7003;0.60275;0.522295;0.473645;0.461855;0.48286;0.52605;0.5778;0.62515;0.6583;0.6725;0.66805]*sz(2),1)";"end"]
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
function SecondOrder_draw_ports(o)
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
function [x,y,typ]=SecondOrder_inputs(o)
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
function [x,y,typ]=SecondOrder_outputs(o)
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

connector RealInput
   Real signal;
end RealInput;

connector RealOutput
   Real signal;
end RealOutput;


 model Sensor       
  parameter Real k=1;
  RealInput RealInputx ;
  Real Signal;
  equation 
      Signal=k*RealInputx.signal;
 end Sensor;

 model Actuator       
  parameter Real k=1;
    RealOutput RealOutputx ; 
    Real Signal;
  equation 
   RealOutputx.signal= k*Signal;
 end Actuator;


model Constant
  parameter Real k=1;
  RealOutput RealOutputx ;
equation
  RealOutputx.signal=k;
end Constant;


model Sine
  parameter Real amplitude=1 "Amplitude of sine wave";
  parameter Real freqHz=1 "Frequency of sine wave";
  parameter Real phase=0 "Phase of sine wave";
  parameter Real offset=0 "Offset of output signal";
  parameter Real startTime=0 "Output = offset for time < startTime";
	parameter Real PI=3.141592653589793;
  RealOutput RealOutputx ;
equation

  RealOutputx.signal = offset + (if time < startTime then 0 else amplitude*
    sin(2*PI*freqHz*(time - startTime) + phase));

end Sine;
 
model SineTF
  parameter Real phase=0 "Phase of sine wave";

  RealInput  RealInputx ;
  RealOutput RealOutputx ;
equation

  RealOutputx.signal = sin(RealInputx.signal+phase);

end SineTF;

model TanTF
  RealInput  RealInputx ;
  RealOutput RealOutputx ;
equation

  RealOutputx.signal = tan(RealInputx.signal);

end TanTF;

model AtanTF
  RealInput  RealInputx ;
  RealOutput RealOutputx ;
equation

  RealOutputx.signal = atan(RealInputx.signal);

end AtanTF;

model PI
  parameter Real k=1;
  parameter Real T=1;

  RealOutput RealOutputx ;
  RealInput  RealInputx ;
  Real x(start=0);
  Real u,y(start=0);
equation
 u=RealInputx.signal;
 y=RealOutputx.signal;
 der(x)=u/T;
 y=k*(x+u);
end PI;

model Feedback
  parameter Real n=1;
  RealOutput RealOutputx ;
  RealInput  RealInput1 ;
  RealInput  RealInput2 ;
equation
  RealOutputx.signal=RealInput1.signal-RealInput2.signal;
end Feedback;

model Gain
   parameter Real k=1;
  RealOutput RealOutputx ;
  RealInput  RealInputx ;
equation
  RealOutputx.signal=RealInputx.signal*k;
end Gain;

model Limiter
   parameter Real uMax=1;
   parameter Real uMin=1;
  RealOutput RealOutputx ;
  RealInput  RealInputx ;
  Real u;
equation
 u=RealInputx.signal;
 RealOutputx.signal = if noEvent(u > uMax) then uMax else if noEvent(u < uMin) then uMin else u;
end Limiter;
//---------------------------------------------
model PT1 
  parameter Real k=1 "Gain";
  parameter Real Ti=1 "Constante de temps (s)";
  //parameter Real U0=0 "Valeur de la sortie à l'instant initial (si non permanent et si u0 non connecté)";
  parameter Real permanent=0 "Calcul du permanent";
  
protected 
  Real x;

public 
  RealInput u, u0;
  RealOutput y;

initial equation 

  if permanent> 0.5 then
    der(x) = 0;
  else
    x = (u0.signal)/k;
  end if;
  
equation 
  
  der(x) = (u.signal - x)/Ti;
  y.signal = k*x;
end PT1;
//---------------------------------------------

model FirstOrder 
    "First order transfer function block (= 1 pole)" 
  parameter Real k=1 "Gain";
  parameter Real T=1 "Constante de temps (s)";
  parameter Real y_start=0 "start valuie of y";
  parameter Real permanent=0 "choice";
 
protected 
  Real x(start=y_start);

public 
  RealInput u;
  RealOutput y;

equation 
  
  der(x) = (u.signal - x)/T;
  y.signal = k*x;

end FirstOrder;
//---------------------------------------------
block SecondOrder
  parameter Real k=1 "Gain:  TF=K/( (s/w)^2+ 2*D*(s/w)+1 )";
  parameter Real w=1 "Angular frequency";
  parameter Real D=1 "Damping";
  parameter Real y_start=0 "Initial or guess value of output (= state)" ;
  parameter Real yd_start=0 "Initial or guess value of derivative";
  parameter Real permanent=0 "Calcul du permanent";

protected 
  Real yd;

public 
  RealInput u;
  RealOutput y;

initial equation 

  if permanent> 0.5 then
    der(y.signal) = 0;
    der(yd)= 0;
  else
    y.signal  =y_start ;
    yd =yd_start ;
  end if;
  
equation 
  der(y.signal) = yd;
  der(yd) = w*(w*(k*u.signal - y.signal) - 2*D*yd);

end SecondOrder;

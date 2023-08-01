function res=determ(W,k)
  
// determinant of a polynomial or rational matrix by FFT
// W=square polynomial matrix
// k=``predicted'' degree of the determinant of W i.e. k is
// an integer larger or equal to the actual degree of W.
// Method: evaluate the determinant of W for the Fourier frequencies
// and apply inverse fft to the coefficients of the determinant.
// See also detr
// F.D.!
// Copyright INRIA
  
  if W==[] then
    res=1;
    return;
  end;
  
  if size(W,1)<>size(W,2) then 
    error('argument must be a square matrix'), 
  end
  
  n1=size(W,1)
  
  // small cases
  
  if n1==1 then
    res=W;
    return;
  elseif n1==2 then
    res = W(1,1)*W(2,2) - W(1,2)*W(2,1);
    return;
  end
  
  //upper bound of the determinant degree
  
  maj = n1*maxi(degree(W))+1;
  
  if argn(2)==1 then 
    k=1;
    while k < maj,
      k=2*k;
    end
  end
  
  if n1>8 then
    write(%io(2),'Computing determinant: Be patient...');
  end
  
  // Default Values
  e=0*ones(k,1);
  e(2)=1;
  
  // Param�tres de clean
  epsa=1.d-10;
  epsr=0;//no relative rounding
  
  if k==1 then
    ksi=1;
  else
    ksi=fft(e,-1);
  end
  
  fi=[];
  
  if ~isreal(W,0) then
    // Cas Complexe
    for kk=1:k,
      fi=[fi,det(horner(W,ksi(kk)))];
    end
    Temp0 = poly(fft(fi,1),varn(W),'c');
    Temp1 = clean(real(Temp0),epsa,epsr)+%i*clean(imag(Temp0),epsa,epsr);
    
  else
    // Cas R�el
    for kk=1:k,fi=[fi,det(freq(W,ones(W),ksi(kk)))];end
    Temp1 = clean(real(poly(fft(fi,1),varn(W),'c')),epsa,epsr);
  end
  
  if argn(2)==1 then
    
    // Cas o� k est d�fini dans les param�tres d'entr�e.
    // On va maintenant annuler tous les coefficients
    // dont le degr� est sup�rieur � maj
    
    Temp2 = coeff(Temp1);
    for i=1:maj,
      Temp2(i) = 0;
    end
    res = Temp1 - poly(Temp2,varn(W),"coeff");
    return;
    
  else
    // Cas o� k n'est pas d�fini dans les param�tres d'entr�e
    res = Temp1;
    return;
  end
  
endfunction

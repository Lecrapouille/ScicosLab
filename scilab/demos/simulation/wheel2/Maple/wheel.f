c      
c     SUBROUTINE wheel
c      
      subroutine wheel(neq,t,z,zdot)
        implicit double precision (t)
        parameter (kn=3)
        doubleprecision t,z(8),zdot(8),r,j(3),m
        doubleprecision me3s(kn,kn)
        doubleprecision const(kn,1),w(3*kn),rcond
        integer i,k,neq,ierr
        data g / 9.81/
        data r / 1.0/
        data m / 1.0/
        data j / 0.3,0.4,1.0/
      t1 = r**2
      t2 = t1*m
      t4 = cos(2*z(2))
      t9 = cos(z(2))
      t10 = t2+J(3)
      t11 = t9*t10
         me3s(1,1) = J(1)/2+t2*t4/2+t2/2+J(3)*t4/2+J(3)/2-J(1)*t4/2
         me3s(1,2) = 0
         me3s(1,3) = t11
         me3s(2,1) = 0
         me3s(2,2) = J(1)+t2
         me3s(2,3) = 0
         me3s(3,1) = t11
         me3s(3,2) = 0
         me3s(3,3) = t10
      t1 = r**2
      t2 = t1*m
      t4 = sin(2*z(2))
      t11 = sin(z(2))
      t16 = z(4)**2
      t24 = cos(z(2))
         const(1,1) = z(5)*(t2*z(4)*t4-J(1)*z(4)*t4+J(3)*z(4)*t4+z(6)*t1
     +1*J(3))
         const(2,1) = -t2*t16*t4/2-t1*t11*m*z(4)*z(6)-r*t24*m*g+J(1)*t16
     +*t4/2-J(3)*t11*z(4)*z(6)-J(3)*t16*t4/2
         const(3,1) = t11*z(4)*z(5)*(2*t2+J(3))
c         
        do 1000, i =1,kn ,1
          zdot(i) = z(i+kn)
 1000   continue
c       
c        we must solve  M z =const 
        call dlslv(me3s,kn,kn,Const,kn,1,w, rcond,ierr,1)
        if (ierr.ne.0) then
          write(6,2000) 
 2000     format('Ill conditioned matrix!')
        endif
c         
        do 1001, i =1,kn ,1
          zdot(kn+i) = const(i,1)
 1001   continue
c       
      t1 = z(2)
      t2 = cos(t1)
      t4 = z(1)
      t5 = sin(t4)
      t9 = sin(t1)
      t11 = cos(t4)
        zdot(7) = r*t2*t5*z(4)+r*t9*t11*z(5)+r*t5*z(6)
      t1 = z(2)
      t2 = cos(t1)
      t4 = z(1)
      t5 = cos(t4)
      t9 = sin(t1)
      t11 = sin(t4)
        zdot(8) = -r*t2*t5*z(4)+r*t9*t11*z(5)-r*t5*z(6)
        return
      end

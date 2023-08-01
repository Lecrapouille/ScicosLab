      subroutine formatnumber(a,ifmt,maxc,str,fl)
      double precision a
      integer n1,n2,fl
      character str*(*)
      character*10 form
      if (ifmt .eq. 1) then
         fl = maxc
         n2 = 1
         write(form,130) maxc,maxc-7
         write(str,form) a
       elseif (ifmt .ge. 0) then
          n1 = ifmt / 32
          n2 = ifmt - 32*n1
          fl = n1
          if(a.lt.0.0d0) fl=fl+1
c     
c          write(form,120) n1,n2
c          write(str(1:n1),form) a
c          workaround to fix gfortran4.0 bug: 0.999999999--> 0
c          if (str(1:n1).eq.' 0.'.and.a.gt.0.9999d0) str(2:2)='1'
c     
c     formatpatch will use C-code in case of gfortran bug 
          call formatpatch(str,n1,n2,a)
       elseif (ifmt .eq. -1) then
C     Inf
          if(a.lt.0.0d0) then
             fl=4
             str='-Inf'
          else
             fl = 3
             str = 'Inf'
          endif
       elseif (ifmt .eq. -2) then
C     Nan
          fl = 3
          str = 'Nan'
       endif

      return

  120 format('(f',i2,'.',i2,')')
  130 format('(1pd',i2,'.',i2,')')
      end

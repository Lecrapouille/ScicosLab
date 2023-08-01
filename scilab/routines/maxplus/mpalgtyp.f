      integer function typecode(l)
      integer l
         typecode=mod(l,8)
c        write(*,*)'typecode' 
c        write(*,*) typecode
      return
      end


      integer function algtype2(m1,m2)
      integer m1,m2
c        write(*,*) 777
c        write(*,*) m1
c        write(*,*) m2
         if (m1.eq.0) then
            algtype2=m2
         else
            algtype2=256+8*(m1-1)+m2
         endif
c        write(*,*)'algtype' 
C        write(*,*) algtype,m1,m2
      return
      end

      integer function algcode(l)
      integer l
      integer typecode
         if (l.le.256) then
            algcode=0
         else
            algcode=1+(l-256-typecode(l))/8
         endif
c        write(*,*)l
c        write(*,*)typecode(l)
c        write(*,*)(l-900-1)/100
c        write(*,*)l
c        write(*,*)'algcode'
c        write(*,*) algcode
c        write(*,*)100/100
c        write(*,*)4/3
      return
      end

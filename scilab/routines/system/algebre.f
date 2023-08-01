c     Copyright INRIA
      integer function basetype(l)
      integer l
      basetype=mod(l,100)
      return
      end

      integer function algtyp2(m1,m2)
      integer m1,m2
      if (m1.eq.0) then
         algtyp2=m2
      else
         algtyp2=900+100*m1+m2
      endif
      return
      end

c      integer function algcode(l)
c      integer l
c      integer typecode
c      if (l.le.999) then
c         algcode=0
c      else
c         algcode=(l-900-typecode(l))/100
c      endif
c      return
c      end

c$$$      double precision function addid(l)
c$$$      integer l
c$$$      if (l.eq.1) then
c$$$         addid=-(10000.3**10000.3)
c$$$      elseif (l.eq.2) then
c$$$         addid=(10000.3**10000.3)
c$$$      else 
c$$$         addid=0.0d0
c$$$      endif
c$$$      return
c$$$      end
c$$$
c$$$      double precision function peak(l)
c$$$      integer l
c$$$         if (l.eq.2) then
c$$$            peak=-(10000.3**10000.3)
c$$$         else
c$$$            peak=(10000.3**10000.3)
c$$$         endif
c$$$      return
c$$$      end


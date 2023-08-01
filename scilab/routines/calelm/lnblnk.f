      integer function lnblnksci(str)
c     Copyright INRIA
      character*(*) str
      n=len(str)+1
 10   continue
      n=n-1
      if (n.eq.0) then
         lnblnksci=0
         return
      else
         if (str(n:n).ne.' ') then
            lnblnksci=n
            return
         endif
      endif
      goto 10
      end

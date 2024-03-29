      subroutine logelm
c ================================== ( Inria    ) =============
c evaluation des fonctions elementaires sur les booleens
c =============================================================
c
c     Copyright INRIA
      include '../stack.h'

c
      if (ddt .eq. 4) then
         write(buf(1:4),'(i4)') fin
         call basout(io,wte,' logelm '//buf(1:4))
      endif

c     functions/fin
c     1      2     3    4
c   find   bool2s  or  and
c
c
c
      goto (10,20,30,40) fin
 10   call intfind
      return
 20   call intsbool2s
      return
 30   call intor('or')
      return
 40   call intand('and')
      return
      end
c
      subroutine intfind
      include '../stack.h'
c
      external gettype
      integer gettype,vt,top0
c
      top0=top
      if(rhs.ne.1.and.rhs.ne.2) then
         call error(39)
         return
      endif

      if(rhs.eq.2) then
c     max number of index to find
         call getrmat('find', top, top, m2, n2, l2)
         if(err.gt.0.or.err1.gt.0) return
         nmax=stk(l2)
         if(nmax.le.0.and.nmax.ne.-1) then
            err=2
            call error(116)
            return
         endif
         top=top-1
      else
         nmax=-1
      endif

      vt=gettype(top)
      if(vt.eq.1.or.vt.eq.4) then
         if(lhs.gt.2) then
            call error(39)
            return
         endif
         call intsfind(nmax)
      elseif(vt.eq.5.or.vt.eq.6) then
         if(lhs.gt.2) then
            call error(39)
            return
         endif
         call intspfind(nmax)
      else
c     .  overloaded find
         call putfunnam('find',top)
         top=top0
         fun=-1
         return
      endif
      return
      end

      subroutine intsfind(nmax)
c     find of a full standard or boolean matrix
      include '../stack.h'

      double precision tv
c
      logical ref
      integer nmax
      integer sadr,iadr
c
      iadr(l)=l+l-1
      sadr(l)=(l/2)+1
c
      lw=lstk(top+1)
c

      
      il1=iadr(lstk(top))
      ilr=il1
      if(nmax.eq.0) then
         nt=nmax
         goto 17
      endif
      if(istk(il1).lt.0) il1=iadr(istk(il1+1))
      ref=ilr.ne.il1

      if(istk(il1).eq.1) then
c     argument is a standard matrix
         m1=istk(il1+1)
         mn1=istk(il1+1)*istk(il1+2)
         it1=istk(il1+3)
         if(it1.ne.0) then
            call putfunnam('find',top)
            if(nmax.ne.-1) top=top+1
            fun=-1
            return
         endif
         l1=sadr(il1+4)
         if(ref) then
            err=sadr(ilr+4)+mn1-lstk(bot)
            if(err.gt.0) then
               call error(17)
               return
            endif
            call icopy(4,istk(il1),1,istk(ilr),1)
         endif
         lr=sadr(ilr+4)
         l=lr
         if(mn1.gt.0) then
            if (nmax.lt.0) then
c     .     get all the occurences
               do 11 k=0,mn1-1
                  if(stk(l1+k).ne.0.0d0) then
                     stk(l)=float(k+1)
                     l=l+1
                  endif
 11            continue
            else
c     .     get at most nmax occurences
               do 12 k=0,mn1-1
                  if(stk(l1+k).ne.0.0d0) then
                     stk(l)=float(k+1)
                     l=l+1
                     if(l-lr.ge.nmax) goto 13
                  endif
 12            continue
            endif
 13         nt=l-lr
         else
            nt=0
         endif
      elseif(istk(il1).eq.4) then
c     argument is a full boolean matrix
         m1=istk(il1+1)
         mn1=istk(il1+1)*istk(il1+2)
         if(.not.ref) then
            il=max(il1+3+mn1,iadr(lstk(top)+mn1*lhs)+8)
            err=sadr(il+mn1)-lstk(bot)
            if(err.gt.0) then
               call error(17)
               return
            endif
            call icopy(mn1,istk(il1+3),1,istk(il),1)
         else
            il=il1+3
         endif
         istk(ilr)=1
         lr=sadr(ilr+4)
         if(mn1.gt.0) then
            l=lr
            if(nmax.lt.0) then
c     .     get all occurrences
               do 14 k=0,mn1-1
                  if(istk(il+k).ne.1) goto 14
                  stk(l)=float(k+1)
                  l=l+1
 14            continue
            else
c     .     get at most nmax occurences
               do 15 k=0,mn1-1
                  if(istk(il+k).ne.1) goto 15
                  stk(l)=float(k+1)
                  l=l+1
                  if(l-lr.ge.nmax) goto 16
 15            continue
            endif
 16         nt=l-lr
         else
            nt=0
         endif
      endif
 17   istk(ilr)=1
      istk(ilr+1)=min(1,nt)
      istk(ilr+2)=nt
      istk(ilr+3)=0
      lstk(top+1)=lr+nt
      if(lhs.eq.1) goto 999
      top=top+1
      il2=iadr(lstk(top))
      istk(il2)=1
      istk(il2+1)=min(1,nt)
      istk(il2+2)=nt
      istk(il2+3)=0
      l2=sadr(il2+4)
      lstk(top+1)=l2+nt
      if(nt.eq.0) goto 999
      do 18 k=0,nt-1
         stk(l2+k)=float(int((stk(lr+k)-1.0d0)/m1)+1)
         stk(lr+k)=stk(lr+k)-(stk(l2+k)-1.0d+0)*m1
 18   continue
      goto 999
c
  999 return
      end

      subroutine intspfind(nmax)
      include '../stack.h'

      logical ref
      double precision temp
      integer sadr,iadr
c
      iadr(l)=l+l-1
      sadr(l)=(l/2)+1
c
      lw=lstk(top+1)


      il1=iadr(lstk(top))
      ilr=il1
      if(nmax.eq.0) then
         nt=nmax
         goto 17
      endif
      if(istk(il1).lt.0) il1=iadr(istk(il1+1))
      ref=ilr.ne.il1

c     sparse matrix find
      m1=istk(il1+1)
      n1=istk(il1+2)
      it1=istk(il1+3)
      if(it1.ne.0) then
         call putfunnam('find',top)
         if(nmax.ne.-1) top=top+1
         fun=-1
         return
      endif
      nel1=istk(il1+4)
      if(nel1.eq.0) then
         nt=0
         lr=sadr(ilr+4)
         goto 17
      endif
c
      if(.not.ref) then
         lr=lw
      else
         lr=sadr(ilr+4)
      endif
      err=lr+nel1-lstk(bot)
      if(err.gt.0) then
         call error(17)
         return
      endif

      li=il1+5
      lj=li+m1

      l=lr
      ip=lj

      do 10 i=0,m1-1
         ni=istk(li+i)
         if(ni.ne.0) then
            do 01 ii=0,ni-1
               stk(l+ii)=(i+1)+dble(istk(ip+ii)-1)*dble(m1) ! fix for bug 10266
 01         continue
            l=l+ni
            ip=ip+ni
         endif
 10   continue

c     order the index column wise
      call dsort(stk(lr),nel1,istk(iadr(lr+nel1)))
      do 11 i=1,int(nel1/2)
         temp=stk(lr-1+i)
         stk(lr-1+i)=stk(lr+nel1-i)
         stk(lr+nel1-i)=temp
 11   continue

      nt=nel1
      if(nmax.ge.0) nt=min(nel1,nmax)

      if(.not.ref) then
         l=sadr(il1+4)
         call dcopy(nt,stk(lr),1,stk(l),1)
         lr=l
      endif

      
 17   istk(ilr)=1
      istk(ilr+1)=min(1,nt)
      istk(ilr+2)=nt
      istk(ilr+3)=0
      lstk(top+1)=lr+nt
      if(lhs.eq.1) return
      top=top+1
      il2=iadr(lstk(top))
      istk(il2)=1
      istk(il2+1)=min(1,nt)
      istk(il2+2)=nt
      istk(il2+3)=0
      l2=sadr(il2+4)
      lstk(top+1)=l2+nt
      if(nt.eq.0) return
      do 18 k=0,nt-1
         stk(l2+k)=aint((stk(lr+k)-1.0d0)/m1+1.d0)
         stk(lr+k)=stk(lr+k)-(stk(l2+k)-1.0d+0)*m1
 18   continue

      return
      end

      subroutine intsbool2s
      include '../stack.h'

      logical ref
      integer sadr,iadr
c
      iadr(l)=l+l-1
      sadr(l)=(l/2)+1
c
      lw=lstk(top+1)
c

   10 if(rhs.ne.1) then
         call error(39)
         return
      endif
      if(lhs.ne.1) then
         call error(39)
         return
      endif

      il1=iadr(lstk(top))
      ilr=il1
      if(istk(il1).lt.0) il1=iadr(istk(il1+1))
      ref=ilr.ne.il1
      mn1=istk(il1+1)*istk(il1+2)

c     this is not good since ref has to be 
c     changed to non-ref
c     if (mn1.eq.0) return
      
      if(istk(il1).eq.4) then
c     argument is a full boolean matrix
         lr=sadr(ilr+4)
         err=lr+mn1-lstk(bot)
         if(err.gt.0) then
            call error(17)
            return
         endif

         do 13 k=mn1-1,0,-1
            stk(lr+k)=istk(il1+3+k)
 13      continue
         istk(ilr)=1
         istk(ilr+1)=istk(il1+1)
         istk(ilr+2)=istk(il1+2)
         istk(ilr+3)=0
         lstk(top+1)=lr+mn1
      elseif(istk(il1).eq.6) then
c     argument is a sparse boolean matrix
         m1=istk(il1+1)
         n1=istk(il1+2)
         nel1=istk(il1+4)
c   
         if(ref) then
            err=sadr(ilr+5+m1+nel1)+nel1-lstk(bot)
            if(err.gt.0) then
               call error(17)
               return
            endif
            call icopy(m1+nel1,istk(il1+5),1,istk(ilr+5),1)
         endif
         lj=sadr(ilr+5+m1+nel1)
         call dset(nel1,1.0d0,stk(lj),1)
         istk(ilr)=5
         istk(ilr+1)=istk(il1+1)
         istk(ilr+2)=istk(il1+2)
         istk(ilr+3)=0
         istk(ilr+4)=nel1
         lstk(top+1)=lj+nel1
      elseif(istk(il1).eq.1) then
c     argument is a matrix
         if(istk(il1+3).ne.0) then
            call putfunnam('bool2s',top)
            fun=-1
            return
         endif
         
         if(mn1.eq.0) then
c           this is important if ref was true we 
c           change ref to standard null matrix
            istk(ilr)=1
            istk(ilr+1)=0
            istk(ilr+2)=0
            istk(ilr+3)=0
            lr=sadr(ilr+4)
            lstk(top+1)=lr
         else
            l1=sadr(il1+4)
            lr=sadr(ilr+4)
            if(ref) then
               err=lr+mn1-lstk(bot)
               if(err.gt.0) then
                  call error(17)
                  return
               endif
            endif
            do 20 k=mn1-1,0,-1
               if(stk(l1+k).ne.0.0d0) then
                  stk(lr+k)=1.0d0
               else
                  stk(lr+k)=0.0d0
               endif
 20         continue
            istk(ilr)=1
            istk(ilr+1)=istk(il1+1)
            istk(ilr+2)=istk(il1+2)
            istk(ilr+3)=0
            lstk(top+1)=lr+mn1
         endif
      elseif(istk(il1).eq.5) then
c     argument is a sparse matrix
         m1=istk(il1+1)
         n1=istk(il1+2)
         nel1=istk(il1+4)
         if(istk(il1+3).ne.0) then
            call putfunnam('bool2s',top)
            fun=-1
            return
         endif
c
         if(ref) then
            err=sadr(ilr+5+m1+nel1)+nel1-lstk(bot)
            if(err.gt.0) then
               call error(17)
               return
            endif
            call icopy(m1+nel1,istk(il1+5),1,istk(ilr+5),1)
         endif
         lj=sadr(ilr+5+m1+nel1)
         call dset(nel1,1.0d0,stk(lj),1)
         istk(ilr)=5
         istk(ilr+1)=istk(il1+1)
         istk(ilr+2)=istk(il1+2)
         istk(ilr+3)=0
         istk(ilr+4)=nel1
         lstk(top+1)=lj+nel1
      else
         call putfunnam('bool2s',top)
         fun=-1
         return
      endif
      end

      

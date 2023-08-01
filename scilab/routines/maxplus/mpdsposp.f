      subroutine mpdsposp(op,ma,na,a,nela,inda,mb,nb,b,nelb,
     $   indb,nelc,indc,ierr)
c      include 'mpstack.h'
c     Copyright INRIA
c!purpose
c     compare the elements of two  sparse matrices.
c!parameters 
c     op   : integer flag which specifies the comparison to perform
c            see routine dcompa for more precision
c     ma,na: row and column dimension of the a matrix  
c     mb,nb: row and column dimension of the b matrix  
c     a,b  : arrays. 
c     Contain non zero elements of first,second sparse matrices.
c     nela :integer: number of non zero elements of a
c     nelb :integer: number of non zero elements of b
c     nelc :integer: 
c                   on entry maximum number  of non zero elements of c
c                   on return number of non zero elements of c
c     inda : a matrix control data:
c            inda(i) 1<=i<=nr contains the number of ith row non zero elements
c             of a
c            inda(m+i) 1<=i<=nela column index of each non zero element
c     indb : b matrix control data:
c            indb(i) 1<=i<=nr contains the number of ith row non zero elements
c            of b
c             indb(m+i) 1<=i<=nelb column index of each non zero element
c     
c     indc : on return contains c matrix control data:
c            indc(i) 1<=i<=nr contains the number of ith row non zero elements
c            of c
c            indc(m+i) 1<=i<=nelb column index of each non zero element
c     ierr : if non zero initial value of nelc is to small
c     !
      double precision a(*),b(*),t
      double precision ZERO
      integer op,nela,inda(*),nelb,indb(*),nelc,indc(*),ierr
c     
      integer jc,ka,kb,jb,i,ja,j1,j2
      logical dcompa,z
      external dcompa,commons
c     
      nr=max(ma,mb)
      nc=max(na,nb)
      call commons(ZERO)

      if (ma.eq.mb .and. na.eq.nb .and. .not.dcompa(ZERO,ZERO,op)) then
         call mpcmpsp(op, ma, na, nela, a, inda, inda(nr+1),
     $                  mb, nb, nelb, b, indb, indb(nr+1), 
     $                  nelc, indc, indc(nr+1), ierr)
         return
      endif
c     
      nelmx=nelc
      ierr=0

c     jc counts elements of c.
      jc     = 1
c     ka,kb are numbers in first i rows of a,b.
      ka     = 1
      kb     = 1
      kc     = 1
c     jb counts elements of b.
      jb     = 1
c     i counts rows of a,b,c.
      if(ma*na.eq.1.and.mb*nb.gt.1) then
c     compare all element of b with scalar a
         t=ZERO
         if(inda(1).eq.1) t=a(1)
         z=dcompa(t,ZERO,op)   
         do 10 i=1,nr
            indc(i)=0
            nirb=indb(i)
            jb=kb        
            jc=kc
            if(nirb.eq.0) then
               do 03 j=1,nc
                  if (z) then
                     if(jc+1.gt.nelmx) goto 99
                     indc(nr+jc)=j
                     jc=jc+1
                  endif
 03            continue
            else
               j2=indb(nr+jb)
               do 04 j=1,nc
                  if(j2.eq.j) then
                     if (dcompa(t,b(jb),op)) then
                        if(jc+1.gt.nelmx) goto 99
                        indc(nr+jc)=j
                        jc=jc+1
                     endif 
                     if(jb-kb+1.lt.nirb) jb=jb+1
                     j2=indb(nr+jb)
                  else
                     if (z) then
                        if(jc+1.gt.nelmx) goto 99
                        indc(nr+jc)=j
                        jc=jc+1
                     endif 
                  endif
 04            continue
            endif
            kb=kb+indb(i)
            indc(i)=jc-kc
            kc=jc
 10      continue

      elseif(ma*na.gt.1.and.mb*nb.eq.1) then
c     compare all elements of a with scalar b  
         t=ZERO
         if(indb(1).eq.1) t=b(1)
         z=dcompa(ZERO,t,op)
         do 20 i=1,nr
            indc(i)=0
            nira=inda(i)
            ja=ka       
            jc=kc
            if(nira.eq.0) then
               if(z) then
                  if(kc+nc.gt.nelmx) goto 99
                  indc(i)=nc
                  do 11 j=1,nc
                     indc(nr+kc-1+j)=j
 11               continue
                  jc=kc+nc
               endif
            else
               j1=inda(nr+ja)
               do 12 j=1,nc
                  if(j1.eq.j) then
                     if (dcompa(a(ja),t,op)) then
                        if(jc+1.gt.nelmx) goto 99
                        indc(nr+jc)=j
                        jc=jc+1
                     endif
                     if(ja-ka+1.lt.nira) ja=ja+1
                     j1=inda(nr+ja)
                  elseif(z) then
                     if(jc+1.gt.nelmx) goto 99
                     indc(nr+jc)=j
                     jc=jc+1
                  endif
 12            continue
            endif
            indc(i)=jc-kc
            ka=ka+nira
            kc=jc
 20      continue 
      else
         z=dcompa(ZERO,ZERO,op)   
         do 30 i=1,nr
            indc(i)=0
            nira=inda(i)
            nirb=indb(i)
            ja=ka
            jb=kb        
            jc=kc
            if(nira.eq.0) then
               if(nirb.eq.0) then
                  if(z) then
                     if(kc+nc.gt.nelmx) goto 99
                     indc(i)=nc
                     do 21 j=1,nc
                        indc(nr+kc-1+j)=j
 21                  continue
                     jc=kc+nc
                  endif
               else
                  j2=indb(nr+jb)
                  do 22 j=1,nc
                     if(j2.eq.j) then
                        if (dcompa(ZERO,b(jb),op)) then
                           if(jc+1.gt.nelmx) goto 99
                           indc(nr+jc)=j
                           jc=jc+1
                        endif
                        if(jb-kb+1.lt.nirb) jb=jb+1
                        j2=indb(nr+jb)
                     elseif(z) then
                        if(jc+1.gt.nelmx) goto 99
                        indc(nr+jc)=j
                        jc=jc+1
                     endif
 22               continue
               endif
            else
               if(nirb.eq.0) then
                  j1=inda(nr+ja)
                  do 23 j=1,nc
                     if(j1.eq.j) then
                        if (dcompa(a(ja),ZERO,op)) then
                           if(jc+1.gt.nelmx) goto 99
                           indc(nr+jc)=j
                           jc=jc+1
                        endif
                        if(ja-ka+1.lt.nira) ja=ja+1
                        j1=inda(nr+ja)
                     elseif(z) then
                        if(jc+1.gt.nelmx) goto 99
                        indc(nr+jc)=j
                        jc=jc+1
                     endif
 23               continue
               else
                  j1=inda(nr+ja)
                  j2=indb(nr+jb)
                  do 24 j=1,nc
                     if(j1.eq.j) then
                        if(j2.eq.j) then
                           if (dcompa(a(ja),b(jb),op)) then
                              if(jc+1.gt.nelmx) goto 99
                              indc(nr+jc)=j
                              jc=jc+1
                           endif 
                           if(ja-ka+1.lt.nira) ja=ja+1
                           if(jb-kb+1.lt.nirb) jb=jb+1
                           j1=inda(nr+ja)
                           j2=indb(nr+jb)
                        else
                           if (dcompa(a(ja),ZERO,op)) then
                              if(jc+1.gt.nelmx) goto 99
                              indc(nr+jc)=j
                              jc=jc+1
                           endif 
                           if(ja-ka+1.lt.nira) ja=ja+1
                           j1=inda(nr+ja)
                        endif
                     else
                        if(j2.eq.j) then
                           if (dcompa(ZERO,b(jb),op)) then
                              if(jc+1.gt.nelmx) goto 99
                              indc(nr+jc)=j
                              jc=jc+1
                           endif
                           if(jb-kb+1.lt.nirb) jb=jb+1
                           j2=indb(nr+jb)
                        elseif(z) then
                           if(jc+1.gt.nelmx) goto 99
                           indc(nr+jc)=j
                           jc=jc+1
                        endif 
                     endif
 24               continue
               endif
            endif
            ka=ka+inda(i)
            kb=kb+indb(i)
            indc(i)=jc-kc
            kc=jc
 30      continue
      endif
      nelc  = jc-1
      return
c     error messages.
 99   ierr=1
c     no more place for c

      return 
      end


C$$$      subroutine cmp_and_update(x, y, op, C_mnel_i, C_icol, j, kC, 
C$$$     $                          C_nelmax, ierr)
C$$$      double precision x, y
C$$$      integer op, C_mnel_i, C_icol(*), j, kC, C_nelmax, ierr
C$$$      logical dcompa
C$$$      external dcompa

C$$$      if ( dcompa(x, y, op) ) then
C$$$         kC = kC + 1
C$$$         if ( kC .gt. C_nelmax ) then
C$$$            ierr = 1
C$$$            return
C$$$         endif
C$$$         C_icol(kC) = j
C$$$         C_mnel_i = C_mnel_i + 1
C$$$      endif
C$$$      end         
      
      
      subroutine mpcmpsp(op, A_m, A_n, A_nel, A_R, A_mnel, A_icol,
     $                     B_m, B_n, B_nel, B_R, B_mnel, B_icol,
     $                     C_nelmax, C_mnel, C_icol, ierr)
      
      implicit none
      integer op, A_m, A_n, A_nel, A_mnel(*), A_icol(*),
     $            B_m, B_n, B_nel, B_mnel(*), B_icol(*), 
     $            C_nelmax, C_mnel(*), C_icol(*), ierr
      double precision A_R(*), B_R(*),ZERO
      

      integer kA, kAf, kB, kBf, kC, i, jA, jB, k
      external commons
      call commons(ZERO)

      kAf = 0
      kBf = 0
      kC = 0
      ierr = 0

      do i = 1, A_m

         kA = kAf + 1
         kB = kBf + 1
         kAf = kAf + A_mnel(i)
         kBf = kBf + B_mnel(i)
         C_mnel(i) = 0

 100     if ( kA .gt. kAf  .or.  kB .gt. kBf ) goto 300
             jA = A_icol(kA)
             jB = B_icol(kB)
 200         continue
                if ( jA .lt. jB ) then
                   call cmp_and_update(A_R(kA), ZERO, op, C_mnel(i),
     $                                 C_icol, jA, kC, C_nelmax, ierr)
                   if (ierr .eq. 1 ) return
                   kA = kA + 1
                   if ( kA .gt. kAf ) goto 300
                   jA = A_icol(kA)
                   goto 200
                elseif ( jA .gt. jB ) then
                   call cmp_and_update(ZERO, B_R(kB), op, C_mnel(i),
     $                                 C_icol, jB, kC, C_nelmax, ierr)
                   if (ierr .eq. 1 ) return
                   kB = kB + 1
                   if ( kB .gt. kBf ) goto 300
                   jB = B_icol(kB)
                   goto 200
                else  ! jA = jB
                   call cmp_and_update(A_R(kA), B_R(kB), op, C_mnel(i),
     $                                 C_icol, jA, kC, C_nelmax, ierr)
                   if (ierr .eq. 1 ) return
                   kA = kA + 1
                   kB = kB + 1
                   goto 100
                endif
 300     continue
         if ( kA .le. kAf) then
            do k = kA, kAf
               call cmp_and_update(A_R(k), ZERO, op, C_mnel(i), C_icol,
     $                             A_icol(k), kC, C_nelmax, ierr)
               if (ierr .eq. 1 ) return
            enddo
         else if ( kB .le. kBf ) then
            do k = kB, kBf
               call cmp_and_update(ZERO, B_R(k), op, C_mnel(i), C_icol,
     $                             B_icol(k), kC, C_nelmax, ierr)
               if (ierr .eq. 1 ) return
            enddo
         endif

      enddo

      C_nelmax = kC

      end

      subroutine talg_p(x,nx,mm,nn,maxc,mode,ll,lunit,cw,iw)
c!but
c     talg_p ecrit une matrice max+ (ou un scalaire) sous
c     la forme d'un tableau s, avec gestion automatique de
c     l'espace disponible.
c!liste d'appel
c
c     subroutine talg_p(x,nx,m,n,maxc,mode,ll,lunit,cw,iw)
c
c     double precision x(*)
c     integer nx,m,n,maxc,mode,iw(*),ll,lunit
c     character cw*(*)
c
c     x : tableau contenant les coefficients de la matrice x
c     nx : entier definissant le rangement dans x
c     m : nombre de ligne de la matrice
c     n : nombre de colonnes de la matrice
c     maxc : nombre de caracteres maximum autorise pour
c            representer un nombre
c     mode : si mode=1 representation variable
c            si mode=0 representation d(maxc).(maxc-7)
c     ll : longueur de ligne maximum admissible
c     lunit : etiquette logique du support d'edition
c     cw : chaine de caracteres de travail de longueur au moins ll
c     iw : tableau de travail entier de taille au moins egale a
c          m*n + 2*n
c!
c     Copyright INRIA
      double precision x(*),a,a1,a2,fact,eps,dlamch
      integer iw(*),maxc,mode,fl,s,typ
      character cw*(*),sgn*1,dlg*1,dld*1
      character*10 form(2)
c
      eps=dlamch('p')
      cw=' '
      write(form(1),130) maxc,maxc-7
      dlg=' '
      dld=' '
      m=abs(mm)
      n=abs(nn)
      if(m*n.gt.1) then
         dlg='['
         dld=']'
      endif
c
c facteur d'echelle
c
      fact=1.0d+0
      a1=0.0d+0
      if(m*n.eq.1) goto 10
      a2=abs(x(1))
      l=-nx
      do 05 j=1,n
         l=l+nx
         do 05 i=1,m
            a=abs(x(l+i))
            if(a.eq.0.0d+0.or.a.gt.dlamch('o')) goto 05
            a1=max(a1,a)
            a2=min(a2,a)
 05   continue
      imax=0
      imin=0
      if(a1.gt.0.0d+0) imax=int(log10(a1))
      if(a2.gt.0.0d+0) imin=int(log10(a2))
      if(imax*imin.le.0) goto 10
      imax=(imax+imin)/2
      if(abs(imax).ge.maxc-2)  fact=10.0d+0**(-imax)
 10   continue
      eps=a1*fact*eps
c     
c phase d'analyse: pour chaque coefficient a representer on determine
c       format avec lequel on va l'editer, on en deduit la longueur
c       de la representation de chacun des coefficients.
c       les differents formats sont stockes sous forme codee dans iw
c       a partir de lf
c       la taille respective des representation des chacun des coeff
c       est contenue dans iw a partir de 1 .
c
      lbloc=n
      lf=lbloc+n+1
      nbloc=1
      iw(lbloc+nbloc)=n
c iw(k) contient la longueur maxi necessaire pour representer un
c       elemnt de colonne k
c iw(lbloc+nbloc) contient le numero de la derniere colonne
c        representable dans le bloc courant
c
      lp=-nx
      ldef=lf
      s=0
      do 20 k=1,n
      iw(k)=0
      lp=lp+nx
      do 15 l=1,m
c
c     traitement du coeff (l,k)
      a=abs(x(lp+l))*fact
c     c_ex      if(a.lt.eps) a=0.0d+0
c     jpc: add of isanan for msvc++
      if(isanan(a).ne.1.and.a.lt.eps.and.mode.ne.0) a=0.0d+0
c     determination du format devant representer a
      typ=1
      if(mode.eq.1) call fmt(a,maxc,typ,n1,n2)
      if(typ.eq.2) then
         fl=n1
         iw(ldef)=n2+32*n1
      elseif(typ.lt.0) then
         iw(ldef)=typ
         fl=3
      else
         iw(ldef)=1
         fl=maxc
         n2=maxc-7
      endif
c
c     determination de la longueur de la representation du monome,
c          cette longueur est a priori fl+2 (' '//sgn//rep(a)).
c           mais peut etre reduite si la representation est entiere
   13 lgh=fl+3
c      if(n2.eq.0) lgh=lgh-1
      ldef=ldef+1
c
      iw(k)=max(iw(k),lgh)
   15 continue
      s=s+iw(k)
      if(s.gt.ll-2) then
         iw(lbloc+nbloc)=k-1
         nbloc=nbloc+1
         iw(lbloc+nbloc)=n
         s=iw(k)
      endif
c
   20 continue
c
      l1=1
      if(fact.ne.1.0d+0) then
         write(cw(l1:l1+11),'(1x,1pd9.1,'' *'')')  1.0d+0/fact
         l1=l1+12
      endif
      if(mm.lt.0) then
         write(cw(l1:l1+4),'(''eye *'')') 
         l1=l1+5
      endif
      if(l1.gt.1) then
         call basout(io,lunit,cw(1:l1-1))
         call basout(io,lunit,' ')
         if(io.eq.-1) goto 99
      endif
c phase d'edition : la chaine de caractere representant la ligne des coeff
c       est constituee puis imprimee.
c
      k1=1
      do 70 ib=1,nbloc
         k2=iw(lbloc+ib)
         if(nbloc.ne.1) then
            call blktit(lunit,k1,k2,io)
            if (io.eq.-1) goto 99
         endif
c
      cw(1:1)=dlg
      do 60 l=1,m
      ldef=lf+l-1+(k1-1)*m
      l1=2
      do 50 k=k1,k2
      a=x(l+(k-1)*nx)*fact
cc_ex      if(abs(a).lt.eps) a=0.0d+0
      if(abs(a).lt.eps.and.mode.ne.0) a=0.0d+0
c
      l0=l1
      ifmt=iw(ldef)
      sgn=' '
      if(a.lt.0.0d+0) sgn='-'
      a=abs(a)
c
      cw(l1:l1+1)=' '//sgn
      l1=l1+2
c
      if(ifmt.eq.1) then
         nf=1
         fl=maxc
         n2=1
         write(cw(l1:l1+fl-1),form(nf)) a
      elseif(ifmt.ge.0) then
         nf=2
         n1=ifmt/32
         n2=ifmt-32*n1
         fl=n1
         write(form(nf),120) fl,n2
         write(cw(l1:l1+fl-1),form(nf)) a
      elseif(ifmt.eq.-1) then
c     Inf
         if(sgn.eq.'-') then
            fl=1
            cw(l1:l1+fl-1)='.'
         else
            fl=3
            cw(l1:l1+fl-1)='Inf'
         endif
      elseif(ifmt.eq.-2) then
c     Nan
         fl=3
         cw(l1:l1+fl-1)='Nan'
      endif
      l1=l1+fl
c
c      if(n2.eq.0) l1=l1-1
      nl1=l0+iw(k)-1
      cw(l1:nl1)=' '
      l1=nl1+1
      ldef=ldef+m
   50 continue
      cw(l1:l1)=dld
      call basout(io,lunit,cw(1:l1) )
      if (io.eq.-1) goto 99
   60 continue
      k1=k2+1
   70 continue
c
   99 return
c
  120 format('(f',i2,'.',i2,')')
  130 format('(1pd',i2,'.',i2,')')
      end


      subroutine cvdm(x,nx,m,n,maxc,mode,str,istr)
c
c ====================================================================
c scilab . librairie system
c ====================================================================
c
c     cvdm transcrit une matrice reelle en une matrice de chaines
c           de caracteres scilab
c
c ====================================================================
c
c     subroutine cvdm(x,nx,m,n,maxc,mode,str,istr)
c
c     double precision x(*)
c     integer nx,m,n,maxc,mode,str(*),istr(m*n+1)
c
c     x : tableau contenant les coefficients de la matrice x
c     nx : entier definissant le rangement dans x
c     m : nombre de ligne de la matrice
c     n : nombre de colonnes de la matrice
c     maxc : nombre de caracteres maximum autorise pour
c            representer un nombre
c     mode : si mode=1 representation variable
c            si mode=0 representation d(maxc).(maxc-7)
c     str : tableau contenant apres execution la suite des codes scilab
c           des caracteres.taille >= m*n*maxc
c     istr : tableau donnant la structure de str
c
      double precision x(*),a,eps,dlamch
      integer maxc,mode,fl,typ,ifmt
      integer str(*),istr(*),ipt
      character*256 cw
      character*1 ii
      data ipt /46/

c
      eps=dlamch('p')
c     
      lstr=1
      istr(1)=1
      lp=-nx
      do 60 k=1,n
         lp=lp+nx
         do 50 l=1,m
c     
c     traitement du coeff (l,k)
            a=x(lp+l)

            if(m*n.gt.1.and.abs(a).lt.eps.and.mode.ne.0) a=0.0d+0
c     determination du format devant representer a
            typ=1
            if(mode.eq.1) call fmt(abs(a),maxc,typ,n1,n2)
c     
            l1=1
            l0=1
c     
            ifmt=typ
            if(typ.eq.2) ifmt=n2+32*n1
            call formatnumber(a,ifmt,maxc,cw(l1:),fl)
c     
            l1=l1+fl
            if(cw(l0:l0).eq.'+'.or.cw(l0:l0).eq.' ') l0=2
            l1=l1+1
 42         l1=l1-1
            ii=cw(l1-1:l1-1)
            if(ichar(ii).eq.ichar(' ')) goto 42
            if(ichar(ii).eq.ipt) goto 42
            call cvstr(l1-l0,str(lstr),cw(l0:l1-1),0)
            lstr=lstr+l1-l0
            istr((k-1)*m+l+1)=lstr
 50      continue
 60   continue
      return
      end

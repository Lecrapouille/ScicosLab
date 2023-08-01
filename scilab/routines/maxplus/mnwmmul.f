C/MEMBR ADD NAME=WMMUL,SSI=0
      subroutine mnwmmul(ar,ai,na,br,bi,nb,cr,ci,nc,l,m,n)
c!but
c     ce sous programme effectue le produit matriciel:
c     c=a*b .
c!liste d'appel
c
c      subroutine wmpmmul(ar,ai,na,br,bi,nb,cr,ci,nc,l,m,n)
c      double precision ar(*),ai(*),br(*),bi(*),cr(*),ci(*)
c      integer i,j,k,ia,ib,ic
c
c     a            tableau de taille na*m contenant la matrice a
c     na           nombre de lignes du tableau a dans le programme appel
c     b,nb,c,nc    definitions similaires a celles de a,na
c     l            nombre de ligne des matrices a et c
c     m            nombre de colonnes de a et de lignes de b
c     n            nombre de colonnes de b et c
c!sous programmes utilises
c     neant
c!
c
      double precision ar(*),ai(*),br(*),bi(*),cr(*),ci(*)
      double precision tr,ti
      double precision mpadd
      integer na,nb,nc,l,m,n
      integer i,j,k,ia,ib,ic
c
c
      ib=0
      ic=0
      do 30 j=1,n
         do 20 i=1,l
         ia=i
            ib=ib+1
         tr=mpadd(ar(ia),br(ib))
         ti=mpadd(ai(ia),bi(ib))
            do 10 k=2,m
            ib=ib+1
            tr=min(tr,mpadd(ar(ia),br(ib)))
            ti=min(tr,mpadd(ai(ia),bi(ib)))
            ia=ia+na
   10       continue
         ib=ib-m
         cr(ic+i)=tr
   20    ci(ic+i)=ti
      ic=ic+nc
      ib=ib+nb
   30 continue
      return
      end

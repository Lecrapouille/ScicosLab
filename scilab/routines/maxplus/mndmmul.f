      subroutine mndmmul(a,na,b,nb,c,nc,l,m,n)
c!but
c     ce sous programme effectue le produit matriciel:
c     c=a*b .
c!liste d'appel
c
c     subroutine dmpmmul(a,na,b,nb,c,nc,l,m,n)
c     double precision a(na,m),b(nb,n),c(nc,n)
c     integer na,nb,nc,l,m,n
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
      double precision a(*),b(*),c(*)
      double precision mnddot
      integer na,nb,nc,l,m,n
      integer i,j,ib,ic
c
      ib=1
      ic=0
c
c
      do 30 j=1,n
         do 20 i=1,l
   20    c(ic+i)=mnddot(m,a(i),na,b(ib),1)
c        write(*,*)'mndmmul'
c        write(*,*)c(ic+i)
      ic=ic+nc
      ib=ib+nb
   30 continue
      return
      end


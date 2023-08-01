      subroutine formatpatch(dest,fl,n2,val) 
      double precision val 
      integer fl,n2 
      character*(*) dest 
      character*10 form
      write(form,120) fl,n2 
      write(dest,form) val 
  120 format('(f',i2,'.',i2,')')
      end
      

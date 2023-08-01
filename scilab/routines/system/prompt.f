      subroutine prompt(pause,escape)
c ====================================================================
c     issue prompt with optional pause
c ================================== ( Inria    ) =============
c     Copyright INRIA
      include '../stack.h'
      integer pause,escape,menusflag
      character *20,linfo
      logical iflag,interruptible
      common /basbrk/ iflag,interruptible

      escape=0
      if (pause .ne. 1) then
         call basout(io,wte,' ')
         call setprlev(paus)
      else
C     version with pause ( mode(7) )
         call setprlev(-1)
c     .  accept immediate dynamic callback execution
c         menusflag=1
 10      call basin(ierr,rte,buf,'*',menusflag)
         if(buf(1:1).eq.'p') iflag=.true.
         if(ierr.eq.-1) then
c     .     if this feature is activated we can block 
c     .     at scilab prompt in mode(7) mode 
c     .     a callback requires to be executed
c            escape=1
         endif
      endif
      return
      end

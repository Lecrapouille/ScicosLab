      integer PCALGCODE
      common /alg/ PCALGCODE

      double precision PCZERO,PCONE,PCTOP,ZERO,TOPM
      common /identity/ PCZERO,PCONE,PCTOP,ZERO,TOPM

      integer SCIERROR
      common /exerror/ SCIERROR

      double precision FG,MPNAN
      common /NANFLAG/ FG,MPNAN

      save alg
      save identity
      save exerror
      save NANFLAG

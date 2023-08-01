function txt=addLookup2D(txt,para,nin,nout)
     x=para.RowIndex
     y=para.ColumnIndex    
     z=para.Table

     meth=para.LookUpMeth

   // 1 : Interpolation-extrapolation (Bilinear)
      // 2 : Interpolation_endvalues
      // 3 : use input nearest
      // 4 : use input below
      // 5 : use input above
      // 6 : Interpolation-extrapolation (linear)


     if meth== "Interpolation-Extrapolation" then
         SIm=6
     elseif meth=="Interpolation-Use End Values" then
         SIm=2
     elseif meth=="Use Input Nearest" then     
         SIm=3
     elseif meth=="Use Input Below" then     
         SIm=4
     elseif meth=="Use Input Above" then     
         SIm=5
     else
         warning('Lookup block: Unknown interpolation method '+meth)
         SIm=1;
     end
     SampleTime=para.SampleTime

    [st,ierr]=evstr(SampleTime)

    if ierr>0 | st>=0 then

     warning('Not inherited Lookup2D blocks not supported. Inherited block is used.')
    end

      txt($+1)=ID+"%blk=instantiate_block('"LOOKUP2D'")"
      txt($+1)=ID+'%exprs='+sci2exp([x;y;z;string(SIm);"n"],0)
      txt($+1)=ID+"%blk=set_block_parameters(%blk,%exprs)"

endfunction

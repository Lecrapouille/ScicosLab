function txt=addFcn(txt,para,nin,nout)
        Expr=para.Expr
	SampleTime=para.SampleTime

       Expr=strsubst(Expr,' ','')
       for i=1:32
         str1="u("+string(i)+")";
         str2="u["+string(i)+"]";
         Expr=strsubst(Expr,str1,"u"+string(i));
         Expr=strsubst(Expr,str2,"u"+string(i));
       end

       //replace isolated u with u1
       ex=ascii(Expr);
       ki=find(ex==117);
       num=[48:57];
       cha=[65:90,97:122,95];
       
       l=size(ex,'*');
       kki=[];
       for i=ki
         if i==1 | ~or(ex(i-1)==[num,cha]) then
            if i==l | ~or(ex(i+1)==[num,cha]) then
               kki=[kki,i];
            end
         end
       end
       ofs=0
       for i=kki
         j=i+ofs;ofs=ofs+1;
         ex=[ex(1:j),ascii('1'),ex(j+1:$)];
       end
//       Expr=ascii(ex)

       //replace sqrt with ^(1/2)
       ofs=0
      // l=size(ex,'*')
       i=0
       while i<size(ex,'*')-6
         i=i+1
       //for i=1:l-7
         j=i+ofs;
         if isequal(ascii('sqrt('),ex(j:j+4)) then
            if j==1 | ~or(ex(j-1)==[num,cha]) then
             // ofs=ofs+1;

              //find corresp )
              cl=0
              for h=j+5:size(ex,'*')
                  if ex(h)==ascii(')') then
                      cl=cl+1
                  elseif ex(h)==ascii('(') then
                      cl=cl-1
                  end
                  if cl==1 then
                    k=h
                    break
                  end
              end
              ex=[ex(1:j-1),ascii('('),ex(j+4:k),ascii('^(1/2))'),ex(k+1:$)];
              //ofs=ofs-3;
           end
         end
      end

       //replace sgn(u) with (u>0)-(u<0)
       ofs=0
       //l=size(ex,'*')
       i=0
       while i<size(ex,'*')-6
         i=i+1
       //for i=1:l-7
         j=i+ofs;
         if isequal(ascii('sgn('),ex(j:j+3)) then
            if j==1 | ~or(ex(j-1)==[num,cha]) then
              //ofs=ofs+1;/////////////////////

              //find corresp )
              cl=0
              for h=j+4:size(ex,'*')
                  if ex(h)==ascii(')') then
                      cl=cl+1
                  elseif ex(h)==ascii('(') then
                      cl=cl-1
                  end
                  if cl==1 then
                    k=h
                    break
                  end
              end
              ex=[ex(1:j-1),ascii('(('),ex(j+3:k),ascii('>0)-('),..
                  ex(j+3:k),ascii('<0))'),ex(k+1:$)];
              //ofs=ofs-2
           end
         end
      end

      Expr=ascii(ex)

      exprs=sci2exp([string(nin);Expr;"0"],0)

  [st,ierr]=evstr(SampleTime)
 if ierr>0 | st>0 then
   txt($+1)=ID+"%blk=instantiate_block(""SUPER_f"")"
   txt($+1)=ID+"%blk.graphics.gr_i(1)="" """
   txt($+1)=ID+"scsm0=instantiate_diagram()"
   txt($+1)=ID+"scsm0=set_diag_bkgcolor(scsm0,8)"
   txt($+1)=ID+"scsm0 = set_diagram_location(scsm0,[428,124,1058,554],1.4)"
   txt($+1)=ID+"%context=.."
   txt($+1)=ID+""" """
   txt($+1)=ID+"scsm0 = set_diagram_context(scsm0,%context)"
   txt($+1)=ID+"%blk0=instantiate_block(""IN_f"")"
   txt($+1)=ID+"%blk0=set_block_bkgcolor(%blk0,8)"
   txt($+1)=ID+"%blk0=set_block_flip(%blk0,%t)"
   txt($+1)=ID+"%blk0=set_block_ident(%blk0,''"")"
   txt($+1)=ID+"%blk0=set_block_orig(%blk0,[184.83733,219.21067])"
   txt($+1)=ID+"%blk0=set_block_sz(%blk0,[20,20])"
   txt($+1)=ID+"%blk0=set_block_theta(%blk0,0)"
   txt($+1)=ID+"%exprs=.."
   txt($+1)=ID+"[""1"";""-1"";""-1""]"
   txt($+1)=ID+"%blk0=set_block_parameters(%blk0,%exprs)"
   txt($+1)=ID+"[scsm0,%l] = add_block(scsm0,%blk0)"
   txt($+1)=ID+"%blk0=instantiate_block(""OUT_f"")"
   txt($+1)=ID+"%blk0=set_block_bkgcolor(%blk0,8)"
   txt($+1)=ID+"%blk0=set_block_flip(%blk0,%t)"
   txt($+1)=ID+"%blk0=set_block_ident(%blk0,''"")"
   txt($+1)=ID+"%blk0=set_block_orig(%blk0,[453.23733,219.21067])"
   txt($+1)=ID+"%blk0=set_block_sz(%blk0,[20,20])"
   txt($+1)=ID+"%blk0=set_block_theta(%blk0,0)"
   txt($+1)=ID+"%exprs=.."
   txt($+1)=ID+"""1"""
   txt($+1)=ID+"%blk0=set_block_parameters(%blk0,%exprs)"
   txt($+1)=ID+"[scsm0,%l] = add_block(scsm0,%blk0)"
   txt($+1)=ID+"%blk0=instantiate_block(""SAMPHOLD_m"")"
   txt($+1)=ID+"%blk0=set_block_bkgcolor(%blk0,8)"
   txt($+1)=ID+"%blk0=set_block_flip(%blk0,%t)"
   txt($+1)=ID+"%blk0=set_block_ident(%blk0,''"")"
   txt($+1)=ID+"%blk0=set_block_orig(%blk0,[262.57067,209.21067])"
   txt($+1)=ID+"%blk0=set_block_sz(%blk0,[40,40])"
   txt($+1)=ID+"%blk0=set_block_theta(%blk0,0)"
   txt($+1)=ID+"%exprs='"-1'""
   txt($+1)=ID+"%blk0=set_block_parameters(%blk0,%exprs)"
   txt($+1)=ID+"[scsm0,%l] = add_block(scsm0,%blk0)"
   txt($+1)=ID+"%blk0=instantiate_block(""EXPRESSION"")"
   txt($+1)=ID+"%blk0=set_block_bkgcolor(%blk0,8)"
   txt($+1)=ID+"%blk0=set_block_flip(%blk0,%t)"
   txt($+1)=ID+"%blk0=set_block_ident(%blk0,''"")"
   txt($+1)=ID+"%blk0=set_block_orig(%blk0,[357.17067,209.21067])"
   txt($+1)=ID+"%blk0=set_block_sz(%blk0,[40,40])"
   txt($+1)=ID+"%blk0=set_block_theta(%blk0,0)"
   txt($+1)=ID+"%exprs=.."
   txt($+1)=ID+exprs
   txt($+1)=ID+"%blk0=set_block_parameters(%blk0,%exprs)"
   txt($+1)=ID+"[scsm0,%l] = add_block(scsm0,%blk0)"
   txt($+1)=ID+"scsm0 = add_explicit_link(scsm0,[1,1],[3,1],[])"
   txt($+1)=ID+"scsm0 = add_explicit_link(scsm0,[3,1],[4,1],[])"
   txt($+1)=ID+"scsm0 = add_explicit_link(scsm0,[4,1],[2,1],[])"
   txt($+1)=ID+"%blk0=instantiate_block(""SampleCLK"")"
   txt($+1)=ID+"%blk0=set_block_bkgcolor(%blk0,8)"
   txt($+1)=ID+"%blk0=set_block_flip(%blk0,%t)"
   txt($+1)=ID+"%blk0=set_block_ident(%blk0,''"")"
   txt($+1)=ID+"%blk0=set_block_orig(%blk0,[252.57067,301.344])"
   txt($+1)=ID+"%blk0=set_block_sz(%blk0,[60,40])"
   txt($+1)=ID+"%blk0=set_block_theta(%blk0,0)"
   txt($+1)=ID+"%exprs=.."
   txt($+1)=ID++sci2exp([SampleTime;"0"],0)
   txt($+1)=ID+"%blk0=set_block_parameters(%blk0,%exprs)"
   txt($+1)=ID+"[scsm0,%l] = add_block(scsm0,%blk0)"
   txt($+1)=ID+"scsm0 = add_event_link(scsm0,[8,1],[3,1],[])"
      
   txt($+1)=ID+"%blk=fill_superblock(%blk,scsm0)"

  
 else
   txt($+1)=ID+"%blk=instantiate_block('"EXPRESSION'")"
   txt($+1)=ID+"%blk=set_block_parameters(%blk,"+exprs+")"
 end

endfunction

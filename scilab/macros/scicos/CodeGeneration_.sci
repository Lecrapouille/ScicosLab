function CodeGeneration_()
//Copyright (c) 1989-2010 Metalau project INRIA
//
// Last update : 18/06/10
//
// Input editor function of Scicos code generator

    k = [] ; //** index of the CodeGen source superbloc candidate

    xc = %pt(1); //** last valid click position
    yc = %pt(2);

    %pt   = []   ;
    Cmenu = [] ;

    k  = getobj(scs_m,[xc;yc]) ; //** look for a block
    needcompile = 4  ;// this have to be done before calling the generator to avoid error with modelica blocks
                      // updateC in compile_modelica must be true when linking the functions

    //@@ default global variable
    ALL         = %f;                  //@@ entire diagram generation

    //** check if we have clicked near an object
    if k==[] then
      ALL = %t;
      //return
    //** check if we have clicked near a block
    elseif typeof(scs_m.objs(k))<>'Block' then
      return
    end

    if ~ALL then
      //** If the clicked/selected block is really a superblock
      //**             <k>
      if scs_m.objs(k).model.sim(1)=='super' | scs_m.objs(k).gui =='DSUPER'  then
         //##adjust selection if necessary
         if Select==[] then
           Select=[k curwin]
         end

         //##
         global scs_m_top

         //## test to know if a simulation have not been finished
         if alreadyran then
            Scicos_commands=['%diagram_path_objective=[];%scicos_navig=1';
                             '[alreadyran,%cpr]=do_terminate();'+...
                             '%diagram_path_objective='+sci2exp(super_path)+';%scicos_navig=1';
                             '%pt='+sci2exp(%pt)+';Cmenu='"Code Generation"'';]

         //## test to know if the precompilation of that sblock have been done
         elseif ( isequal(scs_m_top,[]) | isequal(scs_m_top,list()) ) then
            Scicos_commands=['%diagram_path_objective=[];%scicos_navig=1';
                             'global scs_m_top; scs_m_top=adjust_all_scs_m(scs_m,'+sci2exp(k)+');'+...
                             '%diagram_path_objective='+sci2exp(super_path)+';%scicos_navig=1';
                             '%pt='+sci2exp(%pt)+';Cmenu='"Code Generation"'';]

         else
            // Got to target sblock.
            scs_m_top=goto_target_scs_m(scs_m_top)

            //## call do_compile_superblock
            ierr=execstr('[ok, XX, gui_path, flgcdgen, szclkINTemp, freof, c_atomic_code] = '+...
                              'do_compile_superblock42(scs_m_top, k);','errcatch');

            //@@ silent_mode/cblock
            if k<>-1 then
              silent_mode=scs_m_top.objs(k).model.rpar.codegen.silent
              cblock=scs_m_top.objs(k).model.rpar.codegen.cblock
            else
              silent_mode=scs_m_top.codegen.silent
              cblock=scs_m_top.codegen.cblock
            end

            //## display error message if any
            if ierr<>0 then
              if ~silent_mode then
                message(lasterror())
              else
                disp(lasterror())
              end
              ok=%f;
            end

            clearglobal scs_m_top;
 
            //**quick fix for sblock that contains scope
            gh_curwin=scf(curwin)

            if ok==%t then
              if cblock==1 then
                XX=gencblk4(XX,gui_path)
              end
              scs_m = changeports(scs_m,list('objs',k), XX);  //scs_m.objs(k)=XX
              scs_m = draw_sampleclock(scs_m,XX,k,flgcdgen, szclkINTemp, freof);
              edited      = %t ;
              needcompile = 4  ;

              // The interface function must be defined on the first level
              Scicos_commands=['%diagram_path_objective=[];%scicos_navig=1';
                               'ppprot=funcprot();funcprot(0);'+...
                               'ierr=execstr(''exec('''''+strsubst(gui_path,'''','''''''''')+''''');'',''errcatch'');'+...
                                'funcprot(ppprot);clear ppprot;'+...
                               'if ierr<> 0 then message(''Cannot load the '''''+strsubst(gui_path,'''','''''''''')+''''' file'');end; '+...
                                '%diagram_path_objective='+sci2exp(super_path)+';%scicos_navig=1';
                               'Cmenu='"Replot'"']
            else
              if ok<>-1 then
                Cmenu = "Open/Set"
              end
            end
            //## remove variables
            clear XX flgcdgen k szclkINTemp freof gui_path
         end

      else
        //** the clicked/selected block is NOT a superblock
        message("Code Generation only work for a Superblock or for an entire diagram.")
      end

   //@@
   else

     //@@ check selection
     if Select<>[] then
        message([" Code Generation only work for a Superblock or for an entire diagram.";
                 "Please Select only one Superblock or remove your selection"]);
        return
     end

     //@@ do_terminate if necessary
     if alreadyran then [alreadyran,%cpr]=do_terminate(), end

     //## call do_compile_superblock
     ierr=execstr('[ok, XX, gui_path, flgcdgen, szclkINTemp, freof, c_atomic_code, cpr] ='+ ...
                            'do_compile_superblock42(scs_m, -1);','errcatch')

     //## display error message if any
     if ierr<>0 then
       //@@ silent_mode
       silent_mode=scs_m.codegen.silent
       if ~silent_mode then
         message(lasterror())
       else
         disp(lasterror())
       end
       ok=%f;
     end

     //** quick fix for sblock that contains scope
     gh_curwin=scf(curwin)

     if ok==%t then
       props              = scs_m.props;
       nscs_m             = get_new_scs_m()
       nscs_m.props       = props
       if XX.model.evtout<>[] then
         XX.graphics.pein   = 2
         XX.graphics.peout  = 2
         YY                 = scicos_link(xx   = [20;20;70;70;20;20],...
                                          yy   = [-5.70;-25;-25;60;60;45.7],...
                                          ct   = [5;-1],...
                                          from = [1,1,0],...
                                          to   = [1,1,1])
         nscs_m.objs(1)     = XX
         nscs_m.objs(2)     = YY
       else
         nscs_m.objs(1)     = XX
       end

       needcompile = 4  ;

       if scs_m.codegen.cblock==1 then
         scs_m       = nscs_m
         edited      = %t ;
         Cmenu       = "Replot"
       else
         nc_save=4
         Cmenu=[]
         scs_m_save=scs_m
         scs_m=nscs_m
         [%cpr,ok]=do_compile(scs_m)
         scs_m=scs_m_save
         clear scs_m_save
         if ok then
           %cpr.cor=update_cor(cpr.cor)
           corinv=list()
           for i =1:lstsize(cpr.corinv)
             if cpr.corinv(i)<>0 then
               corinv($+1)=cpr.corinv(i)
             end
           end
           %cpr.corinv(1)=corinv
           %cpr.sim.critev=0 //@@ disable critical event
           newparameters=list()
           %tcur=0 //temps courant de la simulation
           alreadyran=%f
           %state0=%cpr.state;
           needcompile=0;
           needstart=%t
         end
       end

       //## remove variables
       clear XX YY flgcdgen k szclkINTemp freof gui_path nscs_m
     end

   end

endfunction
//**---------------------------------------------------------------------------------------------------------------------------------
function [txt]=call_block42(bk,pt,flag)
//Copyright (c) 1989-2010 Metalau project INRIA

//** call_block42 : generate C calling sequence
//                  of a scicos block
//
// Input : bk   : block index
//         pt   : evt activation number
//         flag : flag
//
// Output : txt  : the generated calling sequence
//                 of the scicos block
//

  txt=[]

  //**
  if flag==2 & ((zcptr(bk+1)-zcptr(bk))<>0) & pt<0 then

  else
    if flag==2 & ((zptr(bk+1)-zptr(bk))+..
                  (ozptr(bk+1)-ozptr(bk))+..
                  (xptr(bk+1)-xptr(bk)+..
                  with_work(bk))==0 |..
                  (pt<=0 & (with_work(bk))==0) ) & ~(stalone & or(bk==actt(:,1))) then
      return // block without state or continuously activated
    end
  end
  if (flag==0 | flag==10) & ((xptr(bk+1)-xptr(bk))==0 & with_work(bk)==0) then
    return // block without continuous state
  end
  if flag==7 & ((xptr(bk+1)-xptr(bk))==0) then
    return // block without continuous state
  end
  if flag==9 & ((zcptr(bk+1)-zcptr(bk))==0) then
    return // block without continuous state
  end
  if flag==3 & ((clkptr(bk+1)-clkptr(bk))==0) then
    return
  end

  //** adjust pt
  if ~(flag==3 & ((zcptr(bk+1)-zcptr(bk))<>0) |..
       flag==2 & ((zcptr(bk+1)-zcptr(bk))<>0)) then
    pt=abs(pt)
  end

  //## check and adjust function type
  ftyp=funtyp(bk)
  ftyp_tmp=modulo(funtyp(bk),10000)
  if ftyp_tmp>2000 then
    ftyp=ftyp-2000
  elseif ftyp_tmp>1000 then
    ftyp=ftyp-1000
  end

  //** change flag 7 to flag 0 for ftyp<10000
  flagi=flag
  if flag==7 & ftyp < 10000 then
    flag=0;
  end

  //** set nevprt and flag for called block
  txt_nf=['block_'+rdnom+'['+string(bk-1)+'].nevprt = '+string(pt)+';'
          'local_flag = '+string(flag)+';']
  //@@ add block number for standalone
  if stalone then
    txt_nf=[txt_nf;
            'set_block_number('+string(bk)+');']
  end

  //@@ init evout
  if flag==3 then
    txt_init_evout=['/* initialize evout */'
                    'for(kf=0;kf<block_'+rdnom+'['+string(bk-1)+'].nevout;kf++) {'
                    '  block_'+rdnom+'['+string(bk-1)+'].evout[kf]=-1.;'
                    '}']
  else
    txt_init_evout=[]
  end

  //** add comment
  txt=[get_comment('call_blk',list(funs(bk),funtyp(bk),bk,ztyp(bk)));]

  //@@ remove call to the end block for standalone
  if stalone & funs(bk)=='scicosexit' then
    txt=[];
    return
  end

  //** see if its bidon, actuator or sensor
  if funs(bk)=='bidon' then
    txt=[];
    return
  elseif funs(bk)=='bidon2' then
    txt=[];
    return
  //@@ agenda_blk
  elseif funs(bk)=='agenda_blk' then
    txt=[];
    return
  //## sensor
  elseif or(bk==capt(:,1)) then
    ind=find(bk==capt(:,1))
    yk=capt(ind,2);

    txt = [txt_init_evout;
           txt;
           txt_nf
           'nport = '+string(ind)+';']

    txt = [txt;
           rdnom+'_sensor(&local_flag, &nport, &block_'+rdnom+'['+string(bk-1)+'].nevprt, \'
           get_blank(rdnom+'_sensor')+' &t, ('+mat2scs_c_ptr(outtb(yk))+' *)block_'+rdnom+'['+string(bk-1)+'].outptr[0], \'
           get_blank(rdnom+'_sensor')+' &block_'+rdnom+'['+string(bk-1)+'].outsz[0], \'
           get_blank(rdnom+'_sensor')+' &block_'+rdnom+'['+string(bk-1)+'].outsz[1], \'
           get_blank(rdnom+'_sensor')+' &block_'+rdnom+'['+string(bk-1)+'].outsz[2], \'
           get_blank(rdnom+'_sensor')+' block_'+rdnom+'['+string(bk-1)+'].insz[0], \'
           get_blank(rdnom+'_sensor')+' block_'+rdnom+'['+string(bk-1)+'].inptr[0]);']
    //## errors management
    txt = [txt;
           '/* error handling */'
           'if(local_flag < 0) {']
    if stalone then
      txt =[txt;
            '  set_block_error(5 - local_flag);']
      if flag<>5 & flag<>4 then
//         if ALL then
          txt =[txt;
                '  '+rdnom+'_cosend();'
                '  return get_block_error();']
//         else
//           txt =[txt;
//                 '  Cosend();'
//                 '  return get_block_error();']
//         end
      end
    else
      txt =[txt;
            '  set_block_error(local_flag);']
      if flag<>5 & flag<>4 then
        txt = [txt;
               '  return;']
      end
    end
    txt = [txt;
           '}']
    return
  //## actuator
  elseif or(bk==actt(:,1)) then
    ind=find(bk==actt(:,1))

    uk=actt(ind,2)
    nin=size(ind,2)

    for j=1:nin
      txt = [txt_init_evout;
             txt;
             txt_nf
             'nport = '+string(ind(j))+';']
      if strindex(funs(bk),"dummy")<>[] then
        txt = [txt;
               rdnom+'_dummy_actuator(&local_flag, &nport, &block_'+rdnom+'['+string(bk-1)+'].nevprt, \'
               get_blank(rdnom+'_actuator')+' &t, \'
               get_blank(rdnom+'_actuator')+' block_'+rdnom+'['+string(bk-1)+'].outsz['+string(j-1)+'], \'
               get_blank(rdnom+'_actuator')+' block_'+rdnom+'['+string(bk-1)+'].outptr['+string(j-1)+']);']
      else
        txt = [txt;
               rdnom+'_actuator(&local_flag, &nport, &block_'+rdnom+'['+string(bk-1)+'].nevprt, \'
               get_blank(rdnom+'_actuator')+' &t, ('+mat2scs_c_ptr(outtb(uk(j)))+' *)block_'+rdnom+'['+string(bk-1)+'].inptr['+string(j-1)+'], \'
               get_blank(rdnom+'_actuator')+' &block_'+rdnom+'['+string(bk-1)+'].insz['+string(j-1)+'], \'
               get_blank(rdnom+'_actuator')+' &block_'+rdnom+'['+string(bk-1)+'].insz['+string(nin+j-1)+'], \'
               get_blank(rdnom+'_actuator')+' &block_'+rdnom+'['+string(bk-1)+'].insz['+string(2*nin+j-1)+'], \'
               get_blank(rdnom+'_actuator')+' block_'+rdnom+'['+string(bk-1)+'].outsz['+string(j-1)+'], \'
               get_blank(rdnom+'_actuator')+' block_'+rdnom+'['+string(bk-1)+'].outptr['+string(j-1)+']);']
      end
      //## errors management
      txt = [txt;
             '/* error handling */'
             'if(local_flag < 0) {']
      if stalone then
        txt =[txt;
              '  set_block_error(5 - local_flag);']
        if flag<>5 & flag<>4 then
//           if ALL then
            txt =[txt;
                  '  '+rdnom+'_cosend();'
                  '  return get_block_error();']
//           else
//             txt =[txt;
//                   '  Cosend();'
//                   '  return get_block_error();']
//           end
        end
      else
        txt =[txt;
              '  set_block_error(local_flag);']
        if flag<>5 & flag<>4 then
          txt = [txt;
                 '  return;']
        end
      end
      txt = [txt;
             '}']
    end

    return
  end

  //**
  nx=xptr(bk+1)-xptr(bk);
  nz=zptr(bk+1)-zptr(bk);
  nrpar=rpptr(bk+1)-rpptr(bk);
  nipar=ipptr(bk+1)-ipptr(bk);
  nin=inpptr(bk+1)-inpptr(bk);  //* number of input ports */
  nout=outptr(bk+1)-outptr(bk); //* number of output ports */

  //**
  //ipar start index ptr
  if nipar<>0 then ipar=ipptr(bk), else ipar=1;end
  //rpar start index ptr
  if nrpar<>0 then rpar=rpptr(bk), else rpar=1; end
  //z start index ptr (warning -1)
  if nz<>0 then z=zptr(bk)-1, else z=0;end
  //x start index ptr
  if nx<>0 then x=xptr(bk)-1, else x=0;end

  //** check function type
  if ftyp < 0 then //** ifthenelse eselect blocks
      txt = [];
      return;
  else
    if (ftyp<>0 & ftyp<>1 & ftyp<>2 & ftyp<>3 & ftyp<>4  & ftyp<>10004) then
      disp("Types other than 0,1,2,3 or 4/10004 are not supported.")
      txt = [];
      return;
    end
  end

  select ftyp

    case 0 then

      txt=[txt_init_evout;
           txt;
           txt_nf]

      //**** input/output addresses definition ****//
      //## concatenate input
      if nin>1 then
        for k=1:nin
          uk=inplnk(inpptr(bk)-1+k);
          nuk=size(outtb(uk),1);
          //## YAUNEERREURICIFAUTRECOPIERTOUTDANSRDOUTTB
//           txt=[txt;
//                'rdouttb['+string(k-1)+']=(double *)'+rdnom+'_block_outtbptr['+string(uk-1)+'];']

          txt=[txt;
               'rdouttb['+string(k-1)+']=(double *)block_'+rdnom+'['+string(bk-1)+'].inptr['+string(k-1)+'];']

        end
        txt=[txt;
             'args[0]=&(rdouttb[0]);']
      elseif nin==0
        uk=0;
        nuk=0;
        txt=[txt;
             'args[0]=NULL;']
      else
        uk=inplnk(inpptr(bk));
        nuk=size(outtb(uk),1);
        txt=[txt;
             'args[0]=(double *)block_'+rdnom+'['+string(bk-1)+'].inptr[0];']
      end

      //## concatenate outputs
      if nout>1 then
        for k=1:nout
          yk=outlnk(outptr(bk)-1+k);
          nyk=size(outtb(yk),1);
          //## YAUNEERREURICIFAUTRECOPIERTOUTDANSRDOUTTB
//           txt=[txt;
//                'rdouttb['+string(k+nin-1)+']=(double *)'+rdnom+'_block_outtbptr['+string(yk-1)+'];'];
          txt=[txt;
               'rdouttb['+string(k+nin-1)+']=(double *)block_'+rdnom+'['+string(bk-1)+'].outptr['+string(k-1)+'];']
        end
        txt=[txt;
             'args[1]=&(rdouttb['+string(nin)+']);'];
      elseif nout==0
        yk=0;
        nyk=0;
        txt=[txt;
             'args[1]=NULL;'];
      else
        yk=outlnk(outptr(bk));
        nyk=size(outtb(yk),1);
        txt=[txt;
             'args[1]=(double *)block_'+rdnom+'['+string(bk-1)+'].outptr[0];'];
      end
      //*******************************************//

      //@@ this is for compatibility, jroot is returned in g for old type
      if (zcptr(bk+1)-zcptr(bk))<>0 & pt<0 then
        txt=[txt;
             '/* Update g array */'
             'for(i=0;i<block_'+rdnom+'['+string(bk-1)+'].ng;i++) {'
             '  block_'+rdnom+'['+string(bk-1)+'].g[i]=(double)block_'+rdnom+'['+string(bk-1)+'].jroot[i];'
             '}']
      end

      //## adjust continuous state array before call
      if impl_blk & flag==0 then
        txt=[txt;
             '/* adjust continuous state array before call */'
             'block_'+rdnom+'['+string(bk-1)+'].res = &(res['+string(xptr(bk)-1)+']);'];

        //*********** call seq definition ***********//
        txtc=['(&local_flag,&block_'+rdnom+'['+string(bk-1)+'].nevprt,&t,block_'+rdnom+'['+string(bk-1)+'].res, \';
              'block_'+rdnom+'['+string(bk-1)+'].x,&block_'+rdnom+'['+string(bk-1)+'].nx, \';
              'block_'+rdnom+'['+string(bk-1)+'].z,&block_'+rdnom+'['+string(bk-1)+'].nz,block_'+rdnom+'['+string(bk-1)+'].evout, \';
              '&block_'+rdnom+'['+string(bk-1)+'].nevout,block_'+rdnom+'['+string(bk-1)+'].rpar,&block_'+rdnom+'['+string(bk-1)+'].nrpar, \';
              'block_'+rdnom+'['+string(bk-1)+'].ipar,&block_'+rdnom+'['+string(bk-1)+'].nipar, \';
              '(double *)args[0],(nrd_1='+string(nuk)+',&nrd_1),(double *)args[1],(nrd_2='+string(nyk)+',&nrd_2));'];
      else
        //*********** call seq definition ***********//
        txtc=['(&local_flag,&block_'+rdnom+'['+string(bk-1)+'].nevprt,&t,block_'+rdnom+'['+string(bk-1)+'].xd, \';
              'block_'+rdnom+'['+string(bk-1)+'].x,&block_'+rdnom+'['+string(bk-1)+'].nx, \';
              'block_'+rdnom+'['+string(bk-1)+'].z,&block_'+rdnom+'['+string(bk-1)+'].nz,block_'+rdnom+'['+string(bk-1)+'].evout, \';
              '&block_'+rdnom+'['+string(bk-1)+'].nevout,block_'+rdnom+'['+string(bk-1)+'].rpar,&block_'+rdnom+'['+string(bk-1)+'].nrpar, \';
             'block_'+rdnom+'['+string(bk-1)+'].ipar,&block_'+rdnom+'['+string(bk-1)+'].nipar, \';
             '(double *)args[0],(nrd_1='+string(nuk)+',&nrd_1),(double *)args[1],(nrd_2='+string(nyk)+',&nrd_2));'];
      end

      if (funtyp(bk)>2000 & funtyp(bk)<3000)
        blank = get_blank(funs(bk)+'( ');
        txtc(1) = funs(bk)+txtc(1);
      elseif (funtyp(bk)<2000)
        //@@ special case for andlog func : should be fixed in scicos
        if funs(bk) <> 'andlog' then
          txtc(1) = 'C2F('+funs(bk)+')'+txtc(1);
          blank = get_blank('C2F('+funs(bk)+') ');
        else
          blank = get_blank(funs(bk)+'( ');
          txtc(1) = funs(bk)+txtc(1);
        end 
      end
      txtc(2:$) = blank + txtc(2:$);
      txt = [txt;txtc];
      //*******************************************//

      //## adjust continuous state array after call
      if impl_blk & flag==0 then
        if flagi==7 then
          txt=[txt;
               '/* adjust continuous state array after call */'
               'for (i=0;i<block_'+rdnom+'['+string(bk-1)+'].nx;i++) {'
               '  block_'+rdnom+'['+string(bk-1)+'].xd[i] = block_'+rdnom+'['+string(bk-1)+'].res[i];'
               '}']
        else
          txt=[txt;
               '/* adjust continuous state array after call */'
               'for (i=0;i<block_'+rdnom+'['+string(bk-1)+'].nx;i++) {'
               '  block_'+rdnom+'['+string(bk-1)+'].res[i] = block_'+rdnom+'['+string(bk-1)+'].res[i] - '+...
                 'block_'+rdnom+'['+string(bk-1)+'].xd[i];'
               '}']
        end
      end
      //## errors management
      txt = [txt;
             '/* error handling */'
             'if(local_flag < 0) {']
      if stalone then
        txt =[txt;
              '  set_block_error(5 - local_flag);']
        if flag<>5 & flag<>4 then
//           if ALL then
            txt =[txt;
                  '  '+rdnom+'_cosend();'
                  '  return get_block_error();']
//           else
//             txt =[txt;
//                   '  Cosend();'
//                   '  return get_block_error();']
//           end
        end
      else
        txt =[txt;
              '  set_block_error(local_flag);']
        if flag<>5 & flag<>4 then
          txt = [txt;
                 '  return;']
        end
      end
      txt = [txt;
             '}']

      if flag==3 then
        //@@ addevs function call
        if ALL & size(evs,'*')<>0 then
          ind=get_ind_clkptr(bk,clkptr,funtyp)
          txt = [txt;
                 '/* addevs function call */'
                 'for(kf=0;kf<block_'+rdnom+'['+string(bk-1)+'].nevout;kf++) {'
                 '  if (block_'+rdnom+'['+string(bk-1)+'].evout[kf]>=t) {'
                 '    '+rdnom+'_addevs(ptr, block_'+rdnom+'['+string(bk-1)+'].evout[kf], '+string(ind)+'+kf);'
                 '  }'
                 '}']
        else
          //@@ adjust values of output register
          //@@ TODO : multiple output event block
          txt = [txt;
                 '/* adjust values of output register */'
                 '/* TODO :  multiple output event block */'
                 'block_'+rdnom+'['+string(bk-1)+'].evout[0] = block_'+rdnom+'['+string(bk-1)+'].evout[0] - t;']
        end
      end
      return

    //**
    case 1 then

      txt=[txt_init_evout;
           txt;
           txt_nf]

      //@@ this is for compatibility, jroot is returned in g for old type
      if (zcptr(bk+1)-zcptr(bk))<>0 & pt<0 then
        txt=[txt;
             '/* Update g array */'
             'for(i=0;i<block_'+rdnom+'['+string(bk-1)+'].ng;i++) {'
             '  block_'+rdnom+'['+string(bk-1)+'].g[i]=(double)block_'+rdnom+'['+string(bk-1)+'].jroot[i];'
             '}']
      end

      //## adjust continuous state array before call
      if impl_blk & flag==0 then
        txt=[txt;
             '/* adjust continuous state array before call */'
             'block_'+rdnom+'['+string(bk-1)+'].res = &(res['+string(xptr(bk)-1)+']);'];

        //*********** call seq definition ***********//
        txtc=['(&local_flag,&block_'+rdnom+'['+string(bk-1)+'].nevprt,&t,block_'+rdnom+'['+string(bk-1)+'].res, \';
              'block_'+rdnom+'['+string(bk-1)+'].x,&block_'+rdnom+'['+string(bk-1)+'].nx, \';
              'block_'+rdnom+'['+string(bk-1)+'].z,&block_'+rdnom+'['+string(bk-1)+'].nz,block_'+rdnom+'['+string(bk-1)+'].evout, \';
              '&block_'+rdnom+'['+string(bk-1)+'].nevout,block_'+rdnom+'['+string(bk-1)+'].rpar,&block_'+rdnom+'['+string(bk-1)+'].nrpar, \';
              'block_'+rdnom+'['+string(bk-1)+'].ipar,&block_'+rdnom+'['+string(bk-1)+'].nipar , \'];
      else
        //*********** call seq definition ***********//
        txtc=['(&local_flag,&block_'+rdnom+'['+string(bk-1)+'].nevprt,&t,block_'+rdnom+'['+string(bk-1)+'].xd, \';
              'block_'+rdnom+'['+string(bk-1)+'].x,&block_'+rdnom+'['+string(bk-1)+'].nx, \';
              'block_'+rdnom+'['+string(bk-1)+'].z,&block_'+rdnom+'['+string(bk-1)+'].nz,block_'+rdnom+'['+string(bk-1)+'].evout, \';
              '&block_'+rdnom+'['+string(bk-1)+'].nevout,block_'+rdnom+'['+string(bk-1)+'].rpar,&block_'+rdnom+'['+string(bk-1)+'].nrpar, \';
              'block_'+rdnom+'['+string(bk-1)+'].ipar,&block_'+rdnom+'['+string(bk-1)+'].nipar , \'];
      end

      if (funtyp(bk)>2000 & funtyp(bk)<3000)
        blank = get_blank(funs(bk)+'( ');
        txtc(1) = funs(bk)+txtc(1);
      elseif (funtyp(bk)<2000)
        txtc(1) = 'C2F('+funs(bk)+')'+txtc(1);
        blank = get_blank('C2F('+funs(bk)+') ');
      end
      if nin>=1 | nout>=1 then
        if nin>=1 then
          for k=1:nin
            uk=inplnk(inpptr(bk)-1+k);
            txtc=[txtc;
                  '(double *)block_'+rdnom+'['+string(bk-1)+'].inptr['+string(k-1)+'],&block_'+rdnom+'['+string(bk-1)+'].insz['+string(k-1)+'], \';]
          end
        end
        if nout>=1 then
          for k=1:nout
            yk=outlnk(outptr(bk)-1+k);
            txtc=[txtc;
                  '(double *)block_'+rdnom+'['+string(bk-1)+'].outptr['+string(k-1)+'],&block_'+rdnom+'['+string(bk-1)+'].outsz['+string(k-1)+'], \';]
          end
        end
      end

      if ztyp(bk) then
        txtc=[txtc;
              'block_'+rdnom+'['+string(bk-1)+'].g,&block_'+rdnom+'['+string(bk-1)+'].ng);']
      else
        txtc($)=part(txtc($),1:length(txtc($))-3)+');';
      end

      txtc(2:$) = blank + txtc(2:$);
      txt = [txt;txtc];
      //*******************************************//

      //## adjust continuous state array after call
      if impl_blk & flag==0 then
        if flagi==7 then
          txt=[txt;
               '/* adjust continuous state array after call */'
               'for (i=0;i<block_'+rdnom+'['+string(bk-1)+'].nx;i++) {'
               '  block_'+rdnom+'['+string(bk-1)+'].xd[i] = block_'+rdnom+'['+string(bk-1)+'].res[i];'
               '}']
        else
          txt=[txt;
               '/* adjust continuous state array after call */'
               'for (i=0;i<block_'+rdnom+'['+string(bk-1)+'].nx;i++) {'
               '  block_'+rdnom+'['+string(bk-1)+'].res[i] = block_'+rdnom+'['+string(bk-1)+'].res[i] - '+...
                 'block_'+rdnom+'['+string(bk-1)+'].xd[i];'
               '}']
        end
      end
      //## errors management
      txt = [txt;
             '/* error handling */'
             'if(local_flag < 0) {']
      if stalone then
        txt =[txt;
              '  set_block_error(5 - local_flag);']
        if flag<>5 & flag<>4 then
//           if ALL then
            txt =[txt;
                  '  '+rdnom+'_cosend();'
                  '  return get_block_error();']
//           else
//             txt =[txt;
//                   '  Cosend();'
//                   '  return get_block_error();']
//           end
        end
      else
        txt =[txt;
              '  set_block_error(local_flag);']
        if flag<>5 & flag<>4 then
          txt = [txt;
                 '  return;']
        end
      end
      txt = [txt;
             '}']

      if flag==3 then
        //@@ addevs function call
        if ALL & size(evs,'*')<>0 then
          ind=get_ind_clkptr(bk,clkptr,funtyp)
          txt = [txt;
                 '/* addevs function call */'
                 'for(kf=0;kf<block_'+rdnom+'['+string(bk-1)+'].nevout;kf++) {'
                 '  if (block_'+rdnom+'['+string(bk-1)+'].evout[kf]>=t) {'
                 '    '+rdnom+'_addevs(ptr, block_'+rdnom+'['+string(bk-1)+'].evout[kf], '+string(ind)+'+kf);'
                 '  }'
                 '}']
        else
          //@@ adjust values of output register
          //@@ TODO : multiple output event block
          txt = [txt;
                 '/* adjust values of output register */'
                 '/* TODO :  multiple output event block */'
                 'block_'+rdnom+'['+string(bk-1)+'].evout[0] = block_'+rdnom+'['+string(bk-1)+'].evout[0] - t;']
        end
      end
      return

    //**
    case 2 then

      txt=[txt_init_evout;
           txt;
           txt_nf]

      //@@ this is for compatibility, jroot is returned in g for old type
      if (zcptr(bk+1)-zcptr(bk))<>0 & pt<0 then
        txt=[txt;
             '/* Update g array */'
             'for(i=0;i<block_'+rdnom+'['+string(bk-1)+'].ng;i++) {'
             '  block_'+rdnom+'['+string(bk-1)+'].g[i]=(double)block_'+rdnom+'['+string(bk-1)+'].jroot[i];'
             '}']
      end

      //## adjust continuous state array before call
      if impl_blk & flag==0 then
        txt=[txt;
             '/* adjust continuous state array before call */'
             'block_'+rdnom+'['+string(bk-1)+'].res = &(res['+string(xptr(bk)-1)+']);'];

        //*********** call seq definition ***********//
        txtc=[funs(bk)+'(&local_flag,&block_'+rdnom+'['+string(bk-1)+'].nevprt,&t,block_'+rdnom+'['+string(bk-1)+'].res, \';
              'block_'+rdnom+'['+string(bk-1)+'].x,&block_'+rdnom+'['+string(bk-1)+'].nx, \';
              'block_'+rdnom+'['+string(bk-1)+'].z,&block_'+rdnom+'['+string(bk-1)+'].nz,block_'+rdnom+'['+string(bk-1)+'].evout, \';
              '&block_'+rdnom+'['+string(bk-1)+'].nevout,block_'+rdnom+'['+string(bk-1)+'].rpar,&block_'+rdnom+'['+string(bk-1)+'].nrpar, \';
              'block_'+rdnom+'['+string(bk-1)+'].ipar,&block_'+rdnom+'['+string(bk-1)+'].nipar, \';
              '(double **)block_'+rdnom+'['+string(bk-1)+'].inptr,block_'+rdnom+'['+string(bk-1)+'].insz,&block_'+rdnom+'['+string(bk-1)+'].nin, \';
              '(double **)block_'+rdnom+'['+string(bk-1)+'].outptr,block_'+rdnom+'['+string(bk-1)+'].outsz, &block_'+rdnom+'['+string(bk-1)+'].nout'];
      else
        //*********** call seq definition ***********//
        txtc=[funs(bk)+'(&local_flag,&block_'+rdnom+'['+string(bk-1)+'].nevprt,&t,block_'+rdnom+'['+string(bk-1)+'].xd, \';
              'block_'+rdnom+'['+string(bk-1)+'].x,&block_'+rdnom+'['+string(bk-1)+'].nx, \';
              'block_'+rdnom+'['+string(bk-1)+'].z,&block_'+rdnom+'['+string(bk-1)+'].nz,block_'+rdnom+'['+string(bk-1)+'].evout, \';
              '&block_'+rdnom+'['+string(bk-1)+'].nevout,block_'+rdnom+'['+string(bk-1)+'].rpar,&block_'+rdnom+'['+string(bk-1)+'].nrpar, \';
              'block_'+rdnom+'['+string(bk-1)+'].ipar,&block_'+rdnom+'['+string(bk-1)+'].nipar, \';
              '(double **)block_'+rdnom+'['+string(bk-1)+'].inptr,block_'+rdnom+'['+string(bk-1)+'].insz,&block_'+rdnom+'['+string(bk-1)+'].nin, \';
              '(double **)block_'+rdnom+'['+string(bk-1)+'].outptr,block_'+rdnom+'['+string(bk-1)+'].outsz, &block_'+rdnom+'['+string(bk-1)+'].nout'];
      end

      if ~ztyp(bk) then
        txtc($)=txtc($)+');';
      else
        txtc($)=txtc($)+', \';
        txtc=[txtc;
              'block_'+rdnom+'['+string(bk-1)+'].g,&block_'+rdnom+'['+string(bk-1)+'].ng);']
      end
      blank = get_blank(funs(bk)+'( ');
      txtc(2:$) = blank + txtc(2:$);
      txt = [txt;txtc];
      //*******************************************//

      //## adjust continuous state array after call
      if impl_blk & flag==0 then
        if flagi==7 then
          txt=[txt;
               '/* adjust continuous state array after call */'
               'for (i=0;i<block_'+rdnom+'['+string(bk-1)+'].nx;i++) {'
               '  block_'+rdnom+'['+string(bk-1)+'].xd[i] = block_'+rdnom+'['+string(bk-1)+'].res[i];'
               '}']
        else
          txt=[txt;
               '/* adjust continuous state array after call */'
               'for (i=0;i<block_'+rdnom+'['+string(bk-1)+'].nx;i++) {'
               '  block_'+rdnom+'['+string(bk-1)+'].res[i] = block_'+rdnom+'['+string(bk-1)+'].res[i] - '+...
                 'block_'+rdnom+'['+string(bk-1)+'].xd[i];'
               '}']
        end
      end
      //## errors management
      txt = [txt;
             '/* error handling */'
             'if(local_flag < 0) {']
      if stalone then
        txt =[txt;
              '  set_block_error(5 - local_flag);']
        if flag<>5 & flag<>4 then
//           if ALL then
            txt =[txt;
                  '  '+rdnom+'_cosend();'
                  '  return get_block_error();']
//           else
//             txt =[txt;
//                   '  Cosend();'
//                   '  return get_block_error();']
//           end
        end
      else
        txt =[txt;
              '  set_block_error(local_flag);']
        if flag<>5 & flag<>4 then
          txt = [txt;
                 '  return;']
        end
      end
      txt = [txt;
             '}']

      if flag==3 then
        //@@ addevs function call
        if ALL & size(evs,'*')<>0 then
          ind=get_ind_clkptr(bk,clkptr,funtyp)
          txt = [txt;
                 '/* addevs function call */'
                 'for(kf=0;kf<block_'+rdnom+'['+string(bk-1)+'].nevout;kf++) {'
                 '  if (block_'+rdnom+'['+string(bk-1)+'].evout[kf]>=t) {'
                 '    '+rdnom+'_addevs(ptr, block_'+rdnom+'['+string(bk-1)+'].evout[kf], '+string(ind)+'+kf);'
                 '  }'
                 '}']
        else
          //@@ adjust values of output register
          //@@ TODO : multiple output event block
          txt = [txt;
                 '/* adjust values of output register */'
                 '/* TODO :  multiple output event block */'
                 'block_'+rdnom+'['+string(bk-1)+'].evout[0] = block_'+rdnom+'['+string(bk-1)+'].evout[0] - t;']
        end
      end
      return

    //**
    case 4 then

      txt=[txt_init_evout;
           txt;
           txt_nf]

      //## adjust continuous state array before call
      if impl_blk & flag==0 then
        txt=[txt;
             '/* adjust continuous state array before call */'
             'block_'+rdnom+'['+string(bk-1)+'].xd  = &(res['+string(xptr(bk)-1)+']);'
             'block_'+rdnom+'['+string(bk-1)+'].res = &(res['+string(xptr(bk)-1)+']);'];
      end

      txt=[txt;
           funs(bk)+'(&block_'+rdnom+'['+string(bk-1)+'],local_flag);'];

      //## adjust continuous state array after call
      if impl_blk & flag==0  then
        if flagi==7 then
          txt=[txt;
               '/* adjust continuous state array after call */'
               'block_'+rdnom+'['+string(bk-1)+'].xd = &(xd['+string(xptr(bk)-1)+']);'
               'for (i=0;i<block_'+rdnom+'['+string(bk-1)+'].nx;i++) {'
               '  block_'+rdnom+'['+string(bk-1)+'].xd[i] = block_'+rdnom+'['+string(bk-1)+'].res[i];'
               '}']
        else
          txt=[txt;
               '/* adjust continuous state array after call */'
               'block_'+rdnom+'['+string(bk-1)+'].xd = &(xd['+string(xptr(bk)-1)+']);'
               'for (i=0;i<block_'+rdnom+'['+string(bk-1)+'].nx;i++) {'
               '  block_'+rdnom+'['+string(bk-1)+'].res[i] = block_'+rdnom+'['+string(bk-1)+'].res[i] - '+...
                 'block_'+rdnom+'['+string(bk-1)+'].xd[i];'
               '}']
        end
      end

    //**
    case 10004 then

      txt=[txt_init_evout;
           txt;
           txt_nf]

      txt=[txt;
           funs(bk)+'(&block_'+rdnom+'['+string(bk-1)+'],local_flag);'];

  end

  //## errors management
  if stalone then
    txt =[txt;
          '/* error handling */'
          'if (get_block_error() < 0) {'
          '  set_block_error(5 - get_block_error());']
    if flag<>5 & flag<>4 then
//         if ALL then
          txt =[txt;
                '  '+rdnom+'_cosend();'
                '  return get_block_error();']
//          else
//            txt = [txt;
//                   '  Cosend();'
//                   '  return get_block_error();']
//          end
    end
    txt =[txt;
          '}']
  else
    if flag<>5 & flag<>4 then
      txt =[txt;
            '/* error handling */'
            'if (get_block_error() < 0) {'
            '  return;'
            '}']
    end
  end

  //@@ addevs function call
  if flag==3 then
    if ALL & size(evs,'*')<>0 then
      ind=get_ind_clkptr(bk,clkptr,funtyp)
      txt = [txt;
             '/* addevs function call */'
             'for(kf=0;kf<block_'+rdnom+'['+string(bk-1)+'].nevout;kf++) {'
             '  if (block_'+rdnom+'['+string(bk-1)+'].evout[kf]>=0.) {'
             '    '+rdnom+'_addevs(ptr, block_'+rdnom+'['+string(bk-1)+'].evout[kf] + t, '+string(ind)+'+kf);'
             '  }'
             '}']
    else
      //@@ adjust values of output register
      //@@ TODO : multiple output event block
      txt=txt
    end
  end

endfunction

function XX=gen_allblk_new()
//@@ creates the Scicos C generick block
//@@ associated to an entire diagram
//@@ generated code
//
//@@ 28/09/08, Alan : initial rev
//@@
//@@ Copyright INRIA

  //@@ adjust oz
  oz=cpr.state.oz;
  //new_oz=list();
  //for i=1:lstsize(oz)
  //  new_oz($+1) = oz(i)
  //end
  //for i=1:lstsize(outtb)
  //  new_oz($+1) = outtb(i)
  //end

  new_oz_str=[];
  for i=1:lstsize(oz)
    new_oz_str = [new_oz_str , sci2exp(oz(i),0)];
  end
  for i=1:lstsize(outtb)
    new_oz_str = [new_oz_str , 'zeros('+string(size(outtb(i),1))+','+string(size(outtb(i),2))+')'];
  end

  new_oz_str='list('+strcat(new_oz_str,',')+')';

  //@@ adjust z
  work=zeros(nblk,1);
  Z=[z;work]

  //@@ get nmode
  nmode = cpr.sim.modptr($)-1

  //@@ get nzcross
  nzcross = cpr.sim.zcptr($)-1

  //@@ get firing
  //firing = min(firing_evtout)
  if find(firing_evtout>=0)<>[] then
    firing = min(firing_evtout(find(firing_evtout>=0)))
  else
    firing = min(firing_evtout)
  end

  //@@ get rpar/ipar/opar
  rpar = cpr.sim.rpar
  ipar = cpr.sim.ipar
  opar = cpr.sim.opar

  //@@ get a new CBLOCK4
  XX             = CBLOCK4('define')

  //@@ set the size
  XX.graphics.sz = 20 *XX.graphics.sz

  //@@ load computational function
  toto=mgetl(rpat+'/'+rdnom+'.c')

  //@@ set the graphics exprs
  XX.graphics.exprs(1)(1)  = rdnom             //simulation function
  if impl_blk then
    XX.graphics.exprs(1)(2)  = 'y'            //implicit blck
  end
  XX.graphics.exprs(1)(3)  = sci2exp([capt(:,3),capt(:,4)],0)  //regular input port size
  XX.graphics.exprs(1)(4)  = sci2exp(scs_c_nb2scs_nb(capt(:,5)),0)  //regular input port type
  XX.graphics.exprs(1)(5)  = sci2exp([actt(:,3),actt(:,4)],0) //regular output port size
  XX.graphics.exprs(1)(6)  = sci2exp(scs_c_nb2scs_nb(actt(:,5)),0) //regular output port type
  XX.graphics.exprs(1)(7)  = '1'                   //event input port size
  XX.graphics.exprs(1)(8)  = '1'                   //event output port size
  XX.graphics.exprs(1)(9)  = sci2exp(x,0)          //continuous state
  XX.graphics.exprs(1)(10) = sci2exp(Z,0)          //discrete state
  //XX.graphics.exprs(1)(11) = sci2exp(new_oz,0)   //object state
  XX.graphics.exprs(1)(11) = new_oz_str            //object state
  XX.graphics.exprs(1)(12) = sci2exp(rpar,0)       //real parameters
  XX.graphics.exprs(1)(13) = sci2exp(ipar,0)       //ipar parameters
  XX.graphics.exprs(1)(14) = sci2exp(opar,0)       //opar parameters
  XX.graphics.exprs(1)(15) = sci2exp(nmode)        //number of modes
  XX.graphics.exprs(1)(16) = sci2exp(nzcross)      //number of zero crossings
  XX.graphics.exprs(1)(17) = sci2exp(firing)       //initial event date
  XX.graphics.exprs(1)(18) = 'n'                   //direct feedthrough
  if ALWAYS_ACTIVE then
    XX.graphics.exprs(1)(19) = 'y'                 //time dependence
  end
  //@@ put text of computational function
  //@@ in CBLOCK
  XX.graphics.exprs(2)=toto

  //@@ run 'set' job of the CBLOCK4
  prot=funcprot()
  funcprot(0)
  getvalue=setvalue;
  deff('message(txt)','x_message(''In block ''+XX.gui+'': ''+txt);global %scicos_prob;%scicos_prob=%t')
  deff('[ok,tt,cancel,'+...
        'libss,cflags] =  CC4(funam,tt,i,o,libss,cflags)','ok=%t,cancel=%f')
  %scicos_prob = %f
  XX = CBLOCK4('set',XX)
  funcprot(prot)

endfunction

function [XX]=gen_allblk()
//Copyright (c) 1989-2010 Metalau project INRIA

//@@ gen_allblk : creates the Scicos C generick block
//   associated to an entire diagram generated code
//
// Output : XX  : an informed CBLOCK4 scicos_block data structure
//

  //@@ adjust oz
  oz=cpr.state.oz;

  new_oz_str=[];
  for i=1:lstsize(oz)
    new_oz_str = [new_oz_str , sci2exp(oz(i),0)];
  end
  for i=1:lstsize(outtb)
    new_oz_str = [new_oz_str , 'zeros('+string(size(outtb(i),1))+','+string(size(outtb(i),2))+')'];
  end

  new_oz_str='list('+strcat(new_oz_str,',')+')';

  //@@ adjust z
  work=zeros(nblk,1);
  Z=[z;work]

  //@@ get nmode
  nmode = cpr.sim.modptr($)-1

  //@@ get nzcross
  nzcross = cpr.sim.zcptr($)-1

  //@@ get firing
  //firing = min(firing_evtout)
  if find(firing_evtout>=0)<>[] then
    firing = min(firing_evtout(find(firing_evtout>=0)))
  else
    firing = min(firing_evtout)
  end

  //@@ get rpar/ipar/opar
  rpar = cpr.sim.rpar
  ipar = cpr.sim.ipar
  opar = cpr.sim.opar

  //@@ get a new CBLOCK4
  XX             = CBLOCK4('define')

  //@@ set the size
  XX.graphics.sz = 20 *XX.graphics.sz

  //@@ load computational function
  toto=mgetl(rpat+'/'+rdnom+'.c')

  //@@ set the graphics exprs
  XX.graphics.exprs(1)(1)  = rdnom             //simulation function
  if impl_blk then
    XX.graphics.exprs(1)(2)  = 'y'            //implicit blck
  end

  //@@ add output for actuator
  out_siz=[];
  out_typ=[];

  if actt<>[] then
    for i=1:size(actt,1)
      out_siz=[out_siz;
               actt(i,3),actt(i,4)]
      out_typ=[out_typ;scs_c_nb2scs_nb(actt(i,5))]
    end
  end

  //@@ add input for sensor
  in_siz=[];
  in_typ=[];

  if capt<>[] then
    for i=1:size(capt,1)
      in_siz=[in_siz;
              capt(i,3),capt(i,4)]
      in_typ=[in_typ;scs_c_nb2scs_nb(capt(i,5))]
    end
  end
  
  XX.graphics.exprs(1)(3)  = sci2exp(in_siz,0)  //regular input port size
  XX.graphics.exprs(1)(4)  = sci2exp(in_typ,0)  //regular input port typ
  XX.graphics.exprs(1)(5)  = sci2exp(out_siz,0) //regular output port size
  XX.graphics.exprs(1)(6)  = sci2exp(out_typ,0) //regular output port typ
  if firing_evtout <> [] then
    XX.graphics.exprs(1)(7)  = '1'              //event input port size
    XX.graphics.exprs(1)(8)  = '1'              //event output port size
  else
    XX.graphics.exprs(1)(7)  = '[]'             //event input port size
    XX.graphics.exprs(1)(8)  = '[]'             //event output port size
  end
  XX.graphics.exprs(1)(9)  = sci2exp(x,0)       //continuous state
  XX.graphics.exprs(1)(10) = sci2exp(Z,0)       //discrete state
  //XX.graphics.exprs(1)(11) = sci2exp(new_oz,0) //object state
  XX.graphics.exprs(1)(11) = new_oz_str         //object state
  XX.graphics.exprs(1)(12) = sci2exp(rpar,0)    //real parameters
  XX.graphics.exprs(1)(13) = sci2exp(ipar,0)    //ipar parameters
  XX.graphics.exprs(1)(14) = sci2exp(opar,0)    //opar parameters
  XX.graphics.exprs(1)(15) = sci2exp(nmode)     //number of modes
  XX.graphics.exprs(1)(16) = sci2exp(nzcross)   //number of zero crossings
  XX.graphics.exprs(1)(17) = sci2exp(firing)    //initial event date
  XX.graphics.exprs(1)(18) = 'n'                //direct feedthrough
  if ALL then
    if ALWAYS_ACTIVE_ALL then
      XX.graphics.exprs(1)(19) = 'y'              //time dependence
    end
  else
    if ALWAYS_ACTIVE then
      XX.graphics.exprs(1)(19) = 'y'              //time dependence
    end
  end

  //@@ put text of computational function
  //@@ in CBLOCK
  XX.graphics.exprs(2)=toto

  //@@ run 'set' job of the CBLOCK4
  prot=funcprot()
  funcprot(0)
  getvalue=setvalue;
  deff('message(txt)','x_message(''In block ''+XX.gui+'': ''+txt);global %scicos_prob;%scicos_prob=%t')
  deff('[ok,tt,cancel,'+...
        'libss,cflags] =  CC4(funam,tt,i,o,libss,cflags)','ok=%t,cancel=%f')
  %scicos_prob = %f
  XX = CBLOCK4('set',XX)
  funcprot(prot)

endfunction

function [ok,c_atomic_code]=gen_atomic_ccode42();
//Copyright (c) 1989-2010 Metalau project INRIA

//** Generate code for atomic scicos block
//** Fady Nassif, inital rev 10/12/07

  Code=make_computational42()
  [CCode,FCode]=gen_blocks()
//   flag_no_ccode = %f;
//   if lstsize(CCode)==1 then
//     for i=1:size(CCode(1),1)
//       if CCode(1)(i)=='void no_ccode()' then flag_no_ccode = %t, end
//       if flag_no_ccode then
//         if CCode(1)(i)=='}' then flag_no_ccode = %f, end
//         CCode(1)(i)='//'+CCode(i)
//       end
//     end
//   end
  CodeC=[]
  for i=1:2:lstsize(CCode)
    CodeC=[CodeC;CCode(i+1);'']
  end
  c_atomic_code=[Code;CodeC]
  //c_atomic_code=Code
endfunction

function [ccode]=gen_blk4_code(tt)
//Copyright (c) 1989-2010 Metalau project INRIA
//
//@@ gen_blk4_code : generation of a ScicosLab function
//                   that returns the code of scicos blocks
//                   of type 4 & 10004
//
// Input : tt : vector of string of compuational function
//              name
//
// Output : ccode : the output code
//
// Use :
// --> [tt]=blk4_lst();[ccode]=gen_blk4_code(tt);
// --> mputl(ccode,'/home/alan/get_blk4_code.sci');
//

  ccode=['function [txt]=get_blk4_code(name)'
         '//Copyright (c) 1989-2010 Metalau project INRIA'
         '//'
         '//@@ get_blk4_code : extract code of scicos blocks'
         '//                   of type 4 & 10004'
         '//'
         '// Input : name : name of a scicos computational function'
         '//                of type 4 or 10004'
         '//'
         '// Output : txt : the output code'
         ''
         '  txt=[];'
         ''
         '  select name']

  for i=1:size(tt,1)
    code=extract_ccode(tt(i))
    if code<>[] then
      ccode=[ccode;
             '      case '''+tt(i)+''' then'
             '        '+get_txt_code(code)
             '']
    end
  end

  ccode=[ccode;'  end';'endfunction']

endfunction

function txt=get_txt_code(code)
//Copyright (c) 1989-2010 Metalau project INRIA
//
//@@ get_txt_code : convert string to scicoslab expression
//                  equivalent to sci2exp but
//                  do what we want
//
// Input : code : vector of string of croutine
//
// Output : txt : the output expression
//

  txt=[]

  code=strsubst(code,'""','""""');
  code=strsubst(code,'''','''''');
  code=strsubst(code,'../machine.h','machine.h');

  code='""'+code+'""'

  code(1)='txt = ['+code(1)
  code(2:$)='       '+code(2:$)
  code($)=code($)+']'

  txt=code;

endfunction

function [ccode]=extract_ccode(nam)
//Copyright (c) 1989-2010 Metalau project INRIA
//
//@@ extract_ccode : get code from default routine
//                   ScicosLab directory
//
// Input : nam : string of file name to read
//
// Output : ccode : the contents of the file
//

  ccode=[]

  rout_path='SCI/routines/scicos'

  if fileinfo(rout_path+'/'+nam+'.c') <> [] then
    ccode=mgetl(rout_path+'/'+nam+'.c')
  end

  //@@ adjust evaluate_expr for lcc
  if nam=='evaluate_expr' then
    for i=size(ccode,1):-1:1
      if(strindex(ccode(i),'#if WIN32'))<>[] then
        ccode(i)=strsubst(ccode(i),'#if WIN32','#if __MSC__')
        break
      end
    end
  end

endfunction

function [tt]=blk4_lst()
//Copyright (c) 1989-2010 Metalau project INRIA
//
//@@ blk4_lst : get list of computational function of
//              type 4 & 10004
//
// Output : tt : vector of strings that contains
//               the name of computational function
//               of type 4 & 10004
//

  tt=[]

  [j,TXT]=create_palette(%f)

  load SCI/macros/scicos/lib;
  exec(loadpallibs,-1)

  gname=[]

  for i=1:size(TXT,1)
    [xpath,name,ext]=splitfilepath(TXT(i))
    gname=[gname;name]
  end

  //@@ call get_sim4_name
  tt = get_sim4_name(gname)

  //@@ add m_frequ
  if tt<>[] then
    tt=[tt;'m_frequ']
  end

  //@@ add dgelsy1
  if tt<>[] then
    tt=[tt;'dgelsy1']
  end

  if tt<>[] then
    tt=sort_vector_string2(tt,'i');
  end
endfunction

function [sim]=get_sim4_name(name)
//Copyright (c) 1989-2010 Metalau project INRIA
//
//@@ get_sim4_name : recursive function to known
//                   which block of type 4 or 10004 are used
//                   inside scicos
//
// Input : name : vector string of scicos blocks GUI
//
// Output : sim : vector of strings that contains
//                the name of computational function
//                of type 4 & 10004
//

  sim=[]

  for i=1:size(name,1)
    execstr('o='+name(i)+'(''define'')');

    if type(o.model.sim)==15 then
      if (o.model.sim(2)==4) | (o.model.sim(2)==10004) then
        sim=[sim;o.model.sim(1)]
      end
    elseif type(o.model.sim)==10 then
      if o.model.sim == 'csuper' then
        gname = []
        for j=1:lstsize(o.model.rpar.objs)
          if typeof(o.model.rpar.objs(j))=='Block' then
            gname=[gname;o.model.rpar.objs(j).gui]
          end
        end
        sim=[sim;get_sim4_name(gname)]
      end
    end
  end

endfunction

function [vv]=sort_vector_string2(v,flag)
//Copyright (c) 1989-2010 Metalau project INRIA
//
//@@ sort_vector_string2 : Coming from scicos tests.
//                         Update : remove doublon
//
// Input : v : vector string to be sorted
//         flag : a flag for gsort
//
// Output : vv : sorted vector of strings
//

  vv=[];

  for i=1:size(v,'*')
    val=ascii(v(i));
    if val(1)>97 & val(1)<122 then
       val(1)=val(1)-32;
    end
    vv=[vv;ascii(val)];
  end

  [vv,k]=gsort(vv,'g',flag);
  vv=v(k(:));

  //@@ remove doublon
  vvv=[]

  for i=1:size(vv,1)
    if find(vv(i)==vvv)==[] then
       vvv=[vvv;vv(i)]
    end
  end

  vv=vvv

endfunction

function [CCode,FCode]=gen_blocks()
//Copyright (c) 1989-2010 Metalau project INRIA

//@@ gen_blocks : generates code for dynamically
//                linked Fortran and C blocks
//
// Output : CCode/FCode list, pair of name/routines contents
//

  //@@ initial empty lists
  CCode=list()
  FCode=list()

  //## look at for the modelica block
  kdyn=find(funtyp==10004);
  ind=[]
  if (size(kdyn,'*')>=1)
    for i=1:size(kdyn,'*')
      if type(corinv(kdyn(i)))==15 then
        ind=kdyn(i);
        break;
      end
    end
  end

  if ind<>[] then
    CCode($+1)=funs(ind)
    CCode($+1)=mgetl(TMPDIR+'/'+funs(ind)+'.c');
  end

  //## remove implicit number
  funtyp=modulo(funtyp,10000)

  kdyn=find(funtyp>1000) //dynamically linked blocs
                         //100X : Fortran blocks
                         //200X : C blocks

  //@@ many dynamical computational functions
  if (size(kdyn,'*') >1)
    kfuns=[];
    //get the block data structure in the initial scs_m structure
    if size(corinv(kdyn(1)),'*')==1 then
      O=scs_m.objs(corinv(kdyn(1)));
    else
      path=list('objs');
      for l=corinv(kdyn(1))(1:$-1)
        path($+1)=l;
        path($+1)='model';
        path($+1)='rpar';
        path($+1)='objs';
      end
      path($+1)=corinv(kdyn(1))($);
      O=scs_m(path);
    end
    if funtyp(kdyn(1))>2000 then
      //C block
      CCode($+1)=funs(kdyn(1))
      CCode($+1)=O.graphics.exprs(2)
    else
      //Fortran block
      FCode($+1)=funs(kdyn(1))
      FCode($+1)=O.graphics.exprs(2)
    end
    kfuns=funs(kdyn(1));
    for i=2:size(kdyn,'*')
      //get the block data structure in the initial scs_m structure
      if size(corinv(kdyn(i)),'*')==1 then
        O=scs_m.objs(corinv(kdyn(i)));
      else
        path=list('objs');
         for l=corinv(kdyn(i))(1:$-1)
           path($+1)=l;
           path($+1)='model';
           path($+1)='rpar';
           path($+1)='objs';
        end
        path($+1)=corinv(kdyn(i))($);
        O=scs_m(path);
      end
      if (find(kfuns==funs(kdyn(i))) == [])
        kfuns=[kfuns;funs(kdyn(i))];
        if funtyp(kdyn(i))>2000  then
          //C block
          CCode($+1)=funs(kdyn(i))
          CCode($+1)=O.graphics.exprs(2)
        else
          //Fortran block
          FCode($+1)=funs(kdyn(1))
          FCode($+1)=O.graphics.exprs(2)
        end
      end
    end
  //@@ one dynamical computational function
  elseif (size(kdyn,'*')==1)
    //get the block data structure in the initial scs_m structure
    if size(corinv(kdyn),'*')==1 then
      O=scs_m.objs(corinv(kdyn));
    else
      path=list('objs');
      for l=corinv(kdyn)(1:$-1)
        path($+1)=l;
        path($+1)='model';
        path($+1)='rpar';
        path($+1)='objs';
      end
      path($+1)=corinv(kdyn)($);
      O=scs_m(path);
    end
    if funtyp(kdyn)>2000 then
      //C block
      CCode($+1)=funs(kdyn)
      CCode($+1)=O.graphics.exprs(2)
    else
      //Fortran block
      FCode($+1)=funs(kdyn(1))
      FCode($+1)=O.graphics.exprs(2)
    end
  end

  //@@ A special case for block of type 4 or 10004
  //@@ that use get_scicos_time/do_cold_restart/get_phase_simulation
  //@@ is done here with the help of the function get_blk4_code
  //@@
  //@@ other routines of scicos blocks can also be included
  //@@
  //@@ warning we use cpr :
  if ALL then
    cod_include=[]
    for kf=1:size(cpr.sim.funtyp,1)
      if (cpr.sim.funtyp(kf)==4) | (cpr.sim.funtyp(kf)==10004) then
        if find(cpr.sim.funs(kf)==cod_include)==[] then
          cod=get_blk4_code(cpr.sim.funs(kf))
          if cod<>[] then
            for i=1:size(cod,1)
              if strindex(cod(i),'get_scicos_time')<>[] then
                cod_include=[cod_include;cpr.sim.funs(kf)]
                CCode($+1)=cpr.sim.funs(kf)
                CCode($+1)=cod
                break
              elseif strindex(cod(i),'do_cold_restart')<>[] then
                cod_include=[cod_include;cpr.sim.funs(kf)]
                CCode($+1)=cpr.sim.funs(kf)
                CCode($+1)=cod
                break
              elseif strindex(cod(i),'get_phase_simulation')<>[] then
                cod_include=[cod_include;cpr.sim.funs(kf)]
                CCode($+1)=cpr.sim.funs(kf)
                CCode($+1)=cod
                break
              end
            end
          end
        end
      end
    end
    //@@ extract dgelsy1
    for kf=1:lstsize(cpr.sim.funs)
      if cpr.sim.funs(kf)=='mat_bksl' | cpr.sim.funs(kf)=='mat_div' then
        cod=get_blk4_code('dgelsy1')
        CCode($+1)='dgelsy1'
        CCode($+1)=cod
        break
      end
    end
  end

  if CCode==list()
//     CCode($+1)=['void no_ccode()'
//                 '{'
//                 '  return;'
//                 '}']
  end
endfunction

function [ok,Cblocks_files,solver_files]=gen_ccode42()
//Copyright (c) 1989-2010 Metalau project INRIA

//** gen_ccode42 : generates the C code for new block simulation
//
// Output : ok          : output flag to say if the generation
//                        is ok
//          blocks_file : vector of string of the name of the
//                        generated scicos blocks
//

  //@@ define blocks_files
  Cblocks_files=[]
  //@@ define solver_files
  solver_files=[]

  //## Remove affich blocks
  cpr=cpr;
  if ALL then cpr_save=cpr, end;

  for i=1:lstsize(cpr.sim.funs)
    //## look at for funs of type string
    if type(cpr.sim.funs(i))==10 then
      if cpr.sim.funs(i)=='affich' then
        cpr.sim.funs(i) ='bidon'
        cpr.sim.funtyp(i) = 0
      elseif cpr.sim.funs(i)=='affich2' then
        cpr.sim.funs(i) ='bidon'
        cpr.sim.funtyp(i) = 0
      end
    end
  end

  //** Generate code for scicos block
  Code=make_computational42()

  ierr=execstr('mputl(Code,rpat+''/''+rdnom+''.c'')','errcatch')
  if ierr<>0 then
    message(lasterror())
    ok=%f
    return
  end

  //@@ change scope to actuators
  if ALL then
    cpr=cpr_save;
    [nbact,act,actt,cpr]=blocks_to_actuators([list_of_scopes(:,1);
                                              'affich';
                                              'affich2';
                                              'writec';
                                              'writef';
                                              'writeau';
                                              'tows_c'],...
                                              nbact,act,actt,cpr)
  end

  //** Generate _void_io.c
  Code=make_void_io()

  ierr=execstr('mputl(Code,rpat+''/''+rdnom+''_void_io.c'')','errcatch')
  if ierr<>0 then
    message(lasterror())
    ok=%f
    return
  end

  //** Generate files for dynamically linked scicos blocks
  [CCode,FCode]=gen_blocks()
  if FCode<>list() then
    fcod=[]
    for i=1:2:lstsize(FCode)
      fcod=[fcod;FCode(i+1);'']
    end
    ierr=execstr('mputl(fcod,rpat+''/''+rdnom+''f.f'')','errcatch')
    if ierr<>0 then
      message(lasterror())
      ok=%f
      return
    end
  end

  //@@
  if CCode<>list() then
    CodeC=[]
    //@@ test for blocks directory
    if ~MSDOS then
      //rpat_blocks=rpat+'/cblocks'
      rpat_blocks=rpat
    else
      //rpat_blocks=rpat+'\cblocks'
      rpat_blocks=rpat
    end
    dirinfo=fileinfo(rpat_blocks)
    if dirinfo==[] then
      [pathrp,fnamerp,extensionrp]=fileparts(rpat_blocks)
      if ~MSDOS then
        fnamerp=strsubst(fnamerp," ",""" """)
      end
      ok=mkdir(pathrp,fnamerp+extensionrp)
      if ~ok then
        x_message('Directory '+rpat_blocks+' cannot be created');
        return
      end
    elseif filetype(dirinfo(2))<>'Directory' then
      ok=%f;
      x_message(rpat_blocks+' is not a directory');
      return
    end

    //@@include scicos_block/scicos_block4.h
    txt=mgetl(SCI+'/routines/scicos/scicos_block4.h');
    txt=['/* Scicos computational function header */'
         '/*     Extracted by Code_Generation toolbox of Scicos with '+ ..
            get_scicos_version()+' */'
         '/*     date : '+date()+' */'
         ''
         '/* Copyright (c) 1989-2010 Metalau project INRIA */'
         ''
         txt]
    ierr=execstr('mputl(txt,rpat_blocks+''/scicos_block4.h'')','errcatch')
    if ierr<>0 then
      message(lasterror())
      ok=%f
      return
    end

    txt=mgetl(SCI+'/routines/scicos/scicos_block.h');
    txt=['/* Scicos computational function header */'
         '/*     Extracted by Code_Generation toolbox of Scicos with '+ ..
            get_scicos_version()+' */'
         '/*     date : '+date()+' */'
         ''
         '/* Copyright (c) 1989-2010 Metalau project INRIA */'
         ''
         txt]
    ierr=execstr('mputl(txt,rpat_blocks+''/scicos_block.h'')','errcatch')
    if ierr<>0 then
      message(lasterror())
      ok=%f
      return
    end

    for i=1:2:lstsize(CCode)
      CCode(i+1)=['/* Code of '+CCode(i)+' routine */'
                  '/*     Extracted by Code_Generation toolbox of Scicos with '+ ..
                     get_scicos_version()+' */'
                  '/*     date : '+date()+' */'
                  ''
                  '/* Copyright (c) 1989-2010 Metalau project INRIA */'
                  ''
                  CCode(i+1)]

      ierr=execstr('mputl(CCode(i+1),rpat_blocks+''/''+CCode(i)+''.c'')','errcatch')
      if ierr<>0 then
        message(lasterror())
        ok=%f
        return
      else
        if find(Cblocks_files==CCode(i))==[] then
          Cblocks_files = [Cblocks_files CCode(i)]
        end
      end
    end
  end

  //## Add optional standalone code generation
  if sta__#<>0 then
    //** Generate _standalone.c
    if ~ALL then
      Code=make_standalone42()
    else
      [Code,Code_xml_param]=make_standalone43()
    end

    ierr=execstr('mputl(Code,rpat+''/''+rdnom+''_standalone.c'')','errcatch')
    if ierr<>0 then
      message(lasterror())
      ok=%f
      return
    end

    //@@ write a rdnom_params.xml file
    if ALL then
      ierr=execstr('mputl(Code_xml_param,rpat+''/''+rdnom+''_params.xml'')','errcatch')
      if ierr<>0 then
        message(lasterror())
        ok=%f
        return
      end
    end

    //## Generate intrdnom_sci.c
    if ALL then
      Code=make_sci_interf43()
    else
      Code=make_sci_interf()
    end

    ierr=execstr('mputl(Code,rpat+''/int''+rdnom+''_sci.c'')','errcatch')
    if ierr<>0 then
      message(lasterror())
      ok=%f
      return
    end

    //** copy source code of machine.h/scicos_block4.h
    //   in target path
    txt=mgetl(SCI+'/routines/machine.h');
    ierr=execstr('mputl(txt,rpat+''/machine.h'')','errcatch')
    if ierr<>0 then
      message(lasterror())
      ok=%f
      return
    end

    txt=mgetl(SCI+'/routines/scicos/scicos_block4.h');
    txt=['/* Scicos computational function header */'
         '/*     Extracted by Code_Generation toolbox of Scicos with '+ ..
            get_scicos_version()+' */'
         '/*     date : '+date()+' */'
         ''
         '/* Copyright (c) 1989-2010 Metalau project INRIA */'
         ''
         txt]
    ierr=execstr('mputl(txt,rpat+''/scicos_block4.h'')','errcatch')
    if ierr<>0 then
      message(lasterror())
      ok=%f
      return
    end

    txt=mgetl(SCI+'/routines/scicos/scicos_block.h');
    txt=['/* Scicos computational function header */'
         '/*     Extracted by Code_Generation toolbox of Scicos with '+ ..
            get_scicos_version()+' */'
         '/*     date : '+date()+' */'
         ''
         '/* Copyright (c) 1989-2010 Metalau project INRIA */'
         ''
         txt]
    ierr=execstr('mputl(txt,rpat+''/scicos_block.h'')','errcatch')
    if ierr<>0 then
      message(lasterror())
      ok=%f
      return
    end

    //## Generate solver codes
    if nxtotal<>0 then
      if impl_blk then
        [ok]=get_solver_code('IDA')
      else
        [ok]=get_solver_code('CVODE')
      end
      if ~ok then return, end
    end

    //## Generate _act_sens_events.c
    [Code]=make_act_sens_events()

    created=[]
    reponse=[]

    created=fileinfo(rpat+'/'+rdnom+'_act_sens_events.c')

    if ~silent_mode then
      if created~=[] then
        reponse=x_message(['File: ""'+rdnom+'_act_sens_events.c"" already exists,';
                           'do you want to replace it ?'],['Yes','No'])
      end
    else
      reponse=1
    end

    if reponse==1 |  reponse==[] then
      ierr=execstr('mputl(Code,rpat+''/''+rdnom+''_act_sens_events.c'')', ...
                   'errcatch')
      if ierr<>0 then
        message(lasterror())
        ok=%f
        return
      end
    end
  end
endfunction

function [ok]=gen_gui42()
//Copyright (c) 1989-2010 Metalau project INRIA

//@@ gen_gui42 : creates the Scicos GUI function associated
//               with the new block
//
// Output : ok : output flag to say if the generation  is ok
//

  clkinput=ones(clkIN)';
  clkoutput=ones(clkOUT)';
  //outtb=outtb;
  oz=cpr.state.oz;

  new_oz_str=[];
  for i=1:lstsize(oz)
    new_oz_str = [new_oz_str , sci2exp(oz(i),0)];
  end
  for i=1:lstsize(outtb)
    new_oz_str = [new_oz_str , 'zeros('+string(size(outtb(i),1))+','+string(size(outtb(i),2))+')'];
  end

  new_oz_str='list('+strcat(new_oz_str,',...'+ascii(10)+'                ')+')';

  //outtb($+1) = zeros(nblk,1);
  Code=['function [x,y,typ]='+rdnom+'_c(job,arg1,arg2)';
        '//Scicos interfacing function'
        '//Generated by Code_Generation toolbox of Scicos with '+ ..
        get_scicos_version()
        '// date : '+date()
        ''
        '//Copyright (c) 1989-2010 Metalau project INRIA'
        ''
        ' x=[];y=[];typ=[];';
        ' select job';
        ' case ''plot'' then';
        '   standard_draw(arg1)';
        ' case ''getinputs'' then';
        '   [x,y,typ]=standard_inputs(arg1)';
        ' case ''getoutputs'' then';
        '   [x,y,typ]=standard_outputs(arg1)';
        ' case ''getorigin'' then';
        '   [x,y]=standard_origin(arg1)';
        ' case ''set'' then';
        '   x=arg1;';
        ' case ''define'' then'
        '   '+sci2exp(capt(:,3),'in',70); //input ports sizes 1
        '   '+sci2exp(capt(:,4),'in2',70); //input ports sizes 2
        '   '+sci2exp(scs_c_nb2scs_nb(capt(:,5)),'intyp',70); //input ports type
        '   '+sci2exp(actt(:,3),'out',70); //output ports sizes 1
        '   '+sci2exp(actt(:,4),'out2',70); //output ports sizes 2
        '   '+sci2exp(scs_c_nb2scs_nb(actt(:,5)),'outtyp',70); //output ports type
        '   '+sci2exp(x,'x',70); //initial continuous state
        '   '+sci2exp(z,'z',70); //initial discrete state
        '   work=zeros('+string(nblk)+',1)';
        '   Z=[z;work]';
        '   odstate='+new_oz_str
        //'   '+sci2exp(new_oz,'odstate',70);
        '   '+sci2exp(cpr.sim.rpar,'rpar',70); //real parameters
        '   '+sci2exp(cpr.sim.ipar,'ipar',70); //integer parameters
        '   '+sci2exp(cpr.sim.opar,'opar',70); //object parameters
       ]

  if ALL & firing_evtout <> [] then
    if find(firing_evtout>=0)<>[] then
      firing = min(firing_evtout(find(firing_evtout>=0)))
    else
      firing = min(firing_evtout)
    end
    Code=[Code;
          '   '+sci2exp(1,'clkinput',70);
          '   '+sci2exp(1,'clkoutput',70);
          '   '+sci2exp(firing,'firing',70);]
  else
    Code=[Code;
          '   '+sci2exp(clkinput,'clkinput',70);
          '   '+sci2exp(clkoutput,'clkoutput',70);
          '   '+sci2exp(FIRING,'firing',70);]
  end

  Code=[Code;
        '   nzcross='+string(sum(cpr.sim.zcptr(2:$)-cpr.sim.zcptr(1:$-1)))';
        '   nmode='+string(sum(cpr.sim.modptr(2:$)-cpr.sim.modptr(1:$-1)))';]

  for i=1:length(bllst)
    deput=[depu_vec',%f]
    if (bllst(i).dep_ut($) == %t) then
      deput(1,$)=%t;
      break;
    end
  end
  Code($+1)='   '+sci2exp(deput,'dep_ut',70);
  if impl_blk then
    Code=[Code
          '   model=scicos_model(sim=list('''+rdnom+''',10004),..']
  else
    Code=[Code
          '   model=scicos_model(sim=list('''+rdnom+''',4),..']
  end
  Code=[Code
        '                      in=in,..'
        '                      in2=in2,..'
        '                      intyp=intyp,..'
        '                      out=out,..'
        '                      out2=out2,..'
        '                      outtyp=outtyp,..'
        '                      evtin=clkinput,..'
        '                      evtout=clkoutput,..'
        '                      firing=firing,..'
        '                      state=x,..'
        '                      dstate=Z,..'
        '                      odstate=odstate,..'
        '                      rpar=rpar,..'
        '                      ipar=ipar,..'
        '                      opar=opar,..'
        '                      blocktype=''c'',..'
        '                      dep_ut=dep_ut,..'
        '                      nzcross=nzcross,..'
        '                      nmode=nmode)'
        '   gr_i=''xstringb(orig(1),orig(2),'''''+rdnom+''''',sz(1),..'
        '          sz(2),''''fill'''')''';
        '   x=standard_define([2 2],model,[],gr_i)';
        ' end'
        'endfunction'];
  //Create file
  ierr=execstr('mputl(Code,rpat+''/''+rdnom+''_c.sci'')','errcatch')
  if ierr<>0 then
    message(lasterror())
    ok=%f
  end
endfunction

function [ccode]=gen_solver_code()
//Copyright (c) 1989-2010 Metalau project INRIA
//
//@@ gen_solver_code : generation of a ScicosLab function
//                   that returns the code of solver
//
// Output : ccode : the output code
//
// Use :
// --> [ccode]=gen_solver_code();
// --> mputl(ccode,'/home/alan/get_solver_file_code.sci');
//
  curdir = getcwd();
  
  chdir('SCI/routines/scicos/sundials');
  lisf=listfiles('*.h') 
  lisf=[lisf;'LICENSE']

  ccode=['function [txt]=get_solver_file_code(name)'
         '//Copyright (c) 1989-2010 Metalau project INRIA'
         '//'
         '//@@ get_solver_file_code : extract code of solver'
         '//'
         '// Input : name : name of a solver file'
         '//'
         '// Output : txt : the output code'
         ''
         '  txt=[];'
         ''
         '  select name']

  for i=1:size(lisf,1)
    code=mgetl(lisf(i))
    if code<>[] then
      ccode=[ccode;
             '      case '''+lisf(i)+''' then'
             '        '+get_solver_txt_code(code)
             '']
    end
  end

  ccode=[ccode;'  end';'endfunction']

  chdir(curdir)
endfunction

function txt=get_solver_txt_code(code)
//Copyright (c) 1989-2010 Metalau project INRIA
//
//@@ get_solver_txt_code : convert string to scicoslab expression
//                  equivalent to sci2exp but
//                  do what we want
//
// Input : code : vector of string of croutine
//
// Output : txt : the output expression
//

  txt=[]

  code=strsubst(code,'""','""""');
  code=strsubst(code,'''','''''');

  code='""'+code+'""'

  code(1)='txt = ['+code(1)
  code(2:$)='       '+code(2:$)
  code($)=code($)+']'

  txt=code;

endfunction

function [ok]=get_solver_code(s_name)
//Copyright (c) 1989-2010 Metalau project INRIA
//
//@@ get_solver_code : generation of solvers code
//                     used by scicos standalone
//                     in rpat
//
// Input : s_name : solver name
//                  'CVODE' : sundials CVODE
//                  'IDA'   : sundials IDA
//
// Output : ok : ok flag
//

  //@@ initial lhs
  ok=%t
  solver_files=[]

  //@@ SUNDIALS @@
  if s_name=='CVODE' | s_name=='IDA' then
    //@@ test for solver directory
    if ~MSDOS then
      rpat_solv=rpat+'/solver'
    else
      rpat_solv=rpat+'\solver'
    end
    dirinfo=fileinfo(rpat_solv)
    if dirinfo==[] then
      [pathrp,fnamerp,extensionrp]=fileparts(rpat_solv)
      if ~MSDOS then
        fnamerp=strsubst(fnamerp," ",""" """)
      end
      ok=mkdir(pathrp,fnamerp+extensionrp)
      if ~ok then
        x_message('Directory '+rpat_solv+' cannot be created');
        return
      end
    elseif filetype(dirinfo(2))<>'Directory' then
      ok=%f;
      x_message(rpat_solv+' is not a directory');
      return
    end

    //@@ License
    if fileinfo(SCI+'/routines/scicos/sundials/LICENSE')<>[] then
      txt=mgetl(SCI+'/routines/scicos/sundials/LICENSE');
    else
      txt=get_solver_file_code('LICENSE');
    end
    ierr=execstr('mputl(txt,rpat+''/solver/LICENSE'')','errcatch')
    if ierr<>0 then
      message(lasterror())
      ok=%f
      return
    end

    //@@ headers
    if fileinfo(SCI+'/routines/scicos/sundials/sundials_types.h')<>[] then
      txt=mgetl(SCI+'/routines/scicos/sundials/sundials_types.h');
    else
      txt=get_solver_file_code('sundials_types.h');
    end
    ierr=execstr('mputl(txt,rpat+''/solver/sundials_types.h'')','errcatch')
    if ierr<>0 then
      message(lasterror())
      ok=%f
      return
    end

    if fileinfo(SCI+'/routines/scicos/sundials/sundials_math.h')<>[] then
      txt=mgetl(SCI+'/routines/scicos/sundials/sundials_math.h');
    else
      txt=get_solver_file_code('sundials_math.h');
    end
    ierr=execstr('mputl(txt,rpat+''/solver/sundials_math.h'')','errcatch')
    if ierr<>0 then
      message(lasterror())
      ok=%f
      return
    end

    if fileinfo(SCI+'/routines/scicos/sundials/nvector_serial.h')<>[] then
      txt=mgetl(SCI+'/routines/scicos/sundials/nvector_serial.h');
    else
      txt=get_solver_file_code('nvector_serial.h');
    end
    ierr=execstr('mputl(txt,rpat+''/solver/nvector_serial.h'')','errcatch')
    if ierr<>0 then
      message(lasterror())
      ok=%f
      return
    end

    if fileinfo(SCI+'/routines/scicos/sundials/sundials_nvector.h')<>[] then
      txt=mgetl(SCI+'/routines/scicos/sundials/sundials_nvector.h');
    else
      txt=get_solver_file_code('sundials_nvector.h');
    end
    ierr=execstr('mputl(txt,rpat+''/solver/sundials_nvector.h'')','errcatch')
    if ierr<>0 then
      message(lasterror())
      ok=%f
      return
    end

    if fileinfo(SCI+'/routines/scicos/sundials/sundials_config.h')<>[] then
      txt=mgetl(SCI+'/routines/scicos/sundials/sundials_config.h');
    else
      txt=get_solver_file_code('sundials_config.h');
    end
    ierr=execstr('mputl(txt,rpat+''/solver/sundials_config.h'')','errcatch')
    if ierr<>0 then
      message(lasterror())
      ok=%f
      return
    end

    if fileinfo(SCI+'/routines/scicos/sundials/sundials_dense.h')<>[] then
      txt=mgetl(SCI+'/routines/scicos/sundials/sundials_dense.h');
    else
      txt=get_solver_file_code('sundials_dense.h');
    end
    ierr=execstr('mputl(txt,rpat+''/solver/sundials_dense.h'')','errcatch')
    if ierr<>0 then
      message(lasterror())
      ok=%f
      return
    end

    if fileinfo(SCI+'/routines/scicos/sundials/sundials_smalldense.h')<>[] then
      txt=mgetl(SCI+'/routines/scicos/sundials/sundials_smalldense.h');
    else
      txt=get_solver_file_code('sundials_smalldense.h');
    end
    ierr=execstr('mputl(txt,rpat+''/solver/sundials_smalldense.h'')','errcatch')
    if ierr<>0 then
      message(lasterror())
      ok=%f
      return
    end

    //@@ C sources
    if fileinfo(SCI+'/routines/scicos/sundials/sundials_math.c')<>[] then
      txt=mgetl(SCI+'/routines/scicos/sundials/sundials_math.c');
      ierr=execstr('mputl(txt,rpat+''/solver/sundials_math.c'')','errcatch')
      if ierr<>0 then
        message(lasterror())
        ok=%f
        return
      end
      solver_files=[solver_files 'sundials_math']
    end

    if fileinfo(SCI+'/routines/scicos/sundials/nvector_serial.c')<>[] then
      txt=mgetl(SCI+'/routines/scicos/sundials/nvector_serial.c');
      ierr=execstr('mputl(txt,rpat+''/solver/nvector_serial.c'')','errcatch')
      if ierr<>0 then
        message(lasterror())
        ok=%f
        return
      end
      solver_files=[solver_files 'nvector_serial']
    end

    if fileinfo(SCI+'/routines/scicos/sundials/sundials_nvector.c')<>[] then
      txt=mgetl(SCI+'/routines/scicos/sundials/sundials_nvector.c');
      ierr=execstr('mputl(txt,rpat+''/solver/sundials_nvector.c'')','errcatch')
      if ierr<>0 then
        message(lasterror())
        ok=%f
        return
      end
      solver_files=[solver_files 'sundials_nvector']
    end

    if fileinfo(SCI+'/routines/scicos/sundials/sundials_dense.c')<>[] then
      txt=mgetl(SCI+'/routines/scicos/sundials/sundials_dense.c');
      ierr=execstr('mputl(txt,rpat+''/solver/sundials_dense.c'')','errcatch')
      if ierr<>0 then
        message(lasterror())
        ok=%f
        return
      end
      solver_files=[solver_files 'sundials_dense']
    end

    if fileinfo(SCI+'/routines/scicos/sundials/sundials_smalldense.c')<>[] then
      txt=mgetl(SCI+'/routines/scicos/sundials/sundials_smalldense.c');
      ierr=execstr('mputl(txt,rpat+''/solver/sundials_smalldense.c'')','errcatch')
      if ierr<>0 then
        message(lasterror())
        ok=%f
        return
      end
      solver_files=[solver_files 'sundials_smalldense']
    end

  end

  //@@@@ IDA @@@@
  if s_name=='IDA' then
    //@@ headers
    if fileinfo(SCI+'/routines/scicos/sundials/ida.h')<>[] then
      txt=mgetl(SCI+'/routines/scicos/sundials/ida.h');
    else
      txt=get_solver_file_code('ida.h');
    end
    ierr=execstr('mputl(txt,rpat+''/solver/ida.h'')','errcatch')
    if ierr<>0 then
      message(lasterror())
      ok=%f
      return
    end

    if fileinfo(SCI+'/routines/scicos/sundials/ida_dense.h')<>[] then
      txt=mgetl(SCI+'/routines/scicos/sundials/ida_dense.h');
    else
      txt=get_solver_file_code('ida_dense.h');
    end
    ierr=execstr('mputl(txt,rpat+''/solver/ida_dense.h'')','errcatch')
    if ierr<>0 then
      message(lasterror())
      ok=%f
      return
    end

    if fileinfo(SCI+'/routines/scicos/sundials/ida_impl.h')<>[] then
      txt=mgetl(SCI+'/routines/scicos/sundials/ida_impl.h');
    else
      txt=get_solver_file_code('ida_impl.h');
    end
    ierr=execstr('mputl(txt,rpat+''/solver/ida_impl.h'')','errcatch')
    if ierr<>0 then
      message(lasterror())
      ok=%f
      return
    end

    //@@ C sources
    if fileinfo(SCI+'/routines/scicos/sundials/ida.c')<>[] then
      txt=mgetl(SCI+'/routines/scicos/sundials/ida.c');
      ierr=execstr('mputl(txt,rpat+''/solver/ida.c'')','errcatch')
      if ierr<>0 then
        message(lasterror())
        ok=%f
        return
      end
      solver_files=[solver_files 'ida']
    end

    if fileinfo(SCI+'/routines/scicos/sundials/ida_dense.c')<>[] then
      txt=mgetl(SCI+'/routines/scicos/sundials/ida_dense.c');
      ierr=execstr('mputl(txt,rpat+''/solver/ida_dense.c'')','errcatch')
      if ierr<>0 then
        message(lasterror())
        ok=%f
        return
      end
      solver_files=[solver_files 'ida_dense']
    end

    if fileinfo(SCI+'/routines/scicos/sundials/ida_ic.c')<>[] then
      txt=mgetl(SCI+'/routines/scicos/sundials/ida_ic.c');
      ierr=execstr('mputl(txt,rpat+''/solver/ida_ic.c'')','errcatch')
      if ierr<>0 then
        message(lasterror())
        ok=%f
        return
      end
      solver_files=[solver_files 'ida_ic']
    end

    if fileinfo(SCI+'/routines/scicos/sundials/ida_io.c')<>[] then
      txt=mgetl(SCI+'/routines/scicos/sundials/ida_io.c');
      ierr=execstr('mputl(txt,rpat+''/solver/ida_io.c'')','errcatch')
      if ierr<>0 then
        message(lasterror())
        ok=%f
        return
      end
      solver_files=[solver_files 'ida_io']
    end

  end

  //@@@@ CVODE @@@@
  if s_name=='CVODE' then
    //@@ headers
    if fileinfo(SCI+'/routines/scicos/sundials/cvode.h')<>[] then
      txt=mgetl(SCI+'/routines/scicos/sundials/cvode.h');
    else
      txt=get_solver_file_code('cvode.h');
    end
    ierr=execstr('mputl(txt,rpat+''/solver/cvode.h'')','errcatch')
    if ierr<>0 then
      message(lasterror())
      ok=%f
      return
    end

    if fileinfo(SCI+'/routines/scicos/sundials/cvode_impl.h')<>[] then
      txt=mgetl(SCI+'/routines/scicos/sundials/cvode_impl.h');
    else
      txt=get_solver_file_code('cvode_impl.h');
    end
    ierr=execstr('mputl(txt,rpat+''/solver/cvode_impl.h'')','errcatch')
    if ierr<>0 then
      message(lasterror())
      ok=%f
      return
    end

    if fileinfo(SCI+'/routines/scicos/sundials/cvode_dense.h')<>[] then
      txt=mgetl(SCI+'/routines/scicos/sundials/cvode_dense.h');
    else
      txt=get_solver_file_code('cvode_dense.h');
    end
    ierr=execstr('mputl(txt,rpat+''/solver/cvode_dense.h'')','errcatch')
    if ierr<>0 then
      message(lasterror())
      ok=%f
      return
    end

    if fileinfo(SCI+'/routines/scicos/sundials/cvode_dense_impl.h')<>[] then
      txt=mgetl(SCI+'/routines/scicos/sundials/cvode_dense_impl.h');
    else
      txt=get_solver_file_code('cvode_dense_impl.h');
    end
    ierr=execstr('mputl(txt,rpat+''/solver/cvode_dense_impl.h'')','errcatch')
    if ierr<>0 then
      message(lasterror())
      ok=%f
      return
    end

    //@@ C sources
    if fileinfo(SCI+'/routines/scicos/sundials/cvode.c')<>[] then
      txt=mgetl(SCI+'/routines/scicos/sundials/cvode.c');
      ierr=execstr('mputl(txt,rpat+''/solver/cvode.c'')','errcatch')
      if ierr<>0 then
        message(lasterror())
        ok=%f
        return
      end
      solver_files=[solver_files 'cvode']
    end

    if fileinfo(SCI+'/routines/scicos/sundials/cvode_dense.c')<>[] then
      txt=mgetl(SCI+'/routines/scicos/sundials/cvode_dense.c');
      ierr=execstr('mputl(txt,rpat+''/solver/cvode_dense.c'')','errcatch')
      if ierr<>0 then
        message(lasterror())
        ok=%f
        return
      end
      solver_files=[solver_files 'cvode_dense']
    end

    if fileinfo(SCI+'/routines/scicos/sundials/cvode_io.c')<>[] then
      txt=mgetl(SCI+'/routines/scicos/sundials/cvode_io.c');
      ierr=execstr('mputl(txt,rpat+''/solver/cvode_io.c'')','errcatch')
      if ierr<>0 then
        message(lasterror())
        ok=%f
        return
      end
      solver_files=[solver_files 'cvode_io']
    end

  end

endfunction

function [ok,XX,gui_path,flgcdgen,szclkINTemp,freof,c_atomic_code,cpr]=do_compile_superblock42(all_scs_m,numk,atomicflag)
//Copyright (c) 1989-2010 Metalau project INRIA

//@@ do_compile_superblock42 : transforms a given Scicos discrete and continuous
//                             SuperBlock into a C defined Block
//
// Input  : all_scs_m     :
//          numk          :
//          atomicflag    :
//
// Output : ok            :
//          XX            :
//          gui_path      :
//          flgcdgen      :
//          szclkINTemp   :
//          freof         :
//          c_atomic_code :
//          cpr           :
//


  //******************* atomic blk **********
  [lhs,rhs] = argn(0)
  if rhs<3 then atomicflag=%f; end
  c_atomic_code=[];
  freof=[];
  flgcdgen=[];
  szclkINTemp=[];cpr=list();
  //*****************************************
  //## set void value for gui_path
  gui_path=[];

  if numk<>-1 then
    //## get the model of the sblock
    XX=all_scs_m.objs(numk);

    //## get the diagram inside the sblock
    scs_m=XX.model.rpar
  else
    XX=[]
    scs_m=all_scs_m;
  end

  //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  //@@ check and set global variables
  if ~exists('ALL') then ALL=%f, end
  if ALL<>%f & ALL<>%t then ALL=%f, end

  //@@ list_of_scopes
  if ~exists('list_of_scopes') then
    list_of_scopes=[]
  end
  list_of_scopes=[list_of_scopes;
                  'bouncexy'  'ipar(1)';
                  'canimxy'   'ipar(1)';
                  'canimxy3d' 'ipar(1)';
                  'cevscpe'   'ipar(1)';
                  'cfscope'   'ipar(1)';
                  'cmat3d'    ''
                  'cmatview'  ''
                  'cmscope'   'ipar(1)';
                  'cscope'    'ipar(1)';
                  'cscopxy'   'ipar(1)';
                  'cscopxy3d' 'ipar(1)'
                  scs_m.codegen.scopes]
  //@@ sim_to_be_removed
  if ~exists('sim_to_be_removed') then
    sim_to_be_removed=[]
  end
  sim_to_be_removed=[sim_to_be_removed;
                     'cfscope' 'Floating Scope';
                     scs_m.codegen.remove]

  //@@ debug_cdgen
  debug_cdgen=scs_m.codegen.enable_debug

  //@@ silent_mode
  silent_mode=scs_m.codegen.silent

  //@@ option for standalone
  sta__#=scs_m.codegen.opt

  //@@ with_gui
  with_gui=scs_m.codegen.cblock

  //@@ cdgen_libs
  if ~exists('%scicos_libs') then
    %scicos_libs=[]
  end
  cdgen_libs=[%scicos_libs(:)',scs_m.codegen.libs(:)']

  //@@ set rdnom
  rdnom=scs_m.codegen.rdnom

  //@@ set rpath
  rpat=scs_m.codegen.rpat
  //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

  //@@ get parameter and name of diagram
  par=scs_m.props;
  hname=scs_m.props.title(1)

  //***********************************************************
  //Check blocks properties and adapt them if necessary
  //***********************************************************

  IN=[];OUT=[];clkIN=[];clkOUT=[];numa=[];numc=[];
  for i=1:size(scs_m.objs)
    if typeof(scs_m.objs(i))=='Block' then
      if scs_m.objs(i).gui=='CLKOUT_f' | scs_m.objs(i).gui=='CLKOUTV_f' then
        ok=%f
        %cpr=list()
        error('Superblock should not have any activation output port.')
      elseif scs_m.objs(i).gui=='INIMPL_f' then
        ok=%f
        %cpr=list()
        error('Superblock should not have any input implicit port.')
      elseif scs_m.objs(i).gui=='OUTIMPL_f' then
        ok=%f
        %cpr=list()
        error('Superblock should not have any output implicit port.')
      elseif scs_m.objs(i).gui=='IN_f' then
        //replace input ports by sensor blocks
        numc=numc+1
        scs_m.objs(i).gui='INPUTPORTEVTS';
        scs_m.objs(i).model.evtin=1
        scs_m.objs(i).model.sim(1)='capteur'+string(numc)
        IN=[IN scs_m.objs(i).model.ipar]
      elseif scs_m.objs(i).gui=='SENSOR_f' then
        numc=numc+1
        scs_m.objs(i).model.sim(1)='capteur'+string(numc)
        IN=[IN scs_m.objs(i).model.ipar]
      elseif scs_m.objs(i).gui=='OUT_f' then
        //replace output ports by actuator blocks
        numa=numa+1
        scs_m.objs(i).gui='OUTPUTPORTEVTS';
        scs_m.objs(i).model.sim(1)='actionneur'+string(numa)
        OUT=[OUT  scs_m.objs(i).model.ipar]
      elseif scs_m.objs(i).gui=='ACTUATOR_f' then
        numa=numa+1
        scs_m.objs(i).model.sim(1)='actionneur'+string(numa)
        OUT=[OUT  scs_m.objs(i).model.ipar]
      elseif scs_m.objs(i).gui=='CLKINV_f' then
        //replace event input ports by  fictious block
        scs_m.objs(i).gui='EVTGEN_f';
        scs_m.objs(i).model.sim(1)='bidon'
        clkIN=[clkIN scs_m.objs(i).model.ipar];
        //elseif scs_m.objs(i).model.dep_ut(2)==%t then
        //check for time dependency PAS IICI
        //ok=%f;%cpr=list()
        //message('a block have time dependence.')
        //return
      elseif scs_m.objs(i).gui=='CLKOUTV_f' then
        scs_m.objs(i).gui='EVTOUT_f';
        scs_m.objs(i).model.sim(1)='bidon2'
        clkOUT=[clkOUT scs_m.objs(i).model.ipar];
      end
    end
  end

  //Check if input/output ports are numered properly
  IN=-sort(-IN);
  if or(IN<>[1:size(IN,'*')]) then
    ok=%f;%cpr=list()
    error('Input ports are not numbered properly.')
  end
  OUT=-sort(-OUT);
  if or(OUT<>[1:size(OUT,'*')]) then
    ok=%f;%cpr=list()
    error('Output ports are not numbered properly.')
  end
  clkIN=-sort(-clkIN);
  if or(clkIN<>[1:size(clkIN,'*')]) then
    ok=%f;%cpr=list()
    error('Event input ports are not numbered properly.')
  end
  clkOUT=-sort(-clkOUT);
  if or(clkOUT<>[1:size(clkOUT,'*')]) then
    ok=%f;%cpr=list()
    error('Event output ports are not numbered properly.')
  end

  //Check if there is more than one clock in the diagram
  szclkIN=size(clkIN,2);
  if szclkIN==0 then szclkIN=[], end
  flgcdgen=szclkIN

  //## overload some functions used
  //## in modelica block compilation
  //## disable it for codegeneration
  //   %mprt=funcprot()
  //   funcprot(0)
  //   deff('[ok] =  buildnewblock(blknam,files,filestan,filesint,libs,rpat,ldflags,cflags)','ok=%t')
  //   funcprot(%mprt)

  //## first pass of compilation
  if ~ALL then
    [bllst,connectmat,clkconnect,cor,corinv,ok,flgcdgen,freof]=c_pass1(scs_m,flgcdgen);
  else
    [bllst,connectmat,clkconnect,cor,corinv,ok,flgcdgen,freof]=c_pass1(scs_m);
    szclkINTemp=flgcdgen;
  end

  //## restore buildnewblock
  clear buildnewblock

  if ~ok then
    %cpr=list()
    error('Sorry: problem in the pre-compilation step.')
  end

  //@@ adjust scope win number if needed
  [bllst,ok]=adjust_id_scopes(list_of_scopes,bllst)
  if ~ok then
    %cpr=list()
    error('Problem adjusting scope id number.')
  end

  //###########################//
  //## Detect implicit block ##//

  //## Force here generation of implicit block
  if scs_m.props.tol(6)==100 & ALL then
    impl_blk = %t;
    %scicos_solver=100;
  else
    impl_blk = %f;
    for blki=bllst
      if type(blki.sim)==15 then
        if blki.sim(2)>10000 then
          impl_blk = %t;
          %scicos_solver=100;
          break;
        end
      end
    end
  end
  //###########################//

  //@@ inform flgcdgen
  if ~ALL then
    if flgcdgen<> szclkIN
      clkIN=[clkIN flgcdgen]
    end
    szclkINTemp=szclkIN;
    szclkIN=flgcdgen;
  end

  //Test for ALWAYS_ACTIVE sblock
  ALWAYS_ACTIVE=%f;
  ALWAYS_ACTIVE_ALL=%f;
  if ~ALL then
    for blki=bllst
      if blki.dep_ut($) then
        ALWAYS_ACTIVE=%t;
        break;
      end
    end
  else
    for blki=bllst
      if blki.dep_ut($) then
        ALWAYS_ACTIVE_ALL=%t;
        break;
      end
    end
  end

  if ALWAYS_ACTIVE then
    for Ii=1:length(bllst)
      if type(bllst(Ii).sim(1))==10 then
        if part(bllst(Ii).sim(1),1:7)=='capteur' then
          bllst(Ii).dep_ut($)=%t
        end
      end
    end
  end

  // *********************************************************
  // build various index tables :
  // cap  : indices of sensors blk in bllst
  // act  : indices of actuators blk in bllst
  // allhowclk  : indices of evt sensors blk in bllst
  // allhowclk2 : indices of evt actuators blk in bllst
  // *********************************************************

  a=[];
  b=[];
  tt=[];
  howclk=[];
  allhowclk=[];
  allhowclk2=[];
  cap=[];
  act=[];

  for i=1:size(bllst)
    for j=1:size(bllst)
      if (bllst(i).sim(1)=='capteur'+string(j)) then
        if tt<>i then
          cap=[cap;i];
          tt=i;
        end
      elseif (bllst(i).sim(1)=='actionneur'+string(j)) then
        if tt<>i then
          act=[act;i];
          tt=i;
        end
      elseif (bllst(i).sim(1)=='bidon') then
        if tt<>i then
          allhowclk=[allhowclk;i];
          tt=i;
        end
      elseif (bllst(i).sim(1)=='bidon2') then
        if tt<>i then
          allhowclk2=[allhowclk2;i];
          tt=i;
        end
      end
    end
  end
  ///**********************************************************

  if szclkIN>1 then
    //replace the N Event inputs by a fictious block with
    // 2^N as many event outputs
    output=ones((2^szclkIN)-1,1)
    bllst($+1)=scicos_model(sim=list('bidon',1),evtout=output,..
                            blocktype='d',..
                            firing=-output',dep_ut=[%f %f])
    corinv(size(bllst))=0
    howclk=size(bllst)
    // adjust the links accordingly
    for i=1:(2^szclkIN)-1
      vec=codebinaire(i,szclkIN)
      for j=1:szclkIN
        if vec(j)*allhowclk(j)>=1 then
          for k=1:size(clkconnect,1)
            if clkconnect(k,1)==allhowclk(j) then
              clkconnect=[clkconnect;[howclk i clkconnect(k,3:4)]]
            end
          end
        end
      end
    end
    ALL=%f
  elseif szclkIN==[] then
    if ~ALL & ~ALWAYS_ACTIVE then
      //superblock has no event input, add a fictious clock
      output=ones((2^(size(cap,'*')))-1,1)
      if (output == []) then
        output=0;
      end
      bllst($+1)=scicos_model(sim=list('bidon',1),evtout=output,..
                              firing=-output,blocktype='d',dep_ut=[%f %f])
      corinv(size(bllst))=0
      howclk=size(bllst);
    else
      //@@ find block with output events
      ind_evtout_blk=[]
      nb_evtout=0
      firing_evtout=[]
      for i=1:size(bllst)
        if bllst(i).evtout<>[] then
           if type(bllst(i).sim)==15 then
             if bllst(i).sim(2)<>-1 & bllst(i).sim(2)<>-2 then
               ind_evtout_blk=[ind_evtout_blk;i]
               for j=1:size(bllst(i).evtout,'*')
                 firing_evtout=[firing_evtout;bllst(i).firing(j)]
               end
               nb_evtout=nb_evtout+size(bllst(i).evtout,'*')
             end
           else
             ind_evtout_blk=[ind_evtout_blk;i]
             for j=1:size(bllst(i).evtout,'*')
               firing_evtout=[firing_evtout;bllst(i).firing(j)]
             end
             nb_evtout=nb_evtout+size(bllst(i).evtout,'*')
           end
        end
      end
      //@@ add an agenda_blk
      if ind_evtout_blk<>[] then
        bllst($+1)=scicos_model(sim=list('agenda_blk',1),evtout=ones(size(firing_evtout,1),1),..
                                firing=-ones(size(firing_evtout,1),1),blocktype='d',dep_ut=[%f %f])
        agenda_blk = size(bllst);
        corinv(size(bllst))=0
        //@@ evt output connection from agenda_blk
        kk=1;
        for i=1:size(ind_evtout_blk,'*')
          for j=1:size(bllst(ind_evtout_blk(i)).evtout,'*')
            for jj=1:size(clkconnect,1)
               if clkconnect(jj,1)==ind_evtout_blk(i) & clkconnect(jj,2)==j then
                 clkconnect(jj,1) = agenda_blk;
                 clkconnect(jj,2) = kk;
               end
            end
            kk=kk+1
          end
        end
      else
        output=ones((2^(size(cap,'*')))-1,1)
        if (output == []) then
          output=0;
        end
        bllst($+1)=scicos_model(sim=list('bidon',1),evtout=output,..
                                firing=-output,blocktype='d',dep_ut=[%f %f])
        corinv(size(bllst))=0
        howclk=size(bllst);
        ALL=%f
      end

    end
  elseif szclkIN==1  then
    howclk=allhowclk
    ALL=%f
  end

  //@@ ordering clkconnect
  if szclkIN>1 then
  //  newclkconnect=clkconnect;
  //  clkconnect=[];
  //  for i=1:size(newclkconnect,1)-1
  //    if or(newclkconnect(i,:)<>newclkconnect(i+1,:)) then
  //      clkconnect=[clkconnect;newclkconnect(i,:)]
  //    end
  //  end
  //  if or(newclkconnect($-1,:)<>newclkconnect($,:)) then
  //    clkconnect=[clkconnect;newclkconnect($,:)]
  //  end

    //@@ remove bidons blk
    newclkconnect=clkconnect;nkt=[];
    for i=1:szclkIN
      for k=1:size(newclkconnect,1)
        if newclkconnect(k,1)~=allhowclk(i) then
          nkt=[nkt;newclkconnect(k,:)];
        end
      end
      newclkconnect=nkt;
      nkt=[];
    end
    clkconnect=newclkconnect;
  end

  //**************************************************
  // new clkconnect with connections on sensors
  //**************************************************
  if ~ALL then
    //Test for ALWAYS_ACTIVE sblock
    n=size(cap,1)
    if ~(szclkIN==[]) then  //triggered case
      for i=1:n
	if szclkIN>1 then
	  for j=1:(2^szclkIN)-1
	    clkconnect=[clkconnect;[howclk j cap(i) 1]];
	  end
	elseif szclkIN==1 then
	  clkconnect=[clkconnect;[howclk 1 cap(i) 1]];
	end
      end
    elseif ~ALWAYS_ACTIVE then
      //inheritance case to activate sensors
      for i=1:2^n-1
	vec=codebinaire(i,n);
	for j=1:n
	  if (vec(j)==1) then
	    clkconnect=[clkconnect;[howclk i cap(j) 1]];
	  end
	end
      end
    end
  end
  //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  //@@ remove problematic scopes
  for i=1:lstsize(bllst)
    ind = find(bllst(i).sim(1)==sim_to_be_removed(:,1))
    if ind<>[] then
      mess=[sim_to_be_removed(ind,2)+' block is not allowed.' ;
            'It will be not called.';];
      if ~silent_mode then
        okk=message(mess,['Ok';'Go Back'])
      else
        disp(mess);
        okk=1
      end
      if okk==1 then
        bllst(i).sim(1)='bidon'
        if type(bllst(i).sim(1))==13 then
          bllst(i).sim(2)=0
        end
      else
        ok=%f
        %cpr=list()
        return
      end
    end
  end
  //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

  FIRING=[]
  for i=1:size(allhowclk2,1)
    j = find(clkconnect(:,3)==allhowclk2(i))
    if j<>[] then
      FIRING=[FIRING;bllst(clkconnect(j,1)).firing(clkconnect(j,2))]
    end
  end

  Code_gene_run=[];
  //******************** To avoid asking for size or type more than one time in incidence_mat*******
  //************************** when creating atomicity *********************************************
  //************************** in other cases it can be done in adjust_all_scs_m *******************
  c_pass2=c_pass2;
  if ok then
    [ok,bllst]=adjust_inout(bllst,connectmat);
  end

  if ok then
    [ok,bllst]=adjust_typ(bllst,connectmat);
  end
  //*************************************************************************************************
  //## second pass of compilation
  cpr=c_pass2(bllst,connectmat,clkconnect,cor,corinv,"silent")

  if cpr==list() then
    ok=%f,
    error("Problem compiling; perhaps an algebraic loop.");
  end

  // computing the incidence matrix to derive actual block's depu
  [depu_mat,ok]=incidence_mat(bllst,connectmat,clkconnect,cor,corinv)
  if ~ok then
    //rmk : incidence_mat seems to return allways ok=%t
    return
  else
    depu_vec=depu_mat*ones(size(depu_mat,2),1)>0
  end

  //## Detect synchro block and type1
  funs_save   = cpr.sim.funs;
  funtyp_save = cpr.sim.funtyp;
  with_work   = zeros(cpr.sim.nb,1)
  with_synchro = %f
  with_nrd     = %f
  with_type1   = %f

  //## loop on blocks
  for i=1:lstsize(cpr.sim.funs)
    //## look at for funs of type string
    if type(cpr.sim.funs(i))==10 then
      if part(cpr.sim.funs(i),1:10)=='actionneur' then
        cpr.sim.funs(i) ='bidon'
        cpr.sim.funtyp(i) = 0
      elseif part(cpr.sim.funs(i),1:7)=='capteur' then
        cpr.sim.funs(i) ='bidon'
        cpr.sim.funtyp(i) = 0
      elseif cpr.sim.funs(i)=='bidon2' then
        cpr.sim.funs(i) ='bidon'
        cpr.sim.funtyp(i) = 0
      elseif cpr.sim.funs(i)=='agenda_blk' then
        cpr.sim.funs(i) ='bidon'
        cpr.sim.funtyp(i) = 0
      elseif cpr.sim.funs(i)=='affich' then
        cpr.sim.funs(i) ='bidon'
        cpr.sim.funtyp(i) = 0
      elseif cpr.sim.funs(i)=='affich2' then
        cpr.sim.funs(i) ='bidon'
        cpr.sim.funtyp(i) = 0
      end
    end
    //## look at for type of block
    if cpr.sim.funtyp(i) < 0 then
       with_synchro = %t //## with_synchro flag comes global
    elseif cpr.sim.funtyp(i) == 0 then
       with_nrd = %t //## with_nrd flag comes global
    elseif cpr.sim.funtyp(i) == 1 then
       if cpr.sim.funs(i) ~= 'bidon' then
         with_type1 = %t //## with_type1 flag comes global
       end
    end
  end //## end of for

  //**** solve which blocks use work ****//
  BeforeCG_WinList = winsid();

  ierr=execstr('[state,t]=scicosim(cpr.state,0,0,cpr.sim,'+..
               '''start'',scs_m.props.tol)','errcatch')

  //@@ save initial outtb
  if ierr==0
    outtb_init = state.outtb;
  else
    outtb_init = cpr.state.outtb
  end

  //** retrieve all open ScicosLab windows with winsid()
  AfterCG_WinList = winsid();

  if ierr==0 then
    for i=1:cpr.sim.nb
       if state.iz(i)<>0 then
          with_work(i)=%t
       end
    end

    ierr=execstr('[state,t]=scicosim(state,0,0,cpr.sim,'+..
                 '''finish'',scs_m.props.tol)','errcatch')
  end

  //@@ remove windows opened by simulation
  xdel(setdiff(AfterCG_WinList,BeforeCG_WinList))

  //*************************************//

  //@@ retrieve original funs name
  cpr.sim.funs=funs_save;
  cpr.sim.funtyp=funtyp_save;

  //@@ add a work ptr for agenda blk
  for i=cpr.sim.nb:-1:1
    if cpr.sim.funs(i)=='agenda_blk' then
      with_work(i)=%t
      break
    end
  end

  //@@ cpr ptrs declaration
  x=cpr.state.x;
  z=cpr.state.z;
  //outtb=cpr.state.outtb;
  outtb=outtb_init;
  zcptr=cpr.sim.zcptr;
  ozptr=cpr.sim.ozptr;
  rpptr=cpr.sim.rpptr;
  ipptr=cpr.sim.ipptr;
  opptr=cpr.sim.opptr;
  funs=cpr.sim.funs;
  xptr=cpr.sim.xptr;
  zptr=cpr.sim.zptr;
  inpptr=cpr.sim.inpptr;
  inplnk=cpr.sim.inplnk;
  outptr=cpr.sim.outptr;
  outlnk=cpr.sim.outlnk;
  ordclk=cpr.sim.ordclk;
  funtyp=cpr.sim.funtyp;
  cord=cpr.sim.cord;
  ncord=size(cord,1);
  nblk=cpr.sim.nb;
  ztyp=cpr.sim.ztyp;
  clkptr=cpr.sim.clkptr
  //taille totale de z : nztotal
  nztotal=size(z,1);
  //taille totale de x : nxtotal
  nxtotal=size(x,'*');

  //*******************************
  //Checking if superblock is valid
  //*******************************
  msg=[]
  for i=1:length(funs)-1
    if funtyp(i)==3 | funtyp(i)==5 then
      msg=[msg;'Scilab block''s not allowed.']
    elseif (clkptr(i+1)-clkptr(i))<>0 &funtyp(i)>-1 &funs(i)~='bidon' then
//      //msg=[msg;'Regular block generating activation not allowed yet']
    end
    if msg<>[] then
      ok=%f
      error(msg)
    end
  end

  //********************************************************
  // Change logical units for readf and writef blocks if any
  //********************************************************
  lunit=0
  for d=1:length(funs)
    if funs(d)=='readf'  then
      z(zptr(d)+2)=lunit
      lunit=lunit+1;
    elseif funs(d)=='writef'
      z(zptr(d)+1)=lunit
      lunit=lunit+1;
    end
  end

  //***********************************
  // Get the name of the file
  //***********************************
  okk=%f;
  if rdnom==[] then
    rdnom=hname;
  end
  if rpat==[] then
    if MSDOS then
      rpat=getcwd()+'\'+hname;
    else
      rpat=getcwd()+'/'+hname;
    end
  end
  if cdgen_libs<>[] then
    libs=sci2exp(cdgen_libs(:)',0);
  else
    libs=''
  end
  if %scicos_cflags<>[] then
    if size(%scicos_cflags,'*')<>1 then
      cflags=sci2exp(%scicos_cflags(:)',0);
    else
      cflags=%scicos_cflags
    end
  else
    cflags=''
  end
  curind=1
  label1=[rdnom;rpat;libs;cflags];

  while %t do
    ok=%t  // to avoid infinite loop

    //@@ atomic case flag
    if atomicflag then
      rdnom=all_scs_m.props.title(1)+'_'+strcat(string(super_path),'_')+'_'+string(numk)
      rdnom = strsubst(rdnom,' ','_');
      rdnom = strsubst(rdnom,'-','_');
      rdnom = strsubst(rdnom,'.','_');
      rdnom = strsubst(rdnom,'''','_');
      rpat=TMPDIR

    //@@ regular code generation
    else
      //@@ check name of block for space,'-','_',quote
      if grep(rdnom," ")<>[] | grep(rdnom,"-")<>[] | grep(rdnom,".")<>[] | grep(rdnom,"''")<>[] then
        rdnom = strsubst(rdnom,' ','_');
        rdnom = strsubst(rdnom,'-','_');
        rdnom = strsubst(rdnom,'.','_');
        rdnom = strsubst(rdnom,'''','_');
        label1=[rdnom;label1(2);label1(3);label1(4)];
      end

      //@@ check if block is already linked
      if c_link(rdnom) then
        rdnom2 = rdnom
        while c_link(rdnom2) then
          rdnom2 = rdnom + string(curind)
          curind = curind + 1
        end
        curind = 1
        label1=[rdnom2;label1(2);label1(3);label1(4)];
      end

      //@@ check directory for space
      if ~MSDOS then
        if grep(rpat," ")<>[] then
          rpat = strsubst(rpat,' ','_');
          label1=[label1(1);rpat;label1(3);label1(4)];
         end
      end

      //@@ user input only for no silent_mode
      if ~silent_mode then
        %scs_help='CodeGeneration'
        [okk,..
         rdnom,..
         rpat,..
         libs,..
         cflags,..
         label1]=getvalue('Set code generator parameters',..
                          ['New block''s name';
                           'Created files Path';
                           'Other object files to link with (if any)';
                           'Additional compiler flag(s)'],..
                           list('str',1,'str',1,'str',1,'str',1),label1);
      else
        rdnom   = label1(1)
        rpat    = label1(2)
        libs    = label1(3)
        cflags  = label1(4)
        okk=%t
      end

      if okk==%f then
        ok=-1
        return
      end
      rpat=stripblanks(rpat);

      //** test to solve multiple libraries
      if strindex(libs,'''')<>[] | strindex(libs,'""')<>[] then
        ierr=execstr('libs=evstr(libs)','errcatch')
        if ierr<>0  then
          ok=-1;
          error(['Can''t solve other files to link'])
        end
      end
    end

    if stripblanks(rdnom)==emptystr() then
      ok=%f;
      mess=('Sorry C file name not defined');
      if atomicflag then
        x_message(mess);
        return
      else
        if ~silent_mode then
          x_message(mess);
        else
          error(mess);
        end
      end
    end

    if ok then
      //** Put a warning here in order to inform the user
      //** that the name of the superblock will change
      //** because the space, the char "-", or  the char "."
      //** (could generate GCC problems) in name isn't allowed.
      //** (the C functions contains the name of the superblock).
      if grep(rdnom," ")<>[] | grep(rdnom,"-")<>[] | grep(rdnom,".")<>[] | grep(rdnom,"''")<>[] then
        mess=[' Superblock name cannot contains space, ""."", ';
              '""-"" and quote characters. The superblock will be renamed :';
              ''''+strsubst(strsubst(strsubst(strsubst(rdnom,' ','_'),'-','_'),'.','_'),'''','_')+''''];
        okk=message(mess,['Ok';'Go Back'])
        if okk==1 then
          rdnom = strsubst(rdnom,' ','_');
          rdnom = strsubst(rdnom,'-','_');
          rdnom = strsubst(rdnom,'.','_');
          rdnom = strsubst(rdnom,'''','_');
          label1=[rdnom;label1(2);label1(3);label1(4)];
        else
           ok=%f;
           if atomicflag then return, end
        end
      end

      //@@ check if rdnom already exists in the linked routine table
      if c_link(rdnom) & ~atomicflag then
        if ~silent_mode | atomicflag then
          mess=[' Warning. An entry point with name '''+rdnom+'''';
                'is already linked. The new generated block may have'
                'another name or the old entry point must be unlinked.'];
          okk=message(mess,['Change block name';'Force unlink'])
          if okk==1 then
            ok=%f
          end
        end
      end

      //@@ libtool doesn't work with directory with white space
      if ok then
        if ~MSDOS then
          if grep(rpat," ")<>[] then
            if silent_mode & ~atomicflag then
              rpat = strsubst(rpat,' ','_');
            else
              mess=[' Superblock path cannot contains space characters';
                    'The path will be renamed :';
                    ''''+strsubst(rpat,' ','_')+''''];
              okk=message(mess,['Ok';'Go Back'])
              if okk==1 then
                rpat = strsubst(rpat,' ','_');
                label1=[label1(1);rpat;label1(3);label1(4)];
                //rpat=strsubst(rpat,'-','_');
              else
                ok=%f;
                if atomicflag then return, end
              end
            end
          end
        end

        if ok then
          dirinfo=fileinfo(rpat)
          if dirinfo==[] then
            [pathrp,fnamerp,extensionrp]=fileparts(rpat)
            if ~MSDOS then
              fnamerp=strsubst(fnamerp," ",""" """)
            end
            ok=mkdir(pathrp,fnamerp+extensionrp)
            if ~ok then
              mess='Directory '+rpat+' cannot be created.'
              if atomicflag | ~silent_mode then
                x_message(mess);
                if atomicflag then return, end
              else
                error(mess);
              end
            end
          elseif filetype(dirinfo(2))<>'Directory' then
            ok=%f;
            mess=rpat+' is not a directory.';
            if atomicflag | ~silent_mode then
              x_message(mess);
              if atomicflag then return, end
            else
              error(mess);
            end
          else
            //@@ add a test for %scicos_libs
            if MSDOS then
              target_lib = rpat+'\lib'+rdnom+'.dll'
            else
              target_lib =  rpat+'/lib'+rdnom+'.so'
            end
            ind = find(libs==target_lib)
            if ind<>[] then
              mess=[' Warning. You want to link an external library';
                    'which is the same than the target library.'
                    'That library can be here removed from the'
                    'list of external libraries (only for expert user).'];
              if atomicflag | ~silent_mode then
                okk=message(mess,['Change block name';'Ok'])
              else
                okk=2
              end
              if okk==2 then
                new_libs=[]
                for i=1:size(libs,'*')
                  if find(i==ind)==[] then
                    new_libs=[new_libs,libs(i)]
                  end
                end
                libs=new_libs
              else
                ok=%f;
                if atomicflag then return, end
              end
            end
          end
        end
      end
    end

    if ok then
      break
    end
  end

  //###################################################
  //generate blocs simulation function prototypes
  //and extract infos from ports for sensors/actuators
  //###################################################

  nbcap=0;
  nbact=0;
  capt=[];
  actt=[];
  Protostalone=[];
  Protos=[];
  dfuns=[]

  //## loop on number of blk
  for i=1:length(funs)
    //## block is a sensor
    if or(i==cap) then
      nbcap = nbcap+1;
      //## number of output ports
      nout=outptr(i+1)-outptr(i);
      if nout==0 then
         //yk    = 0;
         //nyk_1 = 0;
         //nyk_2 = 0;
         //yk_t  = 1;
         disp('nout=0 for a sensor');
         pause
      else
         yk    = outlnk(outptr(i));
         nyk_1 = size(outtb(yk),1);
         nyk_2 = size(outtb(yk),2);
         yk_t  = mat2scs_c_nb(outtb(yk));
      end
      capt=[capt;
            i yk nyk_1 nyk_2 yk_t bllst(i).ipar]

      //## only one proto for sensor
      if nbcap==1 then
        Protostalone=[Protostalone;
                      '';
                      +get_comment('proto_sensor')
                      'void '+rdnom+'_sensor(int *, int *, int *, double *, void *, \';
                      get_blank(rdnom)+'             int *, int *, int *, int, void *);']
      end

    //## block is an actuator
    elseif or(i==act) then
      nbact = nbact+1;
      //## number of input ports
      nin=inpptr(i+1)-inpptr(i);
      if nin==0 then
        //uk    = 0;
        //nuk_1 = 0;
        //nuk_2 = 0;
        //uk_t  = 1;
        disp('nin=0 for an actuator');
        pause
      else
        uk    = inplnk(inpptr(i));
        nuk_1 = size(outtb(uk),1);
        nuk_2 = size(outtb(uk),2);
        uk_t  = mat2scs_c_nb(outtb(uk));
      end
      actt=[actt;
            i uk nuk_1 nuk_2 uk_t bllst(i).ipar]

      //## only one proto for actuator
      if nbact==1 then
        Protostalone=[Protostalone;
                      ''
                      +get_comment('proto_actuator')
                      'void '+rdnom+'_actuator(int *, int *, int *, double *, void *, \';
                      get_blank(rdnom)+'               int *, int *, int *, int, void *);']
      end

    //## all other types of blocks excepts evt sensors and evt actuators
    else
      if funs(i)<>'bidon' & funs(i)<>'bidon2' then
        ki=find(funs(i)==dfuns)
        dfuns=[dfuns;funs(i)]
        if ki==[] then
          Protos=[Protos;'';BlockProto(i)];
          Protostalone=[Protostalone;'';BlockProto(i)];
        end
      end
    end
  end

  //**************************************
  //sort actuator/sensors information matrix
  [junk,index]=sort(-actt(:,$));
  actt=actt(index,1:$) ;
  [junk,index]=sort(-capt(:,$));
  capt=capt(index,1:$) ;

  rdcpr=cpr.sim.funs;
  for r=1:length(cap),rdcpr(cap(r))='bidon';end
  for r=1:length(act),rdcpr(act(r))='bidon';end
  Total_rdcpr=cpr.sim;Total_rdcpr.funs=rdcpr;

  //***************************************************
  // Compute the initial state and outtb (links) values
  //***************************************************

  //
  tcur=0;
  tf=scs_m.props.tf;
  tolerances=scs_m.props.tol;
  //[state,t]=scicosim(cpr.state,tcur,tf,Total_rdcpr,'start',tolerances);
  //cpr.state=state;
  z=cpr.state.z;
  //outtb=cpr.state.outtb;
  //[junk_state,t]=scicosim(cpr.state,tcur,tf,Total_rdcpr,'finish',tolerances);

  //***********************************
  // Scicoslab and C files generation
  //***********************************

  //** generate ScicosLab interfacing function
  //   of the generated scicos block
  ok=gen_gui42();

  //** generate code for atomic blocks
  if ok & atomicflag then
    [ok,c_atomic_code]=gen_atomic_ccode42()
  else
    //** generate C files
    //   of the generated scicos block
    if ok then
      [ok,Cblocks_files,solver_files]=gen_ccode42()
    end

    //** Generates Makefile, loader
    //   and compile and link C files

    //** def files to build
    files=[rdnom Cblocks_files]

    //## Add optional standalone code generation
    if sta__#<>0 then
      //** def files to build for standalone
      filestan=[rdnom+'_standalone' rdnom+'_act_sens_events' Cblocks_files]

      //## def files to build for interfacing of the standalone
      filesint=[rdnom+'_void_io' Cblocks_files 'int'+rdnom+'_sci' rdnom+'_standalone']
    else
      filestan=''
      filesint=''
    end

    //@@ add sundials directory
    if cflags=='' then
      if ALL then cflags='-I""./solver""', end
    else
      if ALL then cflags=[cflags,'-I""./solver""'], end
    end

    if ok then
      ok=buildnewblock(rdnom,files,filestan,filesint,libs,rpat,'',cflags)
    end
  end

  if ok then

    if ~ALL then
      //global gui_path
      gui_path=rpat+'/'+rdnom+'_c.sci'

      //exec the gui function
      exec(gui_path)

      //Change diagram superblock to new generated block
      if isequal(XX,[]) then
        execstr('XX='+rdnom+'_c(''define'')');
        XX.graphics.sz = 20 *XX.graphics.sz
        if scs_m.codegen.cblock==1 then
          XX=gencblk4(XX,gui_path)
        end
      else
        XX=update_block(XX)
      end

      //!! adjust model.blocktype if needed
      if cpr.state.x==[] then
        for kk=1:lstsize(bllst)
          if bllst(kk).blocktype=='x' then
            XX.model.blocktype='x'
            break
          end
        end
      end

      //@@ put a doc into the field doc of the new block
      XX=update_block_doc(XX)

      //## update %scicos_libs if needed
      if MSDOS then
        libnam=rpat+'\lib'+rdnom+'.dll'
      else
        libnam=rpat+'/lib'+rdnom+'.so'
      end
      if exists('%scicos_libs') then
        if find(libnam==%scicos_libs)==[] then
          %scicos_libs=[%scicos_libs,libnam];
        end
      else
        %scicos_libs=libnam
      end

      //## resume the interfacing function to the upper-level
      execstr('['+rdnom+'_c,%scicos_libs]=resume('+rdnom+'_c,%scicos_libs)')

    else
      //@@ get new generated block
      XX = gen_allblk()

      //@@ put a doc into the field doc of the new block
      XX=update_block_doc(XX)

      //@@ display info message
      txt=["The codes for the entire diagram have been successfully ";
           "generated in the path :";
           ""
           """"+rpat+""""
           ""];
      if ~with_gui then
        txt=[txt
             "If you run the simulation now, you will use and test the "
             "generated computational function. The simulation based "
             "on the diagram will be restored when a modification that "
             "implies a recompilation will be detected."];
      end
      if ~silent_mode then
        x_message(txt)
      end

    end
  end
endfunction

function [txt,txt2]=allocblk(model,ind)
//Copyright (c) 1989-2010 Metalau project INRIA

// allocblk : generate needed C lines to do the
//            C allocation of a scicos_block structure
//            from a scilab model of blk.
//
// Input : model : the scilab model of a scicos blk
//        ind    : and index number
//
// Output :  txt  : declaration
//           txt2 : affectation

  txt=[]; //declaration
  txt2=[]; //affectation
  txt3=[]; //final affectation

  rdnam='blk';
  if (argn(2)==2) then
    rdnam=rdnam+string(ind)
  end

  //
  txt=['/* */'
       'scicos_block block_'+rdnam+';'
       ''];

  // 2 : model.sim
  if (type(model.sim)==15) then
    simfun=model.sim(1)
    simtyp=model.sim(2)
  else
    simfun=model.sim
    simtyp=0
  end
  if (type(simfun)<>10) then
    error('ScicosLab simulation function not allowed.');
  end

  txt=[txt
       'int type_'+rdnam+'           = '+string(simtyp)+';']

  if ((simtyp==0) | (simtyp==1)) then
    txt=[txt
         'voidg funpt_'+rdnam+'        = &C2F('+string(simfun)+');'];
  else
    txt=[txt
         'voidg funpt_'+rdnam+'        = &'+string(simfun)+';'];
  end

  txt3=[txt3;
        'block_'+rdnam+'.type         = type_'+rdnam+';'
        'block_'+rdnam+'.funpt        = funpt_'+rdnam+';'];

  // 3 : model.in
  // 4 : model.in2
  // 5 : model.intyp
  if (size(model.in,'*')<>0) then
    if (find(model.in<0)<>[]) then
      error('Undetermined first dimension for input port '+sci2exp(find(model.in<0))+'.');
    else
      if (find(model.in2<0)<>[]) then
        error('Undetermined second dimension for input port '+sci2exp(find(model.in2<0))+'.');
      else
        if (find(model.intyp<0)<>[]) then
          error('Undetermined type for input port '+sci2exp(find(model.intyp<0))+'.');
        else
          model.in2(find(model.in2==[]))=1
          txt=[txt;
               'int nin_'+rdnam+'            = '+string(size(model.in,'*'))+';'
               'int insz_'+rdnam+'[]         = {'+strcat(string([(model.in(:))',(model.in2(:))',scs_nb2scs_c_nb((model.intyp(:)))']),',')+'};'
               'void *inptr_'+rdnam+'[]      = {'+strcat(string(zeros(1,size(model.in,'*'))),',')+'};'];
          for i=1:size(model.in,'*')
            txt2=[txt2;
                  'inptr_'+rdnam+'['+string(i-1)+']           = (void *) in'+string(i)+'_'+rdnam+';'];
            select (model.intyp(i))
              case 1 then
                txt=[txt;
                     'SCSREAL_COP in'+string(i)+'_'+rdnam+'[]  = {'+strcat(string(zeros(1,model.in(i)*model.in2(i)))+'.',',')+'};'];
              case 2 then
                txt=[txt;
                     'SCSCOMPLEX_COP in'+string(i)+'_'+rdnam+'[] = {'+strcat(string(zeros(1,2*model.in(i)*model.in2(i)))+'.',',')+'};'];
              case 3 then
                txt=[txt;
                     'SCSINT32_COP in'+string(i)+'_'+rdnam+'[]  = {'+strcat(string(zeros(1,2*model.in(i)*model.in2(i))),',')+'};'];
              case 4 then
                txt=[txt;
                     'SCSINT16_COP in'+string(i)+'_'+rdnam+'[]  = {'+strcat(string(zeros(1,2*model.in(i)*model.in2(i))),',')+'};'];
              case 5 then
                txt=[txt;
                     'SCSINT8_COP in'+string(i)+'_'+rdnam+'[]   = {'+strcat(string(zeros(1,2*model.in(i)*model.in2(i))),',')+'};'];
              case 6 then
                txt=[txt;
                     'SCSUINT32_COP in'+string(i)+'_'+rdnam+'[] = {'+strcat(string(zeros(1,2*model.in(i)*model.in2(i))),',')+'};'];
              case 7 then
                txt=[txt;
                     'SCSUINT16_COP in'+string(i)+'_'+rdnam+'[] = {'+strcat(string(zeros(1,2*model.in(i)*model.in2(i))),',')+'};'];
              case 8 then
                txt=[txt;
                     'SCSUINT8_COP in'+string(i)+'_'+rdnam+'[]  = {'+strcat(string(zeros(1,2*model.in(i)*model.in2(i))),',')+'};'];
              else
                txt=[txt;
                     'SCSREAL_COP in'+string(i)+'_'+rdnam+'[]   = {'+strcat(string(zeros(1,model.in(i)*model.in2(i)))+'.',',')+'};'];
            end
          end
          txt3=[txt3;
                'block_'+rdnam+'.nin          = nin_'+rdnam+';'
                'block_'+rdnam+'.insz         = insz_'+rdnam+';'
                'block_'+rdnam+'.inptr        = inptr_'+rdnam+';'];
        end
      end
    end
  end

  // 6 : model.out
  // 7 : model.out2
  // 8 : model.outtyp
  if (size(model.out,'*')<>0) then
    if (find(model.out<0)<>[]) then
      error('Undetermined first dimension for output port '+sci2exp(find(model.out<0))+'.');
    else
      if (find(model.out2<0)<>[]) then
        error('Undetermined second dimension for output port '+sci2exp(find(model.out2<0))+'.');
      else
        if (find(model.outtyp<0)<>[]) then
          error('Undetermined type for output port '+sci2exp(find(model.outtyp<0))+'.');
        else
          model.out2(find(model.out2==[]))=1
          txt=[txt;
               'int nout_'+rdnam+'           = '+string(size(model.out,'*'))+';'
               'int outsz_'+rdnam+'[]        = {'+strcat(string([(model.out(:))',(model.out2(:))',scs_nb2scs_c_nb((model.outtyp(:)))']),',')+'};'
               'void *outptr_'+rdnam+'[]     = {'+strcat(string(zeros(1,size(model.out,'*'))),',')+'};'];
          for i=1:size(model.out,'*')
            txt2=[txt2;
                  'outptr_'+rdnam+'['+string(i-1)+']          = (void *) out'+string(i)+'_'+rdnam+';'];
            select (model.outtyp(i))
              case 1 then
                txt=[txt;
                     'SCSREAL_COP out'+string(i)+'_'+rdnam+'[] = {'+strcat(string(zeros(1,model.out(i)*model.out2(i)))+'.',',')+'};'];
              case 2 then
                txt=[txt;
                     'SCSCOMPLEX_COP out'+string(i)+'_'+rdnam+'[] = {'+strcat(string(zeros(1,2*model.out(i)*model.out2(i)))+'.',',')+'};'];
              case 3 then
                txt=[txt;
                     'SCSINT32_COP out'+string(i)+'_'+rdnam+'[] = {'+strcat(string(zeros(1,2*model.out(i)*model.out2(i))),',')+'};'];
              case 4 then
                txt=[txt;
                     'SCSINT16_COP out'+string(i)+'_'+rdnam+'[] = {'+strcat(string(zeros(1,2*model.out(i)*model.out2(i))),',')+'};'];
              case 5 then
                txt=[txt;
                     'SCSINT8_COP out'+string(i)+'_'+rdnam+'[]  = {'+strcat(string(zeros(1,2*model.out(i)*model.out2(i))),',')+'};'];
              case 6 then
                txt=[txt;
                     'SCSUINT32_COP out'+string(i)+'_'+rdnam+'[] = {'+strcat(string(zeros(1,2*model.out(i)*model.out2(i))),',')+'};'];
              case 7 then
                txt=[txt;
                     'SCSUINT16_COP out'+string(i)+'_'+rdnam+'[] = {'+strcat(string(zeros(1,2*model.out(i)*model.out2(i))),',')+'};'];
              case 8 then
                txt=[txt;
                     'SCSUINT8_COP out'+string(i)+'_'+rdnam+'[] = {'+strcat(string(zeros(1,2*model.out(i)*model.out2(i))),',')+'};'];
              else
                txt=[txt;
                     'SCSREAL_COP out'+string(i)+'_'+rdnam+'[]  = {'+strcat(string(zeros(1,model.out(i)*model.out2(i)))+'.',',')+'};'];
            end
          end
          txt3=[txt3;
                'block_'+rdnam+'.nout         = nout_'+rdnam+';'
                'block_'+rdnam+'.outsz        = outsz_'+rdnam+';'
                'block_'+rdnam+'.outptr       = outptr_'+rdnam+';'];
        end
      end
    end
  end

  // 9 : model.evtin

  // 10 : model.evtout
  if (size(model.evtout,'*')<>0) then
    if ((size(model.evtout,'*'))<>(size(model.firing,'*'))) then
      error('Bad evtout definition. Please check evtout and firing fields.');
    else
      txt=[txt
           'int nevout_'+rdnam+'          = '+string(size(model.evtout,'*'))+';'
           'double evout_'+rdnam+'[]      = {'+strcat(string((model.firing(:))'),',')+'};'];
      txt3=[txt3;
            'block_'+rdnam+'.nevout     = nevout_'+rdnam+';'
            'block_'+rdnam+'.evout      = evout_'+rdnam+';'];
    end
  end

  // 11 : model.state
  if (size(model.state,'*'))<>0 then
    txt=[txt
         'int nx_'+rdnam+'             = '+string(size(model.state,'*'))+';'
         'double x_'+rdnam+'[]         = {'+string(strcat(string_to_c_string(model.state),','))+'};'
         'double xd_'+rdnam+'[]        = {'+string(strcat(string(zeros(1,size(model.state,'*')))+'.',','))+'};'
         'int xprop_'+rdnam+'[]        = {'+string(strcat(string(ones(1,size(model.state,'*'))),','))+'};'
         'double res_'+rdnam+'[]       = {'+string(strcat(string(zeros(1,size(model.state,'*')))+'.',','))+'};'
         ''];
    txt3=[txt3;
          'block_'+rdnam+'.nx           = nx_'+rdnam+';'
          'block_'+rdnam+'.x            = x_'+rdnam+';'
          'block_'+rdnam+'.xd           = xd_'+rdnam+';'
          'block_'+rdnam+'.xprop        = xprop_'+rdnam+';'
          'block_'+rdnam+'.res          = res_'+rdnam+';'];
  end

  // 12 : model.dstate
  if (size(model.dstate,'*'))<>0 then
    txt=[txt
         'int nz_'+rdnam+'             = '+string(size(model.dstate,'*'))+';'
         'double z_'+rdnam+'[]         = {'+string(strcat(string_to_c_string(model.dstate),','))+'};'];
    txt3=[txt3;
          'block_'+rdnam+'.nz           = nz_'+rdnam+';'
          'block_'+rdnam+'.z            = z_'+rdnam+';'];
  end

  // 13 : model.odstate
  if (model.odstate<>list()) then
    oztyp=zeros(1,lstsize(model.odstate));
    ozsz=zeros(1,2*lstsize(model.odstate));
    for i=1:lstsize(model.odstate)
      oztyp(i)=mat2scs_c_nb(model.odstate(i));
      ozsz(i)=size(model.odstate(i),1);
      ozsz(i+lstsize(model.odstate))=size(model.odstate(i),2);
    end
    txt=[txt
         '/* */'
         'int noz_'+rdnam+'            = '+string(lstsize(model.odstate))+';'
         'int ozsz_'+rdnam+'[]         = {'+string(strcat(string(ozsz),','))+'};'
         'int oztyp_'+rdnam+'[]        = {'+string(strcat(string(oztyp),','))+'};'
         'void *ozptr_'+rdnam+'[]      = {'+string(strcat(string(zeros(1,lstsize(model.odstate))),','))+'};'];
    for i=1:lstsize(model.odstate)
      txt2=[txt2;
            'ozptr_'+rdnam+'['+string(i-1)+']           = (void *) oz'+string(i)+'_'+rdnam+';'];
      select (oztyp(i))
        case 10 then
          txt=[txt;
               'SCSREAL_COP oz'+string(i)+'_'+rdnam+'[]  = {'+strcat(string_to_c_string(model.odstate(i)(:)),',')+'};'];
        case 11 then
          txt=[txt;
               'SCSCOMPLEX_COP oz'+string(i)+'_'+rdnam+'[] = {'+strcat(string_to_c_string([real(model.odstate(i)(:));imag(model.odstate(i)(:))]),',')+'};'];
        case 84 then
          txt=[txt;
               'SCSINT32_COP oz'+string(i)+'_'+rdnam+'[] = {'+strcat(string(model.odstate(i)(:)),',')+'};'];
        case 82 then
          txt=[txt;
               'SCSINT16_COP oz'+string(i)+'_'+rdnam+'[] = {'+strcat(string(model.odstate(i)(:)),',')+'};'];
        case 81 then
          txt=[txt;
               'SCSINT8_COP oz'+string(i)+'_'+rdnam+'[] = {'+strcat(string(model.odstate(i)(:)),',')+'};'];
        case 814 then
          txt=[txt;
               'SCSUINT32_COP oz'+string(i)+'_'+rdnam+'[] = {'+strcat(string(model.odstate(i)(:)),',')+'};'];
        case 812 then
          txt=[txt;
               'SCSUINT16_COP oz'+string(i)+'_'+rdnam+'[] = {'+strcat(string(model.odstate(i)(:)),',')+'};'];
        case 811 then
          txt=[txt;
               'SCSUINT8_COP oz'+string(i)+'_'+rdnam+'[] = {'+strcat(string(model.odstate(i)(:)),',')+'};'];
        else
          txt=[txt;
               'SCSREAL_COP oz'+string(i)+'_'+rdnam+'[] = {'+strcat(string(zeros(1,size(model.odstate(i),'*')))+'.',',')+'};'];
      end
    end
    txt3=[txt3;
          'block_'+rdnam+'.noz          = noz_'+rdnam+';'
          'block_'+rdnam+'.ozsz         = ozsz_'+rdnam+';'
          'block_'+rdnam+'.oztyp        = oztyp_'+rdnam+';'
          'block_'+rdnam+'.ozptr        = ozptr_'+rdnam+';'];
  end

  // 14 : model.rpar
  if (size(model.rpar,'*'))<>0 then
    txt=[txt
         'int nrpar_'+rdnam+'          = '+string(size(model.rpar,'*'))+';'
         'double rpar_'+rdnam+'[]      = {'+string(strcat(string_to_c_string(model.rpar),','))+'};'];
    txt3=[txt3;
          'block_'+rdnam+'.nrpar        = nrpar_'+rdnam+';'
          'block_'+rdnam+'.rpar         = rpar_'+rdnam+';'];
  end

  // 15 : model.ipar
  if (size(model.ipar,'*'))<>0 then
    txt=[txt
         'int nipar_'+rdnam+'          = '+string(size(model.ipar,'*'))+';'
         'int ipar_'+rdnam+'[]         = {'+string(strcat(string(model.ipar),','))+'};'];
    txt3=[txt3;
          'block_'+rdnam+'.nipar        = nipar_'+rdnam+';'
          'block_'+rdnam+'.ipar         = ipar_'+rdnam+';'];
  end

  // 16 : model.opar
  if (model.opar<>list()) then
    opartyp=zeros(1,lstsize(model.opar));
    oparsz=zeros(1,2*lstsize(model.opar));
    for i=1:lstsize(model.opar)
      opartyp(i)=mat2scs_c_nb(model.opar(i));
      oparsz(i)=size(model.opar(i),1);
      oparsz(i+lstsize(model.opar))=size(model.opar(i),2);
    end
    txt=[txt
         '/* */'
         'int nopar_'+rdnam+'          = '+string(lstsize(model.opar))+';'
         'int oparsz_'+rdnam+'[]       = {'+string(strcat(string(oparsz),','))+'};'
         'int opartyp_'+rdnam+'[]      = {'+string(strcat(string(opartyp),','))+'};'
         'void *oparptr_'+rdnam+'[]    = {'+string(strcat(string(zeros(1,lstsize(model.opar))),','))+'};'];
    for i=1:lstsize(model.opar)
      txt2=[txt2;
            'oparptr_'+rdnam+'['+string(i-1)+']          = (void *) opar'+string(i)+'_'+rdnam+';'];
      select (opartyp(i))
        case 10 then
          txt=[txt;
               'SCSREAL_COP opar'+string(i)+'_'+rdnam+'[] = {'+strcat(string_to_c_string(model.opar(i)(:)),',')+'};'];
        case 11 then
          txt=[txt;
               'SCSCOMPLEX_COP opar'+string(i)+'_'+rdnam+'[] = {'+strcat(string_to_c_string([real(model.opar(i)(:));imag(model.opar(i)(:))]),',')+'};'];
        case 84 then
          txt=[txt;
               'SCSINT32_COP opar'+string(i)+'_'+rdnam+'[] = {'+strcat(string(model.opar(i)(:)),',')+'};'];
        case 82 then
          txt=[txt;
               'SCSINT16_COP opar'+string(i)+'_'+rdnam+'[] = {'+strcat(string(model.opar(i)(:)),',')+'};'];
        case 81 then
          txt=[txt;
               'SCSINT8_COP opar'+string(i)+'_'+rdnam+'[] = {'+strcat(string(model.opar(i)(:)),',')+'};'];
        case 814 then
          txt=[txt;
               'SCSUINT32_COP opar'+string(i)+'_'+rdnam+'[] = {'+strcat(string(model.opar(i)(:)),',')+'};'];
        case 812 then
          txt=[txt;
               'SCSUINT16_COP opar'+string(i)+'_'+rdnam+'[] = {'+strcat(string(model.opar(i)(:)),',')+'};'];
        case 811 then
          txt=[txt;
               'SCSUINT8_COP opar'+string(i)+'_'+rdnam+'[] = {'+strcat(string(model.opar(i)(:)),',')+'};'];
        else
          txt=[txt;
               'SCSREAL_COP opar'+string(i)+'_'+rdnam+'[] = {'+strcat(string(zeros(1,size(model.opar(i),'*')))+'.',',')+'};'];
      end
    end
    txt3=[txt3;
          'block_'+rdnam+'.nopar      = nopar_'+rdnam+';'
          'block_'+rdnam+'.oparsz     = oparsz_'+rdnam+';'
          'block_'+rdnam+'.opartyp    = opartyp_'+rdnam+';'
          'block_'+rdnam+'.oparptr    = oparptr_'+rdnam+';'];
  end

  // 20 : model.label
  if (model.label<>"") then
    txt=[txt
         'char label_'+rdnam+'[]       = ""'+string(model.label)+'"";'];
    txt3=[txt3;
          'block_'+rdnam+'.label        = label_'+rdnam+';'];
  end

  // 21 : model.nzcross
  if (model.nzcross<>0) then
    txt=[txt
         'int ng_'+rdnam+'             = '+string(size(model.nzcross,'*'))+';'
         'double g_'+rdnam+'[]         = {'+string(strcat(string(zeros(1,size(model.nzcross,'*')))+'.',','))+'};'
         'int jroot_'+rdnam+'[]        = {'+string(strcat(string(zeros(1,size(model.nzcross,'*'))),','))+'};'];
    txt3=[txt3;
          'block_'+rdnam+'.ng           = ng_'+rdnam+';'
          'block_'+rdnam+'.g            = g_'+rdnam+';'
          'block_'+rdnam+'.jroot        = jroot_'+rdnam+';'
          'block_'+rdnam+'.ztyp         = ztyp_'+rdnam+';'];
  end

  // 22 : model.nmode
  if (model.nmode<>0) then
    txt=[txt
         'int nmode_'+rdnam+'          = '+string(size(model.nmode,'*'))+';'
         'int mode_'+rdnam+'[]         = {'+string(strcat(string(zeros(1,size(model.nmode,'*'))),','))+'};'];
    txt3=[txt3;
          'block_'+rdnam+'.nmode        = nmode_'+rdnam+';'
          'block_'+rdnam+'.mode         = mode_'+rdnam+';'];
  end

  // work !
  txt=[txt
       'void *work_'+rdnam+'[]         = {0};'];
  txt3=[txt3;
        'block_'+rdnam+'.work         = work_'+rdnam+';'];

  txt2=['/* */'
        txt2;
        ''
        '/* */'
        txt3];

endfunction

function [txt]=BlockProto(bk)
//Copyright (c) 1989-2010 Metalau project INRIA

//BlockProto : generate prototype for a calling C sequence
//             of a scicos computational function
//
// Input :  bk   : block index in cpr
//
// Output : txt  : the generated prototype
//

  nin=inpptr(bk+1)-inpptr(bk);  //* number of input ports */
  nout=outptr(bk+1)-outptr(bk); //* number of output ports */
  funs_bk=funs(bk); //* name of the computational function */
  funtyp_bk=funtyp(bk); //* type of the computational function */
  ztyp_bk=ztyp(bk); //* zero crossing type */

  //&& call make_BlockProto
  txt=make_BlockProto(nin,nout,funs_bk,funtyp_bk,ztyp_bk,bk)

endfunction

function [Code]=make_act_sens_events()
//Copyright (c) 1989-2010 Metalau project INRIA

//@@ make_act_sens_events : generates the routine for actuators
//                          sensors & events
//
// Output : Code : text of the generated file
//

  //@@ header
  Code=['/* Custumizable code for events/actuators/sensors */'
        '/*     Generated by Code_Generation toolbox of Scicos with '+ ..
        get_scicos_version()+' */'
        '/*     date : '+date()+' */'
        ''
        '/* Copyright (c) 1989-2010 Metalau project INRIA */'
        ''
        '/* ---- Headers ---- */'
        '#include <stdio.h>'
        '#include <stdlib.h>'
        '#include <math.h>'
        '#include <string.h>'
        ''
        '/* ---- File ptrs declaration to read/write signals data ----*/']
        
  fprr_str=[]
  fprw_str=[]
  
  nact=size(act,'*')
  ncap=size(cap,'*')
  
  for i=1:ncap
    fprr_str=fprr_str+'*fprr_'+string(i)+',';
  end
  if ncap<>0 then
    if part(fprr_str,length(fprr_str))==',' then
      fprr_str=part(fprr_str,1:length(fprr_str)-1);
    end
  end
  
  for i=1:nact
    fprw_str=fprw_str+'*fprw_'+string(i)+',';
  end
  if nact<>0 then
    if part(fprw_str,length(fprw_str))==',' then
      fprw_str=part(fprw_str,1:length(fprw_str)-1);
    end
  end
  
  if nact<>0 & ncap<>0 then
    Code=[Code
          'FILE '+fprr_str+','+fprw_str+';'
          '']
  elseif ncap<>0 then
    Code=[Code
          'FILE '+fprr_str+';'
          '']
  elseif nact<>0 then
    Code=[Code
          'FILE '+fprw_str+';'
          '']
  end
  
  //@@ events/actuators/sensors
  Code=[Code
        make_outevents()
        make_actuator()
        make_sensor()]

endfunction


function [Code]=make_actuator()
//Copyright (c) 1989-2010 Metalau project INRIA

//@@ make_actuator : Generating the routine for actuators
//                   for standalone
//
// Output : Code : text of the generated routine
//
// nb :
// actt=[i uk nuk_1 nuk_2 uk_t bllst(i).ipar]
//

  //## function prototype
  Call=['/*'+part('-',ones(1,40))+' Actuators */';
        'void '+rdnom+'_actuator(flag,nport,nevprt,t,u,nu1,nu2,ut,typout,outptr)']

  //## add comments
  comments=['     /*'
            '      * To be customized for standalone execution';
            '      * flag   : specifies the action to be done'
            '      * nport  : specifies the  index of the super-block'
            '      *          regular input (The input ports are numbered'
            '      *          from the top to the bottom )'
            '      * nevprt : indicates if an activation had been received'
            '      *          0 = no activation'
            '      *          1 = activation'
            '      * t      : the current time value'
            '      * u      : the vector inputs value'
            '      * nu1    : the input size 1'
            '      * nu2    : the input size 2'
            '      * ut     : the input type'
            '      * typout : learn mode (0 from terminal,1 from input file)'
            '      * outptr : pointer to out data'
            '      *          typout=0, outptr not used'
            '      *          typout=1, outptr contains the output file name'
            '      */']

  //## variables declaration
  dcl=['     int *flag,*nevprt,*nport;'
       '     int *nu1,*nu2,*ut;'
       ''
       '     int typout;'
       '     void *outptr;'
       ''
       '     double *t;'
       '     void *u;'
       '{'
       '  int j,k,l;'
       '  char *file_str;'
       '  char buf[1024];'];

  //## code for terminal
  a_actuator=['    /* skeleton to be customized */'
              '    switch (*flag) {'
              '    case 4 : /* actuator initialisation */'
              '      /* do whatever you want to initialize the actuator */'
              '      break;']

  if szclkIN==[]&ALWAYS_ACTIVE then
    a_actuator=[a_actuator;
                '    case 1 :']
  else
    a_actuator=[a_actuator;
                '    case 2 :']
  end

  a_actuator=[a_actuator;
              '      /*if(*nevprt>0) { print the input value */'
              '        switch (*ut) {'
              '        case 10 :'
              '          for (l=0;l<*nu2;l++) {'
              '            for (k=0;k<*nu1;k++) {'
              '              printf(""Actuator: time=%f, '+...
                                'u(%d,%d) of actuator %d is %f '+...
                                '\n"", \'
              '                     *t, k, l, *nport,'+...
                                    '*((double *) u+(k+l*(*nu1))));'
              '            }'
              '          }'
              '          break;'
              ''
              '        case 11 :'
              '          for (l=0;l<*nu2;l++) {'
              '            for (k=0;k<*nu1;k++) {'
              '              printf(""Actuator: time=%f, '+...
                                'u(%d,%d) of actuator %d is %f,%f '+...
                                '\n"", \'
              '                     *t, k, l, *nport,'+...
                                    '*((double *) u+(k+l*(*nu1))),'+...
                                    '*((double *) u+((*nu1)*(*nu2)+k+l*(*nu1))));'
              '            }'
              '          }'
              '          break;'
              ''
              '        case 81 :'
              '          for (l=0;l<*nu2;l++) {'
              '            for (k=0;k<*nu1;k++) {'
              '              printf(""Actuator: time=%f, '+...
                                'u(%d,%d) of actuator %d is %i '+...
                                '\n"", \'
              '                     *t, k, l, *nport,'+...
                                    '*((char *) u+(k+l*(*nu1))));'
              '            }'
              '          }'
              '          break;'
              ''
              '        case 82 :'
              '          for (l=0;l<*nu2;l++) {'
              '            for (k=0;k<*nu1;k++) {'
              '              printf(""Actuator: time=%f, '+...
                                'u(%d,%d) of actuator %d is %hd '+...
                                '\n"", \'
              '                     *t, k, l, *nport,'+...
                                    '*((short *) u+(k+l*(*nu1))));'
              '            }'
              '          }'
              '          break;'
              ''
              '        case 84 :'
              '          for (l=0;l<*nu2;l++) {'
              '            for (k=0;k<*nu1;k++) {'
              '              printf(""Actuator: time=%f, '+...
                                'u(%d,%d) of actuator %d is %ld '+...
                                '\n"", \'
              '                     *t, k, l, *nport,'+...
                                    '*((long *) u+(k+l*(*nu1))));'
              '            }'
              '          }'
              '          break;'
              ''
              '        case 811 :'
              '          for (l=0;l<*nu2;l++) {'
              '            for (k=0;k<*nu1;k++) {'
              '              printf(""Actuator: time=%f, '+...
                                'u(%d,%d) of actuator %d is %d '+...
                                '\n"", \'
              '                     *t, k, l, *nport,'+...
                                    '*((unsigned char *) u+(k+l*(*nu1))));'
              '            }'
              '          }'
              '          break;'
              ''
              '        case 812 :'
              '          for (l=0;l<*nu2;l++) {'
              '            for (k=0;k<*nu1;k++) {'
              '              printf(""Actuator: time=%f, '+...
                                'u(%d,%d) of actuator %d is %hu '+...
                                '\n"", \'
              '                     *t, k, l, *nport,'+...
                                    '*((unsigned short *) u+(k+l*(*nu1))));'
              '            }'
              '          }'
              '          break;'
              ''
              '        case 814 :'
              '          for (l=0;l<*nu2;l++) {'
              '            for (k=0;k<*nu1;k++) {'
              '              printf(""Actuator: time=%f, '+...
                                'u(%d,%d) of actuator %d is %lu '+...
                                '\n"", \'
              '                     *t, k, l, *nport,'+...
                                    '*((unsigned long *) u+(k+l*(*nu1))));'
              '            }'
              '          }'
              '          break;'
              '        }'
              '      /*} */'
              '      break;'
              '    case 5 : /* actuator ending */'
              '      /* do whatever you want to end the actuator */'
              '      break;'
              '    }']

  //## code for output file
  b_actuator=['    /* skeleton to be customized */'
              '    switch (*flag) {'
              '    case 4 : /* actuator initialisation */'
              '      /* use of seprate files for actuators */'
              '      file_str = (char *) outptr;'
              '      l = 0;'
              ''
              '      /* look at for an extension */'
              '      for(k=strlen(file_str);k>=0;k--) {'
              '        if (file_str[k] == ''.'') {'
              '          l = k;'
              '          break;'
              '         }'
              '       }'
              ''
              '       /* if an extension is found, then add suffixe just before */'
              '       if (l !=0 ) {'
              '         j = 0;'
              '         for (k=0;k<l;k++) {'
              '           buf[j] = file_str[k];'
              '           j++;'
              '         }'
              '         buf[j] = ''_'';'
              '         j++;'
              '         buf[j] = ''\0'';'
              '         sprintf(buf,'"%s%d'",buf,*nport);'
              '         strcat(buf,&file_str[l]);'
              '       }'
              '       else {'
              '         sprintf(buf,'"%s_%d'",file_str,*nport);'
              '       }'
              ''
              '      /* open file */'
              '      fprw_1 = fopen(buf,'"wt'");'
              '      if( fprw_1 == NULL ) {'
              '        fprintf(stderr,'"Error opening file: %s\n'", buf);'
              '        /* internal error */'
              '        *flag=-3;'
              '        return;'
              '      }'
              '      break;']

  if szclkIN==[]&ALWAYS_ACTIVE then
    b_actuator=[b_actuator;
                '    case 1 : /* fprintf the input value */']
  else
    b_actuator=[b_actuator;
                '    case 2 : /* fprintf the input value */']
  end

  b_actuator=[b_actuator
              '      /*if(*nevprt>0) {*/'
              '        /* write time */'
              '        fprintf(fprw_1,""%f "",*t);'
              ''
              '        switch (*ut) {'
              '        case 10 :'
              '          for (l=0;l<*nu2;l++) {'
              '            for (k=0;k<*nu1;k++) {'
              '              fprintf(fprw_1,""%f "", \'
              '                           *((double *) u+(k+l*(*nu1))));'
              '            }'
              '          }'
              '          fprintf(fprw_1,""\n"");'
              '          break;'
              ''
              '        case 11 :'
              '          for (l=0;l<*nu2;l++) {'
              '            for (k=0;k<*nu1;k++) {'
              '              fprintf(fprw_1,""%f "" \'
              '                           ""%f "", \'
              '                           *((double *) u+(k+l*(*nu1))), \'
              '                           *((double *) u+((*nu1)*(*nu2)+k+l*(*nu1))));'
              '            }'
              '          }'
              '          fprintf(fprw_1,""\n"");'
              '          break;'
              ''
              '        case 81 :'
              '          for (l=0;l<*nu2;l++) {'
              '            for (k=0;k<*nu1;k++) {'
              '              fprintf(fprw_1,""%i "", \'
              '                           *((char *) u+(k+l*(*nu1))));'
              '            }'
              '          }'
              '          fprintf(fprw_1,""\n"");'
              '          break;'
              ''
              '        case 82 :'
              '          for (l=0;l<*nu2;l++) {'
              '            for (k=0;k<*nu1;k++) {'
              '              fprintf(fprw_1,""%hd "", \'
              '                           *((short *) u+(k+l*(*nu1))));'
              '            }'
              '          }'
              '          fprintf(fprw_1,""\n"");'
              '          break;'
              ''
              '        case 84 :'
              '          for (l=0;l<*nu2;l++) {'
              '            for (k=0;k<*nu1;k++) {'
              '              fprintf(fprw_1,""%ld "", \'
              '                           *((long *) u+(k+l*(*nu1))));'
              '            }'
              '          }'
              '          fprintf(fprw_1,""\n"");'
              '          break;'
              ''
              '        case 811 :'
              '          for (l=0;l<*nu2;l++) {'
              '            for (k=0;k<*nu1;k++) {'
              '              fprintf(fprw_1,""%d \n"", \'
              '                           *((unsigned char *) u+(k+l*(*nu1))));'
              '            }'
              '          }'
              '          fprintf(fprw_1,""\n"");'
              '          break;'
              ''
              '        case 812 :'
              '          for (l=0;l<*nu2;l++) {'
              '            for (k=0;k<*nu1;k++) {'
              '              fprintf(fprw_1,""%hu "", \'
              '                           *((unsigned short *) u+(k+l*(*nu1))));'
              '            }'
              '          }'
              '          fprintf(fprw_1,""\n"");'
              '          break;'
              ''
              '        case 814 :'
              '          for (l=0;l<*nu2;l++) {'
              '            for (k=0;k<*nu1;k++) {'
              '              fprintf(fprw_1,""%lu "", \'
              '                           *((unsigned long *) u+(k+l*(*nu1))));'
              '            }'
              '          }'
              '          fprintf(fprw_1,""\n"");'
              '          break;'
              '        }'
              '      /*} */'
              '      break;'
              '    case 5 : /* actuator ending */'
              '      fclose(fprw_1);'
              '      break;'
              '    }']


  //## function prototype
  Call_dum=['/*'+part('-',ones(1,40))+' Dummy Actuators */';
            'void '+rdnom+'_dummy_actuator(flag,nport,nevprt,t,typout,outptr)']

  //## add comments
  comments_dum=['     /*'
                '      * To be customized for standalone execution';
                '      * flag   : specifies the action to be done'
                '      * nport  : specifies the  index of the Super Bloc'
                '      *          regular input (The input ports are numbered'
                '      *          from the top to the bottom )'
                '      * nevprt : indicates if an activation had been received'
                '      *          0 = no activation'
                '      *          1 = activation'
                '      * t      : the current time value'
                '      * typout : learn mode (0 from terminal,1 from input file)'
                '      * outptr : pointer to out data'
                '      *          typout=0, outptr not used'
                '      *          typout=1, outptr contains the output file name'
                '      */']

  //## variables declaration
  dcl_dum=['     int *flag,*nevprt,*nport;'
           ''
           '     int typout;'
           '     void *outptr;'
           ''
           '     double *t;'
           '{'
           '  int j,k,l;'
           '  char *file_str;'
           '  char buf[1024];']

  //## code for terminal
  a_actuator_dum=['    /* skeleton to be customized */'
                  '    switch (*flag) {'
                  '    case 4 : /* actuator initialisation */'
                  '      /* do whatever you want to initialize the actuator */'
                  '      break;']

  if szclkIN==[]&ALWAYS_ACTIVE then
    a_actuator_dum=[a_actuator_dum;
                    '    case 1 :']
  else
    a_actuator_dum=[a_actuator_dum;
                    '    case 2 :']
  end

  a_actuator_dum=[a_actuator_dum;
                  '      /*if(*nevprt>0) { print the input value */'
                  '      printf(""Actuator: time=%f of dummy actuator %d\n"", *t, *nport);'
                  '      break;'
                  '    case 5 : /* actuator ending */'
                  '      /* do whatever you want to end the actuator */'
                  '      break;'
                  '    }']

  //## code for output file
  b_actuator_dum=['    /* skeleton to be customized */'
                  '    switch (*flag) {'
                  '    case 4 : /* actuator initialisation */'
                  '      /* use separate files for actuators */'
                  '      file_str = (char *) outptr;'
                  '      l = 0;'
                  ''
                  '      /* look at for an extension */'
                  '      for(k=strlen(file_str);k>=0;k--) {'
                  '        if (file_str[k] == ''.'') {'
                  '          l = k;'
                  '          break;'
                  '         }'
                  '       }'
                  ''
                  '       /* if an extension is found, then add suffixe just before */'
                  '       if (l !=0 ) {'
                  '         j = 0;'
                  '         for (k=0;k<l;k++) {'
                  '           buf[j] = file_str[k];'
                  '           j++;'
                  '         }'
                  '         buf[j] = ''_'';'
                  '         j++;'
                  '         buf[j] = ''\0'';'
                  '         sprintf(buf,'"%s%d'",buf,*nport);'
                  '         strcat(buf,&file_str[l]);'
                  '       }'
                  '       else {'
                  '         sprintf(buf,'"%s_%d'",file_str,*nport);'
                  '       }'
                  ''
                  '      /* open file */'
                  '      fprw_1 = fopen(buf,'"wt'");'
                  '      if( fprw_1 == NULL ) {'
                  '        fprintf(stderr,'"Error opening file: %s\n'", buf);'
                  '        /* internal error */'
                  '        *flag=-3;'
                  '        return;'
                  '      }'
                  '      break;']

  if szclkIN==[]&ALWAYS_ACTIVE then
    b_actuator_dum=[b_actuator_dum;
                    '    case 1 : /* fprintf the time value */']
  else
    b_actuator_dum=[b_actuator_dum;
                    '    case 2 : /* fprintf the time value */']
  end

  b_actuator_dum=[b_actuator_dum
                  '      /*if(*nevprt>0) {*/'
                  '        /* write time */'
                  '        fprintf(fprw_1,""%f "",*t);'
                  '        fprintf(fprw_1,""\n"");'
                  '      break;'
                  '    case 5 : /* actuator ending */'
                  '      fclose(fprw_1);'
                  '      break;'
                  '    }']

  //@@ main text generation
  nc=size(act,'*')
  Code=[]
  
  if nc==1 then
    if strindex(cpr.sim.funs(actt(1,1)),"dummy")<>[] then
      Code=[Call_dum
            comments_dum
            dcl_dum
            '  if (typout == 0) { /* terminal */'
            a_actuator_dum
            '  }'
            '  else if (typout == 1) { /* file */'
            b_actuator_dum
            '  }'
            '}']
    else
      Code=[Call
            comments
            dcl
            '  if (typout == 0) { /* terminal */'
            a_actuator
            '  }'
            '  else if (typout == 1) { /* file */'
            b_actuator
            '  }'
            '}']
    end
  elseif nc>1 then
    S='    switch (*nport) {'
    for k=1:nc
      if strindex(cpr.sim.funs(actt(k,1)),"dummy")<>[] then
        S_dum='    switch (*nport) {'
        break
      end
    end
    for k=1:nc
      if strindex(cpr.sim.funs(actt(k,1)),"dummy")<>[] then
        S_dum=[S_dum;
               '    case '+string(k)+' :/* Port number '+string(k)+' ----------*/'
               '    '+a_actuator_dum
               '    break;']
      else
        S=[S;
           '    case '+string(k)+' :/* Port number '+string(k)+' ----------*/'
           '    '+a_actuator
           '    break;']
      end
    end
    S=[S;'    }']
    for k=1:nc
      if strindex(cpr.sim.funs(actt(k,1)),"dummy")<>[] then
        S_dum=[S_dum;'    }']
        break
      end
    end

    T='    switch (*nport) {'
    for k=1:nc
      if strindex(cpr.sim.funs(actt(k,1)),"dummy")<>[] then
        T_dum='    switch (*nport) {'
        break
      end
    end
    for k=1:nc
      if strindex(cpr.sim.funs(actt(k,1)),"dummy")<>[] then
        T_dum=[T_dum;
               '    case '+string(k)+' :/* Port number '+string(k)+' ----------*/'
               '    '+strsubst(b_actuator_dum,'fprw_1','fprw_'+string(k))
               '    break;']
      else
        T=[T;
           '    case '+string(k)+' :/* Port number '+string(k)+' ----------*/'
           '    '+strsubst(b_actuator,'fprw_1','fprw_'+string(k))
           '    break;']
      end
    end
    T=[T;'    }']
    for k=1:nc
      if strindex(cpr.sim.funs(actt(k,1)),"dummy")<>[] then
        T_dum=[T_dum;'    }']
        break
      end
    end

    if exists('T_dum') then
      only_dum=%t;
      for k=1:nc
        if strindex(cpr.sim.funs(actt(k,1)),"dummy")==[] then
          only_dum=%f;
          break
        end
      end
      if only_dum then
        Code=[Code
              Call_dum
              comments_dum
              dcl_dum
              '  if (typout == 0) { /* terminal */'
              S_dum
              '  }'
              '  else if (typout == 1) { /* file */'
              T_dum
              '  }'
              '}']
      else
        Code=[Code
              Call
              comments
              dcl
              '  if (typout == 0) { /* terminal */'
              S
              '  }'
              '  else if (typout == 1) { /* file */'
              T
              '  }'
              '}'
              ''
              Call_dum
              comments_dum
              dcl_dum
              '  if (typout == 0) { /* terminal */'
              S_dum
              '  }'
              '  else if (typout == 1) { /* file */'
              T_dum
              '  }'
              '}']
      end
    else
      Code=[Code
            Call
            comments
            dcl
            '  if (typout == 0) { /* terminal */'
            S
            '  }'
            '  else if (typout == 1) { /* file */'
            T
            '  }'
            '}']
    end
  end
endfunction

function [txt]=make_BlockProto(nin,nout,funs_bk,funtyp_bk,ztyp_bk,bk)
//Copyright (c) 1989-2010 Metalau project INRIA

//make_BlockProto : generate prototype for a calling C sequence
//                  of a scicos computational function
//
// Input :  nin       : number of input ports
//          nout      : number of output ports
//          funs_bk   : name of the computational function
//          funtyp_bk : type of the computational function
//          ztyp_bk   : say if block has zero crossings
//          bk        : an index number
//
// Output : txt  : the generated prototype
//

  //## check and adjust function type
  ftyp=funtyp_bk
  ftyp_tmp=modulo(funtyp_bk,10000)
  if ftyp_tmp>2000 then
    ftyp=ftyp-2000
  elseif ftyp_tmp>1000 then
    ftyp=ftyp-1000
  end

  //** check function type
  if ftyp < 0 then //** ifthenelse eselect blocks
      txt = [];
      return;
  else
    if (ftyp<>0 & ftyp<>1 & ftyp<>2 & ftyp<>3 & ftyp<>4  & ftyp<>10004) then
      disp("types other than 0,1,2,3 or 4/10004 are not yet supported.")
      txt = [];
      return;
    end
  end

  //@@ agenda_blk
  if funs_bk=='agenda_blk' then
    txt=[]
    return;
  end

  //** add comment
  txt=[get_comment('proto_blk',list(funs_bk,funtyp_bk,bk,ztyp_bk));]

  select ftyp
    //** zero funtyp
    case 0 then

      //*********** prototype definition ***********//
      txtp=['(int *, int *, double *, double *, double *, int *, double *, \';
            ' int *, double *, int *, double *, int *,int *, int *, \';
            ' double *, int *, double *, int *);'];
      if (funtyp_bk>2000 & funtyp_bk<3000)
        blank = get_blank('void '+funs_bk+'(');
        txtp(1) = 'void '+funs_bk+txtp(1);
      elseif (funtyp_bk<2000)
        //@@ special case for andlog func : should be fixed in scicos
        if funs_bk <> 'andlog' then
          txtp(1) = 'void C2F('+funs_bk+')'+txtp(1);
          blank = get_blank('void C2F('+funs_bk+')');
        else
          blank = get_blank('void '+funs_bk+'(');
          txtp(1) = 'void '+funs_bk+txtp(1);
        end
      end
      txtp(2:$) = blank + txtp(2:$);
      txt = [txt;txtp];
      //*******************************************//


    //**
    case 1 then

      //*********** prototype definition ***********//
      txtp=['(int *, int *, double *, double *, double *, int *, double *, \';
            ' int *, double *, int *, double *, int *,int *, int *';]
      if (funtyp_bk>2000 & funtyp_bk<3000)
        blank = get_blank('void '+funs_bk+'(');
        txtp(1) = 'void '+funs_bk+txtp(1);
      elseif (funtyp_bk<2000)
        txtp(1) = 'void C2F('+funs_bk+')'+txtp(1);
        blank = get_blank('void C2F('+funs_bk+')');
      end
      if nin>=1 | nout>=1 then
        txtp($)=txtp($)+', \'
        txtp=[txtp;'']
        if nin>=1 then
          for k=1:nin
            txtp($)=txtp($)+' double *, int * ,'
          end
          txtp($)=part(txtp($),1:length(txtp($))-1); //remove last ,
        end
        if nout>=1 then
          if nin>=1 then
            txtp($)=txtp($)+', \'
            txtp=[txtp;'']
          end
          for k=1:nout
            txtp($)=txtp($)+' double *, int * ,'
          end
          txtp($)=part(txtp($),1:length(txtp($))-1); //remove last ,
        end
      end

      if ztyp_bk then
        txtp($)=txtp($)+', \'
        txtp=[txtp;' double *,int *);'];
      else
        txtp($)=txtp($)+');';
      end

      txtp(2:$) = blank + txtp(2:$);
      txt = [txt;txtp];
      //*******************************************//

    //**
    case 2 then

      //*********** prototype definition ***********//

      txtp=['void '+funs_bk+...
            '(int *, int *, double *, double *, double *, int *, double *, \';
            ' int *, double *, int *, double *, int *, int *, int *, \'
            ' double **, int *, int *, double **,int *, int *'];
      if ~ztyp_bk then
        txtp($)=txtp($)+');';
      else
        txtp($)=txtp($)+', \';
        txtp=[txtp;
              ' double *,int *);']
      end
      blank = get_blank('void '+funs_bk);
      txtp(2:$) = blank + txtp(2:$);
      txt = [txt;txtp];
      //********************************************//

    //**
    case 4 then
      txt=[txt;
           'void '+funs_bk+'(scicos_block *, int );'];

    //**
    case 10004 then
      txt=[txt;
           'void '+funs_bk+'(scicos_block *, int );'];

  end

endfunction

function [Code]=make_callf()
//Copyright (c) 1989-2010 Metalau project INRIA

//make_callf : generate the function callf
//
// Input :  nothing
//
// Output : txt  : the generated function
//

Code=['/*---------------------------------------- callf function */'
      'void callf(double *t, scicos_block *block, int *flag)'
      '{'
      '  double* args[SZ_SIZE];'
      '  integer sz[SZ_SIZE];'
      '  double intabl[TB_SIZE];'
      '  double outabl[TB_SIZE];'
      ''
      '  int ii,in,out,ki,ko,no,ni,k,j;'
      '  int szi,flagi;'
      '  double *ptr_d=NULL;'
      ''
      '  /* function pointers type def */'
      '  voidf loc;'
      '  ScicosF0 loc0;'
      '  ScicosF loc1;'
      '  ScicosF2 loc2;'
      '  ScicosF2z loc2z;'
      '  ScicosFi loci1;'
      '  ScicosFi2 loci2;'
      '  ScicosFi2z loci2z;'
      '  ScicosF4 loc4;'
      ''
      '  int solver = C2F(cmsolver).solver;'
      '  scicos_time     = *t;'
      '  block_error     = flag;'
      ''
      '  /* debug block is never called */'
      '  if (block->type==99) return;'
      ''
      '  /* flag 7 implicit initialization */'
      '  flagi = *flag;'
      '  /* change flag to zero if flagi==7 for explicit block */'
      '  if(flagi==7 && block->type<10000) {'
      '    *flag=0;'
      '  }'
      ''
      '  /* display information for debugging mode */'
      ''
      '  /* C2F(scsptr).ptr = block->scsptr; */'
      ''
      '  /* get pointer of the function */'
      '  loc=block->funpt;'
      ''
      '  /* continuous state */'
      '  if(solver==100 && block->type<10000 && *flag==0) {'
      '    ptr_d = block->xd;'
      '    block->xd  = block->res;'
      '  }'
      ''
      '  /* switch loop */'
      '  switch (block->type) {'
      '    /*******************/'
      '    /* function type 0 */'
      '    /*******************/'
      '  case 0 :'
      '    {  /* This is for compatibility */'
      '       /* jroottmp is returned in g for old type */'
      '      if(block->nevprt<0) {'
      '        for (j =0;j<block->ng;++j) {'
      '          block->g[j] = (double)block->jroot[j];'
      '        }'
      '      }'
      ''
      '      /* concatenated entries and concatened outputs */'
      '      /* catenate inputs if necessary */'
      '      ni=0;'
      '      if (block->nin>1) {'
      '        ki=0;'
      '        for (in=0;in<block->nin;in++) {'
      '          szi=block->insz[in]*block->insz[in+block->nin];'
      '          for (ii=0;ii<szi;ii++) {'
      '            intabl[ki++]= *((double *)(block->inptr[in]) + ii);'
      '          }'
      '          ni=ni+szi;'
      '        }'
      '        args[0]=&(intabl[0]);'
      '      }'
      '      else {'
      '        if (block->nin==0) {'
      '          args[0]=NULL;'
      '        }'
      '        else {'
      '          args[0]= (double *)(block->inptr[0]);'
      '          ni=block->insz[0]*block->insz[1];'
      '        }'
      '      }'
      ''
      '      /* catenate outputs if necessary */'
      '      no=0;'
      '      if (block->nout>1) {'
      '        ko=0;'
      '        for (out=0;out<block->nout;out++) {'
      '          szi=block->outsz[out]*block->outsz[out+block->nout];'
      '          for (ii=0;ii<szi;ii++) {'
      '            outabl[ko++]= *((double *)(block->outptr[out]) + ii);'
      '          }'
      '          no=no+szi;'
      '       }'
      '        args[1]=&(outabl[0]);'
      '      }'
      '      else {'
      '        if (block->nout==0) {'
      '          args[1]=NULL;'
      '        }'
      '        else {'
      '          args[1]= (double *)(block->outptr[0]);'
      '          no=block->outsz[0]*block->outsz[1];'
      '        }'
      '      }'
      ''
      '      loc0 = (ScicosF0) loc;'
      ''
      '      (*loc0)(flag,&block->nevprt,t,block->xd,block->x,&block->nx,'
      '              block->z,&block->nz,'
      '              block->evout,&block->nevout,block->rpar,&block->nrpar,'
      '              block->ipar,&block->nipar,(double *)args[0],&ni,'
      '              (double *)args[1],&no);'
      ''
      '      /* split output vector on each port if necessary */'
      '      if (block->nout>1) {'
      '        ko=0;'
      '        for (out=0;out<block->nout;out++) {'
      '          szi=block->outsz[out]*block->outsz[out+block->nout];'
      '          for (ii=0;ii<szi;ii++) {'
      '            *((double *)(block->outptr[out]) + ii) = outabl[ko++];'
      '          }'
      '        }'
      '      }'
      ''
      '      /* adjust values of output register */'
      '      for(in=0;in<block->nevout;++in) {'
      '        block->evout[in]=block->evout[in]-*t;'
      '      }'
      ''
      '      break;'
      '    }'
      ''
      '    /*******************/'
      '    /* function type 1 */'
      '    /*******************/'
      '  case 1 :'
      '    { /* This is for compatibility */'
      '      /* jroot is returned in g for old type */'
      '      if(block->nevprt<0) {'
      '        for (j =0;j<block->ng;++j) {'
      '          block->g[j] = (double)block->jroot[j];'
      '        }'
      '     }'
      ''
      '      /* one entry for each input or output */'
      '      for (in = 0 ; in < block->nin ; in++) {'
      '        args[in]=block->inptr[in];'
      '        sz[in]=block->insz[in];'
      '      }'
      '      for (out=0;out<block->nout;out++) {'
      '        args[in+out]=block->outptr[out];'
      '        sz[in+out]=block->outsz[out];'
      '      }'
      '      /* with zero crossing */'
      '      if(block->ztyp>0) {'
      '        args[block->nin+block->nout]=block->g;'
      '        sz[block->nin+block->nout]=block->ng;'
      '      }'
      ''
      '      loc1 = (ScicosF) loc;'
      ''
      '      (*loc1)(flag,&block->nevprt,t,block->xd,block->x,&block->nx,'
      '              block->z,&block->nz,'
      '              block->evout,&block->nevout,block->rpar,&block->nrpar,'
      '              block->ipar,&block->nipar,'
      '              (double *)args[0],&sz[0],'
      '              (double *)args[1],&sz[1],(double *)args[2],&sz[2],'
      '              (double *)args[3],&sz[3],(double *)args[4],&sz[4],'
      '              (double *)args[5],&sz[5],(double *)args[6],&sz[6],'
      '              (double *)args[7],&sz[7],(double *)args[8],&sz[8],'
      '              (double *)args[9],&sz[9],(double *)args[10],&sz[10],'
      '              (double *)args[11],&sz[11],(double *)args[12],&sz[12],'
      '              (double *)args[13],&sz[13],(double *)args[14],&sz[14],'
      '              (double *)args[15],&sz[15],(double *)args[16],&sz[16],'
      '              (double *)args[17],&sz[17]);'
      ''
      '      /* adjust values of output register */'
      '      for(in=0;in<block->nevout;++in) {'
      '        block->evout[in]=block->evout[in]-*t;'
      '      }'
      ''
      '      break;'
      '    }'
      ''
      '    /*******************/'
      '    /* function type 2 */'
      '    /*******************/'
      '  case 2 :'
      '    { /* This is for compatibility */'
      '      /* jroot is returned in g for old type */'
      '      if(block->nevprt<0) {'
      '        for (j =0;j<block->ng;++j) {'
      '          block->g[j] = (double)block->jroot[j];'
      '        }'
      '      }'
      ''
      '      /* no zero crossing */'
      '      if (block->ztyp==0) {'
      '        loc2 = (ScicosF2) loc;'
      '        (*loc2)(flag,&block->nevprt,t,block->xd,block->x,&block->nx,'
      '                block->z,&block->nz,'
      '                block->evout,&block->nevout,block->rpar,&block->nrpar,'
      '                block->ipar,&block->nipar,(double **)block->inptr,'
      '                block->insz,&block->nin,'
      '                (double **)block->outptr,block->outsz,&block->nout);'
      '      }'
      '      /* with zero crossing */'
      '      else {'
      '        loc2z = (ScicosF2z) loc;'
      '        (*loc2z)(flag,&block->nevprt,t,block->xd,block->x,&block->nx,'
      '                 block->z,&block->nz,'
      '                 block->evout,&block->nevout,block->rpar,&block->nrpar,'
      '                 block->ipar,&block->nipar,(double **)block->inptr,'
      '                 block->insz,&block->nin,'
      '                 (double **)block->outptr,block->outsz,&block->nout,'
      '                 block->g,&block->ng);'
      '      }'
      ''
      '      /* adjust values of output register */'
      '      for(in=0;in<block->nevout;++in) {'
      '        block->evout[in]=block->evout[in]-*t;'
      '      }'
      ''
      '      break;'
      '    }'
      ''
      '    /*******************/'
      '    /* function type 4 */'
      '    /*******************/'
      '  case 4 :'
      '    { /* get pointer of the function type 4*/'
      '      loc4 = (ScicosF4) loc;'
      ''
      '      (*loc4)(block,*flag);'
      ''
      '      break;'
      '    }'
      ''
      '    /***********************/'
      '    /* function type 10001 */'
      '    /***********************/'
      '  case 10001 :'
      '    { /* This is for compatibility */'
      '      /* jroot is returned in g for old type */'
      '      if(block->nevprt<0) {'
      '        for (j =0;j<block->ng;++j) {'
      '          block->g[j] = (double)block->jroot[j];'
      '        }'
      '      }'
      ''
      '      /* implicit block one entry for each input or output */'
      '      for (in = 0 ; in < block->nin ; in++) {'
      '        args[in]=block->inptr[in];'
      '        sz[in]=block->insz[in];'
      '      }'
      '      for (out=0;out<block->nout;out++) {'
      '        args[in+out]=block->outptr[out];'
      '        sz[in+out]=block->outsz[out];'
      '      }'
      '      /* with zero crossing */'
      '      if(block->ztyp>0) {'
      '        args[block->nin+block->nout]=block->g;'
      '        sz[block->nin+block->nout]=block->ng;'
      '      }'
      ''
      '      loci1 = (ScicosFi) loc;'
      '      (*loci1)(flag,&block->nevprt,t,block->res,block->xd,block->x,'
      '               &block->nx,block->z,&block->nz,'
      '               block->evout,&block->nevout,block->rpar,&block->nrpar,'
      '               block->ipar,&block->nipar,'
      '               (double *)args[0],&sz[0],'
      '               (double *)args[1],&sz[1],(double *)args[2],&sz[2],'
      '               (double *)args[3],&sz[3],(double *)args[4],&sz[4],'
      '               (double *)args[5],&sz[5],(double *)args[6],&sz[6],'
      '               (double *)args[7],&sz[7],(double *)args[8],&sz[8],'
      '               (double *)args[9],&sz[9],(double *)args[10],&sz[10],'
      '               (double *)args[11],&sz[11],(double *)args[12],&sz[12],'
      '               (double *)args[13],&sz[13],(double *)args[14],&sz[14],'
      '               (double *)args[15],&sz[15],(double *)args[16],&sz[16],'
      '               (double *)args[17],&sz[17]);'
      ''
      '      /* adjust values of output register */'
      '      for(in=0;in<block->nevout;++in) {'
      '        block->evout[in]=block->evout[in]-*t;'
      '      }'
      ''
      '      break;'
      '    }'
      ''
      '    /***********************/'
      '    /* function type 10002 */'
      '    /***********************/'
      '  case 10002 :'
      '    { /* This is for compatibility */'
      '      /* jroot is returned in g for old type */'
      '      if(block->nevprt<0) {'
      '        for (j =0;j<block->ng;++j) {'
      '          block->g[j] = (double)block->jroot[j];'
      '        }'
      '      }'
      ''
      '      /* implicit block, inputs and outputs given by a table of pointers */'
      '      /* no zero crossing */'
      '      if(block->ztyp==0) {'
      '        loci2 = (ScicosFi2) loc;'
      '        (*loci2)(flag,&block->nevprt,t,block->res,'
      '                 block->xd,block->x,&block->nx,'
      '                 block->z,&block->nz,'
      '                 block->evout,&block->nevout,block->rpar,&block->nrpar,'
      '                 block->ipar,&block->nipar,(double **)block->inptr,'
      '                 block->insz,&block->nin,'
      '                 (double **)block->outptr,block->outsz,&block->nout);'
      '      }'
      '      /* with zero crossing */'
      '      else {'
      '        loci2z = (ScicosFi2z) loc;'
      '        (*loci2z)(flag,&block->nevprt,t,block->res,'
      '                  block->xd,block->x,&block->nx,'
      '                  block->z,&block->nz,'
      '                  block->evout,&block->nevout,block->rpar,&block->nrpar,'
      '                  block->ipar,&block->nipar,'
      '                  (double **)block->inptr,block->insz,&block->nin,'
      '                  (double **)block->outptr,block->outsz,&block->nout,'
      '                  block->g,&block->ng);'
      '      }'
      ''
      '      /* adjust values of output register */'
      '      for(in=0;in<block->nevout;++in) {'
      '        block->evout[in]=block->evout[in]-*t;'
      '      }'
      ''
      '      break;'
      '    }'
      ''
      '    /***********************/'
      '    /* function type 10004 */'
      '    /***********************/'
      '  case 10004 :'
      '    { /* get pointer of the function type 4*/'
      '      loc4 = (ScicosF4) loc;'
      ''
      '      (*loc4)(block,*flag);'
      ''
      '      break;'
      '    }'
      ''
      '    /***********/'
      '    /* default */'
      '    /***********/'
      '  default :'
      '    {'
      '      fprintf(stderr,'"Undefined Function type\r\n'");'
      '      *flag=-1000;'
      '      return; /* exit */'
      '    }'
      '  }'
      ''
      '  /* Implicit Solver & explicit block & flag==0 */'
      '  /* adjust continuous state vector after call */'
      '  if(solver==100 && block->type<10000 && *flag==0) {'
      '    block->xd  = ptr_d;'
      '    if(flagi!=7) {'
      '      for (k=0;k<block->nx;k++) {'
      '        block->res[k]=block->res[k]-block->xd[k];'
      '      }'
      '    }'
      '    else {'
      '      for (k=0;k<block->nx;k++) {'
      '        block->xd[k]=block->res[k];'
      '      }'
      '    }'
      '  }'
      ''
      '  /* debug block */'
      ''
      '}']
endfunction

function [Code]=make_computational42()
//Copyright (c) 1989-2010 Metalau project INRIA

//@@ make_computational42 : Generates the scicos computational function
//                          associated with the block
//
// Output : Code : text of the generated file
//

  z=cpr.state.z;
  oz=cpr.state.oz;
  outtb=cpr.state.outtb;
  tevts=cpr.state.tevts;
  evtspt=cpr.state.evtspt;
  outptr=cpr.sim.outptr;
  funtyp=cpr.sim.funtyp;
  clkptr=cpr.sim.clkptr;
  ordptr=cpr.sim.ordptr;
  pointi=cpr.state.pointi;
  ztyp=cpr.sim.ztyp;
  zcptr=cpr.sim.zcptr;
  zptr=cpr.sim.zptr;
  ozptr=cpr.sim.ozptr;
  opptr=cpr.sim.opptr;
  opar=cpr.sim.opar;
  rpptr=cpr.sim.rpptr;
  ipptr=cpr.sim.ipptr;
  inpptr=cpr.sim.inpptr;
  funs=cpr.sim.funs;
  xptr=cpr.sim.xptr;
  modptr=cpr.sim.modptr;
  inplnk=cpr.sim.inplnk;
  nblk=cpr.sim.nb;
  outlnk=cpr.sim.outlnk;
  oord=cpr.sim.oord;
  zord=cpr.sim.zord;
  iord=cpr.sim.iord;
  noord=size(cpr.sim.oord,1);
  nzord=size(cpr.sim.zord,1);
  niord=size(cpr.sim.iord,1);

  Indent='  ';
  Indent2=Indent+Indent;
  BigIndent='          ';

  nZ=size(z,'*'); //** index of work in z
  nO=lstsize(oz); //** index of outtb in oz

  stalone=%f

  Code=['/* Scicos Computational function  */'
        '/*     Generated by Code_Generation toolbox of Scicos with '+ ..
        get_scicos_version()+' */';
        '/*     date : '+date()+' */'
        ''
        '/* Copyright (c) 1989-2010 Metalau project INRIA */'
        ''
        '/* ---- Headers ---- */'
        '#include <stdio.h>'
        '#include <stdlib.h>'
        '#include <memory.h>'
        '#include <string.h>'
        '#include <machine.h>'
        '#include <os_specific/link.h>'
        '#include <scicos/scicos.h>'
        '']

  if MSDOS then
   Code=[Code;
         ' '
         '#define max(a,b) ((a) >= (b) ? (a) : (b))'
         '#define min(a,b) ((a) <= (b) ? (a) : (b))'
         ' '
        ]
  end

  Code=[Code;
        Protos]

  //** find activation number
  blks=find(funtyp>-1);
  evs=[];

  if ~ALL then
    for blk=blks
      for ev=clkptr(blk):clkptr(blk+1)-1
        if funs(blk)=='bidon' then
          if ev > clkptr(howclk) -1
          evs=[evs,ev]
         end
        end
      end
    end
  else
    for blk=blks
      for ev=clkptr(blk):clkptr(blk+1)-1
        if funs(blk)=='agenda_blk' then
          nb_agenda_blk=blk
          evs=[evs,ev]
        end
      end
    end
  end

  if ALL & size(evs,'*')<>0 then
    Code=[Code;
          ''
          '/* define agenda struct */'
          'typedef struct {'
          '  int pointi;'
          '  int fromflag3;'
          '  int old_pointi;'
          '  int evtspt['+string(size(evs,'*'))+'];'
          '  double tevts['+string(size(evs,'*'))+'];'
          '} agenda_struct ;'
          ''
          '/* prototype of addevs function */'
          'void '+rdnom+'_addevs(agenda_struct *, double, int);'
         ]
  end

  Code=[Code;
        ''
        '/*'+part('-',ones(1,40))+' Block Computational function */ ';
        'void '+rdnom+'(scicos_block *block, int flag)'
        '{']

  //@@ TOBE IMPROVED
  Code=[Code;
        ''
        '  /* Some general static variables */'
        '  static double zero=0;'
        '  static double w[1];'
        ''
        '  /* declaration of local variables for that block struct */'
        '  double* z      = block->z;'
        '  void **ozptr   = block->ozptr;']

  if max(opptr)>1 then
    Code=[Code;
          '  void **oparptr = block->oparptr;'
          '  /*int nopar      = block->nopar;*/']
  end

  //## Add res if blk contains continuous state register
  if max(xptr)>1 then
    Code=[Code;
          '  double* x      = block->x;'
          '  double* xd     = block->xd;']
  end

  //## Add res if blk is implicit
  if impl_blk then
    Code=[Code;
          '  double* res    = block->res;'
          '  int *xprop     = block->xprop;']
  end

  if size(capt,'*')>0 then
    Code=[Code;
          '  void** u       = block->inptr;']
  end

  Code=[Code;
        '  void** y       = block->outptr;']

  //## look at for use of ipar,rpar (to disable warning)
  with_rpar=%f;
  with_ipar=%f;
  with_nrd2=%f;

  for kf=1:nblk
    //## all blocks without sensor/actuator
    if (part(funs(kf),1:7) ~= 'capteur' &...
        part(funs(kf),1:10) ~= 'actionneur' &...
        funs(kf) ~= 'bidon' &...
        funs(kf) ~= 'bidon2') then
      //** rpar **//
      if (rpptr(kf+1)-rpptr(kf)>0) then
        with_rpar=%t;
      end
      //** ipar **//
      if (ipptr(kf+1)-ipptr(kf))>0 then
        with_ipar=%t;
      end
      //## with_nrd2 ##//
      if funtyp(kf)==0 then
        with_nrd2=%t;
      end
    end
  end

  Code=[Code;
        '  int nevprt     = block->nevprt;']

  if with_rpar then
    Code=[Code;
          '  double* rpar   = block->rpar;'
          '  /*int nrpar      = block->nrpar;*/']
  end

  if with_ipar then
    Code=[Code;
          '  int* ipar      = block->ipar;'
          '  /*int nipar      = block->nipar;*/']
  end

  if ALL & size(evs,'*')<>0 then
    Code=[Code;
          '  double *evout  = block->evout;']
  end

  if max(zcptr)>1 then
    Code=[Code;
          '  double* g      = block->g;'
          '  int* jroot     = block->jroot;']
  end
  if max(modptr)>1 then
    Code=[Code;
          '  int* mode      = block->mode;']
  end
  Code=[Code;
        '  void **work    = block->work;'
        '']

  if ALL & size(evs,'*')<>0 then
    Code=[Code;
          '  /* agenda struct ptr */'
          '  agenda_struct *ptr;'
          '']
  end

//  if (with_nrd&with_nrd2) | with_type1 then
    Code=[Code;
          '  /* time is given in argument of function block */'
          '  double t     = get_scicos_time();']
//  end

  if (max(zcptr)>1 | max(modptr)>1) & with_synchro then
    Code=[Code;
          '  int    phase = get_phase_simulation();']
  end

  Code=[Code;
        '']

  if with_nrd then
    if with_nrd2 then
      Code=[Code;
            '  /* Variables for constant values */'
            '  int nrd_1, nrd_2;'
            ''
            '  double *args[100];'
            '']
    end
  end

  Code=[Code;
        '  int kf;']

  if with_synchro | impl_blk | (zcptr($)-1)~=0 then
    Code=[Code;
          '  int i;']
  end

  if ALL & size(evs,'*')<>0 then
    Code=[Code;
          '  int kever;']
  end

  Code=[Code;
        '  int* reentryflag;'
        ''
        '  int local_flag;'
        //'  int nport;'
        '  void **'+rdnom+'_block_outtbptr;'
        '  scicos_block *block_'+rdnom+';'
        ''
        '  /*  work of blocks are catenated at the end of z */'
        '  work = (void **)(z+'+string(nZ)+');'
        ''
        '  /*  '+rdnom+'_block_outtbptr is catenated at the end of oz */'
        '  '+rdnom+'_block_outtbptr = (void **)(ozptr+'+string(nO)+');'
        ''
        '  /* struct of all blocks are stored in work of that block struct */'
        '  block_'+rdnom+'=(scicos_block*) *block->work;'
        ''];

  Code=[Code;
        '  /* Copy inputs in the block outtb */'];

  for i=1:size(capt,1)
    ni=capt(i,3)*capt(i,4); //** dimension of ith input
    if capt(i,5)<>11 then
      Code=[Code;
            '  memcpy(*('+rdnom+'_block_outtbptr+'+string(capt(i,2)-1)+'),'+...
            '*(u+'+string(capt(i,6)-1)+'),'+...
             string(ni)+'*sizeof('+mat2c_typ(capt(i,5))+'));']
    else //** Cas cmplx
      Code=[Code;
            '  memcpy(*('+rdnom+'_block_outtbptr+'+string(capt(i,2)-1)+'),'+...
            '*(u+'+string(capt(i,6)-1)+'),'+...
             string(2*ni)+'*sizeof('+mat2c_typ(capt(i,5))+'));']
    end
  end

  Code=[Code;
        ''
        '  if (flag != 4 && flag != 6 && flag != 5) {']

  //## adjust ptr array of continuous state before call
  txt = []
  block_has_output=%f
  for kf=1:nblk
     nx=xptr(kf+1)-xptr(kf);
     if nx <> 0 then
       txt=[txt;
            '    block_'+rdnom+'['+string(kf-1)+'].xd    = &(xd['+...
             string(xptr(kf)-1)+']);'
            '    block_'+rdnom+'['+string(kf-1)+'].x     = &(x['+...
             string(xptr(kf)-1)+']);']
       if funtyp(kf)>10000 then
        txt=[txt;
             '    block_'+rdnom+'['+string(kf-1)+'].res   = &(res['+...
              string(xptr(kf)-1)+']);'
             '    block_'+rdnom+'['+string(kf-1)+'].xprop = &(xprop['+...
              string(xptr(kf)-1)+']);']
       end
       if part(funs(kf),1:10) == 'actionneur' then
         block_has_output=%t
       end
     end
  end

  if txt <> [] then
    Code=[Code;
          ''
          '    /* Adjust ptr array of continuous state */'
          txt];
  end

  //## adjust ptr array of zero crossing before call
  txt = []
  for kf=1:nblk
     ng=zcptr(kf+1)-zcptr(kf);
     if ng <> 0 then
       txt=[txt;
            '    block_'+rdnom+'['+string(kf-1)+'].g    = &(g['+...
             string(zcptr(kf)-1)+']);'
            '    block_'+rdnom+'['+string(kf-1)+'].jroot = &(jroot['+...
             string(zcptr(kf)-1)+']);']
     end
  end

  if txt <> [] then
    Code=[Code;
          ''
          '    /* Adjust ptr array of zero crossing */'
          txt];
  end

  for kf=1:nblk
    nin   = inpptr(kf+1)-inpptr(kf); //** number of input ports
    nout  = outptr(kf+1)-outptr(kf); //** number of output ports
    nx    = xptr(kf+1)-xptr(kf);     //@@ number of continuous state
    nz    = zptr(kf+1)-zptr(kf);     //@@ number of continuous state
    nmode = modptr(kf+1)-modptr(kf); //@@ number of mode

    //** add comment
    txt=[get_comment('set_blk',list(funs(kf),funtyp(kf),kf));]

    Code=[Code;
          ''
          '    '+txt];

    //@@ regular input
    for k=1:nin
      lprt=inplnk(inpptr(kf)-1+k);
      Code=[Code;
            '    block_'+rdnom+'['+string(kf-1)+'].inptr['+string(k-1)+']  = '+...
            rdnom+'_block_outtbptr['+string(lprt-1)+'];']
    end

    //@@ regular output
    for k=1:nout
       lprt=outlnk(outptr(kf)-1+k);
       Code=[Code
             '    block_'+rdnom+'['+string(kf-1)+'].outptr['+string(k-1)+'] = '+...
             rdnom+'_block_outtbptr['+string(lprt-1)+'];']
    end

    //@@ discrete state
    if nz>0 then
      Code=[Code
            '    block_'+rdnom+'['+string(kf-1)+'].z         = &(z['+...
            string(zptr(kf)-1)+']);']
    end

    //@@ mode
    if nmode <> 0 then
      Code=[Code;
            '    block_'+rdnom+'['+string(kf-1)+'].mode      = &(mode['+...
            string(modptr(kf)-1)+']);']
    end

    if (part(funs(kf),1:7) ~= 'capteur' &...
        part(funs(kf),1:10) ~= 'actionneur' &...
        funs(kf) ~= 'bidon' &...
        funs(kf) ~= 'bidon2') then
      //** rpar **//
      if (rpptr(kf+1)-rpptr(kf)>0) then
        Code=[Code;
              '    block_'+rdnom+'['+string(kf-1)+'].rpar      = &(rpar['+...
              string(rpptr(kf)-1)+']);']
      end

      //** ipar **//
      if (ipptr(kf+1)-ipptr(kf))>0 then
         Code=[Code;
               '    block_'+rdnom+'['+string(kf-1)+'].ipar      = &(ipar['+...
               string(ipptr(kf)-1)+']);']
      end
      //** opar **//
      if (opptr(kf+1)-opptr(kf)>0) then
        nopar = opptr(kf+1)-opptr(kf);
        for k=1:nopar
          Code=[Code;
                '    block_'+rdnom+'['+string(kf-1)+'].oparptr['+string(k-1)+...
                '] = oparptr['+string(opptr(kf)-1+k-1)+'];'];
        end
      end
      //** oz **//
      if (ozptr(kf+1)-ozptr(kf)>0) then
        noz = ozptr(kf+1)-ozptr(kf);
        for k=1:noz
          Code=[Code;
                '    block_'+rdnom+'['+string(kf-1)+'].ozptr['+string(k-1)+...
                ']  = ozptr['+string(ozptr(kf)-1+k-1)+'];'];
        end
      end
    end

    //@@ work
    if with_work(kf)==1 then
      Code=[Code;
            '    block_'+rdnom+'['+string(kf-1)+'].work      ='+...
            ' (void **)(((double *)work)+'+string(kf-1)+');']
    end
  end

  //@@ reentry flag
  Code=[Code;
        ''
        '    /*  Adjust ptr array that must be done only one times */'
        '    reentryflag=(int*) ((scicos_block *)(*block->work)+'+string(nblk)+');'
        '    if (*reentryflag==0) {'
        '      *reentryflag=1;']

  //** cst blocks and it's dep
  txt=write_code_idoit()

  if txt<>[] then
    Code=[Code;
          ''
          '      /* initial blocks must be called with flag 1 */'
          '    '+txt]
  end

  Code=[Code
        '    }'
        '  }'
        ''
       ]
  /////////////////////////////////////////////

  //## get number of zero crossing
  ng=zcptr($)-1;

  //** flag 0
  flag = 0;

  txt22 = [];

  txt22=[txt22;
         '  '+write_code_odoit(1) //** first pass
         '  '+write_code_odoit(0) //** second pass
        ]

  if txt22<>[] then
    Code=[Code;
          '  if (flag == 0) { '+get_comment('flag',list(flag))
          txt22
          '  }'];
  end

  //@@
  with_flag2=%f;
  with_flag3=%f;

  //** flag 1,2,3
  for flag=[1,2,3]

    txt3=[]

    //** continuous time blocks must be activated
    //** for flag 1
    if flag==1 then
      txt = write_code_cdoit(flag);

      if txt <> [] then
        if ~ALL then
          txt3=[txt3;
                Indent+'  switch (nevprt) {'
               ];
          txt3=[txt3;
                Indent2+'  case '+string(0)+' : '+...
                  get_comment('ev',list(0))
                '    '+txt;
               ];
          txt3=[txt3;'      break;';'']
        else
          txt3=[txt3;
                Indent+'  if (nevprt==0) {'+...
                  get_comment('ev',list(0))
                '    '+txt;
                Indent+'  }'
               ];
        end
      end

    else
      txt=[];
    end

    //!!
    txt44=[];
    if (flag==2) then
      txt44=write_code_odoit(2);
    end

    //** blocks with input discrete event must be activated
    //** for flag 1, 2 and 3
    if size(evs,'*')>=1 then
      txt4=[]
      txt222=[];

      //**
      for ev=evs

        if ~ALL then
          new_ev=ev-(clkptr(howclk)-1)
        else
          new_ev=ev-min(evs)+1
        end
        is_crit=cpr.sim.critev(ev)

        txt2=write_code_doit(ev,flag);

        //!!
        if (flag==2) then
          stupid=%t;
          txt222=[txt222;
                  write_code_doit(ev,flag,stupid)]
        end

        if ALL then
          if flag==2 then
            if txt2<>[] | with_flag2 then
              with_flag2=%t
              if ~with_flag3 then
                tt = write_code_doit(ev,3)
                if tt<>[] then
                  with_flag3=%t
                end
              end
            end
          end
        end

        if txt2<>[] then
          //** adjust event number because of bidon block
          //**
          txt4=[txt4;
                Indent2+['  case '+string(new_ev)+' : '+...
                get_comment('ev',list(new_ev))
                   txt2];]
          if is_crit then
            txt4=[txt4;
                  '        /* critical event */'
                  '        do_cold_restart();'
                  '']
          end
          txt4=[txt4;
                '      break;'
                '']
        end
      end

      //**
      if txt == [] then
        if txt4 <> [] then
          if ~ALL then
            txt3=[txt3;
                  Indent+'  switch (nevprt) {'];

            if txt222<>[] then
              txt3=[txt3;
                    Indent+'    case 0 : /* Hidden states case for block in ordptr */'
                    Indent+'  '+txt222
                    Indent+'    break;';''];
            end

            txt3=[txt3;
                  txt4
                  '    }'];
          else
            txt3=[txt3;
                  Indent+'  ptr = *(block_'+rdnom+'['+string(nb_agenda_blk-1)+'].work);']
            if flag==2 & with_flag2 & with_flag3 then
              txt3=[txt3;
                    Indent+'  if (ptr->fromflag3) {'
                    Indent+'    kever = ptr->old_pointi;'
                    Indent+'    ptr->fromflag3 = 0;'
                    Indent+'  }'
                    Indent+'  else {'
                    Indent+'    kever = ptr->pointi;'
                    Indent+'  }']
            else
              txt3=[txt3;
                    Indent+'  kever = ptr->pointi;']
            end
            if flag==3 then
              txt3=[txt3;
                    Indent+'  ptr->pointi = ptr->evtspt[kever-1];'
                    Indent+'  ptr->evtspt[kever-1] = -1;']
              if with_flag2 & with_flag3 then
                txt3=[txt3;
                      Indent+'  ptr->old_pointi = kever;'
                      Indent+'  ptr->fromflag3  = 1;']
              end
            end
           
            if txt222<>[] then
              txt3=[Indent+'  if (nevprt==0) { /* Hidden states case for block in ordptr */'
                    Indent+txt222
                    Indent+'  }';
                    ''
                    txt3];
            end

            txt3=[txt3;
                  Indent+'  switch (kever) {'
                  txt4
                  '    }'];
            if flag==3 then
              txt3=[txt3;
                    Indent+'  block->evout[0] = ptr->tevts[ptr->pointi-1] - t;']
            end
          end
        end
      else
        if ~ALL then
          txt3=[txt3;
                txt4]
        else
          txt3=[txt3;
                '    else {'
                '      ptr = *(block_'+rdnom+'['+string(nb_agenda_blk-1)+'].work);'
                '      kever = ptr->pointi;']
          if flag==3 then
            txt3=[txt3;
                  '      ptr->pointi = ptr->evtspt[kever-1];'
                  '      ptr->evtspt[kever-1] = -1;']
          end
          txt3=[txt3;
                Indent+'    switch (kever) {'
                txt4
                '      }'
                '    }'];
          if flag==3 then
            txt3=[txt3;
                  Indent+'  block->evout[0] = ptr->tevts[ptr->pointi-1] - t;']
          end
        end
      end
    end

    //**
    if ~ALL then
      if txt <> [] then
        txt3=[txt3;
              '    }'];
      end
    end

    //**
    if txt3<>[] then
      if flag==1 & txt22==[] then
        Code=[Code;
              '  if (flag == '+string(flag)+') { '+...
              get_comment('flag',list(flag))
              txt3
              '  }'];
      else
        //## test for zero crossing
        if (ng ~= 0) & (flag~=1) then
          Code=[Code;
                '  else if ((flag == '+string(flag)+')&&(nevprt>=0)) { '+...
                get_comment('flag',list(flag))]

          if txt44<>[] then
            Code=[Code;
                  '    /* Hidden states case for block in oord */'
                  '    if (nevprt==0) {'
                  '      '+txt44
                  '    }'
                  '']
          end

          Code=[Code;
                txt3]

          if (flag==2) & ~with_flag3 & size(evs,'*')<>0 & ALL then
            Code=[Code;
                  ''
                  '    ptr->pointi = ptr->evtspt[kever-1];'
                  '    ptr->evtspt[kever-1] = -1;']
          end

          Code=[Code;
                '  }'];
        else
          Code=[Code;
                '  else if (flag == '+string(flag)+') { '+...
                get_comment('flag',list(flag))]

          if txt44<>[] then
            Code=[Code;
                  '    /* Hidden states case for block in oord */'
                  '    if (nevprt==0) {'
                  '    '+txt44
                  '    }'
                  '']
          end

          Code=[Code;
                txt3
                '  }'];
        end
      end
    elseif ((flag==2) & txt44<>[]) then
      if txt22==[] then
        Code=[Code;
              '  if ((flag == '+string(flag)+')&&(nevprt==0)) { '+...
              get_comment('flag',list(flag))]
      else
        Code=[Code;
              '  else if ((flag == '+string(flag)+')&&(nevprt==0)) { '+...
              get_comment('flag',list(flag))]
      end
      Code=[Code;
            '    /* Hidden states case for block in oord */'
            '  '+txt44
            '  }'];
    end

    //## zero crossing internal events
    if (ng ~= 0) then
      //##
      if (flag<>1) then
        txt22 = [];

        for k=1:nzord
          bk=zord(k,1);
          if (zcptr(bk+1)-zcptr(bk)) <> 0 then
            //@@ Ooups
            pt=abs(zord(k,2));
            pt=1;
            txt_tmp=call_block42(bk,-pt,flag)
            if txt_tmp<> [] then
              txt_tmp='    '+txt_tmp;

              txt22=[txt22;
                     txt_tmp];

            end
          end
        end

        //@@ get ptr of agenda blk
        txt222=[];
        if ALL & flag==3 & size(evs,'*')<>0 then
          txt222=['    ptr = *(block_'+rdnom+'['+string(nb_agenda_blk-1)+'].work);';
                  '']
        end

        if txt22<>[] then
          Code=[Code;
                '  else if ((flag == '+string(flag)+')&&(nevprt<0)) { '+...
                 '/* zero crossing internal events */'
                txt222
                txt22]
          if ALL & flag==3 & size(evs,'*')<>0 then
            Code=[Code;
                  ''
                  Indent+'  block->evout[0] = ptr->tevts[ptr->pointi-1] - t;'
                  '  }']
          else
            Code=[Code;
                  '  }']
          end
        end
      end
    end

  end //## end of for flag=[1,2,3]

  //** flag 7
  if impl_blk then
    txt22 = [];

    txt22=[txt22;
           '  '+write_code_reinitdoit(1) //** first pass
           '  '+write_code_reinitdoit(7) //** second pass
          ]

    if txt22<>[] then
      Code=[Code;
            '  else if (flag == 7) { /* x_pointer properties */'
            txt22
            '  }'];
    end
  end

  //** flag 9
  if (ng ~= 0) then
    flag = 9;

    Code=[Code;
          '  else if (flag == '+string(flag)+') { '+...
          get_comment('flag',list(flag))
          ''
         ];

    Code=[Code;
          '  '+write_code_zdoit()
         ]

    Code=[Code;
          '  }'];
  end

  //@@ flag 10
  if impl_blk then
    //@@ TODO

    txt  = []

//     txt=[txt;
//          '  '+write_code_odoit(1) //** first pass
//          '  '+write_code_odoit(10) //** second pass
//         ]

    if txt <> [] then
      flag = 10
      Code=[Code;
            '  '
            '  else if (flag == '+string(flag)+') { /* Jacobian computation */'
            '    '+txt
            '  }'
            ''
            ];
    end
  end

  //** flag 4
  Code=[Code;
        '  else if (flag == 4) { '+get_comment('flag',list(4))
        '    /* work array allocation */'
        '    if ((*block->work=scicos_malloc(sizeof(scicos_block)*'+...
         string(nblk)+'+sizeof(int)))== NULL) {'
        '      set_block_error(-16);'
        '      return;'
        '    }'
        '    reentryflag=(int*) ((scicos_block *)(*block->work)+'+string(nblk)+');'
        '    *reentryflag=0;'
        '    block_'+rdnom+'=(scicos_block*) *block->work;'];

  for kf=1:nblk
    nin   = inpptr(kf+1)-inpptr(kf); //* number of input ports */
    nout  = outptr(kf+1)-outptr(kf); //* number of output ports */
    nx    = xptr(kf+1)-xptr(kf);
    nz    = zptr(kf+1)-zptr(kf);
    ng    = zcptr(kf+1)-zcptr(kf);
    nmode = modptr(kf+1)-modptr(kf);

    //** add comment
    txt=[get_comment('set_blk',list(funs(kf),funtyp(kf),kf));]

    Code=[Code;
          ''
          '    '+txt];

    Code=[Code;
          '    block_'+rdnom+'['+string(kf-1)+'].type   = '+...
            string(funtyp(kf))+';';
          '    block_'+rdnom+'['+string(kf-1)+'].ztyp   = '+...
            string(ztyp(kf))+';';
          '    block_'+rdnom+'['+string(kf-1)+'].ng     = '+...
            string(zcptr(kf+1)-zcptr(kf))+';']

    //@@ continuous state
    if nx <> 0 then
      Code=[Code;
            '    block_'+rdnom+'['+string(kf-1)+'].nx     = '+...
             string(nx)+';';
            '    block_'+rdnom+'['+string(kf-1)+'].x      = &(x['+...
             string(xptr(kf)-1)+']);'
            '    block_'+rdnom+'['+string(kf-1)+'].xd     = &(xd['+...
               string(xptr(kf)-1)+']);']
      if impl_blk then
        Code=[Code;
              '    block_'+rdnom+'['+string(kf-1)+'].res    = &(res['+...
                    string(xptr(kf)-1)+']);'
              '    block_'+rdnom+'['+string(kf-1)+'].xprop  = &(xprop['+...
                    string(xptr(kf)-1)+']);']
      end
    else
      Code=[Code;
            '    block_'+rdnom+'['+string(kf-1)+'].nx     = 0;';
            '    block_'+rdnom+'['+string(kf-1)+'].x      = &(zero);'
            '    block_'+rdnom+'['+string(kf-1)+'].xd     = w;']
    end

    //@@ zero-crossing
    if ng <> 0 then
      Code=[Code;
            '    block_'+rdnom+'['+string(kf-1)+'].g      = &(g['+...
            string(zcptr(kf)-1)+']);']
    else
      Code=[Code;
            '    block_'+rdnom+'['+string(kf-1)+'].g      = &(zero);';]
    end

    //@@ mode
    if nmode <> 0 then
      Code=[Code;
            '    block_'+rdnom+'['+string(kf-1)+'].mode   = &(mode['+...
            string(modptr(kf)-1)+']);']
    end

    Code=[Code;
          '    block_'+rdnom+'['+string(kf-1)+'].nz     = '+...
            string(zptr(kf+1)-zptr(kf))+';';
          '    block_'+rdnom+'['+string(kf-1)+'].noz    = '+...
            string(ozptr(kf+1)-ozptr(kf))+';';
          '    block_'+rdnom+'['+string(kf-1)+'].nrpar  = '+...
            string(rpptr(kf+1)-rpptr(kf))+';';
          '    block_'+rdnom+'['+string(kf-1)+'].nopar  = '+...
            string(opptr(kf+1)-opptr(kf))+';';
          '    block_'+rdnom+'['+string(kf-1)+'].nipar  = '+...
            string(ipptr(kf+1)-ipptr(kf))+';'
          '    block_'+rdnom+'['+string(kf-1)+'].nin    = '+...
            string(inpptr(kf+1)-inpptr(kf))+';';
          '    block_'+rdnom+'['+string(kf-1)+'].nout   = '+...
            string(outptr(kf+1)-outptr(kf))+';';
          '    block_'+rdnom+'['+string(kf-1)+'].nevout = '+...
            string(clkptr(kf+1)-clkptr(kf))+';';
          '    block_'+rdnom+'['+string(kf-1)+'].nmode  = '+...
            string(modptr(kf+1)-modptr(kf))+';'];

    Code=[Code;
          '    if ((block_'+rdnom+'['+string(kf-1)+'].evout  = '+...
          'calloc(block_'+rdnom+'['+string(kf-1)+'].nevout,sizeof(double)))== NULL) {'
          '      set_block_error(-16);'
          '      return;'
          '    }'];

    //***************************** input port *****************************//
    if nin>0 then
      //** alloc insz/inptr **//
      Code=[Code;
            '    if ((block_'+rdnom+'['+string(kf-1)+'].insz   = '+...
            'malloc(3*sizeof(int)*block_'+rdnom+'['+string(kf-1)+'].nin))== NULL) {'
            '      set_block_error(-16);'
            '      return;'
            '    }'
            '    if ((block_'+rdnom+'['+string(kf-1)+'].inptr  = '+...
            'malloc(sizeof(void *)*block_'+rdnom+'['+string(kf-1)+'].nin))== NULL) {'
            '      set_block_error(-16);'
            '      return;'
            '    }'];

      //** inptr **//
      for k=1:nin
         lprt=inplnk(inpptr(kf)-1+k);
         Code=[Code
               '    block_'+rdnom+'['+string(kf-1)+'].inptr['+string(k-1)+']  = '+...
               rdnom+'_block_outtbptr['+string(lprt-1)+'];']
      end

      //** 1st dim **//
      for k=1:nin
         lprt=inplnk(inpptr(kf)-1+k);
         Code=[Code
               '    block_'+rdnom+'['+string(kf-1)+'].insz['+string((k-1))+']   = '+...
                string(size(outtb(lprt),1))+';']
      end

      //** 2dn dim **//
      for k=1:nin
         lprt=inplnk(inpptr(kf)-1+k);
         Code=[Code
               '    block_'+rdnom+'['+string(kf-1)+'].insz['+string((k-1)+nin)+']   = '+...
                string(size(outtb(lprt),2))+';']
      end

      //** typ **//
      for k=1:nin
         lprt=inplnk(inpptr(kf)-1+k);
         Code=[Code
               '    block_'+rdnom+'['+string(kf-1)+'].insz['+string((k-1)+2*nin)+']   = '+...
                mat2scs_c_typ(outtb(lprt))+';'];
      end
    end
    //**********************************************************************//

    //***************************** output port *****************************//
    if nout>0 then
      //** alloc outsz/outptr **//
      Code=[Code
            '    if ((block_'+rdnom+'['+string(kf-1)+'].outsz  = '+...
             'malloc(3*sizeof(int)*block_'+rdnom+'['+string(kf-1)+'].nout))== NULL) {'
            '      set_block_error(-16);'
            '      return;'
            '    }';
            '    if ((block_'+rdnom+'['+string(kf-1)+'].outptr = '+...
             'malloc(sizeof(void*)*block_'+rdnom+'['+string(kf-1)+'].nout))== NULL) {'
            '      set_block_error(-16);'
            '      return;'
            '    }'];

      //** outptr **//
      for k=1:nout
         lprt=outlnk(outptr(kf)-1+k);
         Code=[Code
               '    block_'+rdnom+'['+string(kf-1)+'].outptr['+string(k-1)+'] = '+...
                rdnom+'_block_outtbptr['+string(lprt-1)+'];']
      end

      //** 1st dim **//
      for k=1:nout
         lprt=outlnk(outptr(kf)-1+k);
         Code=[Code
               '    block_'+rdnom+'['+string(kf-1)+'].outsz['+string((k-1))+...
               ']  = '+string(size(outtb(lprt),1))+';']
      end

      //** 2dn dim **//
      for k=1:nout
         lprt=outlnk(outptr(kf)-1+k);
         Code=[Code
               '    block_'+rdnom+'['+string(kf-1)+'].outsz['+string((k-1)+nout)+...
               ']  = '+string(size(outtb(lprt),2))+';']
      end

      //** typ **//
      for k=1:nout
         lprt=outlnk(outptr(kf)-1+k);
         Code=[Code
               '    block_'+rdnom+'['+string(kf-1)+'].outsz['+string((k-1)+2*nout)+...
               ']  = '+mat2scs_c_typ(outtb(lprt))+';'];
      end
    end
    //**********************************************************************//

    //@@ discrete state
    if nz>0 then
      Code=[Code
            '    block_'+rdnom+'['+string(kf-1)+'].z         = &(z['+...
            string(zptr(kf)-1)+']);']
    end

    //***************************** object state *****************************//
    if (ozptr(kf+1)-ozptr(kf)>0) then
      noz = ozptr(kf+1)-ozptr(kf);
      Code=[Code
            '    if ((block_'+rdnom+'['+string(kf-1)+'].ozptr = '+...
            'malloc(sizeof(void *)*block_'+rdnom+'['+string(kf-1)+'].noz))== NULL) {'
            '      set_block_error(-16);'
            '      return;'
            '    }';
            '    if ((block_'+rdnom+'['+string(kf-1)+'].ozsz  = '+...
            'malloc(2*sizeof(int)*block_'+rdnom+'['+string(kf-1)+'].noz))== NULL) {'
            '      set_block_error(-16);'
            '      return;'
            '    }';
            '    if ((block_'+rdnom+'['+string(kf-1)+'].oztyp = '+...
            'malloc(sizeof(int)*block_'+rdnom+'['+string(kf-1)+'].noz))== NULL) {'
            '      set_block_error(-16);'
            '      return;'
            '    }']

      //** ozptr **//
      for k=1:noz
        Code=[Code;
              '    block_'+rdnom+'['+string(kf-1)+'].ozptr['+string(k-1)+...
              ']  = ozptr['+string(ozptr(kf)-1+k-1)+'];'];
      end

      //** 1st dim **//
      for k=1:noz
        Code=[Code;
              '    block_'+rdnom+'['+string(kf-1)+'].ozsz['+string(k-1)+...
              ']   = '+string(size(oz(ozptr(kf)-1+k),1))+';'];
      end

      //** 2nd dim **//
      for k=1:noz
        Code=[Code;
              '    block_'+rdnom+'['+string(kf-1)+'].ozsz['+string(noz+(k-1))+...
              ']   = '+string(size(oz(ozptr(kf)-1+k),2))+';'];
      end

      //** typ **//
      for k=1:noz
        Code=[Code;
              '    block_'+rdnom+'['+string(kf-1)+'].oztyp['+string(k-1)+...
              ']  = '+mat2scs_c_typ(oz(ozptr(kf)-1+k))+';'];
      end
    end
    //************************************************************************//

    if (part(funs(kf),1:7) ~= 'capteur' &...
        part(funs(kf),1:10) ~= 'actionneur' &...
        funs(kf) ~= 'bidon' &...
        funs(kf) ~= 'bidon2') then
      if (rpptr(kf+1)-rpptr(kf)>0) then
        Code=[Code;
              '    block_'+rdnom+'['+string(kf-1)+...
              '].rpar      = &(rpar['+string(rpptr(kf)-1)+']);']
      end
      if (ipptr(kf+1)-ipptr(kf)>0) then
        Code=[Code;
              '    block_'+rdnom+'['+string(kf-1)+...
              '].ipar      = &(ipar['+string(ipptr(kf)-1)+']);'] 
      end
      //** opar
      if (opptr(kf+1)-opptr(kf)>0) then
        Code=[Code;
              '    if ((block_'+rdnom+'['+string(kf-1)+'].oparptr = '+...
               'malloc(sizeof(void *)*block_'+rdnom+'['+string(kf-1)+'].nopar))== NULL) {'
              '      set_block_error(-16);'
              '      return;'
              '    }';
              '    if ((block_'+rdnom+'['+string(kf-1)+'].oparsz  = '+...
               'malloc(2*sizeof(int)*block_'+rdnom+'['+string(kf-1)+'].nopar))== NULL) {'
              '      set_block_error(-16);'
              '      return;'
              '    }';
              '    if ((block_'+rdnom+'['+string(kf-1)+'].opartyp = '+...
               'malloc(sizeof(int)*block_'+rdnom+'['+string(kf-1)+'].nopar))== NULL) {'
              '      set_block_error(-16);'
              '      return;'
              '    }';
              ]
        nopar = opptr(kf+1)-opptr(kf);
        //** oparptr **//
        for k=1:nopar
          Code=[Code;
                '    block_'+rdnom+'['+string(kf-1)+'].oparptr['+string(k-1)+...
                 ']  = oparptr['+string(opptr(kf)-1+k-1)+'];'];
        end
        //** 1st dim **//
        for k=1:nopar
          Code=[Code;
                '    block_'+rdnom+'['+string(kf-1)+'].oparsz['+string(k-1)+...
                 ']   = '+string(size(opar(opptr(kf)-1+k),1))+';'];
        end
        //** 2dn dim **//
        for k=1:nopar
          Code=[Code;
                '    block_'+rdnom+'['+string(kf-1)+'].oparsz['+string(nopar+(k-1))+...
                 ']   = '+string(size(opar(opptr(kf)-1+k),2))+';'];
        end
        //** typ **//
        for k=1:nopar
          Code=[Code;
                '    block_'+rdnom+'['+string(kf-1)+'].opartyp['+string(k-1)+...
                 ']  = '+mat2scs_c_typ(opar(opptr(kf)-1+k))+';'];
        end
      end
    end

    //@@ work
    if with_work(kf)==1 then
      Code=[Code;
            '    block_'+rdnom+'['+string(kf-1)+...
             '].work      = (void **)(((double *)work)+'+string(kf-1)+');']
    end

    //@@ nevptr
    Code=[Code;
          '    block_'+rdnom+'['+string(kf-1)+...
           '].nevprt    = nevprt;']

    //@@ label
    Code=[Code;
          '    block_'+rdnom+'['+string(kf-1)+...
          '].label     = NULL;']

//     if length(cpr.sim.labels(kf))== 0 then
//       Code=[Code;
//             '    block_'+rdnom+'['+string(kf-1)+...
//             '].label     = NULL;']
//     else
//       Code=[Code;
//             '    if ((block_'+rdnom+'['+string(kf-1)+'].label  = '+...
//              'malloc(sizeof(char)*'+string(length(cpr.sim.labels(kf))+1)+'))==NULL) return 0;';]
//       Code=[Code;
//             '    block_'+rdnom+'['+string(kf-1)+'].label     = ""'+cpr.sim.labels(kf)+'"";']
//     end

  end //for kf=1:nblk

  //** init
  for kf=1:nblk
    if funs(kf)=='agenda_blk' then
      if ALL & size(evs,'*')<>0 then
        new_pointi=adjust_pointi(cpr.state.pointi,clkptr,funtyp)
        Code=[Code;
              '';
              '    /* Init of agenda_blk (blk nb '+string(kf)+') */'
              '    *(block_'+rdnom+'['+string(kf-1)+'].work) = '+...
                '(agenda_struct*) scicos_malloc(sizeof(agenda_struct));'
              '    ptr = *(block_'+rdnom+'['+string(kf-1)+'].work);'
              '    ptr->pointi     = '+string(new_pointi)+';'
              '    ptr->fromflag3  = 0;'
              '    ptr->old_pointi = 0;'
             ]
        new_evtspt=adjust_agenda(cpr.state.evtspt,clkptr,funtyp)
        for i=1:size(new_evtspt,1)
          if new_evtspt(i)>0 then
            new_evtspt(i)=adjust_pointi(new_evtspt(i),clkptr,funtyp)
          end
        end
        for i=1:size(evs,'*')
          Code=[Code;
                '    ptr->evtspt['+string(i-1)+']  = '+string(new_evtspt(i))+';'
               ]
        end
        new_tevts=adjust_agenda(cpr.state.tevts,clkptr,funtyp)
        for i=1:size(evs,'*')
          Code=[Code;
                '    ptr->tevts['+string(i-1)+']   = '+string_to_c_string(new_tevts(i))+';'
               ]
        end

      end
    else
      if ~(or(kf==act) | or(kf==cap)) then
        txt = call_block42(kf,0,4);
        if txt <> [] then
          Code=[Code;
                '';
                '    '+txt];
        end
      end
    end
  end

  //@@ check block_error after all calls
  Code=[Code;
        '';
        '    /* error handling */'
        '    if (get_block_error() < 0) {'
        '      return;'
        '    }']

  //** init
  for kf=1:nblk
    if ~(or(kf==act) | or(kf==cap)) then
      txt = call_block42(kf,0,6);
      if txt <> [] then
        Code=[Code;
              '';
              '    '+txt];
      end
    end
  end

  if impl_blk then
    //@@ disable analytical jacobian computation
    //@@ for that time : should be removed
    Code=[Code;
          '';
          '    /* Disable Jacobian computation */'
          '    Set_Jacobian_flag(0);'];
  end

  Code=[Code;
        '  }'];

  //** flag 5
  Code=[Code;
        '  else if (flag == 5) { '+get_comment('flag',list(5))
        '    /* get work ptr of that block */'
        '    block_'+rdnom+'=*block->work;']

  for kf=1:nblk
     nin  = inpptr(kf+1)-inpptr(kf); //* number of input ports */
     nout = outptr(kf+1)-outptr(kf); //* number of output ports */
     nx   = xptr(kf+1)-xptr(kf);     //* number of continuous state */
     nz   = zptr(kf+1)-zptr(kf);     //@@ number of discrete state

     //** add comment
     txt=[get_comment('set_blk',list(funs(kf),funtyp(kf),kf));]

     Code=[Code;
           ''
           '    '+txt];

     //@@ regular input
     for k=1:nin
        lprt=inplnk(inpptr(kf)-1+k);
         Code=[Code;
               '    block_'+rdnom+'['+string(kf-1)+'].inptr['+string(k-1)+...
               ']  = '+rdnom+'_block_outtbptr['+string(lprt-1)+'];']
     end

     //@@ regular output
     for k=1:nout
        lprt=outlnk(outptr(kf)-1+k);
        Code=[Code
              '    block_'+rdnom+'['+string(kf-1)+'].outptr['+string(k-1)+...
              '] = '+rdnom+'_block_outtbptr['+string(lprt-1)+'];']
     end

     //@@ discrete state
     if nz>0 then
       Code=[Code
             '    block_'+rdnom+'['+string(kf-1)+'].z         = &(z['+...
              string(zptr(kf)-1)+']);']
     end

     //@@ continuous state
     if nx <> 0 then
       Code=[Code;
             '    block_'+rdnom+'['+string(kf-1)+'].nx     = '+...
              string(nx)+';';
             '    block_'+rdnom+'['+string(kf-1)+'].x      = &(x['+...
              string(xptr(kf)-1)+']);'
             '    block_'+rdnom+'['+string(kf-1)+'].xd     = &(xd['+...
              string(xptr(kf)-1)+']);']
       if impl_blk then
           Code=[Code;
                 '    block_'+rdnom+'['+string(kf-1)+'].res    = &(res['+...
                       string(xptr(kf)-1)+']);']
       end
     end

     if (part(funs(kf),1:7) ~= 'capteur' &...
          part(funs(kf),1:10) ~= 'actionneur' &...
           funs(kf) ~= 'bidon' &...
            funs(kf) ~= 'bidon2') then
       //** rpar **//
       if (rpptr(kf+1)-rpptr(kf)>0) then
         Code=[Code;
               '    block_'+rdnom+'['+string(kf-1)+...
                '].rpar   = &(rpar['+string(rpptr(kf)-1)+']);'];
       end
       //** ipar **//
       if (ipptr(kf+1)-ipptr(kf)>0) then
         Code=[Code;
               '    block_'+rdnom+'['+string(kf-1)+...
                '].ipar   = &(ipar['+string(ipptr(kf)-1)+']);'];
       end
       //** opar **//
       if (opptr(kf+1)-opptr(kf)>0) then
         nopar = opptr(kf+1)-opptr(kf);
         for k=1:nopar
           Code=[Code;
                 '    block_'+rdnom+'['+string(kf-1)+'].oparptr['+string(k-1)+...
                 ']  = oparptr['+string(opptr(kf)-1+k-1)+'];'];
         end
       end
       //** oz **//
       if (ozptr(kf+1)-ozptr(kf)>0) then
         noz = ozptr(kf+1)-ozptr(kf);
         for k=1:noz
           Code=[Code;
                 '    block_'+rdnom+'['+string(kf-1)+'].ozptr['+string(k-1)+...
                ']  = ozptr['+string(ozptr(kf)-1+k-1)+'];'];
         end
       end
     end

     //@@ work
     if with_work(kf)==1 then
       Code=[Code;
             '    block_'+rdnom+'['+string(kf-1)+...
              '].work   = (void **)(((double *)work)+'+string(kf-1)+');'];
     end
  end

  for kf=1:nblk
    if funs(kf)=='agenda_blk' then
      if ALL & size(evs,'*')<>0 then
        Code=[Code;
              '';
              '    /* Free agenda_blk (blk nb '+string(kf)+') */'
              '    if(*(block_'+rdnom+'['+string(kf-1)+'].work) != NULL) {'
              '      scicos_free(*(block_'+rdnom+'['+string(kf-1)+'].work));'
              '    }'
             ];

      end
    else
      if ~(or(kf==act) | or(kf==cap)) then
        txt = call_block42(kf,0,5);
        if txt <> [] then
          Code=[Code;
                '';
                '    '+txt];
        end
      end
    end
  end
  
  Code=[Code;
        ''
        '    for (kf = 0; kf < '+string(nblk)+'; ++kf){'
        '      if (block_'+rdnom+'[kf].nin!=0){'
        '        if (block_'+rdnom+'[kf].insz!=NULL){'
        '          free(block_'+rdnom+'[kf].insz);'
        '        }'
        '      }'
        '      if (block_'+rdnom+'[kf].nout!=0){'
        '        if (block_'+rdnom+'[kf].outsz!=NULL){'
        '          free(block_'+rdnom+'[kf].outsz);'
        '        }'
        '      }'
        '      if (block_'+rdnom+'[kf].nopar!=0){'
        '        if (block_'+rdnom+'[kf].oparptr!=NULL){'
        '          free(block_'+rdnom+'[kf].oparptr);'
        '        }'
        '        if (block_'+rdnom+'[kf].oparsz!=NULL){'
        '          free(block_'+rdnom+'[kf].oparsz);'
        '        }'
        '        if (block_'+rdnom+'[kf].opartyp!=NULL){'
        '          free(block_'+rdnom+'[kf].opartyp);'
        '        }'
        '      }'
        '      if (block_'+rdnom+'[kf].noz!=0){'
        '        if (block_'+rdnom+'[kf].ozptr!=NULL){'
        '          free(block_'+rdnom+'[kf].ozptr);'
        '        }'
        '        if (block_'+rdnom+'[kf].ozsz!=NULL){'
        '          free(block_'+rdnom+'[kf].ozsz);'
        '        }'
        '        if (block_'+rdnom+'[kf].oztyp!=NULL){'
        '          free(block_'+rdnom+'[kf].oztyp);'
        '        }'
        '      }'
        '      if (block_'+rdnom+'[kf].evout!=NULL){'
        '        free(block_'+rdnom+'[kf].evout);'
        '      }'
        '      if (block_'+rdnom+'[kf].label!=NULL){'
        '        free(block_'+rdnom+'[kf].label);'
        '      }'
        '    }'
        '    scicos_free(block_'+rdnom+');'
        '  }'
        ''];

  for i=1:size(actt,1)
    ni=actt(i,3)*actt(i,4); // dimension of ith input
    if actt(i,5)<>11 then
      Code=[Code;
            '  memcpy(*(y+'+string(actt(i,6)-1)+'),'+...
            '*('+rdnom+'_block_outtbptr+'+string(actt(i,2)-1)+'),'+...
             string(ni)+'*sizeof('+mat2c_typ(actt(i,5))+'));'];
    else //** Cas cmplx
      Code=[Code;
            '  memcpy(*(y+'+string(actt(i,6)-1)+'),'+...
            '*('+rdnom+'_block_outtbptr+'+string(actt(i,2)-1)+'),'+...
             string(2*ni)+'*sizeof('+mat2c_typ(actt(i,5))+'));'];
    end
  end

  //**
  Code=[Code;
        '  return;'
        ''
        '} /* '+rdnom+' */']

  //@@ addevs function
  if ALL & size(evs,'*')<>0 then
    Code=[Code;
          ''
          '/* addevs function */'
          'void '+rdnom+'_addevs(agenda_struct *ptr, double t, int evtnb)'
          '{'
          '  int i,j;'
          '']

    if debug_cdgen then
      Code=[Code;
            '  fprintf(stderr,""addevs (begin)\n \tpointi=%d\n \tevtnb=%d\n \tptr->evtspt[evtnb-1]=%d\n \tt=%f\n"", \'
            '                 ptr->pointi,evtnb,ptr->evtspt[evtnb-1],t);'
            '']
    end

    Code=[Code;
          '  /*  */'
          '  if (ptr->evtspt[evtnb-1] != -1) {'
          '    if ((ptr->evtspt[evtnb-1] == 0) && (ptr->pointi==evtnb)) {'
          '      ptr->tevts[evtnb-1] = t;'
          '      return;'
          '    }'
          '    /* */'
          '    else {'
          '      /* (ptr->pointi == evtnb) && ((ptr->evtspt[evtnb] == 0) || (ptr->evtspt[evtnb] != 0)) */'
          '      if (ptr->pointi == evtnb) {'
          '        ptr->pointi = ptr->evtspt[evtnb-1]; /* remove from chain, pointi is now the event provided by ptr->evtspt[evtnb] */'
          '      }'
          '      /* (ptr->pointi != evtnb) && ((ptr->evtspt[evtnb] == 0) || (ptr->evtspt[evtnb] != 0)) */'
          '      else {'
          '        /* find where is the event to be updated in the agenda */'
          '        i = ptr->pointi;'
          '        while (evtnb != ptr->evtspt[i-1]) {'
          '          i = ptr->evtspt[i-1];'
          '        }'
          '        ptr->evtspt[i-1] = ptr->evtspt[evtnb-1]; /* remove old evtnb from chain */'
          ''
          '        /* if (TCritWarning == 0) {'
          '         *  sciprint(""\n\r Warning:an event is reprogrammed at t=%g by removing another"",t );'
          '         *  sciprint(""\n\r         (already programmed) event. There may be an error in"");'
          '         *  sciprint(""\n\r         your model. Please check your model\n\r"");'
          '         *  TCritWarning=1;'
          '         * }'
          '         */'
          ''
          '        do_cold_restart(); /* the erased event could be a critical event, '
          '                            * so do_cold_restart is added to'
          '                            * refresh the critical event table'
          '                            */'
          '      }'
          ''
          '      /* */'
          '      ptr->evtspt[evtnb-1] = 0;'
          '      ptr->tevts[evtnb-1]  = t;'
          '    }'
          '  }'
          '  else {'
          '    ptr->evtspt[evtnb-1] = 0;'
          '    ptr->tevts[evtnb-1]  = t;'
          '  }'
          ''
          '  /* */'
          '  if (ptr->pointi == 0) {'
          '    ptr->pointi = evtnb;'
          '    return;'
          '  }'
          '  if (t < ptr->tevts[ptr->pointi-1]) {'
          '    ptr->evtspt[evtnb-1] = ptr->pointi;'
          '    ptr->pointi = evtnb;'
          '    return;'
          '  }'
          ''
          '  /* */'
          '  i = ptr->pointi;'
          ''
          ' L100:'
          '  if (ptr->evtspt[i-1] == 0) {'
          '    ptr->evtspt[i-1] = evtnb;'
          '    return;'
          '  }'
          '  if (t >= ptr->tevts[ptr->evtspt[i-1]-1]) {'
          '    j = ptr->evtspt[i-1];'
          '    if (ptr->evtspt[j-1] == 0) {'
          '      ptr->evtspt[j-1] = evtnb;'
          '      return;'
          '    }'
          '    i = j;'
          '    goto L100;'
          '  }'
          '  else {'
          '    ptr->evtspt[evtnb-1] = ptr->evtspt[i-1];'
          '    ptr->evtspt[i-1] = evtnb;'
          '  }'
          '']

    if debug_cdgen then
      Code=[Code;
            '  fprintf(stderr,""addevs (end), pointi=%d\n"",ptr->pointi);'
            '']
    end

    Code=[Code;
          '  return;'
          '}'
         ]
  end

endfunction

function [Code]=make_jac()
//Copyright (c) 1989-2010 Metalau project INRIA

//@@ make_jac : Generates the Scicos simulator Jacobians
//              C function to use witn a DAE solver
//
// Output : Code : text of the generated file
//

  Code=['/*'+part('-',ones(1,40))+' '+rdnom+'_Jacobians function */'
        'int '+rdnom+'_Jacobians(long int Neq, realtype tt, N_Vector yy, N_Vector yp,'
        '              N_Vector resvec, realtype cj, void *jdata, DenseMat Jacque,'
        '              N_Vector tempv1, N_Vector tempv2, N_Vector tempv3)'
        '{'
        '  /* local variables used to call block */'
        '  int local_flag;']

  if act<>[] | cap<>[] then
    Code=[Code;
         '  int nport;'
         '']
  end

  if with_nrd then
    //## look at for block of type 0 (no captor)
    ind=find(funtyp==0)
    if ind<>[] then
      with_nrd2=%t
    else
      with_nrd2=%f
    end

    if with_nrd2 then
      Code=[Code;
            '  /* Variables for constant values */'
            '  int nrd_1, nrd_2;'
            '  double *args[100];'
            '']
    end
  end

  Code=[Code;
        '  double  t;'
        '  double *x, *xd, *res, *res_save;'
        ''
        '  int ii,i,j,n, nx,ni,no,m,flag;'
        ''
        '  double **y = NULL;'
        '  double **u = NULL;'
        '  double *RX, *Fx, *Fu, *Gx, *Gu, *ERR1,*ERR2;'
        '  double *Hx, *Hu,*Kx,*Ku,*HuGx,*FuKx,*FuKuGx,*HuGuKx;'
        '  double *ewt_data;'
        '  double ysave;'
        '  double inc, inc_inv, xi, xpi, srur;'
        '  realtype *Jacque_col;'
        '  realtype hh;'
        '  N_Vector ewt;'
        '  User_IDA_data data;'
        ''
        '  //*ierr= 0;'
        ''
        '  data = (User_IDA_data) jdata;'
        '  ewt  = data->ewt;'
        ''
        '  flag = IDAGetCurrentStep(data->ida_mem, &hh);'
        '  //if (flag<0) {  *ierr=200+(-flag); return (*ierr);};'
        ''
        '  flag = IDAGetErrWeights(data->ida_mem, ewt);'
        '  //if (flag<0) {  *ierr=200+(-flag); return (*ierr);};'
        ''
        '  ewt_data = NV_DATA_S(ewt);'
        ''
        '  x   = (double *) N_VGetArrayPointer(yy);'
        '  xd  = (double *) N_VGetArrayPointer(yp);'
        '  res = (double *) data->rwork;'
        ''
        '  t    = (double) tt;'
        '  CJ   = (double) cj;'
        '  srur = (double) RSqrt(UNIT_ROUNDOFF);'
        ''
        '  scicos_time = t;'
        ''
        '  if (AJacobian_block > 0) {'
        '    nx = block_'+rdnom+'[AJacobian_block-1].nx;'
        '    no = block_'+rdnom+'[AJacobian_block-1].nout;'
        '    ni = block_'+rdnom+'[AJacobian_block-1].nin;'
        '    y  = (double **)block_'+rdnom+'[AJacobian_block-1].outptr;'
        '    u  = (double **)block_'+rdnom+'[AJacobian_block-1].inptr;'
        '  }'
        '  else {'
        '    nx = 0;'
        '    no = 0;'
        '    ni = 0;'
        '  }'
        '  n  = Neq;'
        '  //nb = nblk;'
        '  m  = n-nx;'
        ''
        '  ERR1   = res+n;'
        '  ERR2   = ERR1+n;'
        '  RX     = ERR2+n;'
        '  Fx     = RX+(n+ni)*(n+no);'
        '  Fu     = Fx+nx*nx;'
        '  Gx     = Fu+nx*ni;'
        '  Gu     = Gx+no*nx;'
        '  Hx     = Gu+no*ni;'
        '  Hu     = Hx+m*m; '
        '  Kx     = Hu+m*no;'
        '  Ku     = Kx+ni*m;'
        '  HuGx   = Ku+ni*no;'
        '  FuKx   = HuGx+m*nx;'
        '  FuKuGx = FuKx+nx*m;'
        '  HuGuKx = FuKuGx+nx*nx;'
        ''
        '  /* read residuals */']

  Code=[Code
        '  /* adjust x ptr */']

  for kf=1:nblk
    if (xptr(kf+1)-xptr(kf)) <> 0 then
      Code=[Code;
            '  block_'+rdnom+'['+string(kf-1)+'].x   = &x['+string(xptr(kf)-1)+'];'
            '  block_'+rdnom+'['+string(kf-1)+'].xd  = &xd['+string(xptr(kf)-1)+'];'
            '  block_'+rdnom+'['+string(kf-1)+'].res = &res['+string(xptr(kf)-1)+'];']
     end
  end

  Code=[Code;
        ''
        write_code_odoit(1) //** first pass
        write_code_odoit(0) //** second pass
       ]

//       Code=[Code
//             '  job = 0;'
//             '  Jdoit(&t, x, xd, res, &job);'
//             '']

  Code=[Code
        '  /* ""residual"" already contains the current residual,'
        '       so the first call to Jdoit can be removed*/'
        ''
        '  for (i=0;i<m;i++) {'
        '    for (j=0;j<ni;j++) {'
        '      Kx[j+i*ni]=u[j][0];'
        '    }'
        '  }'
        ''
        '  for (ii = 0; ii < m; ii++) {'
        '    xi  = x[ii];'
        '    xpi = xd[ii];'
        '    inc = MAX( srur * MAX( ABS(xi),ABS(hh*xpi)),ONE/ewt_data[ii] );'
        '    /* inc = max( srur * max( abs(xi),abs(hh*xpi)),ONE/ewt_data[ii] ); */'
        '    if (hh*xpi < ZERO) inc = -inc;'
        '    inc = (xi + inc) - xi;'
        '    if (CI == 0) {'
        '      inc = MAX( srur * ABS(hh*xpi),ONE );'
        '      /* inc = max( srur * abs(hh*xpi),ONE ); */'
        '      if (hh*xpi < ZERO) inc = -inc;'
        '      inc = (xpi + inc) - xi;'
        '    }'
        '    x[ii]  += CI*inc;'
        '    xd[ii] += CJ*inc;'
        '']

      Code=[Code
        '    /* adjust x ptr */']
  for kf=1:nblk
    if (xptr(kf+1)-xptr(kf)) <> 0 then
      Code=[Code;
            '    block_'+rdnom+'['+string(kf-1)+'].res = &ERR2['+string(xptr(kf)-1)+'];']
    end
  end

  Code=[Code;
        ''
        '    /* save res ptr */'
        '    res_save = res;'
        '    res = ERR2;']

  Code=[Code;
        ''
        '  '+write_code_odoit(1) //** first pass
        '  '+write_code_odoit(0) //** second pass
           ]

  Code=[Code;
        '    /* restore res ptr */'
        '    res = res_save;'
        '']

//       Code=[Code
//         '    /* read residuals */'
//         '    job=0;'
//         '    Jdoit(&t, x, xd, ERR2, &job);'
//         '    //if (*ierr < 0) return -1;']

  Code=[Code
        '    inc_inv = ONE/inc;'
        '    for (j = 0; j < m; j++) {'
        '      Hx[m*ii+j]=(ERR2[j]-res[j])*inc_inv;'
        '    }'
        '    for (j = 0; j < ni; j++) {'
        '      Kx[j+ii*ni]=(u[j][0]-Kx[j+ii*ni])*inc_inv;'
        '    }'
        '    x[ii]  = xi;'
        '    xd[ii] = xpi;'
        '  }'
        '  /*----- Numerical Jacobian--->> Hu,Ku */'
        ''
        '  if (AJacobian_block == 0) {'
        '    for (j = 0; j < m; j++) {'
        '     Jacque_col=DENSE_COL(Jacque,j);'
        '      for (i = 0; i < m; i++) {'
        '       Jacque_col[i]=Hx[i+j*m];'
        '      }'
        '    }'
        '    return 0;'
        '  }'
        '  /****------------------***/']

  Code=[Code
        '  /* adjust res ptr */']

  for kf=1:nblk
    if (xptr(kf+1)-xptr(kf)) <> 0 then
      Code=[Code;
            '  block_'+rdnom+'['+string(kf-1)+'].res = &ERR1['+string(xptr(kf)-1)+'];']
    end
  end

  Code=[Code;
        ''
        '  /* save res ptr */'
        '  res_save = res;'
        '  res = ERR1;']

  Code=[Code;
        ''
        write_code_odoit(1) //** first pass
        write_code_odoit(0) //** second pass
           ]

  Code=[Code;
        '  /* restore res ptr */'
        '  res = res_save;'
        '']

//       Code=[Code
//         '  job=0;'
//         '  Jdoit(&t, x, xd, ERR1, &job);']

  Code=[Code
        '  for (i = 0; i < no; i++) {'
        '    for (j = 0; j < ni; j++) {'
        '      Ku[j+i*ni]=u[j][0];'
        '    }'
        '  }'
        ''
        '  for (ii = 0; ii < no; ii++) {'
        '    ysave = y[ii][0];'
        '    inc   = srur * MAX( ABS(ysave),1);'
        '    /* inc   = srur * max( abs(ysave),1); */'
        '    inc   = (ysave + inc) - ysave;'
        '    y[ii][0] += inc;'
        ''
        '    /* Applying y[ii][0] to the output of imp block*/']

//       Code=[Code
//         '    job=2;'
//         '    Jdoit(&t, x, xd, ERR2, &job);'
//         '    //if (*ierr < 0) return -1;']

  Code=[Code
        '    /* adjust res ptr */']

  for kf=1:nblk
    if (xptr(kf+1)-xptr(kf)) <> 0 then
      Code=[Code;
            '    if (AJacobian_block != '+string(kf)+') {'
            '      block_'+rdnom+'['+string(kf-1)+'].res = &ERR2['+string(xptr(kf)-1)+'];'
            '    }']
    end
  end

  Code=[Code;
        ''
        '    /* save res ptr */'
        '    res_save = res;'
        '    res = ERR2;']

      //@@ !!!!!!
      //@@ Attention ici
  Code=[Code;
        ''
        '  '+write_code_odoit(1) //** first pass
        '  '+write_code_odoit(0) //** second pass
       ]

  Code=[Code;
        '    /* restore res ptr */'
        '    res = res_save;'
        '']

  Code=[Code
        '    inc_inv = ONE/inc;'
        '    for (j = 0; j < m; j++)  Hu[m*ii+j] = (ERR2[j]-ERR1[j])*inc_inv;'
        '    for (j = 0; j < ni; j++) Ku[j+ii*ni]= (u[j][0]-Ku[j+ii*ni])*inc_inv;'
        '    y[ii][0]=ysave;'
        '  }'
        '  /*----------------------------------------------*/'
        ''
        '  /* Read jacobian through flag=10; */']

//       Code=[Code
//         '  job=1;'
//         '  Jdoit(&t, x, xd, &Fx[-m], &job); /* Filling up the FX:Fu:Gx:Gu */'
//         '']

  Code=[Code
        '  /* adjust res ptr */']

 for kf=1:nblk
   if (xptr(kf+1)-xptr(kf)) <> 0 then
      Code=[Code;
            '  block_'+rdnom+'['+string(kf-1)+'].res = &Fx[-m+'+string(xptr(kf)-1)+'];']
    end
  end

  Code=[Code;
        ''
        '  /* save res ptr */'
        '  res_save = res;'
        '  res = &Fx[-m];']

  Code=[Code;
        ''
        write_code_odoit(1) //** first pass
        write_code_odoit(10) //** second pass
       ]

  Code=[Code;
        '  /* restore res ptr */'
        '  res = res_save;'
        '']

  Code=[Code
        '  /*-------------------------------------------------*/'
        ''
        '  '+rdnom+'_Multp(Fu,Ku,RX,nx,ni,ni,no);'
        '  '+rdnom+'_Multp(RX,Gx,FuKuGx,nx,no,no,nx);'
        ''
        '  for (j = 0; j < nx;j++) {'
        '    Jacque_col=DENSE_COL(Jacque,j+m);'
        '    for (i = 0; i < nx;i++) {'
        '      Jacque_col[i+m]=Fx[i+j*nx]+FuKuGx[i+j*nx];'
        '    }'
        '  }'
        ''
        '  '+rdnom+'_Multp(Hu,Gx,HuGx,m, no, no,nx);'
        ''
        '  for (i = 0; i < nx;i++) {'
        '    Jacque_col=DENSE_COL(Jacque,i+m);'
        '    for (j = 0; j < m;j++) {'
        '      Jacque_col[j]=HuGx[j+i*m];'
        '    }'
        '  }'
        ''
        '  '+rdnom+'_Multp(Fu,Kx,FuKx,nx,ni,ni,m);'
        ''
        '  for (i = 0; i < m; i++) {'
        '   Jacque_col=DENSE_COL(Jacque,i);'
        '   for (j = 0; j < nx; j++) {'
        '     Jacque_col[j+m]=FuKx[j+i*nx];'
        '    }'
        '  }'
        ''
        '  '+rdnom+'_Multp(Hu,Gu,RX,m,no,no,ni);'
        '  '+rdnom+'_Multp(RX,Kx,HuGuKx,m,ni,ni,m);'
        ''
        '  for (j = 0; j < m; j++) {'
        '    Jacque_col=DENSE_COL(Jacque,j);'
        '    for (i = 0; i < m; i++) {'
        '      Jacque_col[i]=Hx[i+j*m]+HuGuKx[i+j*m];'
        '    }'
        '  }'
        ''
        '  return 0;'
        '}'
        '']

  Code=[Code
        ' /* */'
        'void '+rdnom+'_Multp(A,B,R,ra ,ca, rb,cb)'
        '     double *A, *B, *R;'
        '     int ra,rb,ca,cb;'
        '{'
        '  int i,j,k;'
        ''
        '  for (i = 0; i<ra; i++) {'
        '    for (j = 0; j<cb; j++) {'
        '      R[i+ra*j]=0.0;'
        '      for (k = 0; k<ca; k++) {'
        '        R[i+ra*j]+=A[i+k*ra]*B[k+j*rb];'
        '      }'
        '    }'
        '  }'
        '  return;'
        '}'
        '']
endfunction

function [Code]=make_outevents()
//Copyright (c) 1989-2010 Metalau project INRIA

//@@ make_outevents : Generating the routine for external
//                    world events handling function
//
// Output : Code : text of the generated routine
//

  if szclkIN==[] then
    newszclkIN=0;
  else
    newszclkIN=szclkIN;
  end

  Code=['/*'+part('-',ones(1,40))+'  External events handling function */';
         'void '+rdnom+'_events(int *nevprt,double *t)';
         '{'
         '/*  set next event time and associated events ports'
         ' *  nevprt has binary expression b1..b'+string(newszclkIN)+' where bi is a bit'
         ' *  bi is set to 1 if an activation is received by port i. Note that'
         ' *  more than one activation can be received simultaneously'
         ' *  Caution: at least one bi should be equal to one */'
         '']

  if (newszclkIN <> 0) then
    Code=[Code;
          '    int i,p,b[]={'+strcat(string(z(ones(1,newszclkIN))),',')+'};'
          ''
          '/* this is an example for the activation of events ports */'
          '    b[0]=1;']

    if newszclkIN>1 then
      for bb=2:newszclkIN
        Code($+1)='    b['+string(bb-1)+']=1;'
      end
    end

    Code=[Code;
          ''
          '/* definition of the step time  */'
          '    *t = *t + 0.1;'
          ''
          '/* External events handling process */'
          '    *nevprt=0;p=1;'
          '    for (i=0;i<'+string(newszclkIN)+';i++) {'
          '      *nevprt=*nevprt+b[i]*p;'
          '      p=p*2;'
          '    }'
          '}']
  else
    Code=[Code;
          '';
          '/* definition of the step time  */'
          '    *t = *t + 0.1;'
          '}']
  end

endfunction

function [Code]=make_sci_interf43()
//Copyright (c) 1989-2010 Metalau project INRIA

//@@ make_sci_interf43 : generation of a ScicosLab interfacing function
//                       to use the standalone
//
// Output : Code : text of the generated routines
//

 //## get the number of sensors/actuators
 nbcapt=size(capt,1)
 nbact=size(actt,1)

 //@@ get the length of the name of the interfacing scilab function
 l_rdnom=length(rdnom)
 l_rdnom=(l_rdnom>17)*17 + (l_rdnom<=17)*l_rdnom

 //## header
 Code=['/* ScicosLab interfacing function of the Scicos standalone */'
       '/*     Generated by Code_Generation toolbox of Scicos with '+ ..
       get_scicos_version()+' */'
       '/*     date : '+date()+' */'
       ''
       '/* Copyright (c) 1989-2010 Metalau project INRIA */'
       ''
       '/* ---- Headers ---- */'
       '#include <string.h>'
       '#include <stdlib.h>'
       '#include <stdio.h>'
       '#include ""stack-c.h""'
       '#include ""mex.h""'
       '']

 //## external definition of standalone simulation function
 Code=[Code;
       '/* parameters structure definition */'
       'typedef struct {'
       '  char *filen;'
       '  double tf;'
       '} params_struct ;'
       ''
       '/* external definition of standalone simulation function */'
       'extern int '+rdnom+'_sim(params_struct params, \'
       get_blank(rdnom)+'                int *typin, void **inptr, int *typout, void **outptr);'
       ''
       '/* external definition of error table function */'
       'extern void geterr(int ierr,char *err_msg);'
       ''
       '#if WIN32'
       '  #ifndef coserr'
       '    #define coserr _imp__coserr'
       '  #endif'
       '#endif'
       ''
       '/* standalone still use scicos.c here ! */'
       'extern struct {char buf[4096];} coserr;'
       '']

 //## type of in/out structure definition
 Code=[Code;
       '/* structure definition of in/out sensors/actuators */'
       'typedef struct {'
       '  int typ;      /* data type */'
       '  int ndims;    /* number of dims */'
       '  int ndata;    /* number of data */'
       '  int *dims;    /* size of data (length ndims) */'
       '  double *time; /* date of data (length ndata) */'
       '  void *data;   /* data (length ndata*prod(dims)) */'
       '} scicos_inout;'
       '']

 //## comment
 txt_in  = []
 txt_out = []
 for i=1:nbcapt
   txt_in = txt_in+'in'+string(i)+',';
   if i==nbcapt then
     txt_in=part(txt_in,1:length(txt_in)-1);
   end
 end
 for i=1:nbact
   txt_out = txt_out+'out'+string(i)+',';
   if i==nbact then
     txt_out=part(txt_out,1:length(txt_out)-1);
   end
 end

 if txt_in<>[] then
   txt_rhs=txt_in+',[,tf][,fil]';
 else
   txt_rhs='[,tf][,fil]';
 end

 Code_help=[]

 Code_help=[Code_help;
            ' '''+rdnom+''' - ScicosLab simulation function.'
            ''
            ' Usage : ['+txt_out+']='+rdnom+'('+txt_rhs+')'
            ''
            ' Input Parameters (Rhs) :']
 if txt_in<>[] then
   Code_help=[Code_help;
              ' in     : input signal(s) for sensors']
 end

 //@@ look at for end block
 Tfin=[];
 cpr=cpr;
 funs=cpr.sim.funs;
 tevts=cpr.state.tevts;
 clkptr=cpr.sim.clkptr;

 for i=1:nblk
   if funs(i)=='scicosexit' then
     Tfin=tevts(clkptr(i))
   end
 end

 if Tfin==[] then Tfin=scs_m.props.tf, end

 Code_help=[Code_help;
            ' tf     : final time (default : '+string(Tfin)+')'
            ' fil    : parameters file (default : ""'+rdnom+'_params.dat"")'
            '']
  if txt_out<>0 then
    Code_help=[Code_help;
               ' Output Parameters (Lhs) :'
               ' out    : output signal(s) coming from actuator']
  end

  //@@ usage
  Code=[Code;
        '/* set a variable to display the usage of that function */'
        'static char doc[]=""'+Code_help(1)+'\n""'
        '                  ""'+strsubst(Code_help(2:$),'""','\""')+'\n""']
  Code($)=Code($)+';'
  Code=[Code;
        '']


  Code=[Code
        '/*'+Code_help(1);
        ' *'+Code_help(2:$)
        ' */']

 //## interfacing function
 Code=[Code;
       'int int'+part(rdnom,1:l_rdnom)+'_sci(fname,fname_len)'
       '   char *fname;'
       '   unsigned long fname_len;'
       '{']

 //## declaration of variables for scilab stack
 Code = [Code;
         '  /* variables to handle ptr and dims coming from scilab stack */']
 //## for sensors
 for i=1:nbcapt
    Code = [Code;
            '  static int *il'+string(i)+','+...
              'n'+string(i)+',m'+string(i)+';'+...
              '  /* sensor '+string(i)+' */']
 end

 //@@ define number of optional args
 nargs=2

 //## args 1 for [,tf]
 Code = [Code;
         '  static int *il'+string(nbcapt+1)+','+...
           'n'+string(nbcapt+1)+',m'+string(nbcapt+1)+';'+...
            '  /* tf */']
 //## args nargs for [,fil]
 Code = [Code;
         '  static int *il'+string(nbcapt+nargs)+',len'+string(nbcapt+nargs)+','+...
           'n'+string(nbcapt+nargs)+',m'+string(nbcapt+nargs)+';'+...
            '  /* fil */']
 //## for actuators
 for i=1:nbact
    Code = [Code;
            '  static int n'+string(nbcapt+nargs+i)+...
              ',n'+string(nbcapt+nargs+i)+'_t'+...
              ',m'+string(nbcapt+nargs+i)+';'+...
               '  /* actuator '+string(i)+' */']
 end
 //## for scicos signal (mlist)
 if nbact>0 then
    Code = [Code;
            '  static int mL=4,nL=1,lL; /* def scicos signal */'
            '  static char *Str[]={""st"",""dims"",""values"",""time""};'
            '  static int V[]={1,1};'
            '  static SciIntMat M={1,2,4,-1,V};  /* dims field */']
 end

 //## declaration of variables for standalone simulation function
 Code = [Code;
         ''
         '  /* variables for standalone simulation function */']

 //## default values for parameters
 Code=[Code
       '  /* default values for parameters structure */'
       '  double tf  = -1;']

 Code=[Code
       '  /* parameters file declaration */'
       ''
       '  /* a file descriptor to test parameters file */'
       '  FILE *fp;'
       ''
       '  /* default parameters file name */'
       '  char filen[]     = ""'+rdnom+'_params.dat"";']

 //@@ adjust path of parameters file for
 //@@ scicoslab interfacing function
 if MSDOS then
   Code=[Code
         '  char rpatfilen[] = ""'+rpat+'\'+rdnom+'_params.dat"";']
   if strindex(Code($),'\\')==[] then
     Code($)=strsubst(Code($),'\','\\')
   end
 else
   Code=[Code
         '  char rpatfilen[] = ""'+rpat+'/'+rdnom+'_params.dat"";']
 end

 Code=[Code
       '  char data[256];'
       ''
       '  /* parameters structure for simulation function */'
       '  params_struct params;']

 //## sensors
 if nbcapt<>0 then
   Code=[Code
         ''
         '  /* Inputs of sensors */'
         '  /* int nin='+string(nbcapt)+'; */'
         cformatline('  int typin[]={'+...
              strcat(string(2*ones(nbcapt,1)),"," )+'};',70)
         cformatline('  void *inptr[]={'+...
              strcat(string(zeros(nbcapt,1)),"," )+'};',70)]

   for i=1:nbcapt
     Code=[Code
           '  scicos_inout in_'+string(i)+';']
   end
 else
   Code=[Code;
         ''
         '  /* Inputs of sensors */'
         '  /* int nin=0; */'
         '  int *typin=NULL;'
         '  void **inptr=NULL;']
 end

 //## actuators
 if nbact<>0 then
   Code=[Code
         ''
         '  /* Outputs of actuators */'
         '  /* int nout='+string(nbact)+'; */'
         cformatline('  int typout[]={'+...
              strcat(string(2*ones(nbact,1)),"," )+'};',70)
         cformatline('  void *outptr[]={'+...
              strcat(string(zeros(nbact,1)),"," )+'};',70)]

   for i=1:nbact
     Code=[Code
           '  scicos_inout out_'+string(i)+';']
   end
 else
   Code=[Code;
         ''
         '  /* Outputs of actuators */'
         '  /* int nout=0; */'
         '  int *typout=NULL;'
         '  void **outptr=NULL;']
 end

 //## template for actuator transposition
 if nbact<>0 then
   Code=[Code
         ''
         '  /* ptr for output transposition */']
   for i=1:nbact
     Code=[Code
           '  void *out_ptr'+string(i)+';']
   end
 end

 //## error handling
 Code=[Code
       ''
       '  /* Ouput standalone error handling */'
       '  int ierr;'
       '  char err_msg[4096];']

 //## counter variable
 Code=[Code
       ''
       '  /* counter local variable */'
       '  int i,j;']

 //## Initialize LhsVar
 if nbact>0 then
   Code=[Code
         ''
         '  /* initialize LhsVar */']

   for i=1:nbact
     Code=[Code
           '  LhsVar('+string(i)+')=0;']
   end
 end

 //## CheckRhs min=nb sensors, max= nb sensors+4
 Code=[Code;
       ''
       '  /* check numbers of rhs/lhs */']

 Code=[Code;
       '  if ((Rhs<'+string(nbcapt)+') || (Rhs>'+string(nbcapt+nargs)+')){'
       '    sciprint_nd(""\n"");'
       '    sciprint_nd(doc);'
       '    CheckRhs('+string(nbcapt)+','+string(nbcapt+nargs)+');'
       '  }'
       '']

 //## CheckLhs min/max=nb actuators
 Code=[Code;
       '  if ((Lhs<'+string(nbact)+') || (Lhs>'+string(nbact)+')){'
       '    sciprint_nd(""\n"");'
       '    sciprint_nd(doc);'
       '    CheckLhs('+string(nbact)+','+string(nbact)+');'
       '  }'
       '']

 //@@ init for dims of fil variable 
 Code=[Code;
       '  /* init for dims of fil variable */'
       '  n'+string(nbcapt+nargs)+'=0;m'+string(nbcapt+nargs)+'=0;'
       '']


 Code=[Code;
       '  switch(Rhs) {']

 //## Check/get rhs var
 for i=nbcapt+nargs:-1:1

   //## str for stack handling
   i_str = string(i);
   m_str = 'm'+string(i);
   n_str = 'n'+string(i);
   l_str = 'il'+string(i);

  //## fil (parameters file)
  if i==nbcapt+nargs then
     Code=[Code;
           '    case '+i_str+' :    /* check/get fil */'
           '       '+l_str+'  = (int *) GetData('+string(i)+');'
           '       '+m_str+'   = '+l_str+'[1];'
           '       '+n_str+'   = '+l_str+'[2];'
           '       len'+string(i)+' = '+l_str+'[5]-1;'
           '       C2F(cvstr)(&len'+string(i)+',&'+l_str+'[6],data,(j=1,&j),len'+string(i)+');'
           '       data[len'+string(i)+']=''\0'';'
           '']

  //## tf (final time simulation)
  elseif i==nbcapt+1 then
     Code=[Code;
           '    case '+i_str+' :    /* check/get tf */'
           '       '+l_str+'  = (int *) GetData('+string(i)+');'
           '       '+m_str+'   = '+l_str+'[1];'
           '       '+n_str+'   = '+l_str+'[2];'
           '       tf = *((double *) & '+l_str+'[4]);'
           '       /* check value of tf */'
           '       if ( (tf<=0.) && (tf!=-1.) ) {'
           '         Scierror(999,""%s : tf must be positive.\n"",fname);'
           '         return 0;'
           '       }'
           '']

  //## sensors
  else
     Code=[Code;
           '    case '+i_str+' :    /* check/get sensor '+i_str+' */'
           '       '+l_str+'  = (int *) GetData('+string(i)+');'
           '       '+m_str+'   = '+l_str+'[1];'
           '       '+n_str+'   = '+l_str+'[2];'
           '       /* Many thing to do */'
           '']

  end
 end

 Code=[Code;
       '  }'
       '']

 //## inform in/out structure
 //## sensors
 for i=1:nbcapt
   //## in_x.dims
   Code=[Code
         '  /* inform in struct of sensor '+string(i)+' */'
         '  in_'+string(i)+'.typ       = '+string(capt(i,5))+';'
         '  in_'+string(i)+'.ndims     = 2;'
         '  in_'+string(i)+'.ndata     = m'+string(i)+';'
         '  if ((in_'+string(i)+'.dims = (int*) malloc(in_'+string(i)+'.ndims*sizeof(int)))==NULL){'];
   if i<>1 then
     for j=1:i-1
       Code=[Code
             '    free(in_'+string(j)+'.dims);'];
     end
   end
   Code=[Code
         '    return 0;'
         '  }']

   //## in_x.data
   Code=[Code
         '  in_'+string(i)+'.dims[0] = 1;'
         '  in_'+string(i)+'.dims[1] = n'+string(i)+';']
   //## add complex number
   //## arbitrary data type should be done.
   if capt(i,5) == 11 then // cmplx case
     Code=[Code
           '  if ((in_'+string(i)+'.data = (double *) malloc(in_'+string(i)+'.ndata*'+...
                 'in_'+string(i)+'.dims[0]*in_'+string(i)+'.dims[1]*2*sizeof(double)))==NULL){']
   else
     Code=[Code
           '  if ((in_'+string(i)+'.data = (double *) malloc(in_'+string(i)+'.ndata*'+...
                 'in_'+string(i)+'.dims[0]*in_'+string(i)+'.dims[1]*sizeof(double)))==NULL){']
   end

   for j=1:i
     Code=[Code
           '    free(in_'+string(j)+'.dims);']
   end

   Code=[Code
         '    return 0;'
         '  }'
         '  if ((in_'+string(i)+'.dims[0] == 1) &&  (in_'+string(i)+'.dims[1] != 1)) {'
         '    for(i=0;i<in_'+string(i)+'.ndata;i++) {'
         '      for(j=0;j<in_'+string(i)+'.dims[1];j++) {'
         '         *((double *)in_'+string(i)+'.data + i*in_'+string(i)+'.dims[1] + j) = \'
         '             *((double *) &il'+string(i)+'[4] + j*in_'+string(i)+'.ndata + i);']

   if capt(i,5) == 11 then // cmplx case
     Code=[Code
           '         *((double *)in_'+string(i)+'.data + i*in_'+string(i)+'.dims[1] + j + '+...
                       'in_'+string(i)+'.dims[0]*in_'+string(i)+'.dims[1]) = \'
           '             *((double *) &il'+string(i)+'[4] + j*in_'+string(i)+'.ndata + i + '+...
                       'in_'+string(i)+'.dims[0]*in_'+string(i)+'.dims[1]);']
   end

   Code=[Code
         '      }'
         '    }'
         '  }'
         '  else {']

   if capt(i,5) == 11 then // cmplx case
     Code=[Code
           '    for(i=0;i<in_'+string(i)+'.ndata*in_'+string(i)+'.dims[0]*in_'+string(i)+'.dims[1]*2;i++) {'
           '      *((double *)in_'+string(i)+'.data + i) = *((double *) &il'+string(i)+'[4] + i);'
           '    }']
   else
     Code=[Code
           '    for(i=0;i<in_'+string(i)+'.ndata*in_'+string(i)+'.dims[0]*in_'+string(i)+'.dims[1];i++) {'
           '      *((double *)in_'+string(i)+'.data + i) = *((double *) &il'+string(i)+'[4] + i);'
           '    }']
   end

   Code=[Code
         '  }'
         ''];
 end

 //## actuators
 for i=1:nbact
   //## out_x.dims
   Code=[Code
         '  /* inform out struct of actuator '+string(i)+' */'
         '  out_'+string(i)+'.typ       = '+string(actt(i,5))+';'
         '  out_'+string(i)+'.ndims     = 2;'
         '  out_'+string(i)+'.ndata     = 1000; /* default buffer size */'
         '  if ((out_'+string(i)+'.dims = (int *) malloc(out_'+string(i)+'.ndims*sizeof(int)))==NULL){'];
   for j=1:nbcapt
     Code=[Code
           '    free(in_'+string(j)+'.data);'
           '    free(in_'+string(j)+'.dims);'];
   end

   for j=1:i-1
     Code=[Code
           '    free(out_'+string(j)+'.dims);'
           '    free(out_'+string(j)+'.data);'
           '    free(out_'+string(j)+'.time);'];
   end

   Code=[Code
         '    return 0;'
         '  }']

   //## out_x.data
   Code=[Code
         '  out_'+string(i)+'.dims[0]   = '+string(actt(i,3))+';'
         '  out_'+string(i)+'.dims[1]   = '+string(actt(i,4))+';'
         '  out_'+string(i)+'.data      = NULL;']

   if actt(i,5) == 11 then // cmplx case
     Code=[Code
           '  if ((out_'+string(i)+'.data = (double *) realloc(out_'+string(i)+'.data, \'
           '       out_'+string(i)+'.ndata*'+...
            'out_'+string(i)+'.dims[0]*out_'+string(i)+'.dims[1]'+'*sizeof(double)*2))==NULL){'];
   else
     Code=[Code
           '  if ((out_'+string(i)+'.data = (double *) realloc(out_'+string(i)+'.data, \'
           '       out_'+string(i)+'.ndata*'+...
            'out_'+string(i)+'.dims[0]*out_'+string(i)+'.dims[1]'+'*sizeof(double)))==NULL){'];
   end

   for j=1:nbcapt
     Code=[Code
           '    free(in_'+string(j)+'.data);'
           '    free(in_'+string(j)+'.dims);'];
   end

   for j=1:i-1
     Code=[Code
           '    free(out_'+string(j)+'.dims);'
           '    free(out_'+string(j)+'.data);'
           '    free(out_'+string(j)+'.time);'];
   end

   Code=[Code
         '    free(out_'+string(i)+'.dims);']


   Code=[Code
         '    return 0;'
         '  }']

   //## out_x.time
   Code=[Code
         '  out_'+string(i)+'.time      = NULL;'
         '  if ((out_'+string(i)+'.time = (double *) realloc(out_'+string(i)+'.time,'+...
                 'out_'+string(i)+'.ndata*sizeof(double)))==NULL){'];
   for j=1:nbcapt
     Code=[Code
           '    free(in_'+string(j)+'.data);'
           '    free(in_'+string(j)+'.dims);'];
   end

   for j=1:i-1
     Code=[Code
           '    free(out_'+string(j)+'.dims);'
           '    free(out_'+string(j)+'.data);'
           '    free(out_'+string(j)+'.time);'];
   end

   Code=[Code
         '    free(out_'+string(i)+'.dims);'
         '    free(out_'+string(i)+'.data);'];

   Code=[Code
         '    return 0;'
         '  }'
         ''
        ];
 end

 //## store ptr of sensors/actuators
 if nbact<>0 & nbcapt<>0 then
   Code=[Code
         '  /* store ptr of sensors/actuators in inptr/outptr */']
 elseif nbcapt<>0 then
   Code=[Code
         '  /* store ptr of sensors in inptr */']
 elseif nbact<>0 then
   Code=[Code
         '  /* store ptr of actuators in outptr */']
 end

 if nbcapt<>0 then
   for i=1:nbcapt
     Code=[Code;
           '  inptr['+string(i-1)+']  = &in_'+string(i)+';']
   end
 end

 if nbact<>0 then
   for i=1:nbact
     Code=[Code;
           '  outptr['+string(i-1)+'] = &out_'+string(i)+';']
   end
 end

 //@@ set params structure
 Code=[Code
       ''
       '  /* set parameters structure */'
       ''
       '  /* set simulation final time */'
       '  params.tf = tf;'
       ''
       '  /* check parameters data file */'
       '  if (n'+string(nargs)+'!=0) {'
       '    params.filen = data;'
       '  }'
       '  else {'
       '    /* open parameters data file */'
       '    if ((fp = fopen(rpatfilen,""rb"")) == NULL) {'
       '      params.filen = filen;'
       '    }'
       '    else {'
       '      fclose(fp);'
       '      params.filen = rpatfilen;'
       '    }'
       '  }']

 //## call standalone simulation function
 Code=[Code
       ''
       '  /* call standalone simulation function */'
       '  ierr='+rdnom+'_sim(params, typin, inptr, typout, outptr);'
       ''
       '  /* display error message */'
       '  if (ierr!=0) {'
       '    /* standalone still use scicos.c here ! */'
       '    if(ierr!=10) {'
       '      geterr(ierr,err_msg);'
       '    }'
       '    else {'
       '      strcpy(err_msg,coserr.buf);'
       '    }'
       '    Scierror(999,""%s : Simulation fails with error number %d :'+...
             '\n%s\n"",fname,ierr,err_msg);'
       '  }'
      ]

 //## create Lhsvar (actuators)
 if nbact<>0 then
   Code=[Code
         ''
         '  /* Create LhsVar */']

   for i=1:nbact
     //## str for stack handling
     i_str = string(i+nbcapt+nargs);
     m_str = 'm'+string(i+nbcapt+nargs);
     n_str = 'n'+string(i+nbcapt+nargs);
     l_str = 'l'+string(i+nbcapt+nargs);

     Code=[Code
           '  /* actuator '+string(i)+' */'
           '  CreateVar('+i_str+', ""m"", &mL, &nL, &lL);              /* mlist */'
           '  CreateListVarFromPtr('+i_str+',1,""S"", &nL, &mL, Str);  /* str of scicos signal */'
           '  CreateListVarFromPtr('+i_str+',2,""I"", &M.m, &M.n, &M); /* def dims of mlist */'
           '  '+m_str+'=out_'+string(i)+'.ndata;']

     Code=[Code
           '  /* vector case */'
           '  if ((out_'+string(i)+'.dims[0]==1 && out_'+string(i)+'.dims[1]!=1) || \'
           '      (out_'+string(i)+'.dims[0]!=1 && out_'+string(i)+'.dims[1]==1)) {'
           '    if (out_'+string(i)+'.dims[0]!=1) {'
           '      '+n_str+'=out_'+string(i)+'.dims[0];'
           '    }'
           '    else {'
           '      '+n_str+'=out_'+string(i)+'.dims[1];'
           '    }'
           '    /*transpose output */']

     if actt(i,5) == 11 then // cmplx case
       Code=[Code
             '    if ((out_ptr'+string(i)+' = (double *) malloc('+m_str+'*'+n_str+'*2*sizeof(double)))==NULL){']
     else
       Code=[Code
             '    if ((out_ptr'+string(i)+' = (double *) malloc('+m_str+'*'+n_str+'*sizeof(double)))==NULL){']
     end

     if nbcapt<>0 then
       for j=1:nbcapt
         Code=[Code
               '      free(in_'+string(j)+'.data);'
               '      free(in_'+string(j)+'.dims);'];
       end
     end
     for j=1:nbact
       Code=[Code
             '      free(out_'+string(j)+'.dims);'
             '      free(out_'+string(j)+'.data);'
             '      free(out_'+string(j)+'.time);'];
     end
     for ii=1:i-1
       Code=[Code
             '      if((out_'+string(ii)+'.dims[0]!=1) || (out_'+string(ii)+'.dims[1]!=1)) {'
             '        free(out_ptr'+string(ii)+');'
             '      }']
     end

     Code=[Code
           '      return 0;'
           '    }'
           '    for(i=0;i<'+m_str+';i++) {'
           '      for(j=0;j<'+n_str+';j++) {'
           '        *((double *)out_ptr'+string(i)+' + j*'+m_str+' + i) = *((double *) out_'+string(i)+'.data + i*'+n_str+' + j);']

     if actt(i,5) == 11 then // cmplx case
       Code=[Code
             '        *((double *)out_ptr'+string(i)+' + j*'+m_str+' + i + m7*n7) = *((double *) out_'+string(i)+'.data + i*'+n_str+' + j + m7*n7);']
     end

     Code=[Code
           '      }'
           '    }']

     if actt(i,5) == 11 then // cmplx case
       Code=[Code
             '   {'
             '     int it=1;'
             '     double *ptr_d = ((double*) out_ptr'+string(i)+' + m7*n7);'
             '     CreateListCVarFromPtr('+i_str+',3,""d"", &it, &'+m_str+', &'+n_str+', &out_ptr'+string(i)+', &ptr_d);   /* data */'
             '   }']
     else
       Code=[Code
             '    CreateListVarFromPtr('+i_str+',3,""d"", &'+m_str+', &'+n_str+', &out_ptr'+string(i)+');   /* data */']
     end

     Code=[Code
           '  }'
           '  else {'
           '    /* scalar case */'
           '    if (out_'+string(i)+'.dims[0]==1 && out_'+string(i)+'.dims[1]==1) {']

     if actt(i,5) == 11 then // cmplx case
       Code=[Code
             '      '+n_str+'=1;'
             '      int it=1;'
             '      double *ptr_d = ((double*) out_'+string(i)+'.data + m7*n7);'
             '      CreateListCVarFromPtr('+i_str+',3,""d"", &it, &'+m_str+', &'+n_str+', &out_'+string(i)+'.data, &ptr_d);   /* data */']
     else
       Code=[Code
             '      '+n_str+'=1;'
             '      CreateListVarFromPtr('+i_str+',3,""d"", &'+m_str+', &'+n_str+', &out_'+string(i)+'.data);   /* data */']
     end

     Code=[Code
           '    }'
           '    /* matrix case : TODO'
           '     * note that for that time,'
           '     * matrix are concatened in vectors.'
           '     */'
           '    else {']
           '      '

     Code=[Code
           '      '+n_str+'=out_'+string(i)+'.dims[0]*out_'+string(i)+'.dims[1];'
           '      /*transpose output */']

     if actt(i,5) == 11 then // cmplx case
       Code=[Code
             '      if ((out_ptr'+string(i)+' = (double *) malloc('+m_str+'*'+n_str+'*2*sizeof(double)))==NULL){'];
     else
       Code=[Code
             '      if ((out_ptr'+string(i)+' = (double *) malloc('+m_str+'*'+n_str+'*sizeof(double)))==NULL){'];
     end

     if nbcapt<>0 then
       for j=1:nbcapt
         Code=[Code
               '        free(in_'+string(j)+'.data);'
               '        free(in_'+string(j)+'.dims);'];
       end
     end
     for j=1:nbact
       Code=[Code
             '        free(out_'+string(j)+'.dims);'
             '        free(out_'+string(j)+'.data);'
             '        free(out_'+string(j)+'.time);'];
     end
     for ii=1:i-1
       Code=[Code
             '        if((out_'+string(ii)+'.dims[0]!=1) || (out_'+string(ii)+'.dims[1]!=1)) {'
             '          free(out_ptr'+string(ii)+');'
             '        }']
     end

     Code=[Code
           '        return 0;'
           '      }'
           '      for(i=0;i<'+m_str+';i++) {'
           '        for(j=0;j<'+n_str+';j++) {'
           '          *((double *)out_ptr'+string(i)+' + j*'+m_str+' + i) = *((double *) out_'+string(i)+'.data + i*'+n_str+' + j);'];
     if actt(i,5) == 11 then // cmplx case
       Code=[Code
             '        *((double *)out_ptr'+string(i)+' + j*'+m_str+' + i + m7*n7) = *((double *) out_'+string(i)+'.data + i*'+n_str+' + j + m7*n7);']
     end

     Code=[Code
           '        }'
           '      }']

     if actt(i,5) == 11 then // cmplx case
       Code=[Code
             '     {'
             '       int it=1;'
             '       double *ptr_d = ((double*) out_ptr'+string(i)+' + m7*n7);'
             '       CreateListCVarFromPtr('+i_str+',3,""d"", &it, &'+m_str+', &'+n_str+', &out_ptr'+string(i)+', &ptr_d);   /* data */'
             '     }']
     else
       Code=[Code
             '      CreateListVarFromPtr('+i_str+',3,""d"", &'+m_str+', &'+n_str+', &out_ptr'+string(i)+');   /* data */']
     end


     Code=[Code
           '    }'
           '  }']

     //## event date
     Code=[Code
           '  '+n_str+'_t=1;'
           '  CreateListVarFromPtr('+i_str+',4,""d"", &'+m_str+', &'+n_str+'_t'+...
              ', &out_'+string(i)+'.time);   /* event date */'
           '  /* Many thing to do */'
           ''];
   end
 end

 //## put LhsVar
 if nbact<>0 then
   Code=[Code
         '  /* Put LhsVar */']

   for i=1:nbact
     Code=[Code
           '  LhsVar('+string(i)+')='+string(i+nbcapt+nargs)+';']
   end
 end

 //## free allocated array
 //## array of sensors
 if nbcapt<>0 | nbact<>0 then
   Code=[Code
         ''
         '  /* free allocated array */'];
 end

 if nbcapt<>0 then
   for i=1:nbcapt
     Code=[Code
           '  free(in_'+string(i)+'.data);'
           '  free(in_'+string(i)+'.dims);'];
   end
 end

 //## array of actuators
 if nbact<>0 then
   Code=[Code
         ''];
   for i=1:nbact
     Code=[Code
           '  free(out_'+string(i)+'.dims);'];
   end

   for i=1:nbact
     Code=[Code
           '  free(out_'+string(i)+'.data);'];
   end

   for i=1:nbact
     Code=[Code
           '  free(out_'+string(i)+'.time);'];
   end

   for i=1:nbact
     n_str = 'n'+string(i+nbcapt+nargs);
     Code=[Code
           '  if ('+n_str+' != 1) {'
           '    free(out_ptr'+string(i)+');'
           '  }']

   end

 end

 //## end
 Code=[Code;
       '  return 0;'
       '}'
       '']

 //## gateway
 Code=[Code;
       'static GenericTable Tab[]='
       '{'
       ' {(Myinterfun)sci_gateway,int'+part(rdnom,1:l_rdnom)+'_sci,'
       ' """+rdnom+"""}'
       '};'
       ''
       'int C2F(int'+part(rdnom,1:l_rdnom)+'_sci)()'
       '{'
       ' Rhs = Max(0, Rhs);'
       ' (*(Tab[Fin-1].f))(Tab[Fin-1].name,Tab[Fin-1].F);'
       ' return 0;'
       '}'
       '']

endfunction

function [Code]=make_sci_interf()
//Copyright (c) 1989-2010 Metalau project INRIA

//@@ make_sci_interf : generation of a ScicosLab interfacing function
//                     to use the standalone
//
// Output : Code : text of the generated routines
//

 //## get the number of sensors/actuators
 nbcapt=size(capt,1)
 nbact=size(actt,1)

 //@@ get the length of the name of the interfacing scilab function
 l_rdnom=length(rdnom)
 l_rdnom=(l_rdnom>17)*17 + (l_rdnom<=17)*l_rdnom

 //## header
 Code=['/* ScicosLab interfacing function of the Scicos standalone */'
       '/*     Generated by Code_Generation toolbox of Scicos with '+ ..
       get_scicos_version()+' */'
       '/*     date : '+date()+' */'
       ''
       '/* Copyright (c) 1989-2010 Metalau project INRIA */'
       ''
       '/* ---- Headers ---- */'
       '#include <string.h>'
       '#include <stdlib.h>'
       '#include ""stack-c.h""'
       '#include ""mex.h""'
       '']

 //## external definition of standalone simulation function
 Code=[Code;
       '/* external defintion of standalone simulation function */'
       'extern int '+rdnom+'_sim(double tf, double dt, double h, int solver, \'
       get_blank(rdnom)+'                int *typin, void **inptr, int *typout, void **outptr);'
       ''
       '/* external definition of error table function */'
       'extern void get_err_msg(int ierr,char *err_msg);'
       ''
       '#if WIN32'
       '  #ifndef coserr'
       '    #define coserr _imp__coserr'
       '  #endif'
       '#endif'
       ''
       '/* standalone still use scicos.c here ! */'
       'extern struct {char buf[4096];} coserr;'
       '']

 //## type of in/out structure definition
 Code=[Code;
       '/* structure definition of in/out sensors/actuators */'
       'typedef struct {'
       '  int typ;      /* data type */'
       '  int ndims;    /* number of dims */'
       '  int ndata;    /* number of data */'
       '  int *dims;    /* size of data (length ndims) */'
       '  double *time; /* date of data (length ndata) */'
       '  void *data;   /* data (length ndata*prod(dims)) */'
       '} scicos_inout;'
       '']

 //## comment
 txt_in  = []
 txt_out = []
 for i=1:nbcapt
   txt_in = txt_in+'in'+string(i)+',';
   if i==nbcapt then
     txt_in=part(txt_in,1:length(txt_in)-1);
   end
 end
 for i=1:nbact
   txt_out = txt_out+'out'+string(i)+',';
   if i==nbact then
     txt_out=part(txt_out,1:length(txt_out)-1);
   end
 end

 if txt_in<>[] then
   txt_rhs=txt_in+',[,te][,tf][,h][,solver]';
 else
   txt_rhs='[,te][,tf][,h][,solver]';
 end

 Code=[Code;
       '/* ['+txt_out+']='+rdnom+'('+txt_rhs+')'
       ' *'
       ' * Rhs :']
 if txt_in<>[] then
   Code=[Code;
         ' * in     : input signal(s) for sensors']
 end
 Code=[Code;
       ' * te     : sampling time (default : 0.1)'
       ' * tf     : final time (default : 30)'
       ' * h      : solver step (default : 0.001)'
       ' * solver : type of solver (1:Euler, 2:Heun, 3:R.Kutta 4th order)'
       ' *          (default : 3)'
       ' *']
  if txt_out<>0 then
    Code=[Code;
          ' * Lhs :'
          ' * out    : output signal(s) coming from actuator']
  end
  Code=[Code;
        ' */']

 //## interfacing function
 Code=[Code;
       'int int'+part(rdnom,1:l_rdnom)+'_sci(fname,fname_len)'
       '   char *fname;'
       '   unsigned long fname_len;'
       '{']

 //## declaration of variables for scilab stack
 Code = [Code;
         '  /* variables to handle ptr and dims coming from scilab stack */']
 //## for sensors
 for i=1:nbcapt
    Code = [Code;
            '  static int l'+string(i)+','+...
              'n'+string(i)+',m'+string(i)+';'+...
              '  /* sensor '+string(i)+' */']
 end
 //## for [,te][,tf][,h][,solver])
 Code = [Code;
         '  static int l'+string(nbcapt+1)+','+...
           'n'+string(nbcapt+1)+',m'+string(nbcapt+1)+';'+...
           '  /* te */'
         '  static int l'+string(nbcapt+2)+','+...
           'n'+string(nbcapt+2)+',m'+string(nbcapt+2)+';'+...
           '  /* tf */'
         '  static int l'+string(nbcapt+3)+','+...
           'n'+string(nbcapt+3)+',m'+string(nbcapt+3)+';'+...
           '  /* h */'
         '  static int l'+string(nbcapt+4)+','+...
           'n'+string(nbcapt+4)+',m'+string(nbcapt+4)+';'+...
           '  /* solver */']
 //## for actuators
 for i=1:nbact
    Code = [Code;
            '  static int l'+string(nbcapt+4+i)+','+...
              'n'+string(nbcapt+4+i)+',m'+string(nbcapt+4+i)+';'+...
              '  /* actuator '+string(i)+' */']
 end
 //## for scicos signal (mlist)
 if nbact>0 then
    Code = [Code;
            '  static int mL=4,nL=1,lL; /* def scicos signal */'
            '  static char *Str[]={""st"",""dims"",""values"",""time""};'
            '  static int V[]={1,1};'
            '  static SciIntMat M={1,2,4,-1,V};  /* dims field */']
 end

 //## declaration of variables for standalone simulation function
 Code = [Code;
         ''
         '  /* variables for standalone simulation function */']

 //## default values for te, tf, h and solver
 Code=[Code
       '  /* default values te,tf,h and solver */'
       '  double te  = 0.1;'
       '  double tf  = 30;'
       '  double h   = 0.001;'
       '  int solver = 3;']

 //## sensors
 if nbcapt<>0 then
   Code=[Code
         ''
         '  /* Inputs of sensors */'
         '  /* int nin='+string(nbcapt)+'; */'
         cformatline('  int typin[]={'+...
              strcat(string(2*ones(nbcapt,1)),"," )+'};',70)
         cformatline('  void *inptr[]={'+...
              strcat(string(zeros(nbcapt,1)),"," )+'};',70)]

   for i=1:nbcapt
     Code=[Code
           '  scicos_inout in_'+string(i)+';']
   end
 else
   Code=[Code;
         ''
         '  /* Inputs of sensors */'
         '  /* int nin=0; */'
         '  int *typin=NULL;'
         '  void **inptr=NULL;']
 end

 //## actuators
 if nbact<>0 then
   Code=[Code
         ''
         '  /* Outputs of actuators */'
         '  /* int nout='+string(nbact)+'; */'
         cformatline('  int typout[]={'+...
              strcat(string(2*ones(nbact,1)),"," )+'};',70)
         cformatline('  void *outptr[]={'+...
              strcat(string(zeros(nbact,1)),"," )+'};',70)]

   for i=1:nbact
     Code=[Code
           '  scicos_inout out_'+string(i)+';']
   end
 else
   Code=[Code;
         ''
         '  /* Outputs of actuators */'
         '  /* int nout=0; */'
         '  int *typout=NULL;'
         '  void **outptr=NULL;']
 end

 //## template for actuator transposition
 if nbact<>0 then
   Code=[Code
         ''
         '  /* ptr for output transposition */']
   for i=1:nbact
     Code=[Code
           '  void *out_ptr'+string(i)+';']
   end
 end

 //## error handling
 Code=[Code
       ''
       '  /* Ouput standalone error handling */'
       '  int ierr;'
       '  char err_msg[4096];']

 //## counter variable
 Code=[Code
       ''
       '  /* counter local variable */'
       '  int i,j;']

 //## CheckRhs min=nb sensors, max= nb sensors+4
 Code=[Code;
       ''
       '  /* check numbers of rhs/lhs */'
       '  CheckRhs('+string(nbcapt)+','+string(nbcapt+4)+');']

 //## CheckLhs min/max=nb actuators
 Code=[Code;
       '  CheckLhs('+string(nbact)+','+string(nbact)+');'
       '']

 Code=[Code;
       '  switch(Rhs) {']

 //## Check/get rhs var
 for i=nbcapt+4:-1:1

   //## str for stack handling
   i_str = string(i);
   m_str = 'm'+string(i);
   n_str = 'n'+string(i);
   l_str = 'l'+string(i);

  //## solver (solver type)
   if i==nbcapt+4 then
     Code=[Code;
           '    case '+i_str+' :    /* check/get solver */'
           '       GetRhsVar('+i_str+',""d"",&'+m_str+',&'+n_str+',&'+l_str+');'
           '       CheckDims('+i_str+','+m_str+','+n_str+',1,1);'
           '       solver = (int) *stk(l'+i_str+');'
           '']

  //## h (solver time step)
  elseif i==nbcapt+3 then
     Code=[Code;
           '    case '+i_str+' :    /* check/get h */'
           '       GetRhsVar('+i_str+',""d"",&'+m_str+',&'+n_str+',&'+l_str+');'
           '       CheckDims('+i_str+','+m_str+','+n_str+',1,1);'
           '       h = *stk(l'+i_str+');'
           '']

  //## tf (final time simulation)
  elseif i==nbcapt+2 then
     Code=[Code;
           '    case '+i_str+' :    /* check/get tf */'
           '       GetRhsVar('+i_str+',""d"",&'+m_str+',&'+n_str+',&'+l_str+');'
           '       CheckDims('+i_str+','+m_str+','+n_str+',1,1);'
           '       tf = *stk(l'+i_str+');'
           '']

  //## te (clock sampling time)
  elseif i==nbcapt+1 then
     Code=[Code;
           '    case '+i_str+' :    /* check/get te */'
           '       GetRhsVar('+i_str+',""d"",&'+m_str+',&'+n_str+',&'+l_str+');'
           '       CheckDims('+i_str+','+m_str+','+n_str+',1,1);'
           '       te = *stk(l'+i_str+');'
           '']

  //## sensors
  else
     Code=[Code;
           '    case '+i_str+' :    /* check/get sensor '+i_str+' */'
           '       GetRhsVar('+i_str+',""d"",&'+m_str+',&'+n_str+',&'+l_str+');'
           '       /* Many thing to do */'
           '']

  end
 end

 Code=[Code;
       '  }'
       '']

 //## inform in/out structure
 //## sensors
 for i=1:nbcapt
   //## in_x.dims
   Code=[Code
         '  /* inform in struct of sensor '+string(i)+' */'
         '  in_'+string(i)+'.typ       = '+string(capt(i,5))+';'
         '  in_'+string(i)+'.ndims     = 2;'
         '  in_'+string(i)+'.ndata     = m'+string(i)+';'
         '  if ((in_'+string(i)+'.dims = (int*) malloc(in_'+string(i)+'.ndims*sizeof(int)))==NULL){'];
   if i<>1 then
     for j=1:i-1
       Code=[Code
             '    free(in_'+string(j)+'.dims);'];
     end
   end
   Code=[Code
         '    return 0;'
         '  }']

   //## in_x.data
   Code=[Code
         '  in_'+string(i)+'.dims[0] = 1;'
         '  in_'+string(i)+'.dims[1] = n'+string(i)+';']
   //## add complex number
   //## arbitrary data type should be done.
   if capt(i,5) == 11 then // cmplx case
     Code=[Code
           '  if ((in_'+string(i)+'.data = (double *) malloc(in_'+string(i)+'.ndata*'+...
                 'in_'+string(i)+'.dims[0]*in_'+string(i)+'.dims[1]*2*sizeof(double)))==NULL){']
   else
     Code=[Code
           '  if ((in_'+string(i)+'.data = (double *) malloc(in_'+string(i)+'.ndata*'+...
                 'in_'+string(i)+'.dims[0]*in_'+string(i)+'.dims[1]*sizeof(double)))==NULL){']
   end

   for j=1:i
     Code=[Code
           '    free(in_'+string(j)+'.dims);']
   end

   Code=[Code
         '    return 0;'
         '  }'
         '  if ((in_'+string(i)+'.dims[0] == 1) &&  (in_'+string(i)+'.dims[1] != 1)) {'
         '    for(i=0;i<in_'+string(i)+'.ndata;i++) {'
         '      for(j=0;j<in_'+string(i)+'.dims[1];j++) {'
         '         *((double *)in_'+string(i)+'.data + i*in_'+string(i)+'.dims[1] + j) = \'
         '             *((double *) stk(l'+string(i)+') + j*in_'+string(i)+'.ndata + i);']

   if capt(i,5) == 11 then // cmplx case
     Code=[Code
           '         *((double *)in_'+string(i)+'.data + i*in_'+string(i)+'.dims[1] + j + '+...
                       'in_'+string(i)+'.dims[0]*in_'+string(i)+'.dims[1]) = \'
           '             *((double *) stk(l'+string(i)+') + j*in_'+string(i)+'.ndata + i + '+...
                       'in_'+string(i)+'.dims[0]*in_'+string(i)+'.dims[1]);']
   end

   Code=[Code
         '      }'
         '    }'
         '  }'
         '  else {']

   if capt(i,5) == 11 then // cmplx case
     Code=[Code
           '    for(i=0;i<in_'+string(i)+'.ndata*in_'+string(i)+'.dims[0]*in_'+string(i)+'.dims[1]*2;i++) {'
           '      *((double *)in_'+string(i)+'.data + i) = *((double *) stk(l'+string(i)+') + i);'
           '    }']
   else
     Code=[Code
           '    for(i=0;i<in_'+string(i)+'.ndata*in_'+string(i)+'.dims[0]*in_'+string(i)+'.dims[1];i++) {'
           '      *((double *)in_'+string(i)+'.data + i) = *((double *) stk(l'+string(i)+') + i);'
           '    }']
   end

   Code=[Code
         '  }'
         ''];
 end

 //## actuators
 for i=1:nbact
   //## out_x.dims
   Code=[Code
         '  /* inform out struct of actuator '+string(i)+' */'
         '  out_'+string(i)+'.typ       = '+string(actt(i,5))+';'
         '  out_'+string(i)+'.ndims     = 2;'
         '  out_'+string(i)+'.ndata     = 1000; /* default buffer size */'
         '  if ((out_'+string(i)+'.dims = (int *) malloc(out_'+string(i)+'.ndims*sizeof(int)))==NULL){'];
   for j=1:nbcapt
     Code=[Code
           '    free(in_'+string(j)+'.data);'
           '    free(in_'+string(j)+'.dims);'];
   end

   for j=1:i-1
     Code=[Code
           '    free(out_'+string(j)+'.dims);'
           '    free(out_'+string(j)+'.data);'
           '    free(out_'+string(j)+'.time);'];
   end

   Code=[Code
         '    return 0;'
         '  }']

   //## out_x.data
   Code=[Code
         '  out_'+string(i)+'.dims[0]   = '+string(actt(i,3))+';'
         '  out_'+string(i)+'.dims[1]   = '+string(actt(i,4))+';'
         '  out_'+string(i)+'.data      = NULL;']

   if actt(i,5) == 11 then // cmplx case
     Code=[Code
           '  if ((out_'+string(i)+'.data = (double *) realloc(out_'+string(i)+'.data, \'
           '       out_'+string(i)+'.ndata*'+...
            'out_'+string(i)+'.dims[0]*out_'+string(i)+'.dims[1]'+'*sizeof(double)*2))==NULL){'];
   else
     Code=[Code
           '  if ((out_'+string(i)+'.data = (double *) realloc(out_'+string(i)+'.data, \'
           '       out_'+string(i)+'.ndata*'+...
            'out_'+string(i)+'.dims[0]*out_'+string(i)+'.dims[1]'+'*sizeof(double)))==NULL){'];
   end

   for j=1:nbcapt
     Code=[Code
           '    free(in_'+string(j)+'.data);'
           '    free(in_'+string(j)+'.dims);'];
   end

   for j=1:i-1
     Code=[Code
           '    free(out_'+string(j)+'.dims);'
           '    free(out_'+string(j)+'.data);'
           '    free(out_'+string(j)+'.time);'];
   end

   Code=[Code
         '    free(out_'+string(i)+'.dims);']


   Code=[Code
         '    return 0;'
         '  }']

   //## out_x.time
   Code=[Code
         '  out_'+string(i)+'.time      = NULL;'
         '  if ((out_'+string(i)+'.time = (double *) realloc(out_'+string(i)+'.time,'+...
                 'out_'+string(i)+'.ndata*sizeof(double)))==NULL){'];
   for j=1:nbcapt
     Code=[Code
           '    free(in_'+string(j)+'.data);'
           '    free(in_'+string(j)+'.dims);'];
   end

   for j=1:i-1
     Code=[Code
           '    free(out_'+string(j)+'.dims);'
           '    free(out_'+string(j)+'.data);'
           '    free(out_'+string(j)+'.time);'];
   end

   Code=[Code
         '    free(out_'+string(i)+'.dims);'
         '    free(out_'+string(i)+'.data);'];

   Code=[Code
         '    return 0;'
         '  }'
         ''
        ];
 end

 //## store ptr of sensors/actuators
 if nbact<>0 & nbcapt<>0 then
   Code=[Code
         '  /* store ptr of sensors/actuators in inptr/outptr */']
 elseif nbcapt<>0 then
   Code=[Code
         '  /* store ptr of sensors in inptr */']
 elseif nbact<>0 then
   Code=[Code
         '  /* store ptr of actuators in outptr */']
 end

 if nbcapt<>0 then
   for i=1:nbcapt
     Code=[Code;
           '  inptr['+string(i-1)+']  = &in_'+string(i)+';']
   end
 end

 if nbact<>0 then
   for i=1:nbact
     Code=[Code;
           '  outptr['+string(i-1)+'] = &out_'+string(i)+';']
   end
 end

 //## call standalone simulation function
 Code=[Code
       ''
       '  /* call standalone simulation function */'
       '  ierr='+rdnom+'_sim(tf, te, h, solver, typin, inptr, typout, outptr);'
       ''
       '  /* display error message */'
       '  if (ierr!=0) {'
       '    /* standalone still use scicos.c here ! */'
       '    if(ierr!=10) {'
       '      get_err_msg(ierr,err_msg);'
       '    }'
       '    else {'
       '      strcpy(err_msg,coserr.buf);'
       '    }'
       '    sciprint(""Simulation fails with error number %d :'+...
             '\n%s\n"",ierr,err_msg);'
       '  }'
      ]

 //## create Lhsvar (actuators)
 if nbact<>0 then
   Code=[Code
         ''
         '  /* Create LhsVar */']

   for i=1:nbact
     //## str for stack handling
     i_str = string(i+nbcapt+4);
     m_str = 'm'+string(i+nbcapt+4);
     n_str = 'n'+string(i+nbcapt+4);
     l_str = 'l'+string(i+nbcapt+4);

     Code=[Code
           '  /* actuator '+string(i)+' */'
           '  CreateVar('+i_str+', ""m"", &mL, &nL, &lL);              /* mlist */'
           '  CreateListVarFromPtr('+i_str+',1,""S"", &nL, &mL, Str);  /* str of scicos signal */'
           '  CreateListVarFromPtr('+i_str+',2,""I"", &M.m, &M.n, &M); /* def dims of mlist */'
           '  '+m_str+'=out_'+string(i)+'.ndata;']

     Code=[Code
           '  /* vector case */'
           '  if ((out_'+string(i)+'.dims[0]==1 && out_'+string(i)+'.dims[1]!=1) || \'
           '      (out_'+string(i)+'.dims[0]!=1 && out_'+string(i)+'.dims[1]==1)) {'
           '    if (out_'+string(i)+'.dims[0]!=1) {'
           '      '+n_str+'=out_'+string(i)+'.dims[0];'
           '    }'
           '    else {'
           '      '+n_str+'=out_'+string(i)+'.dims[1];'
           '    }'
           '    /*transpose output */']

     if actt(i,5) == 11 then // cmplx case
       Code=[Code
             '    if ((out_ptr'+string(i)+' = (double *) malloc('+m_str+'*'+n_str+'*2*sizeof(double)))==NULL){']
     else
       Code=[Code
             '    if ((out_ptr'+string(i)+' = (double *) malloc('+m_str+'*'+n_str+'*sizeof(double)))==NULL){']
     end

     if nbcapt<>0 then
       for j=1:nbcapt
         Code=[Code
               '      free(in_'+string(j)+'.data);'
               '      free(in_'+string(j)+'.dims);'];
       end
     end
     for j=1:nbact
       Code=[Code
             '      free(out_'+string(j)+'.dims);'
             '      free(out_'+string(j)+'.data);'
             '      free(out_'+string(j)+'.time);'];
     end
     for ii=1:i-1
       Code=[Code
             '      if((out_'+string(ii)+'.dims[0]!=1) || (out_'+string(ii)+'.dims[1]!=1)) {'
             '        free(out_ptr'+string(ii)+');'
             '      }']
     end

     Code=[Code
           '      return 0;'
           '    }'
           '    for(i=0;i<'+m_str+';i++) {'
           '      for(j=0;j<'+n_str+';j++) {'
           '        *((double *)out_ptr'+string(i)+' + j*'+m_str+' + i) = *((double *) out_'+string(i)+'.data + i*'+n_str+' + j);']

     if actt(i,5) == 11 then // cmplx case
       Code=[Code
             '        *((double *)out_ptr'+string(i)+' + j*'+m_str+' + i + m7*n7) = *((double *) out_'+string(i)+'.data + i*'+n_str+' + j + m7*n7);']
     end

     Code=[Code
           '      }'
           '    }']

     if actt(i,5) == 11 then // cmplx case
       Code=[Code
             '   {'
             '     int it=1;'
             '     double *ptr_d = ((double*) out_ptr'+string(i)+' + m7*n7);'
             '     CreateListCVarFromPtr('+i_str+',3,""d"", &it, &'+m_str+', &'+n_str+', &out_ptr'+string(i)+', &ptr_d);   /* data */'
             '   }']
     else
       Code=[Code
             '    CreateListVarFromPtr('+i_str+',3,""d"", &'+m_str+', &'+n_str+', &out_ptr'+string(i)+');   /* data */']
     end

     Code=[Code
           '  }'
           '  else {'
           '    /* scalar case */'
           '    if (out_'+string(i)+'.dims[0]==1 && out_'+string(i)+'.dims[1]==1) {']

     if actt(i,5) == 11 then // cmplx case
       Code=[Code
             '      '+n_str+'=1;'
             '      int it=1;'
             '      double *ptr_d = ((double*) out_'+string(i)+'.data + m7*n7);'
             '      CreateListCVarFromPtr('+i_str+',3,""d"", &it, &'+m_str+', &'+n_str+', &out_'+string(i)+'.data, &ptr_d);   /* data */']
     else
       Code=[Code
             '      '+n_str+'=1;'
             '      CreateListVarFromPtr('+i_str+',3,""d"", &'+m_str+', &'+n_str+', &out_'+string(i)+'.data);   /* data */']
     end

     Code=[Code
           '    }'
           '    /* matrix case : TODO'
           '     * note that for that time,'
           '     * matrix are concatened in vectors.'
           '     */'
           '    else {']
           '      '

     Code=[Code
           '      '+n_str+'=out_'+string(i)+'.dims[0]*out_'+string(i)+'.dims[1];'
           '      /*transpose output */']

     if actt(i,5) == 11 then // cmplx case
       Code=[Code
             '      if ((out_ptr'+string(i)+' = (double *) malloc('+m_str+'*'+n_str+'*2*sizeof(double)))==NULL){'];
     else
       Code=[Code
             '      if ((out_ptr'+string(i)+' = (double *) malloc('+m_str+'*'+n_str+'*sizeof(double)))==NULL){'];
     end

     if nbcapt<>0 then
       for j=1:nbcapt
         Code=[Code
               '        free(in_'+string(j)+'.data);'
               '        free(in_'+string(j)+'.dims);'];
       end
     end
     for j=1:nbact
       Code=[Code
             '        free(out_'+string(j)+'.dims);'
             '        free(out_'+string(j)+'.data);'
             '        free(out_'+string(j)+'.time);'];
     end
     for ii=1:i-1
       Code=[Code
             '        if((out_'+string(ii)+'.dims[0]!=1) || (out_'+string(ii)+'.dims[1]!=1)) {'
             '          free(out_ptr'+string(ii)+');'
             '        }']
     end

     Code=[Code
           '        return 0;'
           '      }'
           '      for(i=0;i<'+m_str+';i++) {'
           '        for(j=0;j<'+n_str+';j++) {'
           '          *((double *)out_ptr'+string(i)+' + j*'+m_str+' + i) = *((double *) out_'+string(i)+'.data + i*'+n_str+' + j);'];
     if actt(i,5) == 11 then // cmplx case
       Code=[Code
             '        *((double *)out_ptr'+string(i)+' + j*'+m_str+' + i + m7*n7) = *((double *) out_'+string(i)+'.data + i*'+n_str+' + j + m7*n7);']
     end

     Code=[Code
           '        }'
           '      }']

     if actt(i,5) == 11 then // cmplx case
       Code=[Code
             '     {'
             '       int it=1;'
             '       double *ptr_d = ((double*) out_ptr'+string(i)+' + m7*n7);'
             '       CreateListCVarFromPtr('+i_str+',3,""d"", &it, &'+m_str+', &'+n_str+', &out_ptr'+string(i)+', &ptr_d);   /* data */'
             '     }']
     else
       Code=[Code
             '      CreateListVarFromPtr('+i_str+',3,""d"", &'+m_str+', &'+n_str+', &out_ptr'+string(i)+');   /* data */']
     end


     Code=[Code
           '    }'
           '  }']

     //## event date
     Code=[Code
           '  '+n_str+'=1;'
           '  CreateListVarFromPtr('+i_str+',4,""d"", &'+m_str+', &'+n_str+...
              ', &out_'+string(i)+'.time);   /* event date */'
           '  /* Many thing to do */'
           ''];
   end
 end

 //## put LhsVar
 if nbact<>0 then
   Code=[Code
         '  /* Put LhsVar */']

   for i=1:nbact
     Code=[Code
           '  LhsVar('+string(i)+')='+string(i+nbcapt+4)+';']
   end
 end

 //## free allocated array
 //## array of sensors
 if nbcapt<>0 | nbact<>0 then
   Code=[Code
         ''
         '  /* free allocated array */'];
 end

 if nbcapt<>0 then
   for i=1:nbcapt
     Code=[Code
           '  free(in_'+string(i)+'.data);'
           '  free(in_'+string(i)+'.dims);'];
   end
 end

 //## array of actuators
 if nbact<>0 then
   Code=[Code
         ''];
   for i=1:nbact
     Code=[Code
           '  free(out_'+string(i)+'.dims);'];
   end

   for i=1:nbact
     Code=[Code
           '  free(out_'+string(i)+'.data);'];
   end

   for i=1:nbact
     Code=[Code
           '  free(out_'+string(i)+'.time);'];
   end

   for i=1:nbact
     n_str = 'n'+string(i+nbcapt+4);
     Code=[Code
           '  if ('+n_str+' != 1) {'
           '    free(out_ptr'+string(i)+');'
           '  }']

   end

 end

 //## end
 Code=[Code;
       '  return 0;'
       '}'
       '']

 //## Gateway
 Code=[Code;
       'static GenericTable Tab[]='
       '{'
       ' {(Myinterfun)sci_gateway,int'+part(rdnom,1:l_rdnom)+'_sci,'
       ' """+rdnom+"""}'
       '};'
       ''
       'int C2F(int'+part(rdnom,1:l_rdnom)+'_sci)()'
       '{'
       ' Rhs = Max(0, Rhs);'
       ' (*(Tab[Fin-1].f))(Tab[Fin-1].name,Tab[Fin-1].F);'
       ' return 0;'
       '}'
       '']

endfunction

function [Code]=make_sensor()
//Copyright (c) 1989-2010 Metalau project INRIA

//@@ make_sensor : Generates the routine for sensors
//                 for standalone
//
// Output : Code : text of the generated routine
//

  //## function prototype
  Call=['/*'+part('-',ones(1,40))+' Sensors */';
        'void '+rdnom+'_sensor(flag,nport,nevprt,t,y,ny1,ny2,yt,typin,inptr)']

  //## add comments
  comments=['     /*'
            '      * To be customized for standalone execution';
            '      * flag  : specifies the action to be done'
            '      * nport : specifies the  index of the super-block'
            '      *         regular input (The input ports are numbered'
            '      *         from the top to the bottom )'
            '      * nevprt: indicates if an activation had been received'
            '      *         0 = no activation'
            '      *         1 = activation'
            '      * t     : the current time value'
            '      * y     : the vector outputs value'
            '      * ny1   : the output size 1'
            '      * ny2   : the output size 2'
            '      * yt    : the output type'
            '      * typin : learn mode (0 from terminal,1 from input file)'
            '      * inptr : pointer to out data'
            '      *          typin=0, inptr not used'
            '      *          typin=1, inptr contains the input file name'
            '      */']

  //## variables declaration
  dcl=['     int *flag,*nevprt,*nport;'
       '     int *ny1,*ny2,*yt;'
       ''
       '     int typin;'
       '     void *inptr;'
       ''
       '     double *t;'
       '     void *y;'
       '{'
       '  int j,k,l;'
       '  double temps;'
       '  char *file_str;'
       '  char buf[1024];']

  //## code for terminal
  a_sensor=['    /* skeleton to be customized */'
            '    switch (*flag) {'
            '    case 4 : /* sensor initialisation */'
            '      /* do whatever you want to initialize the sensor */'
            '      break;'
            '    case 1 : /* set the output value */'
            '      printf(""Require outputs of sensor number %d\n"", *nport);'
            '      printf(""time is: %f\n"", *t);'
            '      printf(""sizes of the sensor output is: %d,%d\n"", *ny1,*ny2);'
            '      switch (*yt) {'
            '      case 10 :'
            '        printf(""type of the sensor output is: %d (double) \n"", *yt);'
            '        puts(""Please set the sensor output values"");'
            '        for (l=0;l<*ny2;l++) {'
            '          for (k=0;k<*ny1;k++) {'
            '            printf(""y(%d,%d) : "",k,l);'
            '            scanf(""%lf"", (double *) y+(k+l*(*ny1)));'
            '          }'
            '        }'
            '        break;'
            ''
            '      case 11 :'
            '        printf(""type of the sensor output is: %d (complex) \n"", *yt);'
            '        puts(""Please set the sensor output values"");'
            '        for (l=0;l<*ny2;l++) {'
            '          for (k=0;k<*ny1;k++) {'
            '            printf(""y(%d,%d) real part : "",k,l);'
            '            scanf(""%lf"", (double *) y+(k+l*(*ny1)));'
            '            printf(""y(%d,%d) imag part : "",k,l);'
            '            scanf(""%lf"", (double *) y+((*ny1)*(*ny2)+k+l*(*ny1)));'
            '          }'
            '        }'
            '        break;'
            ''
            '      case 81 :'
            '        printf(""type of the sensor output is: %d (char) \n"", *yt);'
            '        puts(""Please set the sensor output values"");'
            '        for (l=0;l<*ny2;l++) {'
            '          for (k=0;k<*ny1;k++) {'
            '            printf(""y(%d,%d) : "",k,l);'
            '            scanf(""%i"", &j);'
            '            *((char *) y+(k+l*(*ny1))) = (char) j;'
            '          }'
            '        }'
            '        break;'
            ''
            '      case 82 :'
            '        printf(""type of the sensor output is: %d (char) \n"", *yt);'
            '        puts(""Please set the sensor output values"");'
            '        for (l=0;l<*ny2;l++) {'
            '          for (k=0;k<*ny1;k++) {'
            '            printf(""y(%d,%d) : "",k,l);'
            '            scanf(""%hd"", (short *) y+(k+l*(*ny1)));'
            '          }'
            '        }'
            '        break;'
            ''
            '      case 84 :'
            '        printf(""type of the sensor output is: %d (long) \n"", *yt);'
            '        puts(""Please set the sensor output values"");'
            '        for (l=0;l<*ny2;l++) {'
            '          for (k=0;k<*ny1;k++) {'
            '            printf(""y(%d,%d) : "",k,l);'
            '            scanf(""%ld"", (long *) y+(k+l*(*ny1)));'
            '          }'
            '        }'
            '        break;'
            ''
            '      case 811 :'
            '        printf(""type of the sensor output is: %d (unsigned char) \n"", *yt);'
            '        puts(""Please set the sensor output values"");'
            '        for (l=0;l<*ny2;l++) {'
            '          for (k=0;k<*ny1;k++) {'
            '            printf(""y(%d,%d) : "",k,l);'
            '            scanf(""%d"", &j);'
            '            *((unsigned char *) y+(k+l*(*ny1))) = (unsigned char) j;'
            '          }'
            '        }'
            '        break;'
            ''
            '      case 812 :'
            '        printf(""type of the sensor output is: %d (unsigned short) \n"", *yt);'
            '        puts(""Please set the sensor output values"");'
            '        for (l=0;l<*ny2;l++) {'
            '          for (k=0;k<*ny1;k++) {'
            '            printf(""y(%d,%d) : "",k,l);'
            '            scanf(""%hu"", (unsigned short *) y+(k+l*(*ny1)));'
            '          }'
            '        }'
            '        break;'
            ''
            '      case 814 :'
            '        printf(""type of the sensor output is: %d (unsigned long) \n"", *yt);'
            '        puts(""Please set the sensor output values"");'
            '        for (l=0;l<*ny2;l++) {'
            '          for (k=0;k<*ny1;k++) {'
            '            printf(""y(%d,%d) : "",k,l);'
            '            scanf(""%lu"", (unsigned long *) y+(k+l*(*ny1)));'
            '          }'
            '        }'
            '        break;'
            ''
            '      }'
            '      break;'
            '    case 5 : /* sensor ending */'
            '      /* do whatever you want to end the sensor */'
            '      break;'
            '    }']

  //## code for input file
  b_sensor=['    /* skeleton to be customized */'
            '    switch (*flag) {'
            '    case 4 : /* sensor initialisation */'
            '      /* use separate files for sensors */'
            '      file_str = (char *) inptr;'
            '      l = 0;'
            ''
            '      /* look at for an extension */'
            '      for(k=strlen(file_str);k>=0;k--) {'
            '        if (file_str[k] == ''.'') {'
            '          l = k;'
            '          break;'
            '         }'
            '       }'
            ''
            '       /* if an extension is found, then add suffixe just before */'
            '       if (l !=0 ) {'
            '         j = 0;'
            '         for (k=0;k<l;k++) {'
            '           buf[j] = file_str[k];'
            '           j++;'
            '         }'
            '         buf[j] = ''_'';'
            '         j++;'
            '         buf[j] = ''\0'';'
            '         sprintf(buf,'"%s%d'",buf,*nport);'
            '         strcat(buf,&file_str[l]);'
            '       }'
            '       else {'
            '         sprintf(buf,'"%s_%d'",file_str,*nport);'
            '       }'
            ''
            '      /* open file */'
            '      fprr_1 = fopen(buf,'"r'");'
            '      if( fprr_1 == NULL ) {'
            '        fprintf(stderr,'"Error opening file: %s\n'", buf);'
            '        /* internal error */'
            '        *flag=-3;'
            '        return;'
            '      }'
            '      break;'
            '    case 1 : /* fscanf the output value */'
            '    /*if(*nevprt>0) {*/'
            '      /* read time */'
            '      fscanf(fprr_1,""%lf "",&temps);'
            ''
            '      switch (*yt) {'
            '      case 10 :'
            '        for (l=0;l<*ny2;l++) {'
            '          for (k=0;k<*ny1;k++) {'
            '            fscanf(fprr_1,""%lf "", \'
            '                        (double *) y+(k+l*(*ny1)));'
            '          }'
            '        }'
            '        fscanf(fprr_1,""\n"");'
            '        break;'
            ''
            '      case 11 :'
            '        for (l=0;l<*ny2;l++) {'
            '          for (k=0;k<*ny1;k++) {'
            '            fscanf(fprr_1,""%lf "" \'
            '                        ""%lf "", \'
            '                        (double *) y+(k+l*(*ny1)), \'
            '                        (double *) y+((*ny1)*(*ny2)+k+l*(*ny1)));'
            '          }'
            '        }'
            '        fscanf(fprr_1,""\n"");'
            '        break;'
            ''
            '      case 81 :'
            '        for (l=0;l<*ny2;l++) {'
            '          for (k=0;k<*ny1;k++) {'
            '            fscanf(fprr_1,""%i "", \'
            '                        &j);'
            '            *((char *) y+(k+l*(*ny1))) = (char) j;'
            '          }'
            '        }'
            '        fscanf(fprr_1,""\n"");'
            '        break;'
            ''
            '      case 82 :'
            '        for (l=0;l<*ny2;l++) {'
            '          for (k=0;k<*ny1;k++) {'
            '            fscanf(fprr_1,""%hd "", \'
            '                        (short *) y+(k+l*(*ny1)));'
            '          }'
            '        }'
            '        fscanf(fprr_1,""\n"");'
            '        break;'
            ''
            '      case 84 :'
            '        for (l=0;l<*ny2;l++) {'
            '          for (k=0;k<*ny1;k++) {'
            '            fscanf(fprr_1,""%ld "", \'
            '                        (long *) y+(k+l*(*ny1)));'
            '          }'
            '        }'
            '        fscanf(fprr_1,""\n"");'
            '        break;'
            ''
            '      case 811 :'
            '        for (l=0;l<*ny2;l++) {'
            '          for (k=0;k<*ny1;k++) {'
            '            fscanf(fprr_1,""%d "", &j);'
            '            *((unsigned char *) y+(k+l*(*ny1))) = (unsigned char) j;'
            '          }'
            '        }'
            '        fscanf(fprr_1,""\n"");'
            '        break;'
            ''
            '      case 812 :'
            '        for (l=0;l<*ny2;l++) {'
            '          for (k=0;k<*ny1;k++) {'
            '            fscanf(fprr_1,""%hu "", \'
            '                        (unsigned short *) y+(k+l*(*ny1)));'
            '          }'
            '        }'
            '        fscanf(fprr_1,""\n"");'
            '        break;'
            ''
            '      case 814 :'
            '        printf(""type of the sensor output is: %d (unsigned long) \n"", *yt);'
            '        puts(""Please set the sensor output values"");'
            '        for (l=0;l<*ny2;l++) {'
            '          for (k=0;k<*ny1;k++) {'
            '            fscanf(fprr_1,""%lu "", \'
            '                        (unsigned long *) y+(k+l*(*ny1)));'
            '          }'
            '        }'
            '        fscanf(fprr_1,""\n"");'
            '        break;'
            '      }'
            '    /*} */'
            '      break;'
            '    case 5 : /* sensor ending */'
            '      fclose(fprr_1);'
            '      /* do whatever you want to end the sensor */'
            '      break;'
            '    }']

  //@@ main text generation
  nc=size(cap,'*')
  Code=[]

  if nc==1 then
    Code=[Code;
          Call
          comments
          dcl
          '  if (typin == 0) {'
          a_sensor;
          '  } '
          '  else if (typin == 1) {'
          b_sensor;
          '  }'
          '}']
  elseif nc>1 then
    S='    switch (*nport) {'
    for k=1:nc
      S=[S;
         '    case '+string(k)+' : /* Port number '+string(k)+' ----------*/'
         '    '+a_sensor
         '    break;']
    end
    S=[S;'    }']

    T='    switch (*nport) {'
    for k=1:nc
      T=[T;
         '    case '+string(k)+' :/* Port number '+string(k)+' ----------*/'
         '    '+strsubst(b_sensor,'fprr_1','fprr_'+string(k))
         '    break;']
    end
    T=[T;'    }']

    Code=[Code
          Call
          comments
          dcl
          '  if (typin == 0) {'
          S
          '  }'
          '  else if (typin == 1) {'
          T
          '  }'
          '}']
  end
endfunction

function [Code]=make_standalone42()
//Copyright (c) 1989-2010 Metalau project INRIA

//@@ make_standalone42() : generates code of the standalone simulation procedure
//
// Output : Code : text of the generated routines
//
// rmk : zdoit is not used
//

  x=cpr.state.x;
  modptr=cpr.sim.modptr;
  rpptr=cpr.sim.rpptr;
  ipptr=cpr.sim.ipptr;
  opptr=cpr.sim.opptr;
  rpar=cpr.sim.rpar;
  ipar=cpr.sim.ipar;
  opar=cpr.sim.opar;
  oz=cpr.state.oz;
  ordptr=cpr.sim.ordptr;
  oord=cpr.sim.oord;
  zord=cpr.sim.zord;
  iord=cpr.sim.iord;
  tevts=cpr.state.tevts;
  evtspt=cpr.state.evtspt;
  zptr=cpr.sim.zptr;
  ozptr=cpr.sim.ozptr;
  clkptr=cpr.sim.clkptr;
  ordptr=cpr.sim.ordptr;
  pointi=cpr.state.pointi;
  funs=cpr.sim.funs;
  funtyp=cpr.sim.funtyp;
  noord=size(cpr.sim.oord,1);
  nzord=size(cpr.sim.zord,1);
  niord=size(cpr.sim.iord,1);

  Indent='  ';
  Indent2=Indent+Indent;
  BigIndent='          ';

  nX=size(x,'*');

  stalone = %t;

  //** evs : find source activation number
  //## with_nrd2 : find blk type 0 (wihtout)
  blks=find(funtyp>-1);
  evs=[];

  with_nrd2=%f;
  if ~ALL then
    for blk=blks
      for ev=clkptr(blk):clkptr(blk+1)-1
        if funs(blk)=='bidon' then
          if ev > clkptr(howclk) -1
           evs=[evs,ev];
          end
        end
      end

      //## all blocks without sensor/actuator
      if (part(funs(blk),1:7) ~= 'capteur' &...
          part(funs(blk),1:10) ~= 'actionneur' &...
          funs(blk) ~= 'bidon') then
        //## with_nrd2 ##//
        if funtyp(blk)==0 then
          with_nrd2=%t;
        end
      end
    end
  else
    for blk=blks
      for ev=clkptr(blk):clkptr(blk+1)-1
        if funs(blk)=='agenda_blk' then
          nb_agenda_blk=blk
          //if ev > clkptr(howclk) -1
          evs=[evs,ev];
         //end
        end
      end
      //## all blocks without sensor/actuator
      if (part(funs(blk),1:7) ~= 'capteur' &...
          part(funs(blk),1:10) ~= 'actionneur' &...
          funs(blk) ~= 'bidon') then
        //## with_nrd2 ##//
        if funtyp(blk)==0 then
          with_nrd2=%t;
        end
      end
    end
  end

  Code=['/* Code prototype for standalone use  */'
        '/*     Generated by Code_Generation toolbox of Scicos with '+ ..
        get_scicos_version()+' */'
        '/*     date : '+date()+' */'
        ''
        '/* Copyright (c) 1989-2010 Metalau project INRIA */'
        ''
        '/* To learn how to use the standalone code, type '"./standalone -h'" */'
        ''
        '/* ---- Headers ---- */'
        '#include <stdio.h>'
        '#include <stdlib.h>'
        '#include <math.h>'
        '#include <string.h>'
        '#ifdef __STDC__'
        '#include <stdarg.h>'
        '#else'
        '#include <varargs.h>'
        '#endif'
        '#include <memory.h>'
        '#include '"scicos_block4.h'"'
        '#include '"machine.h'"'
        ''
        '/* ---- Internals functions and global variables declaration ---- */'
        Protostalone
        '']

  Code=[Code
        '/* prototype for input simulation function */'
        'int '+rdnom+'_sim(double, double, double, int, \'
        '                  int *, void **, int *, void **);'
        '']

  //@@ cosend function declaration
  Code=[Code
        '/* ----  Prototype for cosend function ----  */'
        'int '+rdnom+'_cosend();'
        '']

  if ALL & size(evs,'*')<>0 then
    Code=[Code;
          ''
          '/* define agenda struct */'
          'typedef struct {'
          '  int pointi;'
          '  int fromflag3;'
          '  int old_pointi;'
          '  int evtspt['+string(size(evs,'*'))+'];'
          '  double tevts['+string(size(evs,'*'))+'];'
          '} agenda_struct ;'
          ''
          '/* prototype of addevs function */'
          'void '+rdnom+'_addevs(agenda_struct *, double, int);'
         ]
  end

  if x<>[] then
    if impl_blk then
      Code=[Code
            '/* ---- Solver functions prototype for standalone use ---- */'
            'int '+rdnom+'simblk_imp(double , double *, double *, double *);'
            'int dae1();'
            '']
    else
      Code=[Code
            '/* ---- Solver functions prototype for standalone use ---- */'
            'int '+rdnom+'simblk(double , double *, double *);'
            'int ode1();'
            'int ode2();'
            'int ode4();'
            '']
    end
  end

  Code=[Code;
        '/* ---- Specific declaration for the main() function ---- */'
        'int getopt (int, char **, char *);'
        'static int optind = 1;'
        'static void usage(char *);'
        '']


  //## add a C macro for cosend
  //## to properly handle error in standalone
  Code_end=[''
            '  '+get_comment('flag',list(5))]

  for kf=1:nblk
    if or(kf==act) | or(kf==cap) then
        txt = call_block42(kf,0,5);
        if txt <> [] then
          Code_end=[Code_end;
                    '';
                    '  '+txt];
        end
    else
      txt = call_block42(kf,0,5);
      if txt <> [] then
        Code_end=[Code_end;
                  '';
                  '  '+txt];
      end
    end
  end

  Code_end_mac = ['#define Cosend() '+Code_end(1)+'\']
  for i=2:size(Code_end,1)
    if i<>size(Code_end,1) then
      len=length(Code_end(i))
      if len <> 0 then
        if part(Code_end(i),len)<>'\' then
           Code_end_mac($+1) = Code_end(i) + '\'
        else
           Code_end_mac($+1) = Code_end(i)
        end
      else
        Code_end_mac($+1) = '  \'
      end
    else
      Code_end_mac($+1) = Code_end(i)
    end
  end
  //Code_end_mac = [Code_end_mac;Code_end($)]

//   Code=[Code;
//         '/* Define Cosend macro */'
//         Code_end_mac
//         '  \'
//         '  return get_block_error()'
//         '']

//@@ Cosend in a function
  Code_end_fun=['/*'+part('-',ones(1,40))+' Cosend function */'
                'int '+rdnom+'_cosend()'
                '{'
                '  /* local variables used to call block */'
                '  int local_flag,i;']
  if act<>[] | cap<>[] then
    Code_end_fun=[Code_end_fun;
                  '  int nport;']
  end
  if (with_nrd & with_nrd2) then
    Code_end_fun=[Code_end_fun;
                  ''
                  '  /* Variables for constant values */'
                  '  int nrd_1, nrd_2;'
                  '  double *args[100];']
  end
  Code_end_fun=[Code_end_fun;
                ''
                '  double t;'
                ''
                '  /* get scicos_time */'
                '  t = scicos_time;']

  Code_end_fun=[Code_end_fun
                Code_end
                ''
                '  /* return block_error */'
                '  return get_block_error();'
                '}']

//   Code=[Code;
//         '/* Define Cosend macro */'
//         Code_end_mac
//         '']

  //*** Continuous state ***//
  if x <> [] then
    //## implicit block
    if impl_blk then
      Code=[Code;
            '/* def number of continuous state */'
            '#define NEQ '+string(nX/2)
            '']
    //## explicit block
    else
      Code=[Code;
            '/* def number of continuous state */'
            '#define NEQ '+string(nX)
            '']
    end
  end

  Code=[Code;
        '/* def phase sim variable */'
        'int phase;'
        ''
        '/* a variable for the current time */'
        'double scicos_time;'
        '']

  if impl_blk then
    Code=[Code;
          '/* Jacobian parameters */'
          'double Jacobian_Flag;'
          'double CJJ;'
          'double SQuround;'
          '']
  end

  Code=[Code
        '/* block_error must be pass in argument of _sim function */'
        'int *block_error;'
        'char err_msg[2048];'
        ''
        '/* block_number */'
        'int block_number;'
        ''
        '/* prototype of error table function */'
        'void get_err_msg(int ierr,char *err_msg);'
        '']

  //## rmk: we can remove a 'bidon' structure
  //## sometimes at the end
  if funs(nblk)=='bidon' then nblk=nblk-1, end;

  Code=[Code;
        '/* declaration of scicos block structures */'
        'scicos_block block_'+rdnom+'['+string(nblk)+'];'
        '']

  Code=[Code;
        '/* Main program */'
        'int main(int argc, char *argv[])'
        '{'
        '  /* local variables */'
        '  char input[50],output[50];'
        '  char **p=NULL;'
        ''
        '  /* default values for parameters of _sim function */'
        '  double tf=30;         /* final time */'
        '  double dt=0.1;        /* clock time */'
        '  double h=0.001;       /* solver step */']

  if impl_blk then
    Code=[Code;
       '  int solver=3;         /* type of solver */']
  else
    Code=[Code;
       '  int solver=1;         /* type of solver */']
  end

  Code_in=[]
  if size(capt,1)>0 then
    Code_in='  int nin='+string(size(capt,1))+';'
    Code_in=[Code_in;
             cformatline('  int typin[]={'+...
                  strcat(string(zeros(size(capt,1),1)),"," )+'};',70)]
    Code_in=[Code_in;
             cformatline('  void *inptr[]={'+...
                  strcat(string(zeros(size(capt,1),1)),"," )+'};',70)]
  end
  if Code_in<>[] then
    Code=[Code;
          '  /* Inputs of sensors */'
          Code_in]
  else
    Code=[Code;
          '  /* Inputs of sensors */'
          '  int nin=0;'
          '  int *typin=NULL;'
          '  void **inptr=NULL;']
  end

  Code_out=[]
  if size(actt,1)>0 then
    Code_out='  int nout='+string(size(actt,1))+';'
    Code_out=[Code_out;
              cformatline('  int typout[]={'+...
                  strcat(string(zeros(size(actt,1),1)),"," )+'};',70)]
    Code_out=[Code_out;
             cformatline('  void *outptr[]={'+...
                  strcat(string(zeros(size(actt,1),1)),"," )+'};',70)]
  end
  if Code_out<>[] then
    Code=[Code;
          '  /* Outputs of actuators */'
          Code_out]
  else
    Code=[Code;
          '  /* Outputs of actuators */'
          '  int nout=0;'
          '  int *typout=NULL;'
          '  void **outptr=NULL;']
  end

  Code=[Code;
        '  /**/'
        '  char * progname = argv[0];'
        '  /* local counter variable */'
        '  int c,i;'
        '  /* error handling variable */'
        '  int ierr;'
        ''
        '  /* init in/output files */'
        '  strcpy(input,'"'");'
        '  strcpy(output,'"'");'
        ''
        '  /* check rhs args */'
        '  while ((c = getopt(argc , argv, '"i:o:d:t:e:s:hv'")) != -1)'
        '    switch (c) {'
        '    case ''i'':'
        '      strcpy(input,argv[optind-1]);'
        '      break;'
        '    case ''o'':'
        '      strcpy(output,argv[optind-1]);'
        '      break;'
        '    case ''d'':'
        '      dt=strtod(argv[optind-1],p);'
        '      break;'
        '    case ''t'':'
        '      tf=strtod(argv[optind-1],p);'
        '      break;'
        '    case ''e'':'
        '      h=strtod(argv[optind-1],p);'
        '      break;'
        '    case ''s'':'
        '      solver=(int) strtod(argv[optind-1],p);'
        '      break;'
        '    case ''h'':'
        '      usage(progname);'
        '      return 0;'
        '      break;'
        '    case ''v'':'
        '      printf(""Generated by Code_Generation toolbox of Scicos ""'
        '             ""with '+get_scicos_version()+'\n"");'
        '      return 0;'
        '      break;'
        '    case ''?'':'
        '      usage(progname);'
        '      return 0;'
        '      break;'
        '    }'
        '']

  Code=[Code;
        '  /* adjust in/out of sensors/actuators */'
        '  if (strlen(input) > 0) {'
        '    for(i=0;i<nin;i++) {'
        '      typin[i]= 1;'
        '      inptr[i]= (void *) input;'
        '    }'
        '  }'
        '  if (strlen(output)> 0) {'
        '    for(i=0;i<nout;i++) {'
        '      typout[i]= 1;'
        '      outptr[i]= (void *) output;'
        '    }'
        '  }'
        '']

  Code=[Code;
        '  /* call simulation function */'
        '  ierr='+rdnom+'_sim(tf,dt,h,solver,typin,inptr,typout,outptr);'
        ''
        '  /* display error message */'
        '  if (ierr!=0) {'
        '    get_err_msg(ierr,err_msg);'
        '    fprintf(stderr,""Simulation fails with error number %d :'+...
             '\n%s\n"",ierr,err_msg);'
        '  }'
        ''
        '  return ierr;'
        '}'
        '']

  Code=[Code;
        '/* Error table function */'
        'void get_err_msg(int ierr,char *err_msg)'
        '{'
        '  switch (ierr)'
        '  {'
        '   case 1  : strcpy(err_msg,""scheduling problem"");'
        '             break;'
        ''
        '   case 2  : strcpy(err_msg,""input to zero-crossing stuck on zero"");'
        '             break;'
        ''
        '   case 3  : strcpy(err_msg,""event conflict"");'
        '             break;'
        ''
        '   case 4  : strcpy(err_msg,""algrebraic loop detected"");'
        '             break;'
        ''
        '   case 5  : strcpy(err_msg,""cannot allocate memory"");'
        '             break;'
        ''
        '   case 6  : strcpy(err_msg,""a block has been called with input out of its domain"");'
        '             break;'
        ''
        '   case 7  : strcpy(err_msg,""singularity in a block"");'
        '             break;'
        ''
        '   case 8  : strcpy(err_msg,""block produces an internal error"");'
        '             break;'
        ''
        '   case 10 : break;'
        ''
        '   /* other scicos error should be done */'
        ''
        '   default : strcpy(err_msg,""undefined error"");'
        '             break;'
        '  }'
        '}'
        '']

  Code=[Code;
        'static void usage(prog)'
        '       char *prog;'
        '{'
        '  fprintf(stderr, ""Usage: %s [-h] [-v] [-i arg] [-o arg] ""'
        '                  ""[-d arg] [-t arg] [-e arg] [-s arg]\n"", prog);'
        '  fprintf(stderr, ""Options : \n"");'
        '  fprintf(stderr, ""     -h for the help  \n"");'
        '  fprintf(stderr, ""     -v for printing the Scicos version \n"");'
        '  fprintf(stderr, ""     -i for input file name, by default is Terminal \n"");'
        '  fprintf(stderr, ""     -o for output file name, by default is Terminal \n"");'
        '  fprintf(stderr, ""     -d for the clock period, by default is 0.1 \n"");'
        '  fprintf(stderr, ""     -t for the final time, by default is 30 \n"");'
        '  fprintf(stderr, ""     -e for the solvers step size, by default is 0.001 \n"");'
        '  fprintf(stderr, ""     -s integer parameter for select the numerical solver : \n"");']

  if impl_blk then
    Code=[Code;
          '  fprintf(stderr, ""        1 for a dae solver... \n"");']
  else
    Code=[Code;
          '  fprintf(stderr, ""        1 for Euler''s method \n"");'
          '  fprintf(stderr, ""        2 for Heun''s method \n"");'
          '  fprintf(stderr, ""        3 (default value) for the Fourth-Order Runge-Kutta'+...
           ' (RK4) Formula \n"");']
  end
  Code=[Code;
        '}'
        '']

  Code=[Code
        '/*'+part('-',ones(1,40))+'  External simulation function */'
        'int '+rdnom+'_sim(tf,dt,h,solver,typin,inptr,typout,outptr)'
        ''
        '   double tf,dt,h;'
        '   int solver;'
        '   int *typin,*typout;'
        '   void **inptr,**outptr;'
        '{'
        '  double t;']

  if ALL & size(evs,'*')<>0 then
    Code=[Code;
          ''
          '  /* agenda struct ptr */'
          '  agenda_struct *ptr;'
          '  int kever;'
          '']
  end

  if ~ALL & evs<>[] then
    Code=[Code
          '  int nevprt=1;']
  end

  Code=[Code
        '  int local_flag;'
        '  int nport;'
        '  int kf;']

  if with_synchro | impl_blk then
    Code=[Code
          '  int i;'
          '']
  else
    Code=[Code
         '']
  end

  if (with_nrd & with_nrd2) then
    Code=[Code;
          '  /* Variables for constant values */'
          '  int nrd_1, nrd_2;'
          ''
          '  double *args[100];'
          '']
  end

  if (x <> []) then
    Code=[Code
          '  double tout;'
          '  double he=0.1;'
          '']
  end

  //## set a variable to trace error of block
  Code=[Code
        '  int err=0;'
        ''
        '  /* Initial values */'
        '']

  //### Real parameters ###//
  if size(rpar,1) <> 0 then
    Code=[Code;
          '  /* Real parameters declaration */']
          //'static double RPAR1[ ] = {'];

    for i=1:(length(rpptr)-1)
      if rpptr(i+1)-rpptr(i)>0  then

        //** Add comments **//

        //## Modelica block
        if type(corinv(i))==15 then
          //## we can extract here all informations
          //## from original scicos blocks with corinv : TODO
          Code($+1)='  /* MODELICA BLK RPAR COMMENTS : TODO */';
        else
          if size(corinv(i),'*')==1 then
            OO=scs_m.objs(corinv(i));
          else
            path=list('objs');
            for l=cpr.corinv(i)(1:$-1)
              path($+1)=l;
              path($+1)='model';
              path($+1)='rpar';
              path($+1)='objs';
            end
            path($+1)=cpr.corinv(i)($);
            OO=scs_m(path);
          end

          Code($+1)='  /* Routine name of block: '+strcat(string(cpr.sim.funs(i)));
          Code($+1)='   * Gui name of block: '+strcat(string(OO.gui));
          Code($+1)='   * Compiled structure index: '+strcat(string(i));

          if stripblanks(OO.model.label)~=emptystr() then
            Code=[Code;
                  '  '+cformatline(' * Label: '+strcat(string(OO.model.label)),70)];
          end
          if stripblanks(OO.graphics.exprs(1))~=emptystr() then
            Code=[Code;
                  '  '+cformatline(' * Exprs: '+strcat(OO.graphics.exprs(1),","),70)];
          end
          if stripblanks(OO.graphics.id)~=emptystr() then
            Code=[Code;
                  '  '+cformatline(' * Identification: '+strcat(string(OO.graphics.id)),70)];
          end
          //txt=[txt;' * rpar='];
          Code($+1)='   */';
        end
        //******************//

        txt=cformatline(strcat(msprintf('%.16g,\n',rpar(rpptr(i):rpptr(i+1)-1))),70);

        txt(1)='double rpar_'+string(i)+'[]={'+txt(1);
        for j=2:size(txt,1)
          txt(j)=get_blank('double rpar_'+string(i)+'[]')+txt(j);
        end
        txt($)=part(txt($),1:length(txt($))-1)+'};'
        Code=[Code;
              '  '+txt
              '']
      end
    end
  end
  //#######################//

  //### Integer parameters ###//
  if size(ipar,1) <> 0 then
    Code=[Code;
          '  /* Integers parameters declaration */']

    for i=1:(length(ipptr)-1)
      if ipptr(i+1)-ipptr(i)>0  then

        //** Add comments **//

        //## Modelica block
        if type(corinv(i))==15 then
          //## we can extract here all informations
          //## from original scicos blocks with corinv : TODO
          Code($+1)='  /* MODELICA BLK IPAR COMMENTS : TODO */';
        else
          if size(corinv(i),'*')==1 then
            OO=scs_m.objs(corinv(i));
          else
            path=list('objs');
            for l=cpr.corinv(i)(1:$-1)
              path($+1)=l
              path($+1)='model'
              path($+1)='rpar'
              path($+1)='objs'
            end
            path($+1)=cpr.corinv(i)($);
            OO=scs_m(path);
          end

          Code($+1)='  /* Routine name of block: '+strcat(string(cpr.sim.funs(i)));
          Code($+1)='   * Gui name of block: '+strcat(string(OO.gui));
          Code($+1)='   * Compiled structure index: '+strcat(string(i));
          if stripblanks(OO.model.label)~=emptystr() then
            Code=[Code;
                  '  '+cformatline(' * Label: '+strcat(string(OO.model.label)),70)];
          end

          if stripblanks(OO.graphics.exprs(1))~=emptystr() then
            Code=[Code;
                  '  '+cformatline(' * Exprs: '+strcat(OO.graphics.exprs(1),","),70)];
          end
          if stripblanks(OO.graphics.id)~=emptystr() then
            Code=[Code;
                  '  '+cformatline(' * Identification: '+strcat(string(OO.graphics.id)),70)];
          end
          Code=[Code;
                '  '+cformatline(' * ipar= {'+strcat(string(ipar(ipptr(i):ipptr(i+1)-1)),",")+'};',70)];
          Code($+1)='   */';
        end
        //******************//

        txt=cformatline(strcat(string(ipar(ipptr(i):ipptr(i+1)-1))+','),70);

        txt(1)='int ipar_'+string(i)+'[]={'+txt(1);
        for j=2:size(txt,1)
          txt(j)=get_blank('int ipar_'+string(i)+'[]')+txt(j);
        end
        txt($)=part(txt($),1:length(txt($))-1)+'};'
        Code=[Code;
              '  '+txt
              '']
      end
    end
  end
  //##########################//

  //### Object parameters ###//

  //** declaration of opar
  Code_opar = [];
  Code_ooparsz=[];
  Code_oopartyp=[];
  Code_oparptr=[];

  for i=1:(length(opptr)-1)
    nopar = opptr(i+1)-opptr(i)
    if nopar>0  then
      //** Add comments **//

      //## Modelica block
      if type(corinv(i))==15 then
        //## we can extract here all informations
        //## from original scicos blocks with corinv : TODO
        Code_opar($+1)='  /* MODELICA BLK OPAR COMMENTS : TODO */';
      else
        //@@ 04/11/08, disable generation of comment for opar
        //@@ for m_frequ because of sample clock
        if funs(i)=='m_frequ' then
        else
          if size(corinv(i),'*')==1 then
            OO=scs_m.objs(corinv(i));
          else
            path=list('objs');
            for l=cpr.corinv(i)(1:$-1)
              path($+1)=l;
              path($+1)='model';
              path($+1)='rpar';
              path($+1)='objs';
            end
            path($+1)=cpr.corinv(i)($);
            OO=scs_m(path);
          end

          Code_opar($+1)='  /* Routine name of block: '+strcat(string(cpr.sim.funs(i)));
          Code_opar($+1)='   * Gui name of block: '+strcat(string(OO.gui));
          Code_opar($+1)='   * Compiled structure index: '+strcat(string(i));
          if stripblanks(OO.model.label)~=emptystr() then
            Code_opar=[Code_opar;
                  '  '+cformatline(' * Label: '+strcat(string(OO.model.label)),70)];
          end
          if stripblanks(OO.graphics.id)~=emptystr() then
            Code_opar=[Code_opar;
                  '  '+cformatline(' * Identification: '+strcat(string(OO.graphics.id)),70)];
          end
          Code_opar($+1)='   */';
        end
      end
      //******************//

      for j=1:nopar
        if mat2scs_c_nb(opar(opptr(i)+j-1)) <> 11 then
          Code_opar =[Code_opar;
                 '  '+cformatline(mat2c_typ(opar(opptr(i)+j-1)) +...
                         ' opar_'+string(opptr(i)+j-1) + '[]={'+...
                             strcat(msprintf('%.16g,\n',opar(opptr(i)+j-1)))+'};',70)]

//        txt=cformatline(strcat( msprintf('%.16g,\n',rpar(rpptr(i):rpptr(i+1)-1)) ),70);

        else //** cmplx test
          Code_opar =[Code_opar;
                 '  '+cformatline(mat2c_typ(opar(opptr(i)+j-1)) +...
                         ' opar_'+string(opptr(i)+j-1) + '[]={'+...
                             strcat(msprintf('%.16g,\n',[real(opar(opptr(i)+j-1)(:));
                                            imag(opar(opptr(i)+j-1)(:))]))+'};',70)]
        end
      end
      Code_opar($+1)='';

      //## size
      Code_oparsz   = []
      //** 1st dim **//
      for j=1:nopar
        Code_oparsz=[Code_oparsz
                     string(size(opar(opptr(i)+j-1),1))]
      end
      //** 2dn dim **//
      for j=1:nopar
        Code_oparsz=[Code_oparsz
                     string(size(opar(opptr(i)+j-1),2))]
      end
      Code_tooparsz=cformatline(strcat(Code_oparsz,','),70);
      Code_tooparsz(1)='int oparsz_'+string(i)+'[]={'+Code_tooparsz(1);
      for j=2:size(Code_tooparsz,1)
        Code_tooparsz(j)=get_blank('int oparsz_'+string(i)+'[]')+Code_tooparsz(j);
      end
      Code_tooparsz($)=Code_tooparsz($)+'};'
      Code_ooparsz=[Code_ooparsz;
                    Code_tooparsz];

      //## typ
      Code_opartyp   = []
      for j=1:nopar
        Code_opartyp=[Code_opartyp
                      mat2scs_c_typ(opar(opptr(i)+j-1))]
      end
      Code_toopartyp=cformatline(strcat(Code_opartyp,','),70);
      Code_toopartyp(1)='int opartyp_'+string(i)+'[]={'+Code_toopartyp(1);
      for j=2:size(Code_toopartyp,1)
        Code_toopartyp(j)=get_blank('int opartyp_'+string(i)+'[]')+Code_toopartyp(j);
      end
      Code_toopartyp($)=Code_toopartyp($)+'};'
      Code_oopartyp=[Code_oopartyp;
                     Code_toopartyp];

      //## ptr
      Code_tooparptr=cformatline(strcat(string(zeros(1,nopar)),','),70);
      Code_tooparptr(1)='void *oparptr_'+string(i)+'[]={'+Code_tooparptr(1);
      for j=2:size(Code_tooparptr,1)
        Code_tooparptr(j)=get_blank('void *oparptr_'+string(i)+'[]')+Code_tooparptr(j);
      end
      Code_tooparptr($)=Code_tooparptr($)+'};'
      Code_oparptr=[Code_oparptr
                    Code_tooparptr]

    end
  end

  if Code_opar <> [] then
    Code=[Code;
          '  /* Object parameters declaration */'
          Code_opar
          ''
          '  '+Code_ooparsz
          ''
          '  '+Code_oopartyp
          ''
          '  '+Code_oparptr
          '']
  end

  //##########################//

  //*** Continuous state ***//
  if x <> [] then
   //## implicit block
   if impl_blk then
     Code=[Code;
           '  /* Continuous states declaration */'
           cformatline('  double x[]={'+strcat(string(x(1:nX/2)),',')+'};',70)
           cformatline('  double xd[]={'+strcat(string(zeros(nX/2+1:nX)),',')+'};',70)
           cformatline('  double res[]={'+strcat(string(zeros(1,nX/2)),',')+'};',70)
           ''
           '  /* def xproperty */'
           cformatline('  int xprop[]={'+strcat(string(ones(1:nX/2)),',')+'};',70)
           '']

   //## explicit block
   else
     Code=[Code;
           '  /* Continuous states declaration */'
           cformatline('  double x[]={'+strcat(string(x),',')+'};',70)
           cformatline('  double xd[]={'+strcat(string(zeros(1,nX)),',')+'};',70)
           '']
   end
  end
  //************************//

  //### discrete states ###//
  if size(z,1) <> 0 then
    Code=[Code;
          '  /* Discrete states declaration */']
    for i=1:(length(zptr)-1)
      if zptr(i+1)-zptr(i)>0 then

        //** Add comments **//

        //## Modelica block
        if type(corinv(i))==15 then
          //## we can extract here all informations
          //## from original scicos blocks with corinv : TODO
          Code($+1)='  /* MODELICA BLK Z COMMENTS : TODO ';
        else
          if size(corinv(i),'*')==1 then
            OO=scs_m.objs(corinv(i))
          else
            path=list('objs')
            for l=cpr.corinv(i)(1:$-1)
              path($+1)=l;path($+1)='model'
              path($+1)='rpar'
              path($+1)='objs'
            end
            path($+1)=cpr.corinv(i)($)
            OO=scs_m(path)
          end
          aaa=OO.gui
          bbb=emptystr(3,1);
          if and(aaa+bbb~=['INPUTPORTEVTS';'OUTPUTPORTEVTS';'EVTGEN_f']) then
            Code($+1)='  /* Routine name of block: '+strcat(string(cpr.sim.funs(i)));
            Code($+1)='     Gui name of block: '+strcat(string(OO.gui));
            //Code($+1)='/* Name block: '+strcat(string(cpr.sim.funs(i)));
            //Code($+1)='Object number in diagram: '+strcat(string(cpr.corinv(i)));
            Code($+1)='     Compiled structure index: '+strcat(string(i));
            if stripblanks(OO.model.label)~=emptystr() then
              Code=[Code;
                    cformatline('     Label: '+strcat(string(OO.model.label)),70)]
            end
            if stripblanks(OO.graphics.exprs(1))~=emptystr() then
              Code=[Code;
                    cformatline('     Exprs: '+strcat(OO.graphics.exprs(1),","),70)]
            end
            if stripblanks(OO.graphics.id)~=emptystr() then
              Code=[Code;
                    cformatline('     Identification: '+..
                       strcat(string(OO.graphics.id)),70)]
            end
          end
        end
        Code($+1)='  */';
        Code=[Code;
              cformatline('  double z_'+string(i)+'[]={'+...
              strcat(string(z(zptr(i):zptr(i+1)-1)),",")+'};',70)]
        Code($+1)='';
      end
      //******************//
    end
  end
  //#######################//

  //** declaration of work
  Code_work=[]
  for i=1:size(with_work,1)
    if with_work(i)==1 then
       Code_work=[Code_work
                  '  void *work_'+string(i)+'[]={0};']
    end
  end

  if Code_work<>[] then
    Code=[Code
          '  /* Work array declaration */'
          Code_work
          '']
  end

  //### Object state ###//
  //** declaration of oz
  Code_oz = [];
  Code_oozsz=[];
  Code_ooztyp=[];
  Code_ozptr=[];

  for i=1:(length(ozptr)-1)
    noz = ozptr(i+1)-ozptr(i)
    if noz>0 then

      for j=1:noz
        if mat2scs_c_nb(oz(ozptr(i)+j-1)) <> 11 then
          Code_oz=[Code_oz;
                   cformatline('  '+mat2c_typ(oz(ozptr(i)+j-1))+...
                               ' oz_'+string(ozptr(i)+j-1)+'[]={'+...
                               strcat(msprintf('%.16g,\n',oz(ozptr(i)+j-1)(:)))+'};',70)]
        else //** cmplx test
          Code_oz=[Code_oz;
                   cformatline('  '+mat2c_typ(oz(ozptr(i)+j-1))+...
                               ' oz_'+string(ozptr(i)+j-1)+'[]={'+...
                               strcat(msprintf('%.16g,\n',[real(oz(ozptr(i)+j-1)(:));
                                              imag(oz(ozptr(i)+j-1)(:))]))+'};',70)]
        end
      end

      //## size
      Code_ozsz   = []
      //** 1st dim **//
      for j=1:noz
        Code_ozsz=[Code_ozsz
                     string(size(oz(ozptr(i)+j-1),1))]
      end
      //** 2dn dim **//
      for j=1:noz
        Code_ozsz=[Code_ozsz
                     string(size(oz(ozptr(i)+j-1),2))]
      end
      Code_toozsz=cformatline(strcat(Code_ozsz,','),70);
      Code_toozsz(1)='int ozsz_'+string(i)+'[]={'+Code_toozsz(1);
      for j=2:size(Code_toozsz,1)
        Code_toozsz(j)=get_blank('int ozsz_'+string(i)+'[]')+Code_toozsz(j);
      end
      Code_toozsz($)=Code_toozsz($)+'};'
      Code_oozsz=[Code_oozsz;
                    Code_toozsz];

      //## typ
      Code_oztyp   = []
      for j=1:noz
        Code_oztyp=[Code_oztyp
                      mat2scs_c_typ(oz(ozptr(i)+j-1))]
      end
      Code_tooztyp=cformatline(strcat(Code_oztyp,','),70);
      Code_tooztyp(1)='int oztyp_'+string(i)+'[]={'+Code_tooztyp(1);
      for j=2:size(Code_tooztyp,1)
        Code_tooztyp(j)=get_blank('int oztyp_'+string(i)+'[]')+Code_tooztyp(j);
      end
      Code_tooztyp($)=Code_tooztyp($)+'};'
      Code_ooztyp=[Code_ooztyp;
                     Code_tooztyp];

      //## ptr
      Code_toozptr=cformatline(strcat(string(zeros(1,noz)),','),70);
      Code_toozptr(1)='void *ozptr_'+string(i)+'[]={'+Code_toozptr(1);
      for j=2:size(Code_toozptr,1)
        Code_toozptr(j)=get_blank('void *ozptr_'+string(i)+'[]')+Code_toozptr(j);
      end
      Code_toozptr($)=Code_toozptr($)+'};'
      Code_ozptr=[Code_ozptr
                    Code_toozptr]

    end
  end

  if Code_oz <> [] then
    Code=[Code;
          '  /* Object discrete states declaration */'
          Code_oz
          ''
          '  '+Code_oozsz
          ''
          '  '+Code_ooztyp
          ''
          '  '+Code_ozptr
          '']
  end
  //#######################//

  //** declaration of outtb
  Code_outtb = [];
  for i=1:lstsize(outtb)
    if mat2scs_c_nb(outtb(i)) <> 11 then
      Code_outtb=[Code_outtb;
                  cformatline('  '+mat2c_typ(outtb(i))+...
                              ' outtb_'+string(i)+'[]={'+...
                              strcat(string_to_c_string(outtb(i)(:)),',')+'};',70)]
    else //** cmplx test
      Code_outtb=[Code_outtb;
                  cformatline('  '+mat2c_typ(outtb(i))+...
                              ' outtb_'+string(i)+'[]={'+...
                              strcat(string_to_c_string([real(outtb(i)(:));
                                             imag(outtb(i)(:))]),',')+'};',70)]
    end
  end

  if Code_outtb<>[] then
    Code=[Code
          '  /* Output declaration */'
          Code_outtb
          '']
  end

  Code_outtbptr=[];
  for i=1:lstsize(outtb)
    Code_outtbptr=[Code_outtbptr;
                   '  '+rdnom+'_block_outtbptr['+...
                    string(i-1)+'] = (void *) outtb_'+string(i)+';'];
  end

  //##### insz/outsz #####//
  Code_iinsz=[];
  Code_inptr=[];
  Code_ooutsz=[];
  Code_outptr=[];
  for kf=1:nblk
    nin=inpptr(kf+1)-inpptr(kf);  //** number of input ports
    Code_insz=[];

    //########
    //## insz
    //########

    //## case sensor ##//
    if or(kf==capt(:,1)) then
      ind=find(kf==capt(:,1))
      //Code_insz = 'typin['+string(ind-1)+']'
    //## other blocks ##//
    elseif nin<>0 then
      //** 1st dim **//
      for kk=1:nin
         lprt=inplnk(inpptr(kf)-1+kk);
         Code_insz=[Code_insz
                    string(size(outtb(lprt),1))]
      end
      //** 2dn dim **//
      for kk=1:nin
         lprt=inplnk(inpptr(kf)-1+kk);
         Code_insz=[Code_insz
                    string(size(outtb(lprt),2))]
      end
      //** typ **//
      for kk=1:nin
         lprt=inplnk(inpptr(kf)-1+kk);
         Code_insz=[Code_insz
                    mat2scs_c_typ(outtb(lprt))]
      end
    end
    if Code_insz<>[] then
      Code_toinsz=cformatline(strcat(Code_insz,','),70);
      Code_toinsz(1)='int insz_'+string(kf)+'[]={'+Code_toinsz(1);
      for j=2:size(Code_toinsz,1)
        Code_toinsz(j)=get_blank('int insz_'+string(kf)+'[]')+Code_toinsz(j);
      end
      Code_toinsz($)=Code_toinsz($)+'};'
      Code_iinsz=[Code_iinsz
                  Code_toinsz]
    end

    //########
    //## inptr
    //########

    //## case sensor ##//
    if or(kf==capt(:,1)) then
      Code_inptr=[Code_inptr;
                  'void *inptr_'+string(kf)+'[]={0};';]
    //## other blocks ##//
    elseif nin<>0 then
      Code_toinptr=cformatline(strcat(string(zeros(1,nin)),','),70);
      Code_toinptr(1)='void *inptr_'+string(kf)+'[]={'+Code_toinptr(1);
      for j=2:size(Code_toinptr,1)
        Code_toinptr(j)=get_blank('void *inptr_'+string(kf)+'[]')+Code_toinptr(j);
      end
      Code_toinptr($)=Code_toinptr($)+'};'
      Code_inptr=[Code_inptr
                  Code_toinptr]
    end

    nout=outptr(kf+1)-outptr(kf); //** number of output ports
    Code_outsz=[];

    //########
    //## outsz
    //########

    //## case actuators ##//
    if or(kf==actt(:,1)) then
      ind=find(kf==actt(:,1))
      //Code_outsz = 'typout['+string(ind-1)+']'
    //## other blocks ##//
    elseif nout<>0 then
      //** 1st dim **//
      for kk=1:nout
         lprt=outlnk(outptr(kf)-1+kk);
         Code_outsz=[Code_outsz
                     string(size(outtb(lprt),1))]
      end
      //** 2dn dim **//
      for kk=1:nout
         lprt=outlnk(outptr(kf)-1+kk);
         Code_outsz=[Code_outsz
                     string(size(outtb(lprt),2))]
      end
      //** typ **//
      for kk=1:nout
         lprt=outlnk(outptr(kf)-1+kk);
         Code_outsz=[Code_outsz
                     mat2scs_c_typ(outtb(lprt))]
      end
    end
    if Code_outsz<>[] then
      Code_tooustz=cformatline(strcat(Code_outsz,','),70);
      Code_tooustz(1)='int outsz_'+string(kf)+'[]={'+Code_tooustz(1);
      for j=2:size(Code_tooustz,1)
        Code_tooustz(j)=get_blank('int outsz_'+string(kf)+'[]')+Code_tooustz(j);
      end
      Code_tooustz($)=Code_tooustz($)+'};'
      Code_ooutsz=[Code_ooutsz
                   Code_tooustz]
    end

    //#########
    //## outptr
    //#########

    //## case actuators ##//
    if or(kf==actt(:,1)) then
      Code_outptr=[Code_outptr;
                   'void *outptr_'+string(kf)+'[]={0};';]
    //## other blocks ##//
    elseif nout<>0 then
      Code_tooutptr=cformatline(strcat(string(zeros(1,nout)),','),70);
      Code_tooutptr(1)='void *outptr_'+string(kf)+'[]={'+Code_tooutptr(1);
      for j=2:size(Code_tooutptr,1)
        Code_tooutptr(j)=get_blank('void *outptr_'+string(kf)+'[]')+Code_tooutptr(j);
      end
      Code_tooutptr($)=Code_tooutptr($)+'};'
      Code_outptr=[Code_outptr
                   Code_tooutptr]
    end
  end

  if Code_iinsz<>[] then
     Code=[Code;
          '  /* Inputs */'
          '  '+Code_iinsz
          ''];
  end
  if Code_inptr<>[] then
     Code=[Code;
          '  '+Code_inptr
          ''];
  end
  if Code_ooutsz<>[] then
     Code=[Code;
          '  /* Outputs */'
          '  '+Code_ooutsz
          ''];
  end
  if Code_outptr<>[] then
     Code=[Code;
          '  '+Code_outptr
          ''];
  end
  //######################//

  //##### out events #####//
  Code_evout=[];
  for kf=1:nblk
    if funs(kf)<>'bidon' then
      nevout=clkptr(kf+1)-clkptr(kf);
      if nevout <> 0 then
        Code_toevout=cformatline(strcat(string(cpr.state.evtspt((clkptr(kf):clkptr(kf+1)-1))),','),70);
        Code_toevout(1)='double evout_'+string(kf)+'[]={'+Code_toevout(1);
        for j=2:size(Code_toevout,1)
          Code_toevout(j)=get_blank('double evout_'+string(kf)+'[]')+Code_toevout(j);
        end
        Code_toevout($)=Code_toevout($)+'};';
        Code_evout=[Code_evout
                    Code_toevout];
      end
    end
  end
  if Code_evout<>[] then
     Code=[Code;
          '  /* Outputs event declaration */'
          '  '+Code_evout
          ''];
  end
  //################//

  //## input connection to outtb
  Code_inptr=[]
  for kf=1:nblk
    nin=inpptr(kf+1)-inpptr(kf);  //** number of input ports
    //## case sensor ##//
    if or(kf==capt(:,1)) then
      ind=find(kf==capt(:,1))
      Code_inptr=[Code_inptr;
                  '  inptr_'+string(kf)+'[0] = inptr['+string(ind-1)+'];';]
    //## other blocks ##//
    elseif nin<>0 then
      for k=1:nin
        lprt=inplnk(inpptr(kf)-1+k);
        Code_inptr=[Code_inptr
                    '  inptr_'+string(kf)+'['+string(k-1)+'] = (void *) outtb_'+string(lprt)+';']
      end
    end
  end
  if Code_inptr<>[] then
    Code=[Code;
          '  /* Affectation of inptr */';
          Code_inptr;
          ''];
  end

  //## output connection to outtb
  Code_outptr=[]
  for kf=1:nblk
    nout=outptr(kf+1)-outptr(kf); //** number of output ports
    //## case actuators ##//
    if or(kf==actt(:,1)) then
    ind=find(kf==actt(:,1))
    Code_outptr=[Code_outptr;
                 '  outptr_'+string(kf)+'[0] = outptr['+string(ind-1)+'];';]
    //## other blocks ##//
    elseif nout<>0 then
      for k=1:nout
        lprt=outlnk(outptr(kf)-1+k);
        Code_outptr=[Code_outptr
                    '  outptr_'+string(kf)+'['+string(k-1)+'] = (void *) outtb_'+string(lprt)+';']
      end
    end
  end
  if Code_outptr<>[] then
    Code=[Code;
          '  /* Affectation of outptr */';
          Code_outptr;
          ''];
  end

  //## affectation of oparptr
  Code_oparptr=[]
  for kf=1:nblk
    nopar=opptr(kf+1)-opptr(kf); //** number of object parameters
    if nopar<>0 then
      for k=1:nopar
        Code_oparptr=[Code_oparptr
                    '  oparptr_'+string(kf)+'['+string(k-1)+'] = (void *) opar_'+string(opptr(kf)+k-1)+';']
      end
    end
  end
  if Code_oparptr<>[] then
    Code=[Code;
          '  /* Affectation of oparptr */';
          Code_oparptr;
          ''];
  end

  //## affectation of ozptr
  Code_ozptr=[]
  for kf=1:nblk
    noz=ozptr(kf+1)-ozptr(kf); //** number of object states
    if noz<>0 then
      for k=1:noz
        Code_ozptr=[Code_ozptr
                    '  ozptr_'+string(kf)+'['+string(k-1)+'] = (void *) oz_'+string(ozptr(kf)+k-1)+';']
      end
    end
  end
  if Code_ozptr<>[] then
    Code=[Code;
          '  /* Affectation of ozptr */';
          Code_ozptr;
          ''];
  end

  //## fields of each scicos structure
  for kf=1:nblk
    if funs(kf)<>'bidon' then
      nx=xptr(kf+1)-xptr(kf);         //** number of continuous state
      nz=zptr(kf+1)-zptr(kf);         //** number of discrete state
      nin=inpptr(kf+1)-inpptr(kf);    //** number of input ports
      nout=outptr(kf+1)-outptr(kf);   //** number of output ports
      nevout=clkptr(kf+1)-clkptr(kf); //** number of event output ports

      //** add comment
      txt=[get_comment('set_blk',list(funs(kf),funtyp(kf),kf));]

      Code=[Code;
            '  '+txt];

      Code=[Code;
            '  block_'+rdnom+'['+string(kf-1)+'].type    = '+string(funtyp(kf))+';';
            '  block_'+rdnom+'['+string(kf-1)+'].ztyp    = '+string(ztyp(kf))+';';
            '  block_'+rdnom+'['+string(kf-1)+'].ng      = '+string(zcptr(kf+1)-zcptr(kf))+';';
            '  block_'+rdnom+'['+string(kf-1)+'].nz      = '+string(zptr(kf+1)-zptr(kf))+';';
            '  block_'+rdnom+'['+string(kf-1)+'].nx      = '+string(nx)+';';
            '  block_'+rdnom+'['+string(kf-1)+'].noz     = '+string(ozptr(kf+1)-ozptr(kf))+';';
            '  block_'+rdnom+'['+string(kf-1)+'].nrpar   = '+string(rpptr(kf+1)-rpptr(kf))+';';
            '  block_'+rdnom+'['+string(kf-1)+'].nopar   = '+string(opptr(kf+1)-opptr(kf))+';';
            '  block_'+rdnom+'['+string(kf-1)+'].nipar   = '+string(ipptr(kf+1)-ipptr(kf))+';'
            '  block_'+rdnom+'['+string(kf-1)+'].nin     = '+string(inpptr(kf+1)-inpptr(kf))+';';
            '  block_'+rdnom+'['+string(kf-1)+'].nout    = '+string(outptr(kf+1)-outptr(kf))+';';
            '  block_'+rdnom+'['+string(kf-1)+'].nevout  = '+string(clkptr(kf+1)-clkptr(kf))+';';
            '  block_'+rdnom+'['+string(kf-1)+'].nmode   = '+string(modptr(kf+1)-modptr(kf))+';';]

      if nx <> 0 then
        Code=[Code;
              '  block_'+rdnom+'['+string(kf-1)+'].x       = &(x['+string(xptr(kf)-1)+']);'
              '  block_'+rdnom+'['+string(kf-1)+'].xd      = &(xd['+string(xptr(kf)-1)+']);']
        if impl_blk then
          Code=[Code;
                '  block_'+rdnom+'['+string(kf-1)+'].res     = &(res['+string(xptr(kf)-1)+']);'
                '  block_'+rdnom+'['+string(kf-1)+'].xprop   = &(xprop['+string(xptr(kf)-1)+']);'];
        end
      end

      //** evout **//
      if nevout<>0 then
        Code=[Code;
              '  block_'+rdnom+'['+string(kf-1)+'].evout   = evout_'+string(kf)+';']
      end

      //***************************** input port *****************************//
      //## case sensor ##//
      if or(kf==capt(:,1)) then
        ind=find(kf==capt(:,1))
        Code=[Code;
              '  block_'+rdnom+'['+string(kf-1)+'].inptr   = inptr_'+string(kf)+';'
              '  block_'+rdnom+'['+string(kf-1)+'].insz    = &typin['+string(ind-1)+'];']
//              '  block_'+rdnom+'['+string(kf-1)+'].insz    = insz_'+string(kf)+';']
      //## other blocks ##//
      elseif nin<>0 then
        Code=[Code;
              '  block_'+rdnom+'['+string(kf-1)+'].inptr   = inptr_'+string(kf)+';'
              '  block_'+rdnom+'['+string(kf-1)+'].insz    = insz_'+string(kf)+';']
      end
      //**********************************************************************//

      //***************************** output port *****************************//
      //## case actuators ##//
      if or(kf==actt(:,1)) then
        ind=find(kf==actt(:,1))
        Code=[Code;
              '  block_'+rdnom+'['+string(kf-1)+'].outptr  = outptr_'+string(kf)+';'
              '  block_'+rdnom+'['+string(kf-1)+'].outsz   = &typout['+string(ind-1)+'];']
//              '  block_'+rdnom+'['+string(kf-1)+'].outsz   = outsz_'+string(kf)+';']
      //## other blocks ##//
      elseif nout<>0 then
        Code=[Code;
              '  block_'+rdnom+'['+string(kf-1)+'].outptr  = outptr_'+string(kf)+';'
              '  block_'+rdnom+'['+string(kf-1)+'].outsz   = outsz_'+string(kf)+';']
      end
      //**********************************************************************//

      //## discrete states ##//
      if (nz>0) then
        Code=[Code
              '  block_'+rdnom+'['+string(kf-1)+...
              '].z       = z_'+string(kf)+';']
      end

      //** rpar **//
      if (rpptr(kf+1)-rpptr(kf)>0) then
        Code=[Code;
              '  block_'+rdnom+'['+string(kf-1)+...
              '].rpar    = rpar_'+string(kf)+';']
      end

      //** ipar **//
      if (ipptr(kf+1)-ipptr(kf)>0) then
        Code=[Code;
              '  block_'+rdnom+'['+string(kf-1)+...
              '].ipar    = ipar_'+string(kf)+';']
      end

      //** opar **//
      if (opptr(kf+1)-opptr(kf)>0) then
        Code=[Code;
              '  block_'+rdnom+'['+string(kf-1)+'].oparptr = oparptr_'+string(kf)+';'
              '  block_'+rdnom+'['+string(kf-1)+'].oparsz  = oparsz_'+string(kf)+';'
              '  block_'+rdnom+'['+string(kf-1)+'].opartyp = opartyp_'+string(kf)+';'
              ]
      end

      //** oz **//
      if (ozptr(kf+1)-ozptr(kf)>0) then
        Code=[Code;
              '  block_'+rdnom+'['+string(kf-1)+'].ozptr   = ozptr_'+string(kf)+';'
              '  block_'+rdnom+'['+string(kf-1)+'].ozsz    = ozsz_'+string(kf)+';'
              '  block_'+rdnom+'['+string(kf-1)+'].oztyp   = oztyp_'+string(kf)+';'
              ]
      end

      //** work **/
      if with_work(kf)==1 then
        Code=[Code;
              '  block_'+rdnom+'['+string(kf-1)+'].work    = work_'+string(kf)+';'
              ]
      end

      //** TODO label **//

      Code=[Code;
            '']
    end
  end

  Code=[Code;
        '  /* set a variable to trace error of blocks */'
        '  block_error=&err; /*GLOBAL*/'
        '']

  if ~ALL then
    Code=[Code;
          '  /* set initial time */'
          '  t=0.0;'
          '']
  end

  Code=[Code;
        '  /* set initial phase simulation */'
        '  phase=1;'
        '']

  if impl_blk then
    Code=[Code;
          '  /* default jacob_param */'
          '  CJJ=1/h;'
          '']
  end

  //** init
  Code=[Code;
        '  '+get_comment('flag',list(4))]

  for kf=1:nblk
    if funs(kf)=='agenda_blk' then
      if ALL & size(evs,'*')<>0 then
        new_pointi=adjust_pointi(cpr.state.pointi,clkptr,funtyp)
        Code=[Code;
              '';
              '  /* Init of agenda_blk (blk nb '+string(kf)+') */'
              '  *(block_'+rdnom+'['+string(kf-1)+'].work) = '+...
                '(agenda_struct*) scicos_malloc(sizeof(agenda_struct));'
              '  ptr = *(block_'+rdnom+'['+string(kf-1)+'].work);'
              '  ptr->pointi     = '+string(new_pointi)+';'
              '  ptr->fromflag3  = 0;'
              '  ptr->old_pointi = 0;'
             ]
        new_evtspt=adjust_agenda(cpr.state.evtspt,clkptr,funtyp)
        for i=1:size(new_evtspt,1)
          if new_evtspt(i)>0 then
            new_evtspt(i)=adjust_pointi(new_evtspt(i),clkptr,funtyp)
          end
        end
        for i=1:size(evs,'*')
          Code=[Code;
                '  ptr->evtspt['+string(i-1)+'] = '+string(new_evtspt(i))+';'
               ]
        end
        new_tevts=adjust_agenda(cpr.state.tevts,clkptr,funtyp)
        for i=1:size(evs,'*')
          Code=[Code;
                '  ptr->tevts['+string(i-1)+']  = '+string_to_c_string(new_tevts(i))+';'
               ]
        end

        Code=[Code;
              ''
              '  /* set initial time */'
              '  t='+string(cpr.state.tevts(pointi))+';'
              '']

      end
    elseif or(kf==act) | or(kf==cap) then
        txt = call_block42(kf,0,4);
        if txt <> [] then
          Code=[Code;
                '';
                '  '+txt];
        end
    else
      txt = call_block42(kf,0,4);
      if txt <> [] then
        Code=[Code;
              '';
              '  '+txt];
      end
    end
  end

  //@@ check block_error after all calls
  Code=[Code;
        '';
        '  /* error handling */'
        '  if (get_block_error() != 0) {'
        '    '+rdnom+'_cosend();'
        '    return get_block_error();'
        '  }']

  //** cst blocks and it's dep
  txt=write_code_idoit()

  if txt<>[] then
    Code=[Code;
          ''
          '  /* Initial blocks must be called with flag 1 */'
          txt];
  end

  //## reinidoit
  if x <> [] then
    //## implicit block
    if impl_blk then
      txt=[write_code_reinitdoit(1) //** first pass
           write_code_reinitdoit(7) //** second pass
          ]

      if txt<>[] then
        Code=[Code;
              '  /* Initial derivative computation */'
              txt];
      end
    end
  end

  //** begin input main loop on time
  Code=[Code;
        ''
        '  while (t<=tf) {';
        '    /* */'
        '    scicos_time=t;'
        '']

  if ALL then
    Code=[Code;
          '    /* */'
          '    ptr = *(block_'+rdnom+'['+string(nb_agenda_blk-1)+'].work);'
          '    kever = ptr->pointi;'
          '']
  end

  //** flag 1,2,3
  for flag=[1,3,2]

    txt3=[]

    //** continuous time blocks must be activated
    //** for flag 1
    if flag==1 then
      txt = write_code_cdoit(flag);

      if txt <> [] then
        txt3=[''
              '    '+get_comment('ev',list(0))
              txt;
             ];
      end
    end

    //** blocks with input discrete event must be activated
    //** for flag 1, 2 and 3
    if size(evs,2)>=1 then
      txt4=[]
      //**
      for ev=evs
        txt2=write_code_doit(ev,flag);
        if txt2<>[] then
          //** adjust event number because of bidon block
          if ~ALL then
            new_ev=ev-(clkptr(howclk)-1)
          else
            new_ev=ev-min(evs)+1
          end
          //**
          txt4=[txt4;
                Indent2+['  case '+string(new_ev)+' : '+...
                get_comment('ev',list(new_ev))
                   txt2];
                '      break;';'']
        end
      end

      //**
      if txt4 <> [] then
        if ~ALL then
          txt3=[txt3;
                Indent+'  /* Discrete activations */'
                Indent+'  switch (nevprt) {'
                txt4
                '    }'];
        else
          txt33=[]
          if flag==3 then
            txt33=[Indent+'  ptr->pointi = ptr->evtspt[kever-1];'
                   Indent+'  ptr->evtspt[kever-1] = -1;']
          end
          txt3=[txt3;
                txt33;
                Indent+'  switch (kever) {'
                txt4
                '    }'
                ''];
        end
      end
    end

    //**
    if txt3<>[] then
      Code=[Code;
            '    '+get_comment('flag',list(flag))
            txt3];
    end
  end

  if x<>[] then
    Code=[Code
          ''
          '    tout=t;'
          ''
          '   /* integrate until the cumulative add of the integration'
          '    * time step doesn''t cross the sample time step'
          '    */']

    if ALL then
      Code=[Code
            '    while (tout+h<ptr->tevts[ptr->pointi-1]){'
            '      switch (solver) {']
    else
      Code=[Code
            '    while (tout+h<t+dt){'
            '      switch (solver) {']
    end

    if impl_blk then
      Code=[Code
            '      case 1:'
            '        err=dae1('+rdnom+'simblk_imp,x,xd,res,tout,h);'
            '        break;'
            '      default :'
            '        err=dae1('+rdnom+'simblk_imp,x,xd,res,tout,h);'
            '        break;'
            '      }']
    else
      Code=[Code
            '      case 1:'
            '        err=ode1('+rdnom+'simblk,x,xd,tout,h);'
            '        break;'
            '      case 2:'
            '        err=ode2('+rdnom+'simblk,x,xd,tout,h);'
            '        break;'
            '      case 3:'
            '        err=ode4('+rdnom+'simblk,x,xd,tout,h);'
            '        break;'
            '      default :'
            '        err=ode4('+rdnom+'simblk,x,xd,tout,h);'
            '        break;'
            '      }']
    end
    Code=[Code
          '      if (err!=0) return err;']

    Code=[Code
          '       tout=tout+h;'
          '    }'
          ''
          '    /* integration for the remainder piece of time */']

    if ALL then
      Code=[Code
            '    he=ptr->tevts[ptr->pointi-1]-tout;']
    else
      Code=[Code
            '    he=t+dt-tout;']
    end

    Code=[Code
          '    switch (solver) {']

    if impl_blk then
      Code=[Code
            '    case 1:'
            '      err=dae1('+rdnom+'simblk_imp,x,xd,res,tout,he);'
            '      break;'
            '    default :'
            '      err=dae1('+rdnom+'simblk_imp,x,xd,res,tout,he);'
            '      break;'
            '      }']
    else
      Code=[Code
            '    case 1:'
            '      err=ode1('+rdnom+'simblk,x,xd,tout,he);'
            '      break;'
            '    case 2:'
            '      err=ode2('+rdnom+'simblk,x,xd,tout,he);'
            '      break;'
            '    case 3:'
            '      err=ode4('+rdnom+'simblk,x,xd,tout,he);'
            '      break;'
            '    default :'
            '      err=ode4('+rdnom+'simblk,x,xd,tout,he);'
            '      break;'
            '    }']
    end
    Code=[Code
          '    if (err!=0) return err;']
  end

  //** 13/10/07, fix bug provided by Roberto Bucher
  if nX <> 0 then
    Code=[Code;
          ''
          '    /* update ptrs of continuous array */']
    for kf=1:nblk
      nx=xptr(kf+1)-xptr(kf);  //** number of continuous state
      if nx<>0 then
        Code=[Code;
              '    block_'+rdnom+'['+string(kf-1)+'].nx = '+...
                string(nx)+';';
              '    block_'+rdnom+'['+string(kf-1)+'].x  = '+...
               '&(x['+string(xptr(kf)-1)+']);'
              '    block_'+rdnom+'['+string(kf-1)+'].xd = '+...
               '&(xd['+string(xptr(kf)-1)+']);']
        if impl_blk then
          Code=[Code;
                '    block_'+rdnom+'['+string(kf-1)+'].res = '+...
                 '&(res['+string(xptr(kf)-1)+']);']
        end
      end
    end
  end

  if ALL then
    Code=[Code
          ''
          '    /* update current time */'
          '    t=ptr->tevts[ptr->pointi-1];']
  else
    Code=[Code
          ''
          '    /* update current time */'
          '    t=t+dt;']
  end

  Code=[Code
        ''
        '    /* set phase simulation */'
        '    phase=1;'
        '  }']

  //** flag 5
//   Code=[Code;
//         Code_end]

  Code=[Code
        ''
        '  '+rdnom+'_cosend();'
        '  return get_block_error();'
        '}']

  Code=[Code
        Code_end_fun
        '']

  Code=[Code
        ''
        '/*'+part('-',ones(1,40))+'  Lapack messag function */';
        'void C2F(xerbla)(SRNAME,INFO,L)'
        '     char *SRNAME;'
        '     int *INFO;'
        '     long int L;'
        '{'
        '  printf(""** On entry to %s, parameter number %d""'
        '         ""  had an illegal value\n"",SRNAME,*INFO);'
        '}'
        '']

  Code=[Code;
        'void set_block_error(int err)'
        '{'
        '  *block_error = err;'
        '  return;'
        '}'
        ''
        'int get_block_error()'
        '{'
        '  return *block_error;'
        '}'
        ''
        'void set_block_number(int kfun)'
        '{'
        '  block_number = kfun;'
        '  return;'
        '}'
        ''
        'int get_block_number()'
        '{'
        '  return block_number;'
        '}'
        ''
        'int get_phase_simulation()'
        '{'
        '  return phase;'
        '}'
        ''
        'void * scicos_malloc(size_t size)'
        '{'
        '  return malloc(size);'
        '}'
        ''
        'void scicos_free(void *p)'
        '{'
        '  free(p);'
        '}'
        ''
        'double get_scicos_time()'
        '{'
        '  return scicos_time;'
        '}'
        ''
        'void do_cold_restart()'
        '{'
        '  return;'
        '}'
        ''
        'void sciprint (char *fmt)'
        '{'
        '  return;'
        '}']

 Code=[Code
        ''
        '#if WIN32'
        ' #ifndef vsnprintf'
        '   #define vsnprintf _vsnprintf'
        ' #endif'
        '#endif'
        ''
        '#ifdef __STDC__'
        'void Coserror (char *fmt,...)'
        '#else'
        'void Coserror(va_alist) va_dcl'
        '#endif'
        '{'
        ' int retval;'
        ' va_list ap;'
        ''
        '#ifdef __STDC__'
        ' va_start(ap,fmt);'
        '#else'
        ''
        ' char *fmt;'
        ' va_start(ap);'
        ''
        ' fmt = va_arg(ap, char *);'
        '#endif'
        ''
        '#if defined (vsnprintf) || defined (linux)'
        ' retval= vsnprintf(err_msg,4095, fmt, ap);'
        '#else'
        ' retval= vsprintf(err_msg,fmt, ap);'
        '#endif'
        ''
        ' if (retval == -1) {'
        '   err_msg[0]=''\0'';'
        ' }'
        ''
        ' va_end(ap);'
        ''
        ' /* coserror use error number 10 */'
        ' *block_error=-5;'
        ''
        ' return;'
        '}'
        '']

  if impl_blk then
    Code=[Code;
          'void Set_Jacobian_flag(int flag)'
          '{'
          '  Jacobian_Flag=flag;'
          '  return;'
          '}'
          ''
          'double Get_Jacobian_parameter(void)'
          '{'
          '  return CJJ;'
          '}'
          ''
          'double Get_Scicos_SQUR(void)'
          '{'
          '  return  SQuround;'
          '}'
         ]
  end

  Code=[Code;
        'int getopt (int argc, char *argv[], char *optstring)'
        '{'
        '  char *group, option, *sopt;'
        '  char *optarg;'
        '  int len;'
        '  int offset = 0;'
        '  option = -1;'
        '  optarg = NULL;'
        '  while ( optind < argc )'
        '    { '
        '      group = argv[optind];'
        '      if ( *group != ''-'' )'
        '        {'
        '         option = -1;'
        '         optarg = group;'
        '         optind++;'
        '         break;'
        '        }'
        '      len = strlen (group);'
        '      group = group + offset;'
        '      if ( *group == ''-'' )'
        '        {'
        '         group++;'
        '         offset += 2;'
        '        }'
        '      else'
        '        offset++ ;'
        '      option = *group ;'
        '      sopt = strchr ( optstring, option ) ;'
        '      if ( sopt != NULL )'
        '        {'
        '         sopt++ ;'
        '         if ( *sopt == '':'' )'
        '           {'
        '             optarg = group + 1;'
        '             if ( *optarg == ''\0'' )'
        '                optarg = argv[++optind];'
        '             if ( *optarg == ''-'' )'
        '                {'
        '                 fprintf ( stderr, '"%s: illegal option -- %c \n'",'
        '                           argv[0], option );'
        '                 option = ''?'';'
        '                 break;'
        '                }'
        '             else'
        '                {'
        '                 optind++;'
        '                 offset = 0;'
        '                 break;'
        '                }'
        '           }'
        '         if ( offset >= len )'
        '           {'
        '             optind++;'
        '             offset = 0;'
        '           }'
        '         break;'
        '        }'
        '      else'
        '        {'
        '         fprintf ( stderr, '"%s: illegal option -- %c \n'", argv[0], option );'
        '         option = ''?'';'
        '         break;'
        '        }'
        '    }'
        '  return ( option );'
        '}'
        '']

  if (x <> []) then

    //## implicit case
    if impl_blk then
      Code=[Code;
            'int '+rdnom+'simblk_imp(t, x, xd, res)'
            ''
            '   double t, *x, *xd, *res;'
            ''
            '     /*'
            '      *  !purpose'
            '      *  compute state derivative of the continuous part'
            '      *  !calling sequence'
            '      *  NEQ   : a defined integer : the size of the  continuous state'
            '      *  t     : current time'
            '      *  x     : double precision vector whose contains the continuous state'
            '      *  xd    : double precision vector whose contains the computed derivative'
            '      *          of the state'
            '      *  res   : double precision vector whose contains the computed residual'
            '      *          of the state'
            '      */'
            '{'
            '  /* local variables used to call block */'
            '  int local_flag;']

      if act<>[] | cap<>[] then
        Code=[Code;
              '  int nport;']
      end

      Code=[Code;
            ''
            '  /* counter local variable */'
            '  int i;'
            '']

      if with_nrd then
        //## look at for block of type 0 (no captor)
        ind=find(funtyp==0)
        if ind<>[] then
          with_nrd2=%t
        else
          with_nrd2=%f
        end
//         with_nrd2=%f;
//         for k=1:size(ind,2)
//           if ~or(oord([ind(k)],1)==cap) then
//             with_nrd2=%t;
//             break;
//           end
//         end
        if with_nrd2 then
          Code=[Code;
                '  /* Variables for constant values */'
                '  int nrd_1, nrd_2;'
                ''
                '  double *args[100];'
                '']
        end
      end

      Code=[Code;
            '  /* set phase simulation */'
            '  phase=2;'
            ''
            '  /* initialization of residual */'
            '  for(i=0;i<NEQ;i++) res[i]=xd[i];'
            '']

      Code=[Code;
            '  '+get_comment('update_xd',list())]

      for kf=1:nblk
        if (xptr(kf+1)-xptr(kf)) > 0 then
          Code=[Code;
                '  block_'+rdnom+'['+string(kf-1)+'].x='+...
                  '&(x['+string(xptr(kf)-1)+']);'
                '  block_'+rdnom+'['+string(kf-1)+'].xd='+...
                  '&(xd['+string(xptr(kf)-1)+']);'
                '  block_'+rdnom+'['+string(kf-1)+'].res='+...
                  '&(res['+string(xptr(kf)-1)+']);']
        end
      end

      Code=[Code;
            ''
            write_code_odoit(1)
            write_code_odoit(0)
           ]

      Code=[Code
            ''
            '  return 0;'
            '}'
            ''
            '/* DAE Method */'
            'int dae1(f,x,xd,res,t,h)'
            '  int (*f) ();'
            '  double *x,*xd,*res;'
            '  double t, h;'
            '{'
            '  int i;'
            '  int ierr;'
            ''
            '  /**/'
            '  ierr=(*f)(t,x, xd, res);'
            '  if (ierr!=0) return ierr;'
            ''
            '  for (i=0;i<NEQ;i++) {'
            '   x[i]=x[i]+h*xd[i];'
            '  }'
            ''
            '  return 0;'
            '}']
    //## explicit case
    else
      Code=[Code;
            'int '+rdnom+'simblk(t, x, xd)'
            ''
            '   double t, *x, *xd;'
            ''
            '     /*'
            '      *  !purpose'
            '      *  compute state derivative of the continuous part'
            '      *  !calling sequence'
            '      *  NEQ   : a defined integer : the size of the  continuous state'
            '      *  t     : current time'
            '      *  x     : double precision vector whose contains the continuous state'
            '      *  xd    : double precision vector whose contains the computed derivative'
            '      *          of the state'
            '      */'
            '{'
            '  /* local variables used to call block */'
            '  int local_flag;']

      if act<>[] | cap<>[] then
        Code=[Code;
              '  int nport;']
      end

      Code=[Code;
            ''
            '  /* counter local variable */'
            '  int i;'
            '']

      if with_nrd then
        //## look at for block of type 0 (no captor)
        ind=find(funtyp==0)
        if ind<>[] then
          with_nrd2=%t
        else
          with_nrd2=%f
        end
//         with_nrd2=%f;
//         for k=1:size(ind,2)
//           if ~or(oord([ind(k)],1)==cap) then
//             with_nrd2=%t;
//             break;
//           end
//         end
        if with_nrd2 then
          Code=[Code;
                '  /* Variables for constant values */'
                '  int nrd_1, nrd_2;'
                ''
                '  double *args[100];'
                '']
        end
      end

      Code=[Code;
            '  /* set phase simulation */'
            '  phase=2;'
            ''
            '  /* initialization of derivatives */'
            '  for(i=0;i<NEQ;i++) xd[i]=0.;'
            '']

      Code=[Code;
            '  '+get_comment('update_xd',list())]

      for kf=1:nblk
        if (xptr(kf+1)-xptr(kf)) > 0 then
          Code=[Code;
                '  block_'+rdnom+'['+string(kf-1)+'].x='+...
                  '&(x['+string(xptr(kf)-1)+']);'
                '  block_'+rdnom+'['+string(kf-1)+'].xd='+...
                  '&(xd['+string(xptr(kf)-1)+']);']
        end
      end

      Code=[Code;
            ''
            write_code_odoit(1)
            write_code_odoit(0)
           ]

      Code=[Code
            ''
            '  return 0;'
            '}'
            ''
            '/* Euler''s Method */'
            'int ode1(f,x,xd,t,h)'
            '  int (*f) ();'
            '  double *x,*xd;'
            '  double t, h;'
            '{'
            '  int i;'
            '  int ierr;'
            ''
            '  /**/'
            '  ierr=(*f)(t,x, xd);'
            '  if (ierr!=0) return ierr;'
            ''
            '  for (i=0;i<NEQ;i++) {'
            '   x[i]=x[i]+h*xd[i];'
            '  }'
            ''
            '  return 0;'
            '}'
            ''
            '/* Heun''s Method */'
            'int ode2(f,x,xd,t,h)'
            '  int (*f) ();'
            '  double *x,*xd;'
            '  double t, h;'
            '{'
            '  int i;'
            '  int ierr;'
            '  double y['+string(nX)+'],yh['+string(nX)+'],temp,f0['+string(nX)+'],th;'
            ''
            '  /**/'
            '  memcpy(y,x,NEQ*sizeof(double));'
            '  memcpy(f0,xd,NEQ*sizeof(double));'
            ''
            '  /**/'
            '  ierr=(*f)(t,y, f0);'
            '  if (ierr!=0) return ierr;'
            ''
            '  /**/'
            '  for (i=0;i<NEQ;i++) {'
            '    x[i]=y[i]+h*f0[i];'
            '  }'
            '  th=t+h;'
            '  for (i=0;i<NEQ;i++) {'
            '    yh[i]=y[i]+h*f0[i];'
            '  }'
            '  ierr=(*f)(th,yh, xd);'
            '  if (ierr!=0) return ierr;'
            ''
            '  /**/'
            '  temp=0.5*h;'
            '  for (i=0;i<NEQ;i++) {'
            '    x[i]=y[i]+temp*(f0[i]+xd[i]);'
            '  }'
            ''
            '  return 0;'
            '}'
            ''
            '/* Fourth-Order Runge-Kutta (RK4) Formula */'
            'int ode4(f,x,xd,t,h)'
            '  int (*f) ();'
            '  double *x,*xd;'
            '  double t, h;'
            '{'
            '  int i;'
            '  int ierr;'
            '  double y['+string(nX)+'],yh['+string(nX)+'],'+...
              'temp,f0['+string(nX)+'],th,th2,'+...
              'f1['+string(nX)+'],f2['+string(nX)+'];'
            ''
            '  /**/'
            '  memcpy(y,x,NEQ*sizeof(double));'
            '  memcpy(f0,xd,NEQ*sizeof(double));'
            ''
            '  /**/'
            '  ierr=(*f)(t,y, f0);'
            '  if (ierr!=0) return ierr;'
            ''
            '  /**/'
            '  for (i=0;i<NEQ;i++) {'
            '    x[i]=y[i]+h*f0[i];'
            '  }'
            '  th2=t+h/2;'
            '  for (i=0;i<NEQ;i++) {'
            '    yh[i]=y[i]+(h/2)*f0[i];'
            '  }'
            '  ierr=(*f)(th2,yh, f1);'
            '  if (ierr!=0) return ierr;'
            ''
            '  /**/'
            '  temp=0.5*h;'
            '  for (i=0;i<NEQ;i++) {'
            '    x[i]=y[i]+temp*f1[i];'
            '  }'
            '  for (i=0;i<NEQ;i++) {'
            '    yh[i]=y[i]+(h/2)*f1[i];'
            '  }'
            '  ierr=(*f)(th2,yh, f2);'
            '  if (ierr!=0) return ierr;'
            ''
            '  /**/'
            '  for (i=0;i<NEQ;i++) {'
            '    x[i]=y[i]+h*f2[i];'
            '  }'
            '  th=t+h;'
            '  for (i=0;i<NEQ;i++) {'
            '    yh[i]=y[i]+h*f2[i];'
            '  }'
            '  ierr=(*f)(th2,yh, xd);'
            '  if (ierr!=0) return ierr;'
            ''
            '  /**/'
            '  temp=h/6;'
            '  for (i=0;i<NEQ;i++) {'
            '    x[i]=y[i]+temp*(f0[i]+2.0*f1[i]+2.0*f2[i]+xd[i]);'
            '  }'
            ''
            '  return 0;'
            '}']
    end
  end

  //@@ addevs function
  if ALL & size(evs,'*')<>0 then
    Code=[Code;
          ''
          '/* addevs function */'
          'void '+rdnom+'_addevs(agenda_struct *ptr, double t, int evtnb)'
          '{'
          '  int i,j;'
          '']

    if debug_cdgen then
      Code=[Code;
            '  fprintf(stderr,""addevs (begin)\n \tpointi=%d\n \tevtnb=%d\n \tptr->evtspt[evtnb-1]=%d\n \tt=%f\n"", \'
            '                 ptr->pointi,evtnb,ptr->evtspt[evtnb-1],t);'
            '']
    end

    Code=[Code;
          '  /*  */'
          '  if (ptr->evtspt[evtnb-1] != -1) {'
          '    if ((ptr->evtspt[evtnb-1] == 0) && (ptr->pointi==evtnb)) {'
          '      ptr->tevts[evtnb-1] = t;'
          '      return;'
          '    }'
          '    /* */'
          '    else {'
          '      /* (ptr->pointi == evtnb) && ((ptr->evtspt[evtnb] == 0) || (ptr->evtspt[evtnb] != 0)) */'
          '      if (ptr->pointi == evtnb) {'
          '        ptr->pointi = ptr->evtspt[evtnb-1]; /* remove from chain, pointi is now the event provided by ptr->evtspt[evtnb] */'
          '      }'
          '      /* (ptr->pointi != evtnb) && ((ptr->evtspt[evtnb] == 0) || (ptr->evtspt[evtnb] != 0)) */'
          '      else {'
          '        /* find where is the event to be updated in the agenda */'
          '        i = ptr->pointi;'
          '        while (evtnb != ptr->evtspt[i-1]) {'
          '          i = ptr->evtspt[i-1];'
          '        }'
          '        ptr->evtspt[i-1] = ptr->evtspt[evtnb-1]; /* remove old evtnb from chain */'
          ''
          '        /* if (TCritWarning == 0) {'
          '         *  sciprint(""\n\r Warning:an event is reprogrammed at t=%g by removing another"",t );'
          '         *  sciprint(""\n\r         (already programmed) event. There may be an error in"");'
          '         *  sciprint(""\n\r         your model. Please check your model\n\r"");'
          '         *  TCritWarning=1;'
          '         * }'
          '         */'
          ''
          '        do_cold_restart(); /* the erased event could be a critical event, '
          '                            * so do_cold_restart is added to'
          '                            * refresh the critical event table'
          '                            */'
          '      }'
          ''
          '      /* */'
          '      ptr->evtspt[evtnb-1] = 0;'
          '      ptr->tevts[evtnb-1]  = t;'
          '    }'
          '  }'
          '  else {'
          '    ptr->evtspt[evtnb-1] = 0;'
          '    ptr->tevts[evtnb-1]  = t;'
          '  }'
          ''
          '  /* */'
          '  if (ptr->pointi == 0) {'
          '    ptr->pointi = evtnb;'
          '    return;'
          '  }'
          '  if (t < ptr->tevts[ptr->pointi-1]) {'
          '    ptr->evtspt[evtnb-1] = ptr->pointi;'
          '    ptr->pointi = evtnb;'
          '    return;'
          '  }'
          ''
          '  /* */'
          '  i = ptr->pointi;'
          ''
          ' L100:'
          '  if (ptr->evtspt[i-1] == 0) {'
          '    ptr->evtspt[i-1] = evtnb;'
          '    return;'
          '  }'
          '  if (t >= ptr->tevts[ptr->evtspt[i-1]-1]) {'
          '    j = ptr->evtspt[i-1];'
          '    if (ptr->evtspt[j-1] == 0) {'
          '      ptr->evtspt[j-1] = evtnb;'
          '      return;'
          '    }'
          '    i = j;'
          '    goto L100;'
          '  }'
          '  else {'
          '    ptr->evtspt[evtnb-1] = ptr->evtspt[i-1];'
          '    ptr->evtspt[i-1] = evtnb;'
          '  }'
          '']

    if debug_cdgen then
      Code=[Code;
            '  fprintf(stderr,""addevs (end), pointi=%d\n"",ptr->pointi);'
            '']
    end

    Code=[Code;
          '  return;'
          '}'
         ]
  end

endfunction

function [Code,Code_xml_param]=make_standalone43()
//Copyright (c) 1989-2010 Metalau project INRIA

//@@ make_standalone43() : generates code of the standalone simulation procedure
//
// Output : Code : text of the generated routines
//          Code_xml_param : parameters file map
//

  //@@ define cpr ptr
  x      = cpr.state.x;
  modptr = cpr.sim.modptr
  rpptr  = cpr.sim.rpptr
  ipptr  = cpr.sim.ipptr
  opptr  = cpr.sim.opptr
  rpar   = cpr.sim.rpar
  ipar   = cpr.sim.ipar
  opar   = cpr.sim.opar
  oz     = cpr.state.oz
  ordptr = cpr.sim.ordptr
  oord   = cpr.sim.oord
  zord   = cpr.sim.zord
  iord   = cpr.sim.iord
  tevts  = cpr.state.tevts
  evtspt = cpr.state.evtspt
  zptr   = cpr.sim.zptr
  ozptr  = cpr.sim.ozptr
  clkptr = cpr.sim.clkptr
  ordptr = cpr.sim.ordptr
  pointi = cpr.state.pointi
  funs   = cpr.sim.funs
  funtyp = cpr.sim.funtyp
  noord  = size(cpr.sim.oord,1)
  nzord  = size(cpr.sim.zord,1)
  niord  = size(cpr.sim.iord,1)
  ng     = cpr.sim.zcptr($)-1
  nmod   = cpr.sim.modptr($)-1
  nX     = size(x,'*')

  //@@ define indentation variable
  Indent    = '  ';
  Indent2   = Indent+Indent;
  BigIndent = '          ';

  //@@ define stalone variable
  stalone = %t;

  //@@ define blks variable
  blks=find(funtyp>-1);

  //## rmk: we can remove a 'bidon' structure
  //## sometimes at the end
  if funs(nblk)=='bidon' then nblk=nblk-1, end;

  //## with_nrd2 : find blk type 0 (wihtout)
  //   should be pass in do_compile_superblock
  with_nrd2=%f;
  for blk=blks
    //## all blocks without sensor/actuator
    if (part(funs(blk),1:7) ~= 'capteur' &...
        part(funs(blk),1:10) ~= 'actionneur' &...
        funs(blk) ~= 'bidon') then
      //## with_nrd2 ##//
      if funtyp(blk)==0 then
        with_nrd2=%t;
      end
    end
  end

  //** evs : find source activation number
  evs=[];
  if ~ALL then
    for blk=blks
      for ev=clkptr(blk):clkptr(blk+1)-1
        if funs(blk)=='bidon' then
          if ev > clkptr(howclk) -1
           evs=[evs,ev]
          end
        end
      end
    end
  else
    for blk=blks
      for ev=clkptr(blk):clkptr(blk+1)-1
        if funs(blk)=='agenda_blk' then
          nb_agenda_blk=blk
          evs=[evs,ev]
        end
      end
    end
  end

  //@@ main header
  Code=['/* Code prototype for standalone use  */'
        '/*     Generated by Code_Generation toolbox of Scicos with '+ ..
        get_scicos_version()+' */'
        '/*     date : '+date()+' */'
        ''
        '/* Copyright (c) 1989-2010 Metalau project INRIA */'
        ''
        '/* To learn how to use the standalone code, type '"./standalone -h'" */'
        '']

  //@@ standard C headers
  Code=[Code;
        '/* ---- Standard C headers ---- */'
        '#include <stdio.h>'
        '#include <stdlib.h>'
        '#include <math.h>'
        '#include <string.h>'
        '#ifdef __STDC__'
        '#include <stdarg.h>'
        '#else'
        '#ifdef __MSC__'
        '#include <stdarg.h>'
        '#else'
        '#include <varargs.h>'
        '#endif'
        '#endif'
        '/* #include <memory.h> */'
        '']

  //@@ scicoslab headers
  Code=[Code;
        '/* ---- ScicosLab headers ---- */'
        '#include '"scicos_block4.h'"'
        '#include '"machine.h'"'
        '']

  //@@ solver headers
  if ALL & nX<>0 then
    Code=[Code;
          '/* ---- Solver headers ---- */']

    if impl_blk then
      Code=[Code;
            '#include ""solver/ida.h""'
            '#include ""solver/ida_dense.h""'
            '#include ""solver/ida_impl.h""']
    else
      Code=[Code;
            '#include ""solver/cvode.h""'
            '#include ""solver/cvode_dense.h""']
    end

    Code=[Code;
          '#include ""solver/nvector_serial.h""'
          '#include ""solver/sundials_types.h""'
          '#include ""solver/sundials_math.h""'
          '']
  end

  //@@ C useful macros
  if ALL then
    Code=[Code;
          '/* ---- Define useful macros ---- */'
          '#define abs(x)   ((x) >=  0  ? (x) : -(x))'
          '#define max(a,b) ((a) >= (b) ? (a) : (b))'
          '#define min(a,b) ((a) <= (b) ? (a) : (b))']
     if impl_blk then
       Code=[Code;
             '#define T0   RCONST(0.0)'
             '#define ZERO RCONST(0.0)'
             '#define ONE  RCONST(1.0)']
     else
       Code=[Code;
             '#define T0 RCONST(0.0)']
     end
     Code=[Code;
           '']
  end

  //*** Continuous state ***//
  if x <> [] then
    Code=[Code;
          '/* ---- Define number of continuous state ---- */']
    if impl_blk then //## implicit block
      Code=[Code;
            '#define NEQ '+string(nX/2)]
    else             //## explicit block
      Code=[Code;
            '#define NEQ '+string(nX)]
    end
    Code=[Code;
          '']
  end

  //## cosend
  //## to properly handle error in standalone
  Code_end=[''
            '  '+get_comment('flag',list(5))]

  for kf=1:nblk
    if or(kf==act) | or(kf==cap) then
        txt = call_block42(kf,0,5);
        if txt <> [] then
          Code_end=[Code_end;
                    '';
                    '  '+txt];
        end
    else
      txt = call_block42(kf,0,5);
      if txt <> [] then
        Code_end=[Code_end;
                  '';
                  '  '+txt];
      end
    end
  end

  //@@ Cosend in a C macro
  Code_end_mac=['#define Cosend() '+Code_end(1)+'\']
  for i=2:size(Code_end,1)
    if i<>size(Code_end,1) then
      len=length(Code_end(i))
      if len <> 0 then
        if part(Code_end(i),len)<>'\' then
           Code_end_mac($+1)=Code_end(i) + '\'
        else
           Code_end_mac($+1)=Code_end(i)
        end
      else
        Code_end_mac($+1)='  \'
      end
    else
      Code_end_mac($+1)=Code_end(i)
    end
  end

  Code_end_mac=[Code_end_mac;
                '/* Define Cosend macro */'
                Code_end_mac
                '']

  //@@ Cosend in a function
  Code_end_fun=['/*'+part('-',ones(1,40))+' Cosend function */'
                'int '+rdnom+'_cosend()'
                '{'
                '  /* local variables used to call block */'
                '  int local_flag,i;']
  if act<>[] | cap<>[] then
    Code_end_fun=[Code_end_fun;
                  '  int nport;']
  end
  if (with_nrd & with_nrd2) then
    Code_end_fun=[Code_end_fun;
                  ''
                  '  /* Variables for constant values */'
                  '  int nrd_1, nrd_2;'
                  '  double *args[100];']
  end
  Code_end_fun=[Code_end_fun;
                ''
                '  double t;'
                ''
                '  /* get scicos_time */'
                '  t = scicos_time;']

  Code_end_fun=[Code_end_fun
                Code_end
                ''
                '  /* return block_error */'
                '  return get_block_error();'
                '}']

  //@@ free allocated array by solver
  Code_Free=[]
  if ALL & nX<>0 then
    Code_Free=['/* free allocated array by solver */']
    if impl_blk then  // DAE case
      Code_Free=[Code_Free
                 'free(ida_data->rwork);'
                 'N_VDestroy_Serial(ida_data->ewt);']

      if ng<>0 then
        Code_Free=[Code_Free
                   'free(ida_data->gwork);']
      end
      Code_Free=[Code_Free
                 'free(ida_data);'
                 'IDAFree(&ida_mem);'
                 'N_VDestroy_Serial(IDx);'
                 'N_VDestroy_Serial(yp);'
                 'N_VDestroy_Serial(yy);']
    else  // ODE case
      Code_Free=[Code_Free
                 'CVodeFree(&cvode_mem);'
                 'N_VDestroy_Serial(y);']
    end
  end

  //@@ (re)Build Protostalone
  Protostalone=[];pacbn=0;tcabn=0;tcabn_dummy=0;dfuns=[]
  for i=1:length(funs)
    //## block is a sensor
    if or(i==cap) then
      pacbn = pacbn+1;
      if pacbn==1 then
        Protostalone=[Protostalone;
                      ''
                      +get_comment('proto_sensor')
                      'void '+rdnom+'_sensor(int *, int *, int *, double *, void *, \';
                      get_blank(rdnom)+'             int *, int *, int *, int, void *);']
      end
    //## block is an actuator
    elseif or(i==act) then
      if strindex(funs(i),"dummy")<>[] then
        tcabn_dummy=tcabn_dummy+1;
        if tcabn_dummy==1 then
          Protostalone=[Protostalone;
                        ''
                        +get_comment('proto_actuator')
                        'void '+rdnom+'_dummy_actuator(int *, int *, int *, double *, \';
                        get_blank(rdnom)+'                     int, void *);']
        end
      else
        tcabn=tcabn+1;
        if tcabn==1 then
          Protostalone=[Protostalone;
                        ''
                        +get_comment('proto_actuator')
                        'void '+rdnom+'_actuator(int *, int *, int *, double *, void *, \';
                        get_blank(rdnom)+'               int *, int *, int *, int, void *);']
        end
      end
    //## all other types of blocks excepts evt sensors and evt actuators
    else
      if funs(i)<>'bidon' & funs(i)<>'bidon2' then
        ki=find(funs(i)==dfuns)
        dfuns=[dfuns;funs(i)]
        if ki==[] then
          Protostalone=[Protostalone;'';BlockProto(i)];
        end
      end
    end
  end

  //@@ prototypes of used computational function
  Code=[Code;
        '/* ---- Internals functions and global variables declaration ---- */'
        Protostalone]

  //@@ simulation function declaration
  if ALL then
    Code=[Code;
          '/* ---- Parameters structure ---- */'
          'typedef struct {'
          '  char *filen;'
          '  double tf;'
          '} params_struct ;'
          '']
  end

  if ~ALL then
    Code=[Code
          '/* Prototype for input simulation function */'
          'int '+rdnom+'_sim(double, double, double, int, \'
          '                  int *, void **, int *, void **);'
          '']
  else
    Code=[Code
          '/* ----  Prototype for input simulation function ----  */'
          'int '+rdnom+'_sim(params_struct, int *, void **, int *, void **);'
          '']
    //@@ cosend function declaration
    Code=[Code
          '/* ----  Prototype for cosend function ----  */'
          'int '+rdnom+'_cosend();'
          '']
  end

  //@@ agenda struct and function declaration
  if ALL & size(evs,'*')<>0 then
    Code=[Code;
          '/* ---- Internal agenda ---- */'
          'typedef struct {'
          '  int pointi;'
          '  int fromflag3;'
          '  int old_pointi;'
          '  int evtspt['+string(size(evs,'*'))+'];'
          '  double tevts['+string(size(evs,'*'))+'];'
          '  int critev['+string(size(evs,'*'))+'];'
          '} agenda_struct ;'
          ''
          'void '+rdnom+'_addevs(agenda_struct *, double, int);'
          '']
  end

  //@@ solver function prototype and structure declaration
  if ALL then
    //@@ DAE case
    if impl_blk then
      if x<>[] then
        Code=[Code
              '/* ---- Solver functions prototype for standalone use ---- */'
              'int '+rdnom+'_simblkdaskr(realtype tres, N_Vector yy, N_Vector yp, N_Vector resval, void *rdata);'
              '']

        if ng<>0 then
          Code=[Code
                'int '+rdnom+'_grblkdaskr(realtype t, N_Vector yy, N_Vector yp, realtype *gout, void *g_data);'
                '']
        end

        //@@ TODO : check if Jacobians is enable
        Code=[Code;
              'int '+rdnom+'_Jacobians(long int Neq, realtype, N_Vector, N_Vector, N_Vector, \'
              '              realtype, void *, DenseMat, N_Vector, N_Vector, N_Vector);'
              '']
        //@@ Mult : to be removed
        Code=[Code;
              'void '+rdnom+'_Multp(double *, double *,double *, int, int, int ,int);'
              '']

        Code=[Code;
             '/* ---- Declaration of IDA data structure ---- */'
              'typedef struct {'
              '  void *ida_mem;'
              '  N_Vector ewt;'
              '  double *rwork;'
              '  int *iwork;'
              '  double *gwork;'
              '} *User_IDA_data;'
              '']
      end

      Code=[Code;
            '/* ---- Declaration of Jacobian variables ---- */'
            'int Jacobian_Flag;'
            'int AJacobian_block;'
            'double CI, CJ;'
            'double SQuround;'
            '']

    //@@ ODE case
    else
      if x<>[] then
        Code=[Code
              '/* ---- Solver functions prototype for standalone use ---- */'
              'int '+rdnom+'_simblk(realtype tx, N_Vector yy, N_Vector yp, void *f_data);'
              '']

        if ng<>0 then
          Code=[Code
                'int '+rdnom+'_grblk(realtype tx, N_Vector yy, realtype *gout, void *g_data);'
                '']
        end

        Code=[Code;
             '/* ---- Declaration of CVODE data structure ---- */'
              'typedef struct {'
              '  void *cvode_mem;'
              '} User_CV_data;'
              '']
      end
    end

    //@@ Sfcallerid declaration
    Code=[Code;
          '/* ---- Declaration of Sfcallerid variable ---- */'
          'int Sfcallerid;'
          '']

  else
    if impl_blk then
      if x<>[] then
        Code=[Code
              '/* ---- Solver functions prototype for standalone use ---- */'
              'int '+rdnom+'simblk_imp(double , double *, double *, double *);'
              'int dae1();'
              '']
      end
    else
      if x<>[] then
        Code=[Code
              '/* ---- Solver functions prototype for standalone use ---- */'
              'int '+rdnom+'_simblk(double , double *, double *);'
              'int ode1();'
              'int ode2();'
              'int ode4();'
              '']
      end
    end
  end

  //@@ 'main' functions variables and functions declaration
  Code=[Code;
        '/* ---- Specific declarations for the main() function ---- */'
        'int getopt(int, char **, char *);'
        'static int optind = 1;'
        'static void usage(char *);'
        '']

  //@@ simulator global variable declaration
  Code=[Code;
        '/* ---- Declaration of phase variable ---- */'
        'int phase;'
        ''
        '/* ---- Declaration of scicos current time variable ---- */'
        'double scicos_time;'
        '']

  if ALL & nX<>0 then
    Code=[Code;
          '/* ---- Declaration of solver restart variable ---- */'
          'int hot;'
          '']
  end

  //@@ error function(s) and variable(s) declaration
  Code=[Code
        '/* ---- Declaration of error variables ---- */'
        'int *block_error;'
        'char err_msg[2048];'
        ''
        '/* ---- Prototype of error table function ---- */'
        'void geterr(int ierr, char *err_msg);'
        ''
        '/* ---- Declaration of block_number variable ---- */'
        'int block_number;'
        '']

  //@@ block structures declaration
  Code=[Code;
        '/* ---- Declaration of scicos block structures ---- */'
        'scicos_block block_'+rdnom+'['+string(nblk)+'];'
        '']

  //@@@@----@@@@
  filen = rpat+'/'+rdnom+'_params.dat'
  fpp   = mopen(filen,'wb');

  //@@ main() function
  Code=[Code;
        '/*'+part('-',ones(1,40))+' main function */']

  Code=[Code;
        'int main(int argc, char *argv[])'
        '{'
        '  /* main() variables */'
        '  char input[50],output[50],data[256];'
        '  char **p = NULL;'
        '  char * progname = argv[0];'
        '  FILE *fp;'
        '']

  Code=[Code;
        '  /* file name variable to write parameters */'
        '  char filen[]=""'+rdnom+'_params.dat"";']

  //@@ adjust path of parameters file for
  //@@ scicoslab interfacing function
  if MSDOS then
    Code=[Code
          '  char rpatfilen[] = ""'+rpat+'\'+rdnom+'_params.dat"";']
    if strindex(Code($),'\\')==[] then
      Code($)=strsubst(Code($),'\','\\')
    end
  else
    Code=[Code
          '  char rpatfilen[] = ""'+rpat+'/'+rdnom+'_params.dat"";']
  end

  Code=[Code;
        '  /* parameters structure for simulation function */'
        '  params_struct params;'
        '']

  Code=[Code;
        '  /* local counter variable */'
        '  int c,i;'
        ''
        '  /* error handling variable */'
        '  int ierr;'
        '']

  if ALL then
    Code=[Code;
          '  /* parameters of _sim function */']

    //@@ look at for end block
    Tfin=[]
    for i=1:nblk
      if funs(i)=='scicosexit' then
        Tfin=cpr.state.tevts(clkptr(i))
      end
    end

    if Tfin==[] then Tfin=scs_m.props.tf, end

    Code=[Code;
          '  double tf = -1.;        /* final time */']
  else
    Code=[Code;
          '  /* default values for parameters of _sim function */'
          '  double tf = 30;         /* final time */']
  end

  if ~ALL then
    Code=[Code;
          '  double dt = 0.1;         /* clock time */'
          '  double h  = 0.001;       /* solver step */']

    if impl_blk then
      Code=[Code;
            '  int solver = 3;         /* type of solver */']
    else
      Code=[Code;
            '  int solver = 1;         /* type of solver */']
    end
  end

  Code_in=[]
  if size(capt,1)>0 then
    Code_in='  int nin       = '+string(size(capt,1))+';'
    Code_in=[Code_in;
             cformatline('  int typin[]   = {'+...
                  strcat(string(zeros(size(capt,1),1)),"," )+'};',70)]
    Code_in=[Code_in;
             cformatline('  void *inptr[] = {'+...
                  strcat(string(zeros(size(capt,1),1)),"," )+'};',70)]
  end
  if Code_in<>[] then
    Code=[Code;
          ''
          '  /* variables for sensors */'
          Code_in]
  else
    Code=[Code;
          ''
          '  /* variables for sensors */'
          '  int nin      = 0;'
          '  int *typin   = NULL;'
          '  void **inptr = NULL;']
  end

  Code_out=[]
  if size(actt,1)>0 then
    Code_out='  int nout       = '+string(size(actt,1))+';'
    Code_out=[Code_out;
              cformatline('  int typout[]   = {'+...
                  strcat(string(zeros(size(actt,1),1)),"," )+'};',70)]
    Code_out=[Code_out;
             cformatline('  void *outptr[] = {'+...
                  strcat(string(zeros(size(actt,1),1)),"," )+'};',70)]
  end
  if Code_out<>[] then
    Code=[Code;
          ''
          '  /* variables for actuators */'
          Code_out]
  else
    Code=[Code;
          ''
          '  /* variables for actuators */'
          '  int nout      = 0;'
          '  int *typout   = NULL;'
          '  void **outptr = NULL;']
  end

  Code=[Code;
        ''
        '  /* init input/output files name */'
        '  strcpy(input,'"'");'
        '  strcpy(output,'"'");'
        ''
        '  /* init parameters file name */'
        '  strcpy(data,'"'");'
        ''
        '  /* check rhs args */'
        '  while ((c = getopt(argc , argv, '"i:o:p:d:t:e:s:hv'")) != -1)'
        '    switch (c) {'
        '    case ''i'':'
        '      strcpy(input,argv[optind-1]);'
        '      break;'
        '    case ''o'':'
        '      strcpy(output,argv[optind-1]);'
        '      break;'
        '    case ''p'':'
        '      strcpy(data,argv[optind-1]);'
        '      break;']

  if ~ALL then
    Code=[Code;
          '    case ''d'':'
          '      dt = strtod(argv[optind-1],p);'
          '      break;']
  end

  Code=[Code;
        '    case ''t'':'
        '      tf = strtod(argv[optind-1],p);'
        '      break;']

  if ~ALL then
    Code=[Code;
          '    case ''e'':'
          '      h = strtod(argv[optind-1],p);'
          '      break;'
          '    case ''s'':'
          '      solver = (int) strtod(argv[optind-1],p);'
          '      break;']
  end

  Code=[Code;
        '    case ''h'':'
        '      usage(progname);'
        '      return 0;'
        '      break;'
        '    case ''v'':'
        '      printf(""Generated by Code_Generation toolbox of Scicos ""'
        '             ""with '+get_scicos_version()+'\n"");'
        '      return 0;'
        '      break;'
        '    case ''?'':'
        '      usage(progname);'
        '      return 0;'
        '      break;'
        '    }'
        '']

  Code=[Code;
        '  /* set in/out of sensors/actuators */'
        '  if (strlen(input) > 0) {'
        '    for(i=0;i<nin;i++) {'
        '      typin[i] = 1;'
        '      inptr[i] = (void *) input;'
        '    }'
        '  }'
        '  if (strlen(output)> 0) {'
        '    for(i=0;i<nout;i++) {'
        '      typout[i] = 1;'
        '      outptr[i] = (void *) output;'
        '    }'
        '  }'
        '']

  Code=[Code;
        '  /* set parameters file name */'
        '  if (strlen(data) > 0) {'
        '    params.filen = data;'
        '  }'
        '  else {'
        '    /* open parameters data file */'
        '    if ((fp = fopen(rpatfilen,""rb"")) == NULL) {'
        '      params.filen = filen;'
        '    }'
        '    else {'
        '      fclose(fp);'
        '      params.filen = rpatfilen;'
        '    }'
        '  }'
        ''
        ]

  Code_xml_param=[];

  if ALL then
    code_to_write_params('&tf',Tfin,fpp)
    Code_xml_param=[Code_xml_param;
                    get_xml_param_code('tf',Tfin)]

    Code=[Code
          '  /* set parameters structure */'
          '  params.tf    = tf;'
          '']
  end

  if ~ALL then
    Code=[Code;
          '  /* call simulation function */'
          '  ierr = '+rdnom+'_sim(tf,dt,h,solver,typin,inptr,typout,outptr);']
  else
    Code=[Code;
          '  /* call simulation function */'
          '  ierr = '+rdnom+'_sim(params,typin,inptr,typout,outptr);']
  end

  Code=[Code;
        '']

  Code=[Code;
        '  /* display error message */'
        '  if (ierr != 0) {'
        '    geterr(ierr,err_msg);'
        '    fprintf(stderr,""Simulation fails with error number %d :'+...
             '\n%s\n"",ierr,err_msg);'
        '  }'
        ''
        '  /* return error number */'
        '  return ierr;'
        '}'
        '']

  //@@ usage definition
  Code=[Code;
        '/*'+part('-',ones(1,40))+' usage function */'
        'static void usage(char *prog)'
        '{']

  if ALL then
    Code=[Code;
          '  fprintf(stderr, ""Usage: %s [-h] [-v] [-i arg] [-o arg] ""'
          '                  ""[-d arg] [-t arg]\n"", prog);'
          '  fprintf(stderr, ""Options : \n"");'
          '  fprintf(stderr, ""     -h for the help  \n"");'
          '  fprintf(stderr, ""     -v for printing the Scicos Version \n"");'
          '  fprintf(stderr, ""     -i for input file name, by default is Terminal \n"");'
          '  fprintf(stderr, ""     -o for output file name, by default is Terminal \n"");'
          '  fprintf(stderr, ""     -t for the final time, by default is '+sprintf("%e",scs_m.props.tf)+' \n"");'
          '  fprintf(stderr, ""     -p for input parameters file name, by default is '+rdnom+'_params.dat\n"");']
  else
    Code=[Code;
          '  fprintf(stderr, ""Usage: %s [-h] [-v] [-i arg] [-o arg] ""'
          '                  ""[-d arg] [-t arg] [-e arg] [-s arg]\n"", prog);'
          '  fprintf(stderr, ""Options : \n"");'
          '  fprintf(stderr, ""     -h for the help  \n"");'
          '  fprintf(stderr, ""     -v for printing the Scicos Version \n"");'
          '  fprintf(stderr, ""     -i for input file name, by default is Terminal \n"");'
          '  fprintf(stderr, ""     -o for output file name, by default is Terminal \n"");'
          '  fprintf(stderr, ""     -d for the clock period, by default is 0.1 \n"");'
          '  fprintf(stderr, ""     -t for the final time, by default is 30 \n"");'
          '  fprintf(stderr, ""     -e for the solvers step size, by default is 0.001 \n"");'
          '  fprintf(stderr, ""     -s integer parameter for select the numerical solver : \n"");']

    if impl_blk then
      Code=[Code;
            '  fprintf(stderr, ""        1 for a dae solver... \n"");']
    else
      Code=[Code;
            '  fprintf(stderr, ""        1 for Euler''s method \n"");'
            '  fprintf(stderr, ""        2 for Heun''s method \n"");'
            '  fprintf(stderr, ""        3 (default value) for the Fourth-Order Runge-Kutta'+...
             ' (RK4) Formula \n"");']
    end
  end

  Code=[Code;
        '}'
        '']

  //@@ getopt definition
  Code=[Code;
        '/*'+part('-',ones(1,40))+' getopt function */'
        'int getopt(int argc, char *argv[], char *optstring)'
        '{'
        '  char *group, option, *sopt;'
        '  char *optarg;'
        '  int len;'
        '  int offset = 0;'
        '  option = -1;'
        '  optarg = NULL;'
        '  while ( optind < argc )'
        '    {'
        '      group = argv[optind];'
        '      if ( *group != ''-'' )'
        '        {'
        '         option = -1;'
        '         optarg = group;'
        '         optind++;'
        '         break;'
        '        }'
        '      len = strlen (group);'
        '      group = group + offset;'
        '      if ( *group == ''-'' )'
        '        {'
        '         group++;'
        '         offset += 2;'
        '        }'
        '      else'
        '        offset++ ;'
        '      option = *group ;'
        '      sopt = strchr ( optstring, option ) ;'
        '      if ( sopt != NULL )'
        '        {'
        '         sopt++ ;'
        '         if ( *sopt == '':'' )'
        '           {'
        '             optarg = group + 1;'
        '             if ( *optarg == ''\0'' )'
        '                optarg = argv[++optind];'
        '             if ( *optarg == ''-'' )'
        '                {'
        '                 fprintf ( stderr, '"%s: illegal option -- %c \n'",'
        '                           argv[0], option );'
        '                 option = ''?'';'
        '                 break;'
        '                }'
        '             else'
        '                {'
        '                 optind++;'
        '                 offset = 0;'
        '                 break;'
        '                }'
        '           }'
        '         if ( offset >= len )'
        '           {'
        '             optind++;'
        '             offset = 0;'
        '           }'
        '         break;'
        '        }'
        '      else'
        '        {'
        '         fprintf ( stderr, '"%s: illegal option -- %c \n'", argv[0], option );'
        '         option = ''?'';'
        '         break;'
        '        }'
        '    }'
        '  return ( option );'
        '}'
        '']

  //@@ geterr definition
  Code=[Code;
        '/*'+part('-',ones(1,40))+' error table function */'
        'void geterr(int ierr, char *err_msg)'
        '{'
        '  switch (ierr)'
        '  {'
        '   case 1    : strcpy(err_msg,""scheduling problem"");'
        '               break;'
        ''
        '   case 2    : strcpy(err_msg,""input to zero-crossing stuck on zero"");'
        '               break;'
        ''
        '   case 3    : strcpy(err_msg,""event conflict"");'
        '               break;'
        ''
        '   case 4    : strcpy(err_msg,""algrebraic loop detected"");'
        '               break;'
        ''
        '   case 5    : strcpy(err_msg,""cannot allocate memory"");'
        '               break;'
        ''
        '   case 6    : strcpy(err_msg,""a block has been called with input out of its domain"");'
        '               break;'
        ''
        '   case 7    : strcpy(err_msg,""singularity in a block"");'
        '               break;'
        ''
        '   case 8    : strcpy(err_msg,""block produces an internal error"");'
        '               break;'
        ''
        '   case 10   : break;'
        ''
        '   case 1000 : strcpy(err_msg,""unable to find parameters data file"");'
        '               break;'
        ''
        '   case 1001 : strcpy(err_msg,""error while reading parameters in data file"");'
        '               break;'
        ''
        '   /* other scicos error should be done */'
        ''
        '   default : strcpy(err_msg,""undefined error"");'
        '             break;'
        '  }'
        '}'
        '']

  //@@ simulation function
  Code=[Code;
        '/*'+part('-',ones(1,40))+' simulation function */']

  //@@@@----@@@@
  Code_to_read_data = []

  if ~ALL then
    Code=[Code
          'int '+rdnom+'_sim(double tf, double dt, double h, int solver,\'
          get_blank(rdnom)+'         int *typin, void **inptr, int *typout, void **outptr)']
  else
    Code=[Code
          'int '+rdnom+'_sim(params_struct params, int *typin, void **inptr, int *typout, void **outptr)']
  end

  Code=[Code
        '{']

  Code=[Code;
        '  /* file descriptor to read parameters */'
        '  FILE *fpp;'
        '']

  Code=[Code
        '  /* simulator variables declaration */'
        '  double tf,told,t;';]


    Code=[Code
          '  double tsave;']


  Code=[Code
        '  double ttol;'
        '  double deltat;']

  if ALL & nX<>0 then
    Code=[Code;
          '  double tstop,rhotmp;'
          '  int kpo;']
  end

  //@@ solver variable declaration
  if ALL & nX<>0 then
    Code=[Code;
          ''
          '  /* solver variable declaration */']

    Code=[Code
          '  double rtol;'
          '  double atol;'
          '  double hmax;']

    if impl_blk then // DAE case
      Code=[Code;
            ''
            '  /* IDA variables declaration */'
            '  realtype reltol;'
            '  realtype abstol;'
            '  realtype mxstep;'
            '  N_Vector yy                = NULL;'
            '  N_Vector yp                = NULL;'
            '  N_Vector IDx               = NULL;'
            '  N_Vector bidon             = NULL;'
            '  N_Vector tempv1            = NULL;'
            '  N_Vector tempv2            = NULL;'
            '  N_Vector tempv3            = NULL;'
            '  User_IDA_data ida_data     = NULL;'
            '  IDAMem IDA_mem_ptr         = NULL;'
            '  DenseMat TJacque           = NULL;'
            '  realtype *scicos_xproperty = NULL;'
            '  realtype *Jacque_col;'
            '  void *ida_mem;'
            ''
            '  /* Jacobian variables declaration */'
            '  int  Jn, Jnx, Jno, Jni, Jactaille;'
            ''
            '  /* error flag solver variables declaration */'
            '  int flag;'
            '  int flagr;']
      if ng<>0 & nmod<>0 then
        Code=[Code;
              ''
              '  /* simulator mode variables declaration */'
              '  int Mode_save['+string(nmod)+'];'
              '  int Mode_change;']
      end
    else // ODE case
      Code=[Code;
            ''
            '  /* CVODE variables declaration */'
            '  realtype reltol;'
            '  realtype abstol;'
            '  realtype mxstep;'
            '  N_Vector y = NULL;'
            '  void *cvode_mem;'
            '  User_CV_data cv_data[]={{0}};'
            ''
            '  /* error flag solver variables declaration */'
            '  int flag;']
      if ng<>0 then
        Code=[Code;
              '  int flagr;']
      end
    end
  end

  //@@ nb : ng can be removed
  if ALL & ng<>0 then
    Code=[Code;
          ''
          '  /* zero crossing variables declaration */'
          '  int ng='+string(ng)+';'
          '  int Discrete_Jump;']
  end

  if ALL & size(evs,'*')<>0 then
    Code=[Code;
          ''
          '  /* internal agenda variables declaration */'
          '  agenda_struct ptr[]={{0}};'
          '  int kever;']
  end

  if ~ALL & evs<>[] then
    Code=[Code
          '  int nevprt=1;']
  end

  Code=[Code
        ''
        '  /* variables for block''s calling sequence */'
        '  int local_flag;'
        '  int nport;'
        '  int kf;'
        '']

  if (with_nrd & with_nrd2) then
    Code=[Code;
          '  /* variables for constant values */'
          '  int nrd_1, nrd_2;'
          '  double *args[100];'
          '']
  end

  txt=[]
  if with_synchro | impl_blk | ng<>0 then
    txt=[txt
         '  int i;']
  end

  if impl_blk & ng<>0 & nmod <>0 then
    txt=[txt
         '  int ii,j;']
  end

  if txt <> [] then
    Code=[Code
          '  /* local counter variables declaration */'
          txt
          '']
  end

  if (x <> []) & ~ALL then
    Code=[Code
          '  double tout;'
          '  double he=0.1;'
          '']
  end

  //## set a variable to trace error of block
  Code=[Code
        '  /* error variale declaration */'
        '  int err = 0;'
        '']

  Code=[Code
        '  /* Initial values */'
        '']

  if ALL then
    Code_read=[]
    Code_read=[Code_read
               '  /* open parameters data file */'
               '  if ((fpp = fopen(params.filen,""rb"")) == NULL) {'
               '    return(1000);'
               '  }'
               ''
               '  /* read final time of simulation */'
               '  if ((fread(&tf, sizeof(SCSREAL_COP), 1, fpp)) != 1) {'
               '    fclose(fpp);'
               '    return(1001);'
               '  }'
               '  if (params.tf != -1) tf = params.tf;'
               '']

    //@@@@----@@@@
    Code_read=[Code_read
               '  /* read tolerance on time */'
               '  '+get_code_to_read_params('&ttol',scs_m.props.tol(3),fpp)
               ''
               '  /* read maximun integration time interval */'
               '  '+get_code_to_read_params('&deltat',scs_m.props.tol(4),fpp)
               '']
    Code_xml_param=[Code_xml_param;
                    get_xml_param_code('ttol',scs_m.props.tol(3))]
    Code_xml_param=[Code_xml_param;
                    get_xml_param_code('deltat',scs_m.props.tol(4))]

    if nX<>0 then
      Code_read=[Code_read
                 '  /* read integrator relative tolerance */'
                 '  '+get_code_to_read_params('&rtol',scs_m.props.tol(2),fpp)
                 '']
      Code_xml_param=[Code_xml_param;
                      get_xml_param_code('rtol',scs_m.props.tol(2))]

      Code_read=[Code_read
                 '  /* set reltol for solver */'
                 '  reltol = (realtype) rtol;'
                 '']

      Code_read=[Code_read
                 '  /* read integrator absolute tolerance */'
                 '  '+get_code_to_read_params('&atol',scs_m.props.tol(1),fpp)
                 '']
      Code_xml_param=[Code_xml_param;
                      get_xml_param_code('atol',scs_m.props.tol(1))]

      Code_read=[Code_read
                 '  /* set abstol for solver */'
                 '  abstol = (realtype) atol;'
                 '']

      if size(scs_m.props.tol,'*')==7 then
        if scs_m.props.tol(7) > 0 then
          hmax=scs_m.props.tol(7)
        else
          hmax=Tfin/100
        end
      else
        hmax=Tfin/100
      end
      Code_read=[Code_read
                 '  /* read maximum step size */'
                 '  '+get_code_to_read_params('&hmax',hmax,fpp)
                 '']
      Code_xml_param=[Code_xml_param;
                      get_xml_param_code('hmax',hmax)]

      Code_read=[Code_read
                 '  /* set maximal time step for solver */'
                 '  mxstep = (realtype) hmax;'
                 '']
    end
  end

  //### Real parameters ###//
  if size(rpar,1) <> 0 then
    Code=[Code;
          '  /* Real parameters declaration */']
          //'static double RPAR1[ ] = {'];

    for i=1:(length(rpptr)-1)
      if rpptr(i+1)-rpptr(i)>0  then

        //** Add comments **//

        //## Modelica block
        if type(corinv(i))==15 then
          //## we can extract here all informations
          //## from original scicos blocks with corinv : TODO
          Code($+1)='  /* Modelica Block */';
        else
          if size(corinv(i),'*')==1 then
            OO=scs_m.objs(corinv(i));
          else
            path=list('objs');
            for l=cpr.corinv(i)(1:$-1)
              path($+1)=l;
              path($+1)='model';
              path($+1)='rpar';
              path($+1)='objs';
            end
            path($+1)=cpr.corinv(i)($);
            OO=scs_m(path);
          end

          Code($+1)='  /* Routine name of block: '+strcat(string(cpr.sim.funs(i)));
          Code($+1)='   * Gui name of block: '+strcat(string(OO.gui));
          Code($+1)='   * Compiled structure index: '+strcat(string(i));

          if stripblanks(OO.model.label)~=emptystr() then
            Code=[Code;
                  '  '+cformatline(' * Label: '+strcat(string(OO.model.label)),70)];
          end
          if stripblanks(OO.graphics.exprs(1))~=emptystr() then
            Code=[Code;
                  '  '+cformatline(' * Exprs: '+strcat(OO.graphics.exprs(1),","),70)];
          end
          if stripblanks(OO.graphics.id)~=emptystr() then
            Code=[Code;
                  '  '+cformatline(' * Identification: '+strcat(string(OO.graphics.id)),70)];
          end
          //txt=[txt;' * rpar='];
          Code($+1)='   */';
        end
        //******************//

//         txt=cformatline(strcat(msprintf('%.16g,\n',rpar(rpptr(i):rpptr(i+1)-1))),70);
// 
//         txt(1)='double rpar_'+string(i)+'[]={'+txt(1);
//         for j=2:size(txt,1)
//           txt(j)=get_blank('double rpar_'+string(i)+'[]')+txt(j);
//         end
//         txt($)=part(txt($),1:length(txt($))-1)+'};'
//         Code=[Code;
//               '  '+txt]
        Code=[Code;
              '  double rpar_'+string(i)+'['+...
                string(size(rpptr(i):rpptr(i+1),'*')-1)+'];'
              '']
        //@@@@----@@@@
        Code_read=[Code_read
                   '  /* read real parameter rpar_'+string(i)+' */'
                   '  '+get_code_to_read_params('rpar_'+string(i),rpar(rpptr(i):rpptr(i+1)-1),fpp)
                   '']
        Code_xml_param=[Code_xml_param;
                        get_xml_param_code('rpar_'+string(i),rpar(rpptr(i):rpptr(i+1)-1))]
      end
    end
  end
  //#######################//

  //### Integer parameters ###//
  if size(ipar,1) <> 0 then
    Code=[Code;
          '  /* Integers parameters declaration */']

    for i=1:(length(ipptr)-1)
      if ipptr(i+1)-ipptr(i)>0  then

        //** Add comments **//

        //## Modelica block
        if type(corinv(i))==15 then
          //## we can extract here all informations
          //## from original scicos blocks with corinv : TODO
          Code($+1)='  /* Modelica Block */';
        else
          if size(corinv(i),'*')==1 then
            OO=scs_m.objs(corinv(i));
          else
            path=list('objs');
            for l=cpr.corinv(i)(1:$-1)
              path($+1)=l
              path($+1)='model'
              path($+1)='rpar'
              path($+1)='objs'
            end
            path($+1)=cpr.corinv(i)($);
            OO=scs_m(path);
          end

          Code($+1)='  /* Routine name of block: '+strcat(string(cpr.sim.funs(i)));
          Code($+1)='   * Gui name of block: '+strcat(string(OO.gui));
          Code($+1)='   * Compiled structure index: '+strcat(string(i));
          if stripblanks(OO.model.label)~=emptystr() then
            Code=[Code;
                  '  '+cformatline(' * Label: '+strcat(string(OO.model.label)),70)];
          end

          if stripblanks(OO.graphics.exprs(1))~=emptystr() then
            Code=[Code;
                  '  '+cformatline(' * Exprs: '+strcat(OO.graphics.exprs(1),","),70)];
          end
          if stripblanks(OO.graphics.id)~=emptystr() then
            Code=[Code;
                  '  '+cformatline(' * Identification: '+strcat(string(OO.graphics.id)),70)];
          end
          Code=[Code;
                '  '+cformatline(' * ipar= {'+strcat(string(ipar(ipptr(i):ipptr(i+1)-1)),",")+'};',70)];
          Code($+1)='   */';
        end
        //******************//

//         txt=cformatline(strcat(string(ipar(ipptr(i):ipptr(i+1)-1))+','),70);
// 
//         txt(1)='int ipar_'+string(i)+'[]={'+txt(1);
//         for j=2:size(txt,1)
//           txt(j)=get_blank('int ipar_'+string(i)+'[]')+txt(j);
//         end
//         txt($)=part(txt($),1:length(txt($))-1)+'};'
//         Code=[Code;
//               '  '+txt
//               '']
        Code=[Code;
              '  int ipar_'+string(i)+'['+...
                string(size(ipptr(i):ipptr(i+1),'*')-1)+'];'
              '']
        //@@@@----@@@@
        Code_read=[Code_read
                   '  /* read integer parameter ipar_'+string(i)+' */'
                   '  '+get_code_to_read_params('ipar_'+string(i),int32(ipar(ipptr(i):ipptr(i+1)-1)),fpp)
                   '']
        Code_xml_param=[Code_xml_param;
                        get_xml_param_code('ipar_'+string(i),int32(ipar(ipptr(i):ipptr(i+1)-1)))]
      end
    end
  end
  //##########################//

  //### Object parameters ###//

  //** declaration of opar
  Code_opar = [];
  Code_ooparsz=[];
  Code_oopartyp=[];
  Code_oparptr=[];

  for i=1:(length(opptr)-1)
    nopar = opptr(i+1)-opptr(i)
    if nopar>0  then
      //** Add comments **//

      //## Modelica block
      if type(corinv(i))==15 then
        //## we can extract here all informations
        //## from original scicos blocks with corinv : TODO
        Code_opar($+1)='  /* Modelica Block */';
      else
        //@@ 04/11/08, disable generation of comment for opar
        //@@ for m_frequ because of sample clock
        if funs(i)=='m_frequ' then
        else
          if size(corinv(i),'*')==1 then
            OO=scs_m.objs(corinv(i));
          else
            path=list('objs');
            for l=cpr.corinv(i)(1:$-1)
              path($+1)=l;
              path($+1)='model';
              path($+1)='rpar';
              path($+1)='objs';
            end
            path($+1)=cpr.corinv(i)($);
            OO=scs_m(path);
          end

          Code_opar($+1)='  /* Routine name of block: '+strcat(string(cpr.sim.funs(i)));
          Code_opar($+1)='   * Gui name of block: '+strcat(string(OO.gui));
          Code_opar($+1)='   * Compiled structure index: '+strcat(string(i));
          if stripblanks(OO.model.label)~=emptystr() then
            Code_opar=[Code_opar;
                  '  '+cformatline(' * Label: '+strcat(string(OO.model.label)),70)];
          end
          if stripblanks(OO.graphics.id)~=emptystr() then
            Code_opar=[Code_opar;
                  '  '+cformatline(' * Identification: '+strcat(string(OO.graphics.id)),70)];
          end
          Code_opar($+1)='   */';
        end
      end
      //******************//

      for j=1:nopar
//         if mat2scs_c_nb(opar(opptr(i)+j-1)) <> 11 then
//           Code_opar =[Code_opar;
//                  '  '+cformatline(mat2c_typ(opar(opptr(i)+j-1)) +...
//                          ' opar_'+string(opptr(i)+j-1) + '[]={'+...
//                              strcat(string(opar(opptr(i)+j-1)),',')+'};',70)]
//         else //** cmplx test
//           Code_opar =[Code_opar;
//                  '  '+cformatline(mat2c_typ(opar(opptr(i)+j-1)) +...
//                          ' opar_'+string(opptr(i)+j-1) + '[]={'+...
//                              strcat(string([real(opar(opptr(i)+j-1)(:));
//                                             imag(opar(opptr(i)+j-1)(:))]),',')+'};',70)]
//         end

        if mat2scs_c_nb(opar(opptr(i)+j-1)) <> 11 then
          Code_opar=[Code_opar;
                     '  '+mat2c_typ(opar(opptr(i)+j-1))+' opar_'+string(opptr(i)+j-1)+'['+...
                       string(size(opar(opptr(i)+j-1),'*'))+'];'
                     '']
        else
          Code_opar=[Code_opar;
                     '  '+mat2c_typ(opar(opptr(i)+j-1))+' opar_'+string(opptr(i)+j-1)+'['+...
                       string(2*size(opar(opptr(i)+j-1),'*'))+'];'
                     '']
        end
        //@@@@----@@@@
        Code_read=[Code_read
                   '  /* read object parameter opar_'+string(opptr(i)+j-1)+' */'
                   '  '+get_code_to_read_params('opar_'+string(opptr(i)+j-1),opar(opptr(i)+j-1),fpp)
                   '']
        Code_xml_param=[Code_xml_param;
                        get_xml_param_code('opar_'+string(opptr(i)+j-1),opar(opptr(i)+j-1))]
      end
      //Code_opar($+1)='';

      //## size
      Code_oparsz   = []
      //** 1st dim **//
      for j=1:nopar
        Code_oparsz=[Code_oparsz
                     string(size(opar(opptr(i)+j-1),1))]
      end
      //** 2dn dim **//
      for j=1:nopar
        Code_oparsz=[Code_oparsz
                     string(size(opar(opptr(i)+j-1),2))]
      end
      Code_tooparsz=cformatline(strcat(Code_oparsz,','),70);
      Code_tooparsz(1)='int oparsz_'+string(i)+'[]={'+Code_tooparsz(1);
      for j=2:size(Code_tooparsz,1)
        Code_tooparsz(j)=get_blank('int oparsz_'+string(i)+'[]')+Code_tooparsz(j);
      end
      Code_tooparsz($)=Code_tooparsz($)+'};'
      Code_ooparsz=[Code_ooparsz;
                    Code_tooparsz];

      //## typ
      Code_opartyp   = []
      for j=1:nopar
        Code_opartyp=[Code_opartyp
                      mat2scs_c_typ(opar(opptr(i)+j-1))]
      end
      Code_toopartyp=cformatline(strcat(Code_opartyp,','),70);
      Code_toopartyp(1)='int opartyp_'+string(i)+'[]={'+Code_toopartyp(1);
      for j=2:size(Code_toopartyp,1)
        Code_toopartyp(j)=get_blank('int opartyp_'+string(i)+'[]')+Code_toopartyp(j);
      end
      Code_toopartyp($)=Code_toopartyp($)+'};'
      Code_oopartyp=[Code_oopartyp;
                     Code_toopartyp];

      //## ptr
      Code_tooparptr=cformatline(strcat(string(zeros(1,nopar)),','),70);
      Code_tooparptr(1)='void *oparptr_'+string(i)+'[]={'+Code_tooparptr(1);
      for j=2:size(Code_tooparptr,1)
        Code_tooparptr(j)=get_blank('void *oparptr_'+string(i)+'[]')+Code_tooparptr(j);
      end
      Code_tooparptr($)=Code_tooparptr($)+'};'
      Code_oparptr=[Code_oparptr
                    Code_tooparptr]

    end
  end

  if Code_opar <> [] then
    Code=[Code;
          '  /* Object parameters declaration */'
          Code_opar
          '  '+Code_ooparsz
          ''
          '  '+Code_oopartyp
          ''
          '  '+Code_oparptr
          '']
  end

  //##########################//

  //*** continuous state ***//
  if x <> [] then
    //## implicit block
    if impl_blk then
// //       Code=[Code;
// //             '  /* Continuous states declaration */'
// //             cformatline('  double x[]={'+strcat(string(x(1:nX/2)),',')+'};',70)
// //             '  double x['+string(nX)+'];
// //             cformatline('  double xd[]={'+strcat(string(zeros(nX/2+1:nX)),',')+'};',70)
// //             cformatline('  double res[]={'+strcat(string(zeros(1,nX/2)),',')+'};',70)
// //             ''
// //             '  /* def xproperty */'
// //             cformatline('  int xprop[]={'+strcat(string(ones(1:nX/2)),',')+'};',70)
// //             '']

      Code=[Code;
            '  /* Continuous states declaration */'
            '  double x['+string(nX)+'];'
            '']

      //@@@@----@@@@
      Code_read=[Code_read
                 '  /* read initial continuous state */'
                 '  '+get_code_to_read_params('x',x(1:nX/2),fpp)
                 '']
      Code_xml_param=[Code_xml_param;
                      get_xml_param_code('x',x(1:nX/2))]

      Code=[Code;
            cformatline('  double xd[]={'+strcat(string(zeros(nX/2+1:nX)),',')+'};',70)
            cformatline('  double res[]={'+strcat(string(zeros(1,nX/2)),',')+'};',70)
            ''
            '  /* def xproperty */'
            cformatline('  int xprop[]={'+strcat(string(ones(1:nX/2)),',')+'};',70)
            cformatline('  double alpha[]={'+strcat(string(ones(1:nX/2))+'.',',')+'};',70)
            cformatline('  double beta[]={'+strcat(string(ones(1:nX/2))+'.',',')+'};',70)
            '']
    //## explicit block
    else
//       Code=[Code;
//             '  /* Continuous states declaration */'
//             cformatline('  double x[]={'+strcat(string(x),',')+'};',70)
//             cformatline('  double xd[]={'+strcat(string(zeros(1,nX)),',')+'};',70)
//             '']

      Code=[Code;
            '  /* Continuous states declaration */'
            '  double x['+string(nX)+'];'
            '']

      //@@@@----@@@@
      Code_read=[Code_read
                 '  /* read initial continuous state x */'
                 '  '+get_code_to_read_params('x',x(1:nX),fpp)
                 '']
      Code_xml_param=[Code_xml_param;
                      get_xml_param_code('x',x(1:nX))]

      Code=[Code;
            cformatline('  double xd[]={'+strcat(string(zeros(1,nX)),',')+'};',70)
            '']
    end
  end
  //************************//

  //### discrete states ###//
  if size(z,1) <> 0 then
    Code=[Code;
          '  /* Discrete states declaration */']
    for i=1:(length(zptr)-1)
      if zptr(i+1)-zptr(i)>0 then

        //** Add comments **//

        //## Modelica block
        if type(corinv(i))==15 then
          //## we can extract here all informations
          //## from original scicos blocks with corinv : TODO
          Code($+1)='  /* Modelica Block ';
        else
          if size(corinv(i),'*')==1 then
            OO=scs_m.objs(corinv(i))
          else
            path=list('objs')
            for l=cpr.corinv(i)(1:$-1)
              path($+1)=l;path($+1)='model'
              path($+1)='rpar'
              path($+1)='objs'
            end
            path($+1)=cpr.corinv(i)($)
            OO=scs_m(path)
          end
          aaa=OO.gui
          bbb=emptystr(3,1);
          if and(aaa+bbb~=['INPUTPORTEVTS';'OUTPUTPORTEVTS';'EVTGEN_f']) then
            Code($+1)='  /* Routine name of block: '+strcat(string(cpr.sim.funs(i)));
            Code($+1)='     Gui name of block: '+strcat(string(OO.gui));
            //Code($+1)='/* Name block: '+strcat(string(cpr.sim.funs(i)));
            //Code($+1)='Object number in diagram: '+strcat(string(cpr.corinv(i)));
            Code($+1)='     Compiled structure index: '+strcat(string(i));
            if stripblanks(OO.model.label)~=emptystr() then
              Code=[Code;
                    cformatline('     Label: '+strcat(string(OO.model.label)),70)]
            end
            if stripblanks(OO.graphics.exprs(1))~=emptystr() then
              Code=[Code;
                    cformatline('     Exprs: '+strcat(OO.graphics.exprs(1),","),70)]
            end
            if stripblanks(OO.graphics.id)~=emptystr() then
              Code=[Code;
                    cformatline('     Identification: '+..
                       strcat(string(OO.graphics.id)),70)]
            end
          end
        end
        Code($+1)='  */';
//         Code=[Code;
//               cformatline('  double z_'+string(i)+'[]={'+...
//               strcat(string(z(zptr(i):zptr(i+1)-1)),",")+'};',70)]
//         Code($+1)='';

        Code=[Code;
              '  double z_'+string(i)+'['+...
                string(size(zptr(i):zptr(i+1),'*')-1)+'];'
              '']
        //@@@@----@@@@
        Code_read=[Code_read
                   '  /* read discrete state z_'+string(i)+' */'
                   '  '+get_code_to_read_params('z_'+string(i),z(zptr(i):zptr(i+1)-1),fpp)
                  '']
        Code_xml_param=[Code_xml_param;
                        get_xml_param_code('z_'+string(i),z(zptr(i):zptr(i+1)-1))]
      end
      //******************//
    end
  end
  //#######################//

  //### Object state ###//
  //** declaration of oz
  Code_oz = [];
  Code_oozsz=[];
  Code_ooztyp=[];
  Code_ozptr=[];

  for i=1:(length(ozptr)-1)
    noz = ozptr(i+1)-ozptr(i)
    if noz>0 then

      for j=1:noz
//         if mat2scs_c_nb(oz(ozptr(i)+j-1)) <> 11 then
//           Code_oz=[Code_oz;
//                    cformatline('  '+mat2c_typ(oz(ozptr(i)+j-1))+...
//                                ' oz_'+string(ozptr(i)+j-1)+'[]={'+...
//                                strcat(string(oz(ozptr(i)+j-1)(:)),',')+'};',70)]
//         else //** cmplx test
//           Code_oz=[Code_oz;
//                    cformatline('  '+mat2c_typ(oz(ozptr(i)+j-1))+...
//                                ' oz_'+string(ozptr(i)+j-1)+'[]={'+...
//                                strcat(string([real(oz(ozptr(i)+j-1)(:));
//                                               imag(oz(ozptr(i)+j-1)(:))]),',')+'};',70)]
//         end

        if mat2scs_c_nb(oz(ozptr(i)+j-1)) <> 11 then
          Code_oz=[Code_oz;
                   '  '+mat2c_typ(oz(ozptr(i)+j-1))+' oz_'+string(ozptr(i)+j-1)+'['+...
                       string(size(oz(ozptr(i)+j-1),'*'))+'];'
                   '']
        else
          Code_oz=[Code_oz;
                   '  '+mat2c_typ(oz(ozptr(i)+j-1))+' oz_'+string(ozptr(i)+j-1)+'['+...
                       string(2*size(oz(ozptr(i)+j-1),'*'))+'];'
                   '']
        end
        //@@@@----@@@@
        Code_read=[Code_read
                   '  /* read object state oz_'+string(ozptr(i)+j-1)+' */'
                   '  '+get_code_to_read_params('oz_'+string(ozptr(i)+j-1),oz(ozptr(i)+j-1),fpp)
                   '']
        Code_xml_param=[Code_xml_param;
                        get_xml_param_code('oz_'+string(ozptr(i)+j-1),oz(ozptr(i)+j-1))]
      end

      //## size
      Code_ozsz   = []
      //** 1st dim **//
      for j=1:noz
        Code_ozsz=[Code_ozsz
                     string(size(oz(ozptr(i)+j-1),1))]
      end
      //** 2dn dim **//
      for j=1:noz
        Code_ozsz=[Code_ozsz
                     string(size(oz(ozptr(i)+j-1),2))]
      end
      Code_toozsz=cformatline(strcat(Code_ozsz,','),70);
      Code_toozsz(1)='int ozsz_'+string(i)+'[]={'+Code_toozsz(1);
      for j=2:size(Code_toozsz,1)
        Code_toozsz(j)=get_blank('int ozsz_'+string(i)+'[]')+Code_toozsz(j);
      end
      Code_toozsz($)=Code_toozsz($)+'};'
      Code_oozsz=[Code_oozsz;
                    Code_toozsz];

      //## typ
      Code_oztyp   = []
      for j=1:noz
        Code_oztyp=[Code_oztyp
                      mat2scs_c_typ(oz(ozptr(i)+j-1))]
      end
      Code_tooztyp=cformatline(strcat(Code_oztyp,','),70);
      Code_tooztyp(1)='int oztyp_'+string(i)+'[]={'+Code_tooztyp(1);
      for j=2:size(Code_tooztyp,1)
        Code_tooztyp(j)=get_blank('int oztyp_'+string(i)+'[]')+Code_tooztyp(j);
      end
      Code_tooztyp($)=Code_tooztyp($)+'};'
      Code_ooztyp=[Code_ooztyp;
                     Code_tooztyp];

      //## ptr
      Code_toozptr=cformatline(strcat(string(zeros(1,noz)),','),70);
      Code_toozptr(1)='void *ozptr_'+string(i)+'[]={'+Code_toozptr(1);
      for j=2:size(Code_toozptr,1)
        Code_toozptr(j)=get_blank('void *ozptr_'+string(i)+'[]')+Code_toozptr(j);
      end
      Code_toozptr($)=Code_toozptr($)+'};'
      Code_ozptr=[Code_ozptr
                    Code_toozptr]

    end
  end

  if Code_oz <> [] then
    Code=[Code;
          '  /* Object discrete states declaration */'
          Code_oz
          '  '+Code_oozsz
          ''
          '  '+Code_ooztyp
          ''
          '  '+Code_ozptr
          '']
  end
  //#######################//

  //##### out events #####//
  Code_evout=[];
  for kf=1:nblk
    if funs(kf)<>'bidon' then
      nevout=clkptr(kf+1)-clkptr(kf);
      if nevout <> 0 then
        Code_toevout=cformatline(strcat(string(cpr.state.evtspt((clkptr(kf):clkptr(kf+1)-1))),','),70);
        Code_toevout(1)='double evout_'+string(kf)+'[]={'+Code_toevout(1);
        for j=2:size(Code_toevout,1)
          Code_toevout(j)=get_blank('double evout_'+string(kf)+'[]')+Code_toevout(j);
        end
        Code_toevout($)=Code_toevout($)+'};';
        Code_evout=[Code_evout
                    Code_toevout];
      end
    end
  end
  if Code_evout<>[] then
     Code=[Code;
          '  /* Outputs event declaration */'
          '  '+Code_evout
          ''];
  end
  //################//

  //*** zero crossing ***//
  if ng <> 0 then
    Code=[Code;
          '  /* Zero crossing declaration */'
          cformatline('  double g[]={'+...
          strcat(string(zeros(1,ng))+'.',",")+'};',70)
          cformatline('  int jroot[]={'+...
          strcat(string(zeros(1,ng)),",")+'};',70)
          '']
  end
  //*********************//

  //*** mode ***//
  if nmod <> 0 then
    Code=[Code;
          '  /* Modes declaration */'
          cformatline('  int mode[]={'+...
          strcat(string(zeros(1,nmod)),",")+'};',70)
          '']
  end
  //*********************//

  //** declaration of work
  Code_work=[]
  for i=1:size(with_work,1)
    if with_work(i)==1 then
       Code_work=[Code_work
                  '  void *work_'+string(i)+'[]={0};']
    end
  end

  if Code_work<>[] then
    Code=[Code
          '  /* Work array declaration */'
          Code_work
          '']
  end

  //** declaration of outtb
  Code_outtb = [];
  for i=1:lstsize(outtb)
    if mat2scs_c_nb(outtb(i)) <> 11 then
//       Code_outtb=[Code_outtb;
//                   cformatline('  '+mat2c_typ(outtb(i))+...
//                               ' outtb_'+string(i)+'[]={'+...
//                               strcat(string_to_c_string(outtb(i)(:)),',')+'};',70)]
      Code_outtb=[Code_outtb;
                  '  '+mat2c_typ(outtb(i))+...
                     ' outtb_'+string(i)+'['+string(size(outtb(i),'*'))+'];']
    else //** cmplx test
//       Code_outtb=[Code_outtb;
//                   cformatline('  '+mat2c_typ(outtb(i))+...
//                               ' outtb_'+string(i)+'[]={'+...
//                               strcat(string_to_c_string([real(outtb(i)(:));
//                                              imag(outtb(i)(:))]),',')+'};',70)]
      Code_outtb=[Code_outtb;
                  '  '+mat2c_typ(outtb(i))+...
                     ' outtb_'+string(i)+'['+2*string(size(outtb(i),'*'))+'];']
    end
    //@@@@----@@@@
    Code_read=[Code_read
               '  /* read initial output outtb_'+string(i)+' */'
               '  '+get_code_to_read_params('outtb_'+string(i),outtb(i)(:),fpp)
               '']
    Code_xml_param=[Code_xml_param;
                    get_xml_param_code('outtb_'+string(i),outtb(i))] //!!
  end

  if Code_outtb<>[] then
    Code=[Code
          '  /* Output declaration */'
          Code_outtb
          '']
  end

  Code_outtbptr=[];
  for i=1:lstsize(outtb)
    Code_outtbptr=[Code_outtbptr;
                   '  '+rdnom+'_block_outtbptr['+...
                    string(i-1)+'] = (void *) outtb_'+string(i)+';'];
  end

  //##### insz/outsz #####//
  Code_iinsz=[];
  Code_inptr=[];
  Code_ooutsz=[];
  Code_outptr=[];
  for kf=1:nblk
    nin=inpptr(kf+1)-inpptr(kf);  //** number of input ports
    Code_insz=[];

    //########
    //## insz
    //########

    //## case sensor ##//
    if or(kf==capt(:,1)) then
      ind=find(kf==capt(:,1))
      //Code_insz = 'typin['+string(ind-1)+']'
    //## other blocks ##//
    elseif nin<>0 then
      //** 1st dim **//
      for kk=1:nin
         lprt=inplnk(inpptr(kf)-1+kk);
         Code_insz=[Code_insz
                    string(size(outtb(lprt),1))]
      end
      //** 2dn dim **//
      for kk=1:nin
         lprt=inplnk(inpptr(kf)-1+kk);
         Code_insz=[Code_insz
                    string(size(outtb(lprt),2))]
      end
      //** typ **//
      for kk=1:nin
         lprt=inplnk(inpptr(kf)-1+kk);
         Code_insz=[Code_insz
                    mat2scs_c_typ(outtb(lprt))]
      end
    end
    if Code_insz<>[] then
      Code_toinsz=cformatline(strcat(Code_insz,','),70);
      Code_toinsz(1)='int insz_'+string(kf)+'[]={'+Code_toinsz(1);
      for j=2:size(Code_toinsz,1)
        Code_toinsz(j)=get_blank('int insz_'+string(kf)+'[]')+Code_toinsz(j);
      end
      Code_toinsz($)=Code_toinsz($)+'};'
      Code_iinsz=[Code_iinsz
                  Code_toinsz]
    end

    //########
    //## inptr
    //########

    //## case sensor ##//
    if or(kf==capt(:,1)) then
      Code_inptr=[Code_inptr;
                  'void *inptr_'+string(kf)+'[]={0};';]
    //## other blocks ##//
    elseif nin<>0 then
      Code_toinptr=cformatline(strcat(string(zeros(1,nin)),','),70);
      Code_toinptr(1)='void *inptr_'+string(kf)+'[]={'+Code_toinptr(1);
      for j=2:size(Code_toinptr,1)
        Code_toinptr(j)=get_blank('void *inptr_'+string(kf)+'[]')+Code_toinptr(j);
      end
      Code_toinptr($)=Code_toinptr($)+'};'
      Code_inptr=[Code_inptr
                  Code_toinptr]
    end

    nout=outptr(kf+1)-outptr(kf); //** number of output ports
    Code_outsz=[];

    //########
    //## outsz
    //########

    //## case actuators ##//
    if or(kf==actt(:,1)) then
      ind=find(kf==actt(:,1))
      //Code_outsz = 'typout['+string(ind-1)+']'
    //## other blocks ##//
    elseif nout<>0 then
      //** 1st dim **//
      for kk=1:nout
         lprt=outlnk(outptr(kf)-1+kk);
         Code_outsz=[Code_outsz
                     string(size(outtb(lprt),1))]
      end
      //** 2dn dim **//
      for kk=1:nout
         lprt=outlnk(outptr(kf)-1+kk);
         Code_outsz=[Code_outsz
                     string(size(outtb(lprt),2))]
      end
      //** typ **//
      for kk=1:nout
         lprt=outlnk(outptr(kf)-1+kk);
         Code_outsz=[Code_outsz
                     mat2scs_c_typ(outtb(lprt))]
      end
    end
    if Code_outsz<>[] then
      Code_tooustz=cformatline(strcat(Code_outsz,','),70);
      Code_tooustz(1)='int outsz_'+string(kf)+'[]={'+Code_tooustz(1);
      for j=2:size(Code_tooustz,1)
        Code_tooustz(j)=get_blank('int outsz_'+string(kf)+'[]')+Code_tooustz(j);
      end
      Code_tooustz($)=Code_tooustz($)+'};'
      Code_ooutsz=[Code_ooutsz
                   Code_tooustz]
    end

    //#########
    //## outptr
    //#########

    //## case actuators ##//
    if or(kf==actt(:,1)) then
      ind=find(kf==actt(:,1))
      nnin=size(ind,2)
      Code_tooutptr=cformatline(strcat(string(zeros(1,nnin)),','),70);
      Code_tooutptr(1)='void *outptr_'+string(kf)+'[]={'+Code_tooutptr(1);
      for j=2:size(Code_tooutptr,1)
        Code_tooutptr(j)=get_blank('void *outptr_'+string(kf)+'[]')+Code_tooutptr(j);
      end
      Code_tooutptr($)=Code_tooutptr($)+'};'
      Code_outptr=[Code_outptr
                   Code_tooutptr]
//       Code_outptr=[Code_outptr;
//                    'void *outptr_'+string(kf)+'[]={'++'};';]
    //## other blocks ##//
    elseif nout<>0 then
      Code_tooutptr=cformatline(strcat(string(zeros(1,nout)),','),70);
      Code_tooutptr(1)='void *outptr_'+string(kf)+'[]={'+Code_tooutptr(1);
      for j=2:size(Code_tooutptr,1)
        Code_tooutptr(j)=get_blank('void *outptr_'+string(kf)+'[]')+Code_tooutptr(j);
      end
      Code_tooutptr($)=Code_tooutptr($)+'};'
      Code_outptr=[Code_outptr
                   Code_tooutptr]
    end
  end

  if Code_iinsz<>[] then
     Code=[Code;
          '  /* Inputs */'
          '  '+Code_iinsz
          ''];
  end
  if Code_inptr<>[] then
     Code=[Code;
          '  '+Code_inptr
          ''];
  end
  if Code_ooutsz<>[] then
     Code=[Code;
          '  /* Outputs */'
          '  '+Code_ooutsz
          ''];
  end
  if Code_outptr<>[] then
     Code=[Code;
          '  '+Code_outptr
          ''];
  end
  //######################//

  //@@@@----@@@@
  if ALL then
    //@@@@----@@@@
    Code=[Code
          Code_read
          '  /* close the parameters data file */'
          '  fclose(fpp);'
          '']
  end

  //@@@@----@@@@
  mclose(fpp);

  //## input connection to outtb
  Code_inptr=[]
  for kf=1:nblk
    nin=inpptr(kf+1)-inpptr(kf);  //** number of input ports
    //## case sensor ##//
    if or(kf==capt(:,1)) then
      ind=find(kf==capt(:,1))
      Code_inptr=[Code_inptr;
                  '  inptr_'+string(kf)+'[0] = inptr['+string(ind-1)+'];';]
    //## other blocks ##//
    elseif nin<>0 then
      for k=1:nin
        lprt=inplnk(inpptr(kf)-1+k);
        Code_inptr=[Code_inptr
                    '  inptr_'+string(kf)+'['+string(k-1)+'] = (void *) outtb_'+string(lprt)+';']
      end
    end
  end
  if Code_inptr<>[] then
    Code=[Code;
          '  /* Affectation of inptr */';
          Code_inptr;
          ''];
  end

  //## output connection to outtb
  Code_outptr=[]
  for kf=1:nblk
    nout=outptr(kf+1)-outptr(kf); //** number of output ports
    //## case actuators ##//
    if or(kf==actt(:,1)) then
    ind=find(kf==actt(:,1))
    nin=size(ind,2)
    for j=1:nin
      Code_outptr=[Code_outptr;
                   '  outptr_'+string(kf)+'['+string(j-1)+'] = outptr['+string(ind(j)-1)+'];';]
    end
    //## other blocks ##//
    elseif nout<>0 then
      for k=1:nout
        lprt=outlnk(outptr(kf)-1+k);
        Code_outptr=[Code_outptr
                    '  outptr_'+string(kf)+'['+string(k-1)+'] = (void *) outtb_'+string(lprt)+';']
      end
    end
  end
  if Code_outptr<>[] then
    Code=[Code;
          '  /* Affectation of outptr */';
          Code_outptr;
          ''];
  end

  //## affectation of oparptr
  Code_oparptr=[]
  for kf=1:nblk
    nopar=opptr(kf+1)-opptr(kf); //** number of object parameters
    if nopar<>0 then
      for k=1:nopar
        Code_oparptr=[Code_oparptr
                    '  oparptr_'+string(kf)+'['+string(k-1)+'] = (void *) opar_'+string(opptr(kf)+k-1)+';']
      end
    end
  end
  if Code_oparptr<>[] then
    Code=[Code;
          '  /* Affectation of oparptr */';
          Code_oparptr;
          ''];
  end

  //## affectation of ozptr
  Code_ozptr=[]
  for kf=1:nblk
    noz=ozptr(kf+1)-ozptr(kf); //** number of object states
    if noz<>0 then
      for k=1:noz
        Code_ozptr=[Code_ozptr
                    '  ozptr_'+string(kf)+'['+string(k-1)+'] = (void *) oz_'+string(ozptr(kf)+k-1)+';']
      end
    end
  end
  if Code_ozptr<>[] then
    Code=[Code;
          '  /* Affectation of ozptr */';
          Code_ozptr;
          ''];
  end

  //## fields of each scicos structure
  for kf=1:nblk
    if funs(kf)<>'bidon' then
      nx=xptr(kf+1)-xptr(kf);         //** number of continuous state
      nz=zptr(kf+1)-zptr(kf);         //** number of discrete state
      nin=inpptr(kf+1)-inpptr(kf);    //** number of input ports
      nout=outptr(kf+1)-outptr(kf);   //** number of output ports
      nevout=clkptr(kf+1)-clkptr(kf); //** number of event output ports

      //** add comment
      txt=[get_comment('set_blk',list(funs(kf),funtyp(kf),kf));]

      Code=[Code;
            '  '+txt];

      Code=[Code;
            '  block_'+rdnom+'['+string(kf-1)+'].type    = '+string(funtyp(kf))+';';
            '  block_'+rdnom+'['+string(kf-1)+'].ztyp    = '+string(ztyp(kf))+';';
            '  block_'+rdnom+'['+string(kf-1)+'].ng      = '+string(zcptr(kf+1)-zcptr(kf))+';';
            '  block_'+rdnom+'['+string(kf-1)+'].nz      = '+string(zptr(kf+1)-zptr(kf))+';';
            '  block_'+rdnom+'['+string(kf-1)+'].nx      = '+string(nx)+';';
            '  block_'+rdnom+'['+string(kf-1)+'].noz     = '+string(ozptr(kf+1)-ozptr(kf))+';';
            '  block_'+rdnom+'['+string(kf-1)+'].nrpar   = '+string(rpptr(kf+1)-rpptr(kf))+';';
            '  block_'+rdnom+'['+string(kf-1)+'].nopar   = '+string(opptr(kf+1)-opptr(kf))+';';
            '  block_'+rdnom+'['+string(kf-1)+'].nipar   = '+string(ipptr(kf+1)-ipptr(kf))+';'
            '  block_'+rdnom+'['+string(kf-1)+'].nin     = '+string(inpptr(kf+1)-inpptr(kf))+';';
            '  block_'+rdnom+'['+string(kf-1)+'].nout    = '+string(outptr(kf+1)-outptr(kf))+';';
            '  block_'+rdnom+'['+string(kf-1)+'].nevout  = '+string(clkptr(kf+1)-clkptr(kf))+';';
            '  block_'+rdnom+'['+string(kf-1)+'].nmode   = '+string(modptr(kf+1)-modptr(kf))+';';]

      //@@ continuous state
      if nx <> 0 then
        Code=[Code;
              '  block_'+rdnom+'['+string(kf-1)+'].x       = &(x['+string(xptr(kf)-1)+']);'
              '  block_'+rdnom+'['+string(kf-1)+'].xd      = &(xd['+string(xptr(kf)-1)+']);']
        if impl_blk then
          Code=[Code;
                '  block_'+rdnom+'['+string(kf-1)+'].res     = &(res['+string(xptr(kf)-1)+']);'
                '  block_'+rdnom+'['+string(kf-1)+'].xprop   = &(xprop['+string(xptr(kf)-1)+']);';
                '  block_'+rdnom+'['+string(kf-1)+'].alpha   = &(alpha['+string(xptr(kf)-1)+']);';
                '  block_'+rdnom+'['+string(kf-1)+'].beta    = &(beta['+string(xptr(kf)-1)+']);'];
        end
      end

      //@@ zero crossing
      if (zcptr(kf+1)-zcptr(kf)) <> 0 then
        Code=[Code;
              '  block_'+rdnom+'['+string(kf-1)+'].g       = &(g['+string(zcptr(kf)-1)+']);'
              '  block_'+rdnom+'['+string(kf-1)+'].jroot   = &(jroot['+string(zcptr(kf)-1)+']);']
      end

      //@@ mode
      if (modptr(kf+1)-modptr(kf)) <> 0 then
        Code=[Code;
              '  block_'+rdnom+'['+string(kf-1)+'].mode    = &(mode['+string(modptr(kf)-1)+']);']
      end

      //** evout **//
      if nevout<>0 then
        Code=[Code;
              '  block_'+rdnom+'['+string(kf-1)+'].evout   = evout_'+string(kf)+';']
      end

      //***************************** input port *****************************//
      //## case sensor ##//
      if or(kf==capt(:,1)) then
        ind=find(kf==capt(:,1))
        Code=[Code;
              '  block_'+rdnom+'['+string(kf-1)+'].inptr   = inptr_'+string(kf)+';'
              '  block_'+rdnom+'['+string(kf-1)+'].insz    = &typin['+string(ind-1)+'];']
      //## other blocks ##//
      elseif nin<>0 then
        Code=[Code;
              '  block_'+rdnom+'['+string(kf-1)+'].inptr   = inptr_'+string(kf)+';'
              '  block_'+rdnom+'['+string(kf-1)+'].insz    = insz_'+string(kf)+';']
      end
      //**********************************************************************//

      //***************************** output port *****************************//
      //## case actuators ##//
      if or(kf==actt(:,1)) then
        ind=find(kf==actt(:,1))
        Code=[Code;
              '  block_'+rdnom+'['+string(kf-1)+'].outptr  = outptr_'+string(kf)+';'
              '  block_'+rdnom+'['+string(kf-1)+'].outsz   = &typout['+string(ind(1)-1)+'];']
      //## other blocks ##//
      elseif nout<>0 then
        Code=[Code;
              '  block_'+rdnom+'['+string(kf-1)+'].outptr  = outptr_'+string(kf)+';'
              '  block_'+rdnom+'['+string(kf-1)+'].outsz   = outsz_'+string(kf)+';']
      end
      //**********************************************************************//

      //## discrete states ##//
      if (nz>0) then
        Code=[Code
              '  block_'+rdnom+'['+string(kf-1)+...
              '].z       = z_'+string(kf)+';']
      end

      //** rpar **//
      if (rpptr(kf+1)-rpptr(kf)>0) then
        Code=[Code;
              '  block_'+rdnom+'['+string(kf-1)+...
              '].rpar    = rpar_'+string(kf)+';']
      end

      //** ipar **//
      if (ipptr(kf+1)-ipptr(kf)>0) then
        Code=[Code;
              '  block_'+rdnom+'['+string(kf-1)+...
              '].ipar    = ipar_'+string(kf)+';']
      end

      //** opar **//
      if (opptr(kf+1)-opptr(kf)>0) then
        Code=[Code;
              '  block_'+rdnom+'['+string(kf-1)+'].oparptr = oparptr_'+string(kf)+';'
              '  block_'+rdnom+'['+string(kf-1)+'].oparsz  = oparsz_'+string(kf)+';'
              '  block_'+rdnom+'['+string(kf-1)+'].opartyp = opartyp_'+string(kf)+';'
              ]
      end

      //** oz **//
      if (ozptr(kf+1)-ozptr(kf)>0) then
        Code=[Code;
              '  block_'+rdnom+'['+string(kf-1)+'].ozptr   = ozptr_'+string(kf)+';'
              '  block_'+rdnom+'['+string(kf-1)+'].ozsz    = ozsz_'+string(kf)+';'
              '  block_'+rdnom+'['+string(kf-1)+'].oztyp   = oztyp_'+string(kf)+';'
              ]
      end

      //** work **/
      if with_work(kf)==1 then
        Code=[Code;
              '  block_'+rdnom+'['+string(kf-1)+'].work    = work_'+string(kf)+';'
              ]
      end

      //** TODO label **//

      Code=[Code;
            '']
    end
  end

  Code=[Code;
        '  /* set a variable to trace error of blocks */'
        '  block_error = &err; /*GLOBAL*/'
        '']

  Code=[Code;
        '  /* set initial time */'
        '  t = 0.;'
        '']

  if ALL then
    Code=[Code;
          '  /* set initial told value */'
          '  told = t;'
          '']
  end

  Code=[Code;
        '  /* set initial phase simulation */'
        '  phase = 1;'
        '']

  if ALL then
    Code=[Code;
          '  /* set initial Sfcallerid value */'
          '  Sfcallerid=99;'
          '']
  end
 
  if ALL & nX<>0 then
    Code=[Code;
          '  /* set initial hot value */'
          '  hot = 0;'
          '']

    if impl_blk then
      Code=[Code;
            '  /* set initial Jacobian variable value */'
            '  AJacobian_block = 0;'
            '  Jacobian_Flag   = 0;'
            '  CI              = 1.0;'
            '']
    end
  end

  //** init
  Code=[Code;
        '  '+get_comment('flag',list(4))]

  for kf=1:nblk
    if funs(kf)=='agenda_blk' then
      if ALL & size(evs,'*')<>0 then
        new_pointi=adjust_pointi(cpr.state.pointi,clkptr,funtyp)
        Code=[Code;
              '';
              '  /* Init of agenda_blk (blk nb '+string(kf)+') */'
              '  //*(block_'+rdnom+'['+string(kf-1)+'].work) = '+...
                '(agenda_struct*) scicos_malloc(sizeof(agenda_struct));'
              '  //ptr = *(block_'+rdnom+'['+string(kf-1)+'].work);'
              '  ptr->pointi     = '+string(new_pointi)+';'
              '  ptr->fromflag3  = 0;'
              '  ptr->old_pointi = 0;'
             ]
        new_evtspt=adjust_agenda(cpr.state.evtspt,clkptr,funtyp)
        for i=1:size(new_evtspt,1)
          if new_evtspt(i)>0 then
            new_evtspt(i)=adjust_pointi(new_evtspt(i),clkptr,funtyp)
          end
        end
        for i=1:size(evs,'*')
          Code=[Code;
                '  ptr->evtspt['+string(i-1)+']  = '+string(new_evtspt(i))+';'
               ]
        end
        new_tevts=adjust_agenda(cpr.state.tevts,clkptr,funtyp)
        for i=1:size(evs,'*')
          Code=[Code;
                '  ptr->tevts['+string(i-1)+']   = '+string_to_c_string(new_tevts(i))+';'
               ]
        end
        //new_critev=adjust_agenda(cpr.sim.critev,clkptr,funtyp)
        new_critev=cpr.sim.critev(evs)
        for i=1:size(evs,'*')
          Code=[Code;
                '  ptr->critev['+string(i-1)+']  = '+string(new_critev(i))+';'
               ]
        end

      end
    elseif or(kf==act) | or(kf==cap) then
        txt = call_block42(kf,0,4);
        if txt <> [] then
          Code=[Code;
                '';
                '  '+txt];
        end
    else
      txt = call_block42(kf,0,4);
      if txt <> [] then
        Code=[Code;
              '';
              '  '+txt]
        if impl_blk then
          if (xptr(kf+1)-xptr(kf)) <> 0 then
            Code=[Code
                  '  if ((Jacobian_Flag == 1) && (AJacobian_block == 0)) AJacobian_block = '+string(kf)+';']
          end
        end
      end
    end
  end

  //@@ check block_error after all calls
  Code=[Code;
        '';
        '  /* error handling */'
        '  if (get_block_error() != 0) {'
        '    '+rdnom+'_cosend();'
        '    return get_block_error();'
        '  }']


  if impl_blk & ALL then
    Code=[Code;
          '';
          '  /* Disable analytical jacobian computation */'
          '  AJacobian_block=0;Jacobian_Flag=0;']
  end

  //@@ add one call for output initialisation
  txt2=[]
  for kf=1:nblk
    if (funs(kf)<>'agenda_blk') & ...
      ~(or(kf==act) | or(kf==cap)) then

      txt = call_block42(kf,0,6);
      if txt <> [] then
        txt2=[txt2;
              '';
              '  '+txt];
      end
    end
  end

  Code=[Code;
        ''
        '  /* Init outputs */'
        txt2]

  //@@ solvers initialization
  txt=[];
  if ALL & nX>0 then
    //@@ DAE case
    if impl_blk then
      txt=[txt;
           ''
           '  /* IDA variable affectation */'
           '  yy = N_VNewEmpty_Serial(NEQ);'
           '  /* TODO : check flag */'
           ''
           '  NV_DATA_S(yy)=x;'
           ''
           '  yp = N_VNewEmpty_Serial(NEQ);'
           '  /* TODO : check flag */'
           ''
           '  NV_DATA_S(yp)=xd;'
           ''
           '  IDx = N_VNew_Serial(NEQ);'
           '  /* TODO : check flag */'
           ''
           '  /* Call IDACreate and IDAMalloc to initialize IDA memory */'
           '  ida_mem = IDACreate();'
           '  /* TODO : check flag */'
           ''
           '  /* */'
           '  IDA_mem_ptr = (IDAMem) ida_mem;'
           ''
           '  flag = IDAMalloc(ida_mem, '+rdnom+'_simblkdaskr, T0, yy, yp, IDA_SS, reltol, &abstol);'
           '  /* TODO : check flag */'
           '']

      if ng<>0 then
        txt=[txt;
             '  /* */'
             '  flag = IDARootInit(ida_mem, ng, '+rdnom+'_grblkdaskr, NULL);'
             '  /* TODO : check flag */'
             '']
      end

      txt=[txt;
           '  /* */'
           '  flag = IDADense(ida_mem, NEQ);'
           '  /* TODO : check flag */'
           '']

      txt=[txt;
           '  /* */'
           '  ida_data = (User_IDA_data) malloc(sizeof(*ida_data));'
           '  /* TODO check malloc */'
           ''
           '  /* */'
           '  ida_data->ida_mem = ida_mem;'
           '  ida_data->ewt   = NULL;'
           '  ida_data->iwork = NULL;'
           '  ida_data->rwork = NULL;'
           '  ida_data->gwork = NULL;'
           ''
           '  ida_data->ewt   = N_VNew_Serial(NEQ);'
           '  /* TODO : check flag */'
           '']

      if ng<>0 then
        txt=[txt;
             '  ida_data->gwork   = (double *) malloc(ng * sizeof(double));'
             '  /* TODO check malloc */'
             '']
      end

      //@@ TODO check if Jacobian is enable
      txt=[txt;
           '  if (AJacobian_block > 0) {'
           '    Jn  = NEQ;'
           '    Jnx = block_'+rdnom+'[AJacobian_block-1].nx;'
           '    Jno = block_'+rdnom+'[AJacobian_block-1].nout;'
           '    Jni = block_'+rdnom+'[AJacobian_block-1].nin;'
           '  }'
           '  else {'
           '    Jn  = NEQ;'
           '    Jnx = 0;'
           '    Jno = 0;'
           '    Jni = 0;'
           '  }'
           '  Jactaille = 3*Jn+(Jn+Jni)*(Jn+Jno)+Jnx*(Jni+2*Jn+Jno)+(Jn-Jnx)*(2*(Jn-Jnx)+Jno+Jni)+2*Jni*Jno;'
           ''
           '  ida_data->rwork = (double *) malloc(Jactaille * sizeof(double));'
           '  /* TODO check malloc */'
           ''
           '  flag = IDADenseSetJacFn(ida_mem, '+rdnom+'_Jacobians, ida_data);'
           '  /* TODO : check flag */'
           ''
           '  TJacque = (DenseMat) DenseAllocMat(NEQ, NEQ);'
           ''
           '  flag = IDASetRdata(ida_mem, ida_data);'
           '  /* TODO : check flag */'
           ''
           '  /* Setting the maximum number of Jacobian evaluation during a Newton step */'
           '  flag = IDASetMaxNumJacsIC(ida_mem, 100);'
           '  /* TODO : check flag */'
           ''
           '  /* Setting the maximum number of Newton iterations in any one attemp to solve CIC */'
           '  flag = IDASetMaxNumItersIC(ida_mem, 10);'
           '  /* TODO : check flag */'
           ''
           '  /* Setting the maximum number of steps in an integration interval */'
           '  flag = IDASetMaxNumSteps(ida_mem, 2000);'
           '  /* TODO : check flag */'
           ''
           '  /* Setting the maximum step time */'
           '  flag = IDASetMaxStep(ida_mem, mxstep);'
           '  /* TODO : check flag */'
           '']

    //@@ ODE case
    else
      txt=[txt;
           ''
           '  /* CVODE variable affectation */'
           '  y = N_VNewEmpty_Serial(NEQ);'
           '  NV_DATA_S(y) = x;'
           ''
           '  /* */'
           '  cvode_mem = NULL;'
           '  cvode_mem = CVodeCreate(CV_BDF, CV_NEWTON);'
           ''
           '  /* */'
           '  cv_data->cvode_mem = cvode_mem;'
           '  CVodeSetFdata(cvode_mem, cv_data);'
           ''
           '  /* */'
           '  flag = CVodeMalloc(cvode_mem, '+rdnom+'_simblk, T0, y, CV_SS, reltol, &abstol);'
           '  /* TODO : check flag */']

      if ng<>0 then
        txt=[txt;
             ''
             '  /* */'
             '  flag = CVodeRootInit(cvode_mem, ng, '+rdnom+'_grblk, NULL);'
             '  /* TODO : check flag */']
      end

      txt=[txt;
           ''
           '  /* */'
           '  flag = CVDense(cvode_mem, NEQ);'
           '  /* TODO : check flag */'
           '']

      txt=[txt;
           ''
           '  /* */'
           '  flag = CVodeSetMaxStep(cvode_mem, mxstep);'
           '  /* TODO : check flag */'
           '']
    end
  end

  if txt<>[] then
    Code=[Code;
          ''
          '  /* Solver initialisation */'
          txt]
  end

  //** cst blocks and it's dep
  txt=write_code_idoit()

  if txt<>[] then
    Code=[Code;
          ''
          '  /* Initial blocks must be called with flag 1 */'
          txt];
  end

  //@@ storing ZC signs just after a solver call
  if ng<>0 then
    Code=[Code;
          '  /*'
          '   * Update Zero Crossing surface'
          '   */'
          ''
          '  /* adjust xd ptr */']

    for k=1:nzord
      kf=zord(k,1)
      if (xptr(kf+1)-xptr(kf)) <> 0 then
        Code=[Code;
              '  block_'+rdnom+'['+string(kf-1)+'].xd = &(x['+string(xptr(kf)-1)+']);']
      end
    end

    Code=[Code;
          ''
          write_code_zdoit()
          '  /* adjust xd ptr */']

    for k=1:nzord
      kf=zord(k,1)
      if (xptr(kf+1)-xptr(kf)) <> 0 then
        Code=[Code;
              '  block_'+rdnom+'['+string(kf-1)+'].xd = &(xd['+string(xptr(kf)-1)+']);']
      end
    end

    Code=[Code;
          ''
          '  /* storing ZC signs just after a solver call */'
          '  for (i = 0; i < ng; i++) {'
          '    if (g[i] >= 0.) {'
          '      jroot[i] = 5;'
          '    }'
          '    else {'
          '      jroot[i] = -5;'
          '    }'
          '  }']
  end

  //## reinidoit
  if x <> [] then
    //## implicit block
    if impl_blk then
      txt=[write_code_reinitdoit(1) //** first pass
           write_code_reinitdoit(7) //** second pass
          ]

      if txt<>[] then
        Code=[Code;
              '  /* Initial derivative computation */'
              txt];
      end
    else
      Code=[Code;
            '']
    end
  else
    Code=[Code;
          '']
  end

  //** begin input main loop on time
  Code=[Code;
        '  /* loop on time */'
        '  while (told < tf) {';
        '']

  if size(evs,'*')<>0 then
    Code=[Code;
          '    /* Get current primary activation source */'
          '    kever = ptr->pointi;'
          ''
          '    if (ptr->pointi == 0) {'
          '      t = tf;'
          '    }'
          '    else {'
          '      t = ptr->tevts[ptr->pointi-1];'
          '    }']
  else
    Code=[Code;
          '    t = tf;']
  end

  Code=[Code;
        '    if (abs(t - told) < ttol) {'
        '      t = told;'
        '    }']

  Code=[Code;
        ''
        '    /* Continuous time */'
        '    if (told != t) {']

  if nX == 0 then
    Code=[Code;
          '      /* No continuous state */'
          '      if (told + deltat + ttol > t) {'
          '        told = t;'
          '      }'
          '      else {'
          '        told += deltat;'
          '      }']

    txt = write_code_cdoit(1);
 
    if txt <> [] then
      Code=[Code;
            '      /* */'
            '      if (told >= tf) {'
            '        /* save current time */'
            '        tsave       = t;'
            '        t           = told;'
            ''
            '       '+get_comment('ev',list(0))
            '    '+txt;
            '        /* restore current time */'
            '        t           = tsave;'
            '      }'
            ]
    end

  else
    if size(evs,'*')<>0 then
      Code=[Code;
            '      /* Integrate */'
            '      rhotmp = tf + ttol;'
            '      if (ptr->pointi != 0) {'
            '        kpo = ptr->pointi;'
            '      L20:'
            '        if (ptr->critev[kpo-1] == 1) {'
            '          rhotmp = ptr->tevts[kpo-1];'
            '          goto L30;'
            '        }'
            '        kpo = ptr->evtspt[kpo-1];'
            '        if (kpo != 0) {'
            '          goto L20;'
            '        }'
            '      L30:'
            '        if (rhotmp < tstop) {'
            '          hot = 0;'
            '        }'
            '      }'
            '      tstop = rhotmp;']
    else
      Code=[Code;
            '      /* Integrate */'
            '      rhotmp = tf + ttol;'
            '      tstop  = rhotmp;']
    end

    Code=[Code;
          ''
          '      /* update current time */'
          '      t = min(told + deltat,min(t,tf + ttol));'
          ''
          '      '+get_comment('update scicos_time',list())
          '      scicos_time = told;'
          '']

    //@@ discrete zero crossings (explicit case only)
    if ~impl_blk then
      if ng<>0 & nmod<>0 then
        Code=[Code;
              '      /* discrete zero crossing detection */'
              ''
              '      if (hot == 0) {'
              '        /*'
              '         * Update Zero Crossing surface'
              '         */'
              ''
              '        /* save current time */'
              '        tsave       = t;'
              '        t           = told;'
              ''
              '        /* adjust xd ptr */']

        for k=1:nzord
          kf=zord(k,1);
          if (xptr(kf+1)-xptr(kf)) <> 0 then
            Code=[Code;
                  '        block_'+rdnom+'['+string(kf-1)+'].x  = &(x['+string(xptr(kf)-1)+']);'
                  '        block_'+rdnom+'['+string(kf-1)+'].xd = &(x['+string(xptr(kf)-1)+']);']
           end
        end

        Code=[Code;
              ''
              '        /* adjust g ptr */'
              '        for (i = 0; i < ng; i++) g[i] = 0.;']
        for kf=1:nblk
          if (zcptr(kf+1)-zcptr(kf)) <> 0 then
              Code=[Code;
                    '        block_'+rdnom+'['+string(kf-1)+'].g = &(g['+string(zcptr(kf)-1)+']);']
          end
        end

        Code=[Code;
              ''
              '      '+write_code_zdoit()
              '        /* adjust xd ptr */']

        for k=1:nzord
          kf=zord(k,1);
          if (xptr(kf+1)-xptr(kf)) <> 0 then
            Code=[Code;
                  '        block_'+rdnom+'['+string(kf-1)+'].xd = &(xd['+string(xptr(kf)-1)+']);']
          end
        end

        Code=[Code;
              ''
              '        /* restore current time */'
              '        t           = tsave;'
              '      }']
      end
    end

    Code=[Code;
          ''
          '      /* reinitialisation if needed */'
          '      if (hot == 0) {']

    //@@ implicit case
    if impl_blk then
      Code=[Code;
            '        /* Setting the stop time*/'
            '        flag = IDASetStopTime(ida_mem, (realtype)tstop);'
            '        /* TODO : check flag */'
            '']

      //@@ txt_zdoit
      txt_zdoit =['        /* discrete zero crossing detection */'
              ''
              '        /* set phase simulation */'
              '        phase = 1;'
              ''
              '        /* save current time */'
              '        tsave       = t;'
              '        t           = told;'
              ''
              '        /*'
              '         * Update Zero Crossing surface'
              '         */'
              ''
              '        /* adjust xd ptr */']

        for k=1:nzord
          kf=zord(k,1)
          if (xptr(kf+1)-xptr(kf)) <> 0 then
            txt_zdoit=[txt_zdoit;
                       '        block_'+rdnom+'['+string(kf-1)+'].x  = &(x['+string(xptr(kf)-1)+']);'
                       '        block_'+rdnom+'['+string(kf-1)+'].xd = &(xd['+string(xptr(kf)-1)+']);']
          end
        end

        txt_zdoit=[txt_zdoit;
              ''
              '        /* adjust g ptr */'
              '        for (i = 0; i < ng; i++) g[i] = 0.;']
        for kf=1:nblk
          if (zcptr(kf+1)-zcptr(kf)) <> 0 then
              txt_zdoit=[txt_zdoit;
                    '        block_'+rdnom+'['+string(kf-1)+'].g = &(g['+string(zcptr(kf)-1)+']);']
          end
        end

        txt_zdoit=[txt_zdoit;
              ''
              '      '+write_code_zdoit()]

        txt_zdoit=[txt_zdoit;
              '        /* restore current time */'
              '        t           = tsave;'
              '']

      //@@ call zdoit hot = 0 IDA 1
      if ng<>0 & nmod<>0 then
        Code=[Code;
              txt_zdoit]
      end

      Code=[Code;
            '        /* ID setting/checking */'
            '        N_VConst(ONE, IDx); /* Initialize id to 1''s. */'
            '        scicos_xproperty=NV_DATA_S(IDx);']

      txt=[write_code_reinitdoit(1) //** first pass
           write_code_reinitdoit(7) //** second pass
          ]

      if txt<>[] then
        Code=[Code;
              ''
              '        /* Update Sfcallerid value'
              '         * Added because reinitdoit() has call to blocks with flag 0'
              '         */'
              '        Sfcallerid=-18;'
              ''
              '        /* save current time */'
              '        tsave       = t;'
              '        t           = told;'
              '']
        //@@ adjust x ptr
        txt2=[]
        for kf=1:nblk
          if (xptr(kf+1)-xptr(kf)) <> 0 then
            txt2=[txt2;
                  '        block_'+rdnom+'['+string(kf-1)+'].x   = &(x['+string(xptr(kf)-1)+']);'
                  '        block_'+rdnom+'['+string(kf-1)+'].xd  = &(xd['+string(xptr(kf)-1)+']);'
                  '        block_'+rdnom+'['+string(kf-1)+'].res = &(res['+string(xptr(kf)-1)+']);']
          end
        end
        if txt2<>[] then
          Code=[Code;
                '        /* adjust x ptr */'
                txt2
                '']
        end
        Code=[Code;
              '      '+txt
              '        /* restore current time */'
              '        t           = tsave;']
      end

      Code=[Code;
            ''
            '        /* */'
            '        CI=0.;'
            '        CJ=100.;'
            '        for (i = 0; i < NEQ; i++) {'
            '          if (xprop[i] ==  1) scicos_xproperty[i] = ONE;'
            '          if (xprop[i] == -1) scicos_xproperty[i] = ZERO;'
            '          alpha[i] = CI;'
            '          beta[i]  = CJ;'
            '        }']

      Code=[Code;
            ''
            '        /* */'
            '        '+rdnom+'_Jacobians(NEQ, (realtype) (told), yy, yp, bidon, \'
            '                  (realtype) CJ, ida_data, TJacque, tempv1, tempv2, tempv3);'
            ''
            '        /* */'
            '        for (i = 0; i < NEQ; i++) {'
            '          Jacque_col = DENSE_COL(TJacque,i);'
            '          CI=ZERO;'
            '          for (kf = 0; kf < NEQ; kf++) {'
            '            if ((Jacque_col[kf]-Jacque_col[kf]) != 0) {'
            '              CI = -ONE;'
            '              break;'
            '            }'
            '            else {'
            '              if (Jacque_col[kf] != 0) {'
            '                CI = ONE;'
            '                break;'
            '              }'
            '            }'
            '          }'
            '          if (CI >= ZERO) {'
            '            scicos_xproperty[i] = CI;'
            '          }'
            '          else {'
            '            fprintf(stderr,""\n\rWarning! Xproperties are not match for i=%d!"",i);'
            '          }'
            '        }'
            ''
            '        CI=1.;'
            '        for (i = 0; i < NEQ; i++) {'
            '          alpha[i] = CI;'
            '        }'
            '']

      Code=[Code;
            '        flag = IDASetId(ida_mem,IDx);'
            '        /* TODO : check flag */'
            ''
            '        flag = IDASetMaxNumJacsIC(ida_mem, 100);'
            '        /* TODO : check flag */'
            ''
            '        flag = IDASetLineSearchOffIC(ida_mem,FALSE);'
            '        /* TODO : check flag */'
            ''
            '        flag = IDASetMaxNumItersIC(ida_mem, 10);'
            '        /* TODO : check flag */']

      txt_no_zc_no_mode = [''
            '        flag = IDAReInit(ida_mem, '+rdnom+'_simblkdaskr, (realtype)(told), yy, yp, IDA_SS, reltol, &abstol);'
            '        /* TODO : check flag */'
            ''
            '        /* */'
            '        phase = 2;'
            ''
            '        /* */'
            '        IDA_mem_ptr->ida_kk=1;'
            ''
            '        flagr = IDACalcIC(ida_mem, IDA_YA_YDP_INIT, (realtype)(t));'
            '        /* TODO : check flagr */'
            ''
            '        /* */'
            '        phase = 1;'
            ''
            '        flag  = IDAGetConsistentIC(ida_mem, yy, yp);'
            '        /* TODO : check flag */']

      //@@ call zdoit hot = 0 IDA 2
      if ng<>0 & nmod<>0 then

        indent_txt_zdoit=[]
        for i=1:size(txt_zdoit,'*')
          if txt_zdoit(i)<>'' then
            indent_txt_zdoit=[indent_txt_zdoit
                              '  '+txt_zdoit(i)]
          else
            indent_txt_zdoit=[indent_txt_zdoit
                              '']
          end
        end

        indent_txt_no_zc_no_mode=[]
        for i=1:size(txt_no_zc_no_mode,'*')
          if txt_no_zc_no_mode(i)<>'' then
            indent_txt_no_zc_no_mode=[indent_txt_no_zc_no_mode
                                      '  '+txt_no_zc_no_mode(i)]
          else
            indent_txt_no_zc_no_mode=[indent_txt_no_zc_no_mode
                                      '']
          end
        end

        Code=[Code;
              ''
              '        for (ii = 0; ii <= '+string(4+nmod*4)+'; ii++) {'
              indent_txt_no_zc_no_mode
              ''
              '          /* saving the previous modes*/'
              '          for (j = 0; j < '+string(nmod)+'; ++j) {'
              '            Mode_save[j] = mode[j];'
              '          }'
              ''
              indent_txt_zdoit
              '          /* */'
              '          Mode_change = 0;'
              ''
              '          for (j = 0; j < '+string(nmod)+'; ++j) {'
              '            if (Mode_save[j] != mode[j]) {'
              '              Mode_change=1;'
              '              break;'
              '            }'
              '          }'
              ''
              '          if (Mode_change == 0) {'
              '            if (flagr >= 0) {'
              '              break;'
              '            }'
              '            else if (ii >= '+string(2+nmod*2)+') {'
              ''
              '              IDASetMaxNumJacsIC(ida_mem,10);'
              ''
              '              IDASetLineSearchOffIC(ida_mem,TRUE);'
              ''
              '              flag=IDASetMaxNumItersIC(ida_mem, 1000);'
              '              /* TODO : check flag */'
              '            }'
              '          }'
              '        }'
              ''
              '        if (Mode_change == 1) {'
              '          /* */'
              '          phase = 1;'
              ''
              '          /* */'
              '          IDA_mem_ptr->ida_kk=1;'
              ''
              '          flagr = IDACalcIC(ida_mem, IDA_YA_YDP_INIT, (realtype)(t));'
              '          /* TODO : check flag */'
              ''
              '          /* */'
              '          phase = 1;'
              ''
              '          flag  = IDAGetConsistentIC(ida_mem, yy, yp);'
              '          /* TODO : check flag */'
              '        }'
              ]

      //@@ no zc no mode
      else
        Code=[Code;
              txt_no_zc_no_mode]

      end

    //@@ explicit case
    else
      Code=[Code;
            '        /* Setting the stop time*/'
            '        flag = CVodeSetStopTime(cvode_mem, (realtype)tstop);'
            '        /* TODO : check flag */'
            ''
            '        flag = CVodeReInit(cvode_mem, '+rdnom+'_simblk, (realtype)(told), y, CV_SS, reltol, &abstol);'
            '        /* TODO : check flag */'
            '']
    end

    Code=[Code;
          '      }'
          '']

    //@@ discrete zero crossings
    if ng<>0 then
      Code=[Code;
            '      /* discrete zero crossing detection */'
            '      Discrete_Jump = 0;'
            ''
            '      if (hot == 0) {'
            '        /*'
            '         * Update Zero Crossing surface'
            '         */'
            ''
            '        /* save current time */'
            '        tsave       = t;'
            '        t           = told;'
            ''
            '        /* adjust xd ptr */']

      for k=1:nzord
        kf=zord(k,1);
        if (xptr(kf+1)-xptr(kf)) <> 0 then
          Code=[Code;
                '        block_'+rdnom+'['+string(kf-1)+'].x  = &(x['+string(xptr(kf)-1)+']);']
          if impl_blk then
            Code=[Code;
                  '        block_'+rdnom+'['+string(kf-1)+'].xd = &(xd['+string(xptr(kf)-1)+']);']
          else
            Code=[Code;
                  '        block_'+rdnom+'['+string(kf-1)+'].xd = &(x['+string(xptr(kf)-1)+']);']
          end
        end
      end

      Code=[Code;
            ''
            '        /* adjust g ptr */'
            '        for (i = 0; i < ng; i++) g[i] = 0.;']
      for kf=1:nblk
        if (zcptr(kf+1)-zcptr(kf)) <> 0 then
            Code=[Code;
                  '        block_'+rdnom+'['+string(kf-1)+'].g = &(g['+string(zcptr(kf)-1)+']);']
        end
      end

      Code=[Code;
            ''
            '      '+write_code_zdoit()
            '        /* restore current time */'
            '        t           = tsave;']

      if ~impl_blk then
        Code=[Code;
              '        /* adjust xd ptr */']

        for k=1:nzord
          kf=zord(k,1)
          if (xptr(kf+1)-xptr(kf)) <> 0 then
            Code=[Code;
                  '        block_'+rdnom+'['+string(kf-1)+'].xd = &(xd['+string(xptr(kf)-1)+']);']
          end
        end
      end

      Code=[Code;
            ''
            '        for (i = 0; i < ng; i++) {'
            '          if ((g[i] >= 0.) && (jroot[i] == -5)) {'
            '            Discrete_Jump = 1;'
            '            jroot[i]      = 1;'
            '          }'
            '          else if ((g[i] < 0.) && (jroot[i] == 5)) {'
            '            Discrete_Jump = 1;'
            '            jroot[i]      = -1;'
            '          }'
            '          else {'
            '            jroot[i] = 0;'
            '          }'
            '        }'
            '      }'
            '']

    end

    //@@ implicit case
    if impl_blk then
      txt=['      /* integration */'
           '      phase = 2;'
           '      flag  = IDASolve(ida_mem, t, &told, yy, yp, IDA_NORMAL_TSTOP);'
           '      phase = 1;']

      if ng<>0 then
        Code=[Code;
              '      if (Discrete_Jump == 0) {'
              '  '+txt
              '      }'
              '      else {'
              '        flag = IDA_ROOT_RETURN;'
              '      }']
      else
        Code=[Code;
              txt]
      end

    //@@ explicit case
    else
      txt=['      /* integration */'
           '      phase = 2;'
           '      flag  = CVode(cvode_mem, t, y, &told, CV_NORMAL_TSTOP);'
           '      phase = 1;']

      if ng<>0 then
        Code=[Code;
              '      if (Discrete_Jump == 0) {'
              '  '+txt
              '      }'
              '      else {'
              '        flag = CV_ROOT_RETURN;'
              '      }']
      else
        Code=[Code;
              txt]
      end
    end

    //@@ Update Sfcallerid value
    Code=[Code;
          ''
          '      /* update Sfcallerid value */'
          '      Sfcallerid=98;']

    txt = write_code_cdoit(1);

    if txt <> [] then
      Code=[Code;
            ''
            '      /* */'
            '      if (told >= tf) {'
            '        /* save current time */'
            '        tsave       = t;'
            '        t           = told;'
            ''
            '       '+get_comment('ev',list(0))
            '    '+txt;
            '        /* restore current time */'
            '        t           = tsave;'
            '      }'
            ]
    end

    Code=[Code;
          ''
          '      if (flag >= 0) {'
          '        hot = 1;'
          '      }'
          '']

    //@@ implicit case
    if impl_blk then
      Code=[Code
            '      /* new feature of sundials, detects unmasking */'
            '      if (flag == IDA_ZERO_DETACH_RETURN) {'
            '        hot = 0;'
            '      }'
            '']
    //@@ explicit case
    else
      Code=[Code;
            '      /* new feature of sundials, detects zero-detaching */'
            '      if (flag == CV_ZERO_DETACH_RETURN) {'
            '        hot = 0;'
            '      }'
            '']
    end

    if ng<>0 then
      //@@ implicit case
      if impl_blk then
        Code=[Code;
              '      /* at a least one root has been found */'
              '      if (flag == IDA_ROOT_RETURN) {'
              '        hot = 0;'
              '        if (Discrete_Jump == 0) {'
              '          flagr = IDAGetRootInfo(ida_mem, jroot);'
              '          /* TODO : check flagr */'
              '        }'
              '']

      //@@ explicit case
      else
        Code=[Code;
              '      /* at a least one root has been found */'
              '      if (flag == CV_ROOT_RETURN) {'
              '        hot = 0;'
              '        if (Discrete_Jump == 0) {'
              '          flagr = CVodeGetRootInfo(cvode_mem, jroot);'
              '          /* TODO : check flagr */'
              '        }'
              '']
      end

      Code=[Code;
            '        /*'
            '         * Update Zero Crossing surface'
            '         * NB : only for old block (? : ask Masoud)'
            '         */']

      Code=[Code;
            ''
            '        /* save current time */'
            '        tsave       = t;'
            '        t           = told;'
            ''
            '        /* adjust x ptr */']
      for k=1:nzord
        kf=zord(k,1)
        if (xptr(kf+1)-xptr(kf)) <> 0 then
          Code=[Code;
                '        block_'+rdnom+'['+string(kf-1)+'].x  = &(x['+string(xptr(kf)-1)+']);'
                '        block_'+rdnom+'['+string(kf-1)+'].xd = &(xd['+string(xptr(kf)-1)+']);']
        end
      end

      Code=[Code;
            ''
            '        /* adjust g ptr */'
            '        for (i = 0; i < ng; i++) g[i] = 0.;']

      for kf=1:nblk
        if (zcptr(kf+1)-zcptr(kf)) <> 0 then
            Code=[Code;
                  '        block_'+rdnom+'['+string(kf-1)+'].g = &(g['+string(zcptr(kf)-1)+']);']
        end
      end

      Code=[Code;
            ''
            '      '+write_code_zdoit()
            '        /* restore current time */'
            '        t           = tsave;'
            '']

      //** flag 3,2
      txt22 = [];
      for flag=[3,2]
        for k=1:nzord
          bk=zord(k,1);
          if (zcptr(bk+1)-zcptr(bk)) <> 0 then
            //@@ Ooups
            pt=abs(zord(k,2));
            pt=1;
            txt_tmp=call_block42(bk,-pt,flag)
            if txt_tmp<> [] then
              txt_tmp='    '+txt_tmp;

              txt22=[txt22;
                     txt_tmp];

            end
          end
        end
      end
      if txt22<>[] then
        Code=[Code;
              '        /* save current time */'
              '        tsave       = t;'
              '        t           = told;'
              ''
              '    '+txt22
              ''
              '        /* restore current time */'
              '        t           = tsave;']
      end

      Code=[Code;
            '      }']
    end

  end

  if ng<>0 then
    Code=[Code;
          ''
          '      /*'
          '       * Update Zero Crossing surface'
          '       */'
          ''
          '      /* save current time */'
          '      tsave       = t;'
          '      t           = told;'
          ''
          '      /* adjust xd ptr */']

    for k=1:nzord
      kf=zord(k,1)
      if (xptr(kf+1)-xptr(kf)) <> 0 then
        Code=[Code;
              '      block_'+rdnom+'['+string(kf-1)+'].x   = &(x['+string(xptr(kf)-1)+']);']
        if impl_blk then
          Code=[Code;
                '      block_'+rdnom+'['+string(kf-1)+'].xd  = &(xd['+string(xptr(kf)-1)+']);'
                '      block_'+rdnom+'['+string(kf-1)+'].res = &(res['+string(xptr(kf)-1)+']);']
        else
          Code=[Code;
                '      block_'+rdnom+'['+string(kf-1)+'].xd  = &(x['+string(xptr(kf)-1)+']);']
        end
      end
    end

    Code=[Code;
          ''
          '      /* adjust g ptr */'
          '      for (i = 0; i < ng; i++) g[i] = 0.;']
    for kf=1:nblk
      if (zcptr(kf+1)-zcptr(kf)) <> 0 then
        Code=[Code;
              '      block_'+rdnom+'['+string(kf-1)+'].g = &(g['+string(zcptr(kf)-1)+']);']
       end
    end

    Code=[Code;
          ''
          '    '+write_code_zdoit()
          '      /* restore current time */'
          '      t           = tsave;']

    if ~impl_blk then
      Code=[Code;
            ''
            '      /* adjust xd ptr */']

      for k=1:nzord
        kf=zord(k,1)
        if (xptr(kf+1)-xptr(kf)) <> 0 then
          Code=[Code;
                '      block_'+rdnom+'['+string(kf-1)+'].xd = &(xd['+string(xptr(kf)-1)+']);']
        end
      end
    end

    Code=[Code;
          ''
          '      for (i = 0; i < ng; i++) {'
          '        if (g[i] >= 0.) {'
          '          jroot[i] = 5;'
          '        }'
          '        else {'
          '          jroot[i] = -5;'
          '        }'
          '      }']
  else
    txt=[]
    for kf=1:nblk
      if (xptr(kf+1)-xptr(kf)) <> 0 then
        txt=[txt;
             '      block_'+rdnom+'['+string(kf-1)+'].x   = &(x['+string(xptr(kf)-1)+']);'
             '      block_'+rdnom+'['+string(kf-1)+'].xd  = &(xd['+string(xptr(kf)-1)+']);']
        if impl_blk then
          txt=[txt;
               '      block_'+rdnom+'['+string(kf-1)+'].res = &(res['+string(xptr(kf)-1)+']);']
        end
      end
    end
    if txt<>[] then
      Code=[Code;
            '      /* adjust x ptr */'
            txt]
    end
  end

  Code=[Code;
        '    }']

  Code=[Code;
        '    else {'
        '      /* t == told */'
        ''
        '      '+get_comment('update scicos_time',list())
        '      scicos_time = t;'
        '']

  if size(evs,'*')<>0 then
    Code=[Code;
          '      /* Get current primary activation source */'
          '      kever = ptr->pointi;'
          '      ptr->pointi = ptr->evtspt[kever-1];'
          '      ptr->evtspt[kever-1] = -1;'
          '']
  end

  //** flag 1,2,3
  for flag=[1,3,2]

    txt3=[]

    //** continuous time blocks must be activated
    //** for flag 1
//     if flag==1 then
//       txt = write_code_cdoit(flag);
// 
//       if txt <> [] then
//         txt3=[''
//               '      '+get_comment('ev',list(0))
//               '  '+txt;
//              ];
//       end
//     end

    //** blocks with input discrete event must be activated
    //** for flag 1, 2 and 3
    if size(evs,2)>=1 then
      txt4=[]
      //**
      for ev=evs
        txt2=write_code_doit(ev,flag);
        if txt2<>[] then
          //** adjust event number because of bidon block
          if ~ALL then
            new_ev=ev-(clkptr(howclk)-1)
          else
            new_ev=ev-min(evs)+1
          end
          is_crit=cpr.sim.critev(ev)
          //**
          txt4=[txt4;
                Indent2+['  case '+string(new_ev)+' : '+...
                get_comment('ev',list(new_ev))
                   txt2];]
          if is_crit then
            if nX<>0 then
              txt4=[txt4;
                    '        /* critical event */'
                    '        hot = 0;'
                    '']
            end
          end
          txt4=[txt4;
                '      break;'
                '']
        end
      end

      //**
      if txt4 <> [] then
        if ~ALL then
          txt3=[txt3;
                Indent+'    /* Discrete activations */'
                Indent+'    switch (nevprt) {'
                '  '+txt4
                '      }'];
        else
          txt33=[]
          if flag==1 then
            if nX<>0 then
              //@@ do_cold_restart if it is a critical event
              txt33=[''
                     Indent+'    /* */'
                     Indent+'    /* if (ptr->critev[kever-1] != 0) {'
                     Indent+'     * hot = 0;'
                     Indent+'     *}'
                     Indent+'     */']
            end
//          elseif flag==3 then
//            //@@ adjust pointi
//            txt33=[Indent+'    /* */'
//                   Indent+'    ptr->pointi = ptr->evtspt[kever-1];'
//                   Indent+'    ptr->evtspt[kever-1] = -1;'
//                   '']
          end
          txt3=[txt33;
                txt3;
                Indent+'    switch (kever) {'
                '  '+txt4
                '      }'
                ''];
        end
      end
    end

    //**
    if txt3<>[] then
      Code=[Code;
            '      '+get_comment('flag',list(flag))
            txt3];
    end
  end

  Code=[Code;
        '    }'
        '  }'
        '']

  //** flag 5

  Code=[Code
        '  /* Ending */'
        '  '+rdnom+'_cosend();']

  if Code_Free<>[] then
    Code=[Code
          ''
          '  '+Code_Free]
  end

  Code=[Code
        ''
        '  return get_block_error();'
        '}'
        '']

  Code=[Code
        Code_end_fun
        '']

  if (x <> []) then

    //## implicit case
    if impl_blk then
      if ~ALL then
        Code=[Code;
              'int '+rdnom+'simblk_imp(t, x, xd, res)'
              ''
              '   double t, *x, *xd, *res;']
      else
        Code=[Code;
              '/*'+part('-',ones(1,40))+' simblkdaskr function */'
              'int '+rdnom+'_simblkdaskr(realtype tres, N_Vector yy, N_Vector yp, N_Vector resval, void *rdata)']
      end

      if ~ALL then
        Code=[Code;
              ''
              '     /*'
              '      *  !purpose'
              '      *  compute state derivative of the continuous part'
              '      *  !calling sequence'
              '      *  NEQ   : a defined integer : the size of the  continuous state'
              '      *  t     : current time'
              '      *  x     : double precision vector whose contains the continuous state'
              '      *  xd    : double precision vector whose contains the computed derivative'
              '      *          of the state'
              '      *  res   : double precision vector whose contains the computed residual'
              '      *          of the state'
              '      */']
      end

      Code=[Code;
            '{'
            '  /* local variables used to call block */'
            '  int local_flag;']

      if act<>[] | cap<>[] then
        Code=[Code;
              '  int nport;']
      end

      Code=[Code;
            ''
            '  /* counter local variable */'
            '  int i;'
            '']

      if ALL then
        Code=[Code;
              '  /* */'
              '  double t, *x, *xd, *res;']

        if ng<>0 then
          Code=[Code;
                '  double *gout;']
        end

        Code=[Code;
              ''
              '  /* */'
              '  realtype hh;'
              '  realtype alpha;'
              '  int flag;'
              '  int qlast;'
              '  User_IDA_data data;'
              '  void *ida_mem;'
              '']
      end

      if (with_nrd & with_nrd2) then
        Code=[Code;
              '  /* variables for constant values */'
              '  int nrd_1, nrd_2;'
              '  double *args[100];'
              '']
      end

      Code=[Code;
            '  /* variables for solver */'
            '  data    = (User_IDA_data) rdata;'
            '  ida_mem = data->ida_mem;'
            '  IDAGetfcallerid(ida_mem,  &Sfcallerid);']

      if ng<>0 then
        Code=[Code;
              '  gout = (double *) data->gwork;']
      end

      Code=[Code;
            ''
            '  /* */'
            '  x    = (double *) NV_DATA_S(yy);'
            '  xd   = (double *) NV_DATA_S(yp);'
            '  res  = (double *) NV_DATA_S(resval);'
            '  t    = (double) tres;']

      Code=[Code;
            ''
            '  '+get_comment('update scicos_time',list())
            '  scicos_time = t;'
            '']

      if ng<>0 then
        Code=[Code;
              '  /* */'
              '  if (get_phase_simulation() == 1) {']

        Code=[Code;
              '    '+get_comment('update_xd',list())]

        for kf=1:nblk
          if (xptr(kf+1)-xptr(kf)) > 0 then
            Code=[Code;
                  '    block_'+rdnom+'['+string(kf-1)+'].x  = '+...
                  '&(x['+string(xptr(kf)-1)+']);']
            if impl_blk then
              Code=[Code;
                    '    block_'+rdnom+'['+string(kf-1)+'].xd = '+...
                    '&(xd['+string(xptr(kf)-1)+']);']
            end
          end
        end

        Code=[Code;
              ''
              '    /* adjust g ptr */'
              '    for (i = 0; i < '+string(ng)+'; i++) gout[i] = 0.;']

        for kf=1:nblk
          if (zcptr(kf+1)-zcptr(kf)) <> 0 then
            Code=[Code;
                  '    block_'+rdnom+'['+string(kf-1)+'].g = &(gout['+string(zcptr(kf)-1)+']);']
          end
        end

        Code=[Code;
              ''
              '  '+write_code_zdoit()]

        Code=[Code;
              '  }'
              '']
      end

      if ~ALL then
        Code=[Code;
              ''
              '  /* initialization of residual */'
              '  for (i = 0; i < NEQ; i++) res[i] = xd[i];'
              '']
      else
        Code=[Code;
              '  hh    = ZERO;'
              '  flag  = IDAGetCurrentStep(data->ida_mem, &hh);'
              '  /*TODO : check flag*/'
              ''
              '  qlast = 0;'
              '  flag  = IDAGetCurrentOrder(data->ida_mem, &qlast);'
              '  /*TODO : check flag*/'
              ''
              '  alpha = ZERO;'
              '  for (i = 0; i < qlast; i++) alpha = alpha -ONE/(i+1);'
              '  if (hh != 0) CJ = -alpha/hh;'
              '  /*TODO : error checking*/'
              '']

        Code=[Code;
              '  /* initialization of residual */'
              '  for (i = 0; i < NEQ; i++) res[i] = xd[i];'
              '']
      end

      Code=[Code;
            '  '+get_comment('update_xd',list())]

      for kf=1:nblk
        if (xptr(kf+1)-xptr(kf)) > 0 then
          Code=[Code;
                '  block_'+rdnom+'['+string(kf-1)+'].x   = '+...
                  ' &(x['+string(xptr(kf)-1)+']);'
                '  block_'+rdnom+'['+string(kf-1)+'].xd  = '+...
                  ' &(xd['+string(xptr(kf)-1)+']);'
                '  block_'+rdnom+'['+string(kf-1)+'].res = '+...
                  ' &(res['+string(xptr(kf)-1)+']);']
        end
      end

      Code=[Code;
            ''
            write_code_odoit(1)
            write_code_odoit(0)
           ]

      Code=[Code
            '  return 0;'
            '}'
            '']

      //@@ grblk generation
      if ALL then
        if ng<>0 then
          Code=[Code;
                '/*'+part('-',ones(1,40))+' grblkdaskr function */'
                'int '+rdnom+'_grblkdaskr(realtype tx, N_Vector yy, N_Vector yp, realtype *gout, void *g_data)']

          Code=[Code;
                '{'
                '  /* local variables used to call block */'
                '  int local_flag,i;']

          if act<>[] | cap<>[] then
            Code=[Code;
                  '  int nport;']
          end

          Code=[Code;
                ''
                '  double t, *x, *xd, *g;']

          if (with_nrd & with_nrd2) then
            Code=[Code;
                  '  /* Variables for constant values */'
                  '  int nrd_1, nrd_2;'
                  '  double *args[100];'
                  '']
          end

          Code=[Code;
                ''
                '  /* */'
                '  t  = (double) tx;'
                '  x  = (double *) NV_DATA_S(yy);'
                '  xd = (double *) NV_DATA_S(yp);'
                '  g  = (double *) gout;']

          Code=[Code;
                ''
                '  '+get_comment('update scicos_time',list())
                '  scicos_time = t;']

          Code=[Code;
                ''
                '  '+get_comment('update_xd',list())]

          for kf=1:nblk
            if (xptr(kf+1)-xptr(kf)) > 0 then
              Code=[Code;
                    '  block_'+rdnom+'['+string(kf-1)+'].x='+...
                    '&(x['+string(xptr(kf)-1)+']);']
              Code=[Code;
                    '  block_'+rdnom+'['+string(kf-1)+'].xd='+...
                    '&(xd['+string(xptr(kf)-1)+']);']
            end
          end

          Code=[Code;
                ''
                '  /* adjust g ptr */'
                '  for(i=0;i<'+string(ng)+';i++) gout[i]=0.;']

          for kf=1:nblk
            if (zcptr(kf+1)-zcptr(kf)) <> 0 then
              Code=[Code;
                    '  block_'+rdnom+'['+string(kf-1)+'].g = &(gout['+string(zcptr(kf)-1)+']);']
            end
          end

          Code=[Code;
                ''
                write_code_zdoit()]

          Code=[Code
                '  return 0;'
                '}'
                '']
        end
      end

      if ~ALL then
        Code=[Code
              '/* DAE Method */'
              'int dae1(f,x,xd,res,t,h)'
              '  int (*f) ();'
              '  double *x,*xd,*res;'
              '  double t, h;'
              '{'
              '  int i;'
              '  int ierr;'
              ''
              '  /**/'
              '  ierr=(*f)(t,x, xd, res);'
              '  if (ierr!=0) return ierr;'
              ''
              '  for (i=0;i<NEQ;i++) {'
              '   x[i]=x[i]+h*xd[i];'
              '  }'
              ''
              '  return 0;'
              '}']
      end

    //## explicit case
    else
      //@@ simblk generation
      if ~ALL then
        Code=[Code;
              'int '+rdnom+'_simblk(t, x, xd)'
              ''
              '   double t, *x, *xd;'
              '']
      else
        Code=[Code;
              '/*'+part('-',ones(1,40))+' simblk function */'
              'int '+rdnom+'_simblk(realtype tx, N_Vector yy, N_Vector yp, void *f_data)']
      end

      if ~ALL then
        Code=[Code;
              '     /*'
              '      *  !purpose'
              '      *  compute state derivative of the continuous part'
              '      *  !calling sequence'
              '      *  NEQ   : a defined integer : the size of the  continuous state'
              '      *  t     : current time'
              '      *  x     : double precision vector whose contains the continuous state'
              '      *  xd    : double precision vector whose contains the computed derivative'
              '      *          of the state'
              '      */']
       end

       Code=[Code;
            '{'
            '  /* local variables used to call block */'
            '  int local_flag;']

      if act<>[] | cap<>[] then
        Code=[Code;
              '  int nport;']
      end

      Code=[Code;
            ''
            '  /* counter local variable */'
            '  int i;'
            '']

      if ALL then
        Code=[Code;
              '  /* */'
              '  double t, *x, *xd;'
              '']
      end

      if (with_nrd &  with_nrd2) then
        Code=[Code;
              '  /* Variables for constant values */'
              '  int nrd_1, nrd_2;'
              '  double *args[100];'
              '']
      end

      if ALL then
        Code=[Code;
              '  /* Variable for solver */'
              '  void *cvode_mem;'
              ''
              '  /* get solver caller id */'
              '  cvode_mem = ((User_CV_data*) f_data)->cvode_mem;'
              '  CVodeGetfcallerid(cvode_mem, &Sfcallerid);']

        Code=[Code;
              '  t  = (double) tx;'
              '  x  = (double *) NV_DATA_S(yy);'
              '  xd = (double *) NV_DATA_S(yp);'
              ''
              '  '+get_comment('update scicos_time',list())
              '  scicos_time = t;']
      end

      Code=[Code;
            ''
            '  /* initialization of derivatives */'
            '  for(i=0;i<NEQ;i++) xd[i]=0.;']

      Code=[Code;
            ''
            '  '+get_comment('update_xd',list())]

      for kf=1:nblk
        if (xptr(kf+1)-xptr(kf)) > 0 then
          Code=[Code;
                '  block_'+rdnom+'['+string(kf-1)+'].x  ='+...
                  ' &(x['+string(xptr(kf)-1)+']);'
                '  block_'+rdnom+'['+string(kf-1)+'].xd ='+...
                  ' &(xd['+string(xptr(kf)-1)+']);']
        end
      end

      Code=[Code;
            ''
            write_code_odoit(1)
            write_code_odoit(0)
           ]

      Code=[Code
            '  return 0;'
            '}'
            '']

      //@@  generation
      if ALL then
        if ng<>0 then
          Code=[Code;
                '/*'+part('-',ones(1,40))+' grblk function */'
                'int '+rdnom+'_grblk(realtype tx, N_Vector yy, realtype *gout, void *g_data)']

          Code=[Code;
                '{'
                '  /* local variables used to call block */'
                '  int local_flag,i;']

          if act<>[] | cap<>[] then
            Code=[Code;
                  '  int nport;']
          end

          Code=[Code;
                ''
                '  double t, *x, *g;']

          if (with_nrd & with_nrd2) then
            Code=[Code;
                  '  /* Variables for constant values */'
                  '  int nrd_1, nrd_2;'
                  '  double *args[100];'
                  '']
          end

          Code=[Code;
                ''
                '  /* */'
                '  t  = (double) tx;'
                '  x  = (double *) NV_DATA_S(yy);'
                '  g  = (double *) gout;']

          Code=[Code;
                ''
                '  '+get_comment('update scicos_time',list())
                '  scicos_time = t;']

          Code=[Code;
                ''
                '  '+get_comment('update_xd',list())]

          for kf=1:nblk
            if (xptr(kf+1)-xptr(kf)) > 0 then
              Code=[Code;
                    '  block_'+rdnom+'['+string(kf-1)+'].x = '+...
                    '&(x['+string(xptr(kf)-1)+']);']
            end
          end

          Code=[Code;
                ''
                '  /* adjust g ptr */'
                '  for(i=0;i<'+string(ng)+';i++) gout[i]=0.;']

          for kf=1:nblk
            if (zcptr(kf+1)-zcptr(kf)) <> 0 then
              Code=[Code;
                    '  block_'+rdnom+'['+string(kf-1)+'].g = &(gout['+string(zcptr(kf)-1)+']);']
            end
          end

          Code=[Code;
                ''
                write_code_zdoit()]

          Code=[Code
                '  return 0;'
                '}'
                '']
        end
      end

      if ~ALL then
        Code=[Code
              '/* Euler''s Method */'
              'int ode1(f,x,xd,t,h)'
              '  int (*f) ();'
              '  double *x,*xd;'
              '  double t, h;'
              '{'
              '  int i;'
              '  int ierr;'
              ''
              '  /**/'
              '  ierr=(*f)(t,x, xd);'
              '  if (ierr!=0) return ierr;'
              ''
              '  for (i=0;i<NEQ;i++) {'
              '   x[i]=x[i]+h*xd[i];'
              '  }'
              ''
              '  return 0;'
              '}'
              ''
              '/* Heun''s Method */'
              'int ode2(f,x,xd,t,h)'
              '  int (*f) ();'
              '  double *x,*xd;'
              '  double t, h;'
              '{'
              '  int i;'
              '  int ierr;'
              '  double y['+string(nX)+'],yh['+string(nX)+'],temp,f0['+string(nX)+'],th;'
              ''
              '  /**/'
              '  memcpy(y,x,NEQ*sizeof(double));'
              '  memcpy(f0,xd,NEQ*sizeof(double));'
              ''
              '  /**/'
              '  ierr=(*f)(t,y, f0);'
              '  if (ierr!=0) return ierr;'
              ''
              '  /**/'
              '  for (i=0;i<NEQ;i++) {'
              '    x[i]=y[i]+h*f0[i];'
              '  }'
              '  th=t+h;'
              '  for (i=0;i<NEQ;i++) {'
              '    yh[i]=y[i]+h*f0[i];'
              '  }'
              '  ierr=(*f)(th,yh, xd);'
              '  if (ierr!=0) return ierr;'
              ''
              '  /**/'
              '  temp=0.5*h;'
              '  for (i=0;i<NEQ;i++) {'
              '    x[i]=y[i]+temp*(f0[i]+xd[i]);'
              '  }'
              ''
              '  return 0;'
              '}'
              ''
              '/* Fourth-Order Runge-Kutta (RK4) Formula */'
              'int ode4(f,x,xd,t,h)'
              '  int (*f) ();'
              '  double *x,*xd;'
              '  double t, h;'
              '{'
              '  int i;'
              '  int ierr;'
              '  double y['+string(nX)+'],yh['+string(nX)+'],'+...
                'temp,f0['+string(nX)+'],th,th2,'+...
                'f1['+string(nX)+'],f2['+string(nX)+'];'
              ''
              '  /**/'
              '  memcpy(y,x,NEQ*sizeof(double));'
              '  memcpy(f0,xd,NEQ*sizeof(double));'
              ''
              '  /**/'
              '  ierr=(*f)(t,y, f0);'
              '  if (ierr!=0) return ierr;'
              ''
              '  /**/'
              '  for (i=0;i<NEQ;i++) {'
              '    x[i]=y[i]+h*f0[i];'
              '  }'
              '  th2=t+h/2;'
              '  for (i=0;i<NEQ;i++) {'
              '    yh[i]=y[i]+(h/2)*f0[i];'
              '  }'
              '  ierr=(*f)(th2,yh, f1);'
              '  if (ierr!=0) return ierr;'
              ''
              '  /**/'
              '  temp=0.5*h;'
              '  for (i=0;i<NEQ;i++) {'
              '    x[i]=y[i]+temp*f1[i];'
              '  }'
              '  for (i=0;i<NEQ;i++) {'
              '    yh[i]=y[i]+(h/2)*f1[i];'
              '  }'
              '  ierr=(*f)(th2,yh, f2);'
              '  if (ierr!=0) return ierr;'
              ''
              '  /**/'
              '  for (i=0;i<NEQ;i++) {'
              '    x[i]=y[i]+h*f2[i];'
              '  }'
              '  th=t+h;'
              '  for (i=0;i<NEQ;i++) {'
              '    yh[i]=y[i]+h*f2[i];'
              '  }'
              '  ierr=(*f)(th2,yh, xd);'
              '  if (ierr!=0) return ierr;'
              ''
              '  /**/'
              '  temp=h/6;'
              '  for (i=0;i<NEQ;i++) {'
              '    x[i]=y[i]+temp*(f0[i]+2.0*f1[i]+2.0*f2[i]+xd[i]);'
              '  }'
              ''
              '  return 0;'
              '}'
              '']
      end
    end
  end

  //@@ addevs function
  if ALL & size(evs,'*')<>0 then
    Code=[Code;
          '/*'+part('-',ones(1,40))+' agenda function */'
          'void '+rdnom+'_addevs(agenda_struct *ptr, double t, int evtnb)'
          '{'
          '  /* counter local variable */'
          '  int i,j;'
          '']

    if debug_cdgen then
      Code=[Code;
            '  fprintf(stderr,""addevs (begin)\n \tpointi=%d\n \tevtnb=%d\n \tptr->evtspt[evtnb-1]=%d\n \tt=%f\n"", \'
            '                 ptr->pointi,evtnb,ptr->evtspt[evtnb-1],t);'
            '']
    end

    Code=[Code;
          '  /*  */'
          '  if (ptr->evtspt[evtnb-1] != -1) {'
          '    if ((ptr->evtspt[evtnb-1] == 0) && (ptr->pointi == evtnb)) {'
          '      ptr->tevts[evtnb-1] = t;'
          '      return;'
          '    }'
          '    /* */'
          '    else {'
          '      /* */'
          '      if (ptr->pointi == evtnb) {'
          '        /* remove from chain, pointi is now the event provided by ptr->evtspt[evtnb] */'
          '        ptr->pointi = ptr->evtspt[evtnb-1];'
          '      }'
          '      /* */'
          '      else {'
          '        /* find where is the event to be updated in the agenda */'
          '        i = ptr->pointi;'
          '        while (evtnb != ptr->evtspt[i-1]) {'
          '          i = ptr->evtspt[i-1];'
          '        }'
          '        /* remove old evtnb from chain */'
          '        ptr->evtspt[i-1] = ptr->evtspt[evtnb-1];'
          ''
          '        /* if (TCritWarning == 0) {'
          '         *  sciprint(""\n\r Warning:an event is reprogrammed at t=%g by removing another"",t );'
          '         *  sciprint(""\n\r         (already programmed) event. There may be an error in"");'
          '         *  sciprint(""\n\r         your model. Please check your model\n\r"");'
          '         *  TCritWarning=1;'
          '         * }'
          '         */'
          '']

    if nX<>0 then
      Code=[Code;
            '        /* the erased event could be a critical event */'
            '        hot = 0;'
            '']
    end

    Code=[Code;
          '      }'
          ''
          '      /* */'
          '      ptr->evtspt[evtnb-1] = 0;'
          '      ptr->tevts[evtnb-1]  = t;'
          '    }'
          '  }'
          '  else {'
          '    ptr->evtspt[evtnb-1] = 0;'
          '    ptr->tevts[evtnb-1]  = t;'
          '  }'
          ''
          '  /* */'
          '  if (ptr->pointi == 0) {'
          '    ptr->pointi = evtnb;'
          '    return;'
          '  }'
          '  if (t < ptr->tevts[ptr->pointi-1]) {'
          '    ptr->evtspt[evtnb-1] = ptr->pointi;'
          '    ptr->pointi = evtnb;'
          '    return;'
          '  }'
          ''
          '  /* */'
          '  i = ptr->pointi;'
          ''
          ' L100:'
          '  if (ptr->evtspt[i-1] == 0) {'
          '    ptr->evtspt[i-1] = evtnb;'
          '    return;'
          '  }'
          '  if (t >= ptr->tevts[ptr->evtspt[i-1]-1]) {'
          '    j = ptr->evtspt[i-1];'
          '    if (ptr->evtspt[j-1] == 0) {'
          '      ptr->evtspt[j-1] = evtnb;'
          '      return;'
          '    }'
          '    i = j;'
          '    goto L100;'
          '  }'
          '  else {'
          '    ptr->evtspt[evtnb-1] = ptr->evtspt[i-1];'
          '    ptr->evtspt[i-1] = evtnb;'
          '  }'
          '']

    if debug_cdgen then
      Code=[Code;
            '  fprintf(stderr,""addevs (end), pointi=%d\n"",ptr->pointi);'
            '']
    end

    Code=[Code;
          '  return;'
          '}'
         ]
  end

  //@@ Jacobians
  if ALL & impl_blk & nX<>0 then
    Code=[Code;
          ''
          make_jac()]
  end

  if impl_blk then
    Code=[Code;
          '/*'+part('-',ones(1,40))+' set_Jacobian_flag function */'
          'void Set_Jacobian_flag(int flag)'
          '{'
          '  Jacobian_Flag=flag;'
          '  return;'
          '}'
          '']

    Code=[Code;
          '/*'+part('-',ones(1,40))+' get_Jacobian_ci function */'
          'double Get_Jacobian_ci(void)'
          '{'
          '  return CI;'
          '}'
          '']

    Code=[Code;
          '/*'+part('-',ones(1,40))+' get_Jacobian_cj function */'
          'double Get_Jacobian_cj(void)'
          '{'
          '  return CJ;'
          '}'
          '']

    Code=[Code;
          '/*'+part('-',ones(1,40))+' get_Scicos_SQUR function */'
          'double Get_Scicos_SQUR(void)'
          '{'
          '  return  SQuround;'
          '}'
          '']

    Code=[Code;
          '/*'+part('-',ones(1,40))+' exp_ function */'
          'double exp_(double x)'
          '{'
          '  double Limit=16;'
          ''
          '  if (x<Limit) {'
          '    return exp(x);'
          '  }'
          '  else {'
          '    return exp(Limit)*(x+1-Limit);'
          '  }'
          '}'
          '']

    Code=[Code;
          '/*'+part('-',ones(1,40))+' log_ function */'
          'double log_(double x)'
          '{'
          '  double eps=1e-10;'
          ''
          '  if (abs(x)>eps) {'
          '    return log(abs(x));'
          '  }'
          '  else {'
          '    return (abs(x)/eps)+log(eps)-1;'
          '  }'
          '}'
          '']

    Code=[Code;
          '/*'+part('-',ones(1,40))+' pow_ function */'
          'double pow_(double x, double y)'
          '{'
          '  return exp_(y*log_(x));'
          '}'
          '']
  end

  Code=[Code
        ''
        '/*'+part('-',ones(1,40))+' Lapack messag function */';
        'void C2F(xerbla)(char *SRNAME, int *INFO, long int L)'
        '{'
        '  printf(""** On entry to %s, parameter number %d""'
        '         ""  had an illegal value\n"",SRNAME,*INFO);'
        '}'
        '']

  Code=[Code;
        '/*'+part('-',ones(1,40))+' set_block_error function */'
        'void set_block_error(int err)'
        '{'
        '  *block_error = err;'
        '  return;'
        '}'
        '']

  Code=[Code;
        '/*'+part('-',ones(1,40))+' get_block_error function */'
        'int get_block_error()'
        '{'
        '  return *block_error;'
        '}'
        '']

  Code=[Code;
        '/*'+part('-',ones(1,40))+' set_block_number function */'
        'void set_block_number(int kfun)'
        '{'
        '  block_number = kfun;'
        '  return;'
        '}'
        '']

  Code=[Code;
        '/*'+part('-',ones(1,40))+' get_block_number function */'
        'int get_block_number()'
        '{'
        '  return block_number;'
        '}'
        '']

  Code=[Code;
        '/*'+part('-',ones(1,40))+' get_phase_simulation function */'
        'int get_phase_simulation()'
        '{'
        '  return phase;'
        '}'
        '']

  if ALL then
    Code=[Code
          '/*'+part('-',ones(1,40))+' get_fcaller_id function */'
          'int get_fcaller_id()'
          '{'
          '  return Sfcallerid;'
          '}'
          '']
  end

  Code=[Code;
        '/*'+part('-',ones(1,40))+' scicos_malloc function */'
        'void * scicos_malloc(size_t size)'
        '{'
        '  return malloc(size);'
        '}'
        '']

  Code=[Code;
        '/*'+part('-',ones(1,40))+' scicos_free function */'
        'void scicos_free(void *p)'
        '{'
        '  if (p != NULL) {'
        '    free(p);'
        '  }'
        '}'
        '']

  Code=[Code;
        '/*'+part('-',ones(1,40))+' get_scicos_time function */'
        'double get_scicos_time()'
        '{'
        '  return scicos_time;'
        '}'
        '']

  Code=[Code;
        '/*'+part('-',ones(1,40))+' do_cold_restart function */'
        'void do_cold_restart()'
        '{']

 if ALL & nX <> 0 then
   Code=[Code
          '  hot = 0;']
 end

 Code=[Code
        '  return;'
        '}'
        '']

 Code=[Code;
       '/*'+part('-',ones(1,40))+' sciprint function */'
       'void sciprint (char *fmt)'
       '{'
       '  return;'
       '}'
       '']

 Code=[Code
        '/*'+part('-',ones(1,40))+' Coserror function */']

//  Code=[Code
//         ''
//         '#ifdef __STDC__'
//         'void Coserror (char *fmt,...)'
//         '#else'
//         'void Coserror(va_alist) va_dcl'
//         '#endif'
//         '{'
//         ' int retval;'
//         ' va_list ap;']
// 
//  Code=[Code
//         ''
//         '#ifdef __STDC__'
//         ' va_start(ap,fmt);'
//         '#else'
//         ''
//         ' char *fmt;'
//         ' va_start(ap);'
//         ''
//         ' fmt = va_arg(ap, char *);'
//         '#endif']
// 
//  Code=[Code
//         ''
//         ' va_end(ap);'
//         ''
//         ' /* copy error message in error buffer message */'
//         ' strcpy(err_msg,fmt);'
//         ''
//         ' /* coserror use error number 10 */'
//         ' *block_error=-5;'
//         ''
//         ' return;'
//         '}'
//         '']

//@@ try
//  Code=[Code
//        'void Coserror (char *fmt)'
//        '{'
//        ''
//        ' /* copy error message in error buffer message */'
//        ' strcpy(err_msg,fmt);'
//        ''
//        ' /* coserror use error number 10 */'
//        ' *block_error = -5;'
//        ''
//        '  return;'
//        '}'
//        '']

//@@ old
 Code=[Code
        '#if WIN32'
        ' #ifndef vsnprintf'
        '   #define vsnprintf _vsnprintf'
        ' #endif'
        '#endif']

 Code=[Code
        ''
        '#ifdef __STDC__'
        'void Coserror (char *fmt,...)'
        '#else'
        '#ifdef __MSC__'
        'void Coserror (char *fmt,...)'
        '#else'
        'void Coserror(va_alist) va_dcl'
        '#endif'
        '#endif'
        '{'
        ' int retval;'
        ' va_list ap;']

 Code=[Code
        ''
        '#ifdef __STDC__'
        ' va_start(ap,fmt);'
        '#else'
        '#ifdef __MSC__'
        ' va_start(ap,fmt);'
        '#else'
        ''
        ' char *fmt;'
        ' va_start(ap);'
        ''
        ' fmt = va_arg(ap, char *);'
        '#endif'
        '#endif'
        '']

 Code=[Code
        '#if defined (vsnprintf) || defined (linux)'
        ' retval= vsnprintf(err_msg,4095, fmt, ap);'
        '#else'
        ' retval= vsprintf(err_msg,fmt, ap);'
        '#endif'
        ''
        ' if (retval == -1) {'
        '   err_msg[0]=''\0'';'
        ' }'
        ''
        ' va_end(ap);'
        ''
        ' /* coserror use error number 10 */'
        ' *block_error=-5;'
        ''
        ' return;'
        '}'
        '']

 Code_xml_param=['<?xml version='"1.0'" encoding='"ISO-8859-1'"?>'
                 ''
                 '<ScicosParam Name='"'+rdnom+''" version='"'+get_scicos_version()+''">'
                 '  '+Code_xml_param
                 '</ScicosParam>']
endfunction

//generates  static table definitions
//
//Author : Rachid Djenidi
//Copyright INRIA
function txt=make_static_standalone42()
  txt=['static int optind = 1;'
       'static void usage(char *);'
       ''];

endfunction

function [Code]=make_void_io()
//Copyright (c) 1989-2010 Metalau project INRIA

//@@ make_void_io : generates the C code for sensors/actuators
//                    of the ScicosLab interfacing function
//
// Output : Code : text of the generated routines
//

  //## headers
  Code=['/* Code for actuators/sensors to be used in generic interfacing functions */'
        '/*     Generated by Code_Generation toolbox of Scicos with '+ ..
        get_scicos_version()+' */'
        '/*     date : '+date()+' */'
        ''
        '/* Copyright (c) 1989-2010 Metalau project INRIA */'
        ''
        '/* ---- Headers ---- */'
        '#include <stdio.h>'
        '#include <stdlib.h>'
        '#include <string.h>'
        '#include ""stack-c.h""'
        '#include ""mex.h""'
        '#include <scicos/scicos.h>']

  //## type of in/out structure definition
  Code=[Code;
        ''
        '/* structure definition of in/out sensors/actuators */'
        'typedef struct {'
        '  int typ;      /* data type */'
        '  int ndims;    /* number of dims */'
        '  int ndata;    /* number of data */'
        '  int *dims;    /* size of data (length ndims) */'
        '  double *time; /* date of data (length ndata) */'
        '  void *data;   /* data (length ndata*prod(dims)) */'
        '} scicos_inout;'
        '']

  //## dummy Actuators
  Code=[Code
        '/*---------------------------------------- Actuators */'
        'void '+rdnom+'_dummy_actuator(flag,nport,nevprt,t,typout,outptr)'
        '     int *flag,*nevprt,*nport;'
        ''
        '     int typout;'
        '     void *outptr;'
        ''
        '     double *t;'
        '{']

  //## declaration of scicos_inout variables for output of actuators
  if size(actt,1)<>0 then
    Code=[Code
          '  /* declaration of scicos_inout variable for output of actuator */'
          '  scicos_inout *out;'
          '']
  end

  //## declaration of static counter variable for actuators (state)
  if size(actt,1)<>0 then
    Code=[Code
          '  /* static counter variable */']
    for i=1:size(actt,1)
      Code=[Code
            '  static int cnt_'+string(i)+';']
    end
  end

  //## declaration of a local counter variable
  if size(actt,1)<>0 then
    Code=[Code
          '  int cnt=0;'
          '']

    //## update the local counter variable value
    Code=[Code
          '  /* update cnt */']

    for i=1:size(actt,1)
      if i==1 then
        Code=[Code
              '  if(*nport=='+string(i)+') {'
              '    cnt=cnt_'+string(i)+';']
      else
        Code=[Code
              '  }'
              '  else if(*nport=='+string(i)+') {'
              '    cnt=cnt_'+string(i)+';']
      end
    end
    Code=[Code
          '  }'
          '']
  end
  
  //## affectation of output structure of actuators
  if size(actt,1)<>0 then
    Code=[Code
          '  /* affectation of output structure of actuators*/'
          '  out=(scicos_inout *)outptr;'
          '']
  end
  
  Code=[Code
        '  switch (*flag) {'
        ''
        '    case 4 : /* actuator initialisation */']
  if size(actt,1)<>0 then
    Code=[Code
          '      /* initialisation of counter variable */'
          '      cnt=0;']
  end
  Code=[Code
        '      break;'
        '']

//   if szclkIN==[]&ALWAYS_ACTIVE then
    Code=[Code;
          '    case 1 :']
//   else
//     Code=[Code;
//           '    case 2 :']
//   end
  
  if size(actt,1)<>0 then
    Code=[Code
          '      out->time[cnt]=*t;'
          '      /*fprintf(stderr,""actuator %d : cnt = %d\n"",*nport,cnt);*/']
  end

  
  //## increase the local counter variable value
  if size(actt,1)<>0 then
    Code=[Code
          '      /* increase counter variable */'
          '      /*fprintf(stderr,""out->ndata=%d\n"",out->ndata);*/'
          '      cnt++;'
          ''
          '      /* check and realloc out->data/out->time if needed */'
          '      if (cnt==out->ndata) {'
          '        out->ndata=2*out->ndata;']
    Code=[Code
          '        if ((out->time = (double *) realloc(out->time, \'
          '             out->ndata*sizeof(double)))==NULL) {'
          '          set_block_error(-16);'
          '          return;'
          '        }'
          '      }']
  end

  Code=[Code;
        '    case 5 : /* actuator ending */']

  if size(actt,1)<>0 then
    Code=[Code
          '      out->ndata=cnt;']
  end

  Code=[Code
        '      break;'
        '  }'
        '']

  //## update the static counter variables with the
  //## local counter variable value
  if size(actt,1)<>0 then

    Code=[Code
          '  /* update cnt */']

    for i=1:size(actt,1)
      if i==1 then
        Code=[Code
              '  if(*nport=='+string(i)+') {'
              '    cnt_'+string(i)+'=cnt;']
      else
        Code=[Code
              '  }'
              '  else if(*nport=='+string(i)+') {'
              '    cnt_'+string(i)+'=cnt;']
      end
    end
    Code=[Code
          '  }']
  end

  Code=[Code
        '}'
        '']

  //## Actuators
  Code=[Code
        '/*---------------------------------------- Actuators */'
        'void '+rdnom+'_actuator(flag,nport,nevprt,t,u,nu1,nu2,ut,typout,outptr)'
        '     int *flag,*nevprt,*nport;'
        '     int *nu1,*nu2,*ut;'
        ''
        '     int typout;'
        '     void *outptr;'
        ''
        '     double *t;'
        '     void *u;'
        '{'
        '  /*int k,l;*/']

  //## declaration of scicos_inout variables for output of actuators
  if size(actt,1)<>0 then
    Code=[Code
          '  /* declaration of scicos_inout variable for output of actuator */'
          '  scicos_inout *out;'
          '']
  end

  //## declaration of static counter variable for actuators (state)
  if size(actt,1)<>0 then
    Code=[Code
          '  /* static counter variable */']
    for i=1:size(actt,1)
      Code=[Code
            '  static int cnt_'+string(i)+';']
    end
  end

  //## declaration of a local counter variable
  if size(actt,1)<>0 then
    Code=[Code
          '  int cnt=0;'
          '']

    //## update the local counter variable value
    Code=[Code
          '  /* update cnt */']

    for i=1:size(actt,1)
      if i==1 then
        Code=[Code
              '  if(*nport=='+string(i)+') {'
              '    cnt=cnt_'+string(i)+';']
      else
        Code=[Code
              '  }'
              '  else if(*nport=='+string(i)+') {'
              '    cnt=cnt_'+string(i)+';']
      end
    end
    Code=[Code
          '  }'
          '']
  end

  //## affectation of output structure of actuators
  if size(actt,1)<>0 then
    Code=[Code
          '  /* affectation of output structure of actuators*/'
          '  out=(scicos_inout *)outptr;'
          '']
  end

  Code=[Code
        '  switch (*flag) {'
        ''
        '    case 4 : /* actuator initialisation */']
  if size(actt,1)<>0 then
    Code=[Code
          '      /* initialisation of counter variable */'
          '      cnt=0;']
  end
  Code=[Code
        '      break;'
        '']

//   if szclkIN==[]&ALWAYS_ACTIVE then
    Code=[Code;
          '    case 1 :']
//   else
//     Code=[Code;
//           '    case 2 :']
//   end

  Code=[Code
        '      switch (*ut) {'
        '      case 10 :']

  if size(actt,1)<>0 then
    Code=[Code
          '        memcpy(((double *) out->data + cnt*(*nu1)*(*nu2)), \'
          '               ((double *) u), (*nu1)*(*nu2)*sizeof(double));'
          '        /* *((double *) out->data + cnt)=*((double *) u); */'
          '        out->time[cnt]=*t;'
          '        /*fprintf(stderr,""actuator %d : cnt = %d\n"",*nport,cnt);*/']
  end

  Code=[Code
        '        break;'
        ''
        '      case 11 :']

  if size(actt,1)<>0 then
    Code=[Code
          '        memcpy(((double *) out->data + cnt*(*nu1)*(*nu2)), \'
          '               ((double *) u), (*nu1)*(*nu2)*sizeof(double));'
          '        memcpy(((double *) out->data + cnt*(*nu1)*(*nu2) + out->ndata), \'
          '               ((double *) u + (*nu1)*(*nu2)), (*nu1)*(*nu2)*sizeof(double));'
          '        out->time[cnt]=*t;']
  end

  Code=[Code
        '        break;'
        ''
        '      case 81 :'
        '        break;'
        ''
        '      case 82 :'
        '        break;'
        ''
        '      case 84 :'
        '        break;'
        ''
        '      case 811 :'
        '        break;'
        ''
        '      case 812 :'
        '        break;'
        ''
        '      case 814 :'
        '        break;'
        '      }'
        '']
  //## increase the local counter variable value
  if size(actt,1)<>0 then
    Code=[Code
          '      /* increase counter variable */'
          '      /*fprintf(stderr,""out->ndata=%d\n"",out->ndata);*/'
          '      cnt++;'
          ''
          '      /* check and realloc out->data/out->time if needed */'
          '      if (cnt==out->ndata) {'
          '        out->ndata=2*out->ndata;']

    Code=[Code
          '        if ((*ut)==11) {'
          '          if ((out->data = (double *) realloc(out->data, \'
          '               out->ndata*(*nu1)*(*nu2)*2*sizeof(double)))==NULL) {'
          '            set_block_error(-16);'
          '            return;'
          '          }'
          '          memcpy(((double *) out->data + (out->ndata/2)*(*nu1)*(*nu2)), \'
          '                 ((double *) out->data + out->ndata*(*nu1)*(*nu2)), \'
          '                  (out->ndata/2)*(*nu1)*(*nu2)*sizeof(double));'
          '        }'
          '        else {'
          '          if ((out->data = (double *) realloc(out->data, \'
          '               out->ndata*(*nu1)*(*nu2)*sizeof(double)))==NULL) {'
          '            set_block_error(-16);'
          '            return;'
          '          }'
          '        }']

    Code=[Code
          '        if ((out->time = (double *) realloc(out->time, \'
          '             out->ndata*sizeof(double)))==NULL) {'
          '          set_block_error(-16);'
          '          return;'
          '        }'
          '      }']
  end
  Code=[Code
        '      break;'
        ''
        '    case 5 : /* actuator ending */']

  if size(actt,1)<>0 then
    Code=[Code
          '      switch (*ut) {'
          '        case 11 :'
          '          memcpy(((double *) out->data + (cnt)*(*nu1)*(*nu2)), \'
          '                 ((double *) out->data + out->ndata*(*nu1)*(*nu2)), \'
          '                  (cnt)*(*nu1)*(*nu2)*sizeof(double));'
          '      }'
          '      out->ndata=cnt;']
  end

  Code=[Code
        '      break;'
        '  }'
        '']

  //## update the static counter variables with the
  //## local counter variable value
  if size(actt,1)<>0 then

    Code=[Code
          '  /* update cnt */']

    for i=1:size(actt,1)
      if i==1 then
        Code=[Code
              '  if(*nport=='+string(i)+') {'
              '    cnt_'+string(i)+'=cnt;']
      else
        Code=[Code
              '  }'
              '  else if(*nport=='+string(i)+') {'
              '    cnt_'+string(i)+'=cnt;']
      end
    end
    Code=[Code
          '  }']
  end

  Code=[Code
        '}'
        '']

  //## Sensors
  Code=[Code
        '/*---------------------------------------- Sensors */'
        'void '+rdnom+'_sensor(flag,nport,nevprt,t,y,ny1,ny2,yt,typin,inptr)'
        '     int *flag,*nevprt,*nport;'
        '     int *ny1,*ny2,*yt;'
        ''
        '     int typin;'
        '     void *inptr;'
        ''
        '     double *t;'
        '     void *y;'
        '{'
        '  /*int k,l;*/']

  //## declaration of scicos_inout variables for input of sensors
  if size(capt,1)<>0 then
    Code=[Code
          '  /* declaration of scicos_inout variable for input of sensors */'
          '  scicos_inout *in;'
          '']
  end

  //## declaration of static counter variable for actuators (state)
  if size(capt,1)<>0 then
    Code=[Code
          '  /* static counter variable */']
    for i=1:size(capt,1)
      Code=[Code
            '  static int cnt_'+string(i)+';']
    end
  end

  //## declaration of a local counter variable
  if size(capt,1)<>0 then
    Code=[Code
          '  int cnt=0;'
          '']

    Code=[Code
          '  /* */'
          '  if (get_phase_simulation()!=1) {'
          '    return;'
          '  }';
          '']

    Code=[Code
          '  /* update cnt */']

    for i=1:size(capt,1)
      if i==1 then
        Code=[Code
              '  if(*nport=='+string(i)+') {'
              '    cnt=cnt_'+string(i)+';']
      else
        Code=[Code
              '  }'
              '  else if(*nport=='+string(i)+') {'
              '    cnt=cnt_'+string(i)+';']
      end
    end
    Code=[Code
          '  }']
  end

  //## affectation of input structure for sensors
  if size(capt,1)<>0 then
    Code=[Code
          '  /* affectation of intput structure of sensors */'
          '  in=(scicos_inout *)inptr;'
          '']
  end

  Code=[Code
        '  switch (*flag) {'
        ''
        '    case 4 : /* sensor initialisation */']
  if size(capt,1)<>0 then
    Code=[Code
          '      /* initialisation of counter variable */'
          '      cnt=0;']
  end
  Code=[Code
        '      break;'
        ''
        '    case 1 :'
        '      switch (*yt) {'
        '      case 10 :']

  if size(capt,1)<>0 then
    Code=[Code
          '        memcpy((double *) y, \'
          '              ((double *) in->data + cnt*(*ny1)*(*ny2)), \'
          '              (*ny1)*(*ny2)*sizeof(double));'
          '        /* *((double *)y)=*((double *)in->data + cnt); */'
          '        /*fprintf(stderr,""sensor %d : cnt = %d\n"",*nport,cnt);*/']
  end

  Code=[Code
        '        break;'
        ''
        '      case 11 :']

  if size(capt,1)<>0 then
    Code=[Code
          '        memcpy((double *) y, \'
          '              ((double *) in->data + cnt*(*ny1)*(*ny2)), \'
          '              (*ny1)*(*ny2)*sizeof(double));'
          '        memcpy((double *) y+(*ny1)*(*ny2), \'
          '              ((double *) in->data + cnt*(*ny1)*(*ny2)) + (*ny1)*(*ny2)*in->ndata, \'
          '              (*ny1)*(*ny2)*sizeof(double));']
  end

  Code=[Code
        '        break;'
        ''
        '      case 81 :'
        '        break;'
        ''
        '      case 82 :'
        '        break;'
        ''
        '      case 84 :'
        '        break;'
        ''
        '      case 811 :'
        '        break;'
        ''
        '      case 812 :'
        '        break;'
        ''
        '      case 814 :'
        '        break;'
        '      }'
        '']
  //## increase the local counter variable value
  if size(capt,1)<>0 then
    Code=[Code
          '      /* increase counter variables */'
          '      cnt++;'
          ''
          '      /* check value of cnt */'
          '      if (cnt==in->ndata) {'
          '        cnt--;'
          '      }']
  end
  Code=[Code
        '      break;'
        ''
        '    case 5 : /* sensor ending */'
        '      break;'
        '  }'
        '']

  //## update the static counter variables with the
  //## local counter variable value
  if size(capt,1)<>0 then

    Code=[Code
          '  /* update cnt */']

    //## update the local counter variable value
    for i=1:size(capt,1)
      if i==1 then
        Code=[Code
              '  if(*nport=='+string(i)+') {'
              '    cnt_'+string(i)+'=cnt;']
      else
        Code=[Code
              '  }'
              '  else if(*nport=='+string(i)+') {'
              '    cnt_'+string(i)+'=cnt;']
      end
    end
    Code=[Code
          '  }']
  end

  Code=[Code
        '}']

endfunction

function [txt]=protoblk(model,ind)
//Copyright (c) 1989-2010 Metalau project INRIA

//protoblk : generate prototype for a calling C sequence
//           of a scicos computational function from
//           a scilab model of blk.
//
// Input : model : the scilab model of a scicos blk
//        ind    : and index number
//
// Output : txt  : the generated prototype
//

  nin=size(model.in(:),1);   //* number of input ports */
  nout=size(model.out(:),1); //* number of output ports */
  if (type(model.sim)==15) then //* type and name of the computational function */
    funs_bk=model.sim(1);
    funtyp_bk=model.sim(2);
  else
    funs_bk=model.sim;
    funtyp_bk=0;
  end
  if (type(funs_bk)<>10) then
    error('ScicosLab simulation function not allowed.');
  end
  ztyp_bk=(model.nzcross<>0); //* zero crossing type */

  //&& call make_BlockProt
  [txt]=make_BlockProto(nin,nout,funs_bk,funtyp_bk,ztyp_bk,ind);

endfunction

function [ccmat]=adj_clkconnect_dep(blklst,ccmat)
//Copyright (c) 1989-2010 Metalau project INRIA

//this part was taken from c_pass2 and put in c_pass1;!!
nbl=size(blklst)
fff=ones(nbl,1)==1
clkptr=zeros(nbl+1,1);clkptr(1)=1; typ_l=fff;typ_t=fff;
for i=1:nbl
  ll=blklst(i);
  clkptr(i+1)=clkptr(i)+size(ll.evtout,'*');
  //tblock(i)=ll.dep_ut($);
  typ_l(i)=ll.blocktype=='l';
  typ_t(i)=ll.dep_ut($)
end
all_out=[]
for k=1:size(clkptr,1)-1
  if ~typ_l(k) then
    kk=[1:(clkptr(k+1)-clkptr(k))]'
    all_out=[all_out;[k*ones(kk),kk]]
  end
end
all_out=[all_out;[0,0]]
ind=find(typ_t==%t)
ind=ind(:);
for k=ind'
  ccmat=[ccmat;[all_out,ones(all_out)*[k,0;0,0]]]
end
endfunction


function [new_agenda]=adjust_agenda(evts,clkptr,funtyp)
//Copyright (c) 1989-2010 Metalau project INRIA
//
//@@ adjust_agenda : remove secondary activation sources
//                   from the scicos cpr agenda
//
// Input : evts   :   evts vector of scicos agenda
//         clkptr : compiled clkptr vector
//         funtyp : compiled funtyp vector
//
// Output : new_agenda : new evts vector without
//                       secondary activation sources
//

  //@@ initial var
  k=1
  new_agenda=[]

  //@@ loop on number of computational functions
  for i=1:size(clkptr,1)
    if i<>size(clkptr,1)
      j = clkptr(i+1) - clkptr(i)
      if j<>0 then
        //@@ check type of activation source
        if funtyp(i)<>-1 & funtyp(i)<>-2 then
          new_agenda = [new_agenda;evts(k:k+j-1)]
        end
        k=k+j
      end
    end
  end

endfunction

function [clkptr]=adjust_clkptr(clkptr,funtyp)
//Copyright (c) 1989-2010 Metalau project INRIA
//
//@@ adjust_clkptr : remove secondary activation sources
//                   from the compiled clkptr
//
// Input :  clkptr : compiled clkptr vector
//          funtyp : compiled funtyp vector
//
// Output : clkptr : new clkptr vector without
//                   secondary activation sources
//

  //@@ initial var
  j=0

  //@@ loop on number of computational functions
  for i=1:size(clkptr,1)
    clkptr(i)=clkptr(i)-j
    if i<>size(clkptr,1)
      //@@ check type of activation source
      if funtyp(i)==-1 | funtyp(i)==-2 then
        j = clkptr(i+1) - clkptr(i)
      end
    end
  end

endfunction

function [bllst,ok]=adjust_id_scopes(list_of_scopes,bllst)
//Copyright (c) 1989-2010 Metalau project INRIA
//
//@@ adjust_adjust_id_scopes : function to adjust negative
//                             and positive id of scicos scopes
//
// Input :  list_of_scopes : list of scicos scopes
//          bllst : list of models of scicos blocks
//
// Output : bllst : output bllst with adjusted models for scopes
//          ok    : output flag
//

  //@@ initial var
  ok=%t
  pos_win=[]
  pos_i=[]
  pos_ind=[]

  //@@ loop on number of scicos models
  for i=1:lstsize(bllst)
    ind = find(bllst(i).sim(1)==list_of_scopes(:,1))
    if ind<>[] then
      ierr=execstr('win=bllst(i).'+list_of_scopes(ind,2),'errcatch');
      if ierr<>0 then
        ok=%f, return;
      end
      if win<0 then
        win = 30000 + i
        execstr('bllst(i).'+list_of_scopes(ind,2)+'='+string(win))
      else
        pos_win=[pos_win;win]
        pos_i=[pos_i;i]
        pos_ind=[pos_ind;ind]
      end
    end
  end

  if pos_win<>[] & size(pos_win,1)<>1 then
    ko=%t;
    while ko
      for j=1:size(pos_win,1)
        if find(pos_win(j)==pos_win(j+1:$))<>[] then
          pos_win(j)=pos_win(j)+1
          ko=%t
          break
        end
        ko=%f
      end
    end
    for i=1:size(pos_ind,1)
      execstr('bllst(pos_i(i)).'+list_of_scopes(pos_ind(i),2)+'='+string(pos_win(i)))
    end
  end

endfunction
// remove synchro block from clkptr
function new_pointi=adjust_pointi(pointi,clkptr,funtyp)
j=0
new_pointi=pointi
for i=1:size(clkptr,1)
  if clkptr(i)>pointi then break, end;
  if i<>size(clkptr,1)
    if funtyp(i)==-1 | funtyp(i)==-2 then
       j = clkptr(i+1) - clkptr(i)
       new_pointi=new_pointi-j
    end
  end
end
endfunction

function [nbact,act,actt,cpr]=blocks_to_actuators(list_of_blk,nbact,act,actt,cpr)
//Copyright (c) 1989-2010 Metalau project INRIA
//
//@@ blocks_to_actuators : change blocks simulation function by actuators
//                         in a compiled scicos structure
//
// list_of_blk : vector of strings of computational function name
//               to replace by actuator
// nbact : number of actuators
// act   : vector of index of actuators
// actt  : informations matrix of actuators
// cpr   : compiled scicos structure
//

  //@@loop on number of blocks
  for kf=1:lstsize(cpr.sim.funs)
    if find(list_of_blk==cpr.sim.funs(kf))<>[] then
      //## number of input ports
      nin   = cpr.sim.inpptr(kf+1)-cpr.sim.inpptr(kf);
      if nin==0 then
          nbact = nbact+1;
          act   = [act;kf]

          uk    = 0
          nuk_1 = 0
          nuk_2 = 0
          uk_t  = 0;
          actt  = [actt;
                     kf uk nuk_1 nuk_2 uk_t 999]

          cpr.sim.funs(kf)='actionneur_dummy'+string(nbact)
      else
        //@@ update actuators
        for j=1:nin
          nbact = nbact+1;
          act   = [act;kf]

          uk    = cpr.sim.inplnk(cpr.sim.inpptr(kf)+j-1);
          nuk_1 = size(cpr.state.outtb(uk),1);
          nuk_2 = size(cpr.state.outtb(uk),2);
          uk_t  = mat2scs_c_nb(cpr.state.outtb(uk));
          actt  = [actt;
                     kf uk nuk_1 nuk_2 uk_t 999]
          if j==1 then
            cpr.sim.funs(kf)='actionneur'+string(nbact)
          end
        end
      end
    end
  end

endfunction

//@@ blocks_to_sensors
//@@ change blocks simulation function by sensors
//@@ in a compiled scicos structure
//@@
function [nbcap,cap,capt,cpr]=blocks_to_sensors(list_of_blk,nbcap,cap,capt,cpr)
//Copyright (c) 1989-2010 Metalau project INRIA
//
//@@ blocks_to_sensors : change blocks simulation function by sensors
//                       in a compiled scicos structure
//
// list_of_blk : vector of strings of computational function name
//               to replace by sensors
// nbcap : number of sensors
// cap   : vector of index of sensors
// capt  : informations matrix of sensors
// cpr   : compiled scicos structure
//

  //@@loop on number of blocks
  for kf=1:lstsize(cpr.sim.funs)
    if find(list_of_blk==cpr.sim.funs(kf))<>[] then
      //## number of output ports
      nout   = cpr.sim.outptr(kf+1)-cpr.sim.outptr(kf);
      //@@ update sensors
      for j=1:nout
        nbcap = nbcap+1;
        cap   = [cap;kf]

        yk    = cpr.sim.outlnk(cpr.sim.outptr(kf)+j-1);
        nyk_1 = size(cpr.state.outtb(yk),1);
        nyk_2 = size(cpr.state.outtb(yk),2);
        yk_t  = mat2scs_c_nb(cpr.state.outtb(yk));
        capt  = [capt;
                 kf yk nyk_1 nyk_2 yk_t 999]
        if j==1 then
          cpr.sim.funs(kf)='capteur'+string(nbcap)
        end
      end
    end
  end

endfunction

function [t1]=cformatline(t ,l)
//Copyright (c) 1989-2010 Metalau project INRIA
//
//@@ cformatline : utilitary fonction used to format long C instruction
//
// Input : t  : a string containing a C instruction
//         l  : max line length allowed
//
// Output : t1 : formatted output text
//

  sep=[',','+']
  l1=l-2
  t1=[]
  kw=strindex(t,' ')
  nw=0

  if kw<>[] then
    if kw(1)==1 then //there is leading blanks
      k1=find(kw(2:$)-kw(1:$-1)<>1)
      if k1==[] then //there is a single blank
        nw=1
      else
        nw=kw(k1(1))
      end
    end
  end

  t=part(t,nw+1:length(t))
  bl=part(' ',ones(1,nw))
  l1=l-nw
  first=%t

  while %t
    if length(t)<=l then
      t1=[t1;bl+t]
      return
    end

    k=strindex(t,sep)
    if k==[] then t1=[t1;bl+t]
      return
    end

    k($+1)=length(t)+1 //positions of the commas
    i=find(k(1:$-1)<=l&k(2:$)>l) //nearest left comma (reltively to l)

    if i==[] then i=1,end

    t1=[t1;bl+part(t,1:k(i))]
    t=part(t,k(i)+1:length(t))

    if first then
       l1=l1-2;bl=bl+'  '
       first=%f
    end
  end

endfunction

function [vec]=codebinaire(v,szclkIN)
//Copyright (c) 1989-2010 Metalau project INRIA
//
//@@ codebinaire : utilitary fonction used in do_compile_superblock
//

  vec=zeros(1,szclkIN)

  for i=1:szclkIN
    w=v/2;
    vec(i)=v-2*int(w);
    v=int(w);
  end

endfunction

function [txt]=code_to_read_params(varname,var,fpp,typ_str)
//Copyright (c) 1989-2010 Metalau project INRIA
//
//@@ code_to_read_params :  function that write binary data in a scilab file
//                          descriptor fpp and returns the C code to read
//                          binary data from the file descriptor fpp
//                          To have a test concerning reading use the wrapper
//                          get_code_to_read_params
//
// Input :  varname : the C ptr (buffer)
//          var     : the ScicosLab variable
//          fpp     : the ScicosLab file descriptor to write the var
//          typ_str : the C type of the data
//
// Output : txt : the C cmd to read binary data in the file descriptor fpp
//
// nb : data is written in little-endian format
//

 //** check rhs paramaters
 [lhs,rhs]=argn(0);
 if rhs == 3 then typ_str=[], end

 txt=[]

 select type(var)
   //real matrix
   case 1 then
      if isreal(var) then
        mput(var,"dl",fpp)
        if typ_str==[] then typ_str='SCSREAL_COP', end
        txt='fread('+varname+', sizeof('+typ_str+'), '+string(size(var,'*'))+', fpp)'
      else
        mput(real(var),"dl",fpp)
        mput(imag(var),"dl",fpp)
        if typ_str==[] then typ_str='SCSCOMPLEX_COP', end
        txt='fread('+varname+', 2*sizeof('+typ_str+'), '+string(size(var,'*'))+', fpp)'
      end
   //integer matrix
   case 8 then
      select typeof(var)
         case 'int32' then
           mput(var,"ll",fpp)
           if typ_str==[] then typ_str='SCSINT32_COP', end
           txt='fread('+varname+', sizeof('+typ_str+'), '+string(size(var,'*'))+', fpp)'
         case 'int16' then
           mput(var,"sl",fpp)
           if typ_str==[] then typ_str='SCSINT16_COP', end
           txt='fread('+varname+', sizeof('+typ_str+'), '+string(size(var,'*'))+', fpp)'
         case 'int8' then
           mput(var,"cl",fpp)
           if typ_str==[] then typ_str='SCSINT8_COP', end
           txt='fread('+varname+', sizeof('+typ_str+'), '+string(size(var,'*'))+', fpp)'
         case 'uint32' then
           mput(var,"ull",fpp)
           if typ_str==[] then typ_str='SCSUINT32_COP', end
           txt='fread('+varname+', sizeof('+typ_str+'), '+string(size(var,'*'))+', fpp)'
         case 'uint16' then
           mput(var,"usl",fpp)
           if typ_str==[] then typ_str='SCSUINT16_COP', end
           txt='fread('+varname+', sizeof('+typ_str+'), '+string(size(var,'*'))+', fpp)'
         case 'uint8' then
           mput(var,"ucl",fpp)
           if typ_str==[] then typ_str='SCSUINT8_COP', end
           txt='fread('+varname+', sizeof('+typ_str+'), '+string(size(var,'*'))+', fpp)'
      end
   else
     break;
 end

endfunction

function [txt]=code_to_write_params(varname,var,fpp,typ_str)
//Copyright (c) 1989-2010 Metalau project INRIA
//
//@@ code_to_write_params : function that write binary data in a scilab file
//                         descriptor fpp and returns the C code to write
//                         binary data from the file descriptor fpp
//
// Input :  varname : the C ptr (buffer)
//          var     : the ScicosLab variable
//          fpp     : the ScicosLab file descriptor to write the var
//          typ_str : the C type of the data
//
// Output : txt : the C cmd to write binary data in the file descriptor fpp
//
// nb : data is written in little-endian format
//

 //** check rhs paramaters
 [lhs,rhs]=argn(0);
 if rhs == 3 then typ_str=[], end

 txt=[]

 select type(var)
   //real matrix
   case 1 then
      if isreal(var) then
        mput(var,"dl",fpp)
        if typ_str==[] then typ_str='SCSREAL_COP', end
        txt='fwrite('+varname+', sizeof('+typ_str+'), '+string(size(var,'*'))+', fpp)'
      else
        mput(real(var),"dl",fpp)
        mput(imag(var),"dl",fpp)
        if typ_str==[] then typ_str='SCSCOMPLEX_COP', end
        txt='fwrite('+varname+', 2*sizeof('+typ_str+'), '+string(size(var,'*'))+', fpp)'
      end
   //integer matrix
   case 8 then
      select typeof(var)
         case 'int32' then
           mput(var,"ll",fpp)
           if typ_str==[] then typ_str='SCSINT32_COP', end
           txt='fwrite('+varname+', sizeof('+typ_str+'), '+string(size(var,'*'))+', fpp)'
         case 'int16' then
           mput(var,"sl",fpp)
           if typ_str==[] then typ_str='SCSINT16_COP', end
           txt='fwrite('+varname+', sizeof('+typ_str+'), '+string(size(var,'*'))+', fpp)'
         case 'int8' then
           mput(var,"cl",fpp)
           if typ_str==[] then typ_str='SCSINT8_COP', end
           txt='fwrite('+varname+', sizeof('+typ_str+'), '+string(size(var,'*'))+', fpp)'
         case 'uint32' then
           mput(var,"ull",fpp)
           if typ_str==[] then typ_str='SCSUINT32_COP', end
           txt='fwrite('+varname+', sizeof('+typ_str+'), '+string(size(var,'*'))+', fpp)'
         case 'uint16' then
           mput(var,"usl",fpp)
           if typ_str==[] then typ_str='SCSUINT16_COP', end
           txt='fwrite('+varname+', sizeof('+typ_str+'), '+string(size(var,'*'))+', fpp)'
         case 'uint8' then
           mput(var,"ucl",fpp)
           if typ_str==[] then typ_str='SCSUINT8_COP', end
           txt='fwrite('+varname+', sizeof('+typ_str+'), '+string(size(var,'*'))+', fpp)'
      end
   else
     break;
 end

endfunction

function [scs_m]=draw_sampleclock(scs_m,XX,k,flgcdgen,szclkINTemp,freof)
//Copyright (c) 1989-2010 Metalau project INRIA
//
//@@ draw_sampleclock : draw a sample clock above the new generated
//                      scicos block
//

  if flgcdgen <> szclkINTemp then
    // XX.graphics.pein($)=size(scs_m.objs)+2
    XX.graphics.pein = [XX.graphics.pein ; size(scs_m.objs)+2]
    scs_m.objs(k) = XX
    bk = SampleCLK('define');
    [posx,posy] = getinputports(XX)
    posx = posx($); posy = posy($);
    teta = XX.graphics.theta
    pos  = rotate([posx;posy],teta*%pi/180, ...
                  [XX.graphics.orig(1)+XX.graphics.sz(1)/2,...
                   XX.graphics.orig(2)+XX.graphics.sz(2)/2]) ; 
    posx = pos(1); posy = pos(2);
    bk.graphics.orig = [posx posy]+[-30 20]
    bk.graphics.sz = [60 40]
    bk.graphics.exprs = [sci2exp(freof(1));sci2exp(freof(2))]
    bk.model.rpar = freof;
    bk.graphics.peout = size(scs_m.objs)+2
    scs_m.objs($+1) = bk;
    [posx2,posy2] = getoutputports(bk);
    lnk    = scicos_link();
    lnk.xx = [posx2;posx];
    lnk.yy = [posy2;posy];
    lnk.ct = [5 -1]
    lnk.from = [size(scs_m.objs) 1 0]
    lnk.to = [k flgcdgen 1]
    scs_m.objs($+1) = lnk;
  end

endfunction

function [t]=filetype(m)
//Copyright (c) 1989-2010 Metalau project INRIA
//
//@@ filetype : return type of file using fileinfo
//              output 2
//
// Input :  m : fileinfo(2)
//
// Output : t : file types
//

  m=int32(m)

  filetypes=['Directory','Character device','Block device',...
             'Regular file','FIFO','Symbolic link','Socket']

  bits=[16384,8192,24576,32768,4096,40960,49152]

  m=int32(m)&int32(61440)

  t=filetypes(find(m==int32(bits)))

endfunction

function [txt]=get_blank(str)
//Copyright (c) 1989-2010 Metalau project INRIA
//
//@@ get_blank : return blanks with a length
//               of the given input string
//
// Input : str : a string
//
// Output : txt : blanks
//

 txt=''

 for i=1:length(str)
     txt=txt+' '
 end

endfunction

function [txt]=get_code_to_read_params(varname,var,fpp,typ_str)
//Copyright (c) 1989-2010 Metalau project INRIA
//
//@@ get_code_to_read_params : function that write binary data in a scilab file
//                             descriptor fpp and returns the C code to read
//                             binary data from the file descriptor fpp
//
// Input :  varname : the C ptr (buffer)
//          var     : the ScicosLab variable
//          fpp     : the ScicosLab file descriptor to write the var
//          typ_str : the C type of the data
//
// Output : txt : the C cmd to read binary data in the file descriptor fpp
//
// nb : data is written in little-endian format
//

 //** check rhs paramaters
 [lhs,rhs]=argn(0);
 if rhs == 3 then typ_str=[], end

 //@@ call code_to_read_params
 txt=[]
 txt=code_to_read_params(varname,var,fpp,typ_str)

 //@@ add a C check
 if txt<>[] then
  txt=['if (('+txt+') != '+string(size(var,'*'))+') {'
       '  fclose(fpp);'
       '  return(1001);'
       '}']
 end

endfunction

function [txt]=get_comment(typ,param)
//Copyright (c) 1989-2010 Metalau project INRIA
//
//@@ get_comment : return a C comment
//                 for generated code
//
// Input : typ : a string
//         param : a list
//
// Output : txt : a C comment
//

  txt = [];

  select typ
    //** main flag
    case 'flag' then
        select param(1)
          case 0 then
             txt = '/* Continuous state computation */'
          case 1 then
             txt = '/* Output computation */'
          case 2 then
             txt = '/* Discrete state computation */'
          case 3 then
             txt = '/* Output Event computation */'
          case 4 then
             txt = '/* Initialization */'
          case 5 then
             txt = '/* Ending */'
          case 9 then
             txt = '/* Update zero crossing surfaces */'
        end
    //** blocks activated on event number
    case 'ev' then
       txt = '/* Blocks activated on the event number '+string(param(1))+' */'

    //** blk calling sequence
    case 'call_blk' then
        txt = ['/* Call of '''+param(1) + ...
               ''' (type '+string(param(2))+' - blk nb '+...
                    string(param(3))];
        if param(4) then
          txt=txt+' - with zcross) */';
        else
          txt=txt+') */';
        end
    //** proto calling sequence
    case 'proto_blk' then
        txt = ['/* prototype of '''+param(1) + ...
               ''' (type '+string(param(2))];
        if param(4) then
          txt=txt+' - with zcross) */';
        else
          txt=txt+') */';
        end
    //** ifthenelse calling sequence
    case 'ifthenelse_blk' then
        txt = ['/* Call of ''if-then-else'' blk (blk nb '+...
                    string(param(1))+') */']
    //** eventselect calling sequence
    case 'evtselect_blk' then
        txt = ['/* Call of ''event-select'' blk (blk nb '+...
                    string(param(1))+') */']
    //** set block structure
    case 'set_blk' then
        txt = ['/* set blk struc. of '''+param(1) + ...
               ''' (type '+string(param(2))+' - blk nb '+...
                    string(param(3))+') */'];
    //** Update xd vector ptr
    case 'update_xd' then
        txt = ['/* Update xd vector ptr */'];
    //** Update g vector ptr
    case 'update_g' then
        txt = ['/* Update g vector ptr */'];
    //@@ Prototype sensor
    case 'proto_sensor' then
        txt = ['/* prototype of ''sensor'' */'];
    //@@ Prototype actuator
    case 'proto_actuator' then
        txt = ['/* prototype of ''actuator'' */'];
    //@@ update scicos_time variable
    case 'update scicos_time' then
        txt = ['/* update scicos_time variable */'];
    else
      break;
  end
endfunction

function [ind]=get_ind_clkptr(bk,clkptr,funtyp)
//Copyright (c) 1989-2010 Metalau project INRIA
//
//@@ get_ind_clkptr : get event index of adjusted
//                    compiled clkptr vector
//
// Input :  bk     : block number
//          clkptr : compiled clkptr vector
//          funtyp : compiled funtyp vector
//
// Output : ind : indices of adjusted event
//

  //@@ call adjust_clkptr
  clkptr=adjust_clkptr(clkptr,funtyp)

  //@@ return indices
  ind=clkptr(bk)

endfunction


function [txt]=get_xml_param_code(name,var)
//Copyright (c) 1989-2010 Metalau project INRIA
//
//@@ get_xml_param_code : function that returns the size and dims
//                        of a scicos variable in xml format

  txt='<ScicosVar name='"'+name+''" dim1='"'+string(size(var,1))+''" dim2='"'+...
      string(size(var,2))+''" typ='"'+string(mat2scs_c_nb(var))+''"/>'
endfunction

function [scs_m]=goto_target_scs_m(scs_m)
//Copyright (c) 1989-2010 Metalau project INRIA
//
//@@ goto_target_scs_m : look if we want generate a sblock
//                       contained in a sblock
//
// scs_m : a scicos diagram structure
//

  //@@ get the super path
  kk=super_path

  //## scs_temp becomes the scs_m of the upper-level sblock
  if size(kk,'*')>1 then
    while size(kk,'*')>1 do
      scs_m=scs_m.objs(kk(1)).model.rpar
      kk(1)=[];
    end
    scs_m=scs_m.objs(kk).model.rpar
  elseif size(kk,'*')>0 then
    scs_m=scs_m.objs(kk).model.rpar
  end

endfunction

function [depu_mat,ok]=incidence_mat(bllst,connectmat,clkconnect,cor,corinv)
//Copyright (c) 1989-2010 Metalau project INRIA
//
//@@ incidence_mat : compute the incidence matrix
//
// Input :  bllst      : list of scicos blocks models
//          connectmat : regular link connection matrix
//          clkconnect : event link connection matrix
//          cor        : scs_m to cpr list
//          corinv     : cpr to scs_m list
//
// Output : depu_mat   : incidence matrix
//          ok         : output flag
//

  //@@ initial variables
  ok         = %t
  In_blocks  = []
  OUt_blocks = []
  depu_mat   = []

  //@@ get vector of blocks sensor/actuators
  for i=1:lstsize(bllst)
    sim=bllst(i).sim;sim=sim(1);
    if type(sim)==10 then
      if part(sim,1:10)=='actionneur' then
        OUt_blocks(bllst(i).ipar)=i
      elseif part(sim,1:7)=='capteur' then
        In_blocks(bllst(i).ipar)=i
      end
    end
  end

  //@@ disable function protection
  //   to overload message function
  %mprt=funcprot()
  funcprot(0) 
  deff('message(txt)',' ')
  funcprot(%mprt)

  in = 0

  for i=In_blocks'
    in  = in+1
    out = 0
    for j=OUt_blocks'
      out = out+1
      if is_dep(i,j,bllst,connectmat,clkconnect,cor,corinv) then
        depu_mat(in,out)=1
      else
        depu_mat(in,out)=0
      end
    end
  end

endfunction

function [dep]=is_dep(i,j,bllst,connectmat,clkconnect,cor,corinv)
//Copyright (c) 1989-2010 Metalau project INRIA
//
//@@ is_dep : return the dep_u dependance concerning block i and j
//
// Input :  i,j        : block indices
//          bllst      : list of scicos blocks models
//          connectmat : regular link connection matrix
//          clkconnect : event link connection matrix
//          cor        : scs_m to cpr list
//          corinv     : cpr to scs_m list
//
// Output : dep        : the dep_u dependance
//

  bllst(i).dep_ut=[%t,%t]
  bllst(i).in=1;
  bllst(i).in2=1;
  bllst(i).intyp=1

  bllst(j).dep_ut=[%t,%t]
  bllst(j).out=1;
  bllst(j).out2=1;
  bllst(j).outtyp=1

  connectmat=[connectmat;j 1 i 1];
  clkconnect=adj_clkconnect_dep(bllst,clkconnect)
  cpr=c_pass2(bllst,connectmat,clkconnect,cor,corinv,"silent")

  dep=(cpr==list())

endfunction

function [txt]=mat2c_typ(outtb)
//Copyright (c) 1989-2010 Metalau project INRIA
//
//@@ mat2c_typ : returns the C type of a given ScicosLab
//               variable
//
// Input :  outtb : a ScicosLab variable
//
// Output : txt : string that give the C type
//

 select type(outtb)
   //real matrix
   case 1 then
      if isreal(outtb) then
        txt = "double"
      else
        txt = "double"
      end
   //integer matrix
   case 8 then
      select typeof(outtb)
         case 'int32' then
           txt = "long"
         case 'int16' then
           txt = "short"
         case 'int8' then
           txt = "char"
         case 'uint32' then
           txt = "unsigned long"
         case 'uint16' then
           txt = "unsigned short"
         case 'uint8' then
           txt = "unsigned char"
      end
   else
     break;
 end

endfunction

function [c_nb]=mat2scs_c_nb(outtb)
//Copyright (c) 1989-2010 Metalau project INRIA
//
//@@ mat2scs_c_nb : returns the scicos C type of a
//                  given ScicosLab variable
//
// Input :  outtb : a ScicosLab variable
//
// Output : c_nb : scalar that give the scicos C type
//

 select type(outtb)
   //real matrix
   case 1 then
      if isreal(outtb) then
        c_nb = 10
      else
        c_nb = 11
      end
   //integer matrix
   case 8 then
      select typeof(outtb)
         case 'int32' then
           c_nb = 84
         case 'int16' then
           c_nb = 82
         case 'int8' then
           c_nb = 81
         case 'uint32' then
           c_nb = 814
         case 'uint16' then
           c_nb = 812
         case 'uint8' then
           c_nb = 811
      end
   else
     break;
 end

endfunction

function [txt]=mat2scs_c_ptr(outtb)
//Copyright (c) 1989-2010 Metalau project INRIA
//
//@@ mat2scs_c_ptr : returns the scicos C ptr of a
//                  given ScicosLab variable
//
// Input : outtb : a ScicosLab variable
//
// Output : txt  : string of the C scicos ptr
//                 of the data of outtb
//

 select type(outtb)
   //real matrix
   case 1 then
      if isreal(outtb) then
        txt = "SCSREAL_COP"
      else
        txt = "SCSCOMPLEX_COP"
      end
   //integer matrix
   case 8 then
      select typeof(outtb)
         case 'int32' then
           txt = "SCSINT32_COP"
         case 'int16' then
           txt = "SCSINT16_COP"
         case 'int8' then
           txt = "SCSINT8_COP"
         case 'uint32' then
           txt = "SCSUINT32_COP"
         case 'uint16' then
           txt = "SCSUINT16_COP"
         case 'uint8' then
           txt = "SCSUINT8_COP"
      end
   else
     break;
 end

endfunction

function [txt]=mat2scs_c_typ(outtb)
//Copyright (c) 1989-2010 Metalau project INRIA
//
//@@ mat2scs_c_typ matrix to scicos C type
//
// Input : outtb : a ScicosLab variable
//
// Output : txt  : string of the C scicos typ
//                 of the data of outtb
//

 select type(outtb)
   //real matrix
   case 1 then
      if isreal(outtb) then
        txt = "SCSREAL_N"
      else
        txt = "SCSCOMPLEX_N"
      end
   //integer matrix
   case 8 then
      select typeof(outtb)
         case 'int32' then
           txt = "SCSINT32_N"
         case 'int16' then
           txt = "SCSINT16_N"
         case 'int8' then
           txt = "SCSINT8_N"
         case 'uint32' then
           txt = "SCSUINT32_N"
         case 'uint16' then
           txt = "SCSUINT16_N"
         case 'uint8' then
           txt = "SCSUINT8_N"
      end
   else
     break;
 end

endfunction

function [txt]=scs_c_n2c_fmt(c_nb)
//Copyright (c) 1989-2010 Metalau project INRIA
//
//@@ scs_c_n2c_fmt : scicos C number to C format
//
// Input : c_nb : a C scicos type number
//
// Output : txt : the string of the C format string
//

  select c_nb
    //real matrix
    case 10 then
      txt = '%f';
    //complex matrix
    case 11 then
      txt = '%f,%f';
    //int8 matrix
    case 81 then
      txt = '%d';
    //int16 matrix
    case 82 then
      txt = '%d';
    //int32 matrix
    case 84 then
      txt = '%d';
    //uint8 matrix
    case 811 then
      txt = '%d';
    //uint16 matrix
    case 812 then
      txt = '%d';
    //uint32 matrix
    case 814 then
      txt = '%d';
    else
      txt='%f'
      break;
 end

endfunction

function [txt]=scs_c_n2c_typ(c_nb)
//Copyright (c) 1989-2010 Metalau project INRIA
//
//@@ scs_c_n2c_typ : scicos C number to C type
//
// Input : c_nb : a C scicos type number
//
// Output : txt : the string of the C type
//

  select c_nb
    //real matrix
    case 10 then
      txt = 'double';
    //complex matrix
    case 11 then
      txt = 'double';
    //int8 matrix
    case 81 then
      txt = 'char';
    //int16 matrix
    case 82 then
      txt = 'short';
    //int32 matrix
    case 84 then
      txt = 'long';
    //uint8 matrix
    case 811 then
      txt = 'unsigned char';
    //uint16 matrix
    case 812 then
      txt = 'unsigned short';
    //uint32 matrix
    case 814 then
      txt = 'unsigned long';
    else
      txt='double'
      break;
 end

endfunction

function [scs_nb]=scs_c_nb2scs_nb(c_nb)
//Copyright (c) 1989-2010 Metalau project INRIA
//
//@@ scs_c_nb2scs_nb : scicos C number to scicos number
//
// Input :  c_nb   : the scicos C number type
//
// Output : scs_nb : the scilab number type
//

  scs_nb=zeros(size(c_nb,1),size(c_nb,2));

  for i=1:size(c_nb,1)
    for j=1:size(c_nb,2)
      select (c_nb(i,j))
        case 10 then
          scs_nb(i,j) = 1
        case 11 then
          scs_nb(i,j) = 2
        case 81 then
          scs_nb(i,j) = 5
        case 82 then
          scs_nb(i,j) = 4
        case 84 then
          scs_nb(i,j) = 3
        case 811 then
          scs_nb(i,j) = 8
        case 812 then
          scs_nb(i,j) = 7
        case 814 then
          scs_nb(i,j) = 6
        else
          scs_nb(i,j) = 1
      end
    end
  end

endfunction

function [c_nb]=scs_nb2scs_c_nb(scs_nb)
//Copyright (c) 1989-2010 Metalau project INRIA
//
//@@ scs_nb2scs_c_nb : scicos number to scicos C number
//
// Input : scs_nb : the scilab number type
//
// Output :  c_nb   : the scicos C number type
//

  c_nb=zeros(size(scs_nb,1),size(scs_nb,2));

  for i=1:size(scs_nb,1)
    for j=1:size(scs_nb,2)
      select (scs_nb(i,j))
        case 1 then
          c_nb(i,j) = 10
        case 2 then
          c_nb(i,j) = 11
        case 3 then
          c_nb(i,j) = 84
        case 4 then
          c_nb(i,j) = 82
        case 5 then
          c_nb(i,j) = 81
        case 6 then
          c_nb(i,j) = 814
        case 7 then
          c_nb(i,j) = 812
        case 8 then
          c_nb(i,j) = 811
        else
          c_nb(i,j) = -1
      end
    end
  end

endfunction

function [str]=string_to_c_string(a)
//Copyright (c) 1989-2010 Metalau project INRIA
//
//@@ string_to_c_string : ScicosLab string to C string
//
// Input :  a   : ScicosLab variable
//
// Output : str : the C string
//

  //@@ converter ScicosLab variable
  //   in a ScicosLab string
  str=string(a)

  //@@ look at for D-/D+
  for i=1:size(str,1)
    if strindex(str(i),"D-")<>[] then
      str(i)=strsubst(str(i),"D-","e-");
    elseif strindex(str(i),"D+")<>[] then
      str(i)=strsubst(str(i),"D+","e");
    end
  end

endfunction

function [XX]=update_block_doc(XX)
//Copyright (c) 1989-2010 Metalau project INRIA
//
//@@ update_block_doc : function to set a doc of the
//                      generated scicos block
//
// XX : a scicos_block data structure
//

  //@@
  doc=['//generated doc by CodeGeneration of '+get_scicos_version()
       '//date :'+date()
       '//Copyright (c) 1989-2010 Metalau project INRIA'
       ''
       '//path'
       'rpat  ='''+rpat+''';'
       ''
       '//name'
       'rdnom ='''+rdnom+''';'
       '']

  if cpr.sim.xptr($)-1<>0 then
    doc=[doc
         '//number of continuous states'
         'nx = '+string(cpr.sim.xptr($)-1)+';'
         '']
  end

  if cpr.sim.zptr($)-1<>0 then
    doc=[doc
         '//number of discrete states'
         'nz = '+string(cpr.sim.zptr($)-1)+';'
         '']
  end

  if cpr.sim.zcptr($)-1<>0 then
    doc=[doc
         '//number of zero crossing'
         'ng = '+string(cpr.sim.zcptr($)-1)+';'
         '']
  end

  if cpr.sim.modptr($)-1<>0 then
    doc=[doc
         '//number of modes'
         'nmode = '+string(cpr.sim.modptr($)-1)+';'
         '']
  end

  doc=[doc
       '//Simulator parameters'
       'ttol   = '+string_to_c_string(scs_m.props.tol(3))+';'
       'deltat = '+string_to_c_string(scs_m.props.tol(4))+';'
       '']

  if cpr.sim.xptr($)-1<>0 then
    doc=[doc
         '//Solver parameters'
         'atol   = '+string_to_c_string(scs_m.props.tol(1))+';'
         'rtol   = '+string_to_c_string(scs_m.props.tol(2))+';'
         'solver = '+string_to_c_string(scs_m.props.tol(6))+';'
         '']
  end

  txt_actt=sci2exp(actt,70);
  if size(txt_actt,'*')<>1 then
    txt_actt(1)='actt ='+txt_actt(1);
    for i=2:size(txt_actt,'*')
      txt_actt(i)='           '+txt_actt(i);
    end
  else
    txt_actt='actt ='+txt_actt+';';
  end

  txt_capt=sci2exp(capt,70);
  if size(txt_capt,'*')<>1 then
    txt_capt(1)='capt ='+txt_capt(1);
    for i=2:size(txt_capt,'*')
      txt_capt(i)='           '+txt_capt(i);
    end
  else
    txt_capt='capt ='+txt_capt+';';
  end

  doc=[doc
       '//actuators'
       txt_actt
       ''
       '//sensors'
       txt_capt
       ''
       '//standalone'
       'sta__#='+string(sta__#)
       '']

  //@@ add information for standalone
  //   if generated
  if sta__#<>0 then

   cpr=cpr;
   [nbact_sta,act_sta,actt_sta,cpr_sta]=...
            blocks_to_actuators([list_of_scopes(:,1);
                                 'affich';
                                 'affich2';
                                 'writec';
                                 'writef';
                                 'writeau';
                                 'tows_c'],...
                                 nbact,act,actt,cpr);
   [nbcap_sta,cap_sta,capt_sta,cpr_sta]=...
            blocks_to_sensors(list(),nbcap,cap,capt,cpr);

    txt_actt=sci2exp(actt_sta,70);
    if size(txt_actt,'*')<>1 then
      txt_actt(1)='actt_sta ='+txt_actt(1);
      for i=2:size(txt_actt,'*')
        txt_actt(i)='           '+txt_actt(i);
      end
    else
      txt_actt='actt_sta ='+txt_actt+';';
    end

    txt_capt=sci2exp(capt_sta,70);
    if size(txt_capt,'*')<>1 then
      txt_capt(1)='capt_sta ='+txt_capt(1);
      for i=2:size(txt_capt,'*')
        txt_capt(i)='           '+txt_capt(i);
      end
    else
      txt_capt='capt_sta ='+txt_capt+';';
    end

    doc=[doc
         '//actuators standalone'
         txt_actt
         ''
         '//sensors standalone'
         txt_capt
         '']
  end

  //@@ use standard_doc scicos function
  do_doc=do_doc;
  funname='standard_doc';
  execstr('docfun='+funname)
  documentation=list(docfun,doc)

  XX.doc=documentation

endfunction

//used in do_compile_superblock
function [XX]=update_block(XX)
//Copyright (c) 1989-2010 Metalau project INRIA
//
//@@ update_block : update a scicos_block data structure
//
// XX : a scicos_block data structure
//

  execstr('o='+rdnom+'_c(''define'')')

  XX.model=o.model
  XX.gui=rdnom+'_c'
  XX.graphics.gr_i=o.graphics.gr_i

endfunction

function cor=update_cor(cor)
//Copyright (c) 1989-2010 Metalau project INRIA
//
//@@ update_cor : update the cor list of an entire generated diagram
//
// Input :  cor : the cor list to update
//
// Output : cor : the update cor list
//
 for k=1:lstsize(cor)
   if type(cor(k))==15 then
     cor(k)=update_cor(cor(k))
   else
     if cor(k)<>0 then
       cor(k)=1
     end
   end
 end
endfunction

function [txt]=write_code_cdoit(flag)
//Copyright (c) 1989-2010 Metalau project INRIA

//@@ write_code_cdoit : generate body of the code for
//                      for all time dependant blocks
//
// Input : flag : flag number for block's call
//
// Output : txt : text for cord blocks
//

  txt=[];

  for j=1:ncord
    bk=cord(j,1);
    pt=cord(j,2);
    //** blk
    if funtyp(bk)>-1 then
      if or(bk==act) | or(bk==cap) then
        if stalone then
          txt2=call_block42(bk,pt,flag);
          if txt2<>[] then
            txt=[txt;
                 '    '+txt2
                 ''];
          end
        end
      else
        txt2=call_block42(bk,pt,flag);
        if txt2<>[] then
          txt=[txt;
               '    '+txt2
               ''];
        end
      end
    //** ifthenelse blk
    elseif funtyp(bk)==-1 then
      ix=-1+inplnk(inpptr(bk));
      TYPE=mat2c_typ(outtb(ix+1)); //** scilab index start from 1
      thentxt=write_code_doit(clkptr(bk),flag);
      elsetxt=write_code_doit(clkptr(bk)+1,flag);
      if thentxt<>[] | elsetxt<>[] then
        txt=[txt;
             '    '+get_comment('ifthenelse_blk',list(bk));]
        //** C **//
        if stalone then
          tmp_='*(('+TYPE+' *)outtb_'+string(ix+1)+')'
        else
          tmp_='*(('+TYPE+' *)'+rdnom+'_block_outtbptr['+string(ix)+'])'
        end
        txt=[txt;
             '    if('+tmp_+'>0) {']
        //*******//
        txt=[txt;
             Indent+thentxt];
        if elsetxt<>[] then
          //** C **//
          txt=[txt;
               '    }';
               '    else {';]
          //*******//
          txt=[txt;
               Indent+elsetxt];
        end
        //** C **//
        txt=[txt;
             '    }']
        //*******//
      end
    //** eventselect blk
    elseif funtyp(bk)==-2 then
      Noutport=clkptr(bk+1)-clkptr(bk);
      ix=-1+inplnk(inpptr(bk));
      TYPE=mat2c_typ(outtb(ix+1)); //** scilab index start from 1
      II=[];
      switchtxt=list()
      for i=1: Noutport
        switchtxt(i)=write_code_doit(clkptr(bk)+i-1,flag);
        if switchtxt(i)<>[] then II=[II i];end
      end
      if II<>[] then
        txt=[txt;
             '    '+get_comment('evtselect_blk',list(bk));]
        //** C **//
        if stalone then
          tmp_='*(('+TYPE+' *)outtb_'+string(ix+1)+')'
        else
          tmp_='*(('+TYPE+' *)'+rdnom+'_block_outtbptr['+string(ix)+'])'
        end
        txt=[txt;
             '    i=max(min((int) '+...
              tmp_+',block_'+rdnom+'['+string(bk-1)+'].nevout),1);'
             '    switch(i)'
             '    {']
        //*******//
        for i=II
         //** C **//
         txt=[txt;
              '     case '+string(i)+' :';]
         //*******//
         txt=[txt;
              BigIndent+write_code_doit(clkptr(bk)+i-1,flag);]
         //** C **//
         txt=[txt;
              BigIndent+'break;']
         //*******//
        end
        //** C **//
        txt=[txt;
             '    }'];
        //*******//
      end
    //** Unknown block
    else
      error('Unknown block type '+string(bk));
    end
  end

endfunction

function [txt]=write_code_doit(ev,flag,vvvv)
//Copyright (c) 1989-2010 Metalau project INRIA

//@@ write_code_doit : generate body of the code for
//                     ordering calls of blocks during
//                     flag 1,2 & flag 3
//
// Input : ev   : evt number for block's call
//         flag : flag number for block's call
//
// Output : txt : text for flag 1 or 2, or flag 3
//

  txt=[];
  zeroflag=(argn(2)==3);

  for j=ordptr(ev):ordptr(ev+1)-1
    bk=ordclk(j,1);
    if zeroflag then
      pt=0;
    else
      pt=ordclk(j,2);
    end
    //** blk
    if funtyp(bk)>-1 then
      if or(bk==act) | or(bk==cap) then
        if stalone then
          txt2=call_block42(bk,pt,flag);
          if txt2<>[] then
            txt=[txt;
                 '    '+txt2
                 ''];
          end
        end
      else
        if flag==1 | pt>0  then
          txt2=call_block42(bk,pt,flag);
        elseif  (flag==2 & pt<=0 & with_work(bk)==1) then
          pt=0
          txt2=call_block42(bk,pt,flag)
        else
          txt2=[]
        end
        if txt2<>[] then
          txt=[txt;
               '    '+txt2
               ''];
        end
      end
    //** ifthenelse blk
    elseif funtyp(bk)==-1 then
      ix=-1+inplnk(inpptr(bk));
      TYPE=mat2c_typ(outtb(ix+1)); //** scilab index start from 1
      thentxt=write_code_doit(clkptr(bk),flag);
      elsetxt=write_code_doit(clkptr(bk)+1,flag);
      if thentxt<>[] | elsetxt<>[] then
        txt=[txt;
             '    '+get_comment('ifthenelse_blk',list(bk));]
        //** C **//
        if stalone then
          tmp_='*(('+TYPE+' *)outtb_'+string(ix+1)+')'
        else
          tmp_ = '*(('+TYPE+' *)'+rdnom+'_block_outtbptr['+string(ix)+'])'
        end
        txt=[txt;
             '    if('+tmp_+'>0) {']
        //*******//
        txt=[txt;
             Indent+thentxt]
        //@@
        if ALL then
          if cpr.sim.critev(clkptr(bk)) == 1 then
            if stalone then
              if nX<>0 then
                txt=[txt;
                     Indent+'    /* critical event */'
                     Indent+'    hot = 0;']
              end
            else
              txt=[txt;
                   Indent+'    /* critical event */'
                   Indent+'    do_cold_restart();']
            end
          end
        end
        if elsetxt<>[] then
          //** C **//
          txt=[txt;
               '    }';
               '    else {';]
          //*******//
          txt=[txt;
               Indent+elsetxt]
          //@@
          if ALL then
            if cpr.sim.critev(clkptr(bk)+1) == 1 then
              if stalone then
                if nX<>0 then
                  txt=[txt;
                       Indent+'    /* critical event */'
                       Indent+'    hot = 0;']
                end
              else
                txt=[txt;
                     Indent+'    /* critical event */'
                     Indent+'    do_cold_restart();']
              end
            end
          end
        end
        //** C **//
        txt=[txt;
             '    }']
        //*******//
      end
    //** eventselect blk
    elseif funtyp(bk)==-2 then
      Noutport=clkptr(bk+1)-clkptr(bk);
      ix=-1+inplnk(inpptr(bk));
      TYPE=mat2c_typ(outtb(ix+1)); //** scilab index start from 1
      II=[];
      switchtxt=list()
      for i=1: Noutport
        switchtxt(i)=write_code_doit(clkptr(bk)+i-1,flag);
        if switchtxt(i)<>[] then II=[II i];end
      end
      if II<>[] then
        txt=[txt;
             '    '+get_comment('evtselect_blk',list(bk));]
        //** C **//
        if stalone then
          tmp_='*(('+TYPE+' *)outtb_'+string(ix+1)+')'
        else
          tmp_='*(('+TYPE+' *)'+rdnom+'_block_outtbptr['+string(ix)+'])'
        end
        txt=[txt;
             '    i=max(min((int) '+...
              tmp_+',block_'+rdnom+'['+string(bk-1)+'].nevout),1);'
             '    switch(i)'
             '    {']
        //*******//
        for i=II
          //** C **//
          txt=[txt;
               '     case '+string(i)+' :';]
          //*******//
          txt=[txt;
               BigIndent+write_code_doit(clkptr(bk)+i-1,flag);]
          //@@
          if ALL then
            if cpr.sim.critev(clkptr(bk)+i-1) == 1 then
              if stalone then
                if nX<>0 then
                  txt=[txt;
                       BigIndent+'    /* critical event */'
                       BigIndent+'    hot = 0;']
                end
              else
                txt=[txt;
                     BigIndent+'    /* critical event */'
                     BigIndent+'do_cold_restart();']
              end
            end
          end
          //** C **//
          txt=[txt;
               BigIndent+'break;']
          //*******//
        end
        //** C **//
        txt=[txt;
             '    }']
        //*******//
      end
    //** Unknown block
    else
      error('Unknown block type '+string(bk));
    end
  end

endfunction

function [txt]=write_code_idoit()
//Copyright (c) 1989-2010 Metalau project INRIA

//@@ write_code_idoit : generate body of the code for
//                   ordering calls of initial
//                   called blocks
//
// Input : nothing (blocks are called with flag 1)
//
// Output : txt : text for iord
//

  txt=[];

  for j=1:niord
    bk=iord(j,1);
    pt=iord(j,2);
    //** blk
    if funtyp(bk)>-1 then
      if or(bk==act) | or(bk==cap) then
        if stalone then
          txt2=call_block42(bk,pt,1);
          if txt2<>[] then
            txt=[txt;
                 '  '+txt2
                 ''];
          end
        end
      else
        txt2=call_block42(bk,pt,1);
        if txt2<>[] then
          txt=[txt;
               '  '+txt2
               ''];
        end
      end
    //** ifthenelse blk
    elseif funtyp(bk)==-1 then
      ix=-1+inplnk(inpptr(bk));
      TYPE=mat2c_typ(outtb(ix+1)); //** scilab index start from 1
      thentxt=write_code_doit(clkptr(bk),1);
      elsetxt=write_code_doit(clkptr(bk)+1,1);
      if thentxt<>[] | elsetxt<>[] then
        txt=[txt;
             '  '+get_comment('ifthenelse_blk',list(bk));]
        //** C **//
        if stalone then
          tmp_='*(('+TYPE+' *)outtb_'+string(ix+1)+')'
        else
          tmp_ = '*(('+TYPE+' *)'+rdnom+'_block_outtbptr['+string(ix)+'])'
        end
        txt=[txt;
             '  if('+tmp_+'>0) {']
        //*******//
        txt=[txt;
             Indent+thentxt];
        if elsetxt<>[] then
           //** C **//
           txt=[txt;
                '  }';
                '  else {';]
           //*******//
           txt=[txt;
                Indent+elsetxt];
        end
        //** C **//
        txt=[txt;
             '  }']
        //*******//
      end
    //** eventselect blk
    elseif funtyp(bk)==-2 then
      Noutport=clkptr(bk+1)-clkptr(bk);
      ix=-1+inplnk(inpptr(bk));
      TYPE=mat2c_typ(outtb(ix+1)); //** scilab index start from 1
      II=[];
      switchtxt=list()
      for i=1: Noutport
        switchtxt(i)=write_code_doit(clkptr(bk)+i-1,1);
        if switchtxt(i)<>[] then II=[II i];end
      end
      if II<>[] then
        txt=[txt;
             '  '+get_comment('evtselect_blk',list(bk));]
        //** C **//
        if stalone then
          tmp_='*(('+TYPE+' *)outtb_'+string(ix+1)+')'
        else
          tmp_='*(('+TYPE+' *)'+rdnom+'_block_outtbptr['+string(ix)+'])'
        end
        txt=[txt;
             '  i=max(min((int) '+...
              tmp_+',block_'+rdnom+'['+string(bk-1)+'].nevout),1);']
        txt=[txt;
             '  switch(i)'
             '  {']
        //*******//
        for i=II
          //** C **//
          txt=[txt;
               '   case '+string(i)+' :';]
          //*******//
          txt=[txt;
               BigIndent+write_code_doit(clkptr(bk)+i-1,1);]
          //** C **//
          txt=[txt;
               BigIndent+'break;']
          //*******//
        end
        //** C **//
        txt=[txt;
             '  }'];
        //*******//
      end
    //** Unknown block
    else
      error('Unknown block type '+string(bk));
    end
  end

endfunction

function [txt]=write_code_initdoit(ev,flag)
//Copyright (c) 1989-2010 Metalau project INRIA

//@@ write_code_initdoit : generate body of the code for
//                         ordering calls of blocks during
//                         implicit solver initialization
//
// Input : ev   : evt number for block's call
//         flag : flag number for block's call
//
// Output : txt : text to call block
//

  txt=[];

  for j=ordptr(ev):ordptr(ev+1)-1
    bk=ordclk(j,1);
    pt=ordclk(j,2);
    //** blk
    if funtyp(bk)>-1 then
      if or(bk==act) | or(bk==cap) then
        if stalone then
          txt2=call_block42(bk,pt,flag);
          if txt2<>[] then
            txt=[txt;
                 '  '+txt2
                 ''];
          end
        end
      else
        txt2=call_block42(bk,pt,flag);
        if txt2<>[] then
          txt=[txt;
               '  '+txt2
               ''];
        end
      end
    //** ifthenelse blk
    elseif funtyp(bk)==-1 then
      ix=-1+inplnk(inpptr(bk));
      TYPE=mat2c_typ(outtb(ix+1)); //** scilab index start from 1
      thentxt=write_code_initdoit(clkptr(bk),flag);
      elsetxt=write_code_initdoit(clkptr(bk)+1,flag);
      if thentxt<>[] | elsetxt<>[] then
        txt=[txt;
             '  '+get_comment('ifthenelse_blk',list(bk));]
        //** C **//
        if stalone then
          tmp_='*(('+TYPE+' *)outtb_'+string(ix+1)+')'
        else
          tmp_ = '*(('+TYPE+' *)'+rdnom+'_block_outtbptr['+string(ix)+'])'
        end
        txt=[txt;
             '  if('+tmp_+'>0) {']
        //*******//
        txt=[txt;
             Indent+thentxt]
        if elsetxt<>[] then
           //** C **//
           txt=[txt;
                '  }';
                '  else {';]
           //*******//
           txt=[txt;
                Indent+elsetxt];
        end
        //** C **//
        txt=[txt;
             '  }']
        //*******//
      end
    //** eventselect blk
    elseif funtyp(bk)==-2 then
      Noutport=clkptr(bk+1)-clkptr(bk);
      ix=-1+inplnk(inpptr(bk));
      TYPE=mat2c_typ(outtb(ix+1)); //** scilab index start from 1
      II=[];
      switchtxt=list()
      for i=1: Noutport
        switchtxt(i)=write_code_doit(clkptr(bk)+i-1,flag);
        if switchtxt(i)<>[] then II=[II i];end
      end
      if II<>[] then
        txt=[txt;
             '  '+get_comment('evtselect_blk',list(bk));]
        //** C **//
        if stalone then
          tmp_='*(('+TYPE+' *)outtb_'+string(ix+1)+')'
        else
          tmp_='*(('+TYPE+' *)'+rdnom+'_block_outtbptr['+string(ix)+'])'
        end
        txt=[txt;
             '  i=max(min((int) '+...
              tmp_+',block_'+rdnom+'['+string(bk-1)+'].nevout),1);'
             '  switch(i)'
             '  {']
        //*******//
        for i=II
          //** C **//
          txt=[txt;
               '   case '+string(i)+' :';]
          //*******//
          txt=[txt;
               BigIndent+write_code_doit(clkptr(bk)+i-1,flag);]
          //** C **//
          txt=[txt;
               BigIndent+'break;']
          //*******//
        end
        //** C **//
        txt=[txt;
             '  }']
        //*******//
      end
    //** Unknown block
    else
      error('Unknown block type '+string(bk));
    end
  end

endfunction

function [txt]=write_code_odoit(flag)
//Copyright (c) 1989-2010 Metalau project INRIA

//@@ write_code_odoit : generate body of the code for
//                      ordering calls of blocks before
//                      continuous time integration
//
// Input : flag : flag number for block's call
//
// Output : txt : text for flag 0
//

  txt=[];

  for j=1:noord
    bk=oord(j,1);
    if flag==2 then
      pt=0;
    else
      pt=oord(j,2);
    end
    //** blk
    if funtyp(bk)>-1 then
      if or(bk==cap) then
        if stalone then
          txt2=call_block42(bk,pt,flag);
          if txt2<>[] then
            txt=[txt;
                 '  '+txt2
                 ''];
          end
        end
      else
        txt2=call_block42(bk,pt,flag);
        if txt2<>[] then
          if flag==10 & stalone then
            txt2=['if (AJacobian_block=='+string(bk)+') {'
                  '  '+txt2
                  '}']
          end
          txt=[txt;
               '  '+txt2
               ''];
        end
      end
    //** ifthenelse blk
    elseif funtyp(bk)==-1 then
      ix=-1+inplnk(inpptr(bk));
      TYPE=mat2c_typ(outtb(ix+1)); //** scilab index start from 1
      thentxt=write_code_ozdoit(clkptr(bk),flag);
      elsetxt=write_code_ozdoit(clkptr(bk)+1,flag);
      if thentxt<>[] | elsetxt<>[] then
        txt=[txt;
             '  '+get_comment('ifthenelse_blk',list(bk));]
        //** C **//
        if stalone then
          for i=1:lstsize(funs)-1
            for j=1:outptr(i+1)-outptr(i)
              if outlnk(outptr(i)+j-1)-1 == ix then
                tmp_ = '*(('+TYPE+' *)block_'+rdnom+'['+string(i-1)+'].outptr['+string(j-1)+'])'
                break
              end
            end
          end
          //tmp_='*(('+TYPE+' *)outtb_'+string(ix+1)+')'
        else
          tmp_='*(('+TYPE+' *)'+rdnom+'_block_outtbptr['+string(ix)+'])'
        end
        txt=[txt;
             '  if ((block_'+rdnom+'['+string(bk-1)+'].nmode<0'+...
              ' && '+tmp_+'>0)'+...
              ' || \'
             '      (block_'+rdnom+'['+string(bk-1)+'].nmode>0'+...
              ' && block_'+rdnom+'['+string(bk-1)+'].mode[0]==1)) {']
        //*******//
        txt=[txt;
             Indent+thentxt]
        //** C **//
        txt=[txt;
             '  }'];
        //*******//
        if elsetxt<>[] then
          //** C **//
          txt=[txt;
               '  else if  ((block_'+rdnom+'['+string(bk-1)+'].nmode<0'+...
                ' && '+tmp_+'<=0)'+...
                ' || \'
               '            (block_'+rdnom+'['+string(bk-1)+'].nmode>0'+...
                ' && block_'+rdnom+'['+string(bk-1)+'].mode[0]==2)) {';]
          //*******//
          txt=[txt;
               Indent+elsetxt]
          //** C **//
          txt=[txt;
               '  }'];
          //*******//
        end
      end
    //** eventselect blk
    elseif funtyp(bk)==-2 then
      Noutport=clkptr(bk+1)-clkptr(bk);
      ix=-1+inplnk(inpptr(bk));
      TYPE=mat2c_typ(outtb(ix+1)); //** scilab index start from 1
      II=[];
      switchtxt=list()
      for i=1: Noutport
        switchtxt(i)=write_code_ozdoit(clkptr(bk)+i-1,flag);
        if switchtxt(i)<>[] then II=[II i];end
      end
      if II<>[] then
        txt=[txt;
             '  '+get_comment('evtselect_blk',list(bk));]
        //** C **//
        if stalone then
          tmp_='*(('+TYPE+' *)outtb_'+string(ix+1)+')'
        else
          tmp_='*(('+TYPE+' *)'+rdnom+'_block_outtbptr['+string(ix)+'])'
        end
        txt=[txt;
             '  if (block_'+rdnom+'['+string(bk-1)+'].nmode<0) {';
             '    i=max(min((int) '+...
                tmp_+',block_'+rdnom+'['+string(bk-1)+'].nevout),1);'
             '  }'
             '  else {'
             '    i=block_'+rdnom+'['+string(bk-1)+'].mode[0];'
             '  }']
        txt=[txt;
             '  switch(i)'
             '  {'];
        //*******//
        for i=II
          //** C **//
          txt=[txt;
               '   case '+string(i)+' :';]
          //*******//
          txt=[txt;
               BigIndent+write_code_ozdoit(clkptr(bk)+i-1,flag);]
          //** C **//
          txt=[txt;
               BigIndent+'break;']
          //*******//
        end
        //** C **//
        txt=[txt;
             '  }'];
        //*******//
      end
    //** Unknown block
    else
      error('Unknown block type '+string(bk));
    end
  end

endfunction

function [txt]=write_code_ozdoit(ev,flag)
//Copyright (c) 1989-2010 Metalau project INRIA

//@@ write_code_ozdoit : generate body of the code for both
//                       flag 0 & flag 9
//
// Input:  ev   : evt number for block's call
//         flag : flag number for block's call
//
// Output : txt : text for flag 0 or flag 9
//

  txt=[];

  for j=ordptr(ev):ordptr(ev+1)-1
    bk=ordclk(j,1);
    pt=ordclk(j,2);
    //** blk
    if funtyp(bk)>-1 then
      if (or(bk==act) | or(bk==cap)) & (flag==1) then
        if stalone then
          txt=[txt;
               '    '+call_block42(bk,pt,flag)
               ''];
        end
      else
        txt2=call_block42(bk,pt,flag);
        if txt2<>[] then
          txt=[txt;
               '    '+txt2
               ''];
        end
      end
    //** ifthenelse blk
    elseif funtyp(bk)==-1 then
      ix=-1+inplnk(inpptr(bk));
      TYPE=mat2c_typ(outtb(ix+1)); //** scilab index start from 1
      thentxt=write_code_ozdoit(clkptr(bk),flag);
      elsetxt=write_code_ozdoit(clkptr(bk)+1,flag);
      if thentxt<>[] | elsetxt<>[] then
        txt=[txt;
             '    '+get_comment('ifthenelse_blk',list(bk));]
        //** C **//
        if stalone then
          for i=1:lstsize(funs)-1
            for j=1:outptr(i+1)-outptr(i)
              if outlnk(outptr(i)+j-1)-1 == ix then
                tmp_ = '*(('+TYPE+' *)'+rdnom+'_block['+string(i-1)+'].outptr['+string(j-1)+'])'
                break
              end
            end
          end
          //tmp_='*(('+TYPE+' *)outtb_'+string(ix+1)+')'
        else
          tmp_ = '*(('+TYPE+' *)'+rdnom+'_block_outtbptr['+string(ix)+'])'
        end
        txt=[txt;
             '    if (((phase==1'+...
              ' || block_'+rdnom+'['+string(bk-1)+'].nmode==0)'+...
              ' && '+tmp_+'>0)'+...
              ' || \'
             '        ((phase!=1'+...
              ' && block_'+rdnom+'['+string(bk-1)+'].nmode!=0)'+...
              ' && block_'+rdnom+'['+string(bk-1)+'].mode[0]==1)) {']
        //*******//
        txt=[txt;
             Indent+thentxt]
        //** C **//
        txt=[txt;
             '    }'];
        //*******//
        if elsetxt<>[] then
           //** C **//
           txt=[txt;
                '    else if (((phase==1'+...
                 ' || block_'+rdnom+'['+string(bk-1)+'].nmode==0)'+...
                 ' && '+tmp_+'<=0)'+...
                 ' || \'
                '               ((phase!=1'+...
                 ' && block_'+rdnom+'['+string(bk-1)+'].nmode!=0)'+...
                 ' && block_'+rdnom+'['+string(bk-1)+'].mode[0]==2)) {';]
          //*******//
          txt=[txt;
               Indent+elsetxt]
          //** C **//
          txt=[txt;
                '    }'];
          //*******//
        end
      end
    //** eventselect blk
    elseif funtyp(bk)==-2 then
      Noutport=clkptr(bk+1)-clkptr(bk);
      ix=-1+inplnk(inpptr(bk));
      TYPE=mat2c_typ(outtb(ix+1)); //** scilab index start from 1
      II=[];
      switchtxt=list()
      for i=1: Noutport
        switchtxt(i)=write_code_ozdoit(clkptr(bk)+i-1,flag);
        if switchtxt(i)<>[] then II=[II i];end
      end
      if II<>[] then
        txt=[txt;
             '    '+get_comment('evtselect_blk',list(bk));]
        //** C **//
        if stalone then
          tmp_='*(('+TYPE+' *)outtb_'+string(ix+1)+')'
        else
          tmp_='*(('+TYPE+' *)'+rdnom+'_block_outtbptr['+string(ix)+'])'
        end
        txt=[txt;
             '    if (phase==1 || block_'+rdnom+'['+string(bk-1)+'].nmode==0) {';
             '      i=max(min((int) '+...
              tmp_+',block_'+rdnom+'['+string(bk-1)+'].nevout),1);'
             '    }'
             '    else {'
             '      i=block_'+rdnom+'['+string(bk-1)+'].mode[0];'
             '    }']
        txt=[txt;
             '    switch(i)'
             '    {'];
        //*******//
        for i=II
          //** C **//
          txt=[txt;
               '     case '+string(i)+' :';]
          //*******//
          txt=[txt;
               BigIndent+write_code_ozdoit(clkptr(bk)+i-1,flag);]
          //** C **//
          txt=[txt;
               BigIndent+'break;']
          //*******//
        end
        //** C **//
        txt=[txt;
             '    }'];
        //*******//
      end
    //** Unknown block
    else
      error('Unknown block type '+string(bk));
    end
  end

endfunction

function [txt]=write_code_reinitdoit(flag)
//Copyright (c) 1989-2010 Metalau project INRIA

//@@ write_code_reinitdoit : generate body of the code for
//                           implicit solver reinitialization
//
// Input  : flag : flag number for block's call
//
// Output : txt : text for xproperties
//

  txt=[];

  for j=1:noord
    bk=oord(j,1);
    pt=oord(j,2);
    //** blk
    if funtyp(bk)>-1 then
      if or(bk==cap) then
        if stalone then
          txt2=call_block42(bk,pt,flag);
          if txt2<>[] then
            txt=[txt;
                 '  '+txt2
                 ''];
          end
        end
      else
        txt2=call_block42(bk,pt,flag);
        if txt2<>[] then
          txt=[txt;
               '  '+txt2
               ''];
        end
      end
    //** ifthenelse blk
    elseif funtyp(bk)==-1 then
      ix=-1+inplnk(inpptr(bk));
      TYPE=mat2c_typ(outtb(ix+1)); //** scilab index start from 1
      thentxt=write_code_initdoit(clkptr(bk),flag);
      elsetxt=write_code_initdoit(clkptr(bk)+1,flag);
      if thentxt<>[] | elsetxt<>[] then
        txt=[txt;
             '  '+get_comment('ifthenelse_blk',list(bk));]
        //** C **//
        if stalone then
          tmp_='*(('+TYPE+' *)outtb_'+string(ix+1)+')'
        else
          tmp_='*(('+TYPE+' *)'+rdnom+'_block_outtbptr['+string(ix)+'])'
        end
        txt=[txt;
             '  if ((block_'+rdnom+'['+string(bk-1)+'].nmode<0'+...
              ' && '+tmp_+'>0)'+...
              ' || \'
             '      (block_'+rdnom+'['+string(bk-1)+'].nmode>0'+...
              ' && block_'+rdnom+'['+string(bk-1)+'].mode[0]==1)) {']
        //*******//
        txt=[txt;
             Indent+thentxt]
        //** C **//
        txt=[txt;
             '  }'];
        //*******//
        if elsetxt<>[] then
          //** C **//
          txt=[txt;
               '  else if  ((block_'+rdnom+'['+string(bk-1)+'].nmode<0'+...
                ' && '+tmp_+'<=0)'+...
                ' || \'
               '            (block_'+rdnom+'['+string(bk-1)+'].nmode>0'+...
                ' && block_'+rdnom+'['+string(bk-1)+'].mode[0]==2)) {';]
          //*******//
          txt=[txt;
               Indent+elsetxt]
          //** C **//
          txt=[txt;
               '  }'];
          //*******//
        end
      end
    //** eventselect blk
    elseif funtyp(bk)==-2 then
      Noutport=clkptr(bk+1)-clkptr(bk);
      ix=-1+inplnk(inpptr(bk));
      TYPE=mat2c_typ(outtb(ix+1)); //** scilab index start from 1
      II=[];
      switchtxt=list()
      for i=1: Noutport
        switchtxt(i)=write_code_ozdoit(clkptr(bk)+i-1,flag);
        if switchtxt(i)<>[] then II=[II i];end
      end
      if II<>[] then
        txt=[txt;
             '  '+get_comment('evtselect_blk',list(bk));]
        //** C **//
        if stalone then
          tmp_='*(('+TYPE+' *)outtb_'+string(ix+1)+')'
        else
          tmp_='*(('+TYPE+' *)'+rdnom+'_block_outtbptr['+string(ix)+'])'
        end
        txt=[txt;
             '  if (block_'+rdnom+'['+string(bk-1)+'].nmode<0) {';
             '    i=max(min((int) '+...
                tmp_+',block_'+rdnom+'['+string(bk-1)+'].nevout),1);'
             '  }'
             '  else {'
             '    i=block_'+rdnom+'['+string(bk-1)+'].mode[0];'
             '  }']
        txt=[txt;
             '  switch(i)'
             '  {'];
        //*******//
        for i=II
          //** C **//
          txt=[txt;
               '   case '+string(i)+' :';]
          //*******//
          txt=[txt;
               BigIndent+write_code_initdoit(clkptr(bk)+i-1,flag);]
          //** C **//
          txt=[txt;
               BigIndent+'break;']
          //*******//
        end
        //** C **//
        txt=[txt;
             '  }'];
        //*******//
      end
    //** Unknown block
    else
      error('Unknown block type '+string(bk));
    end
  end

endfunction

function [txt]=write_code_zdoit()
//Copyright (c) 1989-2010 Metalau project INRIA

//@@ write_code_zdoit : generate body of the code for
//                   ordering calls of blocks before
//                   continuous time zero crossing
//                   detection
//
// Input  : noting
//
// Output : txt : text for flag 9
//

  txt=[];

  //** first pass (flag 1)
  for j=1:nzord
    bk=zord(j,1);
    pt=zord(j,2);
    //** blk
    if funtyp(bk)>-1 then
      if or(bk==act) | or(bk==cap) then
        if stalone then
          txt=[txt;
               '  '+call_block42(bk,pt,1)
               ''];
        end
      else
        txt2=call_block42(bk,pt,1);
        if txt2<>[] then
          txt=[txt;
               '  '+txt2
               ''];
        end
      end
    //** ifthenelse blk
    elseif funtyp(bk)==-1 then
      ix=-1+inplnk(inpptr(bk));
      TYPE=mat2c_typ(outtb(ix+1)); //** scilab index start from 1
      thentxt=write_code_ozdoit(clkptr(bk),1);
      elsetxt=write_code_ozdoit(clkptr(bk)+1,1);
      if thentxt<>[] | elsetxt<>[] then
        txt=[txt;
             '  '+get_comment('ifthenelse_blk',list(bk));]
        //** C **//
        if stalone then
          for i=1:lstsize(funs)-1
            for j=1:outptr(i+1)-outptr(i)
              if outlnk(outptr(i)+j-1)-1 == ix then
                tmp_ = '*(('+TYPE+' *)block_'+rdnom+'['+string(i-1)+'].outptr['+string(j-1)+'])'
                break
              end
            end
          end
          //tmp_='*(('+TYPE+' *)outtb_'+string(ix+1)+')'
        else
          tmp_ = '*(('+TYPE+' *)'+rdnom+'_block_outtbptr['+string(ix)+'])'
        end
        txt=[txt;
             '  if (((phase==1'+...
              ' || block_'+rdnom+'['+string(bk-1)+'].nmode==0)'+...
              ' && '+tmp_+'>0)'+...
              ' || \'
             '      ((phase!=1'+...
              ' && block_'+rdnom+'['+string(bk-1)+'].nmode!=0)'+...
              ' && block_'+rdnom+'['+string(bk-1)+'].mode[0]==1)) {']
        //*******//
        txt=[txt;
             Indent+thentxt]
        //** C **//
        txt=[txt;
             '  }'];
        //*******//
        if elsetxt<>[] then
           //** C **//
           txt=[txt;
                '  else if (((phase==1'+...
                 ' || block_'+rdnom+'['+string(bk-1)+'].nmode==0)'+...
                 ' && '+tmp_+'<=0)'+...
                 ' || \'
                '             ((phase!=1'+...
                 ' && block_'+rdnom+'['+string(bk-1)+'].nmode!=0)'+...
                 ' && block_'+rdnom+'['+string(bk-1)+'].mode[0]==2)) {';]
          //*******//
          txt=[txt;
               Indent+elsetxt]
          //** C **//
          txt=[txt;
               '  }'];
          //*******//
        end
      end
    //** eventselect blk
    elseif funtyp(bk)==-2 then
      Noutport=clkptr(bk+1)-clkptr(bk);
      ix=-1+inplnk(inpptr(bk));
      TYPE=mat2c_typ(outtb(ix+1)); //** scilab index start from 1
      II=[];
      switchtxt=list()
      for i=1: Noutport
        switchtxt(i)=write_code_ozdoit(clkptr(bk)+i-1,1);
        if switchtxt(i)<>[] then II=[II i];end
      end
      if II<>[] then
        txt=[txt;
             '  '+get_comment('evtselect_blk',list(bk));]
        //** C **//
        if stalone then
          tmp_='*(('+TYPE+' *)outtb_'+string(ix+1)+')'
        else
          tmp_='*(('+TYPE+' *)'+rdnom+'_block_outtbptr['+string(ix)+'])'
        end
        txt=[txt;
             '  if (phase==1 || block_'+rdnom+'['+string(bk-1)+'].nmode==0){';
             '      i=max(min((int) '+...
               tmp_+',block_'+rdnom+'['+string(bk-1)+'].nevout),1);'
             '  else {'
             '      i=block_'+rdnom+'['+string(bk-1)+'].mode[0];'
             '  }']
        txt=[txt;
             '    switch(i)'
             '    {'];
        //*******//
        for i=II
          //** C **//
          txt=[txt;
               '     case '+string(i)+' :';]
          //*******//
          txt=[txt;
               BigIndent+write_code_ozdoit(clkptr(bk)+i-1,1);]
          //** C **//
          txt=[txt;
               BigIndent+'break;']
          //*******//
        end
        //** C **//
        txt=[txt;
             '    }'];
        //*******//
      end
    //** Unknown block
    else
      error('Unknown block type '+string(bk));
    end
  end

  //** second pass (flag 9)
  for j=1:nzord
    bk=zord(j,1);
    pt=zord(j,2);
    //** blk
    if funtyp(bk)>-1 then
        if or(bk==act) | or(bk==cap) then 
          if stalone then
            txt=[txt;
                 '  '+call_block42(bk,pt,9)
                 ''];
          end
        else
          txt2=call_block42(bk,pt,9);
          if txt2<>[] then
            txt=[txt;
                 '  '+txt2
                 ''];
          end
        end

    //** ifthenelse blk
    elseif funtyp(bk)==-1 then
        ix=-1+inplnk(inpptr(bk));
        TYPE=mat2c_typ(outtb(ix+1)); //** scilab index start from 1
        //** C **//
        if stalone then
          for i=1:lstsize(funs)-1
            for j=1:outptr(i+1)-outptr(i)
              if outlnk(outptr(i)+j-1)-1 == ix then
                tmp_ = '*(('+TYPE+' *)block_'+rdnom+'['+string(i-1)+'].outptr['+string(j-1)+'])'
                break
              end
            end
          end
          //tmp_='*(('+TYPE+' *)outtb_'+string(ix+1)+')'
        else
          tmp_='*(('+TYPE+' *)'+rdnom+'_block_outtbptr['+string(ix)+'])'
        end
        //*******//
        thentxt=write_code_zzdoit(clkptr(bk),9);
        elsetxt=write_code_zzdoit(clkptr(bk)+1,9);
        txt=[txt;
             '  '+get_comment('ifthenelse_blk',list(bk));]
        //** C **//
        txt=[txt;
              '  g['+string(zcptr(bk)-1)+']=(double)'+tmp_+';']
        //*******//
        if thentxt<>[] | elsetxt<>[] then
           //** C **//
           txt=[txt;
                '  if (g['+string(zcptr(bk)-1)+'] > 0.){']
           //*******//
           txt=[txt;
                Indent+thentxt]
           //** C **//
           txt=[txt;
                '    }']
           //*******//
           if elsetxt <> [] then
             //** C **//
             txt=[txt;
                  '    else {']
             //*******//
             txt=[txt;
                  Indent+elsetxt]
             //** C **//
             txt=[txt;
                  '    }']
             //*******//
           end
        end
        //** C **//
        txt=[txt;
              '  if(phase==1 && block_'+rdnom+'['+string(bk-1)+'].nmode > 0){'
              '    if (g['+string(zcptr(bk)-1)+'] > 0.){'
              '      block_'+rdnom+'['+string(bk-1)+'].mode[0] = 1;'
              '    }'
              '    else {'
              '      block_'+rdnom+'['+string(bk-1)+'].mode[0] = 2;'
              '    }'
              '  }']
        //*******//
    //** eventselect blk
    elseif funtyp(bk)==-2 then
        Noutport=clkptr(bk+1)-clkptr(bk);
        ix=-1+inplnk(inpptr(bk));
        TYPE=mat2c_typ(outtb(ix+1));  //** scilab index start from 1
        //** C **//
        if stalone then
          tmp_='*(('+TYPE+' *)outtb_'+string(ix+1)+')'
        else
          tmp_='*(('+TYPE+' *)'+rdnom+'_block_outtbptr['+string(ix)+'])'
        end
        //*******//
        II=[];
        switchtxt=list()
        for i=1:Noutport
          switchtxt(i)=write_code_zzdoit(clkptr(bk)+i-1,9);
          if switchtxt(i)<>[] then II=[II i];end
        end
        txt=[txt;
             '  '+get_comment('evtselect_blk',list(bk));]
        if II<>[] then
          //** C **//
          txt=[txt;
               '  j=max(min((int) '+...
                tmp_+',block_'+rdnom+'['+string(bk-1)+'].nevout),1);']
          txt=[txt;
               '  switch(j)'
               '  {'];
          //*******//
          for i=II
            //** C **//
            txt=[txt;
                 '   case '+string(j)+' :';]
            //*******//
            txt=[txt;
                 BigIndent+write_code_zzdoit(clkptr(bk)+i-1,9);]
            //** C **//
            txt=[txt;
                 BigIndent+'break;']
            //*******//
          end
          //** C **//
          txt=[txt;
               '  }'];
          //*******//
        end
        //** C **//
        txt=[txt;
             '  for (jj=0;jj<block_'+rdnom+'['+string(fun-1)+'].nevout-1;++jj) {'
             '    g['+string(zcptr(bk)-1)+'+jj]=(double)'+tmp_+'-(double)(jj+2);'
             '  }'
             '  if(phase==1 && block_'+rdnom+'['+string(bk-1)+'].nmode>0){'
             '    j=max(min((int) '+tmp_+','
             '              block_'+rdnom+'['+string(bk-1)+'].nevout),1);'
             '    block_'+rdnom+'['+string(bk-1)+'].mode[0]= j;'
             '  }']
        //*******//
    //** Unknown block
    else
      error('Unknown block type '+string(bk));
    end
  end

endfunction

function [txt]=write_code_zzdoit(ev,flag)
//Copyright (c) 1989-2010 Metalau project INRIA

//@@ write_code_zzdoit : generate body of the code for
//                       flag 9
//
// Input : ev   : evt number for block's call
//         flag : flag number for block's call
//
// Output : txt : text for flag 9
//

  txt=[];

  for j=ordptr(ev):ordptr(ev+1)-1
    bk=ordclk(j,1);
    pt=ordclk(j,2);
    //** blk
    if funtyp(bk)>-1 then
      if or(bk==act) | or(bk==cap) then
        if stalone then
          txt=[txt;
               '    '+call_block42(bk,pt,flag)
               ''];
        end
      else
        txt2=call_block42(bk,pt,flag);
        if txt2<>[] then
          txt=[txt;
               '    '+txt2
               ''];
        end
      end
    //** ifthenelse blk
    elseif funtyp(bk)==-1 then
        ix=-1+inplnk(inpptr(bk));
        TYPE=mat2c_typ(outtb(ix+1)); //** scilab index start from 1
        //** C **//
        if stalone then
          for i=1:lstsize(funs)-1
            for j=1:outptr(i+1)-outptr(i)
              if outlnk(outptr(i)+j-1)-1 == ix then
                tmp_ = '*(('+TYPE+' *)block_'+rdnom+'['+string(i-1)+'].outptr['+string(j-1)+'])'
                break
              end
            end
          end
//           tmp_='*(('+TYPE+' *)outtb_'+string(ix+1)+')'
        else
          tmp_ = '*(('+TYPE+' *)'+rdnom+'_block_outtbptr['+string(ix)+'])'
        end
        //*******//
        thentxt=write_code_zzdoit(clkptr(bk),9);
        elsetxt=write_code_zzdoit(clkptr(bk)+1,9);
        txt=[txt;
             '    '+get_comment('ifthenelse_blk',list(bk));]
        //** C **//
        txt=[txt;
              '    g['+string(zcptr(bk)-1)+']=(double)'+tmp_+';']
        //*******//
        if thentxt<>[] | elsetxt<>[] then
           //** C **//
           txt=[txt;
                '    if (g['+string(zcptr(bk)-1)+'] > 0.){']
           //*******//
           txt=[txt;
                Indent+thentxt]
           //** C **//
           txt=[txt;
                '      }']
           //*******//
           if elsetxt <> [] then
             //** C **//
             txt=[txt;
                  '      else {']
             //*******//
             txt=[txt;
                  Indent+elsetxt]
             //** C **//
             txt=[txt;
                  '      }']
             //*******//
           end
        end
        //** C **//
        txt=[txt;
              '    if(phase==1 && block_'+rdnom+'['+string(bk-1)+'].nmode > 0){'
              '      if (g['+string(zcptr(bk)-1)+'] > 0.){'
              '        block_'+rdnom+'['+string(bk-1)+'].mode[0] = 1;'
              '      }'
              '      else {'
              '        block_'+rdnom+'['+string(bk-1)+'].mode[0] = 2;'
              '      }'
              '    }']
        //*******//

    //** eventselect blk
    elseif funtyp(bk)==-2 then
        Noutport=clkptr(bk+1)-clkptr(bk);
        ix=-1+inplnk(inpptr(bk));
        TYPE=mat2c_typ(outtb(ix+1));  //** scilab index start from 1
        //** C **//
        if stalone then
          tmp_='*(('+TYPE+' *)outtb_'+string(ix+1)+')'
        else
          tmp_='*(('+TYPE+' *)'+rdnom+'_block_outtbptr['+string(ix)+'])'
        end
        //*******//
        II=[];
        switchtxt=list()
        for i=1:Noutport
          switchtxt(i)=write_code_zzdoit(clkptr(bk)+i-1,9);
          if switchtxt(i)<>[] then II=[II i];end
        end
        txt=[txt;
             '    '+get_comment('evtselect_blk',list(bk));]
        if II<>[] then
          //** C **//
          txt=[txt;
               '    j=max(min((int) '+...
                tmp_+',block_'+rdnom+'['+string(bk-1)+'].nevout),1);']
          txt=[txt;
               '    switch(j)'
               '    {'];
          //*******//
          for i=II
            //** C **//
            txt=[txt;
                 '     case '+string(j)+' :';]
            //*******//
            txt=[txt;
                 BigIndent+write_code_zzdoit(clkptr(bk)+i-1,9);]
            //** C **//
            txt=[txt;
                 BigIndent+'break;']
            //*******//
          end
          //** C **//
          txt=[txt;
               '    }'];
          //*******//
        end
        //** C **//
        txt=[txt;
             '  for (jj=0;jj<block_'+rdnom+'['+string(fun-1)+'].nevout-1;++jj) {'
             '    g['+string(zcptr(bk)-1)+'+jj]=(double)'+tmp_+'-(double)(jj+2);'
             '  }'
             '  if(phase==1 && block_'+rdnom+'['+string(bk-1)+'].nmode>0){'
             '    j=max(min((int) '+tmp_+','
             '              block_'+rdnom+'['+string(bk-1)+'].nevout),1);'
             '    block_'+rdnom+'['+string(bk-1)+'].mode[0]= j;'
             '  }']
        //*******//

    //** Unknown block
    else
      error('Unknown block type '+string(bk));
    end
  end

endfunction



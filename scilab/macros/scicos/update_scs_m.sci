function scs_m_new = update_scs_m(scs_m,version)
// Copyright INRIA
// update_scs_m : function to do certification of
//                main data structure of
//                a scicos diagram (scs_m)
//                for current version of scicos
//
//   certification is done through initial value of fields in :
//      scicos_diagram()
//         scicos_params()
//         scicos_block()
//            scicos_graphics()
//            scicos_model()
//         scicos_link()

  rhs = argn(2)
  if rhs<2 then
    version=get_scicos_version();
  end

  scs_m_new = scicos_diagram();

  F = getfield(1,scs_m);

  for i=2:size(F,2)

    select F(i)

      //******************* props *******************//
      case 'props' then

        sprops = scs_m.props;
        T = getfield(1,scs_m.props);
        T_txt = [];
        for j=2:size(T,2)
          T_txt = T_txt + strsubst(T(1,j),'title','Title') + ...
                  "=" + "sprops." + T(1,j);
          if j<>size(T,2) then
             T_txt = T_txt + ',';
          end
        end
        T_txt = 'sprops=scicos_params(' + T_txt + ')';
        ierr  = execstr(T_txt,'errcatch')
        if ierr<>0 then
           error("Problem in convertion of props in diagram.")
        end
        scs_m_new.props = sprops;
      //*********************************************//

      //******************** objs *******************//
      case 'objs' then

        for j=1:lstsize(scs_m.objs) //loop on objects

          o=scs_m.objs(j);

          select typeof(o)

            //************** Block ***************//
            case 'Block' then

              o_new=scicos_block();
              T = getfield(1,o);

              for k=2:size(T,2)
                select T(k)
                  //*********** graphics **********//
                  case 'graphics' then
                    ogra  = o.graphics;
                    G     = getfield(1,ogra);
                    G_txt = [];
                    for l=2:size(G,2)
                      G_txt = G_txt + G(1,l) + ...
                              "=" + "ogra." + G(1,l);
                      if l<>size(G,2) then
                        G_txt = G_txt + ',';
                      end
                    end
                    G_txt = 'ogra=scicos_graphics(' + G_txt + ')';
                    ierr  = execstr(G_txt,'errcatch')
                    if ierr<>0 then
                      error("Problem in convertion of graphics in block.")
                    end
                    o_new.graphics = ogra;
                  //*******************************//

                  //************* model ***********//
                  case 'model' then
                    omod  = o.model;
                    M     = getfield(1,o.model);
                    M_txt = [];
                    for l=2:size(M,2)
                      M_txt = M_txt + M(1,l) + ...
                              "=" + "omod." + M(1,l);
                      if l<>size(M,2) then
                        M_txt = M_txt + ',';
                      end
                    end
                    M_txt = 'omod=scicos_model(' + M_txt + ')';
                    ierr  = execstr(M_txt,'errcatch')
                    if ierr<>0 then
                      error("Problem in convertion of model in block.")
                    end
                    //******** super block case ********//
                     //if omod.sim=='super'|omod.sim=='csuper' then
                     //  rpar=update_scs_m(omod.rpar,version)
                     //  omod.rpar=rpar
                     //end
                    o_new.model = omod;
                  //*******************************//

                  //************* other ***********//
                  else
                    T_txt = "o."+T(k);
                    T_txt = "o_new." + T(k) + "=" + T_txt;
                    ierr  = execstr(T_txt,'errcatch')
                    if ierr<>0 then
                      error("Problem in convertion in objs.")
                    end
                  //*******************************//

                end  //end of select T(k)
              end  //end of for k=
              scs_m_new.objs(j) = o_new;
            //************************************//

            //************** Link ****************//
            case 'Link' then

              T     = getfield(1,o);
              T_txt = [];
              for k=2:size(T,2)
                T_txt = T_txt + T(1,k) + ...
                        "=" + "o." + T(1,k);
                if k<>size(T,2) then
                  T_txt = T_txt + ',';
                end
              end
              T_txt = 'o_new=scicos_link(' + T_txt + ')';
              ierr  = execstr(T_txt,'errcatch')
              if ierr<>0 then
                error("Problem in convertion of link in objs.")
              end
              scs_m_new.objs(j) = o_new;
            //************************************//

            //************** Text ****************//
            case 'Text' then
              o_new = mlist(['Text','graphics','model','void','gui'],...
                            scicos_graphics(),scicos_model(),' ','TEXT_f')

              T     = getfield(1,o);
              T_txt = [];
              for k=2:size(T,2)
                select T(k)
                  //*********** graphics **********//
                  case 'graphics' then
                    ogra  = o.graphics;
                    G     = getfield(1,ogra);
                    G_txt = [];
                    for l=2:size(G,2)
                      G_txt = G_txt + G(1,l) + ...
                              "=" + "ogra." + G(1,l);
                      if l<>size(G,2) then
                        G_txt = G_txt + ',';
                      end
                    end
                    G_txt = 'ogra=scicos_graphics(' + G_txt + ')';
                    ierr  = execstr(G_txt,'errcatch')
                    if ierr<>0 then
                      error("Problem in convertion of graphics in text.")
                    end
                    o_new.graphics = ogra;
                  //*******************************//

                  //************* model ***********//
                  case 'model' then
                    omod  = o.model;
                    M     = getfield(1,o.model);
                    M_txt = [];
                    for l=2:size(M,2)
                      M_txt = M_txt + M(1,l) + ...
                              "=" + "omod." + M(1,l);
                      if l<>size(M,2) then
                        M_txt = M_txt + ',';
                      end
                    end
                    M_txt = 'omod=scicos_model(' + M_txt + ')';
                    ierr  = execstr(M_txt,'errcatch')
                    if ierr<>0 then
                      error("Problem in convertion of model in text.")
                    end
                    //******** super block case ********//
                    //if omod.sim=='super'|omod.sim=='csuper' then
                    //  rpar=update_scs_m(omod.rpar,version)
                    //  omod.rpar=rpar
                    //end
                    o_new.model = omod;
                  //*******************************//

                  //************* other ***********//
                  else
                    T_txt = "o."+T(k);
                    T_txt = "o_new." + T(k) + "=" + T_txt;
                    ierr  = execstr(T_txt,'errcatch')
                    if ierr<>0 then
                      error("Problem in convertion in objs.")
                    end
                  //*******************************//

                end  //end of select T(k)
              end  //end of for k=
              scs_m_new.objs(j) = o_new;
            //************************************//

            //************* other ***********//
            else  // JESAISPASIYADAUTRESOBJS
                  // QUEDESBLOCKSDESLINKETDUTEXTESDANSSCICOS
                  // ALORSICIJEFAISRIEN
              scs_m_new.objs(j) = o;
            //************************************//

          end //end of select typeof(o)

        end //end of for j=
       //*********************************************//

      //** version **//
      case 'version' then
          //do nothing here
          //this should be done later

    end  //end of select  F(i)

  end //end of for i=

  //**update version **//
  //scs_m_new.version = version;
endfunction

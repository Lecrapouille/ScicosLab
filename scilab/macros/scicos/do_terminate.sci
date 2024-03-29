function [alreadyran,%cpr] = do_terminate(scs_m,%cpr)
// Terminate the current simulation
// Ne rend pas la main � l'utilisateur en cas d'erreur
// Copyright INRIA


  //** if sim or and state is not in %cpr
  if prod(size(%cpr))<2 then
    alreadyran = %f ;
    return          ;  //** EXIT
  end

  par = scs_m.props ;

  //** if the simulation have already ran
  //** and is not finished
  if alreadyran then
    alreadyran = %f ;
    state=%cpr.state;

    //** win = xget('window');
    gh_win = gcf();

    //** run scicosim via 'finish' flag
    ierr = execstr('[state,t]=scicosim(%cpr.state,par.tf,par.tf,%cpr.sim,'+..
                   '''finish'',par.tol)','errcatch')

    //** xset('window',win)
    scf(gh_win);

    %cpr ; //get write access at the variable
    %cpr.state = state ;//not always called with second arg

    //**----------------------------------
    if ierr<>0 then
      str_err=split_lasterror(lasterror());
      title_err='End problem.'

      kfun = curblock() ;
      corinv = %cpr.corinv
      if kfun<>0 then  //** block error
        path = corinv(kfun)

        if type(path)==15 then //** modelica block
          spec_err='The modelica block returns the error :';
          message([title_err;spec_err;str_err]);

        else //** all other type of blocks
          obj_path=path(1:$-1)
          spec_err='block'
          blk=path($)
          scs_m_n=scs_m;
          //** check if we can open a window
          //** Note : we can improve that piece of code
          //**        to also returns the name of the comput. func.
          for i=1:size(path,'*')
            if scs_m_n.objs(path(i)).model.sim=='super' then
              scs_m_n=scs_m_n.objs(path(i)).model.rpar;
            elseif scs_m_n.objs(path(i)).model.sim=='csuper' then
              obj_path=path(1:i-1);
              blk=path(i);
              //spec_err='csuper block (block '+string(path(i+1))+')'
              spec_err='csuper block'
              break;
            end
          end
          spec_err='The hilited '+spec_err+' returns the error :';
          //**
          scf(curwin)
          //** call bad_connection
          bad_connection(path,...
                         [title_err;spec_err;str_err],0,1,0,-1,0,1)
        end
      else//** simulateur error
        message(['End problem:';str_err])
      end
    end
    //**---------------------------------

    //** xset('window',curwin)
    scf(curwin);

  end
endfunction

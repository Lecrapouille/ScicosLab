function [x,y,typ]=PDE(job,arg1,arg2)
// Copyright INRIA
// développé par EADS-CCR
// fonction graphic du bloc, elle permet le dessin et l'initialisation du bloc                //
// Reference: "Scicos user guid", http://www.scicos.org                                       //
//--------------------------------------------------------------------------------------------//

x=[];y=[];typ=[]; 

select job
case 'plot' then
  if arg1.model.sim(2)==2004 then 
    CCC=[strsubst(arg1.model.sim(1),'_explicite','');'Explicite']
  elseif arg1.model.sim(2)==12004
    CCC=[strsubst(arg1.model.sim(1),'_implicite','');'implicite']
  else
    CCC='  PDE'
  end
  standard_draw(arg1)
case 'getinputs' then
  [x,y,typ]=standard_inputs(arg1)
case 'getoutputs' then
  [x,y,typ]=standard_outputs(arg1)
case 'getorigin' then
  [x,y]=standard_origin(arg1)
case 'set' then
  x=arg1;  
  graphics=arg1.graphics;label=graphics.exprs
  model=arg1.model;  
  params_pde=label(1);


  while %t do
    [ln,fun]=where();  
    if (fun(3) == "clickin") then // cas standard    

      [nok,a_domaine,b_domaine,discr,signe,choix,type_meth,degre,Nbr_maillage,..
         CI,CI1,CLa_type,CLa_exp,CLb_type,CLb_exp,oper,a1,b1,a2,b2,a3,b3,a4,b4,a5,b5,..
         a6,b6,a7,b7,k,mesures,params_pde]=IHM_EDP(params_pde);
    else
      [nok,a_domaine,b_domaine,discr,signe,choix,type_meth,degre,Nbr_maillage,..
         CI,CI1,CLa_type,CLa_exp,CLb_type,CLb_exp,oper,a1,b1,a2,b2,a3,b3,a4,b4,a5,b5,..
         a6,b6,a7,b7,k,mesures,params_pde]=setvalue_IHM_EDP(params_pde);
    end

    if nok then break,end

    //**********************************
    // Get the name of the file
    //***********************************
    rdnom=label(3)
    if stripblanks(rdnom)==emptystr() then
       global PDE_counter
       if isempty(PDE_counter) then PDE_counter=0,else PDE_counter=PDE_counter+1,end
       rdnom='PDE_'+string(PDE_counter)
    end
    label(3)=rdnom;


    ok=%t
    // arbre de decision
    if (choix == 0) then
      // Choix automatique 
      if is_x_dep([a1;a2;a4]) then 
        if (signe == 1) then
          delta=1;
        elseif (signe == 2) then
          delta=-1;
        elseif (signe == 0) then
          delta=0;
        else
          message(['le discriminant n''est pas constant,'; 'Vous devez choisir son signe dans l''IHM']);
          ok=%f
        end
      else
        delta = delta_eval(a1,a2,a4,%scicos_context)
      end
      if ok then type_meth=arbre_decision(delta); end
    end
    
    if ok then
        // a voir si c'est à rajouter pour ne pas regenerer dans le cas d'eval
        //if ~ok then
        cmdt=["[a_value,b_value,mesures,degre,Nbr_maillage]=stringtoval(a_domaine,b_domaine,mesures,degre,Nbr_maillage,%scicos_context)";
        "[flag_type,rdnom,DF_type,tt]=translate(CI,CI1,CLa_type,CLa_exp,CLb_type,CLb_exp,oper,type_meth,...
              degre,a_value,b_value,Nbr_maillage,a1,b1,a2,b2,a3,b3,a4,b4,a5,b5,a6,b6,a7,b7,rdnom,mesures)"];

        ierr=execstr(cmdt,'errcatch' )
        if ierr<>0 then
            if (fun(3) == "clickin") then 
               message(lasterror())
            else
               disp(lasterror())
            end
            ok=%f
         end
        //else
        //   tt=label(3);
        //end
        if ok then
          // augmentation du systeme avec les noeuds fictifs
          Nbr=Nbr_maillage;
          if ((CLa_type==1) & (DF_type==0 | DF_type==1)) | ((CLb_type==1) & (DF_type==0 | DF_type==2)) then
             Nbr=Nbr+1;
          end 
 
          if isempty(mesures) then
            out=Nbr_maillage;
          else
            out=[Nbr_maillage;size(mesures,'*')];
          end
          if (flag_type == 1) then 
          // explicite
             model.sim=list(rdnom,2004);
             if (find(oper == 1) ~= []) then
               model.state=zeros(2*Nbr_maillage,1);  
             else
               model.state=zeros(Nbr_maillage,1);
             end
          elseif (flag_type == 2) then 
             model.sim=list(rdnom,12004);
             if (find(oper == 1) ~= []) then
                if (type_meth ==3 & (find(oper == 2) ~= [] | find(oper == 4) ~= [])) then
                   model.state=zeros(6*Nbr_maillage,1);
                elseif (type_meth == 1) then
                   model.state=zeros(4*Nbr,1);
                else 
                   model.state=zeros(4*Nbr_maillage,1);
                end
             else
                if (type_meth == 3 & (find(oper == 2) ~= [] | find(oper == 4) ~= [])) then
                  model.state=zeros(4*Nbr_maillage,1);
                elseif (type_meth == 1) then
                  model.state=zeros(2*Nbr,1);
                else
                  model.state=zeros(2*Nbr_maillage,1);
                end
             end
          end

          // Ecriture, compilation et linkage du code
          // if (fun(3) == "clickin") then  
          // always ulink and link 
          [ok]=CFORTREDP(rdnom,tt);
          //end
 
          if ok then
  	   [model,graphics,ok]=..
             set_io(model,graphics,list(ones(k,2),ones(k,1)),list([out(:),ones(out(:))],ones(out(:))),[],[])
           if ok then
             label(1)=params_pde;
             label(2)=tt;
             graphics.exprs=label;
             x.graphics=graphics;
             x.model=model;
             break
           end
          end
        end
    end
    if ~(fun(3) == "clickin") then break,end
  end
  
case 'define' then
  model=scicos_model()
  model.state=zeros(10,1)
  model.sim=list('PDE',0)
  model.in=[1;1;1;1;1]
  model.out=[10;0]
  model.blocktype='c'
  model.dep_ut=[%f %t]

  //initialisation de l'ihm
  params_pde=tlist(['paramspde';'a';'b';'txt_exp';'check_op1';'a1';'b1';'check_op2';'a2';'b2';..
                    'check_op3';'a3';'b3';'check_op4';'a4';'b4';'check_op5';'a5';'b5';'check_op6';'a6';'b6';..
                    'check_op7';'a7';'b7';'discr_cst';'discr_non_cst';'signe';'rad_automatique';'rad_manuel';..
                    'methode';'ord1';'ord2';'ord3';'degre';'nnode';'txt_pas';'CI';'dCI';'CLa';'CLa_exp';'CLb';..
                    'CLb_exp';'points'],"","","",'0',"","IN_EDP1(t)",'0',"","IN_EDP2(t)",'0',"","IN_EDP3(t)",..
                    '0',"","IN_EDP4(t)",'0',"","IN_EDP5(t)",'0',"","IN_EDP6(t)",'0',"","IN_EDP7(t)",'0','0',..
                    '0','0','0','0','','','','','',"","","",'0',"IN_CL1(t)",'0',"IN_CL2(t)","");
  // dans label on mis infos de getvalue, infos ihm et le code C
  label=list(params_pde,[],'');
	gr_i=['txt=CCC;';
        'xstringb(orig(1),orig(2),txt,sz(1),sz(2),''fill'');']
  x=standard_define([4 4],model,label,gr_i)
  
end
endfunction

function delta = delta_eval(a1,a2,a4,%scicos_context)
   %mm=getfield(1,%scicos_context)
   for %mi=%mm(3:$)
      ierr=execstr(%mi+'=%scicos_context(%mi)','errcatch')
      if ierr<>0 then
        break
      end
   end
   delta=evstr(a4)^2-4*evstr(a1)*evstr(a2);
   if isempty(delta) then delta=0; end        
endfunction




function [%a,%b,%c,%d,%e] = stringtoval(%a,%b,%c,%d,%e,%scicos_context)
   %mm=getfield(1,%scicos_context)
   for %mi=%mm(3:$)
      ierr=execstr(%mi+'=%scicos_context(%mi)','errcatch')
      if ierr<>0 then
        break
      end
   end
   %a=evstr(%a)
   %b=evstr(%b)
   %c=evstr(%c)
   %d=evstr(%d)
   %e=evstr(%e)
endfunction


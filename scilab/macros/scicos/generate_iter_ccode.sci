function code=generate_iter_ccode(funname,init_output,nbre_iter,step,iter_var_datatype,ss_input_nbre,model,obj_nbre,exist_output,startingstate,XXmdl,iter_op,cpr)
//Fady 15 Dec 2008
if iter_op=='for' then
  funnam='foriterator'
else
  funnam='whileiterator'
end
iter_pos=findinlistcmd(cpr.sim.funs,funnam,'=')
noz=cpr.sim.ozptr(iter_pos(1)+1)-1
blk_nbre=cpr.cor(obj_nbre)-1

vvv=['Real','','int32','int16','int8'];
vv=['double','','long','short','char'];

//*****************Start of the code************************************
code=[' /* This Code is Generated Automatically for the iterator block */'
    ' /* Date: '+date()+' */'
    ''
    '#include <stdio.h>'
    '#include <memory.h>'
    '#include <string.h>'
    '#include <machine.h>'
    '#include <os_specific/link.h>'
    '#include <scicos/scicos.h>'
    ''
    'void '+funname+'(scicos_block *,int );'
    ''
    'void iter_'+funname+'(scicos_block *block, int flag)'
    ' {'];
//***********************************************************************
//*********************Declarations***************************************
code=[code;
    '  '+vv(iter_var_datatype)+' counter,nbre_iteration,cond;'
    '  '+vv(iter_var_datatype)+' *internalcounter;'];

if startingstate then
  code=[code;
      '  int soz,i;'];
end
//************************************************************************
//*********************Number of iterations********************************
if nbre_iter>=0 then  // the number of iteration is a block parameter
  code=[code;
      '  nbre_iteration='+sci2exp(nbre_iter)+';']
  stepentry='0'; // is used later when the set next i is an input port.
elseif nbre_iter==-1 then  // the number of iteration is unlimitted
  code=[code;
      '  nbre_iteration=2;']
  stepentry='0';
else  // the number of iteration is an input
  stepentry='1';
  code=[code;
      '  nbre_iteration=*Get'+vvv(iter_var_datatype)+'InPortPtrs(block,'+sci2exp(ss_input_nbre)+');']
end
//****************************************************************************
//*****************Updating the counter***************************************
if step==1 then  // when set next i is not selected
  if nbre_iter==-1 then
    code1='      counter=counter+0;'
  else
    code1='      counter=counter+'+sci2exp(step)+';'
  end
else  //set next i is an input 
  blk_nbre=cor(obj_nbre)-1;  // the ForIterator block
  // to get the input of the block for iterator. all the information on the blocks inside the block generated are in the work of the block.
  code1='      counter=*(('+vv(iter_var_datatype)+' *) ((((scicos_block *) *block->work)['+sci2exp(blk_nbre)+']).inptr['+stepentry+']));'
end
//****************************************************************************
//****************************Initial and updated condition ******************
if iter_op=='for' then
  code3=['    cond=1;'];
  code2=[];
elseif iter_op=='do while' then
  code3=['    cond=1;'];
  code2=['    cond=*(('+vv(iter_var_datatype)+' *) ((((scicos_block *) *block->work)['+sci2exp(blk_nbre)+']).inptr[0]));']; 
else
  code3=['    cond=*(('+vv(iter_var_datatype)+' *) ((((scicos_block *) *block->work)['+sci2exp(blk_nbre)+']).inptr[1]));'];
  code2=['    cond=*(('+vv(iter_var_datatype)+' *) ((((scicos_block *) *block->work)['+sci2exp(blk_nbre)+']).inptr[0]));'];
end
//****************************************************************************

code=[code;
    '  if ((flag!=1)&&(flag!=2)){']  // case of flag <>1

//***************************** Case with output******************************
if exist_output then  // when the block ForIterator has an output. 
  code=[code;
      '    if (flag==4){';
	'      '+funname+'(block, flag);'; // calling the block with flag 4.
	'       internalcounter=('+vv(iter_var_datatype)+'*) GetOzPtrs(block,'+sci2exp(noz)+');';
	'       *internalcounter='+sci2exp(init_output)+';';
      '    } else if (flag==5) {';
	'        '+funname+'(block, flag);';
      '    } else {';
	'        '+funname+'(block, flag);}']
  code=[code;
    '  } else if ((flag==1)) {'] // case flag==1;
//****************************Case reset states ************************************
if startingstate then
  code=[code;
      '    '+funname+'(block, 5);']
  if size(XXmdl.dstate,'*')<>0 then
    code=[code;
	'    memcpy(block->z,block->z+GetNdstate(block)/2,GetNdstate(block)/2*sizeof(double));']
  end
  if size(XXmdl.state,'*')<>0 then
    code=[code;
	'    memcpy(block->x,block->x+GetNstate(block)/2,GetNstate(block)/2*sizeof(double));']
  end
  if lstsize(XXmdl.odstate)<>0 then
    code=[code;
	'    for (i=0;i<GetNoz(block)/2;i++) {'
	'      soz=(GetOzSize(block,i+1,1)*GetOzSize(block,i+1,2)*GetSizeOfOz(block,i+1));'
	'      memcpy(*(block->ozptr+i),*(block->ozptr+(GetNoz(block)/2)+i),soz);}']
  end
  code=[code;     
      '    '+funname+'(block, 4);']
  
  //******************************Initialize the reentryflag see CodeGeneration_ ******* 
  nblk=cpr.sim.nb;
  code=[code;'*((int*) ((scicos_block *)(*block->work)+'+string(nblk)+'))=0;']
  //************************************************************************************
end
//************************************************************************************
  code=[code;
      '    internalcounter=('+vv(iter_var_datatype)+' *) GetOzPtrs(block,'+sci2exp(noz)+');';  // get the initial value of the counter.
      '    counter=*internalcounter;';
      code3;
      '   /* nbre_iteration is get from the foriterator block inside this subsystem */';
      '    while ((counter<nbre_iteration+'+sci2exp(init_output)+')&&(cond)) {';
	'      '+funname+'(block, 1);'; // calling the block with flag 1
	'      '+funname+'(block, 2);';	// calling the block with flag 2
	'      /* step is get from the foriterator block inside this subsystem */'] 
    code=[code;code1]  // calculating the step value.
    code=[code;code2;
	'}']
//***********************************************************************************
//************************** Case without output*************************************  
else // the ForIterator block has no output it is only done to have an optimized code.
    code=[code;
	'    '+funname+'(block, flag);']
  code=[code;
    '  } else if (flag==1) {']
//****************************Case reset states ************************************
if startingstate then
  code=[code;
      '    '+funname+'(block, 5);']
  if size(XXmdl.dstate,'*')<>0 then
    code=[code;
	'    memcpy(block->z,block->z+GetNdstate(block)/2,GetNdstate(block)/2*sizeof(double));']
  end
  if size(XXmdl.state,'*')<>0 then
    code=[code;
	'    memcpy(block->x,block->x+GetNstate(block)/2,GetNstate(block)/2*sizeof(double));']
  end
  if lstsize(XXmdl.odstate)<>0 then
    code=[code;
	'    for (i=0;i<GetNoz(block)/2;i++) {'
	'      soz=(GetOzSize(block,i+1,1)*GetOzSize(block,i+1,2)*GetSizeOfOz(block,i+1));'
	'      memcpy(*(block->ozptr+i),*(block->ozptr+(GetNoz(block)/2)+i),soz);}']
  end
  code=[code;     
      '    '+funname+'(block, 4);']
  
  //******************************Initialize the reentryflag see CodeGeneration_ ******* 
  nblk=cpr.sim.nb;
  code=[code;'*((int*) ((scicos_block *)(*block->work)+'+string(nblk)+'))=0;']
  //************************************************************************************
end
//************************************************************************************
  code=[code;
      '  counter='+sci2exp(init_output)+';';
      code3;
      ' /* nbre_iteration is get from the foriterator block inside this subsystem */';
      '    while ((counter<nbre_iteration+'+sci2exp(init_output)+')&&(cond)) {';
      '     '+funname+'(block, 1);';
      '     '+funname+'(block, 2);';
      '     /* step is get from the foriterator block inside this subsystem */']
  
  code=[code;
      code1;
      code2;
      ' }']
  
end
//**********************************************************************************
//*******************************Initialize the counter ******************************
if exist_output then
  code=[code;
      '    *('+vv(iter_var_datatype)+' *) GetOzPtrs(block,'+sci2exp(noz)+')='+sci2exp(init_output)+';'
      '    *(('+vv(iter_var_datatype)+' *) ((((scicos_block *) *block->work)['+sci2exp(blk_nbre)+']).ozptr[0]))='+sci2exp(init_output)+';']
end
//************************************************************************************
//*******************************End of code *****************************************
code=[code;
    ' }'
    '  return;'
    '}']
//************************************************************************************
endfunction

function scs_m=changeinout(scs_m)
port_blocks=['IN_f','INIMPL_f','OUT_f','OUTIMPL_f','CLKIN_f','CLKINV_f','CLKOUT_f','CLKOUTV_f']
for i=1:lstsize(scs_m.objs)
  o=scs_m.objs(i)
  if typeof(o)=='Block' then
    if or(o.gui==port_blocks) then
      o.gui='BIDON'
    end
  end
  scs_m.objs(i)=o;
end
endfunction

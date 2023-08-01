//------------------------------------
// Allan CORNET INRIA 2005
//------------------------------------
lines(0);
MSDOS=(getos()=='Windows');
SCI=getenv('SCI'); 
TMPDIR=getenv('TMPDIR');
//------------------------------------
genlib('scsmodhydraulicslib','SCI/macros/scicos_blocks/ModHydraulics'); 
//------------------------------------


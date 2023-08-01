//------------------------------------
// Allan CORNET INRIA 2005
//------------------------------------
SCI=getenv('SCI'); 
TMPDIR=getenv('TMPDIR');
MSDOS=(getos()=='Windows');
//------------------------------------
genlib('scsnonlinearlib','SCI/macros/scicos_blocks/NonLinear');
//------------------------------------

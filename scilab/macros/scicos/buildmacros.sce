//------------------------------------
// Allan CORNET INRIA 2005
//------------------------------------
SCI=getenv('SCI'); 
TMPDIR=getenv('TMPDIR');
MSDOS=(getos()=='Windows');
//------------------------------------
stacksize(5000000);
genlib('scicoslib','SCI/macros/scicos');
//------------------------------------

//------------------------------------
// Allan CORNET INRIA 2005
//------------------------------------
SCI=getenv('SCI'); 
TMPDIR=getenv('TMPDIR');
MSDOS=(getos()=='Windows');
//------------------------------------
genlib('scsthresholdlib','SCI/macros/scicos_blocks/Threshold');
//------------------------------------

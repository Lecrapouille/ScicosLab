//------------------------------------
// Allan CORNET INRIA 2005
//------------------------------------
lines(0);
MSDOS=(getos()=='Windows');
SCI=getenv('SCI'); 
TMPDIR=getenv('TMPDIR');
//------------------------------------
genlib('scsmodelectricallib','SCI/macros/scicos_blocks/ModElectrical');
//------------------------------------
//if MSDOS then
//  unix("dir /B *.mo >models");
//else
//  unix("ls *.mo >models");
//end


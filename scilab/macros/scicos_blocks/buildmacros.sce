SCI=getenv('SCI'); 
TMPDIR=getenv('TMPDIR');
MSDOS=(getos()=='Windows');
lines(0);
CurrentDirScicosBlocks=pwd();
SubDirsScicosBlocks=["Branching",
		    "Events",
		    "Linear",
		    "Misc",
		    "NonLinear",
		    "Sinks",
		    "Sources",
		    "MatrixOp",
		    "Threshold",
		    "ModHydraulics",
		    "ModElectrical",
		    "ModLinear",
		    "PDE",
		    "IntegerOp",
		    "Iterators"];
 
Dim=size(SubDirsScicosBlocks);
for i=1:Dim(1) do 
  chdir(SubDirsScicosBlocks(i));
  printf("%s\n",'---------- Creation of scicos_block/'+SubDirsScicosBlocks(i)+' (Macros) --------');
  exec('buildmacros.sce');
  chdir(CurrentDirScicosBlocks);
end
clear Dim CurrentDirScicosBlocks SubDirsScicosBlocks

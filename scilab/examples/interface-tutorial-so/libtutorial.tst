tutorial_path=get_file_path('libtutorial.tst');
exec(tutorial_path+'/loader.sce');
//same as "exec tutorial.sce"
A=ones(2,2);B=ones(2,2);
C=matmul(A,B);
if norm(A*B-matmul(A,B)) > %eps then pause,end


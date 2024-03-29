// Demo file for ext4c example 

// builder code for ext4c.c 
link_name = 'ext4c';    // functions to be added to the call table 
flag  = "c";		// ext4c is a C function 
files = ['ext4c.o' ];   // objects files for ext4c 
libs  = [];		// other libs needed for linking 

// the next call generates files (Makelib,loader.sce) used
// for compiling and loading ext4c and performs the compilation

ilib_for_link(link_name,files,libs,flag);

// load new function code in the scope of call 
// using the previously generated loader 
exec loader.sce; 

// test new function through the call function 

a=[1,2,3];b=[4,5,6];n=3;YesOrNo='yes';
c=call('ext4c',n,1,'i',a,2,'d',b,3,'d','out',[1,3],4,'d');
if norm(c-(sin(a)+cos(b))) > %eps then pause,end
YesOrNo='no';
c=call('ext4c',n,1,'i',a,2,'d',b,3,'d','out',[1,3],4,'d');
if norm(c-(a+b)) > %eps then pause,end
//clear yes  --> undefined variable : yes


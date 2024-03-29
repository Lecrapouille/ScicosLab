// Copyright ENPC/INRIA
//--------------test format %i
[n,a]=msscanf('123','%i');
if n<>1|a<>123 then pause,end
[n,a]=msscanf('     123','%i');
if n<>1|a<>123 then pause,end
[n,a]=msscanf('123','%2i');
if n<>1|a<>12 then pause,end
[n,a]=msscanf('123','%5i');
//--------------test format %li
[n,a]=msscanf('123','%li');
if n<>1|a<>123 then pause,end
[n,a]=msscanf('     123','%li');
if n<>1|a<>123 then pause,end
[n,a]=msscanf('123','%2li');
if n<>1|a<>12 then pause,end
[n,a]=msscanf('123','%5li');
//--------------test format %hi
[n,a]=msscanf('123','%hi');
if n<>1|a<>123 then pause,end
[n,a]=msscanf('     123','%hi');
if n<>1|a<>123 then pause,end
[n,a]=msscanf('123','%2hi');
if n<>1|a<>12 then pause,end
[n,a]=msscanf('123','%5hi');
//--------------test format %d
[n,a]=msscanf('123','%d');
if n<>1|a<>123 then pause,end
[n,a]=msscanf('     123','%d');
if n<>1|a<>123 then pause,end
[n,a]=msscanf('123','%2d');
if n<>1|a<>12 then pause,end
[n,a]=msscanf('123','%5d');
//--------------test format %ld
[n,a]=msscanf('123','%ld');
if n<>1|a<>123 then pause,end
[n,a]=msscanf('     123','%ld');
if n<>1|a<>123 then pause,end
[n,a]=msscanf('123','%2ld');
if n<>1|a<>12 then pause,end
[n,a]=msscanf('123','%5ld');
//--------------test format %hd
[n,a]=msscanf('123','%hd');
if n<>1|a<>123 then pause,end
[n,a]=msscanf('     123','%hd');
if n<>1|a<>123 then pause,end
[n,a]=msscanf('123','%2hd');
if n<>1|a<>12 then pause,end
[n,a]=msscanf('123','%5hd');

//------------- test format %n 
// Note that %n returned values are not counted in n 
s1='123 45.67 pipo';s2=' foo';
[n,a,b,c,d,e]=msscanf(s1+s2,'%d%lf%s%n%s');
if n<>4|a<>123|b<>45.67|c<>'pipo'|d<>length(s1)|e<>'foo' then pause,end

//------------- test format %u 
[n,a]=msscanf('+123','%u');
if n<>1|a<>123 then pause,end
[n,a]=msscanf(' 123','%2u');
if n<>1|a<>12 then pause,end
[n,a]=msscanf('+123','%5u');
if n<>1|a<>123 then pause,end
//------------- test format %lu 
[n,a]=msscanf('+123','%lu');
if n<>1|a<>123 then pause,end
[n,a]=msscanf(' 123','%2lu');
if n<>1|a<>12 then pause,end
[n,a]=msscanf('+123','%5lu');
if n<>1|a<>123 then pause,end
//------------- test format %hu 
[n,a]=msscanf('+123','%hu');
if n<>1|a<>123 then pause,end
[n,a]=msscanf(' 123','%2hu');
if n<>1|a<>12 then pause,end
[n,a]=msscanf('+123','%5hu');
if n<>1|a<>123 then pause,end


//------------- test format %o
[n,a]=msscanf('123','%o');
if n<>1|a<>83 then pause,end
[n,a]=msscanf('     123','%o');
if n<>1|a<>83 then pause,end
[n,a]=msscanf('123','%2o');
if n<>1|a<>10 then pause,end
[n,a]=msscanf('123','%5o');
if n<>1|a<>83 then pause,end

//------------- test format %x
rep=10*16^2+11*16+12;
[n,a]=msscanf('0xabc','%x');
if n<>1|a<>rep then pause,end
[n,a]=msscanf('     0xabc','%x');
if n<>1|a<>rep then pause,end
[n,a]=msscanf('abc','%2x');
if n<>1|a<>10*16+11 then pause,end
[n,a]=msscanf('0xabc','%5x');
if n<>1|a<>rep then pause,end

//------------- test format %e
[n,a]=msscanf('123.45','%e');
if n<>1|norm(a-123.45)>1.e-2 then pause,end
[n,a]=msscanf('     123.45','%e');
if n<>1|norm(a-123.45)>1.e-2 then pause,end
[n,a]=msscanf('123.45','%2e');
if n<>1| norm(a-12)>0.1 then pause,end
[n,a]=msscanf('123.45','%5e');
if n<>1|norm(a-123.4)>1.e-1 then pause,end

//------------- test format %le
[n,a]=msscanf('123.45','%le');
if n<>1|a<>123.45 then pause,end
[n,a]=msscanf('     123.45','%le');
if n<>1|a<>123.45 then pause,end
[n,a]=msscanf('123.45','%2le');
if n<>1|a<>12 then pause,end
[n,a]=msscanf('123.45','%5le');
if n<>1|a<>123.4 then pause,end

//------------- test format %f
[n,a]=msscanf('123.45','%f');
if n<>1|norm(a-123.45)>1.e-2 then pause,end
[n,a]=msscanf('     123.45','%f');
if n<>1|norm(a-123.45)>1.e-2 then pause,end
[n,a]=msscanf('123.45','%2f');
if n<>1| norm(a-12)>0.1 then pause,end
[n,a]=msscanf('123.45','%5f');
if n<>1|norm(a-123.4)>1.e-1 then pause,end

//------------- test format %lf
[n,a]=msscanf('123.45','%lf');
if n<>1|a<>123.45 then pause,end
[n,a]=msscanf('     123.45','%lf');
if n<>1|a<>123.45 then pause,end
[n,a]=msscanf('123.45','%2lf');
if n<>1|a<>12 then pause,end
[n,a]=msscanf('123.45','%5lf');
if n<>1|a<>123.4 then pause,end

//------------- test format %s
[n,a]=msscanf('123','%s');
if n<>1|a<>'123' then pause,end
[n,a]=msscanf('     123','%s');
if n<>1|a<>'123' then pause,end
[n,a]=msscanf('123','%2s');
if n<>1|a<>'12' then pause,end
[n,a]=msscanf('123','%5s');
if n<>1|a<>'123' then pause,end

//------------- test format %c
//note that  \n is scaned into \ and n
[n,a,b,c,d]=msscanf(' 12\n','%c%c%c%c');
if n<>4|a<>' '|b<>'1'|c<>'2'|d<>'\' then pause,end
//------------- test format [
[n,a,b]=msscanf('012345abczoo','%[0-9abc]%s');
if n<>2|a<>'012345abc'|b<>'zoo' then pause,end

//------------- test format [
[n,a,b]=msscanf('012345abczoo','%[^c]c%s');
if n<>2|a<>'012345ab'|b<>'zoo' then pause,end

//------------- test ignoring arguments 
[n,a,b]=msscanf('123 4 pipo poo','%*s%s%*s%s');
if n<>2|a<>'4'|b<>'poo' then pause,end

//------------- test [ * ^ 

[n,a]=msscanf('123 4 pipo Xpoo','%*[^X]X%s');
if n<>1|a<>'poo' then pause,end

//------------- test ignoring arguments 
[n,a,b]=msscanf('123 4 pipo poo','%*s%s%*s%s');
//if n<>2|a<>'4'|b<>'poo' then pause,end
//------------- test composed directives 
[n,a]=msscanf('123 4','123%le');
if n<>1|a<>4 then pause,end
[n,a,b,c]=msscanf('xxxxx 4 test 23.45','xxxxx%d%s%le');
if n<>3|a<>4|b<>'test'|c<>23.45 then pause,end
[n,a,b]=msscanf('123 456','%le%le');
if n<>2|a<>123|b<>456 then pause,end

//------------- test mismatch 
[n,a]=msscanf('123 poo','123%le');
if n<>0 then pause,end

//------------- test end-of-file
[n,a]=msscanf('123','123%le');
if n<>-1 then pause,end

//------------- test with matrix scan 

n=5
A=int(10*rand(n,n));
A1=strcat(string(A),' ','c');
F='%d';F=strcat(F(ones(1,n)),' ');
// all lines read as int we scan a 5x5 matrix 
A2=msscanf(-1,A1,F);
if norm(A2-A) > %eps then pause;end 
// read just 2 lines 
A2=msscanf(2,A1,F);
if norm(A2-A(1:2,:)) > %eps then pause;end 
// explicit columns we scan five columns 
[n,a,b,c,d,e]=msscanf(-1,A1,F);
if n<>5 then pause;end 
if norm([a,b,c,d,e]-A) > %eps then pause;end 
// all lines read as int but we scan only 2 columns 
A2=msscanf(-1,A1,'%d%d');
if norm(A2-A(:,1:2)) > %eps then pause;end 

// all lines read as string 
F='%s';F=strcat(F(ones(1,n)),' ');
A2=msscanf(-1,A1,F);
if A2<>string(A) then pause;end 
// read just 2 lines 
A2=msscanf(2,A1,F);
if A2<>string(A(1:2,:))  then pause;end 

// mixed types read column 1 and 2 as string and others as int
Fs='%s';Fs=strcat(Fs(ones(1,2)),' ');
Fd='%d';Fd=strcat(Fd(ones(1,n-2)),' ');
[n,a,b,c,d,e]=msscanf(-1,A1,Fs+' '+Fd);
if n<>5 then pause;end 
if norm([eval(a),eval(b),c,d,e]-A) > %eps then pause;end 

// same example but returned values are compacted in L
L=msscanf(-1,A1,Fs+' '+Fd);
if length(L)<>3 then pause;end 
if norm(getfield(3,L)-A(:,3:n)) > %eps then pause;end 
if getfield(2,L)<>string(A(:,1:2)) then pause;end 

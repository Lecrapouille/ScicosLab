// example 1
x=1

ilib_for_link('foof1','foof1.o',[],"f");
exec('loader.sce');
exec('foof1.sci');
out=foof1(x)

ilib_for_link('fooc1','fooc1.o',[],"c");
exec('loader.sce');
exec('fooc1.sci');
out=fooc1(x)

exec('foos1.sci');
out=foos1(x) 

// example 2

ilib_for_link('foof2','foof2.o',[],"f");exec('loader.sce');
exec('foof2.sci');
out=foof2()

ilib_for_link('fooc2','fooc2.o',[],"c");exec('loader.sce');
exec('fooc2.sci');
out=fooc2()

exec('foos2.sci');
out=foos2()

// example 3
x=2

ilib_for_link('fooc3','fooc3.o',[],"c");exec('loader.sce');
exec('fooc3.sci');
out=fooc3(x)

ilib_for_link('foof3','foof3.o',[],"f");exec('loader.sce');
exec('foof3.sci');
out=foof3(x)

exec('foos3.sci');
out=foos3(x)

// example 4
x=1
y=2

ilib_for_link('foof4','foof4.o',[],"f");exec('loader.sce');
exec('foof4.sci');
out=foof4(x,y)

ilib_for_link('fooc4','fooc4.o',[],"c");exec('loader.sce');
exec('fooc4.sci');
out=fooc4(x,y)

exec('foos4.sci');
out=foos4(x,y)

// example 5
k=2
x=[1,2,3]

ilib_for_link('foof5','foof5.o',[],"f");exec('loader.sce');
exec('foof5.sci');
out=foof5(k,x)

ilib_for_link('fooc5','fooc5.o',[],"c");exec('loader.sce');
exec('fooc5.sci');
out=fooc5(k,x)

exec('foos5.sci');
out=foos5(k,x)

// example 6
k=2
x=[1,2,3;4,5,6]

ilib_for_link('foof6','foof6.o',[],"f");exec('loader.sce');
exec('foof6.sci');
out=foof6(k,x)

ilib_for_link('fooc6','fooc6.o',[],"c");exec('loader.sce');
exec('fooc6.sci');
out=fooc6(k,x)

exec('foos6.sci');
out=foos6(k,x)

// example 7
k=2
x=[1,2,3;4,5,6]

ilib_for_link('foof7','foof7.o',[],"f");exec('loader.sce');
exec('foof7.sci');
out=foof7(k,x)

ilib_for_link('fooc7','fooc7.o',[],"c");exec('loader.sce');
exec('fooc7.sci');
out=fooc7(k,x)

exec('foos7.sci');
out=foos7(k,x)

// example 8

ilib_for_link('foof8','foof8.o',[],"f");exec('loader.sce');
exec('foof8.sci');
out=foof8()

ilib_for_link('fooc8','fooc8.o',[],"c");exec('loader.sce');
exec('fooc8.sci');
out=fooc8()

exec('foos8.sci');
out=foos8()

// example 9

exec('foos9.sci');
out=foos9(1,1,1)

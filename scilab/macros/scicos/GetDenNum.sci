function [N,denom_com]=GetDenNum(v,max_v,dt)
//x=log10(v);
//f=round((min(x)+max(x))/2);
//v=v./10^(f);
//Fady: 15 Dec 2008
v=v/max_v;
[N,D]=rat(v,dt);
denom_com=lcm(uint32(D));
N=uint32(N)*denom_com./uint32(D);
denom_com=max_v/double(denom_com);
//value=gcd(N);
//if f>0 then value=value*10^f;
//else denom_com=double(denom_com)*10^(-f);
//end
//denom_com=(double(denom_com))/max_v;
endfunction

function obfuscate(vecfiles)
   Names=randnames(5000)
   fs=[]
   for files=vecfiles
      fs=[fs;listfiles(files)]
   end
   
   fnames=[];exp1l=[];
   for i=1:size(fs,"*")
     [path,fname,extension]=fileparts(fs(i))
     fnames($+1)=fname
     txt=mgetl(fs(i),-1)
     exp1l=unique([exp1l;findvars(txt)])
   end
   jdel=[]
   for j=1:size(exp1l,"*")
     if execstr("ssdkfqzifdhqzifd="+exp1l(j),"errcatch")==0 then 
       jdel=[jdel,j]
     end
   end
   list_keywords=getscilabkeywords()
   exp1l(jdel)=[]
   for llist=list_keywords
      exp1l=setdiff(exp1l,llist)
   end
   exp1l=setdiff(exp1l,fnames)
   exp2l=Names(1:size(exp1l,"*"))
    
   for i=1:size(fs,"*")
     [path,fname,extension]=fileparts(fs(i))
     filout=path+fname+".Obfuscated"
     txt=mgetl(fs(i),-1)
     txtout=substvar(txt,exp1l,exp2l)
     mputl(txtout,filout)
     exec(filout,-1)
   end
endfunction





function rd=randnames(n)
   dd=["_","1","l"]
   Y=grand(12,2*n,'uin',1,3) 
   rd=[]
   for y=Y
     rd($+1)=strcat(dd(y))
   end
   rd=unique(rd)
   rd="_"+rd(1:n)
endfunction

     


function txtout=substvar(txt,exp1l,exp2l)
//replaces in function foo the list of variable names exp1l
//with the list exp2l
//result is written in goo

if size(exp1l)<>size(exp2l) then error('wrong sizes'),end

txtout=[];

for i=1:size(txt,1)
  txtouti=txt(i)
  for j=1:size(exp1l,'*')
    exp1=exp1l(j),exp2=exp2l(j)
    txtouti=varnumsubst(txtouti,exp1,exp2)
  end
  txtout=[txtout;txtouti]
end

endfunction


function vars=findvars(txt)
vars=[];
for i=1:size(txt,1)
  str=txt(i)
  varsi=findvarsi(str)
  vars=[vars;varsi(:)]
end
endfunction

function varsi=findvarsi(strin)
klen=length(strin)
k=0
varsi=[];strout="";
state=0
while k<klen do

  k=k+1
  ch=part(strin,k)
  if state==0 then
    if isalph(ch)|(ch=="%") then
      if k>1 & isnum(part(strin,k-1)) then  //  1.0D03
         state=0
      else
         state=1
         strout=strout+ch
      end
    elseif or(ch==['''','""'])
      state=3
    end   
  elseif state==1 then
    if isalphnum(ch) then
      strout=strout+ch
    else       
      varsi($+1)=strout
      strout=""
      state=0
    end
  elseif state==3 then
     if or(ch==['''','""']) then state=0,end
  end
end
if state==1 then   
    varsi($+1)=strout
end
endfunction

function strout=varnumsubst(strin,exp1,exp2)
klen=length(strin)
k=0;l=0;strout="";buff="";

state=0;

while k<klen do

  k=k+1
  ch=part(strin,k)

  if state==0 then
    if ch==part(exp1,1) then
      buff=ch
      state=2
    elseif isalph(ch)|(ch=="%") then
      if k>1 & isnum(part(strin,k-1)) then  //  1.0D03
        state=0
        strout=strout+ch
      else
        state=1
        strout=strout+ch
      end
    elseif or(ch==['''','""'])
      strout=strout+ch
      state=3
    else
      strout=strout+ch
    end   
  elseif state==1 then
    if isalphnum(ch) then
      strout=strout+ch
    else       
      strout=strout+ch
      state=0
    end
  elseif state==2
    if length(buff)<length(exp1) then
      if ch==part(exp1,length(buff)+1) then
        buff=buff+ch
      elseif isalphnum(ch) then
        strout=strout+buff+ch
        state=1
      else
        strout=strout+buff+ch
        state=0
      end   
    else  
      if buff==exp1 & ~isalphnum(ch) then
        strout=strout+exp2+ch
        state=0   
      else
        strout=strout+buff+ch
        state=1
      end
    end
  elseif state==3
    if or(ch==['''','""'])
      strout=strout+ch
      state=0
    else
      strout=strout+ch
    end
  end
end
if state==2 then   
      if buff==exp1 then
        strout=strout+exp2
      else
        strout=strout+buff
      end
end
endfunction 
      


function y=isalph(ch)
  ach=ascii(ch)
  y=(ach>64&ach<91)|(ach>96&ach<123)|(ach==95)
endfunction

function y=isalphnum(ch)
  ach=ascii(ch)
  y=(ach>47&ach<58)|isalph(ch)
endfunction

function y=isnum(ch)
  ach=ascii(ch)
  y=(ach>47&ach<58)
endfunction

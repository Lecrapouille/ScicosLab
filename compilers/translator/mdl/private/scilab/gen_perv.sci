load SCI/macros/scicos/lib
load SCI/macros/scicos_blocks/Misc/lib
load SCI/macros/scicos_blocks/Linear/lib
load SCI/macros/scicos_blocks/Nonlinear/lib
load SCI/macros/scicos_blocks/Sources/lib
load SCI/macros/scicos_blocks/Sinks/lib
load SCI/macros/scicos_blocks/Events/lib
load SCI/macros/scicos_blocks/Branching/lib
getd(".");


prob=[];

libs=["scsbranchinglib"
      "scseventslib"
      "scssinkslib"
      "scssourceslib"
      "scslinearlib"
      "scsnonlinearlib"
      "scsmisclib" ];


txt="BlockInterfaces {";

for l=libs'
  sl=string(evstr(l));
  blks=sl(2:$);

  for b=blks'
    ierr=execstr("[params,descr,itemhelps,types]=get_params(b)","errcatch")
    if ierr<>0 then 
       prob=[prob;b]
    else

      ier=execstr("bl="+b+"('"define'")","errcatch");
      if ier==0 then
        ports=[size(bl.graphics.pin,"*"),size(bl.graphics.pout,"*"),..
             size(bl.graphics.pein,"*"),size(bl.graphics.peout,"*")];
      else
        ports=[]
      end

      txtb=" Block {"
      txtb($+1)="       BlockType	'"S-Function'"";
      txtb($+1)="       SourceType	'""+b+"'"";
      txtb($+1)="       SourceBlock	'""+l+"'"";
      txtb($+1)="       Ports    "+sci2exp(ports);
      txtb($+1)="       BlockInterfaceParameters {";
//      ti=1
      for i=1:size(params,"*")
//       partype=types(ti)
         partype="string";
//         if partype=="mat" then ti=ti+3; else ti=ti+2;end
         txtb($+1)="       "+params(i)+" : "+sci2exp(partype);
      end
      txtb($+1)=" }";
      txtb($+1)="}";
      txt=[txt;txtb];
    end
  end
end

txt($+1)="}";
mdelete("scicos_pervasives.mdli")
write('scicos_pervasives.mdli',txt)

function [params,descr,itemhelps,types]=get_params(fun)
 if type(fun)==10 then execstr("fun="+fun),end
lis=macr2lst(fun);

[params,descr,itemhelps,types]=loo(lis)
endfunction




function [vec,descr,itemhelps,types]=loo(lis)
   vec=[],descr=[],itemhelps=[],types=[];
   for i=1:length(lis) 
     l=lis(i)
     if type(l)==15 then 
        [vec,descr,itemhelps,types]=loo(l)
        if vec<>[] then break,end
     else
        if size(l,'*')>1 & l(2)=="getvalue" then
           rep=lis(i+2)
           vec=[];
           cc=2
           for i=size(rep,'*')-3:-2:5
              str=rep(i)
              if rep(i+1)=="1" then 
                 str=str+"."+lis(cc)(2)
                 cc=cc+1
              end
              vec=[vec;str];                 
           end
	   while lis(cc)=="15", cc=cc+1,end
           descr=lis(cc)(2)
           if descr=="Btitre" then break,end
           cc=cc+1
           cci=cc
           while ~(lis(cc)(1)=="2"&lis(cc)(2)=="list"), cc=cc+1,end
           while size(types,"*")/2<size(vec,"*")
               cc=cc-1
               h=lis(cc)
               if h(1)=="3"|h(1)=="6" then
                 types=[h(2);types]
               end
           end
	   while size(itemhelps,"*")<size(vec,"*")
               cc=cc-1
               h=lis(cc)
               if h(1)=="3" then
                 itemhelps=[h(2);itemhelps]
               end
           end

           while lis(cc)=="15"|lis(cc)(1)=="5", cc=cc-1,end
	   for i=cci:cc
              h=lis(i)
              if h(1)=="3" then
                descr=[descr;h(2)]
              end
           end
           break
        end
     end
   end
endfunction


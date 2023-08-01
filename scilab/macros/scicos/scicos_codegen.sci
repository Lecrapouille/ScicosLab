function params=scicos_codegen(v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,...
                               v11,v12,v13,v14,v15,v16,v17,v18,v19,v20)

  if exists('silent','local')==0 then silent=0,end
  if exists('cblock','local')==0 then cblock=0,end
  if exists('rdnom','local')==0 then rdnom=[],end
  if exists('rpat','local')==0 then rpat=[],end
  if exists('libs','local')==0 then libs=[],end
  if exists('opt','local')==0 then opt=1,end
  if exists('enable_debug','local')==0 then enable_debug=0,end
  if exists('scopes','local')==0 then scopes=[], end
  if exists('remove','local')==0 then remove=[], end
  if exists('replace','local')==0 then replace=[],end

  params=mlist(['codegeneration','silent','cblock','rdnom','rpat',...
                'libs','opt','enable_debug','scopes','remove','replace'],...
                silent,cblock,rdnom,rpat,libs,opt,enable_debug,...
                scopes,remove,replace)
endfunction

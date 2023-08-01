function    [bllsti,ok]=do_job_compile(o,bllsti,i)
 bllst_old=bllsti
 x=[]
 ierr=execstr('bllsti='+o.gui+'(""compile"",bllsti,i);','errcatch');
 if ierr==0 then
   if ~isequal(bllsti,[]) then
     //##check input/output size/type
     if ~isequal(bllst_old.in,bllsti.in) |...
         ~isequal(bllst_old.in2,bllsti.in2) |...
         ~isequal(bllst_old.out,bllsti.out) |...
         ~isequal(bllst_old.out2,bllsti.out2) |...
         ~isequal(bllst_old.intyp,bllsti.intyp) |...
         ~isequal(bllst_old.outtyp,bllsti.outtyp) then
       hilite_obj(scs_full_path(corinv(i)))
       message(["Size or type of regular port(s) have changed";
                "during job=compile. Compilation aborted."]);        
       unhilite_obj(scs_full_path(corinv(i)))
       ok=%f;
     elseif ~isequal((isempty(bllst_old.state)&~isequal(bllst_old.blocktype,'x')),..
                     (isempty(bllsti.state)&~isequal(bllsti.blocktype,'x'))) |...
             ~isequal(bllst_old.nzcross==0,bllsti.nzcross==0) |...
             ~isequal(bllst_old.nmode==0,bllsti.nmode==0)|...
             ~isequal((size(bllst_old.dstate,"*")+size(bllst_old.odstate))==0,..
             (size(bllsti.dstate,"*")+size(bllsti.odstate))==0) then
       hilite_obj(scs_full_path(corinv(i)))
       message(["States, zero-crossing or modes have changed in job=compile.";
              "Compilation aborted."]);        
       unhilite_obj(scs_full_path(corinv(i)))
       ok=%f;
     else
       ok=%t
     end
   else
     bllsti=bllst_old
   end
 else
   if isequal(o.gui,'INPUTPORT') | isequal(o.gui,'OUTPUTPORT') | ...
      isequal(o.gui,'INPUTPORTEVTS') | isequal(o.gui,'OUTPUTPORTEVTS') then ok=%t,return,end
   ok=%f,
   hilite_obj(scs_full_path(corinv(i)))
   message(lasterror())
   unhilite_obj(scs_full_path(corinv(i)))
 end

endfunction

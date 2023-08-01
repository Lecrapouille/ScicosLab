function [scs_m] = do_block(%pt,scs_m)
// Copyright INRIA
// do_block - edit a block icon

  //** win = %win; //** just for memo: '%win' is the clicked window

  if Select==[] then //** No object is selected

    xc = %pt(1); yc = %pt(2); %pt=[]; //** acquire mouse coordinate
    K = getblock(scs_m,[xc;yc]) ; //** look from a clicked object
    if K==[] then return, end //** if no object --> EXIT

  else //** if the object is selected

    K = Select(:,1)'; %pt=[]
    //** Filter out the multiple object selected cases
    if size(K,'*')>1|%win<>Select(1,2) then
      message("Only one block can be selected in current window for this operation.") ;
      return ; //** EXIT
    end
  end


  gr_i = scs_m.objs(K).graphics.gr_i ; //** isolate the graphics command string 'gr_i'

  if type(gr_i)==15 then //** ? boh
    [gr_i,coli] = gr_i(1:2)
  else
    coli=[] ;
  end

  if gr_i==[] then gr_i=' ',end

  // Acquire the current clicked window and put to "on" the pixmap mode
  gh_curwin = scf(%win);

  //## set param of scstxtedit
  ptxtedit = scicos_txtedit(clos = 0,...
             typ = "icon",...
             head = ['Give scilab instructions to draw block';
                     'shape.';
                     'orig(1) : block down left corner x coordinate';
                     'orig(2) : block down left corner y coordinate';
                     'sz(1)   : block width';
                     'sz(2)   : block height'])

  while %t do
    [gr_i,Quit] = scstxtedit(gr_i,ptxtedit);

    if ~or(winsid()==%win) then
      message('Diagram has been closed. That icon is no more valid.')
      ptxtedit.clos=1
      [gr_i,Quit] = scstxtedit(gr_i,ptxtedit);
      return,
    end

    if ptxtedit.clos==1 then
       break;
    end

    if gr_i==[] | Quit==1 then return; end ; //** no update : EXIT

    mac = null(); deff('[]=mac()', gr_i, 'n')

    if check_mac(mac) then
      o = scs_m.objs(K)
      o.graphics.gr_i = list(gr_i,coli) ; //** update the graphic command string
      scs_m.objs(K) = o ; //** update the data structure
      o_size = size(gh_curwin.children.children) ;
      gr_k=get_gri(K,o_size(1))
      drawlater() ;
      update_gr(gr_k,o)
      draw(gh_curwin.children);
      show_pixmap() ; //** re-draw the graphic object and show on screen
      //break; //** exit from the while loop
      ptxtedit.clos=1
    end

  end //** of the while(1)

endfunction

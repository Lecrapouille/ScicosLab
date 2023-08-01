function YY=gencblk4(XX,gui_path)

  //@@ get a new CBLOCK4
  YY = CBLOCK4('define')
  exprs = YY.graphics.exprs
  pin   = YY.graphics.pin
  pout  = YY.graphics.pout
  pein  = YY.graphics.pein
  peout = YY.graphics.peout

  //@@ set the graphics
  YY.graphics = XX.graphics
  YY.graphics.exprs = exprs
  YY.graphics.pin   = pin
  YY.graphics.pout  = pout
  YY.graphics.pein  = pein
  YY.graphics.peout = peout

  //@@ load computational function
  [path,fname,extension]=fileparts(gui_path)
  toto=mgetl(path+XX.model.sim(1)+'.c')

  //@@ set the graphics exprs
  YY.graphics.exprs(1)(1) = XX.model.sim(1)
  if XX.model.sim(2)==10004 then
    YY.graphics.exprs(1)(2) = 'y'
  end
  YY.graphics.exprs(1)(3)  = sci2exp([XX.model.in,XX.model.in2],0)
  YY.graphics.exprs(1)(4)  = sci2exp([XX.model.intyp],0)
  YY.graphics.exprs(1)(5)  = sci2exp([XX.model.out,XX.model.out2],0)
  YY.graphics.exprs(1)(6)  = sci2exp([XX.model.outtyp],0)
  YY.graphics.exprs(1)(7)  = sci2exp([XX.model.evtin],0)
  YY.graphics.exprs(1)(8)  = sci2exp([XX.model.evtout],0)
  YY.graphics.exprs(1)(9)  = sci2exp([XX.model.state],0)
  YY.graphics.exprs(1)(10) = sci2exp([XX.model.dstate],0)
  YY.graphics.exprs(1)(11) = sci2exp([XX.model.odstate],0)
  YY.graphics.exprs(1)(12) = sci2exp([XX.model.rpar],0)
  YY.graphics.exprs(1)(13) = sci2exp([XX.model.ipar],0)
  YY.graphics.exprs(1)(14) = sci2exp([XX.model.opar],0)
  YY.graphics.exprs(1)(15) = sci2exp([XX.model.nmode],0)
  YY.graphics.exprs(1)(16) = sci2exp([XX.model.nzcross],0)
  YY.graphics.exprs(1)(17) = sci2exp([XX.model.firing],0)
  if XX.model.dep_ut(1)==%t then
    YY.graphics.exprs(1)(18) = 'y'
  else
    YY.graphics.exprs(1)(18) = 'n'
  end
  if XX.model.dep_ut($)==%t then
    YY.graphics.exprs(1)(19) = 'y'
  else
    YY.graphics.exprs(1)(19) = 'n'
  end
  YY.graphics.exprs(2)=toto

  //@@ run 'set' job of the CBLOCK4
  prot=funcprot()
  funcprot(0)
  getvalue=setvalue;
  deff('message(txt)','x_message(''In block ''+YY.gui+'': ''+txt);global %scicos_prob;%scicos_prob=%t')
  deff('[ok,tt,cancel,'+...
        'libss,cflags] =  CC4(funam,tt,i,o,libss,cflags)','ok=%t,cancel=%f')
  %scicos_prob = %f

  YY = CBLOCK4('set',YY)
  funcprot(prot)

endfunction

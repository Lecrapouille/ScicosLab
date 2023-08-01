function txt=addDiscretePulseGenerato(txt,para,nin,nout)

	PulseType= para.PulseType
	TimeSource= para.TimeSource
	Amplitude= para.Amplitude
	Period= para.Period
	PulseWidth= para.PulseWidth
	PhaseDelay= para.PhaseDelay
	SampleTime= para.SampleTime

if PulseType~="Time based" then
   diagName="Pulse Generator"

   context='//   DiscretePulseGenerator'
   paras=getfield(1,para)
   np=size(paras,"*")-2
   for ii=1:np
       context(ii+1)=paras(2+ii)+"="+sci2exp(para(paras(2+ii)),0)
   end
   txt($+1)=ID+"%blk=instantiate_block(""SUPER_f"")"
   txt=create_empty_scsm1(txt,nin,nout,context,diagName)
   txt($+1)=ID+"%blk=fill_superblock(%blk,scsm1)"
   warning('DiscretePulseGenerator: Non Time based Pulse type not supporte.')

elseif TimeSource=="0" then
      txt($+1)=ID+"%blk=instantiate_block('"PULSE_SD'")"
      txt($+1)=ID+'%exprs='+sci2exp([PhaseDelay;PulseWidth;Period;Amplitude],0)
      txt($+1)=ID+"%blk=set_block_parameters(%blk,%exprs)"
else

txt($+1)=ID+"%blk=instantiate_block(""SUPER_f"")"
txt($+1)=ID+"%blk.graphics.gr_i(1)="" """
txt($+1)=ID+"scsm0=instantiate_diagram()"
txt($+1)=ID+"scsm0=set_diag_bkgcolor(scsm0,8)"
txt($+1)=ID+"scsm0 = set_diagram_location(scsm0,[172,298,602,628],1)"

txt($+1)=ID+"%blk0=instantiate_block(""OUT_f"")"
txt($+1)=ID+"%blk0=set_block_bkgcolor(%blk0,8)"
txt($+1)=ID+"%blk0=set_block_flip(%blk0,%t)"
txt($+1)=ID+"%blk0=set_block_ident(%blk0,''"")"
txt($+1)=ID+"%blk0=set_block_orig(%blk0,[452.00186,54.575273])"
txt($+1)=ID+"%blk0=set_block_sz(%blk0,[30;15])"
txt($+1)=ID+"%blk0=set_block_theta(%blk0,0)"
txt($+1)=ID+"%exprs=.."
txt($+1)=ID+"""1"""
txt($+1)=ID+"%blk0=set_block_parameters(%blk0,%exprs)"
txt($+1)=ID+"[scsm0,%l] = add_block(scsm0,%blk0)"

txt($+1)=ID+"%blk0=instantiate_block(""PULSE_SD"")"
txt($+1)=ID+"%blk0=set_block_bkgcolor(%blk0,8)"
txt($+1)=ID+"%blk0=set_block_flip(%blk0,%t)"
txt($+1)=ID+"%blk0=set_block_ident(%blk0,''"")"
txt($+1)=ID+"%blk0=set_block_orig(%blk0,[313.38984,42.075273])"
txt($+1)=ID+"%blk0=set_block_sz(%blk0,[60,40])"
txt($+1)=ID+"%blk0=set_block_theta(%blk0,0)"
txt($+1)=ID+"%exprs=.."
txt($+1)=ID+sci2exp([PhaseDelay;PulseWidth;Period;Amplitude],0)
txt($+1)=ID+"%blk0=set_block_parameters(%blk0,%exprs)"
txt($+1)=ID+"[scsm0,%l] = add_block(scsm0,%blk0)"

txt($+1)=ID+"scsm0 = add_explicit_link(scsm0,[2,1],[1,1],[])"

txt($+1)=ID+"%blk0=instantiate_block(""VirtualCLK0"")"
txt($+1)=ID+"%blk0=set_block_bkgcolor(%blk0,8)"
txt($+1)=ID+"%blk0=set_block_flip(%blk0,%t)"
txt($+1)=ID+"%blk0=set_block_ident(%blk0,''"")"
txt($+1)=ID+"%blk0=set_block_orig(%blk0,[247.67726,91.721818])"
txt($+1)=ID+"%blk0=set_block_sz(%blk0,[40,40])"
txt($+1)=ID+"%blk0=set_block_theta(%blk0,0)"
txt($+1)=ID+"%exprs=.."
txt($+1)=ID+"[]"
txt($+1)=ID+"%blk0=set_block_parameters(%blk0,%exprs)"
txt($+1)=ID+"[scsm0,%l] = add_block(scsm0,%blk0)"

txt($+1)=ID+"%blk0=instantiate_block(""SampleCLK"")"
txt($+1)=ID+"%blk0=set_block_bkgcolor(%blk0,8)"
txt($+1)=ID+"%blk0=set_block_flip(%blk0,%t)"
txt($+1)=ID+"%blk0=set_block_ident(%blk0,''"")"
txt($+1)=ID+"%blk0=set_block_orig(%blk0,[237.67726,171.10485])"
txt($+1)=ID+"%blk0=set_block_sz(%blk0,[60,40])"
txt($+1)=ID+"%blk0=set_block_theta(%blk0,0)"
txt($+1)=ID+"%exprs=.."
txt($+1)=ID+sci2exp([SampleTime;"0"],0)
txt($+1)=ID+"%blk0=set_block_parameters(%blk0,%exprs)"
txt($+1)=ID+"[scsm0,%l] = add_block(scsm0,%blk0)"
txt($+1)=ID+"scsm0 = add_event_link(scsm0,[5,1],[4,1],[])"
   
txt($+1)=ID+"%blk=fill_superblock(%blk,scsm0)"

end
endfunction

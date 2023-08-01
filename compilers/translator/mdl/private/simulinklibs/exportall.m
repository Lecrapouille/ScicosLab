interface_file_name='mdl_pervasives.mdli';
interface_keyword='BlockInterfaces';

builtin_source_type='Simulink';

txt=cell(1);indx=1;
simulink;
libs={'cstblocks','cstextras','simulink_extras/Additional Discrete','simulink_extras/Additional Linear','simulink_extras/Flip Flops','simulink_extras/Additional Sinks','simulink/Additional Math & Discrete','simulink/Additional Math & Discrete/Additional Discrete','simulink/Continuous','simulink/Discontinuities','simulink/Discrete','simulink/Logic and Bit Operations','simulink/Lookup Tables','simulink/Math Operations','simulink/Ports & Subsystems','simulink/Signal Routing','simulink/Signal Attributes','simulink/Sinks','simulink/Sources','simulink/User-Defined Functions','simulink/Math Operations','simulink/Model Verification'};

for i=1:size(libs,2)
    libsimu=libs{i};

b5=sprintf('%s\t', '');

blks=find_system(libsimu,'Type','block');

for blk = blks'

    typ = get_param(blk,'BlockType');
    bt=typ{1};
    masktype=get_param(blk,'MaskType');
    mt=masktype{1};

    if ~(isequal(bt,'SubSystem') & isequal(mt,''))

      txt{indx}='Block {';
      indx=indx+1;
%      typ = get_param(blk,'BlockType');
%      bt=typ{1};

      if ~isempty(findstr(bt,'-'))
          bt=['"',bt,'"'];
      end

      txt{indx}=[b5,'BlockType',b5,bt];
      indx=indx+1;

%      masktype=get_param(blk,'MaskType');

      if isequal(mt,''), mt=builtin_source_type; else mt=['"',mt,'"'];end

      txt{indx}=[b5,'SourceType',b5,mt];
      indx=indx+1;

      blk1=blk{1};
      while 1,idx=findstr(blk1,10);
          if isempty(idx),break,end,
          blk1=[blk1(1:idx(1)-1),'\n',blk1(idx(1)+1:end)];
      end
      txt{indx}=[b5,'SourceBlock',b5,'"',blk1,'"'];
      indx=indx+1;

      ph=get_param(blk,'PortHandles');
      Ports=[];
      Ports(1)=size(ph{1}.Inport,2);
      Ports(2)=size(ph{1}.Outport,2);
      Ports(3)=size(ph{1}.Enable,2);
      Ports(4)=size(ph{1}.Trigger,2);
      Ports(5)=size(ph{1}.State,2);
      Ports(6)=size(ph{1}.LConn,2);
      Ports(7)=size(ph{1}.RConn,2);
      Ports(8)=size(ph{1}.Ifaction,2);
      while ~isempty(Ports) & Ports(end)==0, Ports(end)=[];end
      PortsString='[';
      for p=Ports(1:end-1)
          PortsString=[PortsString,num2str(p),','];
      end
      if isempty(Ports), pend=[]; else pend= num2str(Ports(end));end
      PortsString=[PortsString,pend,']'];
      txt{indx}=[b5,'Ports',b5,PortsString];
      indx=indx+1;

      txt{indx}=[b5,'BlockInterfaceParameters {'];
      indx=indx+1;
      s=get_param(blk,'DialogParameters');
      if ~isempty(s{1}),p=fieldnames(s{1});else p=[];end
      for n=1:size(p,1)
          para=p(n);para=para{1};
          typ = getfield(s{1},para);
          txt{indx} = [b5,para,' : "',typ.Type,'"'];
          indx=indx+1;
      end
      txt{indx}=' }';
      indx=indx+1;
      txt{indx}='}';
      indx=indx+1;
    end
  end
end

fid = fopen(interface_file_name,'w');
fprintf (fid, '%s\n', [interface_keyword, ' {'] );
for i=1:size(txt,2)
  fprintf(fid,'%s\n',txt{i});
end
fprintf (fid, '%s\n', '}' );
fclose(fid);

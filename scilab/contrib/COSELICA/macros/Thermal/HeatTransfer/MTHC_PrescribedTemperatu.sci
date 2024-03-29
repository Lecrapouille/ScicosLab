// Coselica Toolbox for Scicoslab
// Copyright (C) 2009, 2010  Dirk Reusch, Kybernetik Dr. Reusch
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.

function [x,y,typ]=MTHC_PrescribedTemperatu(job,arg1,arg2)
x=[];y=[];typ=[];
select job
  case 'plot' then
    standard_draw(arg1,%f,_MTH_PrescribedTemp_dp);
  case 'getinputs' then
    [x,y,typ]=_MTH_PrescribedTemp_ip(arg1);
  case 'getoutputs' then
    [x,y,typ]=_MTH_PrescribedTemp_op(arg1);
  case 'getorigin' then
    [x,y]=standard_origin(arg1);
  case 'set' then
    x=arg1;
  case 'define' then
    model=scicos_model();
    model.sim='Coselica';
    model.blocktype='c';
    model.dep_ut=[%t %f];
    mo=modelica();
      mo.model='Modelica.Thermal.HeatTransfer.Celsius.PrescribedTemperature';
      mo.inputs=['T'];
      mo.outputs=['port'];
      mo.parameters=list([],list(),[]);
    model.equations=mo;
    model.in=ones(size(mo.inputs,'*'),1);
    model.out=ones(size(mo.outputs,'*'),1);
    exprs=[];
    gr_i=[...
          'if orient then';...
          '  xx=orig(1);yy=orig(2);';...
          '  ww=sz(1);hh=sz(2);';...
          'else';...
          '  xx=orig(1)+sz(1);yy=orig(2);';...
          '  ww=-sz(1);hh=sz(2);';...
          'end';...
          'if orient then';...
          '  xrect(orig(1)+sz(1)*0,orig(2)+sz(2)*1,sz(1)*1,sz(2)*1);';...
          'else';...
          '  xrect(orig(1)+sz(1)*(1-0-1),orig(2)+sz(2)*1,sz(1)*1,sz(2)*1);';...
          'end';...
          'e=gce();';...
          'e.visible=""on"";';...
          'e.foreground=color(0,0,0);';...
          'e.background=color(159,159,223);';...
          'e.fill_mode=""on"";';...
          'e.thickness=0.25;';...
          'e.line_style=0;';...
          'xpoly(xx+ww*[-0.01;0.82],yy+hh*[0.5;0.5]);';...
          'e=gce();';...
          'e.visible=""on"";';...
          'e.foreground=color(191,0,0);';...
          'e.thickness=0.5;';...
          'e.line_style=1;';...
          'if orient then';...
          '  xstringb(orig(1)+sz(1)*0,orig(2)+sz(2)*0,""�C"",sz(1)*0.5,sz(2)*0.5,""fill"");';...
          'else';...
          '  xstringb(orig(1)+sz(1)*(1-0-0.5),orig(2)+sz(2)*0,""�C"",sz(1)*0.5,sz(2)*0.5,""fill"");';...
          'end';...
          'e=gce();';...
          'e.visible=""on"";';...
          'e.foreground=color(0,0,255);';...
          'e.background=color(0,0,0);';...
          'e.font_foreground=color(0,0,0);';...
          'e.fill_mode=""off"";';...
          'if orient then';...
          '  xstringb(orig(1)+sz(1)*-0.11,orig(2)+sz(2)*1.015,""""+model.label+"""",sz(1)*1.2,sz(2)*0.3,""fill"");';...
          'else';...
          '  xstringb(orig(1)+sz(1)*(1--0.11-1.2),orig(2)+sz(2)*1.015,""""+model.label+"""",sz(1)*1.2,sz(2)*0.3,""fill"");';...
          'end';...
          'e=gce();';...
          'e.visible=""on"";';...
          'e.foreground=color(0,0,255);';...
          'e.background=color(0,0,255);';...
          'e.font_foreground=color(0,0,255);';...
          'e.fill_mode=""on"";';...
          'xpoly(xx+ww*[-0.01;0.82],yy+hh*[0.5;0.5]);';...
          'e=gce();';...
          'e.visible=""on"";';...
          'e.foreground=color(191,0,0);';...
          'e.thickness=0.5;';...
          'e.line_style=1;';...
          'xpoly(xx+ww*[0.76;0.76;0.95;0.76],yy+hh*[0.4;0.6;0.5;0.4]);';...
          'e=gce();';...
          'e.visible=""on"";';...
          'e.foreground=color(191,0,0);';...
          'e.background=color(191,0,0);';...
          'e.fill_mode=""on"";';...
          'e.thickness=0.25;';...
          'e.line_style=1;';...
         ];

    x=standard_define([2 2],model,exprs,list(gr_i,0));
    x.graphics.in_implicit=['E'];
    x.graphics.out_implicit=['I'];
  end
endfunction

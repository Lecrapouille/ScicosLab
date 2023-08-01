mode(-1);
//
// -------------------------------------------------------------------------
// SIVP - Scilab Image Processing toolbox
// Copyright (C) 2005  Shiqi Yu
// Copyright (C) 2002  Ricardo Fabbri
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
// -------------------------------------------------------------------------
//

// specific part
libname='libsivp'
libtitle='SIVP - Scilab Image and Video Processing Toolbox 0.5.0';

write(%io(2), libtitle);

SIVP_PATH=get_absolute_file_path('loader.sce');

// load the library macros
execstr(libname+'=lib(""'+SIVP_PATH+'macros/'+'"")')

// add the help chapter
scilab_version=getversion();
if %t then 
   add_help_chapter(libtitle,SIVP_PATH+'/man');
else
   //scilab 5
   path_addchapter = SIVP_PATH + "jar/";
   if ( fileinfo(path_addchapter) <> [] ) then
      add_help_chapter(libtitle, path_addchapter, %F);
      clear add_help_chapter;
   end
end

// add demos to demos menu
global demolist;
have_sivp = 0;
for num=1:size(demolist, 1),
	if demolist(num,1)=='SIVP' then
		have_sivp = 1;
	end
end
if have_sivp==0 then
	demolist = [demolist; 'SIVP', SIVP_PATH+'/demos/sivp.dem'];
end
clear have_sivp num;

functions=[    'sivptest'; 		       'sivp_init'; 		       'imread';		       'int_imwrite';		       'imfinfo'; 		       'aviinfo';		       'aviopen';		       'camopen';		       'avifile';		       'aviclose';		       'avicloseall';		       'avilistopened';		       'avireadframe';		       'addframe';		       'int_imresize';		       'int_imabsdiff';		       'int_imadd'; 		       'int_imsubtract'; 		       'int_immultiply'; 		       'int_imdivide'; 		       'imfilter'; 		       'filter2'; 		       'mat2utfimg'; 		       'int_canny'; 		       'int_sobel'; 		       'int_cvtcolor'; 		       'ind2rgb'; 		       'detectobjects'; 		       'camshift'; 		       'meanshift';		       'detectforeground';		       'impyramid';		   ];

if MSDOS then 
	// load the OpenCV dlls for Windows version
	OpenCV= SIVP_PATH + 'lib\';
	link(OpenCV + 'libguide40.dll');
	link(OpenCV + 'cxcore100.dll');
	link(OpenCV + 'cv100.dll');
	link(OpenCV + 'highgui100.dll');

	addinter(SIVP_PATH+'lib\libsivp.dll','libsivp',functions);
else
	addinter(SIVP_PATH+'lib/libsivp.so','libsivp',functions);
end

sivp_init(SIVP_PATH);

clear functions;
clear libname;
clear libtitle;

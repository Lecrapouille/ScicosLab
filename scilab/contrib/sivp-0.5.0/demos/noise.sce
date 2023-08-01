sts=stacksize(); if (sts(1)<10000000) then, stacksize(10000000);end;
filename = SIVP_PATH + 'images/lena.png';
if MSDOS then filename=strsubst(filename,'/','\'),end
im=imread(filename);               
imn = imnoise(im, 'gaussian');
imshow(imn);

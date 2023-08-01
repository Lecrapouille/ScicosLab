filename = SIVP_PATH + '/images/lena.png';
if MSDOS then filename=strsubst(filename,'/','\'),end
im=imread(filename);               
imc=edge(rgb2gray(im),'canny');
imshow(imc);

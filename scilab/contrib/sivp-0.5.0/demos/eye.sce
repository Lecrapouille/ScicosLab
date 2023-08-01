filename = SIVP_PATH + '/images/lena.png';
if MSDOS then filename=strsubst(filename,'/','\'),end
im = imread(filename);
face = detectfaces(im);

rrect = face .* [1,1,0.7,0.6];
subface = imcrop(im, rrect);
reyes = detectrighteyes(subface);

lrect = face * [1,0,0,0; 0,1,0,0; 0.3,0,0.7,0; 0,0,0,0.6];
subface = imcrop(im, lrect);
leyes = detectlefteyes(subface);


[m,n] = size(reyes);
for i=1:m,  
    im = rectangle(im, reyes(i,:)+rrect.*[1,1,0,0], [0,255,0]);
end;
[m,n] = size(leyes);
for i=1:m,  
    im = rectangle(im, leyes(i,:)+lrect.*[1,1,0,0] , [0,0,255]);
end;

imshow(im);    

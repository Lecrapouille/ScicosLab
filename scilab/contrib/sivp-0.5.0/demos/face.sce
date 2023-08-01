sts=stacksize(); if (sts(1)-sts(2)<10000000) then, stacksize(sts(2)+10000000);end;
filename = SIVP_PATH + '/images/people.jpg';
if MSDOS then filename=strsubst(filename,'/','\'),end
im = imread(filename);
face = detectfaces(im);
[m,n] = size(face);
for i=1:m,
    im = rectangle(im, face(i,:), [0,255,0]);
end;
imshow(im);    

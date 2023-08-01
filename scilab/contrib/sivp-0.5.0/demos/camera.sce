r=x_message(['Do you really have a camera?'],['Yes','No']);

if r==1
  n = camopen();
  for idx=1:100,
    im=avireadframe(n);
    imshow(im);
  end;
  aviclose(n);
end

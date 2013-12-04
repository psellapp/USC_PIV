function err = write_raw(fname,img)
% usage: err = write_raw(fname,img)% writes an 8-bit raw image file% fname = name of the output raw image file% img = image to write to file
fid = fopen(fname,'w');
if fid > 2    err = 0;    imgdata = reshape(img',[prod(size(img)) 1]);%    size(imgdata)    fwrite(fid,imgdata,'uint8');    fclose(fid);else    err = 1;end

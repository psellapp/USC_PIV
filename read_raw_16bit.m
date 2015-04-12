function [img,err] = read_raw_16bit(fname,nx,ny)

% usage: img = read_raw(fname,nx,ny) Reads in a 16-bit raw image file, and
% formats to display properly using imshow
% 
% created: Prabu, 4/12/2015
% 
% fname = name of the raw image file nx, ny = number of pixels in the x and
% y directions

fid = fopen(fname);

if fid > 2
    err = 0;
    imgdata = fread(fid,'*uint16');
%   size(imgdata)
    fclose(fid);
    imgdata = (reshape(imgdata,[nx,ny]))';
    img=imgdata;
%    img = imgdata(ny:-1:1,:);
else
    err = 1;
    img=[];
end


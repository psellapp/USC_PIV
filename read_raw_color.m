function [img,err] = read_raw_color(fname,nx,ny)

% usage: [img,err] = read_raw_color(fname,nx,ny)
% created : Prabu Sellappan, 7/5/2012. 
% reads in a raw image file containing RGB data, and formats to display properly using imshow
% fname = name of the raw image file
% nx, ny = number of pixels in the x and y directions

fid = fopen(fname);

if fid > 2
    err = 0;
    imgdata = fread(fid,'*uint8');
    fclose(fid);
    img=zeros(ny,nx,3,'uint8');
    img(:,:,1) = (reshape(imgdata(1:3:end-2),[nx,ny]))';
    img(:,:,2) = (reshape(imgdata(2:3:end-1),[nx,ny]))';
    img(:,:,3) = (reshape(imgdata(3:3:end),[nx,ny]))';
else
    err = 1;
    img=[];
end

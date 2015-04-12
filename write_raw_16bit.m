function err = write_raw_16bit(fname,img)

% usage: err = write_raw_16bit(fname,img) writes an 16-bit raw image file
% Data type is uint16
% 
% created: Prabu, 4/12/2015
% 
% fname = name of the output raw image file 
% img = image to write to file

fid = fopen(fname,'w');

if fid > 2
    err = 0;
    imgdata = reshape(img',[numel(img) 1]);
%    size(imgdata)
    fwrite(fid,imgdata,'uint16');
    fclose(fid);
else
    err = 1;
end
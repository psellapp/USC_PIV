function [err] = convert_tiff_to_raw(fileNameTIFF,fileNameRAW,deleteTIFF_flag)

% Convert TIFF files to RAW (8-bit uint) 
% Created: Prabu Sellappan, 11/07/2012
% 
% fileNameTIFF - name of TIFF file without extension; fileNameRAW - name of
% RAW file without extension. Can be same as fileNameTIFF.
% deleteTIFF_flag - 0 to keep the TIFF file, 1 to delete the TIFF file

img = imread([fileNameTIFF '.tiff']);

fid = fopen([fileNameRAW '.raw'],'w');

if fid > 2
    err = 0;
    imgdata = reshape(img',[numel(img) 1]);
%    size(imgdata)
    fwrite(fid,imgdata,'uint8');
    fclose(fid);
else
    err = 1;
end
if deleteTIFF_flag
    delete([fileNameTIFF '.tiff']);
end

end

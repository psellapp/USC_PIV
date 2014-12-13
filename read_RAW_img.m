   function [imgMat]= read_RAW_img(filename,nx,ny,xmin,xmax,ymin,ymax,img_precision)
%   read_RAW_img   Reads in RAW image file, crops the image, 
%                and outputs image data in Matlab readable format with double precision
% 
%  Created: Prabu Sellappan, 12/10/2014
%  modified: Prabu, 12/12/2014
%            Changed output data precision to double irrespective of input.
%            -xcorr2 complains if it's not double.
%            -Might need to think about the consequences of this change
% 
%  INPUT PARAMETERS
%  filename - Name of RAW file to be read into memory
%  nx, ny  -  Number of pixels in the x and y directions
%  xmin,xmax,ymin,ymax - vertices of cropped image (Matlab row(y)-column(x) format with (1,1) at top-left corner)
%  img_precision - precision of input image; if empty, defaults to 'uint8'
%
%  OUTPUT PARAMETERS
%  imgMat   - 2-D array containing the grayscale values from RAW file.


%   =========set correct img_precision===========
    if nargin == 8
        if ~ischar(img_precision)
        error('Provide string input for img_precision or leave empty to default to uint8');
        end
    end
    if nargin==7
        img_precision='uint8';
    end
%    img_precision=['*' img_precision]; %so that input and output have same precision
%   =============================================

    fid = fopen(filename);
    if (fid<3)
    error('Cannot open image file. Check file path');
    end
    imgdat = fread(fid,img_precision);
    fclose(fid);
    imgdata = (reshape(imgdat,[nx,ny]))';
    imgMat = imgdata((ymin:ymax),(xmin:xmax)); 
    end
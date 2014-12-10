function [fstatus] = ensemblePIV(fname,fnameindexStart,fnameindexEnd,ensSize,XimgSize,YimgSize,xintwinSize,yintwinSize,xmin,xmax,ymin,ymax)
%  ensemblePIV     Perform DPIV processing of RAW image files 
%                  using the ensemble correlation method.
%                  Matlab Signal Processing Toolbox is required.
%
%  created: Prabu Sellappan, 12/5/2014
%
%  
%  OUTPUT PARAMETERS
% 
%  fstatus - Output value. Takes a value of either 1 or 0 depending on 
%            whether the function completed successfully(1) or failed(0).
% 
%  INPUT PARAMETERS
% 
%  fname   - Placeholder for input filename. 
%               eg. If your image files are named test_filename_23.raw,
%               test_filename_24.raw,etc., then  fname = 'test_filename_'
% 
%  fnameindexStart - Starting index value of files to be processed.
% 
%  fnameindexEnd - Ending index value of files to be processed.
% 
%  nFiles  - Total number of image files to be processed.
% 
%  ensSize - Size of ensemble. Number of image files, not image pairs, in each ensemble. 
% 
%  XimgSize - Horizontal length of input RAW image in pixels.
% 
%  YimgSize - Vertical length of input RAW image in pixels.
% 
%  xintwinSize - Size of interrogation window in pixels along x-axis.
% 
%  yintwinSize - Size of interrogation window in pixels along y-axis.
% 
%  xmin,xmax,ymin,ymax - x and y limit boundaries in pixels, used to crop images. 
%                        Use xmin=1,xmax=XimgSize,ymin=1,ymax=YimgSize if
%                        you want to process the entire image without
%                        cropping.
% 

nFiles=fnameindexEnd-fnameindexStart+1;
XSize=xmax-xmin+1; % XSize,Ysize - Size of image along x and y axis, that is actually processed
YSize=ymax-ymin+1;
if rem(nFiles,2)==1
    fstatus=0;
    error('Number of input files(nFiles) is odd. Number of RAW image files (nFiles) has to even in order to form image pairs');
elseif rem(ensSize,2)==1
    fstatus=0;
    error('Input parameter (ensSize) is odd. Number of RAW images in each ensemble (ensSize) has to be even in order to form image pairs');
elseif rem(YSize,yintwinSize)~=0
    warning('Check size of interrogation window along y-axis. Some part of image might not be processed'); 
elseif rem(XSize,xintwinSize)~=0
    warning('Check size of interrogation window along x-axis. Some part of image might not be processed'); 
elseif ensSize>nFiles
    fstatus=0;
    error('Ensemble size is larger than total number of images available');
end

if rem(nFiles,ensSize)~= 0
    warning('Some RAW image files towards the end will not be processed. This is due to the ensemble size');
    warning('If a complete ensemble set cannot be formed then, the files in the last, incomplete ensemble are discarded');
end

nensSets = floor(nFiles/ensSize);
% nensSets - Number of ensemble sets. 
% Depends on the ensemble size. If a complete ensemble set cannot be formed then the
% remaining files at the end are not processed. 
% 
imgFilenum=fnameindexStart;
% imgFilenum - variable used to increment through filename index inside
%              loop.

for i=1:nensSets
    phi=zeros(((2*xintwinSize)-1),((2*yintwinSize)-1),(XSize/xintwinSize),(YSize/yintwinSize));
    
%     Pre-allocate displacement arrays deltax(:,:) and deltay(:,:). These arrays
%     contain the x and y displacements obtained by peak locating.

    deltax=zeros(floor(YSize/yintwinSize),floor(XSize/xintwinSize));
    deltay=zeros(floor(YSize/yintwinSize),floor(XSize/xintwinSize));

    for j=1:(ensSize/2)
%        tic;
% The loop variable j goes from 1 to (ensSize/2) since both images A and B
% are read into memory inside this loop to form the image pair. 
        filename1 = int2str(imgFilenum);
        filename2 = '.raw';
        filename = [fname,filename1,filename2];
%          Image A is read into memory by calling subfunction readRAWimg
        imgA = readRAWimg(filename,XimgSize,YimgSize,xmin,xmax,ymin,ymax);
        imgFilenum = imgFilenum + 1;
        filename1 = int2str(imgFilenum);
        filename2 = '.raw';
        filename = [fname,filename1,filename2];
%          Image B is read into memory by calling subfunction readRAWimg
        imgB = readRAWimg(filename,XimgSize,YimgSize,xmin,xmax,ymin,ymax);
        imgFilenum = imgFilenum + 1;
% %         ###############################
% %         Debugging code for testing phase - Ignore!! 
%         im1=imgA; im2=imgB;
%         fstatus=1;
% %         ###############################
        kk=1;
        
        for k=1:floor(XSize/xintwinSize)
            ll=1;
            for l=1:floor(YSize/yintwinSize)
% This loop calls the subfunction crosscorr and sends in the same
% interrogation windows from images A and B as input parameters. 
%  CALL CROSS CORRELATION FUNCTION . 

                phi(:,:,k,l)=phi(:,:,k,l) +  crosscorr(imgA((ll:((ll+yintwinSize)-1)),(kk:((kk+xintwinSize)-1))),imgB((ll:((ll+yintwinSize)-1)),(kk:((kk+xintwinSize)-1))));
                
                ll=ll+yintwinSize;
                size(phi);
            end
            kk=kk+xintwinSize;
        end
        clear imgA;clear imgB;
%        toc;
    end
%     #####################
%  Debugging code-ignore!!
%    save('tem','phi');
%     #####################
    for k=1:floor(XSize/xintwinSize)
        for l=1:floor(YSize/yintwinSize)
            [deltax(k,l),deltay(k,l)] =locate_peak_subpixel_gauss(phi(:,:,k,l))
        end 
    end
    filename1=int2str(i);
    filename2='ensSet_';
    filename3='.piv';
    filename4='x_';
    filename5='y_';
    filenamex=[filename4,filename2,filename1,filename3];
    filenamey=[filename5,filename2,filename1,filename3];
    save(filenamex,'deltax')
    save(filenamey,'deltay')
%     Convert the x and y displacement data to velocities using functions
%     read_vel and write_vel
% 

end

    end

    function [imgMat]= readRAWimg(filename,nx,ny,xmin,xmax,ymin,ymax)
%   readRAWimg   Reads in RAW image file to memory and crops the image,if
%                necessary.
% 
%  INPUT PARAMETERS
%  filename - Name of RAW file to be read into memory
%  nx, ny  -  Number of pixels in the x and y directions
%  OUTPUT PARAMETERS
%  imgMat   - 2-D array containing the grayscale values from RAW file.
% 
    fid = fopen(filename);
    if (fid==1)
    error('Cannot open image file...press CTRL-C to exit ');
    end
    imgdat = fread(fid,'uint8');
    fclose(fid);
    imgdata = (reshape(imgdat,[nx,ny]))';
    imgMat = imgdata((ymin:ymax),(xmin:xmax)); 
    end

    function [ccorrMat] = crosscorr(imgAsubmat,imgBsubmat)
%     crosscorr   Performs cross-correlation of interrogation windows from
%                 image A and image B. It uses Matlab function xcorr2 which
%                 requires the Signal Processing Toolbox.
% 
%  INPUT PARAMETERS
%  imgAsubmat - 2-D array containing the interrogation window from image A.
%  imgBsubmat - 2-D array containing the interrogation window from image B.
% 
%  OUTPUT PARAMETERS
%  ccorrMat - 2-D array containing the output from Matlab function xcorr2
%             The size of this array is different from the size of the two
%             input arrays.
% 
    ccorrMat = xcorr2(imgAsubmat,imgBsubmat);
    end    
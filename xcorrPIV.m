function [fstatus] = xcorrPIV(fname,fnameindexStart,fnameindexEnd,XimgSize,YimgSize,xintwinSize,yintwinSize,xmin,xmax,ymin,ymax,img_precision)
%  xcorrPIV     Perform cross correlation of a series of RAW image pairs. Calculates displacement vectors 
%               and saves them with extension '.piv'. Matlab Signal Processing Toolbox is required.
%
%  created: Prabu Sellappan, 12/10/2014
%  modified: Prabu, 12/12/2014
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
%  img_precision - precision of input image; look in camera specs. Usually 'uint8' or 'uint16' 

fstatus=0;
nFiles=fnameindexEnd-fnameindexStart+1;
XSize=xmax-xmin+1; % XSize,Ysize - Size of image along x and y axis, that is actually processed
YSize=ymax-ymin+1;
if rem(nFiles,2)==1
    error('Number of input files(nFiles) is odd. Number of RAW image files (nFiles) has to even in order to form image pairs');
elseif rem(YSize,yintwinSize)~=0
    warning('Check size of interrogation window along y-axis. Some part of image might not be processed'); 
elseif rem(XSize,xintwinSize)~=0
    warning('Check size of interrogation window along x-axis. Some part of image might not be processed'); 
end

imgFilenum=fnameindexStart;
% imgFilenum - variable used to increment through filename index inside loop.

% Preallocate  
phi=zeros(((2*xintwinSize)-1),((2*yintwinSize)-1),(XSize/xintwinSize),(YSize/yintwinSize));    

% Pre-allocate displacement arrays deltax(:,:) and deltay(:,:). These arrays
% contain the x and y displacements obtained by peak locating.
deltax=zeros(floor(YSize/yintwinSize),floor(XSize/xintwinSize));
deltay=zeros(floor(YSize/yintwinSize),floor(XSize/xintwinSize));

for j=1:(nFiles/2)
%        tic;
% The loop variable j goes from 1 to (nFiles/2) since both images A and B
% are read into memory inside this loop to form the image pair. 
    filename1 = int2str(imgFilenum);
    filename2 = '.raw';
    filename = [fname,filename1,filename2];
% Image A is read into memory by calling subfunction read_RAW_img
    imgA = read_RAW_img(filename,XimgSize,YimgSize,xmin,xmax,ymin,ymax,img_precision);
    imgFilenum = imgFilenum + 1;
    filename1 = int2str(imgFilenum);
    filename2 = '.raw';
    filename = [fname,filename1,filename2];
% Image B is read into memory by calling subfunction read_RAW_img
    imgB = read_RAW_img(filename,XimgSize,YimgSize,xmin,xmax,ymin,ymax,img_precision);
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

            phi(:,:,k,l)= phi(:,:,k,l) + crosscorr(imgA((ll:((ll+yintwinSize)-1)),(kk:((kk+xintwinSize)-1))),imgB((ll:((ll+yintwinSize)-1)),(kk:((kk+xintwinSize)-1))));                
            ll=ll+yintwinSize;
%            size(phi);
        end
            kk=kk+xintwinSize;
    end
    clear imgA;clear imgB;
%   toc;
%     #####################
%  Debugging code-ignore!!
%    save('tem','phi');
%     #####################
    for k=1:floor(XSize/xintwinSize)
        for l=1:floor(YSize/yintwinSize)
            [deltax(k,l),deltay(k,l)] =locate_peak_subpixel_gauss(phi(:,:,k,l));
        end 
    end
    filename1=int2str(imgFilenum-2);
    filename2=fname;
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
fstatus = 1;
end %function end

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
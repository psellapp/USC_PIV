function [filenameu,u_vel,filenamev,v_vel,x_grid,y_grid,fstatus] = xcorrPIV(fname_stub,file_ext,fnameindexStart,fnameindexEnd,XimgSize,YimgSize,xintwinSize,yintwinSize,xmin,xmax,ymin,ymax,img_precision,delta_t,pix_to_cm,percentOverlap,save_flag)
%  xcorrPIV     Perform cross correlation of a series of RAW image pairs. Calculates displacement and velocity [cm/s] vectors
%               and, optionally, saves them as Matlab matrices with extension '.mat'. Matlab Signal Processing Toolbox is required.
%
%  created: Prabu Sellappan, 12/10/2014
%  modified: Prabu, 12/12/2014
%            Prabu, 12/13/2014
%            Prabu, 12/30/2014 added option to output filenames
%            Prabu, 1/5/2015 Major changes. Calculate velocity. Added option to output, or save to disk
%            Prabu, 4/26/2015 -added option to include overlap of interrogation windows 
%                             -generate and save spatial grid
% 
%  OUTPUT PARAMETERS
%
%  filenameu,filenamev - filenames of MAT-files containing velocity data
%  u_vel,v_vel - 2-D arrays of u and v velocities, in units of [cm/s]
%  x_grid, y_grid - spatial grid [in units of cm] generated using meshgrid 
%  fstatus - Output value. Takes a value of either 1 or 0 depending on
%            whether the function completed successfully(1) or failed(0).
%
%  INPUT PARAMETERS
%
%  fname_stub   - Placeholder for input filename.
%               eg. If your image files are named test_filename_23.raw,
%               test_filename_24.raw,etc., then  fname = 'test_filename_'
%
%  file_ext - filename extension. eg. '.raw'. Make sure that files contain
%             only uncompressed raw data without any header information
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
%
%  delta_t - pulse separation duration, in microseconds
%
%  pix_to_cm - pixels to length scaling factor, in pixels/cm
%
%  percentOverlap - Percentage (specify as non-negative integer, 0-99) overlap between interrogation windows
%
%  save_flag - set to 1 to save dispalcement and velocity fields to disk, set to 0 to
%              prevent saving to disk

nFiles=fnameindexEnd-fnameindexStart+1;
XSize=xmax-xmin+1; % XSize,Ysize - Size of image along x and y axis, that is actually processed
YSize=ymax-ymin+1;
percentOverlap = 1 - (percentOverlap/100); %convert to percentage shift
N_y = floor(YSize/(yintwinSize*percentOverlap))-1; %number of rows in vector field
N_x = floor(XSize/(xintwinSize*percentOverlap))-1; %number of columns in vector field

if rem(nFiles,2)==1
    error('Number of input files(nFiles) is odd. Number of RAW image files (nFiles) has to even in order to form image pairs');
elseif rem(YSize,yintwinSize*percentOverlap)~=0
    warning('Check size of interrogation window along y-axis. Some part of image might not be processed');
elseif rem(XSize,xintwinSize*percentOverlap)~=0
    warning('Check size of interrogation window along x-axis. Some part of image might not be processed');
end

imgFilenum=fnameindexStart;
% imgFilenum - variable used to increment through filename index inside loop.

for j=1:(nFiles/2)
    %        tic;
    % The loop variable j goes from 1 to (nFiles/2) since both images A and B
    % are read into memory inside this loop to form the image pair.
    
    
    % Preallocate correlation matrix
    phi = zeros(((2*yintwinSize)-1),((2*xintwinSize)-1),N_y,N_x);
    
    % Pre-allocate displacement arrays deltax(:,:) and deltay(:,:). These arrays
    % contain the x and y displacements obtained by peak locating.
    deltax = zeros(N_y,N_x);
    deltay = deltax;
    
    filename1 = int2str(imgFilenum);
    filename = [fname_stub filename1 file_ext];
    % Image A is read into memory by calling subfunction read_RAW_img
    imgA = read_RAW_img(filename,XimgSize,YimgSize,xmin,xmax,ymin,ymax,img_precision);
    imgFilenum = imgFilenum + 1;
    filename1 = int2str(imgFilenum);
    filename = [fname_stub filename1 file_ext];
    % Image B is read into memory by calling subfunction read_RAW_img
    imgB = read_RAW_img(filename,XimgSize,YimgSize,xmin,xmax,ymin,ymax,img_precision);
    imgFilenum = imgFilenum + 1;
    
    % =============Perform cross-correlation to calculate displacement=========
    kk=1; %loop variable init
    for l=1:N_x %Cycle through columns
        
        ll=1; %loop variable init
              %variables kk and ll are counters that track the absolute
              %indices of interrogation windows  w.r.t. the entire image
              
        for k=1:N_y %Cycle through rows
            % This loop calls the subfunction crosscorr and sends in the same
            % interrogation windows from images A and B as input parameters.
            %  CALL CROSS CORRELATION FUNCTION .
            
            phi(:,:,k,l)= phi(:,:,k,l) + crosscorr(imgB((ll:((ll+yintwinSize)-1)),(kk:((kk+xintwinSize)-1))),imgA((ll:((ll+yintwinSize)-1)),(kk:((kk+xintwinSize)-1))));
            ll=ll+floor(yintwinSize*percentOverlap);
%              size(phi)
%              k
%              l
%              kk
%              ll
        end
        kk=kk+floor(xintwinSize*percentOverlap);
    end
    clear imgA;clear imgB;
    
    for l=1:N_x
        for k=1:N_y
            [i_loc,j_loc] = locate_peak_subpixel_gauss(phi(:,:,k,l)); %locate correlation peak to sub-pixel accuracy
            [deltax(k,l),deltay(k,l)] = index_to_delta_pix(i_loc,j_loc,xintwinSize,yintwinSize);
            %             size(deltax)
            %             size(deltay)
            %             k
            %             l
        end
    end
    % =========================================================================
    
    % ============convert pixels to cm==========
    deltax = deltax./pix_to_cm;
    deltay = deltay./pix_to_cm;
    % ==========================================
    filename1=int2str(imgFilenum-2);
    if save_flag
        filenamex=[fname_stub filename1 '_x_disp' '.mat'];
        filenamey=[fname_stub filename1 '_y_disp' '.mat'];
        save(filenamex,'deltax')
        save(filenamey,'deltay')
    end
    % ============convert displacement to velocity=========
    [filenameu,u_vel,filenamev,v_vel,~] = disp2vel([fname_stub filename1],deltax,deltay,delta_t,save_flag);
    % =====================================================
end

% =================Calculate spatial grid==================================
[x_grid,y_grid]=meshgrid(linspace(0,XSize/pix_to_cm,N_x),linspace(0,YSize/pix_to_cm,N_y));
save([fname_stub 'spatialgrid.mat'],'x_grid','y_grid') % save spatial grid to disk. Can be used with quiver function, etc
% =========================================================================
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
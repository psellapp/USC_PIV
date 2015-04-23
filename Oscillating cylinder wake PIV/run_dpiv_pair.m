function run_dpiv_pair(stub,fnum1,fnum2,ndig,im_ext,threshold,keep)
% usage: run_dpiv_pair(stub,fnum1,fnum2,ndig,im_ext,threshold,keep)
%
% runs DPIV processing on one pair of images
% DPIV processing is carried out by external commandline programs
% the sequence of processing steps is:
%   1) cross-correlation, sub-pixel determination of displacements
%   2) outlier removal using magnitude comparrison to neighbors
%   3) cross-correlation with window shifting, sub-pixel determination of
%   displacements
%   4) outlier removal (same as 2)
%   5) vector field smoothing
%   6) conversion of displacements and image coordinates to velocities and
%   locations
%   7) calculation of vorticity field
% 
% assumes that the active directory contains the file 'dpiv.par' which is a
% valid DPIV parameter file
%
% check to make sure that the DPIV processing programs are located in the
% directory specified in this m-file
%
% results will be stored in files with same name as image 1 but various
% extensions (.vel for velocity, .vor for vorticity, etc.)
%
% INPUTS
%
% stub = string containing the portion of the image file names that is the
% same for both images
%
% fnum1, fnum2 = integer frame numbers that are appended to stub to
% complete the image file names
%
% ndig = number of digits in the image file names up to which to pad with
% leading zeros 
%
% im_ext = image file name extension
%
% threshold = threshold level to use for outlier detection
%
% keep = if keep=0, delete intermediate files from processing, otherwise
% allow to remain

% setup the calls to the DPIV processing programs
s = ' ';
DPIV_dir = 'D:\ROTATI~1\CODES\DPIV_S~1\';
dpiv = [DPIV_dir 'dpiv_ipl.exe '];
outliers = [DPIV_dir 'fix_data.exe ' int2str(threshold) s];
winshift = [DPIV_dir 'smeg.exe '];
smooth = [DPIV_dir 'smooth-fixed.exe '];
convert = [DPIV_dir 'convdpiv.exe '];
vorticity = [DPIV_dir 'f_diff.exe -v '];
delete = 'del ';

% setup file extensions
dotpiv = '.piv';
dotfix = '.fix';
dotsmg = '.smg';
dotsmo = '.smo';
dotvel = '.vel';
dotvor = '.vor';

% construct the two file names
fname1 = [stub num2str(fnum1,['%0' int2str(ndig) 'd'])];
fname2 = [stub num2str(fnum2,['%0' int2str(ndig) 'd'])];

% do the processing
[dpiv fname1 im_ext s fname2 im_ext s fname1 dotpiv]
if system([dpiv fname1 im_ext s fname2 im_ext s fname1 dotpiv]); return, end
[outliers fname1 dotpiv s fname1 dotfix]
if system([outliers fname1 dotpiv s fname1 dotfix]); return, end
[winshift fname1 im_ext s fname2 im_ext s fname1 dotfix s fname1 dotsmg]
if system([winshift fname1 im_ext s fname2 im_ext s fname1 dotfix s fname1 dotsmg]); return, end
[outliers fname1 dotsmg s fname1 dotfix]
if system([outliers fname1 dotsmg s fname1 dotfix]); return, end
[smooth fname1 dotfix s fname1 dotsmo]
if system([smooth fname1 dotfix s fname1 dotsmo]); return, end
[convert fname1 dotsmo s fname1 dotvel]
if system([convert fname1 dotsmo s fname1 dotvel]); return, end
[vorticity fname1 dotvel s fname1 dotvor]
if system([vorticity fname1 dotvel s fname1 dotvor]); return, end

if ~keep
    system([delete fname1 dotpiv]);
    system([delete fname1 dotfix]);
    system([delete fname1 dotsmg]);
    system([delete fname1 dotsmo]);
end

return
% end of run_dpiv_pair






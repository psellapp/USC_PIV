function [] = DPIV_process_cases_in_parallel(stubList, numFrames)
%   Function to process DPIV test cases. Uses executables that run in
%   parallel using OpenMP 2.0 to do the processing.
%
%   Written by: Prabu Sellappan, 08/28/2012.
%
%   Usage: DPIV_process_cases_in_parallel(stubList, numFrames)
%
%   stubList - List of sub-folders containing the test cases to be
%   processed. If no list is specified, then a list of all subfolders
%   with names starting with 'f' will be generated.
%   numFrames - number of frames to process
%
%   Folder containing DPIV processing codes should be on system path.

if isempty(stubList)
    stubList = dir('f*'); % generate list of sub-folders starting with 'f'
end

for i=1:size(stubList,1)
    tic
    copyfile('dpiv.par',stubList(i).name);
    cd(stubList(i).name);
    firstFrame = 1;
    if exist([stubList(i).name '_0.raw']','file')==2 % Figure out if first frame number is 0 or 1
        firstFrame = 0;
    end
    stubList(i).name
    pause('on');
    pause(2);
    
    % setup the calls to the DPIV processing programs
    threshold = 5; % threshold value for outlier removal
    s = ' '; % whitespace
    dpiv = ['parallel_dpiv_ipl.exe ' int2str(firstFrame) s int2str(numFrames) s 'dpiv_ipl.exe' s stubList(i).name '_'];
    outliers = ['parallel_fix_data.exe ' int2str(firstFrame) s int2str(numFrames) s 'fix_data.exe' s stubList(i).name '_' s int2str(threshold)];
    winshift = ['parallel_smeg.exe ' int2str(firstFrame) s int2str(numFrames) s 'smeg.exe' s stubList(i).name '_'];
    smooth = ['parallel_smooth-fixed.exe ' int2str(firstFrame) s int2str(numFrames) s 'smooth-fixed.exe' s stubList(i).name '_'];
    convert = ['parallel_convdpiv.exe ' int2str(firstFrame) s int2str(numFrames) s 'convdpiv.exe' s stubList(i).name '_'];
    vorticity = ['parallel_f_diff.exe ' int2str(firstFrame) s int2str(numFrames) s 'f_diff.exe' s stubList(i).name '_'];
    
    % do the processing
    if system(dpiv); return, end
    pause(5);
    if system([outliers s '.piv']); return, end
    pause(5);
    if system(winshift); return, end
    pause(5);
    if system([outliers s '.smg']); return, end
    pause(5);
    if system(smooth); return, end
    pause(5);
    if system(convert); return, end
    pause(5);
    if system(vorticity); return, end
    toc
    ['Number of unprocessed cases remaining: ' int2str(size(stubList,1)-i)]
    pause(2);
    pause('off');
    cd ..
end
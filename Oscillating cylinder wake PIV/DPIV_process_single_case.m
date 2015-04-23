function []=DPIV_process_single_case(stub,first,last)
% 
% DPIV_process_single_case is a function that can be used for DPIV processing of a single test
% case. Assumes that dpiv.par file is present in test case sub-directory.
% This function should be run from parent directory containing test case
% sub-directory.
%
% created by: Prabu Sellappan, 4/22/2011
% 
% usage : DPIV_process_single_case(stub,first,last)
% stub - name of sub-directory containing files
% first,last - index value of first and last file

% set working directory
cd(stub);
% *************************************************************************
% SET THE NUMBER OF DIGITS UP TO WHICH TO PAD FRAME NUMBERS WITH LEADING
% ZEROS (1 for no padding)
% use next line if same for all cases
ndig = 1;
% use next line if different for various cases
% ndig = []; 
% *************************************************************************

% *************************************************************************
% SET THE THRESHOLD LEVEL TO USE FOR DPIV OUTLIER REMOVAL
threshold = 5;
% *************************************************************************
% *************************************************************************
% SET keep=0 TO DELETE INTERMEDIATE DPIV PROCESSING FILES, ANY OTHER VALUE
% TO RETAIN
keep = 1;
% *************************************************************************
% generate the filename stub for this case
stub = [stub '_'];
% carry out the dpiv processing
run_dpiv_set(stub,first,last,ndig,'.raw',threshold,keep);

end
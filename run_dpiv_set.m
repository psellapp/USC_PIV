function run_dpiv_set(stub,first,last,ndig,im_ext,threshold,keep)
% usage: run_dpiv_set(stub,first,last,ndig,im_ext,threshold,keep)
%
% performs DPIV processing on a set of image pairs
% see run_dpiv_pair for detail on processing
%
% active directory must contain the DPIV parameter file 'dpiv.par' to be
% used
%
% assumes that all images are numbered sequentially and that consecutive
% images form a pair, i.e. first & first+1 are a pair, as are first+2 &
% first+3

% check to make sure that im_ext starts with a period
if im_ext(1)~='.'
    im_ext = ['.' im_ext];
end

% ensure that ndig is >= 1 to avoid format specification error
ndig = max(ndig,1);

for fnum = first:2:last
    run_dpiv_pair(stub,fnum,fnum+1,ndig,im_ext,threshold,keep);
end

return
% end of run_dpiv_set

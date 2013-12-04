function sort_dpiv_files(keep,first,last,ndig)
% usage: sort_dpiv_files(keep,first,last,ndig)
%
% sorts DPIV data and output files in to subdirectories based on file
% extension
%
% if keep~=0, sorts intermediate DPIV processing files as well

% setup list of file extensions
extlist = ['raw';'vel';'vor'];
n = 3;
if keep
    extlist = [extlist;'piv';'fix';'smg';'smo'];
    n = 7;
end


for i = 1:n
    ext = extlist(i,:);
    mkdir(ext);
    for fn = first:2:last
        system(['move /Y *_' num2str(fn,['%0' int2str(ndig) 'd']) '.' ext ' ' ext]);
        if i==1, system(['move /Y *_' num2str(fn+1,['%0' int2str(ndig) 'd']) '.' ext ' ' ext]);end
    end
end

return



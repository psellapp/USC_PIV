function err = write_raw(fname,img)
% usage: err = write_raw(fname,img)
fid = fopen(fname,'w');
if fid > 2
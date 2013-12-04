function [stat] = write_vor(x,y,u,filename)

% SYNTAX:
%	[stat] = write_vor(x,y,u,filename)
%
% Brad Dooley
% created 2/16/98
% modified 2/17/98 for faster running
% fixed 11/5/99 to correct a stupid bug

% Writes MATLAB-friendly one-component data in binary format, in the manner
% of the dpiv software.

% What I have are x,y,u

nx = length(x);
ny = length(y);

xmin = x(1);
ymin = y(1);

xmax = x(nx);
ymax = y(ny);

longvec(1) = nx;
longvec(2) = ny;
longvec(3) = xmin;
longvec(4) = ymin;
longvec(5) = xmax;
longvec(6) = ymax;

% need to convert u into a long vector

for j = 1:nx
  longvec((j-1)*ny+1+6 : (j-1)*ny+ny+6) = u(1:ny,j);
end

% Now write this to the filename indicated.

fid = fopen(filename, 'w');

count = fwrite(fid, longvec, 'float32');

stat = fclose(fid);


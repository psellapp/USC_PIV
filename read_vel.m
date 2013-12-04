function [x,y,u,v,err] = read_vel(binfile)

% SYNTAX:
%	[x,y,u,v] = read_vel(binfile)
%
% Brad Dooley
% created 2/16/98
% last modified 4/20/98 to incorporate faster technique on advice
% 	from Han Park.

% Get the file id number
fid = fopen (binfile, 'r');
if fid < 0
    err = [binfile ' does not exist']
    x=[];y=[];u=[];v=[];
    return
end

err=0;
% Read in the file
longvec = fread(fid, 'float32');

% Close the file before you forget
stat = fclose(fid);

% Indentify the important values at the start:

nx = longvec(1);
ny = longvec(2);
xmin = longvec(3);
ymin = longvec(4);
xmax = longvec(5);
ymax = longvec(6);

dx = (xmax-xmin)/(nx-1);
dy = (ymax-ymin)/(ny-1);

velpart = longvec(7:length(longvec));

% Create the x, y vectors
x = xmin:dx:xmax;
y = ymin:dy:ymax;

% Create the u,v arrays
uvec = velpart(1:nx*ny);
vvec = velpart(nx*ny + 1 : 2*nx*ny);

u = reshape(uvec,ny,nx);
v = reshape(vvec,ny,nx);

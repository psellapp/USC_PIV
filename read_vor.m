function [x,y,w,err] = read_vor(binfile)

% SYNTAX:
%	[x,y,w,err] = read_vor(binfile)
%
% Brad Dooley
% created 2/17/98
% last modified 4/20/98 to incorporate faster technique on advice
% 	from Han Park.
% modified 3/12/03 by Tait Pottebaum to add error checking and reporting

% Get the file id number
fid = fopen (binfile, 'r')

if fid < 3 % there was an error opening the file
        disp('this is a break for debugging')
    err = 1
    x=[];
    y=[];
    w=[];
else
    err = 0;
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

	% Create the x,y vectors 
	x = xmin:dx:xmax;
	y = ymin:dy:ymax;

	% Create the u array
	wvec = velpart(1:nx*ny);
	w = reshape(wvec,ny,nx);
end

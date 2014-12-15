function [deltaX,deltaY] = index_to_delta_pix(i,j,XintwinSize,YintwinSize)
% usage: [deltaX,deltaY] = index_to_delta_pix(i,j,XintwinSize,YintwinSize)
%
% Created: TP & PS, Summer 2010
% modified: Prabu, 12/15/2014
% 
% converts the (fractional) index coordinates of the cross-correlation peak
% into (x,y) displacements; also inverts y-axis so that positive is "up";
% assumes that the original cross-correlation was carried out using xcorr2;
% see help on the function xcorr2 for details, but note that entire help
% page uses indexin that starts at zero rather than 1.
%
% index of 1 in a dimension corresponds to a displacement of -(size in that
% dimension - 1) in that same dimension.
% 
%

deltaX = i - XintwinSize;
deltaY = YintwinSize - j;

end % index_to_delta_pix
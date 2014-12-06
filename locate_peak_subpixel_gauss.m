function [i,j] = locate_peak_subpixel_gauss(phi)
%
% Locates the peak to sub-pixel accuracy using the Gaussian peak fit method
% 
% INPUT PARAMETERS
% 
% phi - Contains cross correlation data of a single interrogation window
% 
% OUTPUT PARAMETERS
%
% i,j = location of peak in (fractional) index units
%
% Prabu Sellapan, June 2010
% modified by Tait Pottebaum, June 2010
% modified by Prabu Sellappan, 12/5/2014
%
% Gaussian peak fitting formula:
% 

% locate largest value
peakval = max(phi(:));
[J,I] = find(phi==peakval);
lnpeakval = log(peakval);

% if largest value is not on a boundary, fit Gaussians in each direction
[j_max,i_max] = size(phi);

if (I==1) || (I==i_max)
    i = I; % on an x-boundary, so no subpixel interpolation in x
else
    lnleftval = log(phi(J,I-1));
    lnrightval = log(phi(J,I+1));
    i = I + (lnleftval - lnrightval) / (2*lnleftval - 4*lnpeakval + 2*lnrightval);
end % x interpolation

if (J==1) || (J==j_max)
    j = J; % on an y-boundary, so no subpixel interpolation in y
else
    lndownval = log(phi(J+1,I));
    lnupval = log(phi(J-1,I));
    j = J + (lnupval - lndownval) / (2*lnupval - 4*lnpeakval + 2*lndownval);
end % y interpolation

end % locate_peak_subpixel_gauss
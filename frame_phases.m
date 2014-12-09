function [ss_info,phi_limits] = frame_phases(first,last,freq,frame_rate,nBins)
%
% Create and map phase values to frame numbers. Used by other functions for phase averaging
%
% created by:
% Prabu Sellappan - August 2010
% modified: Prabu Sellappan, 12/9/2014
% 
% usage:
% [ss_info,phi_limits] = frame_phases(first,last,freq,frame_rate,nBins)
% creates Nx2 matrix where col1 is frame # and col2 is phase
% 
% first - starting index value of frames
% last - last index value of frames
% freq - frequency of oscillation of cylinder, in Hz
% frame_rate - frame rate of data acquisition, in fps
% nBins - # of bins for phase averaging

framenums = first:2:last;
ElapsedTime = (framenums-first)/frame_rate;
phases = ElapsedTime * freq;
phases = (phases - floor(phases))*2*pi();
ss_info(:,1) = framenums;
ss_info(:,2) = phases;
phi_limits = zeros(nBins,2);
phi_width = max(phases)/nBins;
for i=1:nBins
    phi_limits(i,1) = (i*phi_width)-phi_width;
    phi_limits(i,2) = i*phi_width;
    
end
end
function [filt_signal] = HighPass_Filter(orig_signal,filter_order,F_s,cutoff_freq)
% Filter a signal using high pass Butterworth filter and output filtered
% signal. 
% Note: Filter order is effectively doubled due to the use of zero-phase 
% distortion filtfilt function.
% 
% usage: [filt_signal] = HighPass_Filter(orig_signal,filter_order,F_s,cutoff_freq)
%
% created: Prabu, 4/15/2015
% modified: PS, 4/25/2015. Use filtfilt for zero-phase filtering
%
% filt_signal - filtered signal with frequencies < cutoff attenuated; 1-D
%               vector of length N
% orig_signal - original signal, 1-D vector of length N
% filter_order - order of filter; higher orders have steeper roll-off
% F_s - Sampling rate, in Hz
% cutoff_freq - cut-off frequency, in Hz
%

if cutoff_freq<(F_s/2) %Ensure cut-off freq is less than Nyquist frequency
    [num,den]=butter(filter_order,cutoff_freq/(F_s/2),'high'); %calculate Butterworth filter coefficients;
    filt_signal=filtfilt(num,den,orig_signal); %apply filter to signal
else
    disp('cut-off frequency must be less than half the sampling rate');
    filt_signal = [];
end

end


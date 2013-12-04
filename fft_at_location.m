function [] = fft_at_location(stub,xpos,ypos,nframes,frame_rate,f_St,win_flag)

% Calculates the power spectrum from velocity data obtained at specified location.
%
% created by: Prabu Sellappan, 10/2/2011.
%
% modified: 
% 
% 2/23/2012, Prabu: Calculate the power spectral density. Also
% included option to apply a Hann window if required.
% 
% 3/25/2012, Prabu: Plot the power spectrum as a function of normalized
% frequency.
% 
% Input parameters:
%
% stub - filename placeholder; xpos,ypos - position on PIV image that is of interest;
% nframes - # of frames to process; frame_rate - camera frame rate [Hz],
% f_St - Strouhal frequency,
% win_flag - set to 1 to apply Hann window, 0 to not use any windowing scheme 
%
% This function assumes that the first file has index value either 0 or 1.
% The function should be called from the parent directory containing the
% test case sub-directory. Assumes that read_vel function is on the Matlab
% path.
%
% Note: The code sets the origin(1,1) of the 2-D velocity field at the top, left
% corner and a grid location of (x_val,y_val) means the point is at a distance
% of x_val in the x-direction(traveling to the right from origin is +ve x)
% and at a distance of (y_max - y_val) in the y-direction(traveling down from origin
% is +ve y).

cd(stub);
% figure out whether the first file has file index value 0 or 1
first = 1;
if (exist([stub '_0.vel'],'file'))==2
    first = 0;
end
frames = first:2:nframes;
if ((exist([stub num2str(frames(end)) ' .vel'],'file'))==2)
    error('last file does not exist. check nframes value');
end

u_i_1 = zeros(1,length(frames));


% read in each velocity file in the time series, extract x-component of
% velocity at desired points

for i = 1:length(frames)
    fname = [stub '_' num2str(frames(i)) '.vel'];
    [~,~,u_i,~,err] = read_vel(fname);
    if ~(err)
        u_i_1(i) = u_i(ypos,xpos);
    end
    clear u_i fname;
end

% Apply Hann window
if win_flag
%     figure(1)
%     subplot(2,1,1)
%     plot(u_i_1);
%     title('Original signal');
    hann_window = (hann(length(u_i_1)))';
    u_i_1 = u_i_1.*hann_window;
%     subplot(2,1,2)
%     plot(u_i_1);
%     title('Windowed signal');
end

% calculate power spectrum and plot it
nfft = 2^nextpow2(length(u_i_1)); % next power of 2 from length of u_i_1. nfft value required to optimize fft function
fft_func = @(u_vec)abs(fft(u_vec,nfft)/length(u_i_1)).^2; %calculates power
f = frame_rate/2*linspace(0,0.5*(1-1/(nfft-1)),nfft/2);
fft_1 = fft_func(u_i_1);
fft_1 = fft_1(1:nfft/2);

% Normalize the x-axis values by the Strouhal frequency
f = f/f_St;

% figure(2);
plot(f(12:end),fft_1(12:end),'k-','LineWidth',1.5);
title(['Grid location: (' num2str(xpos) ',' num2str(ypos) ')']);
xlim([0 4.5]);
% xlabel('{\itF_R}','fontname','Times','fontsize',14)
% ylabel('Magnitude [arbitrary units]','fontname','Times','fontsize',14)
set(gca,'FontName','Times','fontsize',14,'LineWidth',0.25);
clear;
cd ..
end
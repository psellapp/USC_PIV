function [] = power_spectra_along_y(stub,xpos,nframes,frame_rate,f_St,win_flag)

% Calculates the power spectra at 6 arbitrary points alomg Y-axis, from x-component of velocity data at those locations.
%   - Optionally apply Hann window, if required.
%   - Plots spectra as a function of normalized frequency.
%
% created by: Prabu Sellappan, 9/27/2012.
%
% Input parameters:
%
% stub - filename placeholder; xpos - position along horizontal axis that is of interest;
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
if ((exist([stub '_' num2str(frames(end)) '.vel'],'file'))==0)
    error('last file does not exist. check nframes value');
end

u_i_1 = zeros(6,length(frames));
[~,y_size,~,~]=read_vel([stub '_' num2str(first) '.vel']);
y_size=size(y_size,2);
y_pos=[1 2*floor(y_size/6) 3*floor(y_size/6) 4*floor(y_size/6)+2 5*floor(y_size/6)+3 y_size];

% read in each velocity file in the time series, extract x-component of
% velocity at desired points

for i = 1:length(frames)
    fname = [stub '_' num2str(frames(i)) '.vel'];
    [~,~,u_i,~,err] = read_vel(fname);
    if ~(err)
        u_i_1(1,i) = u_i(y_pos(1),xpos);
        u_i_1(2,i) = u_i(y_pos(2),xpos);
        u_i_1(3,i) = u_i(y_pos(3),xpos);
        u_i_1(4,i) = u_i(y_pos(4),xpos);
        u_i_1(5,i) = u_i(y_pos(5),xpos);
        u_i_1(6,i) = u_i(y_pos(6),xpos);
    end
    clear u_i fname;
end

% Apply Hann window
if win_flag
    hann_window = (hann(size(u_i_1,2)))';
    for j=1:6
        u_i_1(j,:) = u_i_1(j,:).*hann_window;
    end
end

% calculate power spectrum and plot it
nfft = 2^nextpow2(length(u_i_1)); % next power of 2 from length of u_i_1. nfft value required to optimize fft function
fft_func = @(u_vec)abs(fft(u_vec,nfft)/length(u_i_1)).^2; %calculates power
f = frame_rate/2*linspace(0,0.5*(1-1/(nfft-1)),nfft/2);
f = f/f_St; % Normalize the x-axis values by the Strouhal frequency

for i=1:6
    fft_1 = fft_func(u_i_1(i,:));
    fft_1 = fft_1(1:nfft/2);
    figure(2);
    subplot(6,1,i)
    plot(f(8:end),fft_1(8:end),'k-','LineWidth',1.0);
    title(['Grid location: (' num2str(xpos) ',' num2str(y_pos(i)) ')']);
    xlim([0.6 4.75]); % This value should be changed depending on frequency range expected in data
%     xlabel('{\itF_R}','fontname','Times','fontsize',10)
%     ylabel('Magnitude [arbitrary units]','fontname','Times','fontsize',10)
    set(gca,'FontName','Times','fontsize',10);
    clear fft_1;
end

cd ..
end
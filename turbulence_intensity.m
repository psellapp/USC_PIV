function [turbulence_intensity,avg_u_vel]=turbulence_intensity(dir_name,nFrames)
%
% Function turbulence_intensity calculates the turbulence intensity and average
% u velocity at a location approximately at the center of the processed PIV field.
% The function also does spatial and temporal averaging to determine
% steadiness and uniformity of the flow.
% 
% Created by: Prabu Sellappan
%             1/23/2011
%
% dir_name - directory name
% nFrames - # of frames to process
%
% This function assumes that the first file is either 0 or 1.
% This function has to be run from parent directory which contains the test
% case sub-directory. Requires read_vel function to be on MATLAB path.

% generate the filename stub for this case
stub = [dir_name '_'];
% generate name of subdirectory for this case and make it the
% active directory
cd(dir_name);

% figure out whether the first file has file index value 0 or 1
firstFrame = 1;
if (exist([stub '0.vel'],'file'))==2
    firstFrame = 0;
end
frames=firstFrame:2:nFrames;
if ((exist([stub num2str(frames(end)) ' .vel'],'file'))==2)
    error('Last file does not exist. Check nFrames value');
end

[~,~,u_i,~]=read_vel([stub num2str(firstFrame) '.vel']);
[m,n]=size(u_i);
y=round(m/2);
x=round(n/2);
x_min=3;
x_max=n-3;
y_min=3;
y_max=m-3;
u_spatial_avg=zeros(1,length(frames));
u_temporal_avg=zeros((y_max-y_min+1),(x_max-x_min+1));
n=0;
u_tot=0;u2_tot=0;
for i=1:length(frames)
    fname = [stub num2str(frames(i)) '.vel'];
    [~,~,u,~,err] = read_vel(fname);
    u_spatial_avg(i)=mean(mean(u(y_min:y_max,x_min:x_max))); 
    u_temporal_avg=u_temporal_avg+u(y_min:y_max,x_min:x_max);
    if ~(err)
        u_i = u(y,x);
        u_tot = u_tot + u_i;
        u2_tot = u2_tot + u_i^2;
        n = n+1;
    end
    clear u_i fname;
end
% compute the time average and rms at each location on centerline
if n>0
    avg_u_vel = mean(u_spatial_avg);
    urms = sqrt(u2_tot/n -2.0*avg_u_vel.*u_tot/n + avg_u_vel.^2);
else
    error('Check function input. Files could not be read.');
end
turbulence_intensity = (urms/avg_u_vel)*100; %turbulence intensity as a percentage

u_spatial_avg = u_spatial_avg.*100;%Multiplied by 100 to convert it from [m/s] to [cm/s]
u_temporal_avg = u_temporal_avg.*100;%Multiplied by 100 to convert it from [m/s] to [cm/s]
avg_u_vel=avg_u_vel*100;
disp(num2str(dir_name));
disp(std(u_spatial_avg));
% disp(std(std(u_temporal_avg)));

subplot(2,1,1);
axis equal;
plot(u_spatial_avg,'-*k');
ylabel('U (spatially averaged velocity) [cm/s]');
xlabel('Time');
title(['Spatially averaged velocity [cm/s] ' num2str(dir_name)]);
saveas(gcf,[num2str(dir_name) '_usp'],'fig');
subplot(2,1,2);
u_temporal_avg=u_temporal_avg/length(frames);
axis equal;
contour(u_temporal_avg);
colorbar;
ylabel('Y location');
xlabel('X location');
title(['Temporally averaged velocity [cm/s] ' num2str(dir_name)]);
saveas(gcf,[num2str(dir_name) '_utavg'],'fig');

% % Calculate the frequency spectrum
% NFFT = 2^nextpow2(length(u_spatial_avg)); % Next power of 2 from length of y
% fft_ts = abs(fft(u_spatial_avg,NFFT)/length(u_spatial_avg));
% fft_ts = fft_ts(1:NFFT/2);
% f = 6.5/2*linspace(0,0.5*(1-1/(NFFT-1)),NFFT/2); % 6.5 is the frame rate
% [peak,index] = max(fft_ts);
% f_St = f(index);
% 
% figure(3)
% plot(f,fft_ts(1:end),'b-',f_St,peak,'r.')
% title('Frequency spectrum of u velocity component timeseries')
% xlabel('Frequency (Hz)')
% ylabel('|FFT|')

cd ..
end
function [turbulence_intensity,mean_U_inf]=turbulence_stats(dir_name,fname_stub,nVelocityFields,[U_inf_yloc U_inf_xloc])
%
% Calculate turbulence intensity and mean U_inf (velocity of unperturbed outer flow). Mean U_inf is calculated
% over a 8x8 postage stamp area whose location should be specified such that it is in the outer flow.
% The function also performs temporal averaging and plots it, along with a time series plot of mean U_inf. 
% 
% Created by: Prabu Sellappan
%             12/4/2014
%
% dir_name - directory name
% fname_stub - filename stub (assumes files are named fname_stub_0.vel,fname_stub_2.vel,...)
%              Numbering goes firstFrame, firstFrame+2, firstFrame+4,... 
% nVelocityFields - Number of velocity fields to process.

% [U_inf_yloc U_inf_xloc] - Approximate center of 8 by 8 postage stamp in region of unperturbed outer flow
% Specify in row-column order with normalized values [0-1 0-1]. eg. [0.75 0.25] would place it near bottom-left of domain                       
%
% This function assumes that the first file is either 0 or 1.
% This function has to be run from parent directory which contains the test
% case sub-directory. Requires read_vel function to be on MATLAB path.

% generate name of subdirectory for this case and make it the active directory
cd(dir_name);
% generate the filename stub for this case
stub = [fname_stub '_'];
% figure out whether the first file has file index value 0 or 1
firstFrame = 1;
if (exist([stub '0.vel'],'file'))==2
    firstFrame = 0;
end
frames=firstFrame:2:nVelocityFields*2;
if ((exist([stub num2str(frames(end)) ' .vel'],'file'))==2)
    error('Last file does not exist. Check nVelocityFields value');
end
%========================Figure out array sizes, locations, and arbitrarily crop edges==================
[~,~,u_i,~]=read_vel([stub num2str(firstFrame) '.vel']);%read in single velocity field
[m,n]=size(u_i);
y=round(m/2);
x=round(n/2);
x_min=3;
x_max=n-3;
y_min=3;
y_max=m-3;

postage_x_min= round(U_inf_xloc*(x_max-x_min+1)) - 4; % Place postage stamp approximately near the requested location 
postage_x_max= round(U_inf_xloc*(x_max-x_min+1)) + 3; % Values of 4 and 3 create a 8 x 8 postage stamp
postage_y_min= round(U_inf_yloc*(y_max-y_min+1)) - 4;
postage_y_max= round(U_inf_yloc*(y_max-y_min+1)) + 3;
if (postage_y_min<y_min | postage_y_max>y_max | postage_x_min<x_min | postage_x_max>x_max)
    error('Postage stamp falls outside domain. Change values of [U_inf_yloc U_inf_xloc]')
end

u_spatial_avg=zeros(1,length(frames)); %preallocate arrays to hold spatially and temporally averaged data 
u_temporal_avg=zeros((y_max-y_min+1),(x_max-x_min+1));
n=0;
u_tot=0;u2_tot=0;
%========================Perform averaging===================================================
for i=1:length(frames)
    fname = [stub num2str(frames(i)) '.vel'];
    [~,~,u,~,err] = read_vel(fname);
    u_spatial_avg(i)=mean(mean(u(postage_y_min:postage_y_max,postage_x_min:postage_x_max))); 
    u_temporal_avg=u_temporal_avg+u(y_min:y_max,x_min:x_max);
    if ~(err)
        u_i = u(y,x);
        u_tot = u_tot + u_i;
        u2_tot = u2_tot + u_i^2;
        n = n+1;
    end
    clear u_i fname;
end

%============compute the mean value of entire velocity field and rms at each location on centerline=================
if n>0
    mean_U_inf = mean(u_spatial_avg);
    urms = sqrt(u2_tot/n -2.0*mean_U_inf.*u_tot/n + mean_U_inf.^2);
else
    error('Check function input. Files could not be read.');
end
turbulence_intensity = (urms/mean_U_inf)*100; %turbulence intensity as a percentage

subplot(2,1,1);
axis equal;
plot(u_spatial_avg,'-*k');
ylabel('U_inf [set appropriate units based on input]');
xlabel('Time');
title(['U_inf (unperturbed outer flow - spatially averaged over postage stamp) ' num2str(dir_name)]);
subplot(2,1,2);
u_temporal_avg=u_temporal_avg./length(frames);
axis equal;
contour(u_temporal_avg);
colorbar;
ylabel('Grid Y coordinates');
xlabel('Grid X coordinates');
title(['Temporally averaged velocity [set appropriate units based on input] ' num2str(dir_name)]);

cd ..

end
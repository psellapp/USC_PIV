function [Cd10_mean,Cd10_std,Cd20_mean,Cd20_std] = calcCD(fname_stub,firstFile,lastFile,n_upper,n_lower,n_order,char_length,plot_pause)
%
% Calculate the coefficient of drag through momentum deficit method. Reads
% in 2D2C velocity data stored in .u files
% created: Prabu, 2/16/2015
% mod: Prabu, 5/25/2015. -added option to pause. Improved this help definition.
%
% fname_stub, firstFile,lastFile - filename stub and range
% n_upper,n_lower,n_order - # of points and order of polynomial fit
% char_length - characteristic length scale, in [cm/s]. Assuming .u files have length
%               scales in dimensions of [cm]
% plot_pause  - amount of time to pause between displaying consecutive
%               profile plots. Specify in seconds. 
%
% Cd1_mean, Cd2_mean - mean C_d from profiles averaged over 10 and 20 cols respectively
%            near right edge of velocity field
% Cd1_std, Cd2_std - standard deviation of Cd values

[Umean,~]=textread('um_post.txt'); %Read and calculate abs(U_mean)
disp('Mean U velocity [cm/s] (from um_post):')
Umean=abs(Umean)

Cd10 = zeros(1,lastFile-firstFile);
Cd20 = Cd10;

for i=firstFile:lastFile
    fname = [fname_stub num2str(i,'%03d') '.u']; %Check the formatSpec value in num2str if there's a problem with file read
    [~,~,~,~,u2d,~,~,y2d,nx_v,ny_v,~] = rd_v_modPS(fname);
    
    [u10corr,u20corr] = longxprof(u2d,y2d,nx_v,ny_v,n_upper,n_lower,n_order);
    pause(plot_pause)
    [momentum10] = calcMomentum(u10corr,y2d,Umean);
    [momentum20] = calcMomentum(u20corr,y2d,Umean);
    
    Cd10(i) = 2*momentum10/char_length;
    Cd20(i) = 2*momentum20/char_length;
    
end

Cd10_mean = mean(Cd10);
Cd20_mean = mean(Cd20);
Cd10_std = std(Cd10);
Cd20_std = std(Cd20);

end
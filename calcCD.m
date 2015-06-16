function [Cd10_mean,Cd10_std,Cd20_mean,Cd20_std] = calcCD(fname_stub,firstFile,lastFile,n_upper,n_lower,n_order,char_length_scale,Umean,range_cols2avg,plot_pause)
%
% Calculate the coefficient of drag through momentum deficit method. Reads
% in 2D2C velocity data stored in .u files
% created: Prabu, 2/16/2015
% mod: Prabu, 5/25/2015 -added option to pause. Improved this help definition.
%      Prabu, 6/15/2015 -added option to specify range of columns
%                       -option to specify free-stream velocity, Umean
%
% Umean - free-stream velocity, [cm/s]. Usually the mean flow in
%         undisturbed portion of flow field.
% fname_stub, firstFile,lastFile - filename stub and range
% n_upper,n_lower,n_order - # of points and order of polynomial fit
% char_length_scale - characteristic length scale, in [cm/s]. Assuming .u files have length
%                     scales in dimensions of [cm]
% range_cols2avg - range of columns to average over. Specify four values, 
%                  [prof1_min prof1_max prof2_min prof2_max]. Empty array []
%                  defaults to [nx_v-4 nx_v nx_v-14 nx_v]
% plot_pause  - amount of time to pause between displaying consecutive
%               profile plots. Specify in seconds. 
%
% Cd10_mean, Cd20_mean - mean C_d from profiles averaged over range of
%                        columns specified in [range_cols2avg]
% Cd10_std, Cd20_std - standard deviation of Cd values

Umean=abs(Umean);

Cd10 = zeros(1,lastFile-firstFile);
Cd20 = Cd10;

for i=firstFile:lastFile
    fname = [fname_stub num2str(i,'%03d') '.u']; %Check the formatSpec value in num2str if there's a problem with file read
    [~,~,~,~,u2d,~,~,y2d,nx_v,ny_v,~] = rd_v_modPS(fname);
    
    [u10corr,u20corr] = longxprof(u2d,y2d,nx_v,ny_v,n_upper,n_lower,n_order,range_cols2avg);
    pause(plot_pause)
    [momentum10] = calcMomentum(u10corr,y2d,Umean);
    [momentum20] = calcMomentum(u20corr,y2d,Umean);
    
    Cd10(i) = 2*momentum10/char_length_scale;
    Cd20(i) = 2*momentum20/char_length_scale;
    
end

disp('Vector field size:')
nx_v 
ny_v

disp(['Coefficient of drag for mean profile ranging from columns ' num2str(range_cols2avg(1)) ' to ' num2str(range_cols2avg(2))])  
Cd10_mean = mean(Cd10)
Cd10_std = std(Cd10)
disp(['Coefficient of drag for mean profile ranging from columns ' num2str(range_cols2avg(3)) ' to ' num2str(range_cols2avg(4))])
Cd20_mean = mean(Cd20)
Cd20_std = std(Cd20)

end
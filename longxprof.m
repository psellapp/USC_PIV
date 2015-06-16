function [u10corr,u20corr] = longxprof(u2d,y2d,nx_v,ny_v,n_upper,n_lower,n_order,range_cols2avg)
%
% Calculate the mean u velocity profiles, averaged horizontally over
% specified range (range_cols2avg) of columns. Also plots the profiles.
% Corrects the profiles based on a n'th order polynomial fit.
%
% Created: Prabu, 2/15/2015.
% Modified: Prabu, 6/15/2015.
%                  -Added option to specify range of columns
%                 
% Inputs: u2d,y2d - arrays of u-vel and y-locations
%         nx_v,ny_v - number of x and y elements
%         n_upper, n_lower - number of points at top and bottom for fit.
%         n_order - order of polynomial
%         range_cols2avg - range of columns to average over. Specify
%                       four values, [prof1_min prof1_max prof2_min prof2_max].
%                       Empty array [] defaults to [nx_v-4 nx_v nx_v-14 nx_v]
%
% Outputs: u10corr, u20corr - Corrected velocity profiles, averaged over
%                             [prof1_min to prof1_max] and [prof2_min to prof2_max] columns
% All velocities are assumed to be in cm/s and length scales are in cm.


% ===================Extract u-velocities==================================
if isempty(range_cols2avg)
    u10=u2d(:,nx_v-4:nx_v);%Extract right-most 5 columns
    u20=u2d(:,nx_v-14:nx_v);%Extract right-most 15 columns
else
    u10=u2d(:,range_cols2avg(1):range_cols2avg(2));%Extract columns for first profile
    u20=u2d(:,range_cols2avg(3):range_cols2avg(4));%Extract columns for second profile
end

% =================Find mean profiles======================================

u10m=mean(u10,2);%calculate mean profile
u20m=mean(u20,2);
figure(gcf)
plot(u10m,y2d,'-^g',u20m,y2d,'--*r') %plot both profiles
xlabel('U [cm/s]');
ylabel('Z [cm]');

% =================Preallocate arrays for calculating polynomial fit=======

y_poly = zeros(1,n_upper+n_lower);
u_poly = y_poly;

y_poly(1:n_upper) = y2d(1:n_upper);
y_poly(n_upper+1:end)=y2d(ny_v-n_lower+1:ny_v);

% =================Calculate polyfit for 10 column avg profile=============

u_poly(1:n_upper) = u10m(1:n_upper);
u_poly(n_upper+1:end)=u10m(ny_v-n_lower+1:ny_v);
u10polycoeff = polyfit(y_poly,u_poly,n_order);

u_polyfit = polyval(u10polycoeff,y2d);
u10corr(1:ny_v) = u10(1:ny_v)-u_polyfit(1:ny_v);

hold on
plot(u_polyfit,y2d,'--g');

% =================Calculate polyfit for 20 column avg profile=============
u_poly(1:n_upper) = u20m(1:n_upper);
u_poly(n_upper+1:end)=u20m(ny_v-n_lower+1:ny_v);
u20polycoeff = polyfit(y_poly,u_poly,n_order);

u_polyfit = polyval(u20polycoeff,y2d);
u20corr(1:ny_v) = u20(1:ny_v)-u_polyfit(1:ny_v);

plot(u_polyfit,y2d,'--r');
% plot(u10corr,y2d,'-k',u20corr,y2d,'--k');
hold off

end

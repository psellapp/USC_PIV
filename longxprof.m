function [u10corr,u20corr] = longxprof(u2d,y2d,nx_v,ny_v,n_upper,n_lower,n_order)
%
% Calculate the mean u velocity profiles, averaged over 10 and 20 columns
% near the right edge of field. Also plots the profiles.
% Corrects the profiles based on a n'th order polynomial fit. 
%
% Created: Prabu, 2/15/2015.
%
% Inputs: u2d,y2d - arrays of u-vel and y-locations
%         nx_v,ny_v - number of x and y elements
%         n_upper, n_lower - number of points at top and bottom for fit.
%         n_order - order of polynomial
% Outputs: u10corr, u20corr - Corrected velocity profiles, averaged over 10
%          and 20 cols respectively
% All velocities are assumed to be in cm/s and length scales are in cm.

% ============= Extract u-velocities==================
u10=u2d(:,nx_v-9:nx_v);%Extract last 10 columns
u20=u2d(:,nx_v-19:nx_v);%Extract last 20 columns

% =================Find mean of u over 10 and 20 colums====================

u10m=mean(u10,2);%calculate mean profile
u20m=mean(u20,2);
figure(gcf)
plot(u10m,y2d,'-^g',u20m,y2d,'-*r') %plot both profiles
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
plot(u10corr,y2d,'-k',u20corr,y2d,'--k');
hold off

end

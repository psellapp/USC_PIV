function [mean_quantity] = mean_velocity_balanced_avg(stub,nBins)
%
% Calculate the mean normalized velocity for a case by balanced full-cycle 
% averaging such that each phase is equally represented. Assumes that
% incoming spatial and velocity values are appropriately
% non-dimensionalized.
%
% -Prabu Sellappan, 2/20/2013.
%
% Input: stub - filename placeholder
%        nBins - # of bins

cd(stub);

[x,y,u,v]=read_vel(['avg_' stub '_01.vel']);
mean_vel_u=zeros(size(u,1),size(u,2));
mean_vel_v=zeros(size(v,1),size(v,2));
for i=1:nBins
    fname=['avg_' stub '_' num2str(i,'%02d') '.vel'];
    [~,~,u,v]=read_vel(fname);
    mean_vel_u=plus(mean_vel_u,u);
    mean_vel_v=plus(mean_vel_v,v);
    clear u v;
end
mean_quantity = mean_vel_u ./ nBins;
mean_quantity_v = mean_vel_v ./ nBins;
quiver(x,y,mean_quantity,mean_quantity_v);
hold on;
set(gcf,'renderer','zbuffer');
xc = 0; yc = 0; radius = 0.5;
xvals = [xc-radius:radius/25:xc+radius];
yvals_u = yc + sqrt(radius*radius - (xvals-xc).*(xvals-xc));
yvals_l = yc - sqrt(radius*radius - (xvals-xc).*(xvals-xc));
xvals = [xvals,xvals(length(xvals):-1:1)];
fill(xvals,[yvals_u,yvals_l],'k')
hold off;
xlabel('{\itx / D}');
ylabel('{\ity / D}');
title('U_{mean}');
xlim([0 7.5]);
ylim([-2 2]);
axis equal
cd ..
end
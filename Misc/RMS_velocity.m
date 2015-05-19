function [rms_vel] = RMS_velocity(stub,nBins,vel_component)
%
% Calculate the Root-Mean-Square velocity for a case with each phase
% equally represented. Mean values are calculated using balanced full-cycle
% averaging. Assumes that the incoming spatial and velocity values have
% been non-dimensionalized appropriately
%
% -Prabu Sellappan, 2/20/2013.
%
% usage: [rms_vel] = RMS_velocity(stub,nBins,vel_component)
%
% stub - filename placeholder
% nBins - # of bins
% vel_component - 1 for U velocity component, 0 for V velocity component

cd(stub);
[x,y,u,v]=read_vel(['avg_' stub '_01.vel']);
mean_vel=zeros(size(u,1),size(u,2));
rms_vel=zeros(size(u,1),size(u,2));
if vel_component
    for i=1:nBins
        fname=['avg_' stub '_' num2str(i,'%02d') '.vel'];
        [~,~,u,~]=read_vel(fname);
        mean_vel = plus(mean_vel,u);
        clear fname;
        fname=['rms_' stub '_' num2str(i,'%02d') '.vel'];
        [~,~,u_rms,~]=read_vel(fname);
        u_squared = u.^2;
        u_rms_squared = u_rms.^2;
        rms_sum = plus(u_squared,u_rms_squared);
        rms_vel = plus(rms_vel,rms_sum);
        clear u v u_rms u_squared u_rms_squared fname rms_sum;
    end
else
    for i=1:nBins
        fname=['avg_' stub '_' num2str(i,'%02d') '.vel'];
        [~,~,~,v]=read_vel(fname);
        mean_vel = plus(mean_vel,v);
        clear fname;
        fname=['rms_' stub '_' num2str(i,'%02d') '.vel'];
        [~,~,~,v_rms]=read_vel(fname);
        v_squared = v.^2;
        v_rms_squared = v_rms.^2;
        rms_sum = plus(v_squared,v_rms_squared);
        rms_vel = plus(rms_vel,rms_sum);
        clear u v v_rms v_squared v_rms_squared fname rms_sum;
    end
end

mean_vel = mean_vel ./ nBins;
rms_vel = (rms_vel ./ nBins) - (mean_vel .^2);
rms_vel = sqrt(rms_vel);

% vn=[-3.0:0.5:-0.5]; % contour levels
% vp=[0.5:0.5:3.0]; % contour levels

[~,h]=contourf(x,y,rms_vel,0.01:0.05:0.75,'-k','LineWidth',0.5);
hold on;
% contour(x,y,mean_quantity,vp,'-k','LineWidth',0.5);
% set(h,'ShowText','on','TextStep',get(h,'LevelStep')*2)
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
if vel_component
    title('U_{rms}');
else
    title('V_{rms}');
end
xlim([0 7.5]);
ylim([-2 2]);
axis equal
cd ..
end
function [mean_quantity] = mean_velocity(stub,nFiles,U_fs,D,vel_component)
%
% Calculate the mean normalized velocity for a case by unbalanced averaging of the
% full data set of velocity fields.
%
% -Prabu Sellappan, 2/19/2013.
%
% Input: stub - filename placeholder
%        nFiles - # of files to process
%        vel_component - 1 for u-velocity, 0 for v-velocity component
%        U_fs - freestream velocity; D - cylinder diameter

cd(stub);
% figure out whether the first file has file index value 0 or 1
first = 1;
if (exist([stub '_0.vel'],'file'))==2
    first = 0;
end
frames = first:2:nFiles;
if ((exist([stub '_' num2str(frames(end)) ' .vel'],'file'))==2)
    error('last file does not exist. check nFiles value');
end

[x,y,u,v]=read_vel([stub '_' num2str(first) '.vel']);
x = x./D;
y = y./D;
mean_vel_u = zeros(size(u,1),size(u,2));
mean_vel_v = zeros(size(u,1),size(u,2));

% read in each velocity file in the time series, extract velocity component
% and average
if vel_component
    for i = 1:length(frames)
        fname = [stub '_' num2str(frames(i)) '.vel'];
        [~,~,u_i,~] = read_vel(fname);
        mean_vel_u = plus(mean_vel_u,u_i);
        clear u_i;
    end
    mean_vel_u = mean_vel_u ./ U_fs;
    v = v ./ U_fs;
    mean_quantity = mean_vel_u ./ length(frames);
    quiver(x,y,mean_quantity,v);
else
    for i = 1:length(frames)
        fname = [stub '_' num2str(frames(i)) '.vel'];
        [~,~,~,v_i] = read_vel(fname);
        mean_vel_v = plus(mean_vel_v,v_i);
        clear v_i;
    end
    mean_vel_v = mean_vel_v ./ U_fs;
    u = u ./ U_fs;
    mean_quantity = mean_vel_v ./ length(frames);
    quiver(x,y,u,mean_quantity);
end

%     for i = 1:length(frames)
%         fname = [stub '_' num2str(frames(i)) '.vel'];
%         [~,~,u_i,v_i] = read_vel(fname);
%         mean_vel_v = plus(mean_vel_v,v_i);
%         mean_vel_u = plus(mean_vel_u,u_i);
%         clear  u_i v_i;
%     end
%     mean_vel_v = mean_vel_v ./ U_fs;
%     mean_vel_u = mean_vel_u ./ U_fs;
%     u = u ./ U_fs;
%     v = v ./ U_fs;
%     mean_quantity_u = mean_vel_u ./ length(frames);
%     mean_quantity = mean_vel_v ./ length(frames);
%     quiver(x,y,mean_quantity_u,mean_quantity);

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
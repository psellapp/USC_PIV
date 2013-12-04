function [rms_vor] = RMS_vorticity(stub,nBins,D,U_fs,x_shaded_ext)
%
% Calculate the Root-Mean-Square vorticity for a case with each phase
% equally represented. Mean values are calculated using balanced full-cycle
% averaging. Assumes that the incoming avg vorticity values have been normalized but RMS
% values have not been normalized, hence they are normalized here.
%
% -Prabu Sellappan, 2/19/2013.
%
% usage: [rms_vor] = RMS_vorticity(stub,nBins,D,U_fs)
% 
% x_shaded_ext - extent of gray box around cylinder in units of x/D
%
cd(stub);
[x,y,w,~]=read_vor(['avg_' stub '_01.vor']);
mean_vor=zeros(size(w,1),size(w,2));
rms_vor=zeros(size(w,1),size(w,2));
for i=1:nBins
    fname=['avg_' stub '_' num2str(i,'%02d') '.vor'];
    [~,~,w,~]=read_vor(fname);
    mean_vor=plus(mean_vor,w);
    clear fname;
    fname=['rms_' stub '_' num2str(i,'%02d') '.vor'];
    [~,~,w_rms,~]=read_vor(fname);
    w_rms = w_rms.*(D/U_fs); % normalize rms vorticity in terms of free-stream velocity and cylinder diameter
    w_squared = w.^2;
    w_rms_squared = w_rms.^2;
    rms_sum = plus(w_squared,w_rms_squared);
    rms_vor = plus(rms_vor,rms_sum);
    clear w w_rms w_squared w_rms_squared fname rms_sum;
end

mean_vor = mean_vor ./ nBins;
rms_vor = (rms_vor ./ nBins) - (mean_vor .^2);
rms_vor = sqrt(rms_vor);

% vn=[-3.0:0.5:-0.5]; % contour levels
% vp=[0.5:0.5:3.0]; % contour levels

[~,h]=contour(x,y,rms_vor,0.5:0.5:4.5,'-k','LineWidth',0.5);
hold on;
% contour(x,y,mean_quantity,vp,'-k','LineWidth',0.5);
% set(h,'ShowText','on','TextStep',get(h,'LevelStep')*2)
set(gcf,'renderer','zbuffer');
    fill([0 x_shaded_ext x_shaded_ext 0],[-2 -2 2 2],[0.85 0.85 0.85])
xc = 0; yc = 0; radius = 0.5;
xvals = [xc-radius:radius/25:xc+radius];
yvals_u = yc + sqrt(radius*radius - (xvals-xc).*(xvals-xc));
yvals_l = yc - sqrt(radius*radius - (xvals-xc).*(xvals-xc));
xvals = [xvals,xvals(length(xvals):-1:1)];
fill(xvals,[yvals_u,yvals_l],'k')
hold off;
% xlabel('{\itx / D}');
% ylabel('{\ity / D}');
% title('\omega_{rms}');
axis equal
xlim([0 7]);
ylim([-2 2]);

cd ..
end
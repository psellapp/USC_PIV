function [mean_quantity] = mean_vorticity(stub,nBins,x_shaded_ext)
%
% Calculate the mean normalized vorticity for a case by balanced full-cycle
% averaging of the phase-binned vorticity. Assumes that vorticity data has 
% already been normalized.
%
% -Prabu Sellappan, 2/13/2013.
%

cd(stub);
[x,y,w,~]=read_vor(['avg_' stub '_01.vor']);
mean_vor=zeros(size(w,1),size(w,2));
for i=1:nBins
    fname=['avg_' stub '_' num2str(i,'%02d') '.vor'];
    [~,~,w,~]=read_vor(fname);
    mean_vor=plus(mean_vor,w);
    clear w;
end
mean_quantity = mean_vor ./ nBins;
vn=[-3.0:0.5:-0.5]; % contour levels
vp=[0.5:0.5:3.0]; % contour levels
contour(x,y,mean_quantity,vn,'--k','LineWidth',0.5);
hold on;
contour(x,y,mean_quantity,vp,'-k','LineWidth',0.5);
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
% title('\omega_{mean}');
axis equal
xlim([0 7]);
ylim([-2 2]);

cd ..
end
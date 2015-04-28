function create_phase_avg_plot_ver2(freq,amp,nBins,nCycles,xmin,xmax,ymin,ymax)
% Creates B&W contour plots of phase-averaged vorticity
% created by:
% Prabu Sellappan - August 2011
% modified - Prabu, 10/09/2011 : added option to specify axes limits
%            Prabu, 3/25/2012 : set the font used in the plot to 'Times' and set plot axis as equal
%
% usage:
% create_phase_avg_plot_ver2(freq,amp,nBins,nCycles,xmin,xmax,ymin,ymax)
%
% freq - freq of test case
% amp - Amplitude of test case
% nBins - # of bins
% nCycles - # of cycles over which it is phase averaged
%
% Note: The plots generated have spatial dimensions that are in terms of
% cylinder diameter

stub = make_stub_rot_cyl(freq,amp);
dir_name = make_dir_rot_cyl(freq,amp);
% stub='f445_a5_';
% dir_name='f445_a5';
% dname=pwd;
% size_dname=size(dname);
% dname=dname(size_dname(1,2)-8:size_dname(1,2));
% if ~strcmp(dname,dir_name)
% cd(dir_name);
% end
i=1;
for j=1:8:nBins
    fname = ['avg_' stub int2str(j) '.vor'];
    if j<10
        fname = ['avg_' stub '0' int2str(j) '.vor'];
    end
    [xw,yw,w] = read_vor(fname);
    subplot(3,2,i)
    set(gca,'FontName','Times','fontsize',10);
    vn=[-2.6:0.5:-0.5]; % contour levels
    vp=[0.5:0.5:2.6]; % contour levels
    contour(xw,yw,w,vn,'--k','LineWidth',0.5);
    hold on;
    contour(xw,yw,w,vp,'-k','LineWidth',0.5);
    
    set(gcf,'renderer','zbuffer');
    fill([0 1.2 1.2 0],[-2 -2 2 2],[0.85 0.85 0.85])
    xc = 0; yc = 0; radius = 0.5;
    xvals = [xc-radius:radius/25:xc+radius];
    yvals_u = yc + sqrt(radius*radius - (xvals-xc).*(xvals-xc));
    yvals_l = yc - sqrt(radius*radius - (xvals-xc).*(xvals-xc));
    xvals = [xvals,xvals(length(xvals):-1:1)];
    fill(xvals,[yvals_u,yvals_l],'k')
    hold off;
    %     contour(xw,yw,w,[vn,vp]);%,':k','LineWidth',0.75
    %     caxis([-2.6,2.6]);
    %     colormap('Gray');
    %     hold on;
    %     contour(xw,yw,w,vn);%,'-k','LineWidth',0.75
    %     hold off;
    axis equal;
%     xlabel('{\itx / D}');
%     ylabel('{\ity / D}');
    xlim([xmin xmax]);
    ylim([ymin ymax]);
%     stub_title = ['\phi = \pi' int2str(j-1) ];
%     title(stub_title);
    set(get(gca,'Title'),'FontName','Times','fontsize',10)
    set(get(gca,'xlabel'),'FontName','Times','fontsize',10)
    set(get(gca,'ylabel'),'FontName','Times','fontsize',10)
    i=i+1;
end
stub=[stub 'phase_averaged_vorticity_nCycles_' int2str(nCycles)];
cd('..');
% print(gcf,stub,'-zbuffer','-r300','-dbmp');
% stub=[stub '.fig'];
% save figure
% saveas(gcf,stub);
% close;
end
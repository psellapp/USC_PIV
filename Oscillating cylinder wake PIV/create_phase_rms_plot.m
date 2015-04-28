function create_phase_rms_plot(freq,amp,nBins,nCycles)
% 
% created by:
% Prabu Sellappan - August 2010
% 
% usage:
% create_phase_rms_plot(freq,amp,nBins)
%
% freq - freq of test case
% amp - Amplitude of test case
% nBins - # of bins 
% nCycles - # of cycles over which it is phase averaged
%

stub = make_stub_rot_cyl(freq,amp);
i=1;
for j=1:3:nBins
    fname = ['rms_' stub int2str(j) '.vor'];
    if j<10
        fname = ['rms_' stub '0' int2str(j) '.vor'];
    end
    [xw,yw,w] = read_vor(fname);
    subplot(4,4,i)
    contourf(xw,yw,w,[-6:-1,1:6]);
    stub_title = ['Bin # -' int2str(j)];
    title(stub_title);
    i=i+1;
end
stub=[stub 'phase_rms_vorticity_nCycles_' int2str(nCycles) '.fig'];
cd('..');
% save figure
saveas(gcf,stub);
close;
end
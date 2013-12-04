function create_phase_avg_movie(freq,amp,nBins)
% created by:
% Prabu Sellappan - Summer 2010
% 
% usage:
% create_phase_avg_movie(freq,amp,nBins)
%
% Creates a movie of the phase averaged vorticity 
% freq - freq of test case
% amp - Amplitude of test case
% nBins - # of bins 
%

stub = make_stub_rot_cyl(freq,amp);
F(1:nBins)=struct('cdata', [],'colormap', []);
i=1;
for j=1:nBins
    fname = ['avg_' stub int2str(j) '.vor'];
    if j<10
        fname = ['avg_' stub '0' int2str(j) '.vor'];
    end
    [xw,yw,w] = read_vor(fname);
    contourf(xw,yw,w,[-6:-1,1:6]);
    hold on
    plot(0.03,(-0.03:0.001:0.02),0.05,(-0.03:0.001:0.02),'-.k')
    hold off
    F(i)=getframe(gcf);
    i=i+1;
end
close;
stub=[stub 'phase_averaged_vorticity' '.avi'];
% Create AVI file.
cd('..');
movie2avi(F,stub,'compression','None','fps',12.5);


end
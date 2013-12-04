function phase_avg_vor(freq,amp,nBins,nCycles,nFrames,fRate,xmin,xmax,ymin,ymax,D,U)
% 
% created by:
% Prabu Sellappan - August 2010
% 
% modified - Prabu, 10/09/2011, 3.37AM (yes! grad school FTW )
%          - added option to add axes limits
%          - modified code to call function phase_averaged_vor_mod which
%          converts all the spatial dimensions to cylinder diameters
% 
% usage:
% phase_avg_vor(freq,amp,nBins,nCycles,nFrames,fRate,xmin,xmax,ymin,ymax,D,U)
%
% Phase averages the vorticity and generates subplots showing the average
% vorticity at various phases
%
% freq,amp - frequency and amplitude of the test case
% nBins - # of bins to group the phases
% nCycles - # of cycles over which to phase average. This depends on the
%           wake mode synchronization
% nFrames - # of frames to process. Assumes that the first frame is either 0 or 1
% fRate - camera frame rate in fps
% xmin,xmax,ymin,ymax - axes limits for the plots
% D - cylinder diameter; U - free-stream velocity (Units for D and U have to be
% consistent with the units in the dpiv.par file used for processing). 
%

% generate the filename stub for this case
stub = make_stub_rot_cyl(freq,amp);
% generate name of subdirectory for this case and make it the
% active directory
dir = make_dir_rot_cyl(freq,amp);
% stub='f445_a5_';
% dir='f445_a5';
cd(dir);

% delete phase averaging files from previous runs. 
delete('avg*');
delete('rms*');

firstFrame = 1;
if (exist([stub '0.raw'],'file'))==2
    firstFrame = 0;
end
lastFrame = firstFrame + nFrames;
freqz = freq/nCycles; 

% SET THE NUMBER OF DIGITS UP TO WHICH TO PAD FRAME NUMBERS WITH LEADING
% ZEROS (1 for no padding)
ndig = 1;

% Generate phase list
framenums = firstFrame:2:lastFrame;
ElapsedTime = (framenums-firstFrame)/fRate;
phases = ElapsedTime * freqz;
phases = (phases - floor(phases))*2*pi();
ss_info(:,1) = framenums;
ss_info(:,2) = phases;
phi_limits = zeros(nBins,2);
phi_width = max(phases)/nBins;
for i=1:nBins
    phi_limits(i,1) = (i*phi_width)-phi_width;
    phi_limits(i,2) = i*phi_width;
end
% call function to perform phase averaging
phase_averaged_vor_mod(ss_info,phi_limits,stub,'.vor',ndig,['avg_' stub],['rms_' stub],'.vor','.vor',D,U);
% call function to create subplots
create_phase_avg_plot_ver2(freq,amp,nBins,nCycles,xmin,xmax,ymin,ymax);
disp('Plot of phase averaged vorticity created');
end

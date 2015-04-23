function stub = make_stub_rot_cyl(freq,amp)
% usage: stub = make_stub_rot_cyl(freq,amp)
%
% constructs the stub for use in image and DPIV file names for differetn
% rotationally oscillating cylinder cases
%
% freq = frequency in Hz 
%
% amp = peak-to-peak amplitude of oscillations in degrees
%
% format of stub is 'f'<round(100*freq)[3 digits]>_a<amp[2 digits]>_

stub = ['f' num2str(round(100*freq),'%03d') '_a' num2str(round(amp),'%02d') '_'];

return
% end of make_stub_rot_cyl


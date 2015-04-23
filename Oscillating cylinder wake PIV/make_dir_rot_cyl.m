function dir = make_dir_rot_cyl(freq,amp)
% usage: dir = make_dir_rot_cyl(freq,amp)
%
% constructs the sub-directory name for use in image and DPIV file names for differetn
% rotationally oscillating cylinder cases
%
% freq = frequency in Hz 
%
% amp = peak-to-peak amplitude of oscillations in degrees
%
% format of dir is 'f'<round(100*freq)[3 digits]>_a<amp[2 digits]>
% this is the same as the format for the corresponding stub without the
% final underscore

dir = ['f' num2str(round(100*freq),'%03d') '_a' num2str(round(amp),'%02d')];

return
% end of make_dir_rot_cyl


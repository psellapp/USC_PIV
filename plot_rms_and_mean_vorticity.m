function plot_rms_and_mean_vorticity(stub,x_shaded_ext,D,U)
% plot RMS and mean vorticity as two subplots. 
% 
% Created: Prabu Sellappan, 4/5/2013
% U - freestream velocity; D-cylinder diameter
% nBins = 48
% x_shaded_ext - extent of shaded region in plot. should be specified in
% normalized units of x/D.

subplot(1,2,1)
mean_vorticity(stub,48,x_shaded_ext);
subplot(1,2,2)
RMS_vorticity(stub,48,D,U,x_shaded_ext);
end
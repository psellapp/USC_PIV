function [rms_vor] = locate_max_RMS_vorticity(stub,nBins,D,U_fs)
%
% Calculate the location of max rms of vorticity for a case with each phase
% equally represented. Mean values are calculated using balanced full-cycle
% averaging. Assumes that the incoming avg vorticity values have been normalized but RMS
% values have not been normalized, hence they are normalized here.
%
% -Prabu Sellappan, 4/6/2013.
%
% usage: [rms_vor] = locate_max_RMS_vorticity(stub,nBins,D,U_fs)
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

[~,h] = max(rms_vor(:));
[y_l,x_l]=ind2sub(size(rms_vor),h)
x_D = x(x_l)
y_D = y(length(y)-y_l)
cd ..
end
function [phi_bins,ss_bins] = phase_averaged_vor_mod(ss_info,phi_limits,stub,ext,ndigits,avg_stub,rms_stub,avg_ext,rms_ext,D,U)
% usage: [phi_bins,ss_bins] = phase_averaged_vor_mod(ss_info,phi_limits,stub,ext,ndigits,avg_stub,rms_stub,avg_ext,rms_ext,D,U)
% finds the averaged vorticity fields and saves to files files;
% bins for averaging are specified in the function call by phi_limits; phi_bins and ss_bins are saved in a 
% mat file named avg_stub.mat
% 
% created by: Someone in the Gharib group! :)
% modified: Prabu Sellappan, 10/09/2011, 3.44 AM (Yes, very much sleep deprived while coding this. Use with caution!)
% In lines 67-69, values for cylinder diameter and free-stream velocity
% have been hardcoded. 
%
% ss_info = snapshot_info
%           Nx2 matrix where col 1 is frame #, 
%                            col 2 is phase
%                               the range of phases is assumed to be
%                               0 <= phi <
%                                  1.5*phi_limits(length(phi_limits),2) -
%                                  0.5*phi_limits(length(phi_limits),1)
%                               all phase angles not in this range will be shifted into this range
%           (N is the total number of frames)
% phi_limits = Mx2 matrix where col 1 is lowest phi to include in bin
%                               col 2 is highest phi to include in bin
%              (M is the total number of bins specified)
%              if lowest phi > highest phi, assumes the range spans the
%              branch cut
% stub = beginning part of the file name
% ext = end of the file name
% ndigits = number of digits in the frame number part of the file name (for adding leading zeros)
% avg_stub = beginning of the file name where final data is stored
% avg_ext = end on the file name where final data is stored
% rms_stub = beginning of the file name where final data is stored
% rms_ext = end on the file name where final data is stored
% D - cylinder diameter; U - free-stream velocity
%
% phi_bins = average phi of the snapshots included in each bin
% ss_bins = snapshot numbers of the snapshots used in each bin (each column
%           is one bin; extra entries to fill up matrix are -1

% allocate the variables to record which shanpshots are averaged and the
% mean phase
phi_bins = zeros(size(phi_limits,1),1);
ss_bins = -ones(length(ss_info),length(phi_limits));

% determine the range of phase angles
maxphi = 1.5*phi_limits(length(phi_limits),2) - 0.5*phi_limits(length(phi_limits),1);

% shift phase angles into the range 0<=phi<phi_max
ss_info(:,2) = rem(ss_info(:,2),maxphi) + maxphi*(ss_info(:,2)<0);

for i = 1:size(phi_limits,1)
%     i
    % set the limits for the bin
    phi_min = phi_limits(i,1);
    phi_max = phi_limits(i,2);
    % find the snapshots that fall within the limits for the bin
    if (phi_min < phi_max)
        snapshots = ss_info(ss_info(:,2)>=phi_min & ss_info(:,2)<=phi_max,:);
        phi_bins(i) = mean(snapshots(:,2));
    else
        snapshots = ss_info(ss_info(:,2)>=phi_min | ss_info(:,2)<=phi_max,:);
        snapshots(snapshots(:,2)>=phi_min,2) = snapshots(snapshots(:,2)>=phi_min,2) - 2*pi;
        phi_bins(i) = mean(snapshots(:,2)) + maxphi*(mean(snapshots(:,2))<0);
    end
    ss_bins(1:size(snapshots,1),i) = snapshots(:,1);
    if size(snapshots,1)>0
        % find the average vorticity field of those snapshots
        [x,y,wbar,wrms] = average_vor(stub,ext,ndigits,snapshots(:,1));
%         ********************* This code was added on 10/09/2011 by Prabu
        wbar = wbar*D/U; % Non-dimensionalize vorticity by (D/U)
        x = x/D;%To non-dimensionalize the spatial dimensions in terms of cylinder diameter
        y = y/D;
%         *********************
        % save to file
        lz = ''; for j = 1:floor(log10(size(phi_limits,1)))-floor(log10(i)), lz = [lz '0']; end
        write_vor(x,y,wbar,[avg_stub lz num2str(i) avg_ext]);
        write_vor(x,y,wrms,[rms_stub lz num2str(i) rms_ext]);
    end
end

% remove extra rows from ss_bins
j = size(ss_bins,1);
while (ss_bins(j,:) == -ones(1,size(ss_bins,2)))
    j = j - 1;
end
ss_bins = ss_bins(1:j,:);

save('-MAT',[avg_stub '.mat'],'phi_bins','ss_bins')

function [filenameu,u_vel,filenamev,v_vel,fstatus] = disp2vel(filename,deltax,deltay,delta_t,save_flag)
%
% Calculate velocity from displacement and pulse separation time and, optionally, save them to disk
%
% created: Prabu, 1/5/2015
%
% ============Output================
% filenameu, filenamev - filenames of u and v velocity files
% u_vel,v_vel - 2-D arrays of velocity fields
%
% ============Input=================
% filename - filename including filenumber. If calling independently, make sure they are
%            consistent with the dispalcement fields read in
% deltax, deltay - 2-D displacement fields
% delta_t - pulse separation time, in microseconds
% save_flag - set to 1 to save dispalcement fields to disk, set to 0 to
%             prevent saving to disk

delta_t = delta_t*0.000001; %convert to seconds
u_vel = deltax./delta_t;
v_vel = deltay./delta_t;

filenameu = [filename '_u_vel.mat'];
filenamev = [filename '_v_vel.mat'];
if save_flag
    save(filenameu,'u_vel')
    save(filenamev,'v_vel')
end

fstatus = 1; %if you got to this point everything's probably OK
end

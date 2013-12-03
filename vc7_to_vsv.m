function [x_grid,y_grid,u_vel,v_vel,w_vel] = vc7_to_vsv(file_path,xy_crop_array,dotV_filename)
%
% Extracts the best choice values of the three velocity components (u,v,w) from
% VC7 files produced by DaVis. Extracted (u,v) data is cropped and writen to a
% binary file with .v extension in a form that can be read by VSV. VC7 files 
% should be in IType=5 configuration containing 3 velocity components.
% Converts length scales to cm and velocities to cm/s.
%
% Created: Prabu Sellappan, 11/5/2013.
%
% Input:
%
% file_path = string containing the file path to the VC7 file. Absolute path has
% to be provided unless the .vc7 file is in the current working directory or is on the
% matlab path. For compatibility with external programs that call this
% function, the file extension '.vc7' should be included in filepath by the
% user and is not automatically added.
% dotV_filename = filename stub for the binary file. .v extension will be
% added automatically and need not be included by user.
% xy_crop_array = [left right bottom top] margins. Specify edges of velocity field. 
% Default is [0 1 1 0]. Crop margin values are normalized between 0 and 1. 
% For example, [0.2 0.9 0 0.8] would crop 20% from left margin, 10% from right
% margin, leave the bottom margin intact and crop 20% from top margin.
%
% Output:
%
% u_vel,v_vel,w_vel = 2D arrays of the three velocity components.
% x_grid,y_grid = 2D array of scaled x and y positions as single
% precision values.
%
% Note: This code requires the readimx toolbox provided by DaVis to be installed
% on the Matlab path. More information about the structure S and its attributes 
% can be found in the readimx manual included with the toolbox.


S = readimx(file_path); %read in .vc7 file to structure named S

u_vel = zeros(S.Nx,S.Ny); %pre-allocate velocity arrays
v_vel = u_vel;
w_vel = u_vel;

truth_table_1 = S.Data(1:S.Nx,1:S.Ny) == 1; %prepare logical array containing truth tables for each possible "best-choice" value selected by DaVis
truth_table_2 = S.Data(1:S.Nx,1:S.Ny) == 2;
truth_table_3 = S.Data(1:S.Nx,1:S.Ny) == 3;
truth_table_4 = S.Data(1:S.Nx,1:S.Ny) == 4;

%extract velocity vectors from appropriate locations using the best-choice values
u_vel = u_vel + S.Data(1:S.Nx,S.Ny+1:S.Ny*2).*truth_table_1 + S.Data(1:S.Nx,(S.Ny*4)+1:(S.Ny*5)).*truth_table_2 + S.Data(1:S.Nx,(S.Ny*7)+1:(S.Ny*8)).*truth_table_3 +S.Data(1:S.Nx,(S.Ny*10)+1:(S.Ny*11)).*truth_table_4;
v_vel = v_vel + S.Data(1:S.Nx,(S.Ny*2)+1:S.Ny*3).*truth_table_1 + S.Data(1:S.Nx,(S.Ny*5)+1:(S.Ny*6)).*truth_table_2 + S.Data(1:S.Nx,(S.Ny*8)+1:(S.Ny*9)).*truth_table_3 +S.Data(1:S.Nx,(S.Ny*11)+1:(S.Ny*12)).*truth_table_4;
w_vel = w_vel + S.Data(1:S.Nx,(S.Ny*3)+1:S.Ny*4).*truth_table_1 + S.Data(1:S.Nx,(S.Ny*6)+1:(S.Ny*7)).*truth_table_2 + S.Data(1:S.Nx,(S.Ny*9)+1:(S.Ny*10)).*truth_table_3 +S.Data(1:S.Nx,(S.Ny*12)+1:(S.Ny*13)).*truth_table_4;

%calculate scaling factor to scale velocity values to cm/s
switch S.UnitI
    case 'mm/s'
        I_scaling_factor = 0.1;
    case 'cm/s'
        I_scaling_factor = 1;
    case 'm/s'
        I_scaling_factor = 100;
    otherwise
        I_scaling_factor = 1;
        warning('Velocity values are in some unexpected units. Program execution will continue, but you may be in for a nasty surprise')
end

u_vel = (u_vel' * S.ScaleI(1,1) + S.ScaleI(2,1)).* I_scaling_factor; %rotate velocity fields so that flow is horizontal
v_vel = (v_vel' * S.ScaleI(1,1) + S.ScaleI(2,1)).* I_scaling_factor; %scale the magnitude of each velocity vector using the linear intensity scaling parameter
w_vel = (w_vel' * S.ScaleI(1,1) + S.ScaleI(2,1)).* I_scaling_factor;

x_pos_vec = single(((1:S.Nx)-0.5)*S.Grid*S.ScaleX(1,1)+S.ScaleX(2,1) ); %x-position vector
y_pos_vec = single(((1:S.Ny)-0.5)*S.Grid*S.ScaleY(1,1)+S.ScaleY(2,1) ); %y-position vector

%scale length values appropriately to units of cm since VSV expects everything to be in
%those units
switch S.UnitX
    case 'mm'
        x_scaling_factor = 0.1;
    case 'cm'
        x_scaling_factor = 1;
    case 'm'
        x_scaling_factor = 100;
    otherwise
        x_scaling_factor = 1;
        warning('Dimensional unit of x values was something unexpected. Program execution will continue, but you might be in for some grief later on')
end
x_pos_vec = x_pos_vec .* x_scaling_factor;

switch S.UnitY
    case 'mm'
        y_scaling_factor = 0.1;
    case 'cm'
        y_scaling_factor = 1;
    case 'm'
        y_scaling_factor = 100;
    otherwise
        y_scaling_factor = 1;
        warning('Dimensional unit of y values was something unexpected. Program execution will continue, but you might be in for some grief later on')
end
y_pos_vec = y_pos_vec .* y_scaling_factor;
[x_grid,y_grid] = meshgrid(x_pos_vec,y_pos_vec);

if isempty(xy_crop_array)
    xy_crop_array = [0 1 0 1];
end
if xy_crop_array(1) >= xy_crop_array(2) || xy_crop_array(3) <= xy_crop_array(4)
    disp('Image crop sizes are wrong')
    return;
end
left_margin = 1+floor(size(u_vel,2)*xy_crop_array(1));
right_margin = size(u_vel,2) - round(size(u_vel,2)*(1-xy_crop_array(2)));
bottom_margin = size(u_vel,1) - round(size(u_vel,1)*(1-xy_crop_array(3)));
top_margin = 1+floor(size(u_vel,1)*xy_crop_array(4));
u_vel_cropped = u_vel(top_margin:bottom_margin,left_margin:right_margin);
v_vel_cropped = v_vel(top_margin:bottom_margin,left_margin:right_margin);
x_grid_cropped = x_grid(top_margin:bottom_margin,left_margin:right_margin);
y_grid_cropped = y_grid(top_margin:bottom_margin,left_margin:right_margin);
% write .v file
fid = fopen([dotV_filename '.v'], 'w');
fwrite(fid, uint32(size(u_vel_cropped,2)*size(u_vel_cropped,1)), 'uint32'); %write a binary file with 4-byte integer data
fclose(fid);
dotV_array = zeros(1,(size(u_vel_cropped,2)*size(u_vel_cropped,1)*4),'single');
%Reshape the 2D arrays to write them to the .v file row-by-row, bottom-to-top
reshape_array = @(rearray)(flipud(rearray))';
x_grid_reshaped = reshape_array(x_grid_cropped);
y_grid_reshaped = reshape_array(y_grid_cropped);
u_vel_reshaped = reshape_array(u_vel_cropped);
v_vel_reshaped = reshape_array(v_vel_cropped);
dotV_array(1:4:end) = x_grid_reshaped(1:end);
dotV_array(2:4:end) = y_grid_reshaped(1:end);
dotV_array(3:4:end) = u_vel_reshaped(1:end);
dotV_array(4:4:end) = -v_vel_reshaped(1:end);%Due to one of many quirks in DaVis (Having an inverted Y-axis, i.e, Y is positive as you go down from the origin at the top-right corner) I have added a minus sign to invert the velocity values so that v velocity stays correct.
fid = fopen([dotV_filename '.v'], 'a+');
fwrite(fid, dotV_array, 'single'); %append to binary file with data arranged as {n,(x y u v)*n}
fclose(fid);

end
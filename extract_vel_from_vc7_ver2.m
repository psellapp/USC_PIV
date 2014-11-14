function [x_grid,y_grid,u_vel,v_vel,w_vel] = extract_vel_from_vc7_ver2(file_path,dotV_flag,dotV_filename)
% 
% Extracts the best choice values of the three velocity components (u,v,w) from 
% VC7 files produced by DaVis. VC7 files should be in IType=5 configuration containing 3 velocity components.  
% If dotV_flag is set to 1, writes the {u,v} velocity field to a binary file with .v
% extension that can be read by VSV. Converts length scales to cm and
% velocities to cm/s.
% 
% Created: Prabu Sellappan, 6/4/2013. 
% 
% modified:
% Ver.2.0 : Prabu Sellappan, 7/1/2013.
%           - changed scaling function to I = a · I[i,j] + b at pixel [i,j]
%           - function now returns scaled x and y positions along with velocities
%           - included option to write to binary file
% Ver.2.1 : Prabu Sellappan, 7/8/2013.
%           - included x, y, and intensity scaling to convert all length scales to
%             cm and velocities to cm/s.
% Ver.2.2 : Prabu Sellappan, 8/19/2013.
%           - included code to reshape the arrays that are written to the .v
%             files. VSV expects data to be written row-by-row, bottom-to-top
% 
% Input: 
% 
% file_path = string containing the file path to the VC7 file. Absolute path has to be provided,
% unless the .vc7 file is in the current working directory or is on the matlab path.
% dotV_flag = set to 1 to write a binary file with .v extension, set to 0
% to prevent writing to file.
% dotV_filename = filename stub for the binary file. .v extension will be
% added automatically
% 
% Output:
% 
% u_vel,v_vel,w_vel = 2D arrays of the three velocity components. If w_vel is not required, supress
% using tilde operator when calling the function. 
% x_grid,y_grid = 2D array of scaled x and y positions as single
% precision values.
% 
% Note: This code requires the readimx toolbox provided by DaVis to be installed on the Matlab
% path. More information about the structure S and its attributes can be found in the readimx manual included with the toolbox. 

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
        warning('Velocity values are in some unexpected units. Program execution will continue, but you may be in for a nasty surprise soon')
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
        warning('Dimensional units of x values was something unexpected. Program execution will continue, but you might be in for some grief later on')
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
        warning('Dimensional units of y values was something unexpected. Program execution will continue, but you might be in for some grief later on')
end
y_pos_vec = y_pos_vec .* y_scaling_factor;

[x_grid,y_grid] = meshgrid(x_pos_vec,y_pos_vec);

if dotV_flag
    fid = fopen([dotV_filename '.v'], 'w');
    fwrite(fid, uint32(S.Nx*S.Ny), 'uint32'); %write a binary file with 4-byte integer data
    fclose(fid);
    dotV_array = zeros(1,(S.Nx*S.Ny*4),'single');
    %Reshape the 2D arrays to write them to the .v file row-by-row, bottom-to-top   
    reshape_array = @(rearray)(flipud(rearray))';
    x_grid_reshaped = reshape_array(x_grid);
    y_grid_reshaped = reshape_array(y_grid);
    u_vel_reshaped = reshape_array(u_vel);
    v_vel_reshaped = reshape_array(v_vel);
    dotV_array(1:4:end) = x_grid_reshaped(1:end);    
    dotV_array(2:4:end) = y_grid_reshaped(1:end);
    dotV_array(3:4:end) = u_vel_reshaped(1:end);
    dotV_array(4:4:end) = -v_vel_reshaped(1:end);%Due to one of many quirks in DaVis (Having an inverted Y-axis, i.e, Y is positive as you go down from the origin at the top-right corner) I have added a minus sign to invert the velocity values so that v velocity stays correct.
    fid = fopen([dotV_filename '.v'], 'a+');
    fwrite(fid, dotV_array, 'single'); %append to binary file with data arranged as {n,(x y u v)*n} 
    fclose(fid);
end

end
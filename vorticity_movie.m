function vorticity_movie(filename_stub,first_frame,last_frame,cam_frame_rate,cmin,cmax,cinc)
%
% Create a movie of vorticity fields.
%
% Created: Prabu Sellappan, 7/8/2013.
%
% Modified: - Prabu Sellappan, 11/13/2014
%             Included comment to clarify required MATLAB functions
%
% Inputs: filename_stub = filename placeholder.
%         first_frame,last_frame = first and last files in your file
%         sequence
%         Example: If your files are named 'B000006.vc7,...,B000123.vc7',
%                  then, filename_stub = B000, first_frame = 6, last_frame = 123
%
%         cam_frame_rate = camera frame rate, i.e., image acquisition rate
%         cmin,cmax,cinc = check help section of vorticity_plot function
%
% Requires the custom MATLAB function extract_vel_from_vc7_ver2 to be on system path. 

warning('Warn:Filesize','Video files produced by this function are uncompressed and, therefore, are EXTREMELY big!!')
warning('Warn:Dropbox','Do not run this function on files stored on shared Dropbox folders. \n Dropbox will automatically try to sync it on every computer that is sharing this folder and make everyone very unhappy. \n Also, Trystan will yell at you through SMS, and rightfully so.')
result = input('Are you operating in a shared Dropbox folder? Enter y/n.','s');
if strcmpi(result,'n')
    disp('You shall proceed!')
else
    error('You suck! Change your working directory!');
end
numFrames = (last_frame - first_frame)+1;
F(1:numFrames) = struct('cdata', [],'colormap', []);
i = 1;
for j = first_frame:last_frame
    %     tic
    fname = [filename_stub num2str(j,'%03d')];
    [x_grid,y_grid,u_vel,v_vel,~] = extract_vel_from_vc7_ver2([fname '.vc7'],0,[]);
    [~,~,~] = vorticity_plot(x_grid,y_grid,u_vel,v_vel,cmin,cmax,cinc);
    F(i)=getframe(gcf);
    clear x_grid y_grid u_vel v_vel;
    i=i+1;
    %     toc
end
close(gcf);
% tic
% Create AVI file.
movie2avi(F,[fname '.avi'],'compression','None','fps',cam_frame_rate/2);
%frame rate of movie is half of camera frame rate because two images are required to produce one velocity/vorticity field in DPIV
% toc

end
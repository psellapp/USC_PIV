function [proc_params]=generate_param_list(nFrames)
%
% ~created by: Prabu Sellappan
%              9/29/2010
%
% usage: [proc_params]=generate_param_list(nFrames)
%
% nFrames - number of frames in each test case. This can be used to decrease
%           the number of frames to be processed by other functions that 
%           use this function to generate parameter lists, even if
%           the actual number of frames present in folder is higher.
% 
% Generates a list of the test case subfolders in the parent directory from which it is run.
% It expects test case folders to be named in the format f###_a###. eg., f156_a40 which is the
% case with freq 1.56 and amplitude 40. It extracts the frequency,
% amplitude, first frame and last frame for each test case and stores it in
% a variable 'proc_params' and gives it as output.
%

[dum_list] = dir('f*');
k=1;
for j=1:length(dum_list)
    if dum_list(j).isdir == 1
        dir_name = dum_list(j).name;
        freq(k,1)=(str2double([dir_name(2) dir_name(3) dir_name(4)])/100);
        [~,y]=size(dir_name);
        if y==8
            amp(k,1)=str2double([dir_name(7) dir_name(8)]);
        else amp(k,1)=str2double([dir_name(7) dir_name(8) dir_name(9)]);
        end
        cd(dir_name);
        firstFrame(k,1) = 1;
        if (exist([dir_name '_0.raw'],'file'))==2
            firstFrame(k,1) = 0;
        end
        lastFrame(k,1) = firstFrame(k,1) + nFrames;
        cd ..
        clear dir_name;
        k = k+1;
    end
end

proc_params(:,1)=amp;
proc_params(:,2)=freq;
proc_params(:,3)=firstFrame;
proc_params(:,4)=lastFrame;

end
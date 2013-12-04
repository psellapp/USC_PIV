
% *************************************************************************
% INSERT LISTS OF FREQUENCIES, AMPLITUDES AND FRAME NUMBER LIMTS HERE
% COULD SET THIS UP TO READ THE CASES FROM A TXT, XLS, MAT OR OTHER FILE
[proc_params]=generate_param_list(1000);
freq= proc_params(:,2);
amp = proc_params(:,1);
first = proc_params(:,3);
last = proc_params(:,4);

    % loop over cases and do processing
    for c = 1:length(freq)
        % generate name of subdirectory for this case and make it the
        % active directory
        dir = make_dir_rot_cyl(freq(c),amp(c));
        cd(dir);
        create_movie(freq(c),amp(c),first(c),last(c));
    end % for        

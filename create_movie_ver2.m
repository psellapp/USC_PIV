function create_movie_ver2(stub,ext,numframes)
% usage: create_movie_ver2(stub,ext,firstframe,lastframe)
% Function to create a movie of velocity or vorticity fields.
%
% written by: prabu sellappan - 4/24/2011
%
% stub - filename place holder ext - filename extension. either '.vel' or
%        '.vor'. depending on extension the corresponding function is called to read in the files
% numframes - # of frames to process
%
% This function has to be called from parent directory containing the test
% case sub-directory

cd(stub);
firstframe = 1;

if exist([stub '_0.raw']','file')==2 % Figure out if first frame number is 0 or 1
    firstframe = 0;
end
lastframe = firstframe + numframes;

stub=[stub '_'];
f(1:ceil(lastframe/2))=struct('cdata', [],'colormap', []);
i=1;
if strcmpi(ext,'.vor')
    for j=1:2:lastframe
        fname = [stub int2str(j) ext];
        if firstframe==0
            fname = [stub int2str(j-1) ext];
        end
        [xw,yw,w] = read_vor(fname);
        vn=[-2.6:0.4:-0.4]; % contour levels
        vp=[0.4:0.4:2.6]; % contour levels
        contourf(xw,yw,w,[vn,vp]);%,':k','LineWidth',0.75
        caxis([-2.6,2.6]);colormap('jet');colorbar;
        hold on
        plot(0.03,(-0.03:0.001:0.02),0.05,(-0.03:0.001:0.02),'-.k')
        hold off
        f(i)=getframe(gcf);
        i=i+1;
    end
    stub=[stub 'vorticity' '.avi'];
else
    for j=1:2:lastframe
        fname = [stub int2str(j) ext];
        if firstframe==0
            fname = [stub int2str(j-1) ext];
        end
        [x,y,u,v] = read_vel(fname);
        quiver(x,y,u,v);
        hold on
        plot(0.03,(-0.03:0.001:0.02),0.05,(-0.03:0.001:0.02),'-.k')
        hold off
        f(i)=getframe(gcf);
        i=i+1;
    end
    stub=[stub 'u_comp_velocity' '.avi'];
end
close;

% create avi file.
cd('..');
movie2avi(f,stub,'compression','none','fps',6.5);


end
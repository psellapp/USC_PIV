function [curlw,C,h] = vorticity_plot(x,y,u,v,cmin,cmax,cinc)
% 
% Calculate and plot the vorticity field by calculating the curl of the velocity
% field. 
% 
% Ver.1.0: Prabu Sellappan, 7/8/2013.
% 
% Inputs: x,y = (x,y) coordinates of the surface. Has to be in MESHGRID form. Output of extract_vel_from_vc7_ver2 can be piped here.
%         u,v = u and v velocity fields. Output of extract_vel_from_vc7_ver2 can be piped here. 
%         cmin,cmax,cinc = min, max, and increment of contour levels. Has
%         to be determined based on measurement uncertainty. 
% 
% Outputs: C = contour matrix
%          h = handle to contour object
%          curlw = vorticity field



curlw = curl(x(1,:),y(:,1),u,v); %curl of velocity field
%[C,h] = contourf(x,y,curlw,[cmin:cinc:-cinc,cinc:cinc:cmax]); %contour levels are set to exclude zero contour level
colormap(jet);
[C,h]=contour(x,y,curlw,-10:1:10);
colorbar('Location','EastOutside');

caxis([cmin cmax]);
colorbar;
xlabel('X');
ylabel('Y');

end

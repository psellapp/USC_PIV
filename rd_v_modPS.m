function [x,y,u,v,u2d,v2d,x2d,y2d,nx_v,ny_v,nv] = rd_v_modPS(fname)
% --------------------------------------------------------------------
% rd_v: read a standard .v or .u file
% The result is a list of nv points whose position is given by {x,y}
% and velocity components by {u,v}.  The points may or may not be on
% a regular grid.
% 
% Original: GRS.
% modified: Prabu. Removed global scope of variables. Function now returns
% those variables instead.

% --------------------------------------------------------------------
% global u2d v2d x2d y2d dx dy nx_v ny_v n_v missing n_miss;

% -----------------------------------------------------
% read file line-by-line into a buffer and compile list
% -----------------------------------------------------
fid=fopen(fname,'rb');
n_v=fread(fid,1,'int32'); nv=n_v;
buff=zeros(1,4);
x=zeros(1,n_v); y=zeros(1,n_v);
u=zeros(1,n_v); v=zeros(1,n_v);
for k=1:n_v
   buff=fread(fid,4,'float32');
   x(k)=buff(1);
   y(k)=buff(2);
   u(k)=buff(3);
   v(k)=buff(4);
end
fclose(fid);

% ------------------------------------------------
% find the smallest increments in x and y = dx, dy
% ------------------------------------------------
ic = 1:n_v-1;
icp = 2:n_v;
xdiff = x(icp)-x(ic);
ydiff = y(icp)-y(ic);

x0=min(x); y0=min(y);
dx=min(abs(xdiff));
tol=0.0001;
dy=min(ydiff(find(ydiff > tol)));

% -----------------------------------------------
% make integer array indices from {x,y} locations
% -----------------------------------------------
j_index=round((x-x0)/dx +1);
i_index=round((y-y0)/dy +1);
ny_v=max(i_index);
nx_v=max(j_index);

% ----------------------------------------------
% if row*col is wrong, most likely skipped a row
% ----------------------------------------------
while(nx_v*ny_v < n_v)
    ny_v=ny_v+1;
    warning = 'possible line skip - incrementing ny_v'
end

% ---------------------------
% make x2d, y2d vectors
% ---------------------------
x2d = min(x)+((1:nx_v)-1)*dx;
y2d = min(y)+((1:ny_v)-1)*dy;

% ------------------------------------------------------------------------
% make zero-filled rectangular arrays and fill with all non-missing values
% ------------------------------------------------------------------------
u2d=zeros(ny_v,nx_v);
v2d=u2d; missing=repmat(1,ny_v,nx_v);
for k=1:n_v
    %fprintf('%d %f\n',k,u(k));
    u2d(i_index(k),j_index(k))=u(k);
    v2d(i_index(k),j_index(k))=v(k);
    missing(i_index(k),j_index(k))=0;
end

% ----------------------------
% summarise missing statistics
% ----------------------------
n_miss=nx_v*ny_v-n_v;

return
end

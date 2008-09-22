% rayinv_load_v : reads a RAYINVR model file into a matlab structure
%
% CALL : 
%    v=rayinv_load_v('v.in')
%    [vvv,xx,yy,v]=rayinv_grid_v(v,xx,yy);
%
%    [vvv,xx,yy,v]=rayinv_grid_v
%    [vvv,xx,yy,v]=rayinv_grid_v('v.in',xx,yy);
%
%    imagesc(xx,yy,vvv);
%
% See also:: rayinv_grid_v
%
% RAYINVR : http://terra.rice.edu/department/faculty/zelt/rayinvr.html
%
function v=rayinv_load_v(filename)

if nargin==0
    filename='v.in';
end

fid=fopen(filename);
il=0;

while ~feof(fid)
    il=il+1;
    for i=1:3
        d1=sscanf(fgetl(fid),'%f')';
        d2=sscanf(fgetl(fid),'%f')';
        d3=sscanf(fgetl(fid),'%f')';       

        if d1(1)~=il
            disp(sprintf('%s : something has gone wrong',mfilename))
        end

        if i==1;
            v.x(il,:)=d1(2:length(d1));
            v.y(il,:)=d2(2:length(d2));
            v.pd(il,:)=d3(2:length(d3));
        elseif i==2
            v.x_u(il,:)=d1(2:length(d1));
            v.v_u(il,:)=d2(2:length(d2));
            v.pd_u(il,:)=d3(2:length(d3));
        else
            v.x_l(il,:)=d1(2:length(d1));
            v.v_l(il,:)=d2(2:length(d2));
            v.pd_l(il,:)=d3(2:length(d3));
        end
    end
    
    if (length(find(d3==-1))==4)
        % ENF OF DATA
        break
    end
end

d1=sscanf(fgetl(fid),'%f')';
d2=sscanf(fgetl(fid),'%f')';
il=il+1;
v.x(il,:)=d1(2);
v.y(il,:)=d2(2);


nl=il-1;;

fclose(fid);

dx=0.01;
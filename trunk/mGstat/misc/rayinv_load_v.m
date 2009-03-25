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
function [v,vv]=rayinv_load_v(filename)
%v_full=[];
if nargin==0
    filename='v.in';
end


%v.x=ones(100,100).*NaN;
%v.y=ones(100,100).*NaN;
%v.pd=ones(100,100).*NaN;

fid=fopen(filename);
n=0;
maxd=0;
while ~feof(fid)
    d=sscanf(fgetl(fid),'%f')';
    maxd=max([maxd (length(d)-1)]);
    n=n+1;
end

fclose(fid);
nl=floor(n/9);

v.x=ones(nl,maxd).*NaN;
v.y=ones(nl,maxd).*NaN;
v.pd=ones(nl,maxd).*NaN;

v.x_u=ones(nl,maxd).*NaN;
v.v_u=ones(nl,maxd).*NaN;
v.pd_u=ones(nl,maxd).*NaN;

v.x_l=ones(nl,maxd).*NaN;
v.v_l=ones(nl,maxd).*NaN;
v.pd_l=ones(nl,maxd).*NaN;


fid=fopen(filename);
il=0;
while ~feof(fid)
    il=il+1;
    for i=1:3
        
        d1=sscanf(fgetl(fid),'%f')';
        d2=sscanf(fgetl(fid),'%f')';
        d3=sscanf(fgetl(fid),'%f')';       

        nd1=length(d1);
        nd2=length(d2);
        nd3=length(d3);
        
        if d1(1)~=il
            disp(sprintf('%s : something has gone wrong',mfilename))
        end

        if i==1;
            v.x(il,1:nd1-1)=d1(2:nd1);
            v.y(il,1:nd2-1)=d2(2:nd2);
            v.pd(il,1:nd3-1)=d3(2:nd3);
        elseif i==2
            v.x_u(il,1:nd1-1)=d1(2:nd1);
            v.v_u(il,1:nd2-1)=d2(2:nd2);
            v.pd_u(il,1:nd3-1)=d3(2:nd3);
        else
            v.x_l(il,1:nd1-1)=d1(2:nd1);
            v.v_l(il,1:nd2-1)=d2(2:nd2);
            v.pd_l(il,1:nd3-1)=d3(2:nd3);
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

% MAKE SURE ALLE HORIZONS HAVE THE SAME LENGTH

x_unique=unique([v.x(:)]);x_unique=x_unique(~isnan(x_unique));x_unique=x_unique(:)';
for i=1:(nl);
    
    %% v.x and v.y
    vv.x(i,:)=x_unique;
    x_layer=v.x(i,:);x_layer=x_layer(~isnan(x_layer));

    d=v.y(i,:);d=d(~isnan(d));
    try
        vv.y(i,:)=interp1(x_layer,d,x_unique,'linear','extrap');
    catch
        keyboard
    end

    %% v.x_u and v.v_u
    x=v.x_u(i,:);x=x(~isnan(x));
    d=v.v_u(i,:);d=d(~isnan(d));
    
    vv.x_u(i,:)=x_unique;
    vv.v_u(i,:)=interp1(x,d,x_unique);
    
    %% v.x_l and v.v_l
    x=v.x_l(i,:);x=x(~isnan(x));
    d=v.v_l(i,:);d=d(~isnan(d));
    
    vv.x_l(i,:)=x_unique;
    vv.v_l(i,:)=interp1(x,d,x_unique);

end
% 
vv.x(nl+1,:)=x_unique;
vv.y(nl+1,:)=v.y(nl+1,1);


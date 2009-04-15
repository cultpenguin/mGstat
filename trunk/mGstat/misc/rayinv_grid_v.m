% rayinv_grid_v : generates a gridded from a RAYINVR model file
%
% CALL : 
%    v=rayinv_load_v('v.in')'
%    [vvv,xx,yy,v]=rayinv_grid_v(v,xx,yy);
%
%    [vvv,xx,yy,v]=rayinv_grid_v
%    [vvv,xx,yy,v]=rayinv_grid_v('v.in',xx,yy);
%
%    imagesc(xx,yy,vvv);
%
% See also:: rayinv_load_v
%
% RAYINVR : http://terra.rice.edu/department/faculty/zelt/rayinvr.html
%
function [vvv,xx,yy,v,region]=rayinv_grid_v(v,xx,yy,use_layers)

if nargin==0
    v='v.in';
end

if isstr(v)
    [v_old,v]=rayinv_load_v;
end

if isempty(v)
      [v_old,v]=rayinv_load_v('v.in');
end
if nargin<2
    dx=((max(v.x(:))-min(v.x(:)))./20);
    xx=min(v.x(:)):dx:max(v.x(:));
end
if nargin<3
    dy=((max(v.y(:))-min(v.y(:)))./200);
    yy=min(v.y(:)):dy:max(v.y(:));
end

if nargin<4
    use_layers=1:size(v.x_u,1);
end

[xxx,yyy]=meshgrid(xx,yy);
vvv=xxx.*0;


nl=size(v.x,1)-1;

for il=1:nl
    v.y_u(il,:)=v.y(il,:);    
    v.y_l(il,:)=v.y(il+1,:)-.0001;    
end


% INTERPOLATE TO EVERY X LOCATION
for i=1:size(v.x_u,1)
    vv.x_u(i,:)=interp1(v.x_u(i,:),v.x_u(i,:),xx,'linear','extrap');
    vv.x_l(i,:)=interp1(v.x_l(i,:),v.x_l(i,:),xx,'linear','extrap');

    vv.y_u(i,:)=interp1(v.x_u(i,:),v.y_u(i,:),xx,'linear','extrap');
    vv.y_l(i,:)=interp1(v.x_l(i,:),v.y_l(i,:),xx,'linear','extrap');

    vv.v_u(i,:)=interp1(v.x_u(i,:),v.v_u(i,:),xx,'linear','extrap');
    vv.v_l(i,:)=interp1(v.x_l(i,:),v.v_l(i,:),xx,'linear','extrap');

    vv.l_u(i,:)=vv.v_u(i,:).*0+i;
    vv.l_l(i,:)=vv.v_l(i,:).*0+i;

    
end


%xg=[v.x(1:nl,:);v.x(1:nl,:)];

xg=[vv.x_u(use_layers,:);vv.x_l(use_layers,:)];
yg=[vv.y_u(use_layers,:);vv.y_l(use_layers,:)];
vg=[vv.v_u(use_layers,:);vv.v_l(use_layers,:)];
vl=[vv.l_u(use_layers,:);vv.l_l(use_layers,:)];

%xg=[v.x_u;v.x_l];yg=[v.y_u;v.y_l];vg=[v.v_u;v.v_l];

% 2Dlinear interpolation
[vvv]=griddata(xg(:),yg(:),vg(:),xxx,yyy,'linear'); 

if nargout>4
    [region]=griddata(xg(:),yg(:),vl(:),xxx,yyy,'linear');
end

% MAKE SURE TOP NAN ROW IS REPLACED WITH NON NANS
iy=find(yy<min(v.y_u(1,:)));
vvv(iy,:)=vvv(max(iy)+1,:);

% 2D nearest neighbor interpolation of NaN data (outside modelgrid)
nnan=length(find(isnan(vvv)));
if (nnan>1)

    inan=find(isnan(vvv));
    nnan=find(~isnan(vvv));
    v_grid=griddata(xxx(nnan),yyy(nnan),vvv(nnan),xxx(inan),xxx(inan),'nearest');
    vvv(inan)=v_grid;
    %keyboard
    %
    %inan=find(~isnan(vvv));
    %[vvv]=griddata(xxx(inan),yyy(inan),vvv(inan),xxx,yyy,'nearest');

end


% 
% keyboard
% 
% 
% 
% for ix=1:length(xx)
%     
%     x_est=xx(ix);
%     for il=1:nl
%         x_layer(il,ix)=x_est;
%         y_u(il)=interp1(v.x(il,:),v.y(il,:),x_est,'spline');
%         y_l(il)=interp1(v.x(il,:),v.y(il+1,:),x_est,'spline')-0.00001;;
%         v_u(il)=interp1(v.x(il,:),v.v_u(il,:),x_est,'spline');
%         v_l(il)=interp1(v.x(il,:),v.v_l(il,:),x_est,'spline');
%                    
%     end    
%     v_u_layer(:,ix)=v_u;
%     v_l_layer(:,ix)=v_l;
%     
%     M=sortrows([[v_l';v_u'],[y_l';y_u']],2);
%     v_arr=M(:,1);
%     y_arr=M(:,2);
%    
%     
%     try
%     vvv(:,ix)=interp1(y_arr,v_arr,yy,'linear');
%     catch
%         keyboard
%     end
%     
% end

return


figure
contourf(xx,yy,vvv,[0:.5:7]);
set(gca,'Ydir','revers')
axis image
colorbar
daspect([2 1 1])

return

axis image
figure
plot(v_u,y_u,'k*',v_l,y_l,'r*',v_arr,y_arr,'g-*')
set(gca,'Ydir','revers')

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
function [vvv,xx,yy,v]=rayinv_grid_v(v,xx,yy)

if nargin==0
    v='v.in';
end

if isstr(v)
    v=rayinv_load_v;
end

if isempty(v)
     v=rayinv_load_v('v.in');
end
if nargin<2
    dx=((max(v.x(:))-min(v.x(:)))./20);
    xx=min(v.x(:)):dx:max(v.x(:));
end
if nargin<3
    dy=((max(v.y(:))-min(v.y(:)))./200);
    yy=min(v.y(:)):dy:max(v.y(:));
end

[xxx,yyy]=meshgrid(xx,yy);
vvv=xxx.*0;

nl=size(v.x,1)-1;
for ix=1:length(xx)
    
    x_est=xx(ix);
    for il=1:nl
        x_layer(il,ix)=x_est;
        y_u(il)=interp1(v.x(il,:),v.y(il,:),x_est);
        y_l(il)=interp1(v.x(il,:),v.y(il+1,:),x_est)-0.00001;;
        %y_l(il)=interp1(v.x(il,:),v.y(il,:),x_est);
        v_u(il)=interp1(v.x(il,:),v.v_u(il,:),x_est);
        v_l(il)=interp1(v.x(il,:),v.v_l(il,:),x_est);
                   
    end
    
    v_u_layer(:,ix)=v_u;
    v_l_layer(:,ix)=v_l;
    
    M=sortrows([[v_l';v_u'],[y_l';y_u']],2);
    v_arr=M(:,1);
    y_arr=M(:,2);
    
    vvv(:,ix)=interp1(y_arr,v_arr,yy,'linear');
    
    
end

figure
imagesc(xx,yy,vvv);
set(gca,'Ydir','revers')
axis image
colorbar
daspect([2 1 1])

return

axis image
figure
plot(v_u,y_u,'k*',v_l,y_l,'r*',v_arr,y_arr,'g-*')
set(gca,'Ydir','revers')

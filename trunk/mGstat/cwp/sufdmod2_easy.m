% sufdmod2_easy
%
% Call:
%    [vs,hs,ss,supar]=sufdmod2_easy(x,z,v,xs,zs,vsx,hsz,tmax,fmax);
function [vs,hs,ss,supar]=sufdmod2_easy(x,z,v,xs,zs,vsx,hsz,tmax,fmax);

if nargin==0
    x=10:10:1000;
    z=10:10:1000;
    v=ones(length(z),length(x)).*3000;
    xs=100;
    zs=100;
    vsx=110;
    hsz=110;
    [vs,hs,ss,supar]=sufdmod2_easy(x,z,v,xs,zs,vsx,hsz);
    %[vs,hs,ss,supar]=sufdmod2_easy(x,z,v,xs,zs,vsx,hsz,tmax,fmax);
    
    
    figure;
    subplot(1,3,1);imagesc(vs);title('vs')
    subplot(1,3,2);imagesc(hs);title('hs')
    subplot(1,3,3);imagesc(ss);title('ss')
    
    return
end

    supar.nx=length(x);
    supar.dx=x(2)-x(1);
    supar.fx=x(1);

    supar.nz=length(z);
    supar.dz=z(2)-z(1);
    supar.fz=z(1);

    supar.xs=xs;
    supar.zs=zs;
    
    supar.vsx=vsx;
    supar.hsz=hsz;
    
    if nargin<8
        tmax=.5;
    end
    supar.tmax=tmax;
    if nargin>8 supar.fmax=fmax; end
    if nargout==1
                [vs]=sufdmod2(v,supar);
    elseif nargout==2
                [vs,hs]=sufdmod2(v,supar);
    else
                [vs,hs,ss,supar]=sufdmod2(v,supar);
    end
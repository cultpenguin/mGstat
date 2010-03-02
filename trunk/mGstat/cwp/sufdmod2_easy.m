% sufdmod2_easy
%
% Call:
%    [vs,hs,ss]=sufdmod2_easy(x,z,v,xs,zs,vsx,hsz,tmax,fmax);
function [vs,hs,ss]=sufdmod2_easy(x,z,v,xs,zs,vsx,hsz,tmax,fmax);

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
                [vs,hs,ss]=sufdmod2(v,supar);
    end
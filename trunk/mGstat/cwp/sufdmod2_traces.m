% sufdmod2_traces
function w=sufdmod2_traces(x,z,v,xs,zs,vsx,vsx_yarr,hsz,hsz_xarr,tmax,fmax)
    
    
    for isou=1:length(xs);       
        
        [vs]=sufdmod2_easy(x,z,v,xs(isou),zs(isou),vsx,hsz,tmax);
        t=1:1:size(vs,1);
        
        [zz,tt]=meshgrid(z,t);
        for iy=1:length(vsx_yarr);
            w(:,iy,isou)=interp2(zz,tt,vs,0.*t+vsx_yarr(iy),t);
        end
    end
    % ALSO EXPORT hsz....
    
    
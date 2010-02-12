% visim_mask : conditional simulation on mask with unique properties
%
% Call:
%  V=visim_mask(V,mask,Vmask,doPlot);
%
function V=visim_mask(V,mask,Vmask,doPlot);

if nargin==0;
    load visim_default;
    x=1:1:150;y=1:1:160;        
    %x=[V.x(1):(V.x(2)-V.x(1)):50];
    %y=[V.y(1):(V.y(2)-V.y(1)):80];
    V.x=x;V.y=y;
    V=visim_init(V.x,V.y);
    V.debuglevel=-1;
    [xx,yy]=meshgrid(V.x,V.y);
    mask=zeros(size(xx))+1;
    dy=15;
    y_arr=[min(V.y):dy:max(V.y)];
    NR=length(y_arr);
    for iy=1:length(y_arr)
        mask(find(yy>=y_arr(iy)))=iy;
        Vmask{iy}.Va=V.Va;
        Vmask{iy}.Va.ang1=(iy/NR)*180-90;
        Vmask{iy}.Va.a_hmax=60;
        Vmask{iy}.Va.a_hmin=5;
        Vmask{iy}.gmean=10+(iy-1)*2;
    end
    
    V=visim_mask(V,mask,Vmask,1);
    return
end

if nargin<4
    doPlot=0;
end

try
   [p,f]=fileparts(V.parfile);
   if isempty(strfind(f,'masksim'))
       V.parfile=sprintf('%s_masksim.par',f);
   end
end


if V.nsim>1
   t0=now;
    for i=1:V.nsim;
        if i==1
            mgstat_verbose(sprintf('%s : real %d/%d',mfilename,i,V.nsim));
        else
            tnow=now;
            t_it=(tnow-t0)./(i-1);
            t_end=t0+V.nsim*t_it;
            t_left=(V.nsim*t_it);
            mgstat_verbose(sprintf('%s : real %d/%d finish:%s',mfilename,i,V.nsim,datestr(t_end)));
        end
        VV=V;
        VV.nsim=1;
        VV.rseed=V.rseed+i-1;
        VV=visim_mask(VV,mask,Vmask,doPlot);
        V.D(:,:,i)=VV.D(:,:,1);
    end
    [em,ev]=etype(V.D);
    V.etype.mean=em;
    V.etype.var=ev;
    
    return
end

[xx,yy]=meshgrid(V.x,V.y);

try;fconddata_org=V.fconddata;;end

Nr=length(Vmask);
for i=1:length(Vmask)
    mgstat_verbose(sprintf('%s : region %2d/%2d',mfilename,i,Nr),1)
    
    % SET CONDITIONAL
    if i>1
        icond_data=find(mask<i);
        x_cond=xx(icond_data);
        y_cond=yy(icond_data);
        z_cond=y_cond.*0+V.z(1);
        val_cond=V.D(:,:,1)';
        val_cond=val_cond(icond_data);
        V=visim_set_conditional_point(V,x_cond,y_cond,z_cond,val_cond);                             
    end
    
    % SET MASK
    use_mask=mask.*0;
    use_mask(find(mask==i))=1;
    V.mask.mask=use_mask;
    V.mask.write=1;
    
    % SET LOCAL GEOSTAT MODEL
    fn=fieldnames(Vmask{i});
    for j=1:length(fn);       
        V.(fn{j})=Vmask{i}.(fn{j});
    end
    
    % PERFORM CONDITIONAL SIMULATION
    V=visim(V);
    
    % UPDATE etype for LSQ mode
    if V.nsim==0
        if i==1;
            VLSQ.etype.mean=V.etype.mean;
            VLSQ.etype.var=V.etype.var;            
        else
            iuse=find(use_mask');
            VLSQ.etype.mean(iuse)=V.etype.mean(iuse);
            VLSQ.etype.var(iuse)=V.etype.var(iuse);                        
        end
    end
    
    % PLOT DATA
    if doPlot==1;
        if i>1;
            subplot(1,3,1);cla;imagesc(V.x,V.y,mask);colorbar;axis image;
        end
        subplot(1,3,2);imagesc(V.x,V.y,use_mask);axis image;
        subplot(1,3,3);imagesc(V.x,V.y,V.D(:,:,1)');axis image;
        drawnow;
    end
    
end

if (V.nsim==0)
    % UPDATE etype for LSQ mode    
    V.etype=VLSQ.etype;
end

% REMOVE CONDTIONAL MASK DATA
try
    V=rmfield(V,'fconddata');   
end
% REVERT TO ORIGINAL SET OF COND DATA
try
    V.fconddata=fconddata_org;
end

try
    V=rmfield(V,'mask');
end



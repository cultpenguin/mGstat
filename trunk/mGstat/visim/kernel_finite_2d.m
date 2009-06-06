function [Knorm,K,dt,options]=kernel_finite_2d(v_ref,x,y,S,R,freq,options);

if nargin<4, S=[x(4) y(4)];end
if nargin<5, R=[x(length(x)-4) y(4)];end
if nargin<6, freq=5;end

if nargin<7, options.null='';end

if ~isfield(options,'Ni');options.Ni=50;end
if ~isfield(options,'alpha'), options.alpha=1.5; end
if ~isfield(options,'doplot'), options.doplot=0; end
if ~isfield(options,'resample'), options.resample=0; end
if ~isfield(options,'pad'), options.pad=0; end
dx=x(2)-x(1);
dy=y(2)-y(1);
   
if options.resample>0
    dx_new=dx/options.resample;
    dy_new=dy/options.resample;
    
    x_new=[x(1)-dx_new : dx_new : max(x)+dx_new];
    y_new=[y(1)-dy_new : dy_new : max(y)+dy_new];
    [xx_new,yy_new]=meshgrid(x_new,y_new);
    [xx,yy]=meshgrid(x,y);
    mgstat_verbose(sprintf('%s : gridding denser grid for forward modeling',mfilename),10)
    v_new=griddata(xx(:),yy(:),v_ref(:),xx_new,yy_new,'nearest');
    
    Ni=options.Ni;
    resample=options.resample;
    options.resample=0;
    options.Ni=options.Ni*2;
    [Knorm,K,options]=kernel_finite_2d(v_new,x_new,y_new,S,R,freq,options);
    options.resample=resample;
    options.Ni=Ni;
    
    % RETURN ONLY THE REQUESTED/DOWNSAMPLED DATA
    ix=resample:resample:(length(x_new));
    iy=resample:resample:(length(y_new));
    
    Knorm=Knorm(iy,ix);
    K=K(iy,ix);
    
    return
    
end

if options.pad>0
    
    % FIRST RESAMPLE

    
    
    
    % THEN PAD
    x_1=([1:1:options.pad]-options.pad-1).*dx;
    x_2=[1:1:options.pad].*dx + max(x);;
    y_1=([1:1:options.pad]-options.pad-1).*dy;
    y_2=[1:1:options.pad].*dy + max(y);;
    x_new=[x_1,x,x_2];
    y_new=[y_1,y,y_2];
    [xx_new,yy_new]=meshgrid(x_new,y_new);
    [xx,yy]=meshgrid(x,y);
    v_new=griddata(xx(:),yy(:),v_ref(:),xx_new,yy_new,'nearest');
    
    resample=options.resample;
    pad=options.pad;
    options.resample=0;
    options.pad=0;    
    
    [Knorm,K,options]=kernel_finite_2d(v_new,x_new,y_new,S,R,freq,options);
    
    options.pad=pad;
    options.resample=resample;
    
    
    return
    
end


if options.doplot==1;
    figure(1);
    imagesc(x,y,v_ref);axis image;
    hold on
    plot(S(:,1),S(:,2),'r*');
    plot(R(:,1),R(:,2),'ko');
    hold off
end

dx=x(2)-x(1);
dy=y(2)-y(1);

% only call fast of time fields are not given as input

if isfield(options,'tS');tS=options.tS;end
if isfield(options,'tR');tR=options.tR;end

if isfield(options,'precal');
    n=length(options.precal.t);
    iis=find( (options.precal.pos(:,1)==S(1)) & (options.precal.pos(:,2)==S(2)) );
    iir=find( (options.precal.pos(:,1)==R(1)) & (options.precal.pos(:,2)==R(2)) );
    
    if ~isempty(iis), 
        tS=options.precal.t{iis(1)}; 
    else
        tS=fast_fd_2d(x,y,v_ref,S);
        n=n+1;
        options.precal.pos(n,:)=S;
        options.precal.t{n}=tS;
    end
    if ~isempty(iir), 
        tR=options.precal.t{iir(1)};
    else
        tR=fast_fd_2d(x,y,v_ref,R);
        n=n+1;
        options.precal.pos(n,:)=R;
        options.precal.t{n}=tR;
    end
end

if ~exist('tS','var');tS=fast_fd_2d(x,y,v_ref,S);end
if ~exist('tR','var');tR=fast_fd_2d(x,y,v_ref,R);end

% SAVE PRECAL
if ~isfield(options,'precal');
    options.precal.pos(1,:)=S;
    options.precal.pos(2,:)=R;
    options.precal.t{1}=tS;
    options.precal.t{2}=tR;
else
    n=length(options.precal.t);

end

dt=tS+tR;
dt=dt-min(dt(:));
if options.doplot==1;
    figure(2);
    subplot(3,1,1);contourf(x,y,tS);title('tS');axis image;set(gca,'ydir','revers')
    subplot(3,1,2);contourf(x,y,tR);title('tR');axis image;set(gca,'ydir','revers')
    subplot(3,1,3);contourf(x,y,dt,linspace(0,.25,11));title('dt');colorbar;axis image;set(gca,'ydir','revers')
end

%% CALCULATE KERNEL
K=munk_fresnel_2d(1./freq,dt,options.alpha);
if options.doplot==1;
    figure(3)
    imagesc(x,y,K);title('Kernel');colorbar;axis image;set(gca,'ydir','revers')
end

%% NOW FIND FIRST ARRIVAL AND RAYLENGTH
str_options = [.01 100000];
[xx,yy]=meshgrid(x,y);
[U,V]=gradient(tS);
start_point=R;
raypath = stream2(xx,yy,-U,-V,start_point(1),start_point(2),str_options);

raypath=raypath{1};


% GET RID OF DATA CLOSE TO SOURCE (DIST <DX)
r2=raypath;r2(:,1)=r2(:,1)-S(1);r2(:,2)=r2(:,2)-S(2);
dd=min([dx dy]);
distS=sqrt(r2(:,1).^2+r2(:,2).^2);
ClosePoints=find(distS<dd/10);
%igood=find(distS>dx/10);
if isempty(ClosePoints)
    igood=1:1:length(distS);
else
    igood=1:1:ClosePoints(1);
end
raypath=[raypath(igood,:);S(1:2)];

raylength=sum(sqrt(diff(raypath(:,1)).^2+diff(raypath(:,2)).^2));

if options.doplot==1;
    figure(4)
    imagesc(x,y,K);title('Kernel');colorbar;axis image;set(gca,'ydir','revers')
    hold on
    plot(raypath(:,1),raypath(:,2),'w-','linewidth',2)
    hold off
end
%%

ix=ceil((raypath(:,1)-(x(1)-dx/2))./dx);
iy=ceil((raypath(:,2)-(y(1)-dy/2))./dy);

ix(find(ix<1))=1;
iy(find(iy<1))=1;


RAY=K.*0;
for j=1:length(ix)
    RAY(iy(j),ix(j))=RAY(iy(j),ix(j))+1;
end


%% NORMALIZE
normMethod=1;
if normMethod==1;
    Knorm=K.*0;
    Ktest=K.*0.;
    % CREATE TIME SLICES
    tt=tS-tR;
    intervals=linspace(min(tt(:)),max(tt(:)),options.Ni);

    % FIRST DETERMINE TRAVEL TIME IN EACH SLICE
    % THIS IS NOT VEY ROBUST.
    % RETURNS BAD RESULTS
    % CALCUALTE CROSS BETWEEN, FINITE FREQUENCY PATH AND TIME SLICE
    % BOUNDARIES, AND USE THOSE CROSSING POINTS AS START AND END
    tt_raypath=interp2(xx,yy,tt,raypath(:,1),raypath(:,2));
    for j=1:(options.Ni-1)
        t1=intervals(j);
        t2=intervals(j+1);
        iray{j}=find((tt_raypath>=t1)&(tt_raypath<t2));

        d_ray(j)=0;
        for i=1:(length(iray{j})-1)
            x1=raypath(iray{j}(i),1);
            x2=raypath(iray{j}(i+1),1);
            y1=raypath(iray{j}(i),2);
            y2=raypath(iray{j}(i+1),2);



            d_ray(j)=d_ray(j)+sqrt((x2-x1).^2+(y2-y1).^2);
        end

    end
    d_ray=raylength.*d_ray./sum(d_ray);

    tt_raypath=interp2(xx,yy,tt,raypath(:,1),raypath(:,2));

    for j=1:(options.Ni-1)
        t1=intervals(j);
        t2=intervals(j+1);

        t_slice=zeros(size(tt));%NaN.*tt;
        it=find( (tt>=t1)&(tt<t2));

        t_slice(it)=1;

        Ktest(it)=1;
        Knorm(it)=d_ray(j).*K(it)./sum(K(it));

        if (options.doplot==1)
            figure(6);clf;%subplot(2,1,1)
            %imagesc(x,y,t_slice)
            imagesc(x,y,K);caxis([-1.2 1])
            hold on
            %contour(x,y,tt,intervals,'k-');
            contour(x,y,tt,[intervals(j:(j+1))],'k-');
            plot(raypath(:,1),raypath(:,2),'k.');
            plot(raypath(iray{j},1),raypath(iray{j},2),'w.');
            hold off
            axis image
            drawnow;
            M6(j)=getframe;
            figure(7);clf;%subplot(2,1,2)
            imagesc(x,y,Knorm);axis image;
            drawnow;
            M7(j)=getframe;
        end
    end
    %figure(7);clf;
    %%imagesc(x,y,t_slice)
    %movie2avi(M6,sprintf('TimeSlices_f%03d.avi',freq),'compression','cinepak','quality',90);
    %movie2avi(M7,sprintf('KernelTimeSlices_f%03d.avi',freq),'compression','cinepak','quality',90);

    
    K=raylength.*K./sum(K(:));
    
end



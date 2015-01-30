% dsim: Direct simulation
%
% VERY simple implementation of Direct Simulation
% Currently only works for relatively small simulations grids, and
% categorical TI
% See Mariethoz et al. (2010) for details
%
% Call
%    dsim(TI,SIM,options)
%
%  TI: [ny,nx] 2D training image (categorical variables
%  SIM: [ny2,nx2] 2D simulation grid. 'NaN' indicates an unkown value
%
%  options [struct] optional:
%  options.n_cond [int]: number of conditional points (def=5)
%  options.n_max_ite [int]: number of maximum iterations through the TI for matching patterns (def=200)
%
%  options.plot    [int]: [0]:none, [1]:plot cond, [2]:storing movie (def=0)
%  options.verbose [int]: [0] no info to screen, [1]:some info (def=1)
%
%
function [out,options]=dsim(TI_data,SIM_data,options)
if nargin<3
    options.null='';
end

if ~isfield(options,'verbose');options.verbose=1;end
if ~isfield(options,'plot');options.plot=-1;end
if ~isfield(options,'plot_interval');options.plot_interval=100;end
if ~isfield(options,'n_cond');options.n_cond=5;end
if ~isfield(options,'n_max_ite');options.n_max_ite=200;end
if ~isfield(options,'rand_path');options.rand_path=1;end
if ~isfield(options,'precalc_dist_full');
    if numel(SIM_data)<=10000;
        options.precalc_dist_full=1;
    else
        options.precalc_dist_full=0;
    end
end

TI.D=TI_data;
[TI.ny,TI.nx]=size(TI.D);
TI.x=1:1:TI.nx;
TI.y=1:1:TI.ny;
N_TI=numel(TI.D);

SIM.D=SIM_data;
[SIM.ny,SIM.nx]=size(SIM.D);
SIM.x=1:1:SIM.nx;
SIM.y=1:1:SIM.ny;
N_SIM=numel(SIM.D);


if options.plot>2
    writerObj = VideoWriter('dsim');
    %writerObj = VideoWriter(vname,'MPEG-4'); % Awful quality ?
    writerObj.FrameRate=30;
    writerObj.Quality=90;
    open(writerObj);
end



% if ~isfield(options,'DIST');
%     [XX,YY]=meshgrid(1:SIM.nx,1:SIM.ny);
%     X=[XX(:) YY(:)];
%     if options.precalc_dist_full==0;
%         if options.verbose>0;fprintf('%s: Precalculating Distance Matrix - start\n',mfilename);end
%         X(:,1)=X(:,1)-X(1,1);
%         X(:,2)=X(:,2)-X(1,2);
%         options.DIST=sqrt(sum(X'.^2));
%     else
%         options.DIST=pdist_tmh(X);
%     end
%     if options.verbose>0;fprintf('%s: Precalculating Distance Matrix - stop\n',mfilename);end
% end

% PRE ALLOCATE MATRIX WITH COUNTS
options.C=zeros(size(SIM.D));



%% SET RANDOM PATH
% find a list of indexes of unsampled values
i_path=find(isnan(SIM.D));
if options.rand_path==1
    % 'SHUFFLE' index of path to get a random path
    i_path=shuffle(i_path);
end
N_PATH=length(i_path);

%% loop over path
for i=1:N_PATH;
    if options.verbose>0
        if ((i/100)==round(i/100))&(options.plot>-1)
            progress_txt(i,N_SIM,mfilename);
            progress_txt(i,N_PATH,mfilename);
        end
    end
    
    % find index of the current node
    i_node=i_path(i);
    [iy,ix]=ind2sub_2d([SIM.ny,SIM.nx],i_node);
    if options.verbose>1
        fprintf('At node iy,ix=[%d,%d]\n',iy,ix);
    end
    
    % FIND n_cond CONDITIONAL POINT, find L
    if i>1
        i_good=find(~isnan(SIM.D));
        
        %[iiy_n,iix_n]=ind2sub_2d([SIM.ny,SIM.nx],i_node);
        %[iiy_g,iix_g]=ind2sub_2d([SIM.ny,SIM.nx],i_good);
        
        %iiy=abs(iiy_n-iiy_g)+1;
        %iix=abs(iix_n-iix_g)+1;
        %ind = sub2ind([[SIM.ny,SIM.nx]],iiy,iix)
        %options.DIST(1,ind)
        
        [d,options]=dsim_get_distance(SIM.ny,SIM.nx,i_node,i_good,options);
        %d=options.DIST(i_node,i_good);
        %keyboard
        ii=1:length(d);
        s=sortrows([ii(:) d(:)],2);
        use_cond=min([options.n_cond length(d)]);
        i_close=i_good(s(1:use_cond,1));
        V=zeros(use_cond,1);
        L=zeros(use_cond,2);
        for k=1:use_cond;
            [iiy,iix]=ind2sub_2d([SIM.ny,SIM.nx],i_close(k));
            V(k,1)=SIM.D(iiy,iix);
            L(k,:)=[iiy-iy iix-ix];
        end
        
        
    end
    
    
    % LOOP OVER TI,
    j_start=ceil(rand(1)*N_TI);
    j_arr(1:(N_TI-j_start+1))=j_start:1:N_TI;
    j_arr((N_TI-j_start+2):N_TI)=1:(j_start-1);
    
    ij=0;
    DIS_MIN=1e+5;
    for j=j_arr
        ij=ij+1;
        [iy_ti,ix_ti]=ind2sub_2d([TI.ny,TI.nx],j);
        if i==1;
            SIM.D(iy,ix)=TI.D(iy_ti,ix_ti);
            break
        else
            % GET INDEX CENTER INDEX IN TI
            %P=repmat([iy_ti ix_ti],size(L,1),1);
            
            % COMPUTE DISTANCE
            DIS=0;
            for k=1:size(L,1);
                iy_test=L(k,1)+iy_ti;
                ix_test=L(k,2)+ix_ti;
                
                if ((iy_test>0)&&(iy_test<=TI.ny)&&(ix_test>0)&(ix_test<=TI.nx))
                    if TI.D(iy_test,ix_test)==V(k);
                        DIS=DIS+0;
                    else
                        DIS=DIS+1;
                    end
                else
                    DIS=DIS+1;
                end
            end
            
            %% keep track of the pattern with the smallesty dist so far
            if DIS<DIS_MIN
                DIS_MIN=DIS;
                iy_ti_min=iy_ti;
                ix_ti_min=ix_ti;
            end
            
            % store how many iteration in the TI is performed
            options.C(iy,ix)=ij;
            
            %% STOP, if perfect match has been reached
            if DIS==0
                SIM.D(iy,ix)=TI.D(iy_ti,ix_ti);
                break
            end
            
            %% STOP, if maximum number of allowed iterations have been reached
            if ij>=options.n_max_ite;
                SIM.D(iy,ix)=TI.D(iy_ti_min,ix_ti_min);
                break;
            end
            
            
        end
    end
    
    %% PLOT START
    if options.plot>0
        if ~exist('im')
            figure_focus(2);
            subplot(1,2,1);
            im=imagesc(TI.D);axis image;
            caxis([-1 1]);
        end
        if exist('im_sim')
            if ((i==N_PATH)|((i/options.plot_interval)==round(i/options.plot_interval)))
                set(im_sim,'Cdata',SIM.D);
                drawnow;
            end
        else
            figure_focus(2);
            subplot(1,2,2);
            im_sim=imagesc(SIM.D);
            caxis([-1 1]);
            colormap(cmap_linear([1 1 1 ; 0 0 0; 1 0 0]))
            axis image
        end
        if options.plot>1
            hold on
            plot(ix,iy,'go','MarkerSize',12)
            for l=1:size(L,1)
                plot([ix ix+L(l,2)],[iy iy+L(l,1)],'g-')
            end
            hold off
        end
        
        if options.plot>2
            frame = getframe(gcf);
            writeVideo(writerObj,frame);
        end
    end
    %% PLOT END
    
    
end

if options.plot>2
    try
        close(writerObj);
    catch
        fprintf('%s : coule not close writerObj',mfilename);
    end
end

out=SIM.D;

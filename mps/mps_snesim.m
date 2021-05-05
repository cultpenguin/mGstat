% mps_snesim: Multiple point simuation through sequential simulation
%      using SNESIM
%
% Call
%    mps_snesim(TI,SIM,options)
%
%  TI: [ny,nx] 2D training image (categorical variables
%  SIM: [ny2,nx2] 2D simulation grid. 'NaN' indicates an unkown value
%
%  options [struct] optional:
%
%  options.type [string] : 'snesim'
%  options.n_cond [int]: number of conditional points (def=5)
%  options.rand_path [int]: [1] random path (default), [0] sequential path
%  options.n_mulgrids=1; % Number og muliple grids
%
%  % specific for options.type='sneism';
%  options.n_template [int]: template size
%  options.storage_type [str]: 'tree';
%
%  % local prior probability / soft probability
%  options.local_prob : structure (ndim=ncat) of with same size as simulation
%                       grid (SIM)
%
%  options.plot    [int]: [0]:none, [1]:plot cond, [2]:storing movie (def=0)
%  options.verbose [int]: [0] no info to screen, [1]:some info (def=1)
%  % approximating the ocnditional pd:
%  options.n_max_condpd=10; % build conditional pd from max 10 counts
%
%
% %% Example
% TI=channels;
% SIM=ones(40,40)*NaN;
%
% options.n_cond=5;;
% options.n_template=16;;
% [out]=mps_snesim(TI,SIM,options)
%
%% SOFT probability
% P{1}=SIM;
% P{1}(:)=0.5;
% P{1}(1:5,:)=0.9; % locally increased probabilitu of category 1
% P{2]=1-P{1};
% options.local_prob=P;
% [out_dsim]=mps_snesim(TI,SIM,options)
%
% See also: mps, mps_enesim, mps_tree_populate, mps_tree_get_cond
%
function [out,options]=mps_snesim(TI_data,SIM_data,options)
out=[];
if nargin<3
    options.null='';
end

if ~isfield(options,'skip_sim');options.skip_sim=0;end
if ~isfield(options,'type');options.type='snesim';end
if ~isfield(options,'template_type');options.template_type=1;end
if ~isfield(options,'storage_type');options.storage_type='tree';end
if ~isfield(options,'verbose');options.verbose=0;end
if ~isfield(options,'n_cond');options.n_cond=5;end
if ~isfield(options,'n_mulgrids');options.n_mulgrids=0;end
if ~isfield(options,'rand_path');options.rand_path=1;end
if ~isfield(options,'debug_level');options.debug_level=0;end

% OLD
if ~isfield(options,'plot');options.plot=1;end
if ~isfield(options,'plot_interval');options.plot_interval=50;end

%% CHECK FOR MULTIPLE GRIDS
if options.n_mulgrids>1
    t_start=now;
    [out,options]=mps_snesim_multigrid(TI_data,SIM_data,options);
    t_end=now;
    options.t=(t_end-t_start)*(3600*24);
    disp(sprintf('%s: simulation ended in %gs',mfilename,options.t));
    return
end

%% SET SOME DATA STRUCTURES

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



% PRE ALLOCATE MATRIX WITH COUNTS
if options.debug_level>0
    options.TIME=zeros(size(SIM.D));
    options.C=zeros(size(SIM.D));
    options.IPATH=zeros(size(SIM.D));
    options.E=zeros(size(SIM.D));
end

%% SET TEMPLATE
if ~isfield(options,'T');
    if ~isfield(options,'n_template');options.n_template=48;end;
    n_dim=ndims(SIM);
    options.T=mps_template(options.n_template,n_dim,options.template_type,0);
end


%% OPEN HANDLE FOR WRITING MOVIE
if options.plot>2
    writerObj = VideoWriter('mps_snesim');
    writerObj.FrameRate=30;
    writerObj.Quality=90;
    open(writerObj);
end



%% POPULATE SEARCH TREE
if ~isfield(options,'ST');
    mgstat_verbose(sprintf('%s: start building search tree',mfilename),-1)
    t1=now;
    [options.ST]=mps_tree_populate(TI.D,options.T);    
    mgstat_verbose(sprintf('%s: end building search tree (%g s)',mfilename,(now-t1)*3600*24),-1)
else
    mgstat_verbose(sprintf('%s: using supplied search tree',mfilename),1)
end
keyboard
%% SET RANDOM PATH
% find a list of indexes of unsampled values
i_path=find(isnan(SIM.D));
if options.rand_path==1
    % 'SHUFFLE' index of path to get a random path
    i_path=shuffle(i_path);
elseif options.rand_path==2
    % mixed_point_path
    i_path=rand_list_MaxEnt(SIM.D);
    %i_path=rand_list_MaxEnt(SIM.D.*NaN);
end

% if options.i_path is set, use that;
if isfield(options,'i_path');
    i_path=options.i_path;
end

N_PATH=length(i_path);


%% BIG LOOP OVER RANDOM PATH
t_start=now;
for i=1:N_PATH; %  % START LOOOP OVER PATH
    
    
    if options.verbose>0
        if ((i/100)==round(i/100))&(options.plot>-1)
            %progress_txt(i,N_SIM,mfilename);
            %progress_txt(i,N_PATH,mfilename);
            disp(sprintf('%s: %03d/%02d',mfilename,i,N_PATH))
        end
    end
    
    % find index of the current node
    i_node=i_path(i);
    [iy,ix]=ind2sub_2d([SIM.ny,SIM.nx],i_node);
    if options.verbose>1
        fprintf('i=%d, at node iy,ix=[%3d,%3d]\n',i,iy,ix);
    end
    if options.debug_level>0
        options.IPATH(iy,ix)=i;
    end
    % only sim if center note is NaN
    if isnan(SIM.D(iy,ix));
        
        % find conditional data
        iz=1; % 2D for now
        [d_cond,n_cond]=mps_cond_from_template(SIM.D,ix,iy,iz,options.T,options.n_cond);
        
        if options.debug_level>0
            options.C(iy,ix)=n_cond;
        end
        
        % get conditinal pdf from search tree
        tic
        [c_pdf]=mps_tree_get_cond(options.ST,d_cond);
        if options.debug_level>0
            options.TIME(iy,ix)=toc;
        end
        
        % optionally get local prior probability
        if isfield(options,'local_prob');
            for k=1:length(options.local_prob);
                c_local(k)=options.local_prob{k}(iy,ix);
            end
            
            c_combined = c_local.*c_pdf;
            c_combined = c_combined./sum(c_combined);
            c_pdf = c_combined;
            
        end
        
        % simulate from search tree
        sim_val=min(find(cumsum(c_pdf)>rand(1)))-1;
        try
            if options.skip_sim==0;
                SIM.D(iy,ix)=sim_val;
            else
                if ~isfield(options,'C_PDF')
                    options.C_PDF=zeros([SIM.ny,SIM.nx,[length(c_pdf)]])*NaN;
                end
                % store condtional event
                % remeber to preallocate
                for k=1:length(c_pdf)
                    options.C_PDF(iy,ix,k)=c_pdf(k);
                end
            end
        catch
            keyboard
        end
        
        
        
        %% COMPUTE ENTROPY
        if options.debug_level>0
            options.E(iy,ix)=entropy(c_pdf);
        end
        
    end
    
    % PLOT START
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
            subplot(1,2,2);
            hold on
            im_sim=imagesc(SIM.D);
            caxis([-1 1]);
            colormap(cmap_linear([1 1 1 ; 0 0 0; 1 0 0]))
            axis image
            plot(ix,iy,'go','MarkerSize',12)
            for l=1:size(L,1)
                plot([ix ix+L(l,2)],[iy iy+L(l,1)],'g-')
            end
            hold off
            
        end
        
        if options.plot>1
            subplot(1,2,1);
            im=imagesc(TI.D);axis image;
            caxis([-1 1]);
            hold on
            plot(ix_ti_min,iy_ti_min,'go','MarkerSize',12)
            for l=1:size(L,1)
                plot([ix_ti_min ix_ti_min+L(l,2)],[iy_ti_min iy_ti_min+L(l,1)],'g-')
            end
            hold off
            %disp('paused - hit keyboard');pause;
        end
        
        
        if options.plot>2
            frame = getframe(gcf);
            writeVideo(writerObj,frame);
        end
    end
    %% PLOT END
    
    
end % END LOOOP OVER PATH
t_end=now;
options.t=(t_end-t_start)*(3600*24);
%disp(sprintf('%s: simulation ended in %gs',mfilename,options.t));


if options.plot>2
    try
        close(writerObj);
    catch
        fprintf('%s : coule not close writerObj',mfilename);
    end
end
out=SIM.D;

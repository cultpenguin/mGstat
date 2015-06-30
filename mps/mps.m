% mps: Multiple point simuation through sequential simulation
%      using DIRECT SIMULATION or ENESIM
%
% Call
%    mps_dsim(TI,SIM,options)
%
%  TI: [ny,nx] 2D training image (categorical variables
%  SIM: [ny2,nx2] 2D simulation grid. 'NaN' indicates an unkown value
%
%  options [struct] optional:
%
%  options.type [string] : 'dsim' (default) or 'enesim'
%  options.n_cond [int]: number of conditional points (def=5)
%  options.rand_path [int]: [1] random path (default), [0] sequential path
%
%  % specific for options.type='dsim';
%  options.n_max_ite [int]: number of maximum iterations through the TI for matching patterns (def=200)
%
%  % specific for options.type='enesim';
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
% %% DIRECT SAMPLING
% options.type='dsim';
% options.n_cond=5;;
% [out_dsim]=mps(TI,SIM,options)
%
% %% ENESIM
% options.type='enesim';
% options.n_cond=5;;
% [out_dsim]=mps(TI,SIM,options)
%
% %% ENESIM USING APPROXIMATE CONDITIONAL
% options.type='enesim';
% options.n_cond=5;
% options.n_max_condpd=10;
% [out_dsim]=mps(TI,SIM,options)
%
%
%
% See also: mps_enesim, mps_dsim
%
function [out,options]=mps_dsim(TI_data,SIM_data,options)
if nargin<3
    options.null='';
end

if ~isfield(options,'type');options.type='dsim';end
if ~isfield(options,'verbose');options.verbose=1;end
if ~isfield(options,'plot');options.plot=-1;end
if ~isfield(options,'plot_interval');options.plot_interval=100;end
if ~isfield(options,'n_cond');options.n_cond=5;end
if ~isfield(options,'rand_path');options.rand_path=1;end
if ~isfield(options,'precalc_dist_full');end

if ~isfield(options,'n_max_condpd');
    options.n_max_condpd=1e+9;
end

if strcmp(options.type,'dsim');
    if ~isfield(options,'n_max_ite');options.n_max_ite=200;end
end
if numel(SIM_data)<=10000;
    options.precalc_dist_full=1;
else
    options.precalc_dist_full=0;
end
if ~strcmp(options.type,'dsim');
    options.H=SIM_data.*0.*NaN;
end
options.N=SIM_data.*0.*NaN;
options.N_DROPPED=zeros(size(SIM_data));;

%% SET SEOM DATA STRICTURES

L=[];
V=[];

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


% PRE ALLOCATE MATRIX WITH COUNTS
options.C=zeros(size(SIM.D));
options.IPATH=zeros(size(SIM.D));


%% SET RANDOM PATH
% find a list of indexes of unsampled values
i_path=find(isnan(SIM.D));
if options.rand_path==1
    % 'SHUFFLE' index of path to get a random path
    i_path=shuffle(i_path);
end
N_PATH=length(i_path);

%% BIG LOOP OVER RANDOM PATH

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
        fprintf('At node iy,ix=[%d,%d]\n',iy,ix);
    end
    options.IPATH(iy,ix)=i;
    
    
    
    %% FIND n_cond CONDITIONAL POINT, find L
    % V value of conditional point
    % L relative location of conditional point
    %
    if i>1
        i_good=find(~isnan(SIM.D));
        
        [d,options]=mps_get_distance(SIM.ny,SIM.nx,i_node,i_good,options);
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
    N_COND=length(V);
    
    if strcmp(lower(options.type),'dsim');
        %% GET REALIZATION FROM TI USING DIRECT SIMULATION
        [sim_val,options.C(iy,ix),ix_ti_min,iy_ti_min]=mps_get_realization_from_template(TI,V,L,options);
        SIM.D(iy,ix)=sim_val;
        
    elseif strcmp(lower(options.type),'enesim');
        %% GET REALIZATION FROM TI BY
        %  a) scanning the whole TO to establisj f(m_i|f(m_1,...,m_{i-1})
        %  b) generate a ralization from f(m_i|f(m_1,...,m_{i-1})
        N_PDF=0;
        if N_COND==0
            [C_PDF,N_PDF,TI]=mps_get_conditional_from_template(TI,[],[],options.n_max_condpd);
        else
            for ic=1:N_COND               
                c_arr=(1:(N_COND-ic+1));
                [C_PDF,N_PDF,TI]=mps_get_conditional_from_template(TI,V(c_arr),L(c_arr,:),options.n_max_condpd);
                
                if N_PDF>0, break; end
                disp(sprintf('%s : PRUNING: dropping a node %02d/%02d at[ix,iy]=[%d,%d]',mfilename,N_COND-ic,N_COND,ix,iy))
                options.N_DROPPED(iy,ix)=ic;
            end
        end
        options.H(iy,ix)=entropy(C_PDF);
        options.N(iy,ix)=N_PDF;
        
        % DRAW REALIZARTION FROM C_PDF
        sim_val=min(find(cumsum(C_PDF)>rand(1)))-1;
        try
            SIM.D(iy,ix)=sim_val;
        catch
            keyboard
        end
        
        
    end
    %% GET FULL CONDITIONAL TO COMPUTE ENTROPY
    options.compute_entropy=0;
    if options.compute_entropy==1;
        [C_PDF,TI]=mp_get_conditional_from_template(TI,V,L);
        options.E(iy,ix)=entropy(C_PDF);
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

if options.plot>2
    try
        close(writerObj);
    catch
        fprintf('%s : coule not close writerObj',mfilename);
    end
end
out=SIM.D;

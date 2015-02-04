% mps_dsim: Direct simulation
%
% VERY simple implementation of Direct Simulation
% Currently only works for relatively small simulations grids, and
% categorical TI
% See Mariethoz et al. (2010) for details
%
% Call
%    mps_dsim(TI,SIM,options)
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
% See also: mps_enesim
%
function [out,options]=mps_dsim(TI_data,SIM_data,options)
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
    
    
    %% GET REALIZATION FROM TI
    if N_COND==0
        [sim_val,options.C(iy,ix)]=mps_get_realization_from_template(TI,[],[],options);
    else
        [sim_val,options.C(iy,ix)]=mps_get_realization_from_template(TI,V,L,options);
    end
    SIM.D(iy,ix)=sim_val;
  
    %% GET FULL CONDITIONAL TO COMPUTE ENTROPY
    options.compute_entropy=0;
    if options.compute_entropy==1;
        [C_PDF,TI]=mp_get_conditional_from_template(TI,V,L);
        options.E(iy,ix)=entropy(C_PDF);
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
        
        %         if options.plot>1
        %             subplot(1,2,1);
        %             im=imagesc(TI.D);axis image;
        %             caxis([-1 1]);
        %             hold on
        %             plot(ix_ti_min,iy_ti_min,'go','MarkerSize',12)
        %             for l=1:size(L,1)
        %                 plot([ix_ti_min ix_ti_min+L(l,2)],[iy_ti_min iy_ti_min+L(l,1)],'g-')
        %             end
        %             hold off
        %         end
        
        
        if options.plot>2
            frame = getframe(gcf);
            writeVideo(writerObj,frame);
        end
    end
    %% PLOT END
    
    %keyboard
    
    
end % END LOOOP OVER PATH

if options.plot>2
    try
        close(writerObj);
    catch
        fprintf('%s : coule not close writerObj',mfilename);
    end
end

out=SIM.D;

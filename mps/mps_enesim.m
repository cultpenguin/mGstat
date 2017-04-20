% mps: Multiple point simuation through sequential simulation
%      using ENESIM and DIRECT SIMULATION %
% Call
%    mps_enesim(TI,SIM,options)
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
%  options.n_max_ite [int]: number of maximum iterations through the TI for matching patterns (def=1e+5)
%  options.plot    [int]: [0]:none, [1]:plot cond, [2]:storing movie (def=0)
%  options.verbose [int]: [0] no info to screen, [1]:some info (def=1)
%
%  % specific for options.type='enesim';
% %    approximating the conditional pd:
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
% [out_enesim]=mps(TI,SIM,options)
%
% %% ENESIM USING APPROXIMATE CONDITIONAL
% options.type='enesim';
% options.n_cond=5;
% options.n_max_condpd=10;
% [out_enesim_app]=mps(TI,SIM,options)
%
%
%
% See also: mps, mps_snesim
%
function [out,options]=mps_enesim(TI_data,SIM_data,options)
if nargin<3
    options.null='';
end

if ~isfield(options,'skip_sim');options.skip_sim=0;end
if ~isfield(options,'type');options.type='dsim';end
if ~isfield(options,'verbose');options.verbose=1;end
if ~isfield(options,'plot');options.plot=-1;end
if ~isfield(options,'plot_interval');options.plot_interval=100;end
if ~isfield(options,'n_cond');options.n_cond=5;end
if ~isfield(options,'rand_path');options.rand_path=1;end
if ~isfield(options,'precalc_dist_full');
    if numel(SIM_data)<=10000;
        options.precalc_dist_full=1;
    else
        options.precalc_dist_full=0;
    end
end
% Patching
if ~isfield(options,'n_patch');options.n_patch=0;end
if ~isfield(options,'i_patch_start');options.i_patch_start=100;end
if options.i_patch_start<1;
    options.i_patch_start=ceil(options.i_patch_start.*prod(size(SIM_data)));
end
options.T_patch=mps_template(options.n_patch);
            
if ~isfield(options,'n_max_condpd');
    options.n_max_condpd=1e+9;
end

%if strcmp(options.type,'dsim');
if ~isfield(options,'n_max_ite');options.n_max_ite=2000;end
%end
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


if isfield(options,'TI2')
    TI2_data=options.TI2;
    TI2.D=TI2_data;
    [TI2.ny,TI2.nx]=size(TI2.D);
    TI2.x=1:1:TI2.nx;
    TI2.y=1:1:TI2.ny;
end

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

if isfield(options,'d_soft');
    i_path=mps_path(SIM.D,options.rand_path,options.d_soft);
else
    i_path=mps_path(SIM.D,options.rand_path);
end

% optionally load path from options
if isfield(options,'i_path');
    i_path=options.i_path;
    if options.verbose>5
        fprintf('Path set in input');
    end
end
N_PATH=length(i_path);

%% BIG LOOP OVER RANDOM PATH
t_start=now;
for i=1:N_PATH; %  % START LOOOP OVER PATH
    
    
    if options.verbose>0
        if ((i/100)==round(i/100))&(options.plot>-1)
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
    
    % CONDITIONAL SIMULATION UNLESS ALLREADY SIMULATD
    if isnan(SIM.D(iy,ix))
        
    
    %% FIND n_cond CONDITIONAL POINT, find L
    % V value of conditional point
    % L relative location of conditional point
    %
    if i>0
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
        
        accept=0;
        n_test=0;
        while accept==0;
            [sim_val,options.C(iy,ix),ix_ti_min,iy_ti_min,options.COND_DIST(iy,ix)]=mps_get_realization_from_template(TI,V,L,options);
            
            % TEST FOR SOFT DATA
            if isfield(options,'d_soft');
                % GET PROPER P_ACC
                n_test=n_test+1;
                if sim_val==0
                    P_acc = options.d_soft(iy,ix);
                else
                    P_acc = 1-options.d_soft(iy,ix);
                end
                if isnan(P_acc)
                    accept=1;
                elseif rand(1)<P_acc
                    %disp(sprintf('i=%d, P_acc=%g, [ix,iy]=[%d,%d], n_test=%d',i,P_acc,ix,iy,n_test))
                    accept=1;
                end
                if n_test>10;
                    accept=1;
                end
            else
                % always accept if no soft data available
                accept=1;
            end
        end
        SIM.D(iy,ix)=sim_val;
        
        
        if (options.n_patch>0)&&(i>options.i_patch_start)
            for ip=1:options.n_patch
                dix=options.T_patch(ip,1);
                diy=options.T_patch(ip,2);
                try
                    if isnan(SIM.D(iy+diy,ix+dix));
                        SIM.D(iy+diy,ix+dix)=TI.D(iy_ti_min+diy,ix_ti_min+dix);
                    end
                end
            end
        end
        
        
        
    elseif strcmp(lower(options.type),'enesim');
        %% GET REALIZATION FROM TI BY
        %  a) scanning the whole TO to establisj f(m_i|f(m_1,...,m_{i-1})
        %  b) generate a ralization from f(m_i|f(m_1,...,m_{i-1})
        N_PDF=0;
        if N_COND==0
            [C_PDF,N_PDF,TI]=mps_get_conditional_from_template(TI,[],[],options);
            
            if isfield(options,'TI2')
                [C_PDF2,N_PDF2]=mps_get_conditional_from_template(TI2,[],[],options);
                N_PDF=min([N_PDF N_PDF2]);
            end
            
            
        else
            for ic=1:N_COND
                c_arr=(1:(N_COND-ic+1));
                [C_PDF,N_PDF,TI]=mps_get_conditional_from_template(TI,V(c_arr),L(c_arr,:),options);
                
                if isfield(options,'TI2')
                    [C_PDF2,N_PDF2]=mps_get_conditional_from_template(TI2,V(c_arr),L(c_arr,:),options);
                    N_PDF=min([N_PDF N_PDF2]);
                end
                
                
                if N_PDF>0, break; end %% N_PDF OS NEVER BELOW 1
                %disp(sprintf('%s : PRUNING: dropping a node %02d/%02d at[ix,iy]=[%d,%d]',mfilename,N_COND-ic,N_COND,ix,iy))
                
                options.N_DROPPED(iy,ix)=ic;
            end
        end
        
        if isfield(options,'TI2')
            p=0;
            p=ix./SIM.nx;
            p=.5*(1+cos(pi-pi*p));
            p=0.5;
            
            txt1=(sprintf('p=%4.2f - PDF=[%2.2f %3.2f]  PDF2=[%2.2f %3.2f]',p,C_PDF(1),C_PDF(2),C_PDF2(1),C_PDF2(2)));
            C_PDF_COMB = p.*C_PDF + (1-p).*C_PDF2;
            C_PDF=C_PDF_COMB./sum(C_PDF_COMB);
            txt2=(sprintf('PDF_COMB=[%3.2f %3.2f]',C_PDF(1),C_PDF(2)));
            disp([txt1,' - ',txt2])
            
        end
        
        options.H(iy,ix)=entropy(C_PDF);
        options.N(iy,ix)=N_PDF;
        
        % DRAW REALIZARTION FROM C_PDF
        sim_val=min(find(cumsum(C_PDF)>rand(1)))-1;
        if isnan(sim_val);
            keyboard
        end
        
        try
            if options.skip_sim==0;
                SIM.D(iy,ix)=sim_val;
            else
                if ~isfield(options,'C_PDF')
                    options.C_PDF=zeros([SIM.ny,SIM.nx,[length(C_PDF)]])*NaN;
                end
                % store condtional event
                % remeber to preallocate
                for k=1:length(C_PDF)
                    
                    options.C_PDF(iy,ix,k)=C_PDF(k);
                end
            end
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
            axis image;
            %axis([1 size(TI.D,2) 1 size(TI.D,1)]);
            caxis([-1 1]);
        end
        if exist('im_sim')
            if ((i==N_PATH)|((i/options.plot_interval)==round(i/options.plot_interval)))
                set(im_sim,'Cdata',SIM.D);
                %axis([1 size(TI.D,2) 1 size(TI.D,1)]);
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
        if ((i==N_PATH)|((i/options.plot_interval)==round(i/options.plot_interval)))
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
                ax=axis;
                caxis([-1 1]);
                hold on
                plot(ix_ti_min,iy_ti_min,'go','MarkerSize',12)
                for l=1:size(L,1)
                    plot([ix_ti_min ix_ti_min+L(l,2)],[iy_ti_min iy_ti_min+L(l,1)],'g-')
                end
                hold off
                axis(ax);
                %disp('paused - hit keyboard');pause;
            end
            
            
            if options.plot>2
                frame = getframe(gcf);
                writeVideo(writerObj,frame);
            end
            
            if options.plot>3
                pause;
            end
        end
    end
    %% PLOT END
    end
    
end % END LOOOP OVER PATH
t_end=now;
options.t=(t_end-t_start)*(3600*24);
mgstat_verbose(sprintf('%s: simulation ended in %gs',mfilename,options.t),1);


if options.plot>2
    try
        close(writerObj);
    catch
        fprintf('%s : coule not close writerObj',mfilename);
    end
end
out=SIM.D;

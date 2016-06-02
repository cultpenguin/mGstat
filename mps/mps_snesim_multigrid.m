% mps_snesim_multigrid: Multiple point simuation through sequential simulation
%      using SNESIM
%
% Call
%    mps_snesim_multigrid(TI,SIM,options)
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
% TI=TI(3:3:end,3:3:end)
% SIM=ones(40,40)*NaN;
%
% options.n_cond=5;;
% options.n_template=16;;
% [out]=mps_snesim(TI,SIM,options)
%
% See also: mps_snesim, mps, mps_enesim, mps_tree_populate, mps_tree_get_cond
function [out,options]=mps_snesim_mulgrid(TI_data,SIM_data,options)
out=[];
if nargin<3
  options.null='';
end

if ~isfield(options,'type');options.type='snesim';end
if ~isfield(options,'storage_type');options.storage_type='tree';end
if ~isfield(options,'verbose');options.verbose=0;end
if ~isfield(options,'n_mulgrids');options.n_mulgrids=3;end
if ~isfield(options,'n_cond');
    options.n_cond=5;
end
if ~isfield(options,'rand_path');options.rand_path=1;end
if ~isfield(options,'compute_entropy');options.compute_entropy=0;end

% OLD
if ~isfield(options,'plot');options.plot=1;end
if ~isfield(options,'plot_interval');options.plot_interval=50;end

%%
if length(options.n_cond)==1
    options.n_cond=ones(1,options.n_mulgrids).*options.n_cond;
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
options.C=zeros(size(SIM.D));
options.IPATH=zeros(size(SIM.D));


d_cell=2.^([(options.n_mulgrids-1):-1:0]);



for i_grid=1:(options.n_mulgrids);
    
    %% SET TEMPLATE [update to one template per mgrid]
    %if ~isempty(options,'T');
        if ~isfield(options,'n_template');
            options.n_template=48;
        end;
        if length(options.n_template)==1;
            n_t=options.n_template;
        else
            n_t=options.n_template(i_grid);
        end
        n_dim=ndims(SIM);
        options.T{i_grid}=mps_template(n_t,n_dim,0);
    %end

%    if ~isfield(options,'ST_mul');
        t_start=now;
        mgstat_verbose(sprintf('%s: Building tree for MultiGrid #%d d_cell=%d',mfilename,i_grid,d_cell(i_grid)),1);
        [options.ST_mul{i_grid}]=mps_tree_populate(TI.D,options.T{i_grid},d_cell(i_grid));
        t_end=now;
        mgstat_verbose(sprintf('%s: Build tree for MultiGrid #%d d_cell=%d in %5.2f s',mfilename,i_grid,d_cell(i_grid),(t_end-t_start)*(3600*24)),-1);
%     else 
%         key
%         t_start=now;
%         mgstat_verbose(sprintf('%s: Building tree for MultiGrid #%d d_cell=%d',mfilename,i_grid,d_cell(i_grid)),1);
%         [options.ST_mul{i_grid}]=mps_tree_populate(TI.D,options.T{i_grid},d_cell(i_grid));
%         t_end=now;
%         mgstat_verbose(sprintf('%s: Build tree for MultiGrid #%d d_cell=%d in %5.2f s',mfilename,i_grid,d_cell(i_grid),(t_end-t_start)*(3600*24)),-1);
%     end
    
    
    
    t_start=now;
    %ix=d_cell(i_grid):d_cell(i_grid):SIM.nx;
    %iy=d_cell(i_grid):d_cell(i_grid):SIM.ny;
    ix=1:d_cell(i_grid):SIM.nx;
    iy=1:d_cell(i_grid):SIM.ny;
    %iz=d_cell(i_grid):d_cell(i_grid):SIM.nz;
    
    SIM_mul=SIM.D(iy,ix);
    %TI_mul=TI.D(d_cell(i_grid):d_cell(i_grid):TI.ny,d_cell(i_grid):d_cell(i_grid):TI.nx);
    
    options_mul=options;
    options_mul.T=options.T{i_grid};
    options_mul.n_mulgrids=0;
    options_mul.n_cond=options.n_cond(i_grid);
    % check of local prior probablity and update according to mul grid
    if isfield(options,'local_prob');
        for i_lp=1:length(options.local_prob);
            P{i_lp}=options.local_prob{i_lp}(iy,ix);
        end
        options_mul.local_prob=P;
    end
    
    options_mul.ST=options.ST_mul{i_grid};
    mgstat_verbose(sprintf('%s: simulating on MultiGrid #%d d_cell=%d',mfilename,i_grid,d_cell(i_grid)),1);
    
    if options.plot>0
        figure_focus(10);
        subplot(options.n_mulgrids,3,(i_grid-1)*3+1);
        imagesc(SIM_mul);axis image;caxis([-1 1])
    end
    [out_mul,o]=mps_snesim(TI.D,SIM_mul,options_mul);
    
    SIM.D(iy,ix)=out_mul;
    options.C(iy,ix)=o.C;
    options.IPATH(iy,ix)=o.IPATH;
    
    if options.plot>0
        figure_focus(10);
        subplot(options.n_mulgrids,3,(i_grid-1)*3+2);
        imagesc(out_mul);axis image;caxis([-1 1])
        subplot(options.n_mulgrids,3,(i_grid-1)*3+3);
        imagesc(SIM.D);axis image;caxis([-1 1])
        colormap(cmap_linear([1 1 1 ; 0 0 0; 1 0 0]))
        
    end
    
    t_end=now;
    mgstat_verbose(sprintf('%s: Simulated MultiGrid #%d d_cell=%d in %5.2f s',mfilename,i_grid,d_cell(i_grid),(t_end-t_start)*(3600*24)),-1);

    
end

out=SIM.D;



% gaussian_simulation_cholesky_resim : generate realizations from a Gaussian 2D
% distribution mean m0 and covariance Cm
%
%
% Call : 
%    [D,options,L,z]=gaussian_simulation_cholesky_resim(x,y,z,Cm,options);
%    in:
%      x,y,z : arrays 
%      Cm : Covariance model 'either matrix or string'
%      options.mean    : mean value (either size (1,nyx) or (ny nx nz)
%      options.is_chol : Cm is really chol(Cm);
%      options.nsim    : number of realisations to create
%      
%    out:
%      L : cholesky decomp of Cm (L=chol(Cm))
%      z : D in 2D matrix form [nxyz,nsim]
%      
%     
% % Example :
%    x=1:1:40;
%    y=1:1:50;
%    z=0;
%    Va='1 Sph(20)';
%    [D,options_out,L,z_real]=gaussian_simulation_cholesky_resim(x,y,z,Va);
%
% % GDM
%    options.is_chol=1;
%    options.randdata=options_out.randdata;
%    options.lim=[5 5];options.gdm_step=pi/2;
%    [D_gdm,options_out,L,z_real]=gaussian_simulation_cholesky_resim(x,y,z,L,options);
%
%    subplot(1,3,1);imagesc(x,y,D);axis image;title('D')
%    subplot(1,3,2);imagesc(x,y,D_gdm);axis image;title('Dgdm')
%    subplot(1,3,3);imagesc(x,y,D_gdm-D);axis image;title('Dgdm-D')
% 
% See also: gaussian_simulation_cholesky
%



function [D,options,L,z]=gaussian_simulation_cholesky_resim(x,y,z,L,options);


options.null='';
if ~isfield(options,'m0');options.m0=0;end
if ~isfield(options,'is_chol');options.is_chol=0;end
if ~isfield(options,'nsim');options.nsim=1;end
%if nargin<2,L=diag(length(m));;end
%if nargin<1,m=ones(size(L,1));end

if isstr(L)
    % % 'L' is a covariance model description (string)
   L=deformat_variogram(L);
end
if isstruct(L)
    % 'L' is a covariance model description
    [xx,yy]=meshgrid(x,y);
    mgstat_verbose(sprintf('%s : Calculating Cm',mfilename))
    L=precal_cov([xx(:) yy(:)],[xx(:) yy(:)],L);
end

nx=length(x);ny=length(y);nz=length(z);
nxyz=nx*ny*nz;
try;dx=x(2)-x(1);catch;dx=1;end
try;dy=y(2)-y(1);catch;dy=1;end
try;dz=z(2)-z(1);catch;dz=1;end
orig_size=[nx ny nz];
cell=dx;


if size(options.m0,2)>1
    options.m0=options.m0(:);
end

t0=now;
if options.is_chol==0
    L=chol(L);
end

z=zeros(nxyz,options.nsim);
if ~isfield(options,'randdata');
    options.randdata=randn(nxyz,options.nsim);
end
% Gradual Deformation ?
if isfield(options,'lim');
    options.wrap_around=0;
    if ~isfield(options,'gdm_step'); options.gdm_step=pi/4; end
    if isfield(options,'pos');
        [options.used]=set_resim_data(x,y,options.randdata(:,1),options.lim,options.pos+[x0 y0],options.wrap_around);
    else
        x0=cell*ceil(rand(1)*nx); y0=cell*ceil(rand(1)*ny);
        options.pos=[x0 y0];
        [options.used]=set_resim_data(1:nx,1:ny,options.randdata(:,1),options.lim,options.pos,options.wrap_around);
    end    
    ii=find(options.used==0);   
    randdata_new=randn(length(ii),options.nsim);
    options.randdata(ii,:) = grad_deform(options.randdata(ii,:),randdata_new,options.gdm_step);        
end

t1=now;
for i=1:options.nsim
    if ((24*3600*(now-t1))>.1)
        if ~exist('di','var')
            di=i;
        end
        if ((i/di)==round(i/di))
            progress_txt(i,optiond.nsim);
        end
    end
  
    randdata=options.randdata(:,i);
    z(:,i)=options.m0+L'*options.randdata;
end
t2=now;
mgstat_verbose(sprintf('%s : cholesky   : Elapsed time : %6.1fs',mfilename,(t1-t0).*(24*3600)),2);
mgstat_verbose(sprintf('%s : simulation : Elapsed time : %6.1fs',mfilename,(t2-t1).*(24*3600)),2);
if nargout>1
    for i=1:options.nsim;
        D(:,:,i)=reshape(z(:,i),fliplr(orig_size));
    end
end
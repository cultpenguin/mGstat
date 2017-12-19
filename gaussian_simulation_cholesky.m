% gaussian_simulation_cholesky : generate realizations from a Gaussian 2D
% distribution mean m0 and covariance Cm
%
% Very eficient for smaller models to generate a sample
% of the posterior PDF for least squares inversion problems :
% 
% For example : 
%  [m_est,Cm_est]=least_squares_inversion(G,Cm,Cd,m0,d0);
%  z_uncond=gaussian_simulation_cholesky(m_est,Cm_est,nsim);
%  z_cond=gaussian_simulation_cholesky(m_est,Cm_est,nsim);
%
% Choleksy decomposition can be calculated prior to calling
%   Cm=chol(Cm)';
%   is_chol=1;
%   z_cond=gaussian_simulation_cholesky(m_est,Cm_est,nsim,is_chol);
%
%
%
% % unconditional realization:
% x=[1:1:40];
% y=[1:1:40];
% [xx,yy]=meshgrid(x,y);
% Cm=precal_cov([xx(:) yy(:)],[xx(:) yy(:)],'1 Sph(45,30,.1)');
% m0=xx.*0;
% nsim=12;
% [z_uncond,D]=gaussian_simulation_cholesky(m0,Cm,nsim);
% for i=1:nsim;subplot(4,3,i);imagesc(x,y,D(:,:,i));axis image;end
%
%
% see also gaussian_simulation_cholesky_resim
%


function [z,D,L,z_rand]=gaussian_simulation_cholesky(m,L,nsim,is_chol,z_rand);

if nargin<4,is_chol=0;end
if nargin<3,nsim=1;end
if nargin<2,Cm=diag(length(m));;end
if nargin<1,m=ones(1,100);end

if length(m)==1;
    if size(L,1)>1
        m=ones(1,size(L,1))*m;
    end
end

orig_size=size(m);

if size(m,2)>1
    m=m(:);
end


t0=now;
if is_chol==0
    L=chol(L,'upper');
    %L=lu(L)';
end
z=zeros(length(m),nsim);
t1=now;
for i=1:nsim
    if ((24*3600*(now-t1))>.1)
        if ~exist('di','var')
            di=i;
        end
        if ((i/di)==round(i/di))
            progress_txt(i,nsim);
        end
    end
    if nargin<5
        z_rand=randn(length(m),1);
    end
    z(:,i)=m+L'*z_rand; % L=chol(Cm,'upper');
    %z(:,i)=m+L*z_rand; % L=chol(Cm);
end
t2=now;
mgstat_verbose(sprintf('%s : cholesky   : Elapsed time : %6.1fs',mfilename,(t1-t0).*(24*3600)),1);
mgstat_verbose(sprintf('%s : simulation : Elapsed time : %6.1fs',mfilename,(t2-t1).*(24*3600)),1);
 
if nargout>1
    for i=1:nsim;
        D(:,:,i)=reshape(z(:,i),fliplr(orig_size));
    end
end
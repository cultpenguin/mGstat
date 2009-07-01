% gaussian_simulation_cholesky : generate realizations from a Gaussian 2D
% distribution mean m0 and covariance Cm
%
% Very eficient for smaller models to generate a sample
% of the posterior PDF for least squares inversion problems :
% 
% For example : 
% [m_est,Cm_est]=least_squares_inversion(G,Cm,Cd,m0,d0);
% z_uncond=gaussian_simulation(m_est,Cm_est,nsim);
% z_cond=gaussian_simulation(m_est,Cm_est,nsim);
%
% % unconditional realization:
% x=[1:1:40];
% y=[1:1:40];
% [xx,yy]=meshgrid(x,y);
% Cm=precal_cov([xx(:) yy(:)],[xx(:) yy(:)],'1 Sph(45,.1,30)');
% m0=xx.*0;
% nsim=12;
% [z_uncond,D]=gaussian_simulation(m0,Cm,nsim);
% for i=1:nsim;subplot(4,3,i);imagesc(x,y,D(:,:,i));axis image;end
%



function [z,D]=gaussian_simulation_cholesky(m,Cm,nsim);

if nargin<3,nsim=1;end
if nargin<2,Cm=diag(length(m));;end
if nargin<1,m=ones(1,100);end

orig_size=size(m);

if size(m,2)>1
    m=m(:);
end

t0=now;
L=chol(Cm);
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
    z(:,i)=m+L'*randn(length(m),1);
end

t2=now;
mgstat_verbose(sprintf('%s : cholesky   : Elapsed time : %6.1fs',mfilename,(t1-t0).*(24*3600)),0);
mgstat_verbose(sprintf('%s : simulation : Elapsed time : %6.1fs',mfilename,(t2-t1).*(24*3600)),0);
 
if nargout>1
    for i=1:nsim;
        D(:,:,i)=reshape(z(:,i),fliplr(orig_size))';
    end

end
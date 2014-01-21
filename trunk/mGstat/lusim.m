% lusim : sequential Gaussian simulation through LU decomposition
%                             of the Gaussian a posterior pdf
%
% Call : 
%   [sim_mul,m_est,Cm_est]=lusim(pos_known,val_known,pos_sim,V,options);%
% 
%   EAMPLES
%   
%   %% Load Jura Data
%   [d_prediction,d_transect,d_validation,h_prediction,h_transect,h_validation,x,y,pos]=jura(.1);
%   Va = '1 Sph(8)';
%   pos_known = d_prediction(:,1:2);
%   val_known = d_prediction(:,5);
%   options.nsim=9;
%   [sim_data,m_est,Cm_est]=lusim(pos_known,val_known,pos,Va,options);
%   for i=1:options.nsim;
%      subplot(3,3,i);
%      %scatter(pos(:,1),pos(:,2),10,sim_data(:,i),'filled');
%      imagesc(x,y,reshape(sim_data(:,i),length(y),length(x)));%axis image;caxis([-2 2])
%      axis image;
%   end
%
%   %%
%   x=[1:1:10];y=[1:1:20];nx=length(x);ny=length(y);
%   [xx,yy]=meshgrid(x,y);
%   pos_sim=[xx(:) yy(:)];
%   options.nsim=10;
%   
%   % unconditional simulation
%   randn('seed',1);
%   [sim_data,m_est,Cm_est]=lusim([],[],pos_sim,'1 Sph(8)',options);
%   figure(1);
%   for i=1:options.nsim;
%      subplot(2,5,i);
%      imagesc(reshape(sim_data(:,i),ny,nx));axis image;caxis([-2 2])
%   end
%   suptitle('uncondtional LUSIM')
%
%
%   % conditional simulation
%   pos_known=[1 1;5 5];
%   val_known=[.5 0;0 1]; % first data i noise free, second data has std=.1
%   randn('seed',1);
%   [sim_data,m_est,Cm_est]=lusim(pos_known,val_known,pos_sim,'1 Sph(8)',options);
%   figure(2);
%   for i=1:options.nsim;
%      subplot(2,5,i);
%      imagesc(reshape(sim_data(:,i),ny,nx));axis image;caxis([-2 2])
%   end
%   suptitle('condtional LUSIM')
%
%   TMH/2011
%
%
% see also: gaussian_simulation_cholesky
%

function [sim_mul,m_est,Cm_est]=lusim(pos_known,val_known,pos_sim,V,options);%

m_est=[];
Cm_est=[];
sim_mul=[];

options.null='';
if ~isfield(options,'nsim'); options.nsim=1;end

if (isempty(pos_known)&isempty(val_known))
    %% DO UNCONDITIONAL SIMULATION
    if ~isfield(options,'mean'); options.mean=0;end
    Cm=precal_cov(pos_sim,pos_sim,V);
    Cm_est=Cm;
    [sim_mul]=gaussian_simulation_cholesky(options.mean,Cm,options.nsim);    
else 
    %% CONDITIONAL SIMULATION%
    
    % Setup and solve least squares inversion system
    
    n_d=size(pos_known,1);
    n_m=size(pos_sim,1);
    
    % m0
    m0=ones(n_m+n_d,1);
 
    % d_obs
    d_obs=val_known(:,1);
       
    % Cd
    if size(val_known,2)>1
        Cd=diag(val_known(:,2));
    else
        Cd=zeros(n_d,n_d);
    end
    
    % Cm
    Cm=zeros(n_d+n_m,n_d+n_m);
    Cm(1:n_m,1:n_m)=precal_cov(pos_sim,pos_sim,V);
    Cm(n_m+1:end,n_m+1:end)=precal_cov(pos_known,pos_known,V);
    Cm_cross=precal_cov(pos_sim,pos_known,V);;
    Cm(n_m+1:end,1:n_m)=Cm_cross';
    Cm(1:n_m,n_m+1:end)=Cm_cross;
    
    % G
    G=zeros(n_d,n_d+n_m);
    G(:,(n_m+1):end)=eye(n_d);
    
    % solve least squares system
    [m_est,Cm_est]=least_squares_inversion(G,Cm,Cd,m0,d_obs);
    % generate realizations from the a posteriori Gaussian pdf
        % add nugget component
        sim_mul=gaussian_simulation_cholesky(m_est,Cm_est+eye(size(Cm_est)).*.000001,options.nsim);
    
    sim_mul=sim_mul(1:n_m,:);
    
    m_est=m_est(1:n_m);
    Cm_est=Cm_est(1:n_m,1:n_m);
    
    
end
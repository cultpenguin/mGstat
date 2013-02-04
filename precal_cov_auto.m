% precal_cov : Precalculate covariance matrix
%
% CALL :
%   cov=precal_cov_auto(pos1,pos2,V,options);
%
% pos1   [ndata1,ndims] : Location of data to be estimated
% V [struct] : Variogram structure
%
% cov [ndata1,ndata1] : Covariance matrix
%
%     
%     % Ex: 2D covariance (Call precal_cov with no arguments for an example)
%     x=[1:.5:10];nx=length(x);
%     y=[1:.5:20];ny=length(y);
%     [xx,yy]=meshgrid(x,y);
%     cov=precal_cov_auto([xx(:) yy(:)]],'1 Sph(5,30,.5)');
%     subplot(2,1,1);imagesc(cov);axis image;colorbar
%     
%     % generate some unconditional realizations
%     nsim=4;
%     reals_of_cov=gaussian_simulation_cholesky(0,cov,4);
%     for i=1:nsim;
%         subplot(2,nsim,nsim+i);imagesc(x,y,reshape(reals_of_cov(:,i),ny,nx));axis image
%     end
%
% 
%
%

function [cov,d]=precal_cov(pos1,V,options)
options.dummy='';
if ~isfield(options,'verbose'), options.verbose=0;end

if nargin==0
    
    
    % Ex: 2D covariance
    x=1:.25:10;nx=length(x);
    y=1:.25:20;ny=length(y);
    [xx,yy]=meshgrid(x,y);
    cov=precal_cov_ati([xx(:) yy(:)],'1 Sph(5,30,.5)');
    subplot(2,1,1);imagesc(cov);axis image;colorbar
    
    % generate som unconditional realizations
    nsim=4;
    reals_of_cov=gaussian_simulation_cholesky(0,cov,4);
    for i=1:nsim;
        subplot(2,nsim,nsim+i);imagesc(x,y,reshape(reals_of_cov(:,i),ny,nx));axis image
    end
    
    return
end

% DETERMINE ISORANGE
if  any(strcmp(fieldnames(options),'isorange'))
    isorange=options.isorange;
else
    isorange=0;
end

if ~isstruct(V);
    V=deformat_variogram(V);
end

n_est1=size(pos1,1);

n_dim1=size(pos1,2);
d=zeros(n_est1,n_est1);
mgstat_verbose([mfilename,' : Setting up covariance'],2);

gvar=sum([V.par1]);

semiv=zeros(size(d));
for iV=1:length(V)
    mgstat_verbose(sprintf('%s : semivar struc #%d',mfilename,iV),2)

    for i=1:n_est1;
        
        % progress bar
        if ((options.verbose>0))
            di=100;
            if (i/di)==round(i/di)
                progress_txt([i iV],[n_est1 length(V)],sprintf('%s : ',mfilename),'Nested struture');
            end
        end

        % FAST VECTORIZED APPROACH
        jj=i:n_est1;            
        if n_dim1==1
            p1=ones(n_est1,1).*pos1(i);
            p2=pos1;
        else
            p1=repmat(pos1(i,:),length(jj),1);
            p2=pos1(jj,:);
        end
        dd=edist(p1,p2,V(iV).par2,isorange);
        %d(i,:)=dd;
        d(i,jj)=dd;
        d(jj,i)=dd';
        
        
        % SLOW ITERATIVE APPROACH
        %for j=1:n_est2;
        %    d(i,j)=edist(pos1(i,:),pos2(j,:),V(iV).par2,isorange);
        %end
        
    end
    
    V(iV).par2=V(iV).par2(1);
    semiv = semiv + semivar_synth(V(iV),d,0);
end
cov=gvar-semiv;

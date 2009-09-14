% precal_cov : Precalculate covariance matrix
%
% CALL :
%   cov=precal_cov(pos1,pos2,V,options);
%
% pos1   [ndata1,ndims] : Location of data to be estimated
% pos2   [ndata2,ndims] : Location of data to be estimated
% V [struct] : Variogram structure
%
% cov [ndata1,ndata1] : Covariance matrix
%
% Ex:
% x=[1:1:10];
% y=[1:1:20];
% [xx,yy]=meshgrid(x,y);
% cov=precal_cov([xx(:) yy(:)],[xx(:) yy(:)],'1 Sph(5,.1,0)');
%

function [cov,d]=precal_cov(pos1,pos2,V,options);
options.dummy='';
if ~isfield(options,'verbose'), options.verbose=0;end

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
n_est2=size(pos2,1);

n_dim1=size(pos1,2);
n_dim2=size(pos2,2);
cov=zeros(n_est1,n_est2);
d=zeros(n_est1,n_est2);
mgstat_verbose([mfilename,' : Setting up covariance'],2);

gvar=sum([V.par1]);

tic;
t=toc;
semiv=zeros(size(d));
for iV=1:length(V)
    mgstat_verbose(sprintf('%s : semivar struc #%d',mfilename,iV),2)

    for i=1:n_est1;
        % progress bar
        if ((t>0)&(options.verbose>0))
            di=100;
            if (i/di)==round(i/di)
                progress_txt([i iV],[n_est1 length(V)],sprintf('%s : ',mfilename),'Nested struture');
            end
        end

        % FAST VECTORIZED APPROACH
        jj=1:n_est2;;            
        if n_dim1==1
            p1=ones(n_est1,1).*pos1(i);
            p2=pos2;
        else
            p1=repmat(pos1(i,:),length(jj),1);
            p2=pos2(jj,:);
        end
        dd=edist(p1,p2,V(iV).par2,isorange);
        d(i,:)=dd;
        % SLOW ITERATIVE APPROACH
        %for j=1:n_est2;
        %    d(i,j)=edist(pos1(i,:),pos2(j,:),V(iV).par2,isorange);
        %end
    end
    
    V(iV).par2=V(iV).par2(1);
    semiv = semiv + semivar_synth(V(iV),d,1);      
end
cov=gvar-semiv;

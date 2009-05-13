% krig_covar_lik : Calculates the likelihood tha V is consistent with data observations
%
% Call :
%   L=krig_covar_lik(pos_known,val_known,V,options)
%
%
% Can be used to infer covariance properties (range, sill, anisotropy,...)
%
function [L,sigma2_est,Cm,Q]=krig_covar_lik(pos_known,val_known,V,options,method)

if exist('method','var')==0
    method=1;
end

options.dummy='';

if isfield(options,'covar_method');
    method=options.covar_method;
end

if isfield(options,'sk_mean')==0
    m0=0;
else
    m0=options.sk_mean;
end

if isfield(options,'mean')==1
    m0=options.mean;
end

nknown=size(pos_known,1);
pos=1:1:nknown;

if isfield(options,'Cm');
    Cm=options.Cm;
else
    Cm=precal_cov(pos_known,pos_known,V,options);
    %Cm=precal_cov(pos_known,pos_known,V);
end
% TMH 05/05/2009 :
% CM IS NOT RIGHT IN CASE OF A NUGGET
% Cm=precal_cov(pos_known,pos_known,V)
% NUGGET IS NOT PRESENT


dm=val_known(:,1)-m0;


if method==1
    mgstat_verbose(sprintf('%s : Pardo-Iguzquiza likelihood',mfilename),1);
    % FROM Pardo-Iguzquiza, 1998, Math Geol, 30(1), EQN 8.
    % Kitanidis (1983), Water Res. Res. 19(4), EQN 29.
    sample_size=nknown;
    sill=sum([V.par1]);

    Cd=eye(size(Cm))+0.00001*sill; % FOR BETTER PERFORMANCE
    Cm=Cm+Cd;
    
    Q=Cm./sill;
    d_val=val_known(:,1)-mean(val_known(:,1));
    iQ=inv(Q);
    detQ=det(Q);
    FAC1=(sample_size/2)*(log(2*pi)+1-log(sample_size));
    dQd=d_val'*iQ*d_val;
    L_nllf=FAC1+.5*log(detQ)+(sample_size/2)*log(dQd);
    %L_nllf=(sample_size/2)*(log(2*pi)+1-log(sample_size))+.5*log(detQ)+(sample_size/2)*log(d_val'*iQ*d_val);
    if nargout > 1
        sigma2_est=(1/sample_size)*(dQd);
    end
    L=-1.*L_nllf;

    %HOO=FAC1+0.5*DET+0.5*NSUB*FAC2

elseif method==2
    %%% NOT YET TESTED !!!!!!
    mgstat_verbose(sprintf('%s : Pardo-Iguzquiza likelihood (known variance)',mfilename),1);
    % FROM Pardo-Iguzquiza, 1998, Math Geol, 30(1), EQN 5.
    sample_size=nknown;
    sill=sum([V.par1]);

    Q=Cm./sill;
    d_val=val_known(:,1);
    iQ=inv(Q);
    L_nllf=(sample_size/2)*log(2*pi) + sample_size.*log(sqrt(sill)) + .5*log(det(Q))+(1/(2*sill))*(d_val'*iQ*d_val);
    %L_nllf=log(det(Q))+sample_size*(d_val'*iQ*d_val);
    L=-1.*L_nllf;
    %if nargout > 1
    %    sigma2_est=(1/sample_size)*(d_val'*iQ*d_val);
    %    L=-1.*L_nllf;
    %    
    %end
elseif method==3,
    mgstat_verbose(sprintf('%s : gauss likelihood',mfilename),-1);
    L=(-.5*dm'*inv(Cm)*dm);
    sigma2_est=0;
end
% krig_covar_lik : Calculates the likelihood tha V is consistent with data observations
%
% Call : 
%   L=krig_covar_lik(pos_known,val_known,V,options)
%
%
% Can be used to covariance properties (range, sill, anisotropy,...)
%
function [L,d2u]=krig_covar_lik(pos_known,val_known,V,options,method)
    
    if exist('method','var')==0
        method=1;
    end
    
    
    options.dummy='';
    
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
    end
        
    dm=val_known(:,1)-m0;

    if method==1,
        L=exp(-.5*dm'*inv(Cm)*dm);
    elseif method==2
        % FROM Pardo-Iguzquiza, 1998, Math Geol, 30(1), EQN 8.
        % Kitanidis (1983), Water Res. Res. 19(4), EQN 29.
        sample_size=nknown;
        sill=sum([V.par1]);
        Q=Cm./sill;
        d_val=val_known(:,1);
        L_nllf=(sample_size/2)*(log(2*pi) +1 -log(sample_size) )+.5*log(det(Q))+(sample_size/2)*(d_val'*inv(Q)*d_val);
        L=-1.*L_nllf;
    end
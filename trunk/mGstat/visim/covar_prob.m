% covar_prob : THIS SHOULD BE CALLED FROM VISIM_PRIOR_PROB
function [Lmean,L,Ldim]=covar_prob(VaExpU,VaExpC,options)
    
    if nargin<3
        options.null='';
    end
    
    if isfield(options,'nocross')==1, nocross=options.nocross; else nocross=0; end
    
    
    ndim=length(VaExpU.g);
    
    for i=1:ndim
        iuse{i}=find(~isnan(sum(VaExpU.g{i}')));
        g{i}=VaExpU.g{i}(iuse{i},:);
        gcc{i}=cov([g{i}']);    
        g0_{i}=mean(VaExpU.g{i}');
        if i==1,
            gcc_cross=g{i}';
            g0=g0_{i}(iuse{i});
        else
            gcc_cross=[gcc_cross,g{i}'];
            g0=[g0 g0_{i}(iuse{i})];
        end
    end    
    gcc_cross=cov(gcc_cross);
    
    
    % NO USE OF CROSS CORRELATION
    if nocross==1
        gcc_cross2=0.*gcc_cross;
        for i=1:size(gcc_cross,1);
            gcc_cross2(i,i)=gcc_cross(i,i);       
        end
        gcc_cross=gcc_cross2;  
    end
    gcc_cross_diag=diag(gcc_cross);
  
    nsim=size(VaExpC.g{1},2);
   
    L=zeros(1,nsim);
    
    for is=1:nsim
        for i=1:ndim
            g_est_{i}=VaExpC.g{i}(:,is)'; % COND
            
            if i==1,
                g_est=g_est_{i}(iuse{i});
            else
                g_est=[g_est g_est_{i}(iuse{i})];
            end
        end

        dg=g0-g_est;
        L(is)=-.5*dg*inv(gcc_cross)*dg';
                    
        % JOINT PROBABILITY        
        for i=1:ndim
            dg_dim{i}=g0_{i}(iuse{i})-g_est_{i}(iuse{i});
            Ldim{i}(is)=-.5*dg_dim{i}*inv(gcc{i})*dg_dim{i}';
        end
        
    end
    %Lmean=log(mean(exp(L)));
    Lmean=mean(L);
        
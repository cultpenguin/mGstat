% least_squares_partition_data : least sq. inversion using partitioning
%
% See Tarantola (2005), page 197, eqn. 6.211 or 6.212.
%
% Least squares inversion by partitioning into to data subsets
% with independent data covariance !
% This can be very fast if the number of data observations is
% large, and large compared to the number of model parameters.
% 
%
% CALL : [m_est,Cm_est]=least_squares_partition_data(G,Cm,Cd,m0,d_obs,nsubsets,use_eq);
function [m_new,C_new]=least_squares_partition_data(G,Cm,Cd,m0,d0,nsubsets,use_eq);

if nargin<6
    nsubsets=4;
end
if nargin<7
    use_eq=6211;
    use_eq=337;
end    
n=size(Cd,1);
ipart=round(linspace(0,n,nsubsets+1));

C_old=Cm;
m_old=m0;


t1=now;
for i=1:nsubsets
    i1=ipart(i)+1;
    i2=ipart(i+1);
    ii=i1:i2;
    disp(sprintf('%s : using data %d-%d (eqn. %d)',mfilename,i1,i2,use_eq));
    
    tic;
    Cd_small=Cd(ii,ii);
    G_small=sparse(G(ii,:));
    d_small=d0(ii);

    if use_eq==337
        [m_new,C_new]=least_squares_inversion(G_small,C_old,Cd_small,m0,d_small,2);
    elseif use_eq==6211
        % Tarantola (2005) eqn. 6.211
        C_old=sparse(C_old);
        S=C_old*(G_small')*inv(Cd_small+G_small*C_old*G_small');
        m_new = m_old + S*(d_small - G_small*m_old);
        C_new = C_old - S*G_small*C_old;
    else
        % Tarantola (2005) eqn. 6.212
        S = inv( G_small'*inv(Cd_small)*G_small + inv(C_old));
        m_new = m_old + S*G_small'*inv(Cd_small)*(d_small - G_small*m_old);
        C_new = S ;
    end
    m_old = m_new;
    C_old = C_new;    
    
end
t2=now;
mgstat_verbose(sprintf('%s : Elapsed time : %6.1fs',mfilename,(t2-t1).*(24*3600)),10);
  

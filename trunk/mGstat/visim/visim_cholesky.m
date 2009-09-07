% visim_cholesky : conditional simulation using cholesky decomp. and a VISIM structure
%                  Fast conditional simulation for small models. 
%                  For larger models consider visim and visim_error_sim.
%
% See also: visim, visim_error_sim, gaussian_simulation_cholesky
%
function V=visim_cholesky(V);

% GET MATRIX FOR LEAST SQUARES INVERSION
if V.cond_sim==0
    % GET MATRIX FOR LEAST SQUARES INVERSION
    [G,d_obs,d_var,Cd,Cm_est,m_est]=visim_to_G(V);
else
    % GET MATRIX FOR LEAST SQUARES INVERSION
    [G,d_obs,d_var,Cd,Cm,m0]=visim_to_G(V);
    % PERFORM LEAST SQUARES INVERSION
    [m_est,Cm_est]=least_squares_inversion(G,Cm,Cd,m0,d_obs);
end

if V.nsim==0;% YET TO IMPLEMENT
    % RETURN LEAST SQUARES
    V.etype.mean=reshape(m_est,V.nx,V.ny);
    V.etype.var=reshape(diag(Cm_est),V.nx,V.ny);
    return
end
    
% GENERATE SAMPLES FROM POSTERIORI
[z,D]=gaussian_simulation_cholesky(reshape(m_est,V.ny,V.nx),Cm_est,V.nsim);

V.D=D;
[em,ev]=etype(D);
V.etype.mean=em;
V.etype.var=ev;

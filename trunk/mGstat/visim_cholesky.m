% visim_cholesky : conditional simulation using cholesky decomp. and a VISIM structure
%                  Fast conditional simulation for small models. 
%                  For larger models consider visim and visim_error_sim.
%
% See also: visim, visim_error_sim
%
function V=visim_cholesky(V);

% GET MATRIX FOR LEAST SQUARES INVERSION
[G,d_obs,d_var,Cd,Cm,m0]=visim_to_G(V);

% PERFORM LEAST SQUARES INVERSION
[m_est,Cm_est]=least_squares_inversion(G,Cm,Cd,m0,d0);

% GENERATE SAMPLES FROM POSTERIORI
[z,D]=gaussian_simulation_cholesky(m_est,Cm_est,V.nsim);

V.D=D;
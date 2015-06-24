% mps_enesim: sequential simulation of mulitple points statistical model
%
% Very simple 2D implementation of the MPS approach 
% described by Guardiano and Srivastava (1993)
%
% Call
%     [out,options]=mps_enesim(TI,SIM,options)
%
%  TI: [ny,nx] 2D training image (categorical variables
%  SIM: [ny2,nx2] 2D simulation grid. 'NaN' indicates an unkown value
%
%  options [struct] optional:
%  options.n_cond [int]: number of conditional points (def=5)
%  options.n_max_ite [int]: number of maximum iterations through the TI for matching patterns (def=200)
%
%  options.plot    [int]: [0]:none, [1]:plot cond, [2]:storing movie (def=0)
%  options.verbose [int]: [0] no info to screen, [1]:some info (def=1)
%
% See also: mps, mps_dsim
%
function [out,options]=mps_enesim(TI_data,SIM_data,options)
options.type='enesim';
[out,options]=mps(TI_data,SIM_data,options);

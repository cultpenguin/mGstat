% mps: sequential simulation of mulitple points statistical model
%
% Very simple 2D implementation of the MPS approach 
% described by Guardiano and Srivastava (1993)
%
% Call
%     [out,options]=mps(TI,SIM,options)
%
% 
%  TI: [ny,nx] 2D training image (categorical variables
%  SIM: [ny2,nx2] 2D simulation grid. 'NaN' indicates an unkown value
%
%  options.type='snesim';% SNESIM 
%  options.type='enesim';% ENESIM
%  options.type='dsim';  % DIRECT SAMPLING
%  options.plot    [int]: [0]:none, [1]:plot cond, [2]:storing movie (def=0)
%  options.verbose [int]: [0] no info to screen, [1]:some info (def=1)
%
%  % general options for all types
%  options [struct] optional:
%  options.n_cond [int]: number of conditional points (def=5)
%  options.n_cond [int]: number of conditional points (def=5)
%  options.rand_path [int]: [1] random path (default), [0] sequential path
%   
%
%  % options specific for enesim/sim
%  options.n_max_ite [int]: number of maximum iterations through the TI for matching patterns (def=200)
%
%  % options specific for snesim
%  options.n_mulgrids=1
%  
% See also: mps_enesim, mps_snesim
%
function [out,options]=mps(TI_data,SIM_data,options)
if nargin<3
  options.type='snesim';
end
if ~isfield(options,'type');
  options.type='snesim';
end  

if strcmp(options.type,'snesim');
  [out,options]=mps_snesim(TI_data,SIM_data,options);
else
  [out,options]=mps_enesim(TI_data,SIM_data,options);
end  

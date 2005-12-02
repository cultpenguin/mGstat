% mGstat Toolbox
% Version 0.1 Feb 18, 2004
%
% mGstat COMMANDS
%   mgstat_verbose - display verbose information
%   krig - simple/ordinary/tren kriging
%   precal_covar - precalculate covariance matrix
%   semivar_synth
%   semivar_exp
%   nscore : Normal socre transformation
%   inscore : Normal socre back transformation
%
%   sgsim    : Sequential Gaussian Simulation
%   dssim    : Direct sequential simulation
%   dssim-hr : Direct sequential simulation with histogram reprod.
%   etype : E-Type from reaslizations.
%
% GSTAT SPECIFIC COMMANDS
%   gstat         - call gstat with parfile of mat-structure
%   gstat_convert - convert binary GSTAT output to ASCII
%   gstat_krig    - Point kriging
%   --gstat_cokrig  - Point cokriging
%   --gstat_krig2d  - 2D kriging
%   --gstat_cokrig2d- 2D cokriging
%   gstat_binary  - returns the path to the binary gstat
%   gstat_demo    - mGstat demos
%   gstat_plot    - Plot predcition/simulation results.
%   semivar_exp_gstat - 
%
% IO
%   read_petrel    - read petrel ascii formatted file
%   read_gstat_par    - read gstat parameter file
%   write_gstat_par   - write gstat parameter file
%   read_eas          - read EAS ascii formatted files
%   write_eas         - write EAS ascii formatted files
%   read_arcinfo_ascii  - read ARCINFO ascii formatted files
%   write_arcinfo_ascii - write ARCINFO ascii formatted files
%
% MISC 
%   nanmean - mean of array, where NaN are excluded.
%   strip_space.m
%   format_variogram.m
%   deformat_variogram.m
%   vonk2d  - random field generator
%   watermark - adds label to figure
%   progress_txt - ascii progress bar
%

% Copyright (C) 2004 Thomas Mejer Hansen
%
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
%
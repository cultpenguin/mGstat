% mGstat Toolbox
% Version 0.1 Feb 18, 2004
%
% CALLING GSTAT AND GEOSTATISCTICAL COMMANDS
%   mgstat         - call gstat with parfile of mat-structure
%   mgstat_convert - convert binary GSTAT output to ASCII
%   mgstat_verbose - display verbose information
%   mgstat_krig    - Point kriging
%   mgstat_cokrig  - Point cokriging
%   mgstat_krig2d  - 2D kriging
%   mgstat_cokrig2d- 2D cokriging
%   mgstat_var     - plot variogram
%   mgstat_binary  - returns the path to the binary gstat
%   mgstat_test    - Runs all the example distributed with GSTAT
%   mgstat_demo    - mGstat demos
% PLOT 
%   mgstat_plot    - Plot predcition/simulation results.
%   cplot       - plot data as dots in specific colormap
% IO
%   read_gstat_par    - read gstat parameter file
%   write_gstat_par   - write gstat parameter file
%   read_eas          - read EAS ascii formatted files
%   write_eas         - write EAS ascii formatted files
%   read_arcinfo_ascii  - read ARCINFO ascii formatted files
%   write_arcinfo_ascii - write ARCINFO ascii formatted files
% PLOT 
%   cplot       - plot data as dots in specific colormap
% MISC 
%   nanmean - mean of array, where NaN are excluded.
%   strip_space.m
%   format_variogram.m
%   deformat_variogram.m
%   vonk2d  - random field generator
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
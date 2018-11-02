# mGstat
mGstat is a geostatistical toolbox for Matlab/Octave.

The latest version is availale from [Github](https://github.com/cultpenguin/mGstat):

    git clone https://github.com/cultpenguin/mGstat.git


mGstat provides

## Native Matlab code
mGstat contains a number of codes and functions written in pure Matlab/Octave.
These codes will therefore not win any speed competition, but allow easy hackable code.

### Native Kriging
* Kriging: Simple kriging, ordinary kriging and Universial/Kriging [krig.m](mfiles/krig.m) with a trend are available, and support 1D/2D/3D/ND. Synthetic semivariogram can be calculated using both GSLIB and GSTAT syntax.
* Semivariogram: Experimental semivariograms can be calculated from data observations. Synthetic semivariogram can be calculated using both GSLIB and GSTAT syntax. Experimental semivariograms can be calculated from data observations. 
* Simulation: Sequential Gaussian Simulation [sgsim.m](mfiles/sgsim.m), LU simulation [lusim.m](mfiles/lusim.m), Direct Sequential Simulation [dssim.m](mfiles/dssim.m), FFT Moving Averate [fft-ma.m](mfiles/fft-ma.m)
* Normal Score: forward and inverse normal score ([nscore.m](mfiles/nscore.m), [inscore.m](mfiles/inscore.m))

[..more in the manual](doc/chapKriging.md)

## Native Multiple Point Statistics - MPS
* ENESIM/GENESIM/Direct Sampling [mps_enesim.m](mps/mps_enesim.m)
* SNESIM (tree/list) [mps_snesim.m](mps/mps_snesim.m)

[.. more info in the manual][..more in the manual](doc/chapMPS.md)

## In Interface to existing codes

### An interface to MPSLIB

[..more in the manual](doc/chapMPSLIB.md)

### An interface to SNESIM (Fortran Stanford Version)

### An interface to GSTAT
mGstat provides an interface to GSTAT[www], which is a popular open source computer code for multivariate geostatistical modelling.
The interface enable one to call gstat and have the output returned seamlessly into Matlab. 
The interface makes it straightforward to call GSTAT using Matlab as a scripting language. 
[..more info in the manual]

### An interface to VISIM
VISIM[www] is a GSLIB style program that can be used to solve linear inverse problems, using either Sequential Gaussian Simulation or Direct Sequential Simulation (with histogram reproduction) conditioned to noisy block data.
It can also function as a conventional point based simulation algorithm.
The mGstat interface enables one to read VISIM parameter files into a Matlab structure. Any VISIM option can be changed through this structure.
Using mGstat, VISIM can be used to perform Conditional Simulation thorugh Error Simulation.

[..more in the manual](doc/chapVISIM.md)


# mGstat
mGstat is a geostatistical toolbox for Matlab/Octave.

The latest version is availale from [Github](https://github.com/cultpenguin/mGstat):

    git clone https://github.com/cultpenguin/mGstat.git


mGstat provides

## Native kriging kriging algorithms
Simple kriging, ordinary kriging and Universial/Kriging with a trend are available. All methods support data observations in ND-space. Thus, for example Time-Space kriging can be used.
Synthetic semivariogram can be calculated using both GSLIB and GSTAT syntax. Experimental semivariograms can be calculated from data observations. 

[..more in the manual](doc/chapMPSLIB.md)

## Native MPS algorithms
Simple kriging, ordinary kriging and Universial/Kriging with a trend are available. All methods support data observations in ND-space. Thus, for example Time-Space kriging can be used.
Synthetic semivariogram can be calculated using both GSLIB and GSTAT syntax. Experimental semivariograms can be calculated from data observations. 

[.. more info in the manual][..more in the manual](doc/chapMPSLIB.md)

## An interface to MPSLIB

[..more in the manual](doc/chapMPSLIB.md)

## An interface to SNESIM (Fortran Stanford Version)

## An interface to GSTAT
mGstat provides an interface to GSTAT[www], which is a popular open source computer code for multivariate geostatistical modelling.
The interface enable one to call gstat and have the output returned seamlessly into Matlab. 
The interface makes it straightforward to call GSTAT using Matlab as a scripting language. 
[..more info in the manual]

## An interface to VISIM
VISIM[www] is a GSLIB style program that can be used to solve linear inverse problems, using either Sequential Gaussian Simulation or Direct Sequential Simulation (with histogram reproduction) conditioned to noisy block data.
It can also function as a conventional point based simulation algorithm.
The mGstat interface enables one to read VISIM parameter files into a Matlab structure. Any VISIM option can be changed through this structure.
Using mGstat, VISIM can be used to perform Conditional Simulation thorugh Error Simulation.

[..more in the manual](doc/chapVISIM.md)


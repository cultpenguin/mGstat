# mGstat: Matlab toolbox of geostatistical tools

mGstat contains a native Matalab implementation of kriging (simpe, oridnary, and trend) for both estimation and simulation, 
and the FFT Moving Average method [https://doi.org/10.1023/A:1007542406333].

mGstat contains a Matlab interface of 
GSTAT [http://gstat.org/], 
VISIM [https://doi.org/10.1016/j.cageo.2007.02.003], an early version of 
SNESIM [https://github.com/SCRFpublic/snesim-standalone],and an early open version of 
SGeMS [http://sgems.sourceforge.net/].


Documentation available at  
http://mgstat.sourceforge.net/

## Getting started

An ultra short intro guide for mGstat :
Open Matlab and change directory to the folder in which you unpacked mGstat*.zip of mGstat*.tgz:
run the following command in matlab:

  >>mgstat_set_path

This sets the proper paths and saves the path for future Matlab session. 

Then, go to a working directory, and try out some of the demos:

mgstat_demo

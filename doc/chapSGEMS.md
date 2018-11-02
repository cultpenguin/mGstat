Install SGEMS {#inssgems}
=============

See [???](#InstallSgems) on details how to install SGEMS on Windows and
Linux.

SGEMS data format {#SGEMS_data_format}
=================

SGEMS handles two data formats: The classical ASCII GEOEAS format, that
has been widely used in the geostatistical community. In addition, SGEMS
make use of a new in BINARY format. The binary format is much faster to
work with, and handles both point set data and grid data, will full
description of the grid properties (cell size, origin, grid size).

In order to run SGEMS interactively from MATLAB only the binary format
can be used, as there is no way to instruct SGEMS about grid size
properties reading a EAS file.

Reading and writing of the GEOEAS format are done using the
[???](#read_eas) and [???](#write_eas) function.

Binary SGEMS formatted data (both point set and grid data) can be read
using the [???](#sgems_read) function.

Binary point set data can be written using the
[???](#sgems_write_pointset) function, and binary grid data can be
written using the [???](#sgems_write_grid) function, and

GEOEAS to SGEMS {#SGEMS_eas_to_sgems}
---------------

EAS files can be converted to SGEMS-binary formatted files using
[???](#eas2sgems).

### GEOEAS Point Set to SGEMS-binary {#SGEMS_eas_to_sgems_POINT}

An EAS with data formatted as a point-set, the data section starts with
'ndim' columns defining the location in ndim-space, followed by N
columns of DATA.

Use the following syntax:

     
    O=eas2sgems(file_eas,file_sgems,ndim);

Convert a 3D EAS file with two data sets (5 cols, 3 dimensions) using

     
    ndim=3
    eas2sgems('file.eas','file.sgems',ndim)

Convert a 2D EAS file with two data sets (4 cols, 2 dimensions) using

     
    ndim=2
    eas2sgems('file.eas','file.sgems',ndim)

### GEOEAS GRID to SGEMS-binary {#SGEMS_eas_to_sgems_GRID}

For an EAS with data formatted as GRIDS, the data section consist of N
colums, representing N grids. An EAS not does not contain information
about the cell size (dx,dy,dx) cell size, or the location of the first
cell for each dimension (x0,y0,z0).

It 'may' (not part of strict format) contain information about the size
of the grid(s) in the first line 'xxxxx (90x10x1)'.

Use the following syntax:

    O=eas2sgems(file_eas,file_sgems,nx,ny,nz,dx,dy,dz,x0,y0,z0);

Convert an EAS file with 2 grids, assuming the grid size is given in the
EAS header ('HEADER (60x70x1)'), and(dx,dy,dz)=(1,1,1),
(x0,y0,z0)=(0,0,0):

     
    ndim=2
    eas2sgems('file.eas','file.sgems')

Same as above, but all manual settings:

     
    eas2sgems('file.eas','file.sgems',60,70,1,1,1,1,0,0,0); 

Same as above, but but (x0,y0,z0)=(10,10,6):

     
    eas2sgems('file.eas','file.sgems',60,70,1,10,10,6,0,0,0); 

SGEMS to EAS {#SGEMS_sgems_to_eas}
------------

SGEMS-binary formatted files can be converted to EAS ASCII formatted
files using [???](#sgems2eas). Simply call :

    sgems2eas('file.sgems','file.eas');

Using SGEMS {#chapSGEMSuse}
===========

In order to make full use of the MATLAB interface to SGEMS some
knowledge of the use of SGEMS is essential. The book Applied
Geostatistics with SGeMS (Remy, Boucher and Wu, Cambridge University
Press, 2009), written by the developers of SGEMS is highly recommended.

The MATLAB interface to SGEMS relies on a feature of SGEMS that allow
SGEMS to read and execute a series of Python commands from the command
line, without the need to load the graphical user interface, as for
example:

    sgems -s sgems_python_script.py

The MATLAB interface consists of methods and functions to automatically
create such a Python script, execute the script using SGEMS and load the
simulated/estimated results into MATLAB

One function ([???](#sgems_grid)) handles these actions allowing
simulation on grids in the following manner:

1.  Define a parameter file ([???](#sgems_get_par),
    [???](#sgems_read_xml))

2.  Write a python script that ([???](#sgems_grid_py))

    1.  sets up a grid or pointset where simulation or estimation is
        performed

    2.  performs the simulation/estimation

    3.  export the simulated/estimated data

3.  Load the data into MATLAB ([???](#sgems_write))

For a complete list of SGEMS related commands on MGSTAT see
[???](#ref_sgems)

Sequential simulation using SGEMS {#SGEMS_seqsim}
---------------------------------

This section contains a rather detailed explanation of using SGEMS to
perform simulation. Much more compact example can be found in the
following chapters.

Unconditional and conditional sequential simulation can be performed
using [???](#sgems_grid) :

    S = sgems_grid(S);

Where `S` is a MATLAB data structure containing all the information
needed to setup and run SGEMS

A number of different simulation algorithms are available in SGEMS The
behavior of each algorithm is controlled through an XML file. Such an
XML file can for example be exported from SGEMS by choosing to save a
parameter file for a specific algorithm.

Such an XML formatted parameter is needed to perform any kind of
simulation. A number of 'default' parameter files available using the
[???](#sgems_get_par) function. For example to obtain a default
parameter file for sequential Gaussian simulation use

    S = sgems_get_par('sgsim')

    S = 

        xml_file: 'sgsim.par'
             XML: [1x1 struct]

As can be seen the adds the name of the XML file (S.xml\_file) as well
as a XML data structure in the SGEMS matlab structure `S.XML`.

All supported simulation/estimation types can be found calling
`sgems_get_par` without arguments:

``` {.matlab}
>> sgems_get_par
sgems_get_par : available SGeMS type dssim
sgems_get_par : available SGeMS type filtersim_cate
sgems_get_par : available SGeMS type filtersim_cont
sgems_get_par : available SGeMS type lusim
sgems_get_par : available SGeMS type sgsim
sgems_get_par : available SGeMS type snesim_std
```

Now all parameters for 'sgsim' simulation can be set directly from the
MATLAB command line. To see the number of fields in the XML file (refer
to the SGEMS book described above for the meaning of all parameters):

    >> S.XML.parameters

    ans = 

                    algorithm: [1x1 struct]
                    Grid_Name: [1x1 struct]
                Property_Name: [1x1 struct]
              Nb_Realizations: [1x1 struct]
                         Seed: [1x1 struct]
                 Kriging_Type: [1x1 struct]
                        Trend: [1x1 struct]
          Local_Mean_Property: [1x1 struct]
             Assign_Hard_Data: [1x1 struct]
                    Hard_Data: [1x1 struct]
        Max_Conditioning_Data: [1x1 struct]
             Search_Ellipsoid: [1x1 struct]
         Use_Target_Histogram: [1x1 struct]
                  nonParamCdf: [1x1 struct]
                    Variogram: [1x1 struct]

To see the number of realization :

    >> S.XML.parameters.Nb_Realizations

    ans = 

        value: 10

To set the number of realization to 20 do:

    >> S.XML.parameters.Nb_Realizations.value=20;

One also need to define the grid used for simulation. This is done
through the `S.dim` data structure:

    %grid size
    S.dim.nx=70;
    S.dim.ny=60;
    S.dim.nz=1;
    % grid cell size
    S.dim.dx=1;
    S.dim.dy=1;
    S.dim.dz=1;
    % grid origin
    S.dim.x0=0;
    S.dim.y0=0;
    S.dim.z0=0;

All the values listed above for the `S.dim` data structure are default,
thus if they are not set, they are assumed as listed.

Unconditional simulation is now performed using:

    >> S=sgems_grid(S);
    sgems_grid : Trying to run SGeMS using sgsim.py, output to SGSIM.out
    'import site' failed; use -v for traceback 
    Executing script... 
     
    working on realization 1
    |#                   |    5%working on realization 2
    |##                  |    10%working on realization 3
    |###                 |    15%working on realization 4
    |####                |    20%working on realization 5
    |#####               |    25%working on realization 6
    |######              |    30%working on realization 7
    |#######             |    35%working on realization 8
    |########            |    40%working on realization 9
    |#########           |    45%working on realization 10
    |##########          |    50%working on realization 11
    |###########         |    55%working on realization 12
    |############        |    60%working on realization 13
    |#############       |    65%working on realization 14
    |##############      |    70%working on realization 15
    |###############     |    75%working on realization 16
    |################    |    80%working on realization 17
    |#################   |    85%working on realization 18
    |##################  |    90%working on realization 19
    |################### |    95%working on realization 20
    |####################|    100% 
    sgems_read : Reading GRID data from SGSIM.sgems
    sgems_grid : SGeMS ran successfully

    S = 

        xml_file: 'sgsim.par'
             XML: [1x1 struct]
             dim: [1x1 struct]
            data: [4200x20 double]
               O: [1x1 struct]
               x: [1x70 double]
               y: [1x60 double]
               z: 1
               D: [4-D double]

As seen above the following field have been added to the SGEMS matlab
structure: `S.x`, `S.y`, `S.z`, `S.data` and `S.D`.

`S.x`, `S.y`, `S.z` are 3 arrays defining the grid.

`S.data`, is the simulated data as exported from SGEMS. Note the each
realization is returned as a list of size nx\*ny\*nz.

`S.D`, is but a rearrangement of `S.data` into a 4D dimensional data
structure, of size (nx,ny,nz,nsim). To visualize for example the 3rd
realization use for example:

    imagesc(S.x,S.y,S.D(:,:,1,3));

Conditional simulation can be performed by setting the `S.d_obs`
parameter. For example:

    S.d_obs=[18 13 0 0; 5 5 0 1; 2 28 0 1];
    S=sgems_grid(S);
    imagesc(S.x,S.y,S.D(:,:,1,3));

### Specification of variogram model {#SgemsSemivariogram}

Using sequential Gaussian simulation the semivariogram model is
specified in `S.XML.parameters.Variogram`:

    >> S.XML.parameters.Variogram
    ans=
          nugget: 1.0000e-003
       structures_count: 1
            structure_1: [1x1 struct

To run 10 simulations with increasing range do for example:

    for i=1:1:10
      r=i*10;
      S.XML.parameters.Variogram.structure_1.ranges.max=[r];
      S.XML.parameters.Variogram.structure_1.ranges.medium=[r];
      S.XML.parameters.Variogram.structure_1.ranges.min=[r];
      S=sgems_grid(S);
      subplot(4,3,i);imagesc(S.x,S.y,S.D(:,:,1)');
    end

The variogram model can also be specified using a shorter notation (same
format as when using GSTAT):

        S.XML.parameters.Variogram=sgems_variogram_xml('0.1 Nug(0) + 0.4 Exp(10) + 0.5 Sph(40,30,0.2)');

Unconditional sequential Gaussian simulation using SGEMS {#SGEMS_seqsim_uncond}
--------------------------------------------------------

A simple example of unconditional sequential simulation.

    S=sgems_get_par('sgsim');
    S.XML.parameters.Nb_Realizations.value=12;
    S=sgems_grid(S);
    for i=1:S.XML.parameters.Nb_Realizations.value;
      subplot(4,3,i);
      imagesc(S.x,S.y,S.D(:,:,1,i));
    end

Conditional sequential Gaussian simulation {#SGEMS_seqsim_cond}
------------------------------------------

Conditioning data can be specified either as a data variable or as an
sgems-binary formatted file (see [SGEMS data
format](#SGEMS_data_format)).

### conditional data as a variable {#SGEMS_seqsim_cond_var}

A simple example of conditional sequential simulation
(`examples/sgems_examples/sgems_example_sgsim_conditional.m`):

``` {.matlab }
```

### conditional data from file {#SGEMS_seqsim_cond_file}

A simple example of conditional sequential simulation
(`examples/sgems_examples/sgems_example_sgsim_conditional_hard_data_from_file.m`):

``` {.matlab }
```

![Sequential Gaussian conditional
simulation](figures/sgems_example_sgsim_conditional_hard_data_from_file.png){width="100%"}

Unconditional SNESIM and FILTERSIM Gaussian simulation using SGEMS {#SGEMS_seqsim_snesim}
------------------------------------------------------------------

A simple example of unconditional SNESIM AND FILTERSIM simulation.


    S1=sgems_get_par('snesim_std'); %
    % Note that S1.ti_file is automatically set. 
    % simply change this to point to another training to use.
    S1.XML.parameters.Nb_Realizations.value=4;

    S2=sgems_get_par('filtersim_cont');
    S2.XML.parameters.Nb_Realizations.value=4;

    S1=sgems_grid(S1);
    S2=sgems_grid(S2);


    for i=1:S1.XML.parameters.Nb_Realizations.value;
      subplot(S1.XML.parameters.Nb_Realizations.value,2,i);
      imagesc(S1.x,S1.y,S1.D(:,:,1,i));axis image;

      subplot(S1.XML.parameters.Nb_Realizations.value,2,i+S1.XML.parameters.Nb_Realizations.value);
      imagesc(S2.x,S2.y,S2.D(:,:,1,i));axis image;
    end

Convert image to training image; {#SGEMS_image2ti}
--------------------------------

Using [a JPG file from
FLICKR](http://farm3.static.flickr.com/2117/1609350318_7300f07360_d.jpg)
as training image:

``` {.matlab }
```

![Example of converting an image and using it for continuous filtersim
simulation](figures/sgems_example_ti_from_image.png){width="100%"}

Simulation demonstration
------------------------

Demonstration simulation of MGSTAT supported simulation algorithms can
be performed using [???](#sgems_demo). To see a list of supported
simulation algorithms use:

``` {.matlab}
>> sgems_get_par
sgems_get_par : available SGeMS type dssim
sgems_get_par : available SGeMS type filtersim_cate
sgems_get_par : available SGeMS type filtersim_cont
sgems_get_par : available SGeMS type lusim
sgems_get_par : available SGeMS type sgsim
sgems_get_par : available SGeMS type snesim_std
```

To run a demonstration of continuous filtersim simulation using the
'filtersim\_cont' algorithm do

``` {.matlab}
>> sgems_demo('filtersim_cont');
```

This will perform both unconditional and conditional simulation, and
visualize the results as for example here below.

![Unconditional
simulation](figures/sgems_demo_filtersim_cont_uncond.png){width="100%"}

![Conditional
simulation](figures/sgems_demo_filtersim_cont_cond.png){width="100%"}

![E-type on conditional
simulations](figures/sgems_demo_filtersim_cont_etype.png){width="100%"}

Running [???](#sgems_demo) without arguments will run the demonstration
using all supported simulation algorithms.

Probability perturbation (PPM)
------------------------------

`examples/sgems-examples/sgems_example_ppm.m` is an example of applying
the probability perturbation method, where one realization can be
gradually deformed into another independent realization.

``` {.matlab }
```

![Example of applying the Probability Perturbation Method using
SGEMS](figures/sgems_example_ppm.png){width="100%"}

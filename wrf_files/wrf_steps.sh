#!/bin/bash

## Create directory for folders and other files
mkdir wrf_stuff
cd wrf_stuff

## All paths specific to WRF should be set (HDF5 and NETCDF

## Clone the git repos
git clone https://github.com/wrf-model/WPS.git
git clone https://github.com/wrf-model/WRF.git

## Enter WRF directory and configure
cd WRF

./configure
# Runs the configure script for WRF. The container uses gcc and mpich, so to configure WRF, you should run select option 35 (smpar+dmpar, gcc option).
# Then enter "1" for the nesting option.

# Once configured, you view the configure.wrf file to view the compiler, mpi, and openmp options enabled. However, it should be correct. Then you just compile with:
 ./compile em_real >& log.compile

# Saving your own log file is optional.
# Once finished (~35-40 min), you can run ls "ls main/*exe", which should return 4 executables (ndown.exe, real.exe, tc.exe, wrf.exe).


## Enter WPS directory and configure, allowing it to build it's own libpng, zlib, and jasper so that it can compile ungrib.exe.
cd WPS

./configure --build-grib2-libs
## Select "—build-grib2-libs" make WPS compile it's own libpng, zlib, and jasper so that it can compile ungrib.exe. 
# Select either option 1 (serial) or 2 (dmpar) 

# Then, to compile all WPS executables, you have to make the following change to the configure.wps script once it has been created:
# L$(NETCDF)/lib -lnetcdff -lnetcdf
# to
# L$(NETCDF)/lib -lnetcdff -lnetcdf -lgomp -lpthread
# You can find it at the WRF_LIB line in the file.

## Then compile 
./compile or #./compile >& log.compile
#This should produce geogrid.exe, metgrid.exe, and ungrib.exe. (~2-3 min)

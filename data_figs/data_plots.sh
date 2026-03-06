#!/bin/bash 

###########################################################
## Creating plots and figures to compare data and output ##
###########################################################

# Copy output files from the model runs into the directory
cp ../WRF/run/wrfout_d01_2011-04-28_00:00:00 .
cp ../pangu_example/outputs/2011-04-27-00-00to2011-04-28-12-00/output_surface_2011-04-28-00-00.nc .

# If you would like to look at other hours, you will need to edit the python scripts and copy new data files.
# Run scripts to subset the output netcdf files to the desired lat lon range and plot the data
python pangu_fig.py
python wrf_fig.py





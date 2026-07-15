#!/bin/bash

## Enter workshop directory
cd /anvil/scratch/$USER/WRF_training_SCIPE

## Make sure you are in the correct directory and set your Workshop directory path
pwd
export WORKSHOP=/anvil/scratch/$USER/WRF_training_SCIPE


###################################
###################################
####### Running WRF and WPS #######
###################################
###################################

#######################
######## WPS ##########
#######################

## Enter WPS Directory to complete final preprocessing step (The others have been completed for you)
        # You should already see geo_em.d01.nc and "FILE*" files
cd $WORKSHOP/WPS
ls -l $WORKSHOP/WPS/geo_em*
ls -l $WORKSHOP/WPS/FILE*

## We will be requesting 10 cores for 10 minutes
## Be sure to enter your email to recieve emails on your job status or delete to not be notified
## You association has been filled in for you and is specific to the allocation.

## The srun command uses "appatainer exec" to run the command from within the container using the "wrf.sif" file.
## We are running metgrid.exe to create files for real.exe in the WRF directory
sbatch $WORKSHOP/WPS/run_wps.sh
## Make sure that the job is running
squeue -u $USER

## Once completed you should see "met_em" files for each boundary condition update hour
ls $WORKSHOP/WPS/met_em*

#######################
######## WRF ##########
#######################

## Move to your WRF/run directory and link the "met_em" files to this directory
cd $WORKSHOP/WRF/run
ln -sf $WORKSHOP/WPS/met_em* $WORKSHOP/WRF/run

## You should now see all of your "met_em" files and your job script
ls -l $WORKSHOP/WRF/run/run_wrf.sh
ls -l $WORKSHOP/WRF/run/met_em*

## Our first run will be using 20 cores 
## The command that is run is the execution of real.exe in serial 
## The wrf.exe (the model) is run after. As with WPS, these are run using the container file wrf.sif
sbatch $WORKSHOP/WRF/run/run_wrf.sh

## Make sure that the job is running
squeue -u $USER

## Check for real.exe output files 
ls $WORKSHOP/WRF/run/wrfbdy*
ls $WORKSHOP/WRF/run/wrfinput*

## wrf.exe will create a log file that records the timing of every timestep that is run
tail -f $WORKSHOP/WRF/run/rsl.out.0000
## Use "Ctrl c" to exit

## Cancel job, edit namelist (for openmp), and resubmit with updated SBATCH options. (can be pasted from squeue output)
scancel <job_id>
sbatch $WORKSHOP/WRF/run/run_wrf.sh

## Make sure that the job is running and view output
squeue -u $USER
tail -f $WORKSHOP/WRF/run/rsl.out.0000
## Use "Ctrl c" to exit

## Once completed you should with "wrfout" files that contain your actual model output
ls $WORKSHOP/WRF/run/wrfout*


###########################################
###########################################
####### Running Pangu Weather Model #######
###########################################
###########################################

## Enter pangu_example directory and untar the input data
cd $WORKSHOP/pangu_example

## The data have been retrieved and prepared for you, so you do not need to run the data_prepare.py script
## The next step is to run the forecast
## The inference.py script will create the "results" directory containing the output of the model (both surface and upper)
## To convert this, we must run "forecast_decode.py", which converts the data back to netcdf data and stores them in the "outputs" directory
## The "run_pangu.sh" slurm script will run both of these python scripts using our conda env
sbatch $WORKSHOP/pangu_example/run_pangu.sh

## Check the following directories for model output
## The results directory contains the output in numpy data arrays (output of inference.py)
ls -l $WORKSHOP/pangu_example/results/2011-04-27-00-00to2011-04-28-12-00
## The outputs directory contains the output in netcdf (output of forecast_decode.py)
ls -l $WORKSHOP/pangu_example/outputs/2011-04-27-00-00to2011-04-28-12-00


##################################
##################################
####### Visualizing Output #######
##################################
##################################

## All of the plot scripts are located under the "data_figs" directory
## We need to move the output files to this directory (specifcally April 28th at 00z)
cd $WORKSHOP/data_figs
cp $WORKSHOP/pangu_example/outputs/2011-04-27-00-00to2011-04-28-12-00/output_surface_2011-04-28-00-00.nc $WORKSHOP/data_figs
cp $WORKSHOP/WRF/run/wrfout_d01_2011-04-28_00:00:00 $WORKSHOP/data_figs

## Submit the following slurm script to create all of the figures
sbatch $WORKSHOP/data_figs/figures.sh

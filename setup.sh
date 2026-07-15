#!/bin/bash
  
## The training will be carried out in your scratch space.
cd /anvil/scratch/$USER

## Clone and enter the github repository
#git clone https://github.com/CongGian/WRF_training_SCIPE.git # Be sure to update the link if any change to the repo name

## Make sure you are in the correct directory and set your Workshop directory path
export WORKSHOP=/anvil/scratch/$USER/WRF_training_SCIPE

###########################
####### WRF and WPS #######
###########################

## Copy wrf.sif container file into workshop directory 
#cp /anvil/projects/x-cis240917/WRF_training_SCIPE/wrf.sif $WORKSHOP

## Copy Pre-compiled Weather Research and Forecasting (WRF) model and WRF Preprossesing System (WPS) into directory
cp -r /anvil/projects/x-cis240917/WRF_training_SCIPE/WRF $WORKSHOP
cp -r /anvil/projects/x-cis240917/WRF_training_SCIPE/WPS $WORKSHOP

## Copy WPS job script into WPS Directory
cp $WORKSHOP/wrf_files/run_wps.sh $WORKSHOP/WPS
cp $WORKSHOP/wrf_files/namelist.wps $WORKSHOP/WPS

## Copy your job script into the directory
cp $WORKSHOP/wrf_files/run_wrf.sh $WORKSHOP/WRF/run
cp $WORKSHOP/wrf_files/namelist.input $WORKSHOP/WRF/run

###########################
######### Pangu ###########
###########################

## Enter pangu_example directory and untar the input data
## Untarring the data file produces the “forecasts/2011-04-27-00-00” directory
cd $WORKSHOP/pangu_example
tar -xJvf $WORKSHOP/pangu_example/data_input.tar.xz

## Create the directory to store the model weights and link the models
mkdir $WORKSHOP/pangu_example/models
ln -s /anvil/projects/x-cis240917/WRF_training_SCIPE/pangu_example/models/* $WORKSHOP/pangu_example/models



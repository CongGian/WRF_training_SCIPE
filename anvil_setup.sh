#!/bin/bash

# 1. Register for an account at Climate Data Store
# 2. Copy the url and key displayed on CDS API key and add them to the ~/.cdsapirc file
# 3. Clone this repo and install dependencies accordingly, depnding on GPU availability

git clone https://github.com/HaxyMoly/Pangu-Weather-ReadyToGo.git
cd pangu_example

## Set variables and create directories for conda and python package to not flood home directory
#export SCRATCH=/anvil/scratch/$USER/
#export CONDA_ENVS_PATH=$SCRATCH/conda/envs
#export CONDA_PKGS_DIRS=$SCRATCH/conda/pkgs
#export PIP_CACHE_DIR=$SCRATCH/pip/cache

## Load Modules and create env
ml conda/2025.09

conda create -n pangu python=3.11
conda activate pangu

# CuDNN package for neural networks and cuda-toolkit: These have to be compatable with each other and onnx library in requirements_gpu.txt
conda install -c nvidia cuda-toolkit=12.9.1 cudnn
# CuDNN is not of the system

# GPU
pip install -r requirements_gpu.txt

## Install ipykernal if wanted to use Jupyter notebook for anything
conda install -c conda-forge cartopy ipykernal cfgrib

# Install ipykernal for jupyter notebook use
python -m ipykernel install --name pangu --display-name "Python (Pangu)" --user


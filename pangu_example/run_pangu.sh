#!/bin/sh -l

#SBATCH -A cis240917-gpu
#SBATCH -p gpu # the default queue is "shared" queue
#SBATCH --gpus-per-node=1
##SBATCH --gres=gpu:1
#SBATCH --nodes=1
#SBATCH --time=00:05:00
#SBATCH --mem=15G
#SBATCH --job-name pangu
#SBATCH --mail-user=<your_email>   # e-mail address
#SBATCH --mail-type=END

# Load conda and activate environment
ml conda
conda activate /anvil/projects/x-cis240917/WRF_training_SCIPE/pangu

# Run inference.py to make a forecast
python inference.py > log.steps

# Convert the forecast output (numpy array) back to NetCDF format
python forecast_decode.py > log.decode

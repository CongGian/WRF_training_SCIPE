#!/bin/sh -l
  
#SBATCH -A cis240917
#SBATCH -p shared # the default queue is "shared" queue
#SBATCH --nodes=1
#SBATCH --mem=6G
#SBATCH --time=00:02:00
#SBATCH --job-name figures
#SBATCH --mail-user=<your_email>   # e-mail address
#SBATCH --mail-type=BEGIN,FAIL,END
#SBATCH --reservation=ci_pivot_cpu

# Load conda and activate environment
ml conda
conda activate /anvil/projects/x-cis240917/WRF_training_SCIPE/pangu

export WORKSHOP=/anvil/scratch/$USER/WRF_training_SCIPE

# Create figures
python $WORKSHOP/data_figs/era5_fig.py
python $WORKSHOP/data_figs/wrf_fig.py
python $WORKSHOP/data_figs/pangu_fig.py

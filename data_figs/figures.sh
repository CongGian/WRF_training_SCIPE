!/bin/sh -l
  
#SBATCH -A cis240917
#SBATCH -p shared # the default queue is "shared" queue
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=00:05:00
#SBATCH --job-name figures
#SBATCH --mail-user=<your_email>   # e-mail address
#SBATCH --mail-type=BEGIN,FAIL,END

# Load conda and activate environment
ml purge
ml conda
conda activate /anvil/scratch/x-tknight/env_test/pangu

export WORKSHOP=/anvil/scratch/$USER/WRF_training_SCIPE

# Create figures
python $WORKSHOP/data_figs/era5_fig.py
python $WORKSHOP/data_figs/wrf_fig.py
python $WORKSHOP/data_figs/pangu_fig.py

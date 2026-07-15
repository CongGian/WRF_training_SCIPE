#!/bin/sh -l

#SBATCH -A cis240917
#SBATCH -p shared # the default queue is "shared" queue
#SBATCH --nodes=1
#SBATCH --ntasks=2
#SBATCH --time=00:05:00
#SBATCH --job-name wps
#SBATCH --mail-user=<your_email>  # e-mail address
#SBATCH --mail-type=BEGIN,FAIL,END
#SBATCH --reservation=ci_pivot_cpu

# Unload all modules
ml purge

# Load mvapich2 for parallel execution 
ml gcc
ml mvapich2

export SCRATCH=/anvil/scratch/$USER

# Run program using container
srun --mpi=pmi2 apptainer exec $SCRATCH/WRF_training_SCIPE/wrf.sif $SCRATCH/WRF_training_SCIPE/WPS/metgrid.exe



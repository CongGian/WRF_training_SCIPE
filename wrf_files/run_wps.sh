#!/bin/sh -l

#SBATCH -A cis240917
#SBATCH -p shared # the default queue is "shared" queue
#SBATCH --nodes=1
#SBATCH --ntasks=10
#SBATCH --mem=20G 
#SBATCH --time=1:00:00
#SBATCH --job-name wps
#SBATCH --mail-user=ak1817@msstate.edu   # e-mail address
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

# Unload all modules
ml purge

# Load mvapich2 for parallel execution 
ml gcc
ml  mvapich2

export SCRATCH=/anvil/scratch/$USER

# Run program using container
srun --mpi=pmi2 apptainer exec $SCRATCH/WRF_training_SCIPE/wrf.sif $SCRATCH/WRF_training_SCIPE/WPS/metgrid.exe



#!/bin/sh -l

#SBATCH -A cis240917
#SBATCH -p shared # the default queue is "shared" queue
#SBATCH --nodes=1
#SBATCH --ntasks=16
##SBATCH --cpus-per-task=2 # Uncomment when not using openmp to maintain 20 cores
#SBATCH --time=00:20:00
#SBATCH --job-name wrf
#SBATCH --mail-user=<your_email>   # e-mail address
#SBATCH --mail-type=BEGIN,FAIL,END
#SBATCH --reservation=ci_pivot_cpu

# Unload all modules
ml purge

# Load mvapich2 for parallel execution 
ml gcc
ml mvapich2

export SCRATCH=/anvil/scratch/$USER

# Run real.exe to get input and boundary conditions files
apptainer exec $SCRATCH/WRF_training_SCIPE/wrf.sif $SCRATCH/WRF_training_SCIPE/WRF/run/real.exe

# Run wrf program using container
srun --mpi=pmi2 apptainer exec $SCRATCH/WRF_training_SCIPE/wrf.sif $SCRATCH/WRF_training_SCIPE/WRF/run/wrf.exe


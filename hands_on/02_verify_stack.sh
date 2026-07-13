#!/usr/bin/env bash
set -euo pipefail

SCRATCH="${SCRATCH:-/anvil/scratch/${USER}}"
WORKSHOP="${WORKSHOP:-${SCRATCH}/WRF_training_SCIPE}"
IMAGE="${IMAGE:-${WORKSHOP}/wrf.sif}"

# Anvil may set LD_PRELOAD for site instrumentation such as XALT.
# Clear it so host preload libraries do not leak into Apptainer commands.
unset LD_PRELOAD

apptainer exec "${IMAGE}" /bin/bash -lc '
    set -e
    source /opt/scripts/paths.sh

    echo "== MPI wrappers =="
    command -v mpicc
    command -v mpif90
    mpichversion | sed -n "1,6p"

    echo
    echo "== netCDF =="
    command -v ncdump
    nc-config --version
    echo "netCDF-4 support: $(nc-config --has-nc4)"
    echo "parallel netCDF-4 support: $(nc-config --has-parallel4)"
    nf-config --version

    echo
    echo "== HDF5 =="
    /opt/hdf5/bin/h5pcc -showconfig | grep -E "HDF5 Version|Parallel HDF5"
'

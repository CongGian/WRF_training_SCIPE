#!/usr/bin/env bash
set -euo pipefail

SCRATCH="${SCRATCH:-/anvil/scratch/${USER}}"
WORKSHOP="${WORKSHOP:-${SCRATCH}/WRF_training_SCIPE}"
IMAGE="${IMAGE:-${WORKSHOP}/wrf.sif}"
WORKDIR="${WORKDIR:-${WORKSHOP}/container_hands_on}"

# Anvil may set LD_PRELOAD for site instrumentation such as XALT.
# Clear it so host preload libraries do not leak into Apptainer commands.
unset LD_PRELOAD

mkdir -p "${WORKDIR}"

echo "== Login node =="
hostname
uname -sr
whoami
pwd
command -v gcc
command -v mpicc

echo
echo "== Inside Apptainer =="
apptainer exec --bind "${WORKDIR}:/work" "${IMAGE}" /bin/bash -lc '
    set -e
    source /opt/scripts/paths.sh
    hostname
    uname -sr
    whoami
    pwd
    command -v gcc
    command -v mpicc
    command -v ncdump
    nc-config --version
    /opt/hdf5/bin/h5pcc -showconfig | grep -E "HDF5 Version|Parallel HDF5"
    echo "hello from inside Apptainer" > /work/login_vs_container_check.txt
'

echo
echo "== File written back to scratch =="
cat "${WORKDIR}/login_vs_container_check.txt"

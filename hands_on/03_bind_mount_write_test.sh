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

apptainer exec --bind "${WORKDIR}:/work" "${IMAGE}" /bin/bash -lc '
    set -e
    source /opt/scripts/paths.sh
    {
        echo "created_inside_container=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
        echo "container_hostname=$(hostname)"
        echo "container_user=$(whoami)"
        echo "WRF_DIR=${WRF_DIR:-unset}"
        echo "WPS_DIR=${WPS_DIR:-unset}"
        echo "ncdump=$(command -v ncdump)"
    } > /work/container_write_check.txt
'

cat "${WORKDIR}/container_write_check.txt"

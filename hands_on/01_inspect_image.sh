#!/usr/bin/env bash
set -euo pipefail

SCRATCH="${SCRATCH:-/anvil/scratch/${USER}}"
WORKSHOP="${WORKSHOP:-${SCRATCH}/WRF_training_SCIPE}"
IMAGE="${IMAGE:-${WORKSHOP}/wrf.sif}"

# Anvil may set LD_PRELOAD for site instrumentation such as XALT.
# Clear it so host preload libraries do not leak into Apptainer commands.
unset LD_PRELOAD

apptainer inspect "${IMAGE}"

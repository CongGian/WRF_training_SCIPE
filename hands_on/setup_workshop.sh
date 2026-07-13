#!/usr/bin/env bash
set -euo pipefail

SCRATCH="${SCRATCH:-/anvil/scratch/${USER}}"
WORKSHOP="${WORKSHOP:-${SCRATCH}/WRF_training_SCIPE}"
PROJECT_IMAGE="${PROJECT_IMAGE:-/anvil/projects/x-cis240917/WRF_training_SCIPE/wrf.sif}"
IMAGE="${IMAGE:-${WORKSHOP}/wrf.sif}"
WORKDIR="${WORKDIR:-${WORKSHOP}/container_hands_on}"

mkdir -p "${WORKDIR}"
cp -n "${PROJECT_IMAGE}" "${IMAGE}"

cat <<EOF
WORKSHOP=${WORKSHOP}
IMAGE=${IMAGE}
WORKDIR=${WORKDIR}

Run:
bash hands_on/00_login_vs_container_walkthrough.sh
bash hands_on/01_inspect_image.sh
bash hands_on/02_verify_stack.sh
bash hands_on/03_bind_mount_write_test.sh
EOF

# WRF Container Hands-On

This short exercise is designed for the containerization block of the NAIRR
WRF/Pangu workshop. Participants work from their Anvil scratch space so the
repository, hands-on scripts, container definition files, and staged image all
live under one workshop directory.

The short exercise intentionally does not build `wrf.sif`, compile WRF/WPS, or
run a full WRF science case. Those steps are too slow for the short hands-on
block and require staged meteorological inputs. The cloned repository is still
needed because it contains the Apptainer definition files and build notes used
for the container-building discussion.

The goal is to teach the stable container workflow and the boundary between
commands on the Anvil login node and commands running inside Apptainer:

1. Compare host/login-node commands with commands run inside the image.
2. Inspect the prepared image.
3. Verify MPI, netCDF, and HDF5 inside the image.
4. Prove that a bind-mounted scratch directory is writable from inside the
   container.

## Scratch Setup

Start in scratch, clone the repository, set the workshop path, and copy the
prepared image into that workshop directory:

```bash
cd /anvil/scratch/$USER
git clone https://github.com/CongGian/WRF_training_SCIPE.git
cd WRF_training_SCIPE

export WORKSHOP=/anvil/scratch/$USER/WRF_training_SCIPE
cp /anvil/projects/x-cis240917/WRF_training_SCIPE/wrf.sif "$WORKSHOP/"
```

The helper script performs the copy and prints the same environment defaults:

```bash
bash hands_on/setup_workshop.sh
```

Default image path after setup:

```bash
$WORKSHOP/wrf.sif
```

Recommended participant sequence:

```bash
export WORKSHOP=/anvil/scratch/$USER/WRF_training_SCIPE
export IMAGE=$WORKSHOP/wrf.sif
export WORKDIR=$WORKSHOP/container_hands_on

bash hands_on/00_login_vs_container_walkthrough.sh
bash hands_on/01_inspect_image.sh
bash hands_on/02_verify_stack.sh
bash hands_on/03_bind_mount_write_test.sh
```

For a slower instructor-guided version, run
`hands_on/00_login_vs_container_walkthrough.sh` first and pause after each
visible command to explain which part is running on the login node and which
part is running inside Apptainer.

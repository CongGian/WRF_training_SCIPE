# WRF Container Hands-On

Run these commands on Anvil. This exercise uses your scratch space and a
prepared Apptainer image. It does not build the image, submit Slurm jobs, or
run a full WRF forecast.

## 1. Set Up Your Workshop Directory

```bash
cd /anvil/scratch/$USER
git clone https://github.com/CongGian/WRF_training_SCIPE.git
cd WRF_training_SCIPE

export WORKSHOP=/anvil/scratch/$USER/WRF_training_SCIPE
bash hands_on/setup_workshop.sh
```

The setup script copies the prepared image into your scratch directory:

```text
$WORKSHOP/wrf.sif
```

It also creates the working directory used by the bind-mount test:

```text
$WORKSHOP/container_hands_on
```

## 2. Run The Hands-On Scripts

```bash
export WORKSHOP=/anvil/scratch/$USER/WRF_training_SCIPE
export IMAGE=$WORKSHOP/wrf.sif
export WORKDIR=$WORKSHOP/container_hands_on

bash hands_on/00_login_vs_container_walkthrough.sh
bash hands_on/01_inspect_image.sh
bash hands_on/02_verify_stack.sh
bash hands_on/03_bind_mount_write_test.sh
```

## 3. What Each Script Shows

```text
00_login_vs_container_walkthrough.sh
```

Compares simple commands on the login node with commands inside Apptainer. The
hostname and Linux kernel stay the same, but the compiler, MPI, netCDF, and
HDF5 tools come from the container.

```text
01_inspect_image.sh
```

Prints metadata from `wrf.sif`.

```text
02_verify_stack.sh
```

Checks the container MPI wrappers, netCDF, netCDF-Fortran, and parallel HDF5.

```text
03_bind_mount_write_test.sh
```

Mounts your scratch work directory inside the container as `/work`, writes a
small file from inside Apptainer, and prints that file from the login node.

The output file is:

```text
$WORKDIR/container_write_check.txt
```

## 4. Stop Here

The Slurm and full WRF model-run steps are handled separately by the training
team.

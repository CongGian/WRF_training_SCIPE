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
```

Before the stack check and bind-mount check, look at the container path setup
script. `/opt/scripts/paths.sh` lives inside the container and sets the
compiler, MPI, HDF5, and netCDF paths used by the later commands:

```bash
apptainer exec "$IMAGE" cat /opt/scripts/paths.sh
```

Then continue:

```bash
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

## 4. Optional: Navigate Inside The Container

This short interactive step shows that normal shell commands still work inside
Apptainer, while `/work` points to your Anvil scratch directory.

Start an interactive shell with the scratch work directory mounted as `/work`:

```bash
apptainer shell --bind $WORKDIR:/work $IMAGE
```

Inside the container:

```bash
pwd
ls
cd /work
pwd
mkdir -p demo_dir
cp /etc/os-release demo_dir/container_os_release.txt
ls -lh demo_dir
cat demo_dir/container_os_release.txt
exit
```

Back on the login node:

```bash
ls -lh $WORKDIR/demo_dir
cat $WORKDIR/demo_dir/container_os_release.txt
```

The file persists because it was written under `/work`, which is the bind mount
to your scratch directory, not a permanent change to the container image.

## 5. Stop Here

The Slurm and full WRF model-run steps are handled separately by the training
team.

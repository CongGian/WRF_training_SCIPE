# Container Hands-On Workflow

This is the proposed participant workflow for the containerization block of the
July 15, 2026 WRF/Pangu training.

## Slide Sequence

Use the last hands-on slides of
`Containerization_Presentation_CG_NAIRR_template_v2.pptx` for the hands-on
transition:

1. `Hands-on workflow: 8-10 minutes`
   - Work from `/anvil/scratch/$USER`.
   - Clone `WRF_training_SCIPE` so the scripts and container definition files
     are available for the hands-on and build discussion.
   - Copy the prepared `wrf.sif` from project storage into `$WORKSHOP`.
   - Set `IMAGE` to `$WORKSHOP/wrf.sif`.
   - Compare login-node commands with commands inside Apptainer.
   - Inspect metadata.
   - Verify the internal MPI, netCDF, and HDF5 stack.
   - Prove a bind mount by writing to scratch from inside the image.
2. `Hands-on: inspect, verify, and bind`
   - Run `hands_on/00_login_vs_container_walkthrough.sh` if you want the
     guided host-versus-container comparison first.
   - Run `hands_on/01_inspect_image.sh`.
   - Run `hands_on/02_verify_stack.sh`.
   - Point out MPI wrappers, netCDF, and HDF5 checks.
   - Run `hands_on/03_bind_mount_write_test.sh`.
   - Show the host-side `container_write_check.txt` file.

## Participant Commands

Start from Anvil scratch:

```bash
cd /anvil/scratch/$USER
git clone https://github.com/CongGian/WRF_training_SCIPE.git
cd WRF_training_SCIPE

export WORKSHOP=/anvil/scratch/$USER/WRF_training_SCIPE
cp /anvil/projects/x-cis240917/WRF_training_SCIPE/wrf.sif "$WORKSHOP/"

export IMAGE=$WORKSHOP/wrf.sif
export WORKDIR=$WORKSHOP/container_hands_on

bash hands_on/00_login_vs_container_walkthrough.sh
bash hands_on/01_inspect_image.sh
bash hands_on/02_verify_stack.sh
bash hands_on/03_bind_mount_write_test.sh
```

Equivalently, after cloning the repo and entering it:

```bash
bash hands_on/setup_workshop.sh
```

The setup helper verifies `$WORKSHOP`, creates the hands-on work directory,
copies the staged project image if needed, and prints the exports used by the
exercise scripts.

The `00_login_vs_container_walkthrough.sh` script separates login-node output
from Apptainer output, compares hostname/kernel/user/path/tool visibility,
writes a small file through the `/work` bind mount, and shows that file from
the host side.

The scripts default to:

```text
/anvil/scratch/$USER/WRF_training_SCIPE/wrf.sif
```

If the image is staged elsewhere, change only the `IMAGE` line:

```bash
export IMAGE=/path/to/wrf.sif
```

The bind-mount script writes to:

```text
$WORKSHOP/container_hands_on/container_write_check.txt
```

The guided host-versus-container script writes to:

```text
$WORKSHOP/container_hands_on/login_vs_container_check.txt
```

Override with:

```bash
export WORKDIR=/anvil/scratch/$USER/my_container_test
```

## Avoid During The Short Hands-On

- Building `wrf.sif`.
- Compiling WRF or WPS.
- Running `real.exe` or `wrf.exe` for the full case.
- Submitting Slurm jobs; that part will be handled separately.
- Debugging missing meteorological input files.

Those are instructor-preparation or later-workflow topics, not the short
containerization exercise.

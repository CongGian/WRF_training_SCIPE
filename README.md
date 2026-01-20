# WRF_training_SCIPE

This repository provides a **single Apptainer definition file**:

- `wrf.def`

You use it to build a WRF/WPS toolchain container image (**`wrf.sif`**) on **Jetstream2 (JS2)**.

We intentionally **do not** store the `.sif` image in this repo because it is large and not suitable for standard Git workflows.

---

## What the built image contains

When you build `wrf.sif` from `wrf.def`, the image includes a toolchain suitable for compiling and running WRF/WPS:

- Ubuntu 22.04 base
- GNU compilers (`gcc`, `g++`, `gfortran`)
- MPI: MPICH
- HDF5 (parallel + Fortran)
- netCDF-C and netCDF-Fortran
- Helper environment script inside the image: `/opt/scripts/paths.sh`

This supports:
- **MPI-only WRF** builds (`dmpar`)
- **OpenMP-only WRF** builds (`smpar`)
- **Hybrid MPI+OpenMP WRF** builds (`dm+sm`)
- **WPS** build (geogrid / ungrib / metgrid)

---

## Jetstream2 workflow overview

1. Create a JS2 VM
2. Install Apptainer on the VM host
3. Clone this repo
4. Build `wrf.sif` from `wrf.def`
5. Enter the container with bind mounts
6. Compile WRF and WPS inside the container
7. Run WPS → `real.exe` → `wrf.exe` (MPI / OpenMP / hybrid)

---

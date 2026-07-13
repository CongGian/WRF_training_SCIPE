# Session Log

This file is the durable handoff record for work done from this repository.
The chat itself may remain available in the UI, but the reliable record for a
new Anvil terminal/session is whatever has been written into repo files.

## Save Cadence

Update this file at practical checkpoints, not after every message:

- At the start of a resumed session, add a short "Resumed" note if the next
  action is not obvious from the latest entry.
- After any successful or failed container build, WRF compile, WPS compile, or
  Slurm/runtime test.
- After changing strategy, pinned versions, paths, or assumptions.
- Before ending a work session, especially before leaving long-running Anvil
  work or after creating/removing important artifacts.
- During long work, checkpoint roughly every 30-60 minutes or after each major
  milestone, whichever comes first.

For routine chat, small inspections, and one-command checks, summarize them in
the next checkpoint entry rather than logging every turn.

## Current Context

- Repository path: `/home/x-cgian/projects/WRF_training_SCIPE`
- Main technical note: `docs/wrf_container_compile_writeup.md`
- Current original image recipe: `wrf.def`
- Faster alternate image recipe: `wrf.fast.def`
- Rebuild helper: `docs/rebuild_wrf_container.sh`
- Copied old image present locally: `wrf.old.sif`
- A local `wrf.sif` exists from the source-build recipe. The faster alternate
  recipe was validated as `/tmp/wrf-fast-test.sif`, not as the repo-root
  `wrf.sif`.
- Generated images and local WRF/WPS source/build trees are ignored by Git:
  `*.sif`, `*.simg`, and `wrf_stuff/`.

## 2026-07-04 13:46 EDT

Created this handoff system:

- Added root `AGENTS.md` telling future sessions to read this log, the WRF
  container writeup, and the README before making changes.
- Added this `docs/session_log.md` as the periodic durable summary.

Recent container/WRF summary:

- `wrf.def` defines the intended reproducible Apptainer image from Ubuntu
  22.04 with GNU compilers, MPICH 4.2.3, parallel HDF5 1.14.3, netCDF-C 4.9.2,
  netCDF-Fortran 4.6.1, `/opt/scripts/paths.sh`, and a `%test` smoke check.
- `docs/rebuild_wrf_container.sh` builds `wrf.sif` from `wrf.def` and runs a
  smoke test.
- `wrf.old.sif` is a copied external image, not the newly built repo artifact.
  It was inspected and smoke-checked with `apptainer exec`; it contains MPICH
  4.2.3, netCDF-C 4.9.2, netCDF-Fortran 4.6.1, and parallel HDF5 1.14.6.
- The WRF/WPS trees under `wrf_stuff/` were compiled with Anvil host modules,
  not inside the container image. There is an older WRF `v4.8.0` + WPS `v4.6.0`
  build and a matching `wrf_stuff/v4.6.0/` WRF `v4.6.0` + WPS `v4.6.0` build.
- The local WRF/WPS builds produced the expected executables, but full model
  runs still need staged runtime inputs such as GRIB/`FILE:*`, `met_em*.nc`,
  `wrfinput*`, and `wrfbdy*`.

Open items:

- Build or obtain the final `wrf.sif` from the current `wrf.def`.
- Compile the final instructor WRF/WPS tree inside that image so binaries match
  the teaching workflow.
- Resolve path mismatches between `wrf_files/wrf_steps.sh`,
  `wrf_files/run_wps.sh`, and `wrf_files/run_wrf.sh`.
- Stage the training inputs/outputs needed for the workshop workflow.

## 2026-07-04 14:30 EDT

Rebuilt the WRF/WPS toolchain container from the current `wrf.def`:

```bash
/usr/bin/time -p docs/rebuild_wrf_container.sh wrf.sif
```

Result:

- Build succeeded and wrote `wrf.sif`.
- Image size: 528 MiB.
- Measured wall time: `real 1976.70` seconds, about 32 minutes 57 seconds.
- CPU time reported by `/usr/bin/time`: `user 3048.87`, `sys 621.51`.
- Apptainer used fakeroot/root-mapped namespace and warned that `/tmp` has the
  `nodev` mount option. This did not stop the build.
- The build ran on Anvil login host `login03.anvil.rcac.purdue.edu` using
  Apptainer `1.4.3-1.el8`, per `apptainer inspect wrf.sif`.
- The image labels show build date `Saturday_4_July_2026_14:28:17_EDT`.
- Post-build smoke test passed:
  - `mpicc` and `mpif90` from `/opt/mpich/bin`
  - MPICH 4.2.3
  - netCDF-C 4.9.2
  - netCDF-Fortran 4.6.1
  - HDF5 1.14.3 with `Parallel HDF5: yes`

Observed build stages:

- Fast initial Ubuntu/apt download and package install.
- Long MPICH configure/build/install stage.
- HDF5 configure/build/install with parallel and Fortran support.
- netCDF-C configure/build/install with netCDF-4 and parallel support.
- netCDF-Fortran configure/build/install.
- Final SIF packaging, then smoke test.

Workshop implication:

- A single current-recipe build took about 33 minutes under favorable conditions
  with parallel build jobs.
- This should be demonstrated by the instructor, not run simultaneously by 100
  participants. Concurrent builds would heavily stress login-node CPU, network,
  `/tmp`, cache, and quota resources and would likely be slower or fail for some
  users.
- For the workshop, stage a prebuilt `wrf.sif` and have participants inspect,
  enter, smoke-test, compile/run WRF pieces, or use precompiled WRF/WPS
  artifacts depending on time.

## 2026-07-06 12:18 EDT

Resumed cleanup and recipe optimization work.

Working-tree cleanup:

- Updated `.gitignore` so generated Apptainer images and local WRF/WPS build
  trees no longer pollute Git status: `*.sif`, `*.simg`, and `wrf_stuff/`.
- Preserved existing local artifacts on disk. The ignored `wrf.sif`,
  `wrf.old.sif`, and `wrf_stuff/` directories were not deleted.

Container recipe change:

- Initially tested the fast approach in `wrf.def`, then restored `wrf.def` to
  the original tracked source-build recipe at the user's request.
- Saved the fast approach as `wrf.fast.def`.
- The fast approach installs Ubuntu Jammy `mpich`, `libmpich-dev`, and
  `libhdf5-mpich-dev`, exposes HDF5 through a WRF-friendly `/opt/hdf5` prefix,
  then source-builds pinned netCDF-C `4.9.2` and netCDF-Fortran `4.6.1` into
  `/opt/netcdf`.
- This keeps the core WRF/WPS container functions: GNU compilers, MPICH,
  parallel HDF5, netCDF-4 with parallel support, netCDF-Fortran, and
  `/opt/scripts/paths.sh`.
- Tradeoff: the image now uses Ubuntu package versions for MPICH/HDF5. The
  successful test image reported MPICH `4.0` and HDF5 `1.10.7`, not the older
  source-built MPICH `4.2.3` and HDF5 `1.14.3`.

Validation:

- Built a throwaway test image from the fast recipe, now saved as
  `wrf.fast.def`: `/tmp/wrf-fast-test.sif`.
- The test image size was `228M`, compared with the earlier local `wrf.sif` at
  about `527M`.
- The build completed successfully and the Apptainer `%test` smoke check passed.
- A clean external smoke check also passed with `LD_PRELOAD` unset:
  - `mpicc` and `mpif90` from `/usr/bin`
  - `h5pcc` from `/opt/hdf5/bin`
  - `ncdump`, `nc-config`, and `nf-config` from `/opt/netcdf/bin`
  - MPICH `4.0`
  - netCDF-C `4.9.2`
  - `nc-config --has-nc4=yes`
  - `nc-config --has-parallel4=yes`
  - netCDF-Fortran `4.6.1`
  - HDF5 `1.10.7` with `Parallel HDF5: yes`

Compile workflow update:

- Updated `wrf_files/wrf_steps.sh` to use pinned shallow clones for WRF/WPS
  `v4.6.0`, initialize WRF submodules, use `WRF_BUILD_JOBS` with
  `./compile -j`, and fix the previous `cd WPS` path error.
- Added an `LD_PRELOAD` unset in `docs/rebuild_wrf_container.sh` to avoid noisy
  Anvil XALT preload warnings during container smoke checks.
- Updated `docs/rebuild_wrf_container.sh` so the first argument is the output
  image and the optional second argument is the definition file. Example:
  `docs/rebuild_wrf_container.sh wrf.fast.sif wrf.fast.def`.

Next items:

- Rebuild the final repo/scratch `wrf.sif` from the revised recipe when ready.
- Compile the final instructor WRF/WPS tree inside that rebuilt image.
- Align `wrf_files/run_wps.sh` and `wrf_files/run_wrf.sh` with the chosen final
  WRF/WPS install paths. `wrf_steps.sh` now builds under `wrf_stuff/`, while the
  Slurm scripts still refer to root-level `WRF/` and `WPS/`.
- Then run the existing missing-input checks or full workflow once GRIB,
  `FILE:*`, `met_em*`, `wrfinput*`, and `wrfbdy*` staging is resolved.

## 2026-07-06 13:35 EDT

Recorded container recipe decision for the WRF hands-on training:

- Use the original `wrf.def` recipe for the hands-on WRF model run path. It
  source-builds MPICH `4.2.3` and HDF5 `1.14.3`, so it is slower to rebuild but
  keeps the more controlled self-contained stack already used for the earlier
  `wrf.sif` build.
- Keep `wrf.fast.def` as an alternate teaching example for the containerization
  slide deck. It demonstrates how rebuild time and image size can be reduced by
  using Ubuntu MPICH/HDF5 binary packages while preserving core WRF/WPS
  functionality through pinned netCDF-C/Fortran builds.
- Slide-deck note for later: explain the tradeoff explicitly. The package-based
  recipe is faster and smaller, but it uses Ubuntu MPICH `4.0` and HDF5
  `1.10.7` rather than source-built MPICH `4.2.3` and HDF5 `1.14.3`; on Anvil,
  neither generic in-container MPI is automatically as fabric-tuned as the
  site-supported MPI stack, so final hands-on runs should be tested with the
  selected image before training.

## 2026-07-07 11:30 EDT

Compiled WRF/WPS inside the original `wrf.sif` and packaged a new runtime image.

Source/build setup:

- Used the existing `wrf.sif` built from the original `wrf.def`.
- Created a clean temporary build tree at `/tmp/wrf-container-build-clean`.
- Locally cloned WRF `v4.6.0` and WPS `v4.6.0` from the existing
  `wrf_stuff/v4.6.0/` repositories rather than modifying the previous
  host-module build trees.
- Initialized WRF `phys/noahmp` from the existing local submodule clone, with no
  GitHub network dependency.

WRF build:

- Configured WRF inside `wrf.sif` with:
  - option `35`: GNU `dm+sm`
  - nesting option `1`: basic nesting
- Confirmed configure resolved `NETCDFPATH=/opt/netcdf` and
  `HDF5PATH=/opt/hdf5` inside the container.
- Compiled with `./compile -j 4 em_real`.
- Build completed successfully in about 13 minutes wall time.
- Produced:
  - `/tmp/wrf-container-build-clean/WRF/main/wrf.exe`
  - `/tmp/wrf-container-build-clean/WRF/main/real.exe`
  - `/tmp/wrf-container-build-clean/WRF/main/ndown.exe`
  - `/tmp/wrf-container-build-clean/WRF/main/tc.exe`
- Verified `ldd` inside `wrf.sif` links WRF to container libraries:
  `/opt/mpich/lib`, `/opt/netcdf/lib`, and `/opt/hdf5/lib`.

WPS build:

- Configured WPS inside `wrf.sif` with `./configure --build-grib2-libs`.
- Selected option `2`: GNU `dmpar`.
- Applied the known OpenMP link fix in `configure.wps`:
  `-lnetcdff -lnetcdf -lgomp -lpthread`.
- Compiled successfully in about 69 seconds.
- Produced `geogrid.exe`, `ungrib.exe`, and `metgrid.exe`.
- Verified `geogrid.exe` and `metgrid.exe` link to container
  `/opt/mpich`, `/opt/netcdf`, and `/opt/hdf5` libraries. `ungrib.exe` does not
  require those netCDF/HDF5 libraries.

Packaged image:

- Created a runtime staging tree under `/tmp/wrf-container-runtime-20260707c`
  with WRF `main/` executables, dereferenced WRF `run/` files, and WPS runtime
  tree.
- Built a new image:
  `wrf-compiled.sif`.
- `wrf-compiled.sif` is based on `wrf.sif` and adds:
  - WRF under `/opt/wrf/WRF`
  - WPS under `/opt/wrf/WPS`
  - environment variables `WRF_DIR=/opt/wrf/WRF` and `WPS_DIR=/opt/wrf/WPS`
- Image size: `682M`.
- `apptainer inspect wrf-compiled.sif` reports build date
  `Tuesday_7_July_2026_11:22:37_EDT` and labels WRF/WPS as v4.6.0 built inside
  `wrf.sif`.
- Smoke check passed inside `wrf-compiled.sif`; WRF/WPS executables exist and
  WRF links to `/opt/mpich`, `/opt/netcdf`, and `/opt/hdf5`.

Important caveats:

- `wrf-compiled.sif` contains compiled binaries and runtime/support files, not
  the full WRF source/build tree.
- Scientific runtime is not yet tested because case inputs are still needed:
  GRIB/`FILE:*`, `met_em*.nc`, `wrfinput*`, and `wrfbdy*`.
- The original `wrf.sif` remains available as the pure toolchain image.

## 2026-07-07 12:05 EDT

Added a detailed slide-deck-ready compilation process note:

- New file: `docs/wrf_wps_container_compilation_process.md`
- Contents: exact command sequence for cloning clean local WRF/WPS sources,
  initializing the WRF submodule locally, configuring and compiling WRF inside
  `wrf.sif`, configuring and compiling WPS, applying the WPS OpenMP link fix,
  verifying library linkage, staging dereferenced runtime files, building
  `wrf-compiled.sif`, and validating the final compiled runtime image.
- The note also records teaching points for the containerization slides,
  including immutable SIF behavior, bind mounts, `LD_PRELOAD` cleanup on Anvil,
  local clone tradeoffs, symlink handling for `%files`, and why the hands-on
  workflow stayed with `wrf.def` while keeping `wrf.fast.def` as a rebuild-time
  tradeoff example.

## 2026-07-07 12:20 EDT

Added a detailed slide-deck-ready containerization process note:

- New file: `docs/wrf_containerization_process.md`
- Contents: how `wrf.def` is structured, what each Apptainer definition section
  does, why Ubuntu 22.04 is used as the base, what the `%environment` variables
  mean, how the `%post` section installs build tools and source-builds MPICH,
  HDF5, netCDF-C, and netCDF-Fortran, how `/opt/scripts/paths.sh` supports
  repeatable WRF/WPS builds, and how to build and smoke-test `wrf.sif`.
- The note also records the July 4, 2026 build result for the original
  source-build recipe, the July 6, 2026 fast-recipe result, and the slide-deck
  tradeoff between controlled source-built MPICH/HDF5 and faster Ubuntu package
  MPICH/HDF5.

## 2026-07-07 16:33 EDT

Copied the compiled WRF/WPS container image to the shared Anvil project path:

- Source: `/home/x-cgian/projects/WRF_training_SCIPE/wrf-compiled.sif`
- Destination: `/anvil/projects/x-cis240917/WRF_training_SCIPE/wrf-compiled.sif`
- Existing destination `wrf.sif` was left untouched.
- Copied image size: `682M`
- SHA-256 checksum verified at both locations:
  `25af818d4a5486ccaa15965f029d71104fffe110d7b4c3cb329de7108528fbef`

## 2026-07-08 12:07 EDT

Added a high-level revision plan for the containerization slide deck:

- New file: `docs/containerization_deck_revision_plan.md`
- New revised deck copy: `Containerization_Presentation_CG_revised.pptx`.
  The original `Containerization_Presentation_CG.pptx` was left unchanged.
- Source materials reviewed: `Containerization_Presentation_CG.pptx`,
  `Template from NAIRR.pptx`, `HPC_Training_Announcement.docx`,
  `index.html`, and the existing WRF containerization/compile notes.
- Recommended structure: about 28-30 minutes of lecture plus an 8-10 minute
  guided hands-on exercise within the containerization block.
- Main talk emphasis: why containerization matters on HPC, Apptainer definition
  file anatomy, build strategy on Jetstream2 versus Anvil, compiling WRF/WPS
  inside `wrf.sif`, packaging `wrf-compiled.sif`, and running through Slurm and
  Apptainer without hiding host responsibilities.
- Hands-on recommendation: inspect the prepared `wrf-compiled.sif`, verify the
  internal MPI/netCDF/HDF5/WRF/WPS tools, and demonstrate a bind mount writing
  back to host scratch. Avoid live image builds or WRF/WPS compiles during the
  participant exercise.
- Added verbatim slide-by-slide speaker script:
  `Containerization_Presentation_CG_revised_verbatim.md`.

Correction after visual/layout concern:

- The earlier `Containerization_Presentation_CG_revised.pptx` was a text-only
  XML revision of the original deck and should not be used as the primary deck
  if its layout is crowded or visually broken.
- Created `Containerization_Presentation_CG_NAIRR.pptx` directly from
  `Template from NAIRR.pptx`, preserving the NAIRR template masters,
  backgrounds, fonts, and media, then replacing the visible slide text with a
  lighter 16-slide containerization sequence.
- Created matching verbatim speaker script:
  `Containerization_Presentation_CG_NAIRR_verbatim.md`.
- Validation performed: `unzip -t Containerization_Presentation_CG_NAIRR.pptx`
  passed, and slide text extraction confirmed 16 revised slides. No
  LibreOffice/Impress renderer or module was available on Anvil, so final
  visual inspection still needs to happen in PowerPoint or another local PPTX
  renderer.

## 2026-07-08 16:42 EDT

Added a self-contained slide rendering handoff so the whole folder can be
copied to a machine with PowerPoint, LibreOffice, or another PPTX renderer:

- New root file: `SLIDE_RENDER_HANDOFF.md`
- New docs pointer: `docs/slide_render_handoff.md`
- Primary deck/script pair for rendering and review:
  - `Containerization_Presentation_CG_NAIRR.pptx`
  - `Containerization_Presentation_CG_NAIRR_verbatim.md`
- The handoff explicitly says not to use
  `Containerization_Presentation_CG_revised.pptx` as the primary visual deck,
  because it was a text-only XML revision and may have broken layout.
- The handoff includes the talk context, current conversation summary,
  supporting technical docs, render commands for PowerPoint/LibreOffice, and a
  visual QA checklist.

## 2026-07-08 22:39 EDT

Created a readable fallback version of the containerization slide deck after
visual review showed the NAIRR-template slide text and pictures were crowded or
misaligned:

- New readable deck: `Containerization_Presentation_CG_NAIRR_readable.pptx`
- New proof PDF: `Containerization_Presentation_CG_NAIRR_readable.pdf`
- New generator: `tools/make_readable_deck.py`
- New rendered proof previews:
  `rendered/readable_slide-01.png` through `rendered/readable_slide-16.png`

Implementation notes:

- The readable deck keeps the 16-slide talk sequence but rebuilds each slide as
  a sparse text-first layout with fixed-position title/body/footer text boxes.
- All slide-level pictures, logos, media files, image relationships, and
  hyperlink relationships were removed from the readable PPTX, including the
  Colorado/CU visual material and the previous `knuths@colorado.edu` hyperlink.
- The original `Containerization_Presentation_CG_NAIRR.pptx` remains in the
  repo as history, but the primary review target is now the readable
  `*_readable.pptx` plus its `*_readable.pdf` proof.

Validation:

- `python3 tools/make_readable_deck.py` succeeded with the system Python 3.6.8.
- `unzip -t Containerization_Presentation_CG_NAIRR_readable.pptx` reported no
  archive errors.
- XML inspection found zero `ppt/media/*` files, zero slide `p:pic` objects,
  and no `colorado`, `knuth`, or `boulder` references in the readable PPTX.
- `pdfinfo Containerization_Presentation_CG_NAIRR_readable.pdf` confirmed 16
  pages at 720 by 405 points.
- `pdftoppm` rendered the PDF to PNG previews, and manual checks of the title
  slide plus dense slides 5, 7, 12, 13, and 16 showed readable text with no
  overlap.

## 2026-07-09 12:15 EDT

Regenerated the containerization slide deck to satisfy the NAIRR-template
requirement and added a concrete hands-on workflow:

- New primary deck: `Containerization_Presentation_CG_NAIRR_template_v2.pptx`
- New generated proof PDF:
  `Containerization_Presentation_CG_NAIRR_template_v2.pdf`
- New matching script:
  `Containerization_Presentation_CG_NAIRR_template_v2_verbatim.md`
- New generator: `tools/make_nairr_template_deck.py`
- New hands-on workflow note: `docs/container_hands_on_workflow.md`
- New participant scripts:
  - `hands_on/01_inspect_image.sh`
  - `hands_on/02_verify_stack.sh`
  - `hands_on/03_bind_mount_write_test.sh`
  - `hands_on/04_slurm_container_check.sbatch`

Deck changes:

- Generated from `Template from NAIRR.pptx`, not from the text-only readable
  fallback.
- Keeps NAIRR visual framing and uses only the NAIRR Pilot and NSF/ACCESS
  support image assets from the template.
- Drops the Colorado/CU logo assets, visible text, and slide relationships from
  the generated deck.
- Expands the talk to 20 slides:
  - slides 2-6 restore more of the March-deck containerization fundamentals,
  - slides 7-16 connect those ideas to `wrf.def`, `wrf.sif`,
    `wrf-compiled.sif`, MPI/OpenMP, Slurm, and the AI sidecar,
  - slides 17-20 lay out the short hands-on exercise.

Hands-on workflow:

- Required participant flow:
  `01_inspect_image.sh`, `02_verify_stack.sh`,
  `03_bind_mount_write_test.sh`.
- Optional Slurm flow:
  `04_slurm_container_check.sbatch`.
- Scripts default to
  `/anvil/projects/x-cis240917/WRF_training_SCIPE/wrf-compiled.sif`, but allow
  `IMAGE=/path/to/wrf-compiled.sif` and `WORKDIR=/path/to/workdir` overrides.

Validation:

- `python3 tools/make_nairr_template_deck.py` succeeded.
- `unzip -t Containerization_Presentation_CG_NAIRR_template_v2.pptx` reported
  no archive errors.
- `pdfinfo Containerization_Presentation_CG_NAIRR_template_v2.pdf` confirmed
  20 pages at 720 by 405 points.
- `pdftoppm` rendered PNG proof previews under
  `rendered/template_v2_pdf_check/`, and manual inspection of slides 1, 3, 14,
  and 19 showed readable content with NAIRR visual framing.
- Slide text extraction confirmed 20 generated slides.
- Package media list contains only `image7.png`, `image11.png`, and
  `image24.png` from the NAIRR template.
- XML/package search found no `Colorado`, `Boulder`, `knuth`, `image1.png`, or
  `image2.jpg` references in the generated deck.
- Shell syntax checks passed for the hands-on scripts; Python bytecode compile
  passed for the generator.
- With Apptainer allowed outside the sandbox, the first three hands-on scripts
  passed against the local `wrf-compiled.sif`. The Slurm script was syntax
  checked but not submitted.

The older `Containerization_Presentation_CG_NAIRR_readable.*` files remain as
readability fallback/history, but the primary deck for review is now
`Containerization_Presentation_CG_NAIRR_template_v2.pptx`. A real
PowerPoint/LibreOffice render is still needed for final visual QA.

## 2026-07-09 14:50 EDT

Revised the NAIRR-template deck again based on user review and regenerated the
PPTX, proof PDF, and verbatim script:

- Updated generator: `tools/make_nairr_template_deck.py`
- Regenerated primary deck:
  `Containerization_Presentation_CG_NAIRR_template_v2.pptx`
- Regenerated generated proof PDF:
  `Containerization_Presentation_CG_NAIRR_template_v2.pdf`
- Regenerated speaker script:
  `Containerization_Presentation_CG_NAIRR_template_v2_verbatim.md`

Deck content changes:

- Set slide text typeface to `Lato` in the PPTX, with `Consolas` retained for
  code blocks. Anvil does not have Lato installed, so the generated PDF proof
  may use viewer/font substitution even though the PPTX requests Lato.
- Expanded slide 7 to explain WRF/WPS binaries and terminology:
  `real.exe`, `wrf.exe`, `ndown.exe`, `tc.exe`, `geogrid.exe`, `ungrib.exe`,
  `metgrid.exe`, `dm+sm`, basic nesting, and GRIB2 support.
- Expanded slide 8 with concrete example lines from Apptainer definition
  sections: `Bootstrap`, `From`, `%environment`, `%post`, and `%runscript`.
- Reworked slide 9 into a Jetstream2-vs-Anvil comparison including sudo or
  privileged-build expectations, where to control/install the user-space stack,
  why Anvil is still the run/test target, and when native modules/local staff
  support may be preferable.
- Removed the previous fast-recipe comparison slide.
- Merged the native-modules/local-staff point into slide 9.
- Added a compile-strategy slide comparing compiling WRF/WPS using the
  toolchain image with baking WRF/WPS compilation directly into the image.
- Rewrote the prepared-runtime slide as participant-facing instruction:
  what they will use, what is already inside the image, and what they will not
  do during the short hands-on block.
- Added an expected Slurm + Apptainer output slide with representative output
  lines for the tiny container smoke check.
- Expanded the AI sidecar section using substance from the older deck:
  AI as learned forecasts, residual correction, downscaling, post-processing,
  or surrogates; Python/ONNX/model-weight/GPU dependencies; Conda as the first
  Anvil path; and a separate AI container with `apptainer exec --nv` as a later
  reproducibility option.
- Kept the deck at 20 slides.

Hands-on script changes:

- Simplified `hands_on/01_inspect_image.sh`,
  `hands_on/02_verify_stack.sh`, and
  `hands_on/03_bind_mount_write_test.sh` to use direct `IMAGE` and `WORKDIR`
  variable defaults without path-discovery `if`/`else` logic.
- Simplified `hands_on/04_slurm_container_check.sbatch` similarly.
- Updated `hands_on/README.md` and `docs/container_hands_on_workflow.md` to
  show `export IMAGE=...` as the setup step and keep participant commands
  explicit.

Validation:

- `python3 tools/make_nairr_template_deck.py` succeeded.
- `python3 -m py_compile tools/make_nairr_template_deck.py` passed.
- `unzip -t Containerization_Presentation_CG_NAIRR_template_v2.pptx` reported
  no archive errors.
- `pdfinfo Containerization_Presentation_CG_NAIRR_template_v2.pdf` confirmed
  20 pages at 720 by 405 points.
- `pdftoppm` rendered updated PNG previews under
  `rendered/template_v2_pdf_check/`.
- Manual checks of proof slides 7, 8, 9, 11, 13, 14, 15, 16, 18, and 19 showed
  readable content after layout adjustments.
- PPTX slide XML requests fonts `Lato` and `Consolas`.
- Package media list still contains only the intended NAIRR template assets:
  `image7.png`, `image11.png`, and `image24.png`.
- XML/package search still found no `Colorado`, `Boulder`, `knuth`,
  `image1.png`, or `image2.jpg` references in the generated deck.
- Shell syntax checks passed for all hands-on scripts.
- With Apptainer allowed outside the sandbox, simplified scripts 1-3 passed
  against the local `wrf-compiled.sif`; the Slurm script was syntax checked but
  not submitted.

## 2026-07-09 15:16 EDT

Revised the NAIRR-template deck again based on the latest user review and
regenerated the PPTX, proof PDF, and verbatim script:

- Regenerated primary deck:
  `Containerization_Presentation_CG_NAIRR_template_v2.pptx`
- Regenerated generated proof PDF:
  `Containerization_Presentation_CG_NAIRR_template_v2.pdf`
- Regenerated speaker script:
  `Containerization_Presentation_CG_NAIRR_template_v2_verbatim.md`

Deck content changes:

- Fixed the later-slide banner behavior so content slides use the NAIRR Pilot
  logo plus NSF/ACCESS support logo instead of switching to the ACCESS-less
  full-width header strip.
- Updated slide 8 to include all `wrf.def` blocks present in the repo:
  `Bootstrap`/`From`, `%labels`, `%environment`, `%post`, and `%runscript`.
  The slide now phrases `%runscript` as an Apptainer section, with
  `echo "WRF/WPS toolchain image"` shown as the command inside it.
- Reworked slide 9 to clarify that the workshop-prep `wrf.sif` was built on
  Anvil and that WRF/WPS were compiled inside it to create
  `wrf-compiled.sif`, while still explaining why JS2 or an approved build VM is
  often cleaner for portable image construction.
- Added two more concrete Pangu/Conda slides using the local
  `pangu_example/README.md`, `requirements_cpu.txt`, `requirements_gpu.txt`,
  and `run_workflow.sh` material:
  - `Create the Pangu Conda environment`
  - `Run Pangu as the AI sidecar`
- Replaced the final takeaway slide with a small participant-facing Slurm job
  exercise after the bind-mount hands-on slide.

Hands-on changes:

- Updated `hands_on/04_slurm_container_check.sbatch` so the tiny Slurm job now
  prints `SLURM_JOB_ID`, node/task counts, host name, host kernel, container
  kernel, visible Slurm variables inside the container, and explicit WRF/WPS
  executable checks.
- Updated `hands_on/README.md` and `docs/container_hands_on_workflow.md` to
  describe the host-allocation and host-kernel demonstration.

Validation:

- `python3 tools/make_nairr_template_deck.py` succeeded.
- `python3 -m py_compile tools/make_nairr_template_deck.py` passed.
- `unzip -t Containerization_Presentation_CG_NAIRR_template_v2.pptx` reported
  no archive errors.
- `pdfinfo Containerization_Presentation_CG_NAIRR_template_v2.pdf` confirmed
  20 pages at 720 by 405 points.
- `pdftoppm` rendered updated PNG previews under
  `rendered/template_v2_pdf_check/`.
- Manual checks of rendered slides 8, 9, 15, 16, 17, 18, 19, and 20 showed
  readable content and the ACCESS logo present on the later slides.
- Slide relationship checks confirmed slides 17 and 20 use `image11.png` and
  `image24.png`, and no generated slide relationship points to `image7.png`.
- Package text scan found no stale `Colorado`, `Boulder`, `knuth`,
  `Run/test host`, `Hands-on: bind mount`, or `Takeaways` text.
- PPTX slide XML requests only `Lato` and `Consolas` typefaces.
- Shell syntax checks passed for all four hands-on scripts. The Slurm script
  was not submitted during this revision.

## 2026-07-09 15:38 EDT

Revised the NAIRR-template deck again based on follow-up feedback and
regenerated the PPTX, proof PDF, and verbatim script:

- Regenerated primary deck:
  `Containerization_Presentation_CG_NAIRR_template_v2.pptx`
- Regenerated generated proof PDF:
  `Containerization_Presentation_CG_NAIRR_template_v2.pdf`
- Regenerated speaker script:
  `Containerization_Presentation_CG_NAIRR_template_v2_verbatim.md`

Deck content changes:

- Reworked slide 6 into `Apptainer workflow objects and bind mounts` with a
  clearer explanation that a bind mount exposes an existing host path inside
  the container while the host still owns the real mounted filesystem,
  permissions, quotas, and persistence. This borrows the operational bind-mount
  point from the earlier containerization deck.
- Removed the Pangu-runtime slide content from slide 17 so this deck does not
  duplicate the next talk.
- Reframed slides 15-17 around a WRF-specific AI sidecar:
  - slide 15 explains that a sidecar can read WRF `wrfout` NetCDF files for
    bias correction, downscaling, learned diagnostics, uncertainty flags, or
    quick-look products;
  - slide 16 creates a small generic `wrf-ai` Conda environment for xarray,
    NetCDF, numpy/pandas, scikit-learn, and optional ONNX runtime;
  - slide 17 shows a small bridge example where WRF runs in
    `wrf-compiled.sif`, writes outputs through the bind mount, and a separate
    `ai_sidecar.py` reads the host `wrfout` file and writes a derived NetCDF
    product.

Validation:

- `python3 tools/make_nairr_template_deck.py` succeeded.
- `python3 -m py_compile tools/make_nairr_template_deck.py` passed.
- `unzip -t Containerization_Presentation_CG_NAIRR_template_v2.pptx` reported
  no archive errors.
- `pdfinfo Containerization_Presentation_CG_NAIRR_template_v2.pdf` confirmed
  20 pages at 720 by 405 points.
- `pdftoppm` rendered updated PNG previews under
  `rendered/template_v2_pdf_check/`.
- Manual checks of rendered slides 6 and 17 confirmed no overlap and readable
  code blocks.
- Package text scan found no stale `Run Pangu`, `Create the Pangu`,
  `pangu_ai`, `inference.py`, `smoke check`, or `Hands-on: bind mount` text.
- PPTX slide XML still requests only `Lato` and `Consolas` typefaces.
- Shell syntax check passed for the Slurm hands-on script. The Slurm script was
  not submitted during this revision.

## 2026-07-10 11:36 EDT

Revised the NAIRR-template deck and verbatim speaker script based on user
feedback:

- Regenerated primary deck:
  `Containerization_Presentation_CG_NAIRR_template_v2.pptx`
- Regenerated generated proof PDF:
  `Containerization_Presentation_CG_NAIRR_template_v2.pdf`
- Regenerated speaker script:
  `Containerization_Presentation_CG_NAIRR_template_v2_verbatim.md`
- Updated generator:
  `tools/make_nairr_template_deck.py`

Deck/content changes:

- Added a new early introduction slide, `Porting vs containerizing`, to explain
  that direct native porting is possible when the team understands both the
  application and the target cluster, but it takes time, local system knowledge,
  and repeated testing. The slide frames containers as a way to preserve the
  validated user-space stack while still requiring Anvil-side validation.
- Kept the deck at 20 slides to match the NAIRR template slide count.
- Made slide 8 the start of the concrete WRF instance:
  `Start the WRF instance: wrf.def`.
- Moved the WRF/WPS executable explanation so it now follows the compile slide:
  slide 12 is `Compile WRF/WPS inside wrf.sif`, and slide 13 is
  `Compiled WRF/WPS: the end products`.
- Removed the separate expected Slurm-output slide to make room for the new
  porting/introduction slide; the Slurm output example remains on the final
  hands-on Slurm slide.
- Expanded the generated verbatim script from short notes into conversational
  slide-by-slide speaker text.
- Tightened dense code-slide layout so the `wrf.def` code block stays inside
  the proof-rendered code box.
- Refreshed `SLIDE_RENDER_HANDOFF.md` and `docs/slide_render_handoff.md` so the
  handoff range descriptions match the new slide structure.

Validation:

- `python3 -m py_compile tools/make_nairr_template_deck.py` passed.
- `python3 tools/make_nairr_template_deck.py` succeeded.
- `unzip -t Containerization_Presentation_CG_NAIRR_template_v2.pptx` reported
  no archive errors.
- `pdfinfo Containerization_Presentation_CG_NAIRR_template_v2.pdf` confirmed
  20 pages at 720 by 405 points.
- `pdftoppm` rendered 20 PNG proof previews under
  `rendered/template_v2_pdf_check/`.
- Manual visual checks of slides 2, 3, 8, 12, 13, and 16-20 showed readable
  content with no obvious overlap in the generated proof previews.
- Package media list still contains only the intended NAIRR template assets:
  `image7.png`, `image11.png`, and `image24.png`.
- XML/package scans found no stale `Expected Slurm`,
  `WRF/WPS as the concrete`, `Run Pangu`, `Create the Pangu`, `Takeaways`,
  `Hands-on: bind mount`, `Colorado`, `Boulder`, `knuth`, `image1.png`, or
  `image2.jpg` references.

## 2026-07-10 12:03 EDT

Rechecked the raw `wrf.def` Apptainer build after the user reported an MPICH
configure failure.

Result:

- Current tracked `wrf.def` is not a clean raw build recipe as previously
  assumed.
- A fresh test build command was run against a new output path:
  `apptainer build --force /tmp/wrf-def-raw-test.sif wrf.def`.
- The build reached MPICH 4.2.3 configuration and failed at:
  `./configure --prefix=/opt/mpich --disable-fortran=no FC=gfortran`.
- MPICH reported: `configure: error: invalid feature name: fortran=no`.
- The build stopped in `%post`; no `/tmp/wrf-def-raw-test.sif` image was
  produced.

Follow-up needed:

- Fix the MPICH configure option in `wrf.def` before telling users that
  `apptainer build wrf.sif wrf.def` works.
- The same invalid line is also documented in
  `docs/wrf_containerization_process.md` and should be corrected there after
  the recipe fix is verified.

## 2026-07-10 12:54 EDT

Fixed and revalidated the source-build `wrf.def` recipe.

Recipe changes:

- Replaced the invalid MPICH configure command
  `./configure --prefix=/opt/mpich --disable-fortran=no FC=gfortran` with the
  known-good command embedded in the working July 4 image:
  `./configure --prefix=/opt/mpich FC=gfortran`.
- Aligned the HDF5 source URL and extracted directory with the working image:
  `hdf5-1_14_3.tar.gz` extracted into `hdfsrc`.
- Added `/opt/mpich/lib` to `LD_LIBRARY_PATH` and `/opt/hdf5/bin` to `PATH`.
- Added the same `%test` smoke check that is embedded in the working
  `wrf.sif`.
- Updated `docs/wrf_containerization_process.md` so it no longer documents the
  broken MPICH/HDF5 commands.

Validation:

- Confirmed `wrf.def` now matches the definition embedded in the existing
  working `wrf.sif` with:
  `apptainer inspect --deffile wrf.sif | diff -u - wrf.def`.
- Built a fresh test image without overwriting the existing repo image:
  `apptainer build --force /tmp/wrf-def-fixed-test.sif wrf.def`.
- Build completed successfully and wrote a 528M image at
  `/tmp/wrf-def-fixed-test.sif`.
- The build passed its `%test` section. Anvil emitted harmless XALT
  `LD_PRELOAD` warnings during `%test`, but the test itself succeeded.
- A clean smoke test with `LD_PRELOAD` unset confirmed:
  - `mpicc` and `mpif90` from `/opt/mpich/bin`
  - `h5pcc` from `/opt/hdf5/bin`
  - `ncdump`, `nc-config`, and `nf-config` from `/opt/netcdf/bin`
  - MPICH `4.2.3`, configured as `--prefix=/opt/mpich FC=gfortran`
  - netCDF-C `4.9.2`
  - `nc-config --has-nc4=yes`
  - `nc-config --has-parallel4=yes`
  - netCDF-Fortran `4.6.1`
  - HDF5 `1.14.3` with `Parallel HDF5: yes`

Notes:

- The repo-root `wrf.sif` was not overwritten during this validation; the fresh
  proof image is `/tmp/wrf-def-fixed-test.sif`.
- `wrf-compiled.sif` is not built directly from `wrf.def`. The chain is:
  `wrf.def` -> `wrf.sif` -> compile/stage WRF/WPS -> build
  `wrf-compiled.sif` from a derived `localimage` definition.
- The old temporary staging paths used for the July 7 compiled image
  (`/tmp/wrf-container-build-clean` and `/tmp/wrf-container-runtime-20260707c`)
  are no longer present, so rebuilding `wrf-compiled.sif` from scratch requires
  rerunning the documented compile/stage process.

## 2026-07-10 13:04 EDT

Preserved the fixed source-build recipe under a separate filename and restored
the canonical repo recipe:

- Saved the validated fixed definition as `wrf.fixed.def`.
- Restored `wrf.def` to the exact content from `HEAD`.
- Verified `git hash-object wrf.def` matches `git rev-parse HEAD:wrf.def`:
  `77004a04de7ff11741339f5a2c72b6ae7ed2bf66`.
- Verified `wrf.fixed.def` matches the definition embedded in the successful
  proof image `/tmp/wrf-def-fixed-test.sif`.

Important:

- `wrf.def` is now back to the original repo version, including the invalid
  MPICH line `--disable-fortran=no`; rebuilding from this file will reproduce
  the MPICH configure error.
- Use `wrf.fixed.def` to rebuild the source-build toolchain image successfully.

## 2026-07-13

Resumed from the durable repo notes rather than a hidden chat transcript.
Current teaching direction from the user: make the hands-on portion focus on
participants seeing the difference between commands run on the Anvil login node
and commands run inside Apptainer.

Hands-on update:

- Added `hands_on/00_login_vs_container_walkthrough.sh` as the first guided
  exercise.
- The script labels commands as `login$` and `container$`, then compares
  hostname, kernel, user, working directory, environment variables, visible
  compilers/MPI/netCDF/HDF5 tools, and `/opt/wrf` WRF/WPS executables.
- The script writes `login_vs_container_check.txt` through a bind mount under
  `$WORKDIR` so participants can see that a process inside the image wrote to
  Anvil host storage.
- The script ends with an optional manual `apptainer shell --bind ...` command
  block for a slower type-along exercise inside the container.
- Updated `hands_on/README.md` and `docs/container_hands_on_workflow.md` so
  the recommended participant flow starts with the new host-versus-container
  walkthrough, then continues with the existing image inspect, stack verify,
  bind-write, and optional Slurm checks.
- Updated `tools/make_nairr_template_deck.py` so the generated hands-on slides
  include the new login-node-versus-container walkthrough.
- Regenerated `Containerization_Presentation_CG_NAIRR_template_v2.pptx`,
  `Containerization_Presentation_CG_NAIRR_template_v2.pdf`, and
  `Containerization_Presentation_CG_NAIRR_template_v2_verbatim.md`.

Validation:

- Shell syntax checks passed for `hands_on/00_login_vs_container_walkthrough.sh`
  and the existing `hands_on/01` through `04` scripts.
- A local smoke run passed with
  `IMAGE=/home/x-cgian/projects/WRF_training_SCIPE/wrf-compiled.sif` and
  `WORKDIR=/tmp/wrf_container_hands_on_test`.
- The smoke run showed the intended teaching contrast: host/login commands saw
  Anvil compiler/MPI paths and no netCDF/HDF5 tools, while container commands
  saw `/opt/mpich`, `/opt/netcdf`, `/opt/hdf5`, WRF/WPS under `/opt/wrf`, and
  the same Anvil hostname/kernel.
- `python3 -m py_compile tools/make_nairr_template_deck.py` passed, deck
  regeneration succeeded, `unzip -t` reported no PPTX archive errors, and
  `pdfinfo` confirmed the generated proof PDF still has 20 pages.
- Refreshed `rendered/template_v2_pdf_check/slide-01.png` through
  `slide-20.png`; manual checks of slides 18 and 19 showed readable content
  and no obvious overlap after adding the `00` command.

## 2026-07-13 15:45 EDT

Updated the hands-on setup to match the scratch-based participant workflow:

- Added `hands_on/setup_workshop.sh`.
  - Defaults `SCRATCH=/anvil/scratch/$USER`.
  - Defaults `WORKSHOP=$SCRATCH/WRF_training_SCIPE`.
  - Defaults `PROJECT_IMAGE=/anvil/projects/x-cis240917/WRF_training_SCIPE/wrf.sif`.
  - Defaults `IMAGE=$WORKSHOP/wrf.sif`.
  - Creates the hands-on work directory, copies the staged project `wrf.sif`
    into `$WORKSHOP` if needed, and prints the exports for participants.
- Updated hands-on scripts `00` through `04` to use `$WORKSHOP/wrf.sif` as the
  default image path instead of the shared project `wrf-compiled.sif`.
- Kept support for `wrf-compiled.sif` as an instructor override by making
  `/opt/wrf` executable checks conditional. Plain `wrf.sif` now validates the
  MPI/netCDF/HDF5 toolchain and reports that compiled WRF/WPS executables are
  absent rather than failing.
- Updated `hands_on/README.md` and `docs/container_hands_on_workflow.md` with
  the participant setup:
  `cd /anvil/scratch/$USER`, clone the GitHub repo, set `WORKSHOP`, copy
  `/anvil/projects/x-cis240917/WRF_training_SCIPE/wrf.sif` into `$WORKSHOP`,
  then run the hands-on scripts.
- Updated `tools/make_nairr_template_deck.py`, regenerated
  `Containerization_Presentation_CG_NAIRR_template_v2.pptx`,
  `Containerization_Presentation_CG_NAIRR_template_v2.pdf`, and
  `Containerization_Presentation_CG_NAIRR_template_v2_verbatim.md`, and
  refreshed `rendered/template_v2_pdf_check/slide-01.png` through
  `slide-20.png`.
- Updated `SLIDE_RENDER_HANDOFF.md` and `docs/slide_render_handoff.md` so the
  active handoff points to the scratch-based hands-on setup.

Validation:

- `bash -n` passed for `hands_on/setup_workshop.sh` and hands-on scripts
  `00` through `03`.
- `sh -n` passed for `hands_on/04_slurm_container_check.sbatch`.
- `python3 -m py_compile tools/make_nairr_template_deck.py` passed.
- `python3 tools/make_nairr_template_deck.py` regenerated the active deck,
  proof PDF, and verbatim script.
- `unzip -t Containerization_Presentation_CG_NAIRR_template_v2.pptx` reported
  no archive errors.
- `pdfinfo Containerization_Presentation_CG_NAIRR_template_v2.pdf` confirmed
  20 pages at 720 by 405 points.
- Manual review of rendered proof slides 14, 18, and 19 showed readable text
  and no obvious overlap.
- Local smoke tests with
  `WORKSHOP=/home/x-cgian/projects/WRF_training_SCIPE`,
  `IMAGE=/home/x-cgian/projects/WRF_training_SCIPE/wrf.sif`, and
  `WORKDIR=/tmp/wrf_container_hands_on_test` passed for:
  `hands_on/setup_workshop.sh`,
  `hands_on/00_login_vs_container_walkthrough.sh`,
  `hands_on/01_inspect_image.sh`,
  `hands_on/02_verify_stack.sh`, and
  `hands_on/03_bind_mount_write_test.sh`.
  Apptainer execution required running outside the Codex sandbox because the
  sandbox blocked Apptainer socket operations.

## 2026-07-13 16:30 EDT

Simplified the participant-facing hands-on scripts after user feedback that the
earlier shell logic was too hard for trainees to read:

- `hands_on/setup_workshop.sh` now only sets path defaults, creates the work
  directory, copies `wrf.sif` with `cp -n`, and prints the four hands-on
  commands.
- `hands_on/00_login_vs_container_walkthrough.sh` is now a direct command
  sheet: a short login-node command block, one `apptainer exec` block, and a
  final `cat` of the file written through the bind mount.
- `hands_on/01_inspect_image.sh` now runs only `apptainer inspect`.
- `hands_on/02_verify_stack.sh` now runs one `apptainer exec` command that
  checks MPI, netCDF, and HDF5. It no longer tries to detect optional
  `wrf-compiled.sif` runtime executables.
- `hands_on/03_bind_mount_write_test.sh` now runs one bind-mounted
  `apptainer exec` command and then `cat`s the written file.
- `hands_on/04_slurm_container_check.sbatch` now keeps one simple
  `srun apptainer exec` check for Slurm visibility, kernel context, `mpicc`,
  and `nc-config`.
- Updated `hands_on/README.md`, `docs/container_hands_on_workflow.md`,
  `SLIDE_RENDER_HANDOFF.md`, and `tools/make_nairr_template_deck.py` to remove
  stale optional `/opt/wrf` runtime-image check language.
- Regenerated `Containerization_Presentation_CG_NAIRR_template_v2.pptx`,
  `Containerization_Presentation_CG_NAIRR_template_v2.pdf`,
  `Containerization_Presentation_CG_NAIRR_template_v2_verbatim.md`, and
  `rendered/template_v2_pdf_check/slide-01.png` through `slide-20.png`.

Validation:

- Syntax checks passed for `hands_on/setup_workshop.sh`, scripts `00` through
  `03`, and `hands_on/04_slurm_container_check.sbatch`.
- `python3 -m py_compile tools/make_nairr_template_deck.py` passed.
- Deck regeneration succeeded.
- `unzip -t Containerization_Presentation_CG_NAIRR_template_v2.pptx` reported
  no archive errors.
- `pdfinfo Containerization_Presentation_CG_NAIRR_template_v2.pdf` confirmed
  20 pages at 720 by 405 points.
- Manual review of rendered proof slides 14 and 19 showed readable content.
- Local smoke tests with a temporary workshop image copy under
  `/tmp/wrf_simple_hands_on` passed for `setup_workshop.sh`,
  `00_login_vs_container_walkthrough.sh`, `01_inspect_image.sh`,
  `02_verify_stack.sh`, and `03_bind_mount_write_test.sh`. Apptainer execution
  again required running outside the Codex sandbox.

## 2026-07-13 17:02 EDT

Cleaned up `LD_PRELOAD` handling in the participant hands-on scripts:

- Added one short comment plus `unset LD_PRELOAD` near the top of each script
  that runs Apptainer:
  `hands_on/00_login_vs_container_walkthrough.sh`,
  `hands_on/01_inspect_image.sh`,
  `hands_on/02_verify_stack.sh`,
  `hands_on/03_bind_mount_write_test.sh`, and
  `hands_on/04_slurm_container_check.sbatch`.
- Removed repeated `env -u LD_PRELOAD` wrappers from individual Apptainer and
  Slurm commands so the commands are easier for participants to read.
- Left `hands_on/setup_workshop.sh` unchanged because it only creates the work
  directory, copies `wrf.sif`, and prints commands; it does not run Apptainer.

Validation:

- Syntax checks passed for scripts `00` through `03` and the Slurm script.
- Local smoke tests against `/tmp/wrf_simple_hands_on/wrf.sif` passed for
  `00_login_vs_container_walkthrough.sh`, `01_inspect_image.sh`,
  `02_verify_stack.sh`, and `03_bind_mount_write_test.sh`. Apptainer execution
  required running outside the Codex sandbox as before.

## 2026-07-13 18:10 EDT

Prepared the participant scripts for upload and scratch-clone testing:

- Removed `hands_on/04_slurm_container_check.sbatch` from the participant
  script set because Slurm will be covered by other instructors.
- Removed Slurm script references from `hands_on/README.md`,
  `docs/container_hands_on_workflow.md`, `SLIDE_RENDER_HANDOFF.md`, and the
  active deck generator.
- Regenerated the active NAIRR-template deck, proof PDF, verbatim script, and
  rendered preview images. The final hands-on slide is now a wrap-up of what
  the container exercise proves instead of a Slurm exercise.
- During scratch-clone testing with the project-staged image
  `/anvil/projects/x-cis240917/WRF_training_SCIPE/wrf.sif`, found that this
  older image has `/opt/hdf5/bin/h5pcc` but does not put `/opt/hdf5/bin` on
  `PATH` through `/opt/scripts/paths.sh`.
- Updated `hands_on/00_login_vs_container_walkthrough.sh` and
  `hands_on/02_verify_stack.sh` to call `/opt/hdf5/bin/h5pcc` explicitly.

Current Git state:

- Local commit `7d5d7ff` was created for the hands-on scripts and notes.
- Push to `origin/main` failed because HTTPS GitHub authentication attempted a
  GUI askpass prompt on the Anvil login node:
  `fatal: could not read Username for 'https://github.com'`.
- `gh` is not installed, so there is no GitHub CLI-authenticated fallback in
  this environment.

## 2026-07-13 18:33 EDT

Completed upload and participant-style scratch test:

- Amended the hands-on commit author and committer to the user's GitHub
  identity:
  `Cong Gian <33527035+CongGian@users.noreply.github.com>`.
- HTTPS push still could not authenticate from the Anvil terminal, but SSH
  push worked.
- Because the local working tree was dirty and behind `origin/main`, created a
  clean temporary clone at `/tmp/wrf_push_clone_20260713_1819`, cherry-picked
  the hands-on commit there, and pushed it to GitHub.
- Pushed commit on `origin/main`: `4dd235b`
  (`Add scratch-based container hands-on scripts`).
- Freshly cloned GitHub `main` over HTTPS into:
  `/anvil/scratch/$USER/wrf_hands_on_github_participant_test_20260713_1823/WRF_training_SCIPE`.
- Confirmed the fresh clone contains commit `4dd235b`.
- Ran `hands_on/setup_workshop.sh` from that fresh scratch clone with
  `WORKSHOP` pointing at the clone. It copied
  `/anvil/projects/x-cis240917/WRF_training_SCIPE/wrf.sif` into the scratch
  clone as `wrf.sif`.
- Ran participant scripts successfully from the fresh GitHub scratch clone:
  `hands_on/00_login_vs_container_walkthrough.sh`,
  `hands_on/01_inspect_image.sh`,
  `hands_on/02_verify_stack.sh`, and
  `hands_on/03_bind_mount_write_test.sh`.

Observed staged image details during the participant test:

- Project image copied to scratch is 484M and has build date
  `Monday_10_November_2025_15:51:17_UTC`.
- It reports MPICH `4.2.3`, netCDF-C `4.9.2`, netCDF-Fortran `4.6.1`, and HDF5
  `1.14.6` with `Parallel HDF5: yes`.
- The bind-mount test wrote `container_write_check.txt` under
  `$WORKSHOP/container_hands_on` and printed it successfully from the host side.

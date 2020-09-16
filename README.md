This repo implements some tests for containerised MPI applications using EasyBuild and Singularity.

It may be useful as an example of building/running such applications.

# Installing EasyBuild.
Follow the [standard instructions](https://easybuild.readthedocs.io/en/latest/Installation.html) - this can be done as an unpriviledged user.

It is recommended to add something like the following to `.bashrc`:

```shell
export EASYBUILD_PREFIX=<easybuild install location>
module use $EASYBUILD_PREFIX/modules/all
```

# Installing Singularity
This **must** be done with root priviledges. The process and prerequesites are documented [e.g. here](https://sylabs.io/guides/3.6/admin-guide/installation.html#installation-on-linux) but note you will need [PR#5550](https://github.com/hpcng/singularity/pull/5550) which currently (as of 3.6) is only in the master branch.

To make this more obvious if using a system with Singularity already installed, the command below is given as `singularity-dev`.

# How to build containers using EasyBuild + Singularity

The steps here are:

1. Use EasyBuild to create a recipe for a container with GCC + OpenMPI + OpenBLAS + ScaLAPACK + FFTW. This can be used as the basis for individual containers for MPI applications, avoiding a (lengthy) rebuild of that toolchain for each application.
1. Fix this recipe so it works.
1. Use Singularity to build this container - it will have modules for the above, which will be activated by default when the container is run.
3. Use EasyBuild to create a recipe for a container based on the above, plus required applications which here are Intel MPI Benchmarks (IMB) and OSU Micro Benchmarks (OMB).
4. Build that container using Singularity.

All of this can be done as an unpriviledged user.

The exact EasyBuild "toolchain" you select in #1. will depend on what's available for the applications you want to run. Here, we use `foss-2019a`.

TODO: link to eb matrix tool?

```shell
module load EasyBuild
eb -r foss-2019a.eb --experimental --containerize --container-config bootstrap=yum,osversion=7
# produces $EASYBUILD_PREFIX/containers/Singularity.foss-2019a

# now modify that file to add:
# yum install --quiet --assumeyes openssl
# after the epel-release install

cd $EASYBUILD_PREFIX/containers/
singularity-dev build --fakeroot foss-2019a.sif Singularity.foss-2019a

eb -r IMB-2019.3-gompi-2019a.eb OSU-Micro-Benchmarks-5.6.2-gompi-2019a.eb --experimental --containerize --container-config bootstrap=localimage,from=foss-2019a.sif --container-image-name mpi-benchmarks
# produces $EASYBUILD_PREFIX/containers/Singularity.mpi-benchmarks

singularity-dev build --fakeroot mpi-benchmarks.sif Singularity.mpi-benchmarks
```

# Testing compatibility

## Incomplete Notes

Name format for `*.sh`,`*.out` & `*.err` files:

    <hostmpi>-<containermpi>-<network>-<test>

where:
- ompi3 = openmpi3 + btl (openhpc package)
- ompi4 = openmpi4 + UCX (spack package)
- foss2019 = (EB package, which ompi version)
- NA = no container

status:
- ompi3-NA-ib-ping.sh: QUEUED
- ompi4-NA-ib-ping.sh: 
- ompi3-foss2019-ib-ping.sh: 
- ompi4-foss2019-ib-ping.sh: 

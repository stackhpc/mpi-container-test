#!/bin/bash
#SBATCH --ntasks=2
#SBATCH --ntasks-per-node=1
#SBATCH --time=0:10:0
#SBATCH --exclusive
#SBATCH --output=%x.out
#SBATCH --error=%x.err
# force use of nodes 0-1 (same rack) for consistency:
#SBATCH --exclude=openhpc-compute-[2-15]
module load gnu7/7.3.0 # openhpc package
module load openmpi3/3.1.0 # # openhpc package, uses btl
export OMPI_MCA_btl_openib_if_include=mlx5_0:1
echo "Nodes:", $SLURM_JOB_NODELIST

mpirun /alaska/steveb/opt/singularity-dev/bin/singularity exec mpi-benchmarks.sif IMB-MPI1 pingpong

echo "Results: " $(python imb-stats.py $SLURM_JOB_NAME.out)

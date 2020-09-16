#!/bin/bash
#SBATCH --job-name="imb"
#SBATCH --ntasks=2
#SBATCH --ntasks-per-node=1
#SBATCH --time=0:10:0
#SBATCH --exclusive
#SBATCH --output=imb.out
#SBATCH --error=imb.err
module load gnu7/7.3.0  openmpi3/3.1.0
module load openmpi3/3.1.0
export UCX_NET_DEVICES=mlx5_0:1 # host MPI - uses UCX
export OMPI_MCA_btl_openib_if_include=mlx5_0:1 # guest MPI - uses openib btl
echo "Nodes:", $SLURM_JOB_NODELIST
module load imb/2018.1
mpirun IMB-MPI1 pingpong

echo "Results: " $(python imb-stats.py imb.out)

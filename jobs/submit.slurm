#!/bin/bash
#SBATCH --job-name=claude_hpc_test
#SBATCH --account=maom0
#SBATCH --output=jobs/output_%j.log
#SBATCH --error=jobs/error_%j.log
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --time=00:05:00
#SBATCH --partition=standard       # <-- Change to your university's partition name

echo "Slurm Job ID: $SLURM_JOB_ID"
echo "Setting up environment..."

# Load modules if required (e.g., module load python)
# cd to the directory where the files were synced
cd "$HOME/hpc-test-project"

# Run the Python script
python3 src/test_job.py


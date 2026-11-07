#!/bin/bash

# --- CONFIGURATION ---
# Replace with your university cluster username and login node address
REMOTE_USER="ymanasa"
REMOTE_HOST="greatlakes.arc-ts.umich.edu"
# The directory on the cluster where your files will go
REMOTE_DIR="/home/ymanasa/hpc-test-project"
# ---------------------

SOCKET_FILE="./.ssh_control/ssh_mux_%h_%p_%r"

# Function to check if the MFA tunnel is alive
check_tunnel() {
    ssh -O check -S "$SOCKET_FILE" "$REMOTE_USER@$REMOTE_HOST" 2>/dev/null
}

# 1. Establish the MFA Tunnel if it doesn't exist
if ! check_tunnel; then
    echo "🔑 No active session found. Establishing secure MFA tunnel..."
    echo "⚠️ Please complete your University MFA prompt (Duo, Authenticator, etc.) now:"
    
    # Opens a master connection in the background (-M) and goes to background (-f) without executing a command (-N)
    ssh -M -f -N -S "$SOCKET_FILE" -o ControlPersist=1h "$REMOTE_USER@$REMOTE_HOST"
    
    if check_tunnel; then
        echo "✅ MFA Tunnel successfully established! (Valid for 1 hour of inactivity)"
    else
        echo "❌ Failed to establish MFA tunnel. Exiting."
        exit 1
    fi
else
    echo "✅ Reusing existing secure MFA tunnel."
fi

# 2. Sync Local Code to Cluster using the tunnel
echo "🔄 Preparing remote directory and syncing files..."

ssh -S "$SOCKET_FILE" "$REMOTE_USER@$REMOTE_HOST" "mkdir -p $REMOTE_DIR"

echo "🔄 Syncing files to the cluster..."
rsync -avz -e "ssh -S $SOCKET_FILE" --exclude='.ssh_control' . "$REMOTE_USER@$REMOTE_HOST:/home/ymanasa/hpc-test-project"

# 3. Submit the Slurm Script using the tunnel
echo "🚀 Submitting Slurm script..."
ssh -S "$SOCKET_FILE" "$REMOTE_USER@$REMOTE_HOST" "cd $REMOTE_DIR && sbatch jobs/submit.slurm"

# 4. Pull down results (Optional shortcut tool for Claude to use later)
if [ "$1" == "--pull" ]; then
    echo "📥 Pulling logs and results back down to local computer..."
    rsync -avz -e "ssh -S $SOCKET_FILE" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR/jobs/" ./jobs/
    rsync -avz -e "ssh -S $SOCKET_FILE" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR/results.txt" ./ 2>/dev/null
fi


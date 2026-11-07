# src/test_job.py
import time
import os

print("Starting compute job on the university cluster...")
print(f"Running on node: {os.uname().nodename}")

# Simulate work
for i in range(5):
    print(f"Processing batch {i+1}/5...")
    time.sleep(2)

# Output results
output_path = "results.txt"
with open(output_path, "w") as f:
    f.write(f"Job completed successfully on {os.uname().nodename}!\n")
    f.write("Data processing matrix verified.\n")

print(f"Job complete. Output written to {output_path}")


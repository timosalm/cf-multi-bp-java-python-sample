#!/bin/bash
# CloudFoundry .profile script - runs before the application starts.
# Unpacks the conda-pack environment so the Python binary and pandas are available.

if [ -f python_env.tar.gz ]; then
    echo "Unpacking conda environment..."
    mkdir -p python_env
    tar -xzf python_env.tar.gz -C python_env
    # Activate and fix prefix paths
    source python_env/bin/activate
    conda-unpack 2>/dev/null || true
    echo "Conda environment ready at: $(pwd)/python_env"
fi

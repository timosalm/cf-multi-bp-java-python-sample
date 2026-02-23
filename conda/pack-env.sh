#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
CONTAINER_NAME="conda-pack-builder"

echo "=== Building linux-amd64 conda-pack environment in Docker ==="

# Build and run a Linux container that creates the conda-pack tarball
docker run --rm \
  --platform linux/amd64 \
  --name "$CONTAINER_NAME" \
  -v "$PROJECT_DIR:/output" \
  -v "$SCRIPT_DIR/environment.yml:/environment.yml:ro" \
  condaforge/miniforge3:latest \
  bash -c '
    set -e
    echo "Installing conda-pack into base env..."
    conda install -y -n base conda-pack

    echo "Creating environment from environment.yml..."
    conda env create -f /environment.yml --prefix /python_env

    echo "Packing environment..."
    conda pack -p /python_env -o /output/python_env.tar.gz

    echo "Done inside container."
  '

echo ""
echo "=== python_env.tar.gz created at: $PROJECT_DIR/python_env.tar.gz ==="
ls -lh "$PROJECT_DIR/python_env.tar.gz"

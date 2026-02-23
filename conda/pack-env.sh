#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "Creating conda environment from environment.yml..."
conda env create -f "$SCRIPT_DIR/environment.yml" --prefix "$SCRIPT_DIR/python_env"

echo "Packing conda environment..."
conda pack -p "$SCRIPT_DIR/python_env" -o "$PROJECT_DIR/python_env.tar.gz"

echo "Cleaning up local conda env..."
conda env remove --prefix "$SCRIPT_DIR/python_env" -y

echo "Done! python_env.tar.gz created at: $PROJECT_DIR/python_env.tar.gz"

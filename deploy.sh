#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DEPLOY_DIR="$SCRIPT_DIR/deploy"

echo "=== Building Spring Boot application ==="
cd "$SCRIPT_DIR"
./mvnw clean package -DskipTests

echo "=== Preparing deploy directory ==="
rm -rf "$DEPLOY_DIR"
mkdir -p "$DEPLOY_DIR/scripts"

# Copy the Spring Boot JAR
cp target/spring-python-demo-0.0.1-SNAPSHOT.jar "$DEPLOY_DIR/"
(cd "$DEPLOY_DIR" && jar xf spring-python-demo-0.0.1-SNAPSHOT.jar)
rm "$DEPLOY_DIR"/spring-python-demo-0.0.1-SNAPSHOT.jar

# Copy Python script
cp scripts/hello.py "$DEPLOY_DIR/scripts/"

# Copy files needed by python_buildpack
cp requirements.txt "$DEPLOY_DIR/"
cp runtime.txt "$DEPLOY_DIR/"

# Copy .profile for conda-pack unpacking at startup
cp .profile "$DEPLOY_DIR/"

# Copy conda-pack tarball (must be created first via conda/pack-env.sh)
if [ -f python_env.tar.gz ]; then
    cp python_env.tar.gz "$DEPLOY_DIR/"
    echo "Conda-pack tarball included."
else
    echo "WARNING: python_env.tar.gz not found!"
    echo "Run './conda/pack-env.sh' first to create the conda-pack environment."
    exit 1
fi

echo "=== Deploy directory ready ==="
echo "Run 'cf push' to deploy to CloudFoundry."

# Spring Boot + Python on CloudFoundry (Multi-Buildpack)

A Spring Boot 3.5 / Java 21 application that invokes a Python script via `ProcessBuilder`.
The Python environment (including pandas) is shipped as a **conda-pack** tarball and unpacked at application startup on CloudFoundry.

## What's special about this deployment

### Multi-Buildpack

CloudFoundry is configured with **two buildpacks** in `manifest.yaml`:

| Order | Buildpack | Role |
|-------|-----------|------|
| 1 | `python_buildpack` | **Supply** buildpack -- installs a base Python runtime into the droplet |
| 2 | `java_buildpack_offline` | **Final** buildpack -- provides the JVM, memory calculator and start command for the Spring Boot app |

The first buildpack only *supplies* dependencies; the last one owns the process type and start command.

### Conda-Pack for the Python environment

Rather than relying on `pip install` at staging time, the Python packages (pandas, etc.) are pre-built into a portable **conda-pack** tarball (`python_env.tar.gz`).
This tarball is created inside a **linux/amd64 Docker container** so the native binaries match the CloudFoundry stack, even when building on macOS (Apple Silicon or Intel).

At application startup the CF `.profile` script unpacks the tarball and activates the environment before the JVM starts.

### Extracted JAR

The `deploy.sh` script uses the `jar xf` command to upack the contents of the JAR file to the deploy directory.
This allows the `java_buildpack_offline` to detect and run the application correctly in a multi-buildpack setup.

## Deploy directory layout

After running `deploy.sh`, the pushed directory looks like this:

```
deploy/
├── .profile                # CF startup hook -- unpacks conda env
├── requirements.txt        # Empty -- triggers python_buildpack detection
├── runtime.txt             # Python version hint for python_buildpack
├── python_env.tar.gz       # Conda-pack tarball (Python 3.11 + pandas)
├── scripts/
│   └── hello.py            # Python script invoked by the Spring Boot app
└── BOOT-INF/   # Extracted Spring Boot JAR
├── META-INF/
└── org/   
```

## Prerequisites

- **Java 21**
- **Maven** (or use the included `mvnw` wrapper)
- **Docker** (for building the conda-pack tarball on macOS)
- **CF CLI** (`cf`) logged in to a CloudFoundry environment

## Build & Deploy

### 1. Create the conda-pack environment

This runs inside a Docker container so the resulting tarball contains linux-amd64 binaries:

```bash
./conda/pack-env.sh
```

The script produces `python_env.tar.gz` in the project root.

### 2. Build the Spring Boot app and assemble the deploy directory

```bash
./deploy.sh
```

This will:
1. Build the Spring Boot fat JAR via Maven
2. Extract it into `deploy/`
3. Copy the Python script, `.profile`, `requirements.txt`, `runtime.txt` and `python_env.tar.gz` into `deploy/`

### 3. Push to CloudFoundry

```bash
cf push
```

### 4. Test

```bash
curl https://<app-route>/run-python
```

Expected output:

```
=== Hello from Python with Pandas! ===
Pandas version: 2.x.x

Language scores:
 language  score
     Java     85
   Python     92
       Go     78
     Rust     88

Average score: 85.8
Top language: Python
=== Done ===
```
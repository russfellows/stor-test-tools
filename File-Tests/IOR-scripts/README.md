# IOR Configuration Scripts

Configuration files for parallel file I/O benchmarking with **IOR**.

## Documentation Resources

For comprehensive IOR and IO500 documentation:

- **IO500 Benchmark Specification**: [io500.io](https://io500.io)
  - Official benchmark rankings and results
  - Test tier specifications: IOR Easy, Standard, Hard
  - MDtest tier specifications for metadata operations
  - MLCommons Storage compliance documentation

- **IOR GitHub Repository**: [github.com/hpc/ior](https://github.com/hpc/ior)
  - Source code and latest releases
  - [IOR Wiki](https://github.com/hpc/ior/wiki) - Configuration examples and parameter reference
  - Issue tracking and feature discussions
  - Performance tuning guides

- **IOR Test Tiers**:
  - **IOR Easy**: Basic read/write workload (smaller file sizes, fewer processes)
  - **IOR Standard**: Standard MLCommons Storage workload (balanced performance metrics)
  - **IOR Hard**: Demanding workload with metadata operations and striping patterns
  - **MDtest**: Dedicated metadata benchmarking (mkdir, stat, unlink, file listing)

## Directory Contents

- **IOR-MDtest-full.ini** - Comprehensive metadata testing configuration
- **io500-mpi-coordinate-gemini-AWS.sh** - IO500 benchmark coordination script for AWS
- **io500-mpi-coordinate-gemini-GCP.sh** - IO500 benchmark coordination script for Google Cloud
- **drop-cache-GCP.sh** - Utility script for dropping caches on Google Cloud instances

## IOR Overview

IOR (Interleaved-Or-Random) is a parallel file I/O benchmark tool implementing MLCommons Storage workload specifications for:
- Testing distributed file system performance
- HPC storage evaluation
- MLCommons Storage benchmark patterns (ResNet50, UNet3D)
- Various I/O access patterns (sequential, random, strided)
- Metadata operation performance
- Both POSIX and specialized file systems (Lustre, GPFS, HDF5, etc.)

## Configuration Files

### IOR-MDtest-full.ini
Comprehensive metadata testing configuration for IOR:
- Focuses on metadata operations (file creation, deletion, listing)
- Tests file system performance under metadata-heavy workloads (MDtest tier)
- Suitable for evaluating file system metadata performance
- Useful for benchmarking name servers and directory operations
- Part of IO500 Hard tier testing

### IO500 Scripts
IO500 is a comprehensive HPC storage benchmarking suite combining IOR and MDtest:

**io500-mpi-coordinate-gemini-AWS.sh**
- Orchestrates IO500 benchmark execution on AWS infrastructure
- Uses MPI for distributed parallel execution across nodes
- Targets AWS Gemini-based storage systems
- Manages test coordination and result aggregation
- Runs IOR Easy, Standard, Hard, and MDtest tiers

**io500-mpi-coordinate-gemini-GCP.sh**
- Orchestrates IO500 benchmark execution on Google Cloud
- Uses MPI for distributed parallel execution across GCP instances
- Targets GCP-based storage systems
- Manages test coordination and performance monitoring
- Runs complete IO500 test suite (all four tiers)

### drop-cache-GCP.sh
Utility script for consistent benchmarking:
- Clears file system caches on Google Cloud instances
- Ensures clean baseline between test runs
- Required for reproducible benchmark results
- Used before IOR Easy tier for consistent measurements
- Typically run between test iterations

## Usage

### Basic IOR Test

```bash
# Pull the container
docker pull quay.io/russfellows-sig65/io500

# Run IOR with metadata testing
docker run -it -v /test/mount:/testdir \
  quay.io/russfellows-sig65/io500 \
  ior -f IOR-MDtest-full.ini -o /testdir/
```

### Distributed IO500 on AWS

```bash
# Run the AWS coordination script
docker run -it \
  -e AWS_REGION=us-west-2 \
  -e AWS_KEY_ID=<key> \
  -e AWS_SECRET_KEY=<secret> \
  quay.io/russfellows-sig65/io500 \
  bash io500-mpi-coordinate-gemini-AWS.sh
```

### Distributed IO500 on GCP

```bash
# Run the GCP coordination script
docker run -it \
  -e GCP_PROJECT=<project> \
  -e GCP_ZONE=<zone> \
  quay.io/russfellows-sig65/io500 \
  bash io500-mpi-coordinate-gemini-GCP.sh
```

### Clear Caches Before Benchmarking

```bash
# Run on GCP to ensure clean test state
docker run -it \
  -e GCP_INSTANCE=<instance-name> \
  -e GCP_ZONE=<zone> \
  quay.io/russfellows-sig65/io500 \
  bash drop-cache-GCP.sh
```

## IOR Configuration File Format

IOR uses INI-style configuration files with parameters like:

- **fs**: File system type (POSIX, HDF5, NetCDF, etc.)
- **nodes**: Number of MPI processes/nodes
- **file**: Output file pattern
- **blockSize**: Size of data block per process
- **transferSize**: Size of each I/O transfer
- **repetitions**: Number of test repetitions
- **keepFile**: Whether to keep/delete files after test
- **verbose**: Verbosity level for output

## Prerequisites

- Docker or container runtime
- For local tests: File system mount point with proper permissions
- For distributed tests: MPI infrastructure, multiple nodes with network connectivity
- For cloud tests: Cloud provider credentials and resource access

## Container

**Image**: `quay.io/russfellows-sig65/io500`

Contains IOR, IO500 tools, MPI libraries, and benchmarking utilities for MLCommons Storage workloads.

See parent directory documentation for more details.

## References

- IOR Project: https://github.com/hpc/ior
- IO500 Benchmark: https://www.vi4io.org/io500/
- IOR Documentation: https://github.com/hpc/ior/wiki

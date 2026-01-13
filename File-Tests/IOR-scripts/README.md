# IOR - Parallel File I/O Benchmark Testing

Distributed parallel file I/O benchmarking with **IOR** (Interleaved-Or-Random), coordinated via MPI across multiple hosts.

## Container

**Image**: `quay.io/russfellows-sig65/io500`

Contains:
- **IOR** - Parallel file I/O benchmark with MPI support
- **IO500 tools** - Complete HPC storage benchmarking suite
- **MPI infrastructure** - OpenMPI/MPICH for distributed execution
- File system testing utilities

Pull the container:
```bash
docker pull quay.io/russfellows-sig65/io500
docker tag quay.io/russfellows-sig65/io500 io500:latest
```

## Overview

IOR (Interleaved-Or-Random) is a parallel file I/O benchmark tool for:
- Distributed file system performance testing
- HPC storage evaluation
- MLCommons Storage workload patterns
- Various I/O patterns: sequential, random, strided
- Metadata operation testing
- POSIX and specialized parallel file systems (Lustre, GPFS, HDF5, etc.)

## Directory Contents

- **IOR-MDtest-full.ini** - Metadata-focused testing configuration
- **io500-mpi-coordinate-gemini-AWS.sh** - Distributed test coordination for AWS infrastructure
- **io500-mpi-coordinate-gemini-GCP.sh** - Distributed test coordination for Google Cloud
- **drop-cache-GCP.sh** - Cache dropping utility for consistent results

## Infrastructure Setup

### Tested Configuration

- **1 Launcher VM** (control/coordinator node)
- **8 Client VMs** (test execution nodes)
- All VMs require the **same SSH key** (PEM file) for passwordless access
- Operating System: **Ubuntu 22.04 LTS**
  - ⚠️ Note: Ubuntu 24.04 is not compatible with Lustre as of current release
- Shared file system: **Lustre** (or compatible HPC parallel file system)

### Pre-Flight Checklist

Before running tests, ensure:
- [ ] Lustre prerequisites installed on all VMs
- [ ] Lustre file system mounted at `/mnt/lustre` (or configured path) on all VMs
- [ ] SSH passwordless access between launcher and all client VMs
- [ ] `hosts.txt` file with list of client hostnames
- [ ] `IOR.ini` configuration file available
- [ ] Network connectivity verified between all nodes
- [ ] Docker installed on launcher VM

## Configuration Files

### 1. IOR.ini - Benchmark Configuration

Defines IOR test parameters:
- I/O patterns (sequential, random, strided)
- Block sizes and object counts
- Number of processes/tasks
- Transfer sizes
- Test phases and iterations
- Read/write operations

**IOR Test Tiers** (IO500 specification):
- **IOR Easy**: Basic read/write performance (smaller workloads)
- **IOR Standard**: Standard MLCommons Storage workload (typical production)
- **IOR Hard**: Demanding workload with metadata operations
- **MDtest**: Metadata operation benchmarking (mkdir, stat, rmdir, unlink, etc.)

**Example: IOR-MDtest-full.ini**
- Metadata-intensive testing configuration
- Includes file creation, stat, listing, and deletion operations
- Useful for evaluating file system metadata performance

### 2. hosts.txt - Client Host List

Text file with one hostname per line (order matters for MPI rank mapping):

```
client-1
client-2
client-3
client-4
client-5
client-6
client-7
client-8
```

**Requirements**:
- One hostname per line
- Hostnames must be resolvable from launcher VM
- Order determines MPI rank assignment
- All hosts must have network connectivity to launcher

### 3. Platform-Specific Coordination Scripts

Two scripts for different cloud platforms - **edit with your environment details**:

**io500-mpi-coordinate-gemini-AWS.sh** - For AWS infrastructure
- Edit to include your username, PEM key path, EC2 hostnames
- Set correct paths to `hosts.txt` and `IOR.ini`
- Configure output directory for results

**io500-mpi-coordinate-gemini-GCP.sh** - For Google Cloud infrastructure
- Edit to include your username, GCP PEM key path, GCE instance names
- Set correct paths to `hosts.txt` and `IOR.ini`
- Configure output directory for results

**drop-cache-GCP.sh** - Cache clearing utility
- Used immediately after write phase completes
- Ensures read phase begins with cold caches
- Critical for accurate, reproducible benchmark results

## Running IOR Benchmarks

### Step 1: Prepare Configuration Files

Ensure three files are in place:
- `IOR.ini` or your custom configuration file
- `hosts.txt` with client VM hostnames
- `io500-mpi-coordinate-gemini-AWS.sh` or `io500-mpi-coordinate-gemini-GCP.sh`

### Step 2: Edit Coordination Script

Edit the appropriate platform script with your environment:

```bash
# For AWS
vim io500-mpi-coordinate-gemini-AWS.sh

# For Google Cloud
vim io500-mpi-coordinate-gemini-GCP.sh
```

Replace placeholders with your actual values:
- SSH username
- Path to PEM key file
- Client VM hostnames
- Configuration file paths
- Output directory

### Step 3: Execute Coordination Script

From the **launcher VM**, run the coordination script:

```bash
# AWS
bash io500-mpi-coordinate-gemini-AWS.sh

# Google Cloud
bash io500-mpi-coordinate-gemini-GCP.sh
```

**What the script does**:
1. Parses `IOR.ini` configuration
2. Distributes test setup to all client VMs
3. Verifies connectivity with all clients
4. Coordinates distributed IOR execution via MPI
5. Collects results from all processes
6. Aggregates and reports performance metrics

### Step 4: Monitor and Drop Caches

IOR benchmarks typically have phases:
1. **Write Phase** - Files are created and written
2. **Read Phase** - Files are read back
3. **Metadata Phase** - Metadata operations (if configured)

**Critical**: Drop file system caches **immediately after write phase completes** and **before read phase begins**.

#### Cache Dropping Timing

The timing window is approximately 5 seconds:

```bash
# In a SEPARATE terminal on the launcher VM
# Monitor IOR output in first terminal
# When you see "Write phase complete" or similar, run immediately:

bash drop-cache-GCP.sh
```

**What `drop-cache-GCP.sh` does**:
- SSHes to each client VM
- Executes `sync && echo 3 > /proc/sys/vm/drop_caches`
- Drops OS-level page cache (not application buffers)
- Completes in ~5-10 seconds for 8 VMs

**Why cache dropping matters**:
- Ensures read phase starts with cold/empty caches
- Removes OS-level caching effects from benchmark
- Required for reproducible, comparable results
- Prevents cached reads from masking actual storage performance

**Timing examples**:
- ❌ Too early (during write): Interferes with write phase
- ❌ Too late (read started): Reads show cached performance, not storage performance
- ✅ Correct: 1-2 seconds after write completes (~5 second window)

### Step 5: Collect Results

After IOR completes, review metrics:
- Aggregate write throughput (MB/sec)
- Aggregate read throughput (MB/sec)
- Metadata operation times (if applicable)
- Consistency check results
- Per-process performance details

## Simple Single-Host Test

For basic testing without distributed coordination:

```bash
# Pull container
docker pull quay.io/russfellows-sig65/io500

# Run IOR directly with configuration
docker run -it -v /mount/point:/testdir \
  quay.io/russfellows-sig65/io500 \
  ior -f IOR-MDtest-full.ini -o /testdir/
```

**Note**: This bypasses distributed coordination. Use coordination scripts for multi-host benchmarks.

## Alternative: Bare Metal Execution

To run IOR directly on VMs instead of containers:

1. **Install IOR** on each client VM:
   ```bash
   apt-get install ior  # or build from github.com/hpc/ior
   ```

2. **Use same configuration files**:
   - `IOR.ini` - identical format
   - `hosts.txt` - identical format

3. **Modify coordination scripts**:
   - Replace Docker commands with direct `mpirun ior` invocations
   - Update paths to installed IOR binary
   - Adjust file system mount paths

4. **Execute identically**:
   - Run from launcher VM
   - Monitor output and drop caches at the right time
   - Collect results when complete

## Documentation and References

### Official Resources

- **IO500 Benchmark**: [io500.io](https://io500.io)
  - Official benchmark results and rankings
  - Test tier specifications
  - MLCommons Storage requirements

- **IOR GitHub**: [github.com/hpc/ior](https://github.com/hpc/ior)
  - Source code and releases
  - [Wiki](https://github.com/hpc/ior/wiki) with configuration examples
  - Parameter reference documentation
  - Performance tuning guides

- **IOR Manual Pages**: Available in container
  ```bash
  docker run -it quay.io/russfellows-sig65/io500 man ior
  ```

- **Argonne National Laboratory**
  - IOR User Guide from ANL HPC team
  - POSIX, MPI-IO, parallel file system patterns
  - Performance tuning and scaling benchmarks

## IOR Configuration File Format

IOR uses INI-style configuration files with parameters:

- **fs**: File system type (POSIX, HDF5, NetCDF, MPI-IO, etc.)
- **nodes**: Number of MPI processes/nodes
- **file**: Output file pattern
- **blockSize**: Size of data block per process
- **transferSize**: Size of each I/O transfer
- **repetitions**: Number of test repetitions
- **keepFile**: Whether to keep/delete files after test
- **verbose**: Verbosity level for output

## Related Documentation

- Main repository: [../../README.md](../../README.md)
- File system testing overview: [../README.md](../README.md)
- vdbench testing: [../vdbench-scripts/README.md](../vdbench-scripts/README.md)
- Container registry: https://quay.io/repository/russfellows-sig65/io500

4. **Execute identically**:
   - Run from launcher VM
   - Monitor output and drop caches at the right time
   - Collect results when complete

## Documentation and References

### Official Resources

- **IO500 Benchmark**: [io500.io](https://io500.io)
  - Official benchmark results and rankings
  - Test tier specifications
  - MLCommons Storage requirements

- **IOR GitHub**: [github.com/hpc/ior](https://github.com/hpc/ior)
  - Source code and releases
  - [Wiki](https://github.com/hpc/ior/wiki) with configuration examples
  - Parameter reference documentation
  - Performance tuning guides

- **IOR Manual Pages**: Available in container
  ```bash
  docker run -it quay.io/russfellows-sig65/io500 man ior
  ```

- **Argonne National Laboratory**
  - IOR User Guide from ANL HPC team
  - POSIX, MPI-IO, parallel file system patterns
  - Performance tuning and scaling benchmarks
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

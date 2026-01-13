# IO500 - HPC Storage Benchmark Suite

Official IO500 benchmark implementation using the `io500` command-line tool to coordinate distributed parallel file I/O performance testing.

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

**IO500** is the official HPC storage benchmark suite that tests parallel file system performance through coordinated execution of multiple benchmark tools:

- **IOR** (Interleaved-Or-Random) - Parallel file I/O operations
  - `ior-easy` - Basic sequential read/write with small block sizes
  - `ior-hard` - Demanding workload with striped access patterns and metadata operations

- **MDtest** - Metadata operation benchmarking
  - `mdtest-easy` - Basic file creation/deletion operations
  - `mdtest-hard` - Complex metadata operations with file trees

- **pfind** - File discovery benchmark for directory traversal

**Benchmark Execution**:
The `io500` command-line tool orchestrates all test phases in sequence, producing a composite score based on bandwidth and IOPS metrics. The suite is designed for:
- Distributed file system performance testing
- HPC storage evaluation  
- MLCommons Storage workload patterns
- Reproducible, standardized benchmarking
- Multi-process/node coordination via MPI

## Directory Contents

- **io500-mpi-coordinate-gemini-GCP.sh** - Distributed test coordination script for Google Cloud
- **drop-cache-GCP.sh** - Cache clearing utility for consistent benchmarking
- **IOR-MDtest-full.ini** - Sample IO500 configuration for metadata-focused testing (deprecated - use official configs)

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

### 1. IO500 Configuration (.ini files)

IO500 uses INI-format configuration files to define all test parameters. The executable `io500` coordinates the execution of IOR, MDtest, and pfind according to the configuration.

**Phases defined in configuration**:
- **ior-easy-write** - Large sequential write operations
- **mdtest-easy-write** - Simple file creation operations  
- **ior-hard-write** - Striped/random write patterns
- **mdtest-hard-write** - Complex file tree creation
- **find** - Directory traversal and file discovery
- **ior-easy-read** - Sequential read operations (validates written data)
- **mdtest-easy-stat** - File metadata queries
- **ior-hard-read** - Striped/random read patterns
- **mdtest-hard-stat** - Complex tree traversal with stat operations
- **mdtest-easy-delete** - Simple file deletion
- **mdtest-hard-delete** - Complex tree deletion

**IOR Test Specifications** (from official IO500):
- **ior-easy**: Sequential I/O with large transfers (MB/s focused)
  - Transfer size: 2MB
  - Block size: 2MB per process
  - Pattern: Sequential read/write
  - Focus: Bandwidth measurement

- **ior-hard**: Complex I/O with small transfers (random access)
  - Transfer size: 47KB
  - Block size: 47KB per process with striping
  - Pattern: Strided random access
  - Focus: IOPS and latency

**MDtest Specifications**:
- **mdtest-easy**: Basic metadata operations
  - File operations per process: 1,000,000
  - Single directory per process
  - Metrics: Operations per second (kIOPS)

- **mdtest-hard**: Complex metadata workloads
  - File operations per process: 1,000,000
  - Complex tree structures with multiple directories
  - Mixed operations: create, stat, read, delete
  - Metrics: Operations per second (kIOPS)

### 2. hosts.txt - Client Host List

Text file with one hostname per line (order matters for MPI process mapping):

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
- Hostnames must be resolvable from launcher VM via SSH
- Order determines MPI rank and process distribution
- All hosts must have network connectivity to launcher
- All hosts must have access to shared file system mount

### 3. Platform-Specific Coordination Script

**io500-mpi-coordinate-gemini-GCP.sh** - For Google Cloud infrastructure
- Configures SSH access to Google Compute Engine instances
- Sets up MPI environment for distributed GCP execution
- Edit to include your GCP username, SSH key path, instance names
- Configure shared file system mount points
- Output directory for results

**drop-cache-GCP.sh** - Cache clearing utility
- Synchronizes cache clearing across all client nodes
- Used between test phases for consistent cold-cache conditions
- Critical for reproducible benchmark results

## Running IO500 Benchmarks

### Step 1: Prepare Configuration Files

Ensure three files are in place:
- `io500.ini` - Use the included **IOR-MDtest-full.ini** file from this directory
- `hosts.txt` with client VM hostnames
- `io500-mpi-coordinate-gemini-GCP.sh` coordination script

**Use the included configuration file**:
```bash
# Copy the included IO500 configuration file
cp IOR-MDtest-full.ini io500.ini

# Review the configuration parameters
cat io500.ini

# Edit if needed for your specific test requirements
vim io500.ini
```

The included `IOR-MDtest-full.ini` provides a comprehensive metadata-focused benchmark configuration. Modify test parameters (file counts, block sizes, process counts) as needed for your specific testing scenario.

### Step 2: Edit Coordination Script

Edit the coordination script with your environment:

```bash
vim io500-mpi-coordinate-gemini-GCP.sh
```

Replace placeholders with your actual values:
- SSH username for remote VMs
- Path to SSH/PEM key file
- Client VM hostnames (must match hosts.txt)
- Configuration file path (io500.ini)
- Output directory for results

### Step 3: Execute Coordination Script

From the **launcher VM**, run the coordination script:

```bash
bash io500-mpi-coordinate-gemini-GCP.sh
```

**What the script does**:
1. Reads hostnames from `hosts.txt` file
2. Validates io500.ini configuration
3. Distributes configuration to all client VMs via SSH
4. Verifies connectivity with all clients
5. Generates and outputs the MPI command to execute

**Output example**:
The script reads `hosts.txt` and generates a command that references it:
```bash
# Script outputs a command like:
mpiexec -f hosts.txt -np 8 ./io500 io500.ini
```

The `-f hosts.txt` flag tells MPI to read the list of available nodes from the `hosts.txt` file you created, rather than specifying hosts on the command line.

### Step 4: Run the IO500 Benchmark

Execute the exact MPI command output by the coordination script from Step 3:

```bash
# This is an EXAMPLE - your actual command will be provided by Step 3
# The command will be similar to:
mpiexec -f hosts.txt -np 8 ./io500 io500.ini
```

**Important**: Do not manually type the command shown above. Copy the exact command output by Step 3. The coordination script generates the proper command based on your specific setup (number of hosts, configuration paths, etc.).

This command:
- Uses the `hosts.txt` file to specify which nodes participate in the benchmark
- Launches IO500 across all client nodes listed in hosts.txt via MPI
- Executes all test phases in sequence (write, read, metadata operations)
- Produces real-time progress output on the launcher VM
- Generates result files (result_summary.txt, result.txt) in the configured output directory

**Expected execution time**: 30 minutes to several hours depending on:
- File system performance
- Data set size configured in io500.ini
- Number of client nodes in hosts.txt
- Storage capacity

### Step 5: Monitor Execution and Drop Caches

While IO500 executes, monitor the output for phase transitions. When write phases complete, drop file system caches in a **separate terminal** on the launcher VM.

IO500 executes test phases sequentially:

1. **Write Phases**
   - `ior-easy-write` - Large sequential writes
   - `mdtest-easy-write` - File creation operations
   - `ior-hard-write` - Strided/random writes
   - `mdtest-hard-write` - Complex tree creation

2. **Intermediate Phase**
   - `find` - Directory traversal benchmark

3. **Read Phases**
   - `ior-easy-read` - Sequential reads (validates write data)
   - `mdtest-easy-stat` - Metadata queries on written files
   - `ior-hard-read` - Strided/random reads
   - `mdtest-hard-stat` - Complex tree stat operations
   - `mdtest-easy-delete` - File deletion operations
   - `mdtest-hard-delete` - Complex tree deletion

**Critical for accurate results**: Drop file system caches between write and read phases.

#### Cache Dropping Timing

Approximately 5-10 second window:

```bash
# In a SEPARATE terminal on the launcher VM
# Monitor IO500 output in first terminal
# When write phases complete, immediately run:

bash drop-cache-GCP.sh
```

**What `drop-cache-GCP.sh` does**:
- SSHes to each client VM in sequence
- Executes `sync && echo 3 > /proc/sys/vm/drop_caches`
- Drops OS-level page cache (not application buffers)
- Completes in ~5-10 seconds for 8 VMs

**Why cache dropping matters**:
- Read phases require cold cache for accurate storage performance measurement
- Without cache dropping, reads may show cached performance rather than actual storage capability
- Required for reproducible, standardized benchmark results per IO500 specification
- Ensures fair comparison across different storage systems

**Timing examples**:
- ❌ Too early (during write phases): Interferes with write measurements
- ❌ Too late (read phase started): Reads show cached performance instead of storage performance
- ✅ Correct: 2-3 seconds after all write phases complete, before first read phase begins (~5-10 second window)

### Step 6: Collect and Analyze Results

After IO500 completes, results are available in multiple formats:

**Console output**: Real-time execution progress with phase names and timing

**result_summary.txt**: Quick reference with key metrics
```
[RESULT]       ior-easy-write        X.XXX GiB/s
[RESULT]    mdtest-easy-write      XXX.X kIOPS
[RESULT]       ior-hard-write        X.XXX GiB/s
[RESULT]    mdtest-hard-write       XX.X kIOPS
[RESULT]                 find     XXXX.X kIOPS
[RESULT]        ior-easy-read        X.XXX GiB/s
[RESULT]     mdtest-easy-stat      XXX.X kIOPS
[RESULT]        ior-hard-read        X.XXX GiB/s
[RESULT]     mdtest-hard-stat      XXX.X kIOPS
[RESULT]   mdtest-easy-delete      XXX.X kIOPS
[RESULT]     mdtest-hard-read      XXX.X kIOPS
[RESULT]   mdtest-hard-delete      XXX.X kIOPS
[SCORE] Bandwidth X.XXX GB/s : IOPS XXX.X kiops : TOTAL X.XXX
```

**result.txt**: Complete INI-format results with detailed metrics
- Execution times for each phase
- Per-command execution details
- Configuration parameters used
- Final composite score (Bandwidth × IOPS × Total)

**Validation**: Verify results integrity
```bash
# Using full-featured io500
./io500 config-used.ini --verify result.txt

# Using lightweight verification tool
./io500-verify config-used.ini result.txt
```

**Key Metrics to Review**:

1. **Bandwidth Scores** (GiB/s):
   - ior-easy-write/read: Sequential I/O performance
   - ior-hard-write/read: Random/strided I/O performance

2. **IOPS Scores** (operations per second):
   - mdtest-easy: Basic metadata operation rate
   - mdtest-hard: Complex metadata workload rate
   - find: Directory traversal performance

3. **Composite Score**:
   - Combines bandwidth and IOPS into single comparable metric
   - [VALID] - Meets IO500 compliance requirements
   - [INVALID] - Configuration or runtime violation detected

## Simple Single-Host IO500 Test

For basic testing without distributed coordination:

```bash
# Pull container with io500 and dependencies
docker pull quay.io/russfellows-sig65/io500

# Generate test configuration
docker run -it quay.io/russfellows-sig65/io500 \
  io500 --list > local-test-config.ini

# Edit config for your test parameters
vim local-test-config.ini

# Run IO500 with configuration
docker run -it -v /mount/point:/testdir \
  quay.io/russfellows-sig65/io500 \
  bash -c "cd /testdir && mpiexec -np 2 ./io500 local-test-config.ini"
```

**Note**: Single-node execution bypasses distributed MPI coordination. Use coordination scripts for multi-host benchmarks to utilize full testing capabilities.

## Alternative: Bare Metal Execution

To run IO500 directly on VMs instead of containers:

1. **Build and install io500** on launcher VM:
   ```bash
   git clone https://github.com/IO500/io500.git
   cd io500
   ./prepare.sh  # Downloads and builds IOR, MDtest, pfind
   make
   ```

2. **Install MPI and required tools** on all client VMs:
   ```bash
   # Ubuntu/Debian
   apt-get install openmpi-bin libopenmpi-dev openssh-server
   
   # CentOS/RHEL
   yum install openmpi openmpi-devel openssh-server
   ```

3. **Build io500 dependencies** on each client VM:
   ```bash
   cd io500 && ./prepare.sh && make
   ```

4. **Use same configuration and coordination approach**:
   - `io500.ini` configuration files remain identical
   - Modify coordination scripts to use `mpiexec` instead of Docker commands
   - Ensure all VMs have shared file system access (Lustre, NFS, etc.)

5. **Execute identically**:
   ```bash
   # From launcher VM with MPI installed
   mpiexec -hosts client-1,client-2,...,client-8 \
     ./io500 io500.ini
   ```

**Advantages of bare metal**:
- Avoid containerization overhead
- Direct access to file system optimizations
- Simpler debugging and profiling
- More control over MPI configuration

**Disadvantages**:
- More complex setup and maintenance
- Requires pre-installation on all nodes
- Harder to reproduce across different environments

## Documentation and References

### Official IO500 Resources

- **IO500 Benchmark Official**: [io500.io](https://io500.io) / [github.com/IO500/io500](https://github.com/IO500/io500)
  - Official benchmark results and rankings
  - Test tier specifications and scoring methodology
  - MLCommons Storage compliance requirements
  - Configuration templates and examples

- **IOR Component** (used by IO500 for I/O benchmarking):
  - [github.com/hpc/ior](https://github.com/hpc/ior) - Source code and releases
  - [IOR Wiki](https://github.com/hpc/ior/wiki) - Configuration examples and parameter reference
  - IOR Manual Pages available in container:
    ```bash
    docker run -it quay.io/russfellows-sig65/io500 man ior
    ```

- **MDtest Component** (used by IO500 for metadata benchmarking):
  - Part of IOR package, focuses on file creation/deletion operations
  - Tests both simple and complex metadata workloads
  - Available via `mdtest` command in container

- **pfind Component** (used by IO500 for directory traversal):
  - Directory discovery and file finding benchmark
  - Part of comprehensive IO500 scoring

- **Reference Documentation**:
  - Argonne National Laboratory HPC resources for IOR
  - POSIX, MPI-IO, parallel file system patterns
  - Performance tuning and scaling best practices

## IO500 Configuration File Format

IO500 configuration files (io500.ini) are INI-style with parameters for coordinating all three benchmarks:

**IOR-specific parameters**:
- **fs**: File system type (POSIX, HDF5, NetCDF, MPI-IO, etc.)
- **nodes**: Number of MPI processes
- **blockSize**: Size of data block per process
- **transferSize**: Size of each I/O transfer
- **repetitions**: Number of test repetitions

**MDtest-specific parameters**:
- File creation/deletion patterns
- Directory structure complexity
- Metadata operation counts

**Test phase parameters**:
- Specifies which tests to run (ior-easy, ior-hard, mdtest-easy, mdtest-hard, find)
- Defines cache dropping between phases
- Sets result collection and validation rules

## Related Documentation

- Main repository: [../../README.md](../../README.md)
- File system testing overview: [../README.md](../README.md)
- vdbench testing: [../vdbench-scripts/README.md](../vdbench-scripts/README.md)
- Container registry: https://quay.io/repository/russfellows-sig65/io500

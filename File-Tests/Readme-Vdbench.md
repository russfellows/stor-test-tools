# File System Testing with vdbench and IOR

This directory contains configuration files for testing file systems using **vdbench** and **IOR**, two complementary file system benchmarking tools.

## Containers

### IOR Container
**Image**: `quay.io/russfellows-sig65/io500`

Contains:
- **IOR** - Parallel file I/O benchmark with MLCommons Storage support
- **IO500 tools** - Comprehensive benchmarking suite
- MPI and distributed testing infrastructure
- Various file system testing utilities

### vdbench Container
**Image**: `quay.io/russfellows-sig65/file-tests`

Contains:
- **vdbench** - File system workload generator
- **fio** - Flexible I/O workload simulator
- Various file system testing utilities

Pull the containers:
```bash
docker pull quay.io/russfellows-sig65/io500       # For IOR
docker pull quay.io/russfellows-sig65/file-tests  # For vdbench
```

## vdbench Overview

vdbench is a comprehensive file system workload generator implementing MLCommons Storage workload specifications. It provides:

- **Flexible Workload Definition**
  - Multiple file types and sizes
  - Sequential and random access patterns
  - Realistic I/O distributions
  - Customizable operation mix (read/write/metadata)

- **Multi-Threading and Distribution**
  - Single-threaded and multi-threaded operation
  - Multi-host distributed execution
  - Per-thread performance tracking

- **Detailed Performance Analysis**
  - Throughput (ops/sec, MB/sec)
  - Latency statistics (average, percentiles)
  - Per-file and per-operation metrics
  - Response time distributions

- **AI/ML Workload Simulation**
  - ResNet50 training patterns
  - UNet3D volumetric processing patterns
  - Complex mixed workloads

## IOR Overview

IOR (Interleaved-Or-Random) is a parallel file I/O benchmark that implements MLCommons Storage workload specifications. It is designed for:

- **HPC Storage Testing**
  - Distributed file system performance
  - Parallel I/O pattern evaluation
  - Scalability testing

- **Multiple I/O Patterns**
  - Sequential reads/writes
  - Random access patterns
  - Strided access patterns
  - Metadata operations

- **Comprehensive Metrics**
  - Aggregate throughput across all processes
  - Per-process performance
  - Latency distributions
  - Metadata operation times

## Configuration Structure

### vdbench Configurations

Located in `vdbench-scripts/`:

```
vdbench-scripts/
├── Resnet50/
│   ├── resnet50-1hosts_parmfile.txt
│   ├── resnet50-4hosts_parmfile.txt
│   └── resnet50-8hosts_parmfile.txt
└── Unet3d/
    ├── unet3d-1hosts_parmfile.txt
    ├── unet3d-4hosts_parmfile.txt
    └── unet3d-8hosts_parmfile.txt
```

**File naming convention**: `{workload}-{num_hosts}_parmfile.txt`

### IOR Configurations

Located in `IOR-scripts/`:

- **IOR-MDtest-full.ini** - Metadata-focused testing
- **io500-mpi-coordinate-gemini-AWS.sh** - AWS infrastructure coordination
- **io500-mpi-coordinate-gemini-GCP.sh** - Google Cloud coordination
- **drop-cache-GCP.sh** - Cache management utility

## Workload Patterns

### ResNet50
Simulates ResNet50 CNN deep learning training I/O patterns:
- **Use case**: Image classification model training
- **Data access**: Batch-sequential with periodic random access
- **Typical characteristics**: 
  - Large file reads (ImageNet batches)
  - Sequential prefetching
  - Metadata-light operations
- **Available**: 1-host, 4-host, 8-host configurations

### UNet3D
Simulates 3D UNet segmentation model training I/O patterns:
- **Use case**: Medical imaging, volumetric data processing
- **Data access**: 3D volume chunks with spatial locality
- **Typical characteristics**:
  - Random access within volumes
  - Mixed read/write (gradient updates)
  - Higher metadata overhead
- **Available**: 1-host, 4-host, 8-host configurations

## Running vdbench Tests

### Prerequisites
- Docker or container runtime
- File system mount point (local or network)
- For multi-host tests: multiple test hosts with shared or synchronized storage

### Single-Host Test Example

```bash
# Pull the container
docker pull quay.io/russfellows-sig65/file-tests

# Run vdbench with ResNet50 1-host configuration
docker run -it -v /test/mount:/testdir \
  quay.io/russfellows-sig65/file-tests \
  vdbench -f resnet50-1hosts_parmfile.txt -o /testdir/output
```

### Multi-Host Distributed Test

For distributed testing, vdbench coordinates execution across multiple hosts:

1. **Prepare test hosts** with shared storage access
2. **Run coordinator** (on primary test host):
   ```bash
   docker run -it \
     -e VDBENCH_HOSTS="host1,host2,host3,host4" \
     -v /test/mount:/testdir \
     quay.io/russfellows-sig65/file-tests \
     vdbench -f resnet50-4hosts_parmfile.txt -o /testdir/output
   ```

## Running IOR Tests

### Prerequisites
- Docker or container runtime
- File system mount point
- For distributed tests: MPI infrastructure and multiple test nodes

### Basic IOR Test

```bash
# Pull the container
docker pull quay.io/russfellows-sig65/io500

# Run IOR with metadata testing configuration
docker run -it -v /test/mount:/testdir \
  quay.io/russfellows-sig65/io500 \
  ior -f IOR-MDtest-full.ini -o /testdir/
```

### Distributed IOR Test (IO500)

```bash
# Run IO500 benchmark on AWS infrastructure
docker run -it \
  -e AWS_REGION=us-west-2 \
  -e AWS_HOSTS="10.0.1.1,10.0.1.2,10.0.1.3,10.0.1.4" \
  quay.io/russfellows-sig65/io500 \
  bash io500-mpi-coordinate-gemini-AWS.sh
```

## Configuration File Formats

### vdbench Parameter Files (.txt)
Text-based format with sections:
- **RD** (Run Definition): Defines one or more workload phases
- **FSD** (File System Definition): File types, sizes, directory structure
- **FWD** (File Work Definition): I/O operations and patterns
- **Performance parameters**: Threads, duration, interval settings

### IOR Configuration Files (.ini)
INI format with sections defining:
- File system type (POSIX, HDF5, NetCDF, etc.)
- Number of processes/threads
- File sizes and access patterns
- Test duration and iteration counts

## Output and Analysis

### vdbench Output
- **Real-time metrics**: Throughput (ops/sec, MB/sec), latency
- **Summary reports**: Aggregate performance across test duration
- **Detailed logs**: Per-operation timing and statistics
- **Charts/graphs**: Performance visualization (if enabled)

### IOR Output
- **Aggregate throughput**: Total MB/sec across all processes
- **Per-process metrics**: Individual process performance
- **Consistency metrics**: Write/read verification results
- **Latency distributions**: Operation response time analysis

## Troubleshooting

### Mount Issues
- Verify file system is mounted before starting container
- Check container user has read/write permissions
- For NFS mounts, verify NFS service is running

### Performance Issues
- Check network connectivity (for distributed tests)
- Monitor file system cache behavior
- Verify storage backend is not bottlenecked
- Check CPU and memory utilization

### Configuration Errors
- Validate parameter file syntax
- Ensure referenced paths exist
- Check host name resolution (for distributed tests)

## Performance Tuning

### For Better Cache Utilization
- Reduce test data size relative to system memory
- Enable read-ahead on file systems
- Adjust buffer sizes in configuration

### For Consistency
- Use `drop-cache-GCP.sh` to clear caches between runs
- Run multiple iterations to warm up storage
- Synchronize clocks across distributed test hosts

## Related Documentation

- Main repository: [../README.md](../README.md)
- Object storage tests: [../Object-Tests/](../Object-Tests/)
- vdbench manual: https://www.oracle.com/downloads/cloud/open-source/vdbench/
- IOR documentation: https://github.com/hpc/ior

## Container Registries

- vdbench: https://quay.io/repository/russfellows-sig65/file-tests
- IOR: https://quay.io/repository/russfellows-sig65/io500

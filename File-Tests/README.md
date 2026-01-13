# File System Testing

This directory contains configuration files for testing file systems using **IOR** and **vdbench**, two industry-standard file system benchmarking tools.

## Testing Tools

### IOR - Parallel File I/O Benchmark
**Container**: `quay.io/russfellows-sig65/io500`

IOR (Interleaved-Or-Random) is a widely used parallel file I/O benchmark for:
- Distributed file system performance testing
- HPC (High-Performance Computing) storage evaluation
- Various I/O patterns: sequential, random, strided
- Metadata operation testing
- Both POSIX and HPC-specific file systems

### vdbench - File System Workload Generator
**Container**: `quay.io/russfellows-sig65/file-tests`

vdbench is a flexible file system workload simulator for:
- Realistic file system workload definition
- Single and multi-threaded operation
- Complex workloads with multiple file types
- Detailed performance analysis and statistics
- Reproducible workload execution

**Additional tools in this container**:
- **fio** - Flexible I/O workload simulator
- Various other file system testing utilities

## Directory Structure

```
File-Tests/
├── IOR-scripts/
│   ├── IOR-MDtest-full.ini
│   ├── drop-cache-GCP.sh
│   ├── io500-mpi-coordinate-gemini-AWS.sh
│   └── io500-mpi-coordinate-gemini-GCP.sh
├── vdbench-scripts/
│   ├── Resnet50/
│   │   ├── resnet50-1hosts_parmfile.txt
│   │   ├── resnet50-4hosts_parmfile.txt
│   │   └── resnet50-8hosts_parmfile.txt
│   └── Unet3d/
│       ├── unet3d-1hosts_parmfile.txt
│       ├── unet3d-4hosts_parmfile.txt
│       └── unet3d-8hosts_parmfile.txt
└── [README files documenting each tool]
```

## Test Configurations

### IOR Configurations

Located in `IOR-scripts/`:

- **IOR-MDtest-full.ini** - Comprehensive metadata testing configuration
- **io500-mpi-coordinate-gemini-AWS.sh** - IO500 benchmark coordination for AWS infrastructure
- **io500-mpi-coordinate-gemini-GCP.sh** - IO500 benchmark coordination for Google Cloud
- **drop-cache-GCP.sh** - Cache dropping utility for consistent GCP testing

### vdbench Configurations

Located in `vdbench-scripts/`, organized by AI/ML workload:

#### ResNet50 Workload
Simulates ResNet50 deep learning training I/O patterns:
- `resnet50-1hosts_parmfile.txt` - Single-host configuration
- `resnet50-4hosts_parmfile.txt` - 4-host distributed configuration
- `resnet50-8hosts_parmfile.txt` - 8-host distributed configuration

#### UNet3D Workload
Simulates 3D UNet segmentation model training I/O patterns:
- `unet3d-1hosts_parmfile.txt` - Single-host configuration
- `unet3d-4hosts_parmfile.txt` - 4-host distributed configuration
- `unet3d-8hosts_parmfile.txt` - 8-host distributed configuration

## Running Tests

### Prerequisites
- Docker or container runtime
- File system mount point
- Network connectivity (for distributed tests)
- Sufficient disk space for test data

### IOR Test Example

```bash
# Pull the container
docker pull quay.io/russfellows-sig65/io500

# Run IOR test with configuration
docker run -it -v /mount/point:/testdir \
  quay.io/russfellows-sig65/io500 \
  ior -f IOR-MDtest-full.ini
```

### vdbench Test Example

```bash
# Pull the container
docker pull quay.io/russfellows-sig65/file-tests

# Run vdbench with ResNet50 1-host configuration
docker run -it -v /mount/point:/testdir \
  quay.io/russfellows-sig65/file-tests \
  vdbench -f resnet50-1hosts_parmfile.txt
```

## Detailed Documentation

For detailed information on each tool:
- **IOR**: See [Readme-Vdbench.md](Readme-Vdbench.md) or the IOR-scripts/ directory
- **vdbench**: See [Readme-Vdbench.md](Readme-Vdbench.md)

## Container Images

| Tool | Container | Repository |
|------|-----------|-----------|
| IOR | `quay.io/russfellows-sig65/io500` | https://quay.io/repository/russfellows-sig65/io500 |
| vdbench | `quay.io/russfellows-sig65/file-tests` | https://quay.io/repository/russfellows-sig65/file-tests |

## Workload Patterns

### ResNet50 (MLCommons Storage)
Configurations implementing MLCommons Storage ResNet50 benchmark:
- Replicates CNN training I/O patterns from MLCommons specification
- 1-client, 4-client, 8-client configurations
- Sequential and random access patterns
- Multi-client distributed configurations available

### UNet3D (MLCommons Storage)
Configurations implementing MLCommons Storage UNet3D benchmark:
- Replicates volumetric segmentation I/O patterns from MLCommons specification
- 1-client, 4-client, 8-client configurations
- 3D volume chunk access patterns
- Medical imaging and scientific computing workload patterns

## Troubleshooting

- **Mount issues**: Ensure file system is mounted and accessible from container
- **Permission errors**: Check container user permissions for target mount point
- **Timeout errors**: Increase test duration in configuration for slow storage
- **Distributed coordination**: Verify network connectivity between test hosts

## Related Resources

- Main repository: [../README.md](../README.md)
- Container registries: https://quay.io/

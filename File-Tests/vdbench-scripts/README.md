# vdbench Configuration Scripts

Configuration files for file system benchmarking with **vdbench**.

## Directory Structure

```
vdbench-scripts/
├── Resnet50/           - ResNet50 CNN training workload patterns
└── Unet3d/             - 3D UNet segmentation workload patterns
```

## Workload Patterns

### Resnet50
ResNet50 deep learning model training workload patterns:
- **Files**:
  - `resnet50-1hosts_parmfile.txt` - Single-host configuration
  - `resnet50-4hosts_parmfile.txt` - 4-host distributed configuration
  - `resnet50-8hosts_parmfile.txt` - 8-host distributed configuration

### Unet3d
3D UNet segmentation model workload patterns:
- **Files**:
  - `unet3d-1hosts_parmfile.txt` - Single-host configuration
  - `unet3d-4hosts_parmfile.txt` - 4-host distributed configuration
  - `unet3d-8hosts_parmfile.txt` - 8-host distributed configuration

## Configuration Details

### File Naming Convention

- `{workload}-{num_hosts}hosts_parmfile.txt`
  - `{workload}`: resnet50, unet3d
  - `{num_hosts}`: 1, 4, or 8

### Workload Characteristics

**ResNet50**
- Simulates ImageNet training I/O patterns
- Large sequential reads (image batches)
- Low metadata operation rate
- Typical for CNN training benchmarking

**UNet3D**
- Simulates volumetric data processing
- Random and sequential access mixed
- Higher metadata operation rates
- Typical for medical imaging and scientific computing

## vdbench Parameter Files

vdbench configurations use parameter files (.txt) with sections:

- **RD (Run Definition)**: Defines one or more workload phases
- **FSD (File System Definition)**: File types, sizes, and directory structure
- **FWD (File Work Definition)**: I/O operations (read, write, delete, mkdir, etc.)
- **Performance settings**: Thread counts, test duration, reporting intervals

## Usage

For detailed instructions on running these tests, see [../Readme-Vdbench.md](../Readme-Vdbench.md)

### Basic Example

```bash
docker run -it -v /test/mount:/testdir \
  quay.io/russfellows-sig65/file-tests \
  vdbench -f vdbench-scripts/Resnet50/resnet50-1hosts_parmfile.txt \
  -o /testdir/output
```

### Multi-Host Execution

For distributed testing across multiple hosts, vdbench requires:
1. Shared storage accessible from all hosts
2. Network connectivity between hosts
3. vdbench slave processes on each remote host

## Container

**Image**: `quay.io/russfellows-sig65/file-tests`

Contains vdbench, fio, and related file system testing tools.

See parent directory documentation for more details.

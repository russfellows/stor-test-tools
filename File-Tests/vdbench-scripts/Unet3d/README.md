# UNet3D Workload Configurations

Configuration files for benchmarking **3D UNet segmentation model workload patterns** with vdbench.

## Workload Overview

UNet3D is a 3D convolutional neural network architecture for volumetric image segmentation. These configurations simulate the file system I/O patterns typical of UNet3D training:

- **Data Access Pattern**: Random and sequential access of 3D volume files
- **Typical Use Case**: Medical image segmentation (CT, MRI scans), scientific computing
- **Data Type**: 3D volume files, segmentation masks, model weights
- **I/O Characteristics**:
  - Mixed random and sequential file access
  - Moderate to large file sizes (volume chunks)
  - Frequent read-write patterns (training with gradient updates)
  - Moderate metadata operation rate

## Configuration Files

### Single-Host Configuration

**unet3d-1hosts_parmfile.txt**
- Single-host vdbench workload definition
- Simulates volumetric data processing on single machine
- Use when: Baseline single-node medical imaging workload

### 4-Host Distributed Configuration

**unet3d-4hosts_parmfile.txt**
- Distributed vdbench configuration for 4 hosts
- Coordinates file I/O across 4 test nodes
- Each host processes portions of volumetric dataset
- Use when: Testing multi-node medical imaging research setup

### 8-Host Distributed Configuration

**unet3d-8hosts_parmfile.txt**
- Distributed vdbench configuration for 8 hosts
- Coordinates file I/O across 8 test nodes
- Use when: Testing large-scale volumetric data processing cluster

## vdbench Parameter File Structure

These parameter files define:

- **RD (Run Definition)**: Workload phases and parameters
- **FSD (File System Definition)**: Volume file layout, sizes, directory structure
- **FWD (File Work Definition)**: I/O operations (random/sequential reads, writes for gradients)
- **Performance settings**: Thread counts, test duration, report intervals

## Typical I/O Characteristics

- **File sizes**: Large (volume chunks, 100s MB to GB typical)
- **Access pattern**: Mixed random and sequential with spatial locality
- **Operation mix**: Balanced read/write (50% read, 50% write for training)
- **Throughput target**: 1-5 GB/sec on modern file systems
- **Metadata operations**: File creation/deletion, directory operations

## Differences from ResNet50

| Aspect | ResNet50 | UNet3D |
|---|---|---|
| Access pattern | Sequential batches | Random + sequential volumes |
| Typical file size | Medium (batch) | Large (3D chunk) |
| Read/Write ratio | 9:1 (heavy reads) | 5:5 (balanced) |
| Latency sensitivity | Throughput-critical | Both throughput and latency |
| Metadata load | Light | Moderate |
| Use case | Image classification | Volumetric segmentation |

## Usage Examples

### Single-Host Test

```bash
docker run -it -v /medical/storage:/testdir \
  quay.io/russfellows-sig65/file-tests \
  vdbench -f unet3d-1hosts_parmfile.txt -o /testdir/results
```

### 4-Host Distributed Test

```bash
# Assumes shared storage (NFS, GPFS) mounted on all hosts
docker run -it \
  -e VDBENCH_HOSTS="medical-1,medical-2,medical-3,medical-4" \
  -v /medical/storage:/testdir \
  quay.io/russfellows-sig65/file-tests \
  vdbench -f unet3d-4hosts_parmfile.txt -o /testdir/results
```

### 8-Host Large-Scale Volumetric Processing

```bash
# Simulates research cluster processing volumetric datasets
docker run -it \
  -e VDBENCH_HOSTS="research-1,research-2,research-3,research-4,research-5,research-6,research-7,research-8" \
  -v /research/data:/testdir \
  quay.io/russfellows-sig65/file-tests \
  vdbench -f unet3d-8hosts_parmfile.txt -o /testdir/results
```

## Performance Expectations

Typical throughput:
- **Single-host**: 200 MB/sec - 1 GB/sec (lower due to random access component)
- **4-host**: 800 MB/sec - 4 GB/sec (less perfect scaling than sequential workloads)
- **8-host**: 1.5-8 GB/sec (depends on storage latency characteristics)

Latency:
- **Random read latency**: 10-100ms typical (file system dependent)
- **Write latency**: 20-200ms typical (must persist gradient updates)
- **File operations**: 1-10ms typical

## Configuration Considerations

### For Medical Imaging Workloads

- **CT/MRI data**: Configure for 512x512x300+ voxel volumes
- **3D reconstruction**: Match typical slice access patterns
- **Segmentation masks**: Include smaller overlay file operations
- **GPU memory sync**: Account for periodic synchronization I/O

### For Scientific Computing

- **Simulation data**: Large volumetric checkpoint files
- **Temporal series**: Sequential time-step access patterns
- **Parallel I/O**: Coordinate between multiple processors
- **Checkpointing**: Include periodic large write operations

### Performance Tuning

- **Random access overhead**: Use larger file sizes to reduce relative overhead
- **Write buffering**: Enable write-back caching for gradient updates
- **Spatial locality**: Configure access patterns for cache efficiency
- **Thread count**: Balance parallelism with storage latency

## File System Recommendations

**Best for NFS**: Medical research with network-attached imaging storage

**Best for Parallel File Systems**: HPC environments (LUSTRE, GPFS) for scientific computing

**Best for Object Storage**: Cloud-based medical imaging with S3 FUSE mounts

## Comparing Access Patterns

### Spatial Locality
UNet3D preserves spatial locality better than random:
- Slice access within volumes follows Z-axis
- Neighboring voxels accessed in sequence
- Caching benefits from this pattern

### Burst Size
Larger bursts than ResNet50:
- Volume chunks larger than image batches
- Fewer but larger I/O operations
- Better network utilization

## Related Configurations

- **ResNet50**: Sequential read-heavy workload (see Resnet50/ directory)
- **Object storage**: UNet3D pattern available with sai3-bench
- **IOR tests**: Parallel I/O benchmarking (see IOR-scripts/ directory)

## Container

**Image**: `quay.io/russfellows-sig65/file-tests`

Contains vdbench, fio, and related file system benchmarking tools.

See parent documentation for container details.

## Use Case Resources

- **Medical Imaging**: MONAI framework, TorchVision medical datasets
- **Scientific Computing**: HDF5 volumetric data format
- **3D Segmentation**: UNet original paper and implementations

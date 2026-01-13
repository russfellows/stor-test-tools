# ResNet50 Workload Configurations

Configuration files for benchmarking **ResNet50 CNN training workload patterns** with vdbench.

## Workload Overview

ResNet50 is a deep residual learning convolutional neural network with 50 layers. These configurations simulate the file system I/O patterns typical of ResNet50 training:

- **Data Access Pattern**: Sequential batch reading from files
- **Typical Use Case**: ImageNet-scale image classification training
- **Data Type**: Image batches stored as files (or file sets)
- **I/O Characteristics**:
  - Large sequential reads (batches of images)
  - Prefetching patterns
  - Checkpointing writes (periodic model snapshots)
  - Relatively metadata-light operations

## Configuration Files

### Single-Host Configuration

**resnet50-1hosts_parmfile.txt**
- Single-host vdbench workload definition
- Simulates training data loading on single machine
- Use when: Baseline single-node performance measurement

### 4-Host Distributed Configuration

**resnet50-4hosts_parmfile.txt**
- Distributed vdbench configuration for 4 hosts
- Coordinates file I/O across 4 test nodes
- Each host simulates part of multi-GPU training setup
- Use when: Testing shared storage performance with multiple trainers

### 8-Host Distributed Configuration

**resnet50-8hosts_parmfile.txt**
- Distributed vdbench configuration for 8 hosts
- Coordinates file I/O across 8 test nodes
- Use when: Testing large-scale multi-node training setup

## vdbench Parameter File Structure

These parameter files define:

- **RD (Run Definition)**: Workload phases and parameters
- **FSD (File System Definition)**: File layout, sizes, directory structure
- **FWD (File Work Definition)**: I/O operations (sequential reads, checkpoint writes)
- **Performance settings**: Thread counts, test duration, report intervals

## Typical I/O Characteristics

- **File sizes**: Medium to large (batch files, 100s MB typical)
- **Access pattern**: Sequential reading with prefetching simulation
- **Operation mix**: Predominantly reads (~90%), periodic writes (~10% checkpoints)
- **Throughput target**: Multi-GB/sec on modern file systems
- **Metadata operations**: Directory listing, file creation/deletion (minimal)

## Usage Examples

### Single-Host Test

```bash
docker run -it -v /training/storage:/testdir \
  quay.io/russfellows-sig65/file-tests \
  vdbench -f resnet50-1hosts_parmfile.txt -o /testdir/results
```

### 4-Host Distributed Test

```bash
# Assumes NFS or other shared storage mounted on all 4 hosts
docker run -it \
  -e VDBENCH_HOSTS="training1,training2,training3,training4" \
  -v /training/storage:/testdir \
  quay.io/russfellows-sig65/file-tests \
  vdbench -f resnet50-4hosts_parmfile.txt -o /testdir/results
```

### 8-Host Large-Scale Test

```bash
# Assumes cluster setup with 8 training nodes
docker run -it \
  -e VDBENCH_HOSTS="trainer-1,trainer-2,trainer-3,trainer-4,trainer-5,trainer-6,trainer-7,trainer-8" \
  -v /cluster/storage:/testdir \
  quay.io/russfellows-sig65/file-tests \
  vdbench -f resnet50-8hosts_parmfile.txt -o /testdir/results
```

## Performance Expectations

Typical throughput:
- **Single-host**: 500 MB/sec - 2 GB/sec (depends on network and file system)
- **4-host**: 2-8 GB/sec (scales with number of parallel readers)
- **8-host**: 4-16 GB/sec (good linear scaling typical for sequential workload)

Latency:
- **Read latency**: 5-50ms typical (file system dependent)
- **File open/close**: 1-10ms typical
- **Directory operations**: 1-5ms typical

## Configuration Tuning

### For Better Performance
- Increase thread count per host for more parallelism
- Use larger block sizes to reduce operation overhead
- Enable read-ahead on the file system
- Ensure sufficient network bandwidth

### For Realistic Training Simulation
- Match file sizes to actual training batch sizes
- Replicate directory structure of training frameworks (PyTorch, TensorFlow)
- Include checkpoint write patterns (periodic, medium-sized writes)

### For Consistency
- Run multiple iterations to warm up file system cache
- Clear caches between runs using `drop-cache-GCP.sh` or similar
- Record baseline with consistent system state

## File System Considerations

**Best for NFS**: Simulates network-attached training storage (common in cloud)

**Best for Parallel File Systems**: HPC environments (LUSTRE, GPFS)

**Best for Object Storage via FUSE**: S3 or Azure blob storage as file system

## Comparing with UNet3D

| Aspect | ResNet50 | UNet3D |
|---|---|---|
| Access pattern | Sequential | Random + Sequential |
| Typical file size | Medium (batch) | Large (volume chunks) |
| Read/Write ratio | 9:1 (reads heavy) | 5:5 (balanced) |
| Metadata ops | Light | Moderate |
| Use case | Image classification | Volumetric segmentation |

## Related Configurations

- **UNet3D**: Different workload pattern for volumetric data (see Unet3d/ directory)
- **Object storage**: Similar workload available with sai3-bench
- **IOR tests**: Parallel metadata testing (see IOR-scripts/ directory)

## Container

**Image**: `quay.io/russfellows-sig65/file-tests`

Contains vdbench, fio, and related file system benchmarking tools.

See parent documentation for container details.

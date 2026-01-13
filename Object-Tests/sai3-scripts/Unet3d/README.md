# UNet3D Workload Configurations

Configuration files for benchmarking **3D UNet segmentation model workload patterns** implementing the MLCommons Storage benchmark with sai3-bench.

## Workload Overview

UNet3D is a 3D convolutional neural network architecture for volumetric image segmentation. These configurations simulate the MLCommons Storage UNet3D I/O patterns typical of UNet3D training on object storage:

- **Data Access Pattern**: Random and sequential access of 3D volume chunks
- **Benchmark Specification**: MLCommons Storage UNet3D
- **Typical Use Case**: Medical image segmentation (CT, MRI scans), scientific computing
- **Data Type**: 3D volume slices, segmentation masks, model weights
- **I/O Characteristics**:
  - Mixed random and sequential access
  - Moderate to large object sizes (volume chunks)
  - Frequent read-write patterns (training gradients)
  - Higher metadata operation rate than CNN training

## Configuration Files

### Single-Client Configuration

**unet3d_1-client-prepare-get.yaml**
- Prepare phase: Uploads 3D volume chunks to object storage
- Get phase: Training simulation by reading/processing volumes
- Use when: Testing full workflow including data upload with single client

**unet3d_1-client-get-only.yaml**
- Get phase only: Assumes volumes already exist in storage
- Use when: Benchmarking read-only performance repeatedly
- More consistent baseline for performance comparisons

### 4-Client Distributed Configuration

**unet3d_4-client-prepare-get.yaml**
- Distributed preparation across 4 clients
- Each client prepares 1/4 of the volume dataset
- Followed by distributed read phase across all 4 clients
- Use when: Testing multi-client volumetric data processing per MLCommons spec

**unet3d_4-client-get-only.yaml**
- 4-client distributed read-only test
- Assumes data already prepared
- Useful for repeatable performance measurements across multiple clients

### 8-Client Distributed Configuration

**unet3d_8-client-prepare-get.yaml**
- Distributed preparation across 8 clients
- Each client prepares 1/8 of the volume dataset
- Followed by distributed read phase across all 8 clients
- Use when: Testing large-scale multi-client volumetric processing per MLCommons spec

**unet3d_8-client-get-only.yaml**
- 8-client distributed read-only test
- Baseline for consistent multi-client benchmarking

## Typical I/O Characteristics

- **Object sizes**: Medium to large (3D volume chunks, 50-500 MB typical)
- **Access pattern**: Mixed random and sequential, spatial locality
- **Operation mix**: Balanced read/write for training (gradient updates)
- **Throughput target**: Multi-GB/sec on modern storage
- **Latency sensitive**: Training dependent on both read and write I/O performance

## Differences from ResNet50

| Characteristic | ResNet50 | UNet3D |
|---|---|---|
| Access pattern | Primarily sequential | Mixed random/sequential |
| Object focus | Image batches (2D) | Volume chunks (3D) |
| Read/Write mix | Mostly reads | Balanced read/write |
| Metadata operations | Light | Moderate/Heavy |
| Network sensitivity | Throughput | Both throughput and latency |

## Usage Examples

### Single-Host with Prepare Phase

```bash
docker run -it quay.io/russfellows-sig65/sai3-tools sai3-bench run \
  --config unet3d_1-host-prepare-get.yaml \
  --endpoint s3.example.com:9000 \
  --bucket medical-data
```

### Single-Host Read-Only (Repeated Tests)

```bash
# Test 1: Baseline
docker run -it quay.io/russfellows-sig65/sai3-tools sai3-bench run \
  --config unet3d_1-host-get-only.yaml \
  --endpoint s3.example.com:9000 \
  --bucket medical-data \
  --output-dir results/baseline

# Test 2: Different cache state
docker run -it quay.io/russfellows-sig65/sai3-tools sai3-bench run \
  --config unet3d_1-host-get-only.yaml \
  --endpoint s3.example.com:9000 \
  --bucket medical-data \
  --output-dir results/cold-cache
```

### 4-Host Distributed Mixed Workload

```bash
# On controller node:
docker run -it quay.io/russfellows-sig65/sai3-tools sai3-bench controller \
  --config unet3d_4-host-prepare-get.yaml \
  --agents 4 \
  --agent-hosts "node1,node2,node3,node4" \
  --output-dir results/4-node-medical
```

## Performance Characteristics

Typical throughput ranges for UNet3D workload:
- **Single-host**: 500 MB/sec - 2 GB/sec (due to mixed access pattern)
- **4-host**: 2-8 GB/sec (scaling may vary due to random access)
- **8-host**: 4-16 GB/sec (depends on storage architecture)

Latency:
- **Object read latency**: 20-200ms typical (higher due to random access)
- **Percentile p99**: 500-1000ms typical (depends on network and storage)

## Tuning and Optimization

### For Better Throughput
- Use larger volume chunks to reduce random access overhead
- Enable spatial locality in access patterns
- Optimize network buffering for mixed read/write
- Ensure storage backend can handle write-heavy patterns

### For Consistency
- Use get-only configurations for baseline measurements
- Account for longer stabilization time (mixed workload more variable)
- Run multiple iterations to capture variance
- Separate read and write phases for analysis

### For Medical Imaging Workloads
- Match volume size to actual medical scan dimensions
- Consider multi-slice access patterns (sequential within volumes)
- Account for segmentation mask I/O (smaller follow-up writes)

## Related Configurations

- **ResNet50**: Different sequential-read-heavy pattern (see Resnet50/ directory)
- **Object storage testing**: Use these with sai3-bench container
- **File system testing**: Similar workload patterns available in vdbench

## Typical Use Cases

- **Medical Image Analysis**: CT/MRI scan processing and segmentation
- **Scientific Computing**: Volumetric data processing (climate models, molecular dynamics)
- **Materials Science**: 3D microscopy data analysis
- **Geoscience**: Seismic survey data processing

## Container

**Image**: `quay.io/russfellows-sig65/sai3-tools`

See parent documentation for container details and other available tools.

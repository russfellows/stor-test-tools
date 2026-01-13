# ResNet50 Workload Configurations

Configuration files for benchmarking **ResNet50 CNN training workload patterns** implementing the MLCommons Storage benchmark with sai3-bench.

## Workload Overview

ResNet50 is a deep residual learning convolutional neural network with 50 layers. These configurations simulate the MLCommons Storage ResNet50 I/O patterns typical of ResNet50 training on object storage:

- **Data Access Pattern**: Sequential batch reading with periodic random access
- **Benchmark Specification**: MLCommons Storage ResNet50
- **Typical Use Case**: ImageNet-scale image classification training
- **Data Type**: Image batches, model weights, gradients
- **I/O Characteristics**:
  - Large sequential reads (batches of images)
  - Prefetching patterns
  - Checkpointing writes (periodic)
  - Relatively metadata-light operations

## Configuration Files

### Single-Client Configuration

**resnet50_1-client-prepare-get.yaml**
- Prepare phase: Uploads image batches to object storage
- Get phase: Trains simulation by reading batches sequentially
- Use when: Testing full workflow including data upload with single client

**resnet50_1-client-get-only.yaml**
- Get phase only: Assumes batches already exist in storage
- Use when: Benchmarking read-only performance repeatedly
- More consistent baseline for performance comparisons

### 4-Client Distributed Configuration

**resnet50_4-client-prepare-get.yaml**
- Distributed preparation across 4 clients
- Each client prepares 1/4 of the dataset
- Followed by distributed read phase across all 4 clients
- Use when: Testing multi-client training setup per MLCommons spec

**resnet50_4-client-get-only.yaml**
- 4-client distributed read-only test
- Assumes data already prepared
- Useful for repeatable performance measurements across multiple clients

### 8-Client Distributed Configuration

**resnet50_8-client-prepare-get.yaml**
- Distributed preparation across 8 clients
- Each client prepares 1/8 of the dataset
- Followed by distributed read phase across all 8 clients
- Use when: Testing large-scale multi-client training per MLCommons spec

**resnet50_8-client-get-only.yaml**
- 8-client distributed read-only test
- Baseline for consistent multi-client benchmarking

## Typical I/O Characteristics

- **Object sizes**: Large (batches of images, 10s-100s MB typical)
- **Access pattern**: Primarily sequential with prefetching
- **Operation mix**: Predominantly reads, periodic writes for checkpoints
- **Throughput target**: Multi-GB/sec on modern storage
- **Latency sensitive**: Training framework dependent on I/O performance

## Usage Examples

### Single-Host with Prepare Phase

```bash
docker run -it quay.io/russfellows-sig65/sai3-tools sai3-bench run \
  --config resnet50_1-host-prepare-get.yaml \
  --endpoint s3.example.com:9000 \
  --bucket training-data
```

### Single-Host Read-Only (Repeated Tests)

```bash
# Test 1: Baseline
docker run -it quay.io/russfellows-sig65/sai3-tools sai3-bench run \
  --config resnet50_1-host-get-only.yaml \
  --endpoint s3.example.com:9000 \
  --bucket training-data \
  --output-dir results/baseline

# Test 2: With cache warm-up
docker run -it quay.io/russfellows-sig65/sai3-tools sai3-bench run \
  --config resnet50_1-host-get-only.yaml \
  --endpoint s3.example.com:9000 \
  --bucket training-data \
  --output-dir results/warm-cache
```

### 4-Host Distributed Read-Only

```bash
# On controller node:
docker run -it quay.io/russfellows-sig65/sai3-tools sai3-bench controller \
  --config resnet50_4-host-prepare-get.yaml \
  --agents 4 \
  --agent-hosts "host1,host2,host3,host4" \
  --output-dir results/4-host-test
```

## Performance Characteristics

Typical throughput ranges for ResNet50 workload:
- **Single-host**: 1-3 GB/sec (depending on network and storage)
- **4-host**: 4-12 GB/sec (linear scaling expected)
- **8-host**: 8-24 GB/sec (scaling depends on storage capacity)

Latency:
- **Object read latency**: 10-100ms typical
- **Percentile p99**: 200-500ms typical (depends on network)

## Tuning and Optimization

### For Throughput
- Increase thread count per host
- Optimize object size vs. number trade-off
- Enable prefetching in configuration
- Ensure sufficient network bandwidth

### For Consistency
- Use get-only configurations for baseline measurements
- Warm up storage cache before measurements
- Run multiple iterations to stabilize results
- Disable background operations on test system

## Related Configurations

- **UNet3D**: Different volumetric data access pattern (see Unet3d/ directory)
- **Object storage testing**: Use these with sai3-bench container
- **File system testing**: Similar workload patterns available in vdbench

## Container

**Image**: `quay.io/russfellows-sig65/sai3-tools`

See parent documentation for container details and other available tools.

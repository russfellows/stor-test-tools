# Object Storage Testing with sai3-bench

This directory contains configuration files for testing object storage systems using **sai3-bench**, a high-performance benchmarking tool for S3-compatible and other object storage backends.

## Container

**Image**: `quay.io/russfellows-sig65/sai3-tools`

This container includes:
- **sai3-bench** - High-performance object storage benchmarking tool
- **warp** - MinIO object storage benchmarking utility
- **s3-cli** - S3 command-line interface from the s3dlio project
- **Cloud CLIs** - AWS CLI, Azure CLI, Google Cloud CLI
- **Additional tools** - Various object storage and cloud tools

To pull the container:
```bash
docker pull quay.io/russfellows-sig65/sai3-tools
```

## sai3-bench Overview

sai3-bench is designed for comprehensive object storage performance testing implementing MLCommons Storage workload specifications. It supports:

- **Multi-Protocol Storage Backends**
  - Amazon S3
  - Microsoft Azure Blob Storage
  - Google Cloud Storage
  - MinIO and other S3-compatible systems
  - On-premises object storage systems

- **Distributed Testing**
  - Single-host and multi-host configurations
  - Controller-agent architecture for coordination
  - Per-agent performance tracking and aggregation

- **Complex Workload Patterns**
  - Sequential and random I/O
  - Prefetching strategies
  - Realistic AI/ML training patterns
  - Customizable read/write mix

- **Comprehensive Metrics**
  - Throughput (operations/sec and GB/sec)
  - Latency histograms with percentiles (p50, p95, p99, etc.)
  - Per-bucket statistics
  - Per-agent performance logs

## Configuration Structure

### Directory Layout

```
Object-Tests/
├── sai3-scripts/
│   ├── Resnet50/
│   │   ├── resnet50_1-host-get-only.yaml
│   │   ├── resnet50_1-host-prepare-get.yaml
│   │   ├── resnet50_4-host-get-only.yaml
│   │   ├── resnet50_4-host-prepare-get.yaml
│   │   ├── resnet50_8-host-get-only.yaml
│   │   └── resnet50_8-host-prepare-get.yaml
│   └── Unet3d/
│       ├── unet3d_1-host-get-only.yaml
│       ├── unet3d_1-host-prepare-get.yaml
│       ├── unet3d_4-host-get-only.yaml
│       ├── unet3d_4-host-prepare-get.yaml
│       ├── unet3d_8-host-get-only.yaml
│       └── unet3d_8-host-prepare-get.yaml
```

## Workload Patterns

### ResNet50 (MLCommons Storage)
Configurations simulating ResNet50 deep learning model training I/O patterns:
- Replicates MLCommons Storage ResNet50 benchmark specification
- Typical use case: CNN training workload benchmarking
- Data pattern: Image batches with sequential access
- Available configurations:
  - 1-client, 4-client, 8-client deployments
  - Prepare phase (object uploads) + Read phase
  - Read-only phase (for repeatable comparisons)

**Files**:
- `resnet50_X-client-prepare-get.yaml` - Two-phase test: upload objects, then read
- `resnet50_X-client-get-only.yaml` - Read-only test (requires pre-populated objects)

### UNet3D (MLCommons Storage)
Configurations simulating 3D UNet segmentation model training I/O patterns:
- Replicates MLCommons Storage UNet3D benchmark specification
- Typical use case: Volumetric data processing (medical imaging, scientific computing)
- Data pattern: 3D volume chunks with random access
- Available configurations:
  - 1-client, 4-client, 8-client deployments
  - Prepare phase (object uploads) + Read phase
  - Read-only phase

**Files**:
- `unet3d_X-client-prepare-get.yaml` - Two-phase test: upload objects, then read
- `unet3d_X-client-get-only.yaml` - Read-only test (requires pre-populated objects)

## Running Tests

### Prerequisites
- Docker or container runtime
- Object storage endpoint (S3 API compatible)
- Network connectivity to the storage endpoint
- For multi-host tests: multiple test hosts with network access

### Single-Host Test Example

```bash
# Pull the container
docker pull quay.io/russfellows-sig65/sai3-tools

# Run sai3-bench with ResNet50 1-host read-only test
docker run -it quay.io/russfellows-sig65/sai3-tools sai3-bench run \
  --config /path/to/resnet50_1-host-get-only.yaml \
  --endpoint s3.example.com:9000 \
  --bucket test-bucket
```

### Multi-Host Distributed Test

For distributed testing, the controller coordinates multiple agent instances:

1. **Start controller** (on main test host):
   ```bash
   docker run -it quay.io/russfellows-sig65/sai3-tools sai3-bench controller \
     --config resnet50_4-host-get-only.yaml \
     --agents 4
   ```

2. **Start agents** (on remote test hosts):
   ```bash
   docker run -it quay.io/russfellows-sig65/sai3-tools sai3bench-agent \
     --controller-ip <controller-ip> \
     --agent-port 9001
   ```

## Configuration File Format

YAML format with sections for:
- **Workload definition**: Number of objects, object sizes, access patterns
- **Operations**: Mix of reads, writes, and metadata operations
- **Distributed settings**: Number of agents/hosts, per-agent object distribution
- **Performance targets**: Expected throughput, SLAs for latency

See individual YAML files for detailed configuration examples.

## Output and Analysis

sai3-bench produces:
- **Console output**: Real-time throughput and latency metrics
- **Performance logs**: Detailed per-operation metrics in TSV format
- **Histograms**: Latency distribution data
- **Per-agent statistics**: Individual host performance tracking

## Troubleshooting

- **Authentication**: Ensure storage credentials are provided (via environment variables or config)
- **Network connectivity**: Verify network path to storage endpoint
- **Object count mismatch**: For read-only tests, ensure objects were pre-populated in the correct bucket
- **Timeout errors**: Increase timeout values in configuration if testing high-latency endpoints

## Related Documentation

- sai3-bench project: https://github.com/russfellows/sai3-bench
- s3dlio project: https://github.com/russfellows/s3dlio
- Main repository: [../README.md](../README.md)

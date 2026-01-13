# Object Storage Testing with sai3-bench

This directory contains configuration files for testing object storage systems using **sai3-bench**, a high-performance benchmarking tool for S3-compatible and other object storage backends.

## Core Tools in sai3-tools Container

### s3dlio - Universal Storage I/O Library
**Repository**: https://github.com/russfellows/s3dlio

s3dlio is a high-performance, multi-protocol storage library that provides:

- **CLI Tool (s3-cli)**: Universal command-line interface for all storage backends
  - `s3-cli ls` - List contents (supports regex patterns, progress indicators, and counting)
  - `s3-cli get` - Download objects and data sets with real-time progress
  - `s3-cli put` - Upload local files to any storage backend
  - `s3-cli delete` - Remove objects with concurrent batching (1000 objects/batch)
  - `s3-cli mkdir/rmdir` - Create and remove directories/prefixes across all backends

- **Multi-Protocol Support**: Unified interface works identically across:
  - S3 (AWS, MinIO, Ceph, etc.) - `s3://` URIs
  - Azure Blob Storage - `az://` URIs
  - Google Cloud Storage - `gs://` or `gcs://` URIs
  - Local File System - `file:///` URIs
  - DirectIO (high-performance local) - `direct:///` URIs

- **High Performance**: 
  - S3 reads: Up to 4.8 GB/s throughput
  - S3 writes: Up to 3.0 GB/s throughput
  - Zero-copy Python integration (NumPy/PyTorch/TensorFlow compatible)
  - Multi-endpoint load balancing for distributed I/O (v0.9.14+)
  - Pre-stat size caching for 2.5x faster multi-object downloads

- **Data Format Support**: 
  - TFRecord with automatic index generation
  - NPZ (NumPy Zip) with multi-array support
  - HDF5 native format support
  - Raw binary with automatic data generation
  - Configurable pseudo-random and cryptographic random data generation

**Documentation**: 
- [CLI Guide](https://github.com/russfellows/s3dlio/blob/main/docs/CLI_GUIDE.md) - Complete command reference
- [Python API Guide](https://github.com/russfellows/s3dlio/blob/main/docs/PYTHON_API_GUIDE.md) - Python library reference
- [Multi-Endpoint Guide](https://github.com/russfellows/s3dlio/blob/main/docs/MULTI_ENDPOINT_GUIDE.md) - Load balancing across endpoints
- [Changelog](https://github.com/russfellows/s3dlio/blob/main/docs/Changelog.md) - Version history and features

### sai3-bench - Multi-Protocol I/O Benchmarking Suite
**Repository**: https://github.com/russfellows/sai3-bench

sai3-bench is a comprehensive testing wrapper around s3dlio that provides:

- **Multi-Protocol Benchmarking**: Test identical workloads across S3, Azure, GCS, and local storage

- **YAML-Based Workload Configuration**:
  - Multiple operation types: GET, PUT, DELETE, METADATA
  - Realistic size distributions: lognormal (many small, few large), uniform, fixed
  - Deduplication and compression simulation
  - Directory tree structures for filesystem-like access patterns
  
- **MLCommons Storage Workloads**:
  - ResNet50 CNN training patterns (sequential image batch access)
  - UNet3D volumetric processing patterns (random + sequential mixed access)
  - Multi-client configurations (1-client, 4-client, 8-client)
  - Support for both preparation and read-only test phases

- **Distributed Testing**:
  - Multi-agent coordination using gRPC
  - Automated SSH deployment across multiple hosts
  - Containerized agents (Docker/Podman support)
  - Automatic result aggregation with HDR histograms
  - Graceful shutdown and error handling

- **Workload Replay & Analysis**:
  - Capture production I/O traces using s3dlio op-logs
  - Replay with microsecond-accurate timing
  - URI remapping for migration testing (single→single, single→multiple, multiple→single)
  - Speed adjustment for accelerated/decelerated load testing

- **Performance Metrics**:
  - HDR histograms with percentile analysis (p50, p90, p99, p99.9)
  - TSV export with per-size-bucket and aggregate statistics
  - Time-series performance logging (v0.8.17+)
  - Per-operation throughput and latency distributions

**Key Binaries**:
- `sai3-bench run` - Execute workload benchmarks
- `sai3-bench replay` - Replay captured operation logs
- `sai3-bench util` - Utilities (health checks, counting, cleanup)
- `sai3bench-agent` - Distributed agent for multi-host testing
- `sai3bench-ctl` - Controller coordinating distributed agents
- `sai3-analyze` - Results consolidation tool (Excel generation)

**Documentation**: 
- [Usage Guide](https://github.com/russfellows/sai3-bench/blob/main/docs/USAGE.md) - Getting started
- [Config Syntax](https://github.com/russfellows/sai3-bench/blob/main/docs/CONFIG_SYNTAX.md) - Configuration reference
- [Config Examples](https://github.com/russfellows/sai3-bench/blob/main/tests/configs/README.md) - Annotated examples
- [Distributed Testing Guide](https://github.com/russfellows/sai3-bench/blob/main/docs/DISTRIBUTED_TESTING_GUIDE.md) - Multi-host setup
- [Data Generation Guide](https://github.com/russfellows/sai3-bench/blob/main/docs/DATA_GENERATION.md) - Workload patterns
- [Changelog](https://github.com/russfellows/sai3-bench/blob/main/docs/CHANGELOG.md) - Version history

## Container

**Image**: `quay.io/russfellows-sig65/sai3-tools`

This container includes:
- **sai3-bench** - High-performance object storage benchmarking tool
- **s3-cli** - Universal S3 command-line interface from s3dlio
- **warp** - MinIO object storage benchmarking utility
- **Cloud CLIs** - AWS CLI, Azure CLI, Google Cloud CLI
- **Additional tools** - Various object storage and cloud utilities

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
- For multi-host tests: multiple test hosts with network access and SSH connectivity

### Single-Host Test Example

For basic testing on a single machine:

```bash
# Pull the container
docker pull quay.io/russfellows-sig65/sai3-tools

# Run sai3-bench with ResNet50 1-host read-only test
docker run -it quay.io/russfellows-sig65/sai3-tools sai3-bench run \
  --config resnet50_1-host-get-only.yaml \
  --endpoint s3.example.com:9000 \
  --bucket test-bucket
```

### Distributed Multi-Host Testing Architecture

sai3-bench uses a distributed agent-controller architecture similar to vdbench:

- **sai3bench-agent**: Lightweight agent that runs on each worker node and listens for commands from the controller
- **sai3bench-ctl**: Controller that coordinates workload execution across multiple agents

The configuration file (YAML) can specify the list of agents, or agents can be provided via command-line arguments to the controller.

#### Agent Command Options

Start an agent on each worker node:

```bash
docker run -d \
  --name sai3-agent \
  -p 7761:7761 \
  quay.io/russfellows-sig65/sai3-tools \
  sai3bench-agent \
    --listen 0.0.0.0:7761 \
    --verbose
```

**Common agent options**:
- `--listen <ADDR>` - Listen address (default: 0.0.0.0:7761)
- `--verbose` or `-v` - Increase verbosity (use `-vv` for debug, `-vvv` for trace)
- `--tls` - Enable TLS with self-signed certificate
- `--op-log <PATH>` - Optional operation log path for detailed tracing

#### Controller Command Examples

**Option 1: Agents specified in YAML configuration file**

If your YAML config includes a `distributed.agents` section listing agent addresses, start the controller without specifying agents:

```bash
docker run -it quay.io/russfellows-sig65/sai3-tools sai3bench-ctl \
  run \
  --config resnet50_4-host-get-only.yaml
```

Your YAML file should include:
```yaml
distributed:
  agents:
    - agent1.example.com:7761
    - agent2.example.com:7761
    - agent3.example.com:7761
    - agent4.example.com:7761
```

**Option 2: Agents specified on controller command line**

If agents are not in the configuration file, specify them when starting the controller:

```bash
docker run -it quay.io/russfellows-sig65/sai3-tools sai3bench-ctl \
  --agents agent1.example.com:7761,agent2.example.com:7761,agent3.example.com:7761,agent4.example.com:7761 \
  run \
  --config resnet50_4-host-get-only.yaml
```

#### Multi-Host Test Workflow

1. **Start agents** on each worker node (in background):
   ```bash
   # On agent1
   docker run -d --name sai3-agent -p 7761:7761 \
     quay.io/russfellows-sig65/sai3-tools \
     sai3bench-agent --listen 0.0.0.0:7761 --verbose
   
   # On agent2, agent3, agent4 (repeat similarly)
   ```

2. **Verify agent connectivity** (from controller host):
   ```bash
   docker run -it quay.io/russfellows-sig65/sai3-tools sai3bench-ctl \
     --agents agent1.example.com:7761,agent2.example.com:7761,agent3.example.com:7761,agent4.example.com:7761 \
     ping
   ```

3. **Run distributed benchmark** (from controller host):
   ```bash
   docker run -it quay.io/russfellows-sig65/sai3-tools sai3bench-ctl \
     --agents agent1.example.com:7761,agent2.example.com:7761,agent3.example.com:7761,agent4.example.com:7761 \
     run \
     --config resnet50_4-host-get-only.yaml
   ```

#### Controller Command Options

- `--agents <AGENTS>` - Comma-separated agent addresses (host:port), optional if specified in YAML
- `--verbose` or `-v` - Increase verbosity
- `--tls` - Enable TLS for secure connections (requires --agent-ca)
- `--agent-ca <PATH>` - Path to agent's self-signed certificate (required if --tls enabled)

#### Controller Subcommands

- `run` - Execute distributed workload from YAML configuration
- `put` - Distributed PUT operation
- `get` - Distributed GET operation
- `ping` - Simple reachability check against all agents
- `ssh-setup` - SSH setup wizard for automated agent deployment

#### Example: SSH-Based Agent Setup (v0.6.11+)

For automated agent deployment across multiple hosts:

```bash
docker run -it quay.io/russfellows-sig65/sai3-tools sai3bench-ctl \
  ssh-setup
```

This interactive wizard:
- Generates SSH keys if needed
- Distributes keys to remote hosts
- Verifies connectivity
- Optionally deploys agents automatically

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

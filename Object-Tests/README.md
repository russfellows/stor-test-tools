# Object Storage Test Configurations

Configuration files for benchmarking object storage systems using **sai3-bench**, a multi-protocol benchmarking suite built on the **s3dlio** storage library.

**See [Readme-sai3bench.md](Readme-sai3bench.md) for detailed documentation.**

## Quick Reference

- **Tool**: sai3-bench
- **Container**: `quay.io/russfellows-sig65/sai3-tools`
- **Workloads**: ResNet50, UNet3D (MLCommons Storage specifications)
- **Configurations**: 1-host, 4-host, 8-host
- **File Format**: YAML

## Core Projects

### [s3dlio - Universal Storage I/O Library](https://github.com/russfellows/s3dlio)
High-performance multi-protocol storage library providing:
- CLI tool (s3-cli) for all storage backends (S3, Azure, GCS, local file, DirectIO)
- High-performance reads (4.8 GB/s) and writes (3.0 GB/s) on S3
- Zero-copy Python API for NumPy/PyTorch integration
- Operation logging for workload capture and replay
- Multi-endpoint load balancing

**Documentation**: [CLI Guide](https://github.com/russfellows/s3dlio/blob/main/docs/CLI_GUIDE.md), [Python API](https://github.com/russfellows/s3dlio/blob/main/docs/PYTHON_API_GUIDE.md), [Changelog](https://github.com/russfellows/s3dlio/blob/main/docs/Changelog.md)

### [sai3-bench - Multi-Protocol I/O Benchmarking](https://github.com/russfellows/sai3-bench)
Comprehensive benchmarking suite supporting:
- YAML-based workload configuration
- Multi-protocol testing (S3, Azure, GCS, local storage)
- Distributed multi-host testing with gRPC coordination
- Workload replay from s3dlio operation logs
- HDR histograms and time-series performance metrics

**Documentation**: [Usage Guide](https://github.com/russfellows/sai3-bench/blob/main/docs/USAGE.md), [Config Syntax](https://github.com/russfellows/sai3-bench/blob/main/docs/CONFIG_SYNTAX.md), [Distributed Testing](https://github.com/russfellows/sai3-bench/blob/main/docs/DISTRIBUTED_TESTING_GUIDE.md), [Changelog](https://github.com/russfellows/sai3-bench/blob/main/docs/CHANGELOG.md)

## Directory Structure

### `sai3-scripts/`
Contains sai3-bench configuration files organized by workload:

- **Resnet50/** - ResNet50 CNN training workload patterns
- **Unet3d/** - 3D UNet segmentation workload patterns

Each workload has configurations for:
- `*-prepare-get.yaml` - Prepare (upload) then read phase
- `*-get-only.yaml` - Read-only phase (for repeatable tests)

For single-host, 4-host, and 8-host distributed deployments.

## Usage

See [Readme-sai3bench.md](Readme-sai3bench.md) for complete instructions on running these tests.

# Object Storage Test Configurations

Configuration files for benchmarking object storage systems using **sai3-bench**.

**See [Readme-sai3bench.md](Readme-sai3bench.md) for detailed documentation.**

## Quick Reference

- **Tool**: sai3-bench
- **Container**: `quay.io/russfellows-sig65/sai3-tools`
- **Workloads**: ResNet50, UNet3D
- **Configurations**: 1-host, 4-host, 8-host
- **File Format**: YAML

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

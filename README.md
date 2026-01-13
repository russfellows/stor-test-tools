# Storage Testing Tools and Configurations

A comprehensive collection of test configurations and scripts for benchmarking storage systems across different workload patterns. This repository contains test configurations for both **object storage** and **file system** testing, using industry-standard tools.

## Project Overview

This repository provides organized test suites for evaluating storage system performance using AI/ML workload patterns. It includes configurations for real-world workloads like ResNet50 and UNet3D, with multi-host distributed testing support.

## Directory Structure

### [Object-Tests/](Object-Tests/)
Configuration files for object storage testing using **sai3-bench**.

- **Container**: `quay.io/russfellows-sig65/sai3-tools`
- **Tool**: sai3-bench - High-performance object storage benchmarking tool
- **Workloads**: ResNet50 and UNet3D (1-host, 4-host, 8-host configurations)
- For details, see [Object-Tests/README.md](Object-Tests/README.md)

### [File-Tests/](File-Tests/)
Configuration files for file system testing using **IOR** and **vdbench**.

- **Containers**: 
  - IOR: `quay.io/russfellows-sig65/io500`
  - vdbench: `quay.io/russfellows-sig65/file-tests`
- **Tools**: IOR (distributed parallel file I/O) and vdbench (file system workload generator)
- **Workloads**: ResNet50 and UNet3D patterns (1-host, 4-host, 8-host configurations)
- For details, see [File-Tests/README.md](File-Tests/README.md)

## Testing Tools

### sai3-bench (Object Storage)
**Container**: `quay.io/russfellows-sig65/sai3-tools`

sai3-bench is a high-performance object storage benchmarking tool that supports:
- Multi-protocol object storage (S3, Azure Blob, Google Cloud Storage)
- Distributed testing across multiple hosts
- MLCommons Storage workload patterns (ResNet50, UNet3D)
- Comprehensive performance metrics and histograms

**Additional tools in this container**:
- warp - MinIO performance benchmarking
- s3-cli - S3 command-line interface from s3dlio project
- AWS CLI, Azure CLI, Google Cloud CLI
- Various other cloud and object storage tools

### IOR (File System I/O)
**Container**: `quay.io/russfellows-sig65/io500`

IOR (Interleaved-Or-Random) is a parallel file I/O benchmark tool that:
- Tests distributed file system performance
- Implements MLCommons Storage workload patterns
- Supports various I/O patterns (sequential, random, strided)
- Includes metadata testing capabilities
- Works with HPC file systems and standard POSIX systems

### vdbench (File System Workload)
**Container**: `quay.io/russfellows-sig65/file-tests`

vdbench is a comprehensive file system workload generator featuring:
- Realistic file system workload simulation
- Single or multi-threaded operation
- Complex workload definitions with multiple file types
- Performance analysis with detailed statistics

**Additional tools in this container**:
- fio - Flexible I/O workload simulator
- Various other file system testing utilities

## Workload Patterns

### ResNet50 (MLCommons Storage)
Configuration files for ResNet50 CNN deep learning training workload patterns:
- Replicates MLCommons Storage ResNet50 benchmark specification
- Simulates typical CNN training I/O patterns
- Available in 1-client, 4-client, and 8-client configurations
- Includes both preparation and read-only test phases
- Used across multiple test tools (sai3-bench, IOR, vdbench)

### UNet3D (MLCommons Storage)
Configuration files for 3D UNet segmentation workload patterns:
- Replicates MLCommons Storage UNet3D benchmark specification
- Simulates volumetric data processing I/O patterns
- Available in 1-client, 4-client, and 8-client configurations
- Typical for medical imaging and scientific computing workloads
- Implemented across multiple test tools (sai3-bench, IOR, vdbench)

## Getting Started

1. **Review** the appropriate README for your testing needs:
   - Object storage testing: [Object-Tests/README.md](Object-Tests/README.md)
   - File system testing: [File-Tests/README.md](File-Tests/README.md)

2. **Pull the container** for your testing tool:
   ```bash
   # For sai3-bench (object storage)
   docker pull quay.io/russfellows-sig65/sai3-tools
   
   # For IOR (file system)
   docker pull quay.io/russfellows-sig65/io500
   
   # For vdbench (file system)
   docker pull quay.io/russfellows-sig65/file-tests
   ```

3. **Run tests** using provided shell scripts or direct container commands

4. **Analyze results** using the benchmarking tool's output and analysis features

## Shell Scripts for vdbench

Two utility shell scripts are provided to simplify vdbench execution:

### `start_vdb-agent.sh` - Agent (Listening) Mode
Starts vdbench in listening mode for distributed multi-host testing:
```bash
docker run --rm -v /mnt/lustre:/mnt/lustre --net=host -it file-tests \
  "/opt/vdbench/vdbench" "rsh"
```
**Use for**: Distributed benchmarks with coordinated agents across multiple hosts

### `start_vdb.sh` - Interactive Container Mode
Starts the container interactively for manual vdbench execution:
```bash
docker run -v /mnt/lustre:/mnt/lustre --net=host -it file-tests
```
**Inside container, run**:
```bash
cd /opt/vdbench
./vdbench -f <config_file> -o <output_dir>
```
**Use for**: Single-host tests and manual testing/debugging

See [File-Tests/Readme-Vdbench.md](File-Tests/Readme-Vdbench.md) for detailed usage examples.

## Configuration Files

- **sai3-bench configs**: YAML format with workload definitions
- **vdbench configs**: Parameter files (.txt format)
- **IOR configs**: Initialization files (.ini format)

## Prerequisites

- Docker or container runtime
- Network access to quay.io registries
- Storage endpoint (S3, Azure, GCS, or local file system)
- For distributed tests: multiple hosts with network connectivity

## License

See [LICENSE](LICENSE) file for details.

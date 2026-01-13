# sai3-bench Configuration Scripts

Configuration files for object storage benchmarking with **sai3-bench**.

## Directory Structure

```
sai3-scripts/
├── Resnet50/           - ResNet50 CNN training workload patterns
└── Unet3d/             - 3D UNet segmentation workload patterns
```

## Workload Patterns

### Resnet50
ResNet50 deep learning model training workload patterns:
- **Files**:
  - `resnet50_1-host-get-only.yaml` - Single-host read-only
  - `resnet50_1-host-prepare-get.yaml` - Single-host prepare + read
  - `resnet50_4-host-get-only.yaml` - 4-host read-only
  - `resnet50_4-host-prepare-get.yaml` - 4-host prepare + read
  - `resnet50_8-host-get-only.yaml` - 8-host read-only
  - `resnet50_8-host-prepare-get.yaml` - 8-host prepare + read

### Unet3d
3D UNet segmentation model workload patterns:
- **Files**:
  - `unet3d_1-host-get-only.yaml` - Single-host read-only
  - `unet3d_1-host-prepare-get.yaml` - Single-host prepare + read
  - `unet3d_4-host-get-only.yaml` - 4-host read-only
  - `unet3d_4-host-prepare-get.yaml` - 4-host prepare + read
  - `unet3d_8-host-get-only.yaml` - 8-host read-only
  - `unet3d_8-host-prepare-get.yaml` - 8-host prepare + read

## Configuration Details

### File Naming Convention

- `{workload}_{hosts}-host-{phase}.yaml`
  - `{workload}`: resnet50, unet3d
  - `{hosts}`: 1, 4, or 8
  - `{phase}`: prepare-get (two phases), get-only (read-only)

### Test Phases

**prepare-get**: Two-phase test
1. **Prepare phase**: Uploads/creates objects in object storage
2. **Get phase**: Performs read operations on the prepared objects

**get-only**: Single phase
- **Get phase only**: Assumes objects already exist, performs read-only tests
- Useful for repeatable comparisons and consistent benchmarking

## Usage

For detailed instructions on running these tests, see [../Readme-sai3bench.md](../Readme-sai3bench.md)

### Basic Example

```bash
docker run -it quay.io/russfellows-sig65/sai3-tools sai3-bench run \
  --config sai3-scripts/Resnet50/resnet50_1-host-get-only.yaml \
  --endpoint <S3_ENDPOINT> \
  --bucket <BUCKET_NAME>
```

## Container

**Image**: `quay.io/russfellows-sig65/sai3-tools`

See parent directory documentation for details on the sai3-tools container.

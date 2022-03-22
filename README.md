# h5torch

## Install

```bash
pip install git+https://github.com/gregunz/h5torch
```

## Usage

### Example 1: convert tensors into an hdf5 dataset

```python
import torch

path = "../data/dataset.hdf5"
data = (torch.rand(3, 224, 224) for _ in range(1000))


from h5torch.utils import convert_tensors_to_default_h5_torch_datasets

convert_tensors_to_default_h5_torch_datasets(
    data=data,
    dataset_path=path,
)
```

### Example 2: load the hdf5 dataset

```python
from h5torch.datasets import H5TorchDataset

path = "../data/dataset.hdf5"

dataset = H5TorchDataset(
    path=path,
)
```

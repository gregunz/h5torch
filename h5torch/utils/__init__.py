from pathlib import Path
from typing import Iterable, List, Optional

import h5py
import torch


def convert_tensors_to_default_h5_torch_datasets(
    data: Iterable[torch.Tensor],
    dataset_path: Path,
    h5_data_key: str = "/data",
    h5_data_indices: Optional[List[str]] = None,
    parts_dir: Optional[Path] = None,
) -> None:
    dataset_path = Path(dataset_path)

    if parts_dir is None:
        parts_dir = dataset_path.parent / f"{dataset_path.name}.parts"
    else:
        parts_dir = Path(parts_dir)

    dataset_path.parent.mkdir(parents=True, exist_ok=True)
    parts_dir.mkdir(parents=True, exist_ok=True)

    part_paths = []

    for idx, sample in enumerate(data):
        if h5_data_indices is None:
            part_path = parts_dir / f"{idx}.hdf5"
        else:
            part_path = parts_dir / f"{h5_data_indices[idx]}.hdf5"

        part_paths.append(part_path)

        with h5py.File(part_path, mode="a") as f:
            if h5_data_key in f:
                del f[h5_data_key]

            f[h5_data_key] = sample.numpy()

    with h5py.File(dataset_path, mode="a") as f:
        for part_path in part_paths:
            h5_part_key = f"{h5_data_key}/{part_path.stem}"

            if h5_part_key in f:
                del f[h5_part_key]

            f[h5_part_key] = h5py.ExternalLink(part_path.as_posix(), h5_data_key)

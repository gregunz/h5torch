from contextlib import contextmanager
from pathlib import Path
from typing import Generator, List, Optional

import h5py
import torch
from torch.utils.data import Dataset


class H5TorchDataset(Dataset):
    def __init__(
        self,
        path: Path,
        h5_data_key: str = "/data",
        h5_data_keys: Optional[List[str]] = None,
        keep_file_open: bool = False,
    ) -> None:
        super().__init__()
        path = Path(path)

        with h5py.File(path, mode="r") as f:

            if h5_data_keys is None:
                h5_data_keys = [f"{h5_data_key}/{k}" for k in f[h5_data_key].keys()]  # type: ignore
            else:
                for key in h5_data_keys:
                    if key not in f:
                        raise KeyError(f"Index ({key}) not found in hdf5 file: {path}")

        self.path = path
        self.h5_data_keys = h5_data_keys
        self._h5_file = None
        if keep_file_open:
            self._h5_file = h5py.File(path, mode="r")

    @contextmanager
    def open(self) -> Generator[h5py.File, None, None]:
        if self._h5_file is None:
            with h5py.File(self.path) as f:
                yield f
        else:
            # this will not close it even when called with "with" statement
            yield self._h5_file

    def __len__(self):
        return len(self.h5_data_keys)

    def __getitem__(self, index: int) -> torch.Tensor:
        key = self.h5_data_keys[index]
        with self.open() as f:
            return torch.from_numpy(f[key][:])  # type: ignore

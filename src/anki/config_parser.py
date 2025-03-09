from collections import defaultdict
from functools import cache
from glob import glob
from pathlib import Path


class RecursiveConfigParser:
    dir: Path
    targets: set[str]
    results: dict[str, dict[Path, str]]

    def __init__(self, dir, targets, recursive=True):
        self.dir = dir
        self.targets = set(targets)
        self.results = defaultdict(dict)
        self._parse_dirs(recursive)

    def _parse_dirs(self, recursive=True):
        files = []
        for target in self.targets:
            if recursive:
                dir = f"{self.dir}/**/{target}"
            else:
                dir = f"{self.dir}/{target}"
            files.extend(glob(dir, include_hidden=target.startswith("."), recursive=recursive))
        for file in files:
            file = Path(file)
            if file.name in self.targets:
                self.results[file.name][file.parent] = file.read_text(encoding="utf-8")

    @cache
    def get_config(self, path: Path, target) -> str | None:
        root_parent = self.dir.parent.resolve()
        path = Path(path.resolve())
        target_results = self.results[target]
        while path != root_parent:
            if result := target_results.get(path):
                return result
            path = path.parent

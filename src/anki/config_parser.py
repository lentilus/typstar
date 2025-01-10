from collections import defaultdict
from functools import cache
from glob import glob
from pathlib import Path


class RecursiveConfigParser:
    dir: Path
    targets: set[str]
    results: dict[str, dict[Path, str]]

    def __init__(self, dir, targets):
        self.dir = dir
        self.targets = set(targets)
        self.results = defaultdict(dict)
        self._parse_recursive()
    
    def _parse_recursive(self):
        files = []
        for target in self.targets:
            files.extend(glob(f"{self.dir}/**/{target}", include_hidden=target.startswith("."), recursive=True))
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

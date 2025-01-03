import hashlib
from pathlib import Path
from typing import List

import tree_sitter


class FileHandler:
    file_path: Path
    file_content: List[bytes]

    def __init__(self, path: Path):
        self.file_path = path
        self.read()

    @property
    def directory_path(self) -> Path:
        return self.file_path.parent

    def get_bytes(self) -> bytes:
        return b"".join(self.file_content)

    def get_file_hash(self) -> str:
        return hashlib.md5(self.get_bytes(), usedforsecurity=False).hexdigest()

    def get_node_content(self, node: tree_sitter.Node, remove_outer=False) -> str:
        content = (
            b"".join(self.file_content[node.start_point.row : node.end_point.row + 1])[
                node.start_point.column : -(
                    len(self.file_content[node.end_point.row]) - node.end_point.column
                )
            ]
        ).decode()
        return content[1:-1] if remove_outer else content

    def update_node_content(self, node: tree_sitter.Node, value):
        new_lines = self.file_content[: node.start_point.row]
        first_line = self.file_content[node.start_point.row][: node.start_point.column]
        last_line = self.file_content[node.end_point.row][node.end_point.column :]
        new_lines.extend(
            (
                line + b"\n"
                for line in (first_line + str(value).encode() + last_line).split(b"\n")
                if line != b""
            )
        )
        new_lines.extend(self.file_content[node.end_point.row + 1 :])
        self.file_content = new_lines

    def read(self):
        with self.file_path.open("rb") as f:
            self.file_content = f.readlines()

    def write(self):
        with self.file_path.open("wb") as f:
            f.writelines(self.file_content)

import os.path
from typing import List

import tree_sitter


class FileHandler:
    file_path: str
    file_content: List[str]

    def __init__(self, path):
        self.file_path = path
        self.read()

    @property
    def directory_path(self) -> str:
        return os.path.dirname(self.file_path)

    def get_bytes(self) -> bytes:
        return bytes("".join(self.file_content), encoding="utf-8")

    def get_node_content(self, node: tree_sitter.Node, remove_outer=False):
        content = "".join(
            self.file_content[node.start_point.row:node.end_point.row + 1]
        )[node.start_point.column:-(len(self.file_content[node.end_point.row]) - node.end_point.column)]
        return content[1:-1] if remove_outer else content

    def update_node_content(self, node: tree_sitter.Node, value):
        new_lines = self.file_content[:node.start_point.row]
        first_line = self.file_content[node.start_point.row][:node.start_point.column]
        last_line = self.file_content[node.end_point.row][node.end_point.column:]
        new_lines.extend((
            line + "\n" for line in (first_line + str(value) + last_line).split("\n")
            if line != ""
        ))
        new_lines.extend(self.file_content[node.end_point.row + 1:])
        self.file_content = new_lines

    def read(self):
        with open(self.file_path, encoding="utf-8") as f:
            self.file_content = f.readlines()

    def write(self):
        with open(self.file_path, "w", encoding="utf-8") as f:
            f.writelines(self.file_content)

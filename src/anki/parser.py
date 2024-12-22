from typing import List

import tree_sitter
from tree_sitter_language_pack import get_language, get_parser

from .file_handler import FileHandler
from .flashcard import Flashcard

ts_flashcard_query = """
(call 
  item: [
    (call 
      item: (call 
        item: (ident) @fncall
        (group 
          (number) @id))
      (content) @front)
    (call
      item: (ident) @fncall
      (group
        (number) @id
        (string) @front))
    ]
    (#eq? @fncall "flashcard")
  ((content) @back
) @flashcard)
"""


class FlashcardParser:
    typst_language: tree_sitter.Language
    typst_parser: tree_sitter.Parser
    flashcard_query: tree_sitter.Query

    def __init__(self):
        self.typst_language = get_language("typst")
        self.typst_parser = get_parser("typst")
        self.flashcard_query = self.typst_language.query(ts_flashcard_query)

    def parse_file(self, file: FileHandler) -> List[Flashcard]:
        cards = []
        tree = self.typst_parser.parse(file.get_bytes(), encoding="utf8")
        captures = self.flashcard_query.captures(tree.root_node)

        n = len(captures["flashcard"]) if captures else 0
        for idx in range(n):
            note_id = captures["id"][idx]
            front = captures["front"][idx]
            back = captures["back"][idx]
            card = Flashcard(
                file.get_node_content(front, True),
                file.get_node_content(back, True),
                note_id=int(file.get_node_content(note_id))
            )
            card.set_ts_nodes(front, back, note_id)
            cards.append(card)
        return cards

import glob
import json
import re

from functools import cache
from pathlib import Path
from typing import List, Tuple

import appdirs
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

ts_deck_query = """
((comment) @deck)
"""
deck_regex = re.compile(r"\W+ANKI:\s*(\S*)")


class FlashcardParser:
    typst_language: tree_sitter.Language
    typst_parser: tree_sitter.Parser
    flashcard_query: tree_sitter.Query
    deck_query: tree_sitter.Query

    file_handlers: List[tuple[FileHandler, List[Flashcard]]]
    file_hashes: dict[str, str]
    file_hashes_store_path: Path = Path(appdirs.user_state_dir("typstar") + "/file_hashes.json")

    def __init__(self):
        self.typst_language = get_language("typst")
        self.typst_parser = get_parser("typst")
        self.flashcard_query = self.typst_language.query(ts_flashcard_query)
        self.deck_query = self.typst_language.query(ts_deck_query)
        self.file_handlers = []
        self._load_file_hashes()

    def _parse_file(self, file: FileHandler, preamble: str) -> List[Flashcard]:
        cards = []
        tree = self.typst_parser.parse(file.get_bytes(), encoding="utf8")
        card_captures = self.flashcard_query.captures(tree.root_node)
        if not card_captures:
            return cards
        deck_captures = self.deck_query.captures(tree.root_node)

        def row_compare(node):
            return node.start_point.row

        card_captures["id"].sort(key=row_compare)
        card_captures["front"].sort(key=row_compare)
        card_captures["back"].sort(key=row_compare)

        deck_refs: List[Tuple[int, str]] = []
        deck_refs_idx = -1
        current_deck = None
        if deck_captures:
            deck_captures["deck"].sort(key=row_compare)
            for comment in deck_captures["deck"]:
                if match := deck_regex.match(file.get_node_content(comment)):
                    deck_refs.append((comment.start_point.row, None if match[1].isspace() else match[1]))

        for note_id, front, back in zip(card_captures["id"], card_captures["front"], card_captures["back"]):
            while deck_refs_idx < len(deck_refs) - 1 and back.end_point.row >= deck_refs[deck_refs_idx + 1][0]:
                deck_refs_idx += 1
                current_deck = deck_refs[deck_refs_idx][1]

            card = Flashcard(
                file.get_node_content(front, True),
                file.get_node_content(back, True),
                current_deck,
                int(file.get_node_content(note_id)),
                preamble,
                file,
            )
            card.set_ts_nodes(front, back, note_id)
            cards.append(card)
        return cards

    def parse_directory(self, root_dir):
        print(f"Parsing flashcards in {root_dir}...")
        root_dir = Path(root_dir)
        preambles = {}
        flashcards = []

        @cache
        def get_preamble(path: Path) -> str | None:
            while path != root_dir:
                if preamble := preambles.get(path):
                    return preamble
                path = path.parent

        for file in sorted(glob.glob(f"{root_dir}/**/**.typ", include_hidden=True, recursive=True)):
            file = Path(file)
            if file.name == ".anki.typ":
                preambles[file.parent] = file.read_text(encoding="utf-8")
                continue
            fh = FileHandler(file)
            if self._hash_changed(fh):
                cards = self._parse_file(fh, get_preamble(file.parent))
                self.file_handlers.append((fh, cards))
                flashcards.extend(cards)
        return flashcards

    def _hash_changed(self, file: FileHandler) -> bool:
        file_hash = file.get_file_hash()
        cached = self.file_hashes.get(str(file.file_path))
        self.file_hashes[str(file.file_path)] = file_hash
        return file_hash != cached

    def _load_file_hashes(self):
        self.file_hashes_store_path.parent.mkdir(parents=True, exist_ok=True)
        self.file_hashes_store_path.touch()
        content = self.file_hashes_store_path.read_text()
        if content:
            self.file_hashes = json.loads(content)
        else:
            self.file_hashes = {}

    def save_file_hashes(self):
        self.file_hashes_store_path.write_text(json.dumps(self.file_hashes))

    def clear_file_hashes(self):
        self.file_hashes = {}
        self.save_file_hashes()

    def update_ids_in_source(self):
        print("Updating ids in source...")
        for fh, cards in self.file_handlers:
            file_updated = False
            for c in cards:
                if c.id_updated:
                    fh.update_node_content(c.note_id_node, c.note_id)
                    file_updated = True
            if file_updated:
                fh.write()
                self.file_hashes[str(fh.file_path)] = fh.get_file_hash()

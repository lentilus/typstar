import asyncio
import glob
import os

from anki.anki_api import AnkiConnectApi
from anki.file_handler import FileHandler
from anki.parser import FlashcardParser
from anki.typst_compiler import TypstCompiler

parser = FlashcardParser()
compiler = TypstCompiler(os.getcwd())
api = AnkiConnectApi()


async def export_flashcards(path):
    # parse flashcards
    print("Parsing flashcards...")
    flashcards = []
    file_handlers = []
    for file in glob.glob(f"{path}/**/*.typ", recursive=True):
        fh = FileHandler(file)
        cards = parser.parse_file(fh)
        file_handlers.append((fh, cards))
        flashcards.extend(cards)

    # async typst compilation
    print("Compiling flashcards...")
    await compiler.compile_flashcards(flashcards)

    # async anki push per deck
    print("Pushing flashcards to anki...")
    await api.push_flashcards(flashcards)

    # write id updates to files
    print("Updating ids in source...")
    for fh, cards in file_handlers:
        file_updated = False
        for c in cards:
            if c.id_updated:
                fh.update_node_content(c.note_id_node, c.note_id)
                file_updated = True
        if file_updated:
            fh.write()
    print("Done")


def main():
    asyncio.run(export_flashcards(os.getcwd()))


if __name__ == "__main__":
    main()

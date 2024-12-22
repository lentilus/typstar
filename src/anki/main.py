import asyncio
import glob
import os
from typing_extensions import Annotated

import typer

from anki.anki_api import AnkiConnectApi
from anki.file_handler import FileHandler
from anki.parser import FlashcardParser
from anki.typst_compiler import TypstCompiler

cli = typer.Typer(name="typstar-anki")


async def export_flashcards(root_dir, typst_cmd):
    parser = FlashcardParser()
    compiler = TypstCompiler(root_dir, typst_cmd)
    api = AnkiConnectApi()

    # parse flashcards
    print("Parsing flashcards...")
    flashcards = []
    file_handlers = []
    for file in glob.glob(f"{root_dir}/**/*.typ", recursive=True):
        fh = FileHandler(file)
        cards = parser.parse_file(fh)
        file_handlers.append((fh, cards))
        flashcards.extend(cards)

    # async typst compilation
    await compiler.compile_flashcards(flashcards)

    # async anki push per deck
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


@cli.command()
def cmd(root_dir: Annotated[
    str, typer.Option(help="Directory scanned for flashcards and passed over to typst compile command")] = os.getcwd(),
        typst_cmd: Annotated[str, typer.Option(help="Typst command used for flashcard compilation")] = "typst"):
    asyncio.run(export_flashcards(root_dir, typst_cmd))


def main():
    typer.run(cmd)


if __name__ == "__main__":
    main()

import asyncio
import os
import random

from pathlib import Path
from typing import List

from .flashcard import Flashcard

default_preamble = """
#set text(size: 20pt)
#set page(width: auto, height: auto, margin: (rest: 8pt))
#let flashcard(id, front, back) = {
  strong(front)
  [\\ ]
  back
}
"""


class TypstCompilationError(ValueError):
    pass


class TypstCompiler:
    preamble: str
    typst_cmd: str
    typst_root_dir: Path
    max_processes: int

    def __init__(self, typst_root_dir: Path, typst_cmd: str):
        self.typst_cmd = typst_cmd
        self.typst_root_dir = typst_root_dir
        self.max_processes = round(os.cpu_count() * 1.5)

    async def _compile(self, src: str, directory: Path) -> bytes:
        tmp_path = f"{directory}/tmp_{random.randint(1, 1000000000)}.typ"
        with open(tmp_path, "w", encoding="utf-8") as f:
            f.write(src)
        proc = await asyncio.create_subprocess_shell(
            f"{self.typst_cmd} compile {tmp_path} - --root {self.typst_root_dir} --format svg",
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE,
        )
        stdout, stderr = await proc.communicate()
        os.remove(tmp_path)
        if stderr:
            raise TypstCompilationError(bytes.decode(stderr, encoding="utf-8"))
        return stdout

    async def _compile_flashcard(self, card: Flashcard):
        preamble = default_preamble if card.preamble is None else card.preamble
        front = await self._compile(preamble + "\n" + card.as_typst(True), card.file_handler.directory_path)
        back = await self._compile(preamble + "\n" + card.as_typst(False), card.file_handler.directory_path)
        card.set_svgs(front, back)

    async def compile_flashcards(self, cards: List[Flashcard]):
        print(f"Compiling {len(cards)} flashcards...")
        semaphore = asyncio.Semaphore(self.max_processes)

        async def compile_coro(card):
            async with semaphore:
                return await self._compile_flashcard(card)

        results = await asyncio.gather(*(compile_coro(card) for card in cards), return_exceptions=True)
        for result in results:
            if isinstance(result, Exception):
                raise result

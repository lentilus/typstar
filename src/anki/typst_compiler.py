import asyncio
import os
from typing import List

from .flashcard import Flashcard

default_preamble = """
#set page(width: auto, height: auto, margin: (rest: 0%))
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
    typst_root_dir: str
    max_processes: int

    def __init__(self, typst_root_dir: str = ".", typst_cmd: str = "typst", preamble: str = None):
        if preamble is None:
            preamble = default_preamble
        self.typst_cmd = typst_cmd
        self.typst_root_dir = typst_root_dir
        self.preamble = preamble
        self.max_processes = round(os.cpu_count() * 1.5)

    async def _compile(self, src: str) -> bytes:
        proc = await asyncio.create_subprocess_shell(
            f"{self.typst_cmd} compile - - --root {self.typst_root_dir} --format svg",
            stdin=asyncio.subprocess.PIPE,
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE,
        )
        proc.stdin.write(bytes(src, encoding="utf-8"))
        proc.stdin.close()
        await proc.wait()
        if err := await proc.stderr.read():
            raise TypstCompilationError(bytes.decode(err, encoding="utf-8"))
        return await proc.stdout.read()

    async def _compile_flashcard(self, card: Flashcard):
        front = await self._compile(self.preamble + "\n" + card.as_typst(True))
        back = await self._compile(self.preamble + "\n" + card.as_typst(False))
        card.set_svgs(front, back)

    async def compile_flashcards(self, cards: List[Flashcard]):
        semaphore = asyncio.Semaphore(self.max_processes)

        async def compile_coro(card):
            async with semaphore:
                return await self._compile_flashcard(card)

        return await asyncio.gather(*(compile_coro(card) for card in cards))

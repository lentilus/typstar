import asyncio
import base64
from typing import List

import aiohttp

from .flashcard import Flashcard


class AnkiConnectError(Exception):
    pass


class AnkiConnectApi:
    url: str

    def __init__(self, url="http://127.0.0.1:8765"):
        self.url = url

    async def push_flashcards(self, cards: List[Flashcard]):
        add = []
        update = []

        for card in cards:
            if card.is_new():
                add.append(card)
            else:
                update.append(card)
        await asyncio.gather(self._add(add), self._update(update))

    async def _request_api(self, action, **params):
        async with aiohttp.ClientSession() as session:
            data = {
                "action": action,
                "version": 6,
                "params": params,
            }
            try:
                async with session.post(url=self.url, json=data) as response:
                    result = await response.json(encoding="utf-8")
                    if err := result["error"]:
                        raise AnkiConnectError(err)
                    return result["result"]
            except aiohttp.ClientError as e:
                raise AnkiConnectError(f"Could not connect to Anki: {e}")

    async def _update_note_model(self, card: Flashcard):
        await self._request_api("updateNoteModel", note=card.as_anki_model())

    async def _store_media(self, card):
        await self._request_api("storeMediaFile",
                                filename=card.svg_filename(True),
                                data=base64.b64encode(card.svg_front).decode())
        await self._request_api("storeMediaFile",
                                filename=card.svg_filename(False),
                                data=base64.b64encode(card.svg_back).decode())

    async def _add(self, cards: List[Flashcard]):
        notes = []
        for card in cards:
            data = {
                "deckName": card.deck,
                "options": {
                    "allowDuplicate": True,  # won't work with svgs
                },
            }
            data.update(card.as_anki_model(True))
            notes.append(data)
        result = await self._request_api("addNotes", notes=notes)
        for idx, note_id in enumerate(result):
            cards[idx].update_id(note_id)
        await self._update(cards)

    async def _update(self, cards: List[Flashcard]):
        await asyncio.gather(*(self._update_note_model(card) for card in cards),
                             *(self._store_media(card) for card in cards))

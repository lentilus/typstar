import asyncio
import base64
from collections import defaultdict
from typing import Iterable, List

import aiohttp

from .flashcard import Flashcard


async def _gather_exceptions(coroutines):
    for result in await asyncio.gather(*coroutines, return_exceptions=True):
        if isinstance(result, Exception):
            raise result


class AnkiConnectError(Exception):
    pass


class AnkiConnectApi:
    url: str
    api_key: str
    semaphore: asyncio.Semaphore

    def __init__(self, url: str, api_key: str):
        self.url = url
        self.api_key = api_key
        self.semaphore = asyncio.Semaphore(2)  # increase in case Anki implements multithreading

    async def push_flashcards(self, cards: Iterable[Flashcard]):
        add: dict[str, List[Flashcard]] = defaultdict(list)
        update: dict[str, List[Flashcard]] = defaultdict(list)
        n_add: int = 0
        n_update: int = 0

        for card in cards:
            if card.is_new():
                add[card.deck].append(card)
                n_add += 1
            else:
                update[card.deck].append(card)
                n_update += 1

        print(
            f"Pushing {n_add} new flashcards and {n_update} updated flashcards to Anki...",
            flush=True,
        )
        await self._create_required_decks({*add.keys(), *update.keys()})
        await self._add_new_cards(add)
        await _gather_exceptions(
            [
                *self._update_cards_requests(add),
                *self._update_cards_requests(update, True),
            ]
        )

    async def _request_api(self, action, **params):
        async with aiohttp.ClientSession() as session:
            data = {
                "action": action,
                "key": self.api_key,
                "params": params,
                "version": 6,
            }
            try:
                async with self.semaphore:
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
        await self._request_api(
            "storeMediaFile",
            filename=card.svg_filename(True),
            data=base64.b64encode(card.svg_front).decode(),
        )
        await self._request_api(
            "storeMediaFile",
            filename=card.svg_filename(False),
            data=base64.b64encode(card.svg_back).decode(),
        )

    async def _change_deck(self, deck: str, cards: List[int]):
        await self._request_api("changeDeck", deck=deck, cards=cards)

    async def _add_new_cards(self, cards_map: dict[str, List[Flashcard]]):
        notes: List[Flashcard] = []
        notes_data: List[dict] = []
        for cards in cards_map.values():
            for card in cards:
                data = {
                    "deckName": card.deck,
                    "options": {
                        "allowDuplicate": True,  # won't work with svgs
                    },
                }
                data.update(card.as_anki_model(True))
                notes.append(card)
                notes_data.append(data)
        result = await self._request_api("addNotes", notes=notes_data)
        for idx, note_id in enumerate(result):
            notes[idx].update_id(note_id)

    async def _create_required_decks(self, required: Iterable[str]):
        existing = await self._request_api("deckNamesAndIds")
        requests = []
        for deck in required:
            if deck not in existing:
                requests.append(self._request_api("createDeck", deck=deck))
        await _gather_exceptions(requests)

    def _update_cards_requests(
        self, cards_map: dict[str, List[Flashcard]], update_deck: bool = True
    ):
        requests = []
        for deck, cards in cards_map.items():
            card_ids = []
            for card in cards:
                requests.append(self._update_note_model(card))
                requests.append(self._store_media(card))
                if update_deck:
                    card_ids.append(card.note_id)
            if card_ids:
                requests.append(self._change_deck(deck, card_ids))
        return requests

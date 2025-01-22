#!/usr/bin/env python3

import asyncio
import json
import websockets
import logging
from pygments import highlight
from pygments.lexers import JsonLexer
from pygments.formatters import Terminal256Formatter

logging.basicConfig(level=logging.ERROR)
logger = logging.getLogger(__name__)

class PhoenixClient:
    def __init__(self, websocket_url="ws://localhost:4000/socket/websocket"):
        self.websocket_url = websocket_url
        self.ref = 0

    def _create_message(self, event, topic, payload=None):
        self.ref += 1
        return json.dumps({
            "event": event,
            "topic": topic,
            "payload": payload or {},
            "ref": str(self.ref)
        })

    async def connect(self):
        try:
            self.websocket = await websockets.connect(self.websocket_url)
            await self.websocket.send(self._create_message(
                "phx_join",
                "bookmarks:firehose"
            ))
            await self._listen()
        except Exception as e:
            logger.error(f"Error: {e}")

    async def _listen(self):
        try:
            while True:
                message = await self.websocket.recv()
                data = json.loads(message)

                if data["event"] == "bookmark_created":
                    json_str = json.dumps(data["payload"], indent=2)
                    colored_json = highlight(
                        json_str,
                        JsonLexer(),
                        Terminal256Formatter()
                    )
                    print(colored_json)

        except Exception as e:
            logger.error(f"Error processing message: {e}")

if __name__ == "__main__":
    asyncio.run(PhoenixClient().connect())
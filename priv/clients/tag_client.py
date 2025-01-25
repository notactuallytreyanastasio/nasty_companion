#!/usr/bin/env python3

import asyncio
import json
import websockets
import logging
import sys
from datetime import datetime
from pygments import highlight
from pygments.lexers import JsonLexer
from pygments.formatters import Terminal256Formatter

logging.basicConfig(level=logging.ERROR)
logger = logging.getLogger(__name__)

class TagClient:
    def __init__(self, tag, websocket_url="ws://localhost:4000/socket/websocket"):
        self.websocket_url = websocket_url
        self.tag = tag.lower()
        self.ref = 0

    def _create_message(self, event, payload=None):
        self.ref += 1
        return json.dumps({
            "event": event,
            "topic": f"bookmarks:tag:{self.tag}",
            "payload": payload or {},
            "ref": str(self.ref)
        })

    async def connect(self):
        try:
            self.websocket = await websockets.connect(self.websocket_url)

            # Join the tag-specific channel
            await self.websocket.send(self._create_message("phx_join"))

            # Start listening for messages
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
    if len(sys.argv) != 2:
        print("Usage: python tag_client.py <tag>")
        print("Example: python tag_client.py python")
        sys.exit(1)

    tag = sys.argv[1]
    asyncio.run(TagClient(tag).connect())
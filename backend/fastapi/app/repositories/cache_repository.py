import logging
from datetime import datetime, timedelta
from typing import Any, Optional
from motor.motor_asyncio import AsyncIOMotorDatabase

logger = logging.getLogger(__name__)

class CacheRepository:
    def __init__(self, db: AsyncIOMotorDatabase):
        self.collection = db["llm_cache"]

    async def get(self, key: str) -> Optional[Any]:
        """Retrieve a cached response if it exists and is not expired (optional)."""
        doc = await self.collection.find_one({"key": key})
        if doc:
            return doc.get("response")
        return None

    async def set(self, key: str, response: Any):
        """Store a response in the cache."""
        try:
            await self.collection.update_one(
                {"key": key},
                {
                    "$set": {
                        "response": response,
                        "timestamp": datetime.now()
                    }
                },
                upsert=True
            )
        except Exception as e:
            logger.error(f"Error saving to LLM cache: {e}")

    async def initialize(self):
        """Create indexes for the cache."""
        await self.collection.create_index("key", unique=True)
        # Optional: Add TTL index if we want cache to expire
        # await self.collection.create_index("timestamp", expireAfterSeconds=86400 * 7) # 7 days

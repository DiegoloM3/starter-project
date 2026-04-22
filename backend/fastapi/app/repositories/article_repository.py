import logging
from typing import List, Optional
from motor.motor_asyncio import AsyncIOMotorDatabase
from app.models.article import Article, ArticleCreate

logger = logging.getLogger(__name__)

class ArticleRepository:
    def __init__(self, db: AsyncIOMotorDatabase):
        self.collection = db["articles"]

    async def get_all(self, category: str = None, limit: int = 10) -> List[Article]:
        query = {}
        if category:
            query["category"] = category
            
        cursor = self.collection.find(query, {"_id": 0}).sort("publishedAt", -1).limit(limit)
        items = await cursor.to_list(length=limit)
        return [Article(**item) for item in items]


    async def create(self, article: ArticleCreate) -> Article:
        doc = article.model_dump()
        logger.debug(f"Saving document to Mongo: {doc}")
        try:
            # Ensure publishedAt is a datetime and not a string
            if isinstance(doc.get("publishedAt"), str):
                from datetime import datetime
                doc["publishedAt"] = datetime.fromisoformat(doc["publishedAt"].replace("Z", "+00:00"))
            
            await self.collection.update_one(
                {"articleId": article.articleId},
                {"$set": doc},
                upsert=True
            )
            return Article(**doc)
        except Exception as e:
            logger.error(f"MongoDB Error: {e}")
            raise

    async def get_by_id(self, article_id: str) -> Optional[Article]:
        doc = await self.collection.find_one({"articleId": article_id}, {"_id": 0})
        return Article(**doc) if doc else None


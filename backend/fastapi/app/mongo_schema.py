from __future__ import annotations

from typing import Any

from pymongo import ASCENDING, DESCENDING


ARTICLE_VALIDATOR = {
    "$jsonSchema": {
        "bsonType": "object",
        "required": [
            "author",
            "title",
            "description",
            "url",
            "urlToImage",
            "publishedAt",
            "content",
            "source",
            "category",
            "views",
            "readTime",
            "tokensEarned",
        ],
        "properties": {
            "author": {"bsonType": "string"},
            "title": {"bsonType": "string"},
            "description": {"bsonType": "string"},
            "url": {"bsonType": "string"},
            "urlToImage": {"bsonType": "string"},
            "publishedAt": {"bsonType": "date"},
            "content": {"bsonType": "string"},
            "source": {"bsonType": "string"},
            "category": {"bsonType": "string"},
            "views": {"bsonType": ["int", "long", "double"]},
            "readTime": {"bsonType": ["int", "long", "double"]},
            "tokensEarned": {"bsonType": ["int", "long", "double"]},
            "articleId": {"bsonType": "string"},
            "sourceId": {"bsonType": ["string", "null"]},
            "expectedReadTime": {"bsonType": ["int", "long", "double", "null"]},
            "qualityScore": {"bsonType": ["int", "long", "double", "null"]},
            "fraudScore": {"bsonType": ["int", "long", "double", "null"]},
            "rewardEpoch": {"bsonType": ["int", "long", "null"]},
            "verifiedImpressionCount": {"bsonType": ["int", "long", "null"]},
        },
    }
}


async def initialize_mongo_schema(db: Any) -> None:
    existing = await db.list_collection_names()
    if "articles" not in existing:
        await db.create_collection("articles", validator=ARTICLE_VALIDATOR)
    else:
        await db.command(
            {
                "collMod": "articles",
                "validator": ARTICLE_VALIDATOR,
                "validationLevel": "moderate",
            }
        )

    await db["articles"].create_index([("publishedAt", DESCENDING)])
    await db["articles"].create_index([("category", ASCENDING), ("publishedAt", DESCENDING)])
    await db["articles"].create_index([("author", ASCENDING)])
    await db["articles"].create_index([("articleId", ASCENDING)], unique=True, sparse=True)
    
    # LLM Cache Indexes
    await db["llm_cache"].create_index([("key", ASCENDING)], unique=True)
    await db["llm_cache"].create_index([("timestamp", DESCENDING)])


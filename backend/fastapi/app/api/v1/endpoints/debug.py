from fastapi import APIRouter, Request, HTTPException
from typing import Any, Dict, List

router = APIRouter()

@router.get("/db-stats")
async def get_db_stats(request: Request):
    """
    Get MongoDB collection statistics for debugging.
    """
    db = request.app.state.db
    stats = {}
    
    collections = ["articles", "users", "rewards", "read_events"]
    for coll in collections:
        count = await db[coll].count_documents({})
        stats[coll] = {"count": count}
        
    return {
        "status": "connected",
        "database": db.name,
        "collections": stats
    }

@router.get("/raw-article/{article_id}")
async def get_raw_article(article_id: str, request: Request):
    """
    Get the exact BSON document from MongoDB without Pydantic filtering.
    """
    db = request.app.state.db
    doc = await db["articles"].find_one({"articleId": article_id})
    if not doc:
        raise HTTPException(status_code=404, detail="Article not found in Mongo")
    
    # Convert ObjectId to string for JSON serialization
    if "_id" in doc:
        doc["_id"] = str(doc["_id"])
        
    return doc

@router.get("/recent-logs")
async def get_recent_logs(limit: int = 10):
    """
    Stub for retrieving system logs if stored in DB.
    """
    return {"message": "Logs retrieval not yet implemented in DB."}

from fastapi import APIRouter, Depends, Request
from app.services.ingestion_service import IngestionService
from app.repositories.article_repository import ArticleRepository
from app.repositories.cache_repository import CacheRepository

router = APIRouter()

def get_ingestion_service(request: Request) -> IngestionService:
    db = request.app.state.db
    repository = ArticleRepository(db)
    cache_repo = CacheRepository(db)
    return IngestionService(repository, cache_repo)


@router.post("/trigger")
async def trigger_ingestion(service: IngestionService = Depends(get_ingestion_service)):
    """
    Manually triggers the news ingestion process from RSS sources.
    Uses AI to refactor the content and assigns stock images if missing.
    """
    new_articles = await service.ingest_all()
    return {
        "status": "success",
        "new_articles_count": new_articles,
        "message": f"Successfully ingested {new_articles} new articles."
    }

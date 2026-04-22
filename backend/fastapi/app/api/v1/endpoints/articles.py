from typing import List
from fastapi import APIRouter, Depends, HTTPException, Request
from app.models.article import Article, ArticleCreate
from app.services.article_service import ArticleService
from app.repositories.article_repository import ArticleRepository

router = APIRouter()

def get_article_service(request: Request) -> ArticleService:
    # Access the database from app state
    db = request.app.state.db
    repository = ArticleRepository(db)
    return ArticleService(repository)

@router.get("/", response_model=List[Article])
async def list_articles(
    category: str = None,
    limit: int = 10, 
    service: ArticleService = Depends(get_article_service)
):
    return await service.list_latest_articles(category=category, limit=limit)


@router.post("/", response_model=Article)
async def create_article(article: ArticleCreate, service: ArticleService = Depends(get_article_service)):
    return await service.create_article(article)

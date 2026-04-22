from typing import List
from app.repositories.article_repository import ArticleRepository
from app.models.article import Article, ArticleCreate

class ArticleService:
    def __init__(self, repository: ArticleRepository):
        self.repository = repository

    async def list_latest_articles(self, category: str = None, limit: int = 10) -> List[Article]:
        return await self.repository.get_all(category=category, limit=limit)


    async def create_article(self, article: ArticleCreate) -> Article:
        # Add any business logic here (e.g. read time calculation if not provided)
        if article.readTime == 0 and len(article.content) > 0:
            # Simple heuristic: 200 words per minute
            words = len(article.content.split())
            article.readTime = max(1, words // 200)
        
        return await self.repository.create(article)

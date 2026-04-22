from datetime import datetime
from typing import Optional
from pydantic import BaseModel, Field

class ArticleBase(BaseModel):
    author: str
    title: str
    description: str
    url: str
    urlToImage: str
    publishedAt: datetime
    content: str
    source: str
    category: str
    views: int = 0
    readTime: int = 0
    tokensEarned: float = 0.0

class ArticleCreate(ArticleBase):
    articleId: str
    sourceId: Optional[str] = None
    expectedReadTime: Optional[int] = None
    qualityScore: Optional[float] = None
    rewardEpoch: Optional[int] = None

class Article(ArticleBase):
    articleId: str
    sourceId: Optional[str] = None
    expectedReadTime: Optional[int] = None
    qualityScore: Optional[float] = None
    fraudScore: Optional[float] = None
    rewardEpoch: Optional[int] = None
    verifiedImpressionCount: int = 0

    class Config:
        from_attributes = True

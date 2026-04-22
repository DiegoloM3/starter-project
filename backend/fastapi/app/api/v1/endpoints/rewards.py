from fastapi import APIRouter, Depends, Request
from app.models.reward import ClaimRequest
from app.services.reward_service import RewardService
from app.repositories.reward_repository import RewardRepository
from app.repositories.article_repository import ArticleRepository

router = APIRouter()

def get_reward_service(request: Request) -> RewardService:
    db = request.app.state.db
    reward_repo = RewardRepository(db)
    article_repo = ArticleRepository(db)
    return RewardService(reward_repo, article_repo)

@router.post("/claim")
async def claim_reward(request: ClaimRequest, service: RewardService = Depends(get_reward_service)):
    """
    Claim tokens for reading an article. 
    This is an off-chain record that will be snapshotted for the testnet distribution.
    """
    return await service.claim_reading_reward(request.userId, request.articleId, request.readTime)


@router.get("/balance/{user_id}")
async def get_balance(user_id: str, service: RewardService = Depends(get_reward_service)):
    """
    Get current off-chain SYM token balance.
    """
    return await service.get_balance(user_id)

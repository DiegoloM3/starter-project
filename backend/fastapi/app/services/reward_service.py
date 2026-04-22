from app.repositories.reward_repository import RewardRepository
from app.repositories.article_repository import ArticleRepository
from fastapi import HTTPException

class RewardService:
    def __init__(self, reward_repo: RewardRepository, article_repo: ArticleRepository):
        self.reward_repo = reward_repo
        self.article_repo = article_repo

    async def claim_reading_reward(self, user_id: str, article_id: str, read_time: float = 0.0):
        # 1. Check if article exists
        article = await self.article_repo.get_by_id(article_id)
        if not article:
            raise HTTPException(status_code=404, detail="Article not found")

        # 2. Basic Scoring Layer: Minimum read time (e.g. 10 seconds for alpha)
        MIN_READ_TIME = 10.0
        if read_time < MIN_READ_TIME:
            import logging
            logging.warning(f"Recompensa rechazada para {user_id}: tiempo insuficiente ({read_time}s)")
            raise HTTPException(
                status_code=400, 
                detail=f"Lectura demasiado breve para recompensa. Mínimo: {MIN_READ_TIME}s"
            )

        # 3. Check if already claimed for this article
        user_reward = await self.reward_repo.get_user_reward(user_id)
        for tx in user_reward.transactions:
            if tx.referenceId == article_id and tx.reason == "Article Read":
                raise HTTPException(status_code=400, detail="Reward already claimed for this article")

        # 4. Apply reward
        reward_amount = 5.0
        return await self.reward_repo.add_reward(
            user_id=user_id,
            amount=reward_amount,
            reason="Article Read",
            reference_id=article_id
        )


    async def get_balance(self, user_id: str):
        user_reward = await self.reward_repo.get_user_reward(user_id)
        return {
            "userId": user_id,
            "balance": user_reward.totalBalance,
            "transactionCount": len(user_reward.transactions)
        }

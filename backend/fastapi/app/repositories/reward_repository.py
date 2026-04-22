from motor.motor_asyncio import AsyncIOMotorDatabase
from app.models.reward import UserReward, RewardTransaction
from datetime import datetime
from typing import Optional

class RewardRepository:
    def __init__(self, db: AsyncIOMotorDatabase):
        self.collection = db["rewards"]

    async def get_user_reward(self, user_id: str) -> UserReward:
        doc = await self.collection.find_one({"userId": user_id})
        if doc:
            return UserReward(**doc)
        return UserReward(userId=user_id)

    async def add_reward(self, user_id: str, amount: float, reason: str, reference_id: str = None):
        transaction = RewardTransaction(
            amount=amount,
            reason=reason,
            referenceId=reference_id,
            timestamp=datetime.now()
        )
        
        await self.collection.update_one(
            {"userId": user_id},
            {
                "$inc": {"totalBalance": amount},
                "$push": {"transactions": transaction.model_dump()},
                "$set": {"lastUpdated": datetime.now()}
            },
            upsert=True
        )
        return transaction

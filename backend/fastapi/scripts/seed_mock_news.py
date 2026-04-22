from __future__ import annotations

from datetime import UTC, datetime, timedelta
from pathlib import Path
import sys

from pymongo import MongoClient, UpdateOne

# Ensure `/app` is importable when script runs as `python scripts/...`.
sys.path.append(str(Path(__file__).resolve().parents[1]))

from app.config import settings


def main() -> None:
    client = MongoClient(settings.mongodb_url)
    db = client[settings.mongodb_db_name]
    articles = db["articles"]

    now = datetime.now(UTC)
    mock_docs = [
        {
            "articleId": "mock-001",
            "author": "Symmetry Labs",
            "title": "Mercados reaccionan al nuevo plan de innovación energética",
            "description": "Un resumen de los anuncios públicos y su impacto inicial.",
            "url": "https://example.com/news/mock-001",
            "urlToImage": "https://picsum.photos/seed/mock001/1200/800",
            "publishedAt": now - timedelta(hours=6),
            "content": "Analistas reportan una mejora en expectativas tras anuncios coordinados.",
            "source": "Symmetry Daily",
            "sourceId": "symmetry-daily",
            "category": "economy",
            "views": 0,
            "readTime": 4,
            "expectedReadTime": 4,
            "tokensEarned": 0,
            "qualityScore": 0.75,
            "fraudScore": 0.01,
            "rewardEpoch": 1,
            "verifiedImpressionCount": 0,
        },
        {
            "articleId": "mock-002",
            "author": "Editor Team",
            "title": "Avances en IA aplicada a periodismo explicativo",
            "description": "Casos de uso reales y límites operativos para redacciones.",
            "url": "https://example.com/news/mock-002",
            "urlToImage": "https://picsum.photos/seed/mock002/1200/800",
            "publishedAt": now - timedelta(hours=4),
            "content": "Equipos híbridos combinan investigación humana con herramientas de IA.",
            "source": "Tech Brief",
            "sourceId": "tech-brief",
            "category": "technology",
            "views": 0,
            "readTime": 5,
            "expectedReadTime": 5,
            "tokensEarned": 0,
            "qualityScore": 0.82,
            "fraudScore": 0.02,
            "rewardEpoch": 1,
            "verifiedImpressionCount": 0,
        },
        {
            "articleId": "mock-003",
            "author": "Marina Ortega",
            "title": "Ciudades piloto prueban transporte autónomo nocturno",
            "description": "Resultados preliminares de seguridad y aceptación ciudadana.",
            "url": "https://example.com/news/mock-003",
            "urlToImage": "https://picsum.photos/seed/mock003/1200/800",
            "publishedAt": now - timedelta(hours=2),
            "content": "El plan incluye métricas semanales y auditoría externa independiente.",
            "source": "Urban Report",
            "sourceId": "urban-report",
            "category": "society",
            "views": 0,
            "readTime": 3,
            "expectedReadTime": 3,
            "tokensEarned": 0,
            "qualityScore": 0.7,
            "fraudScore": 0.01,
            "rewardEpoch": 1,
            "verifiedImpressionCount": 0,
        },
        {
            "articleId": "mock-004",
            "author": "Global Desk",
            "title": "Nuevos acuerdos regionales impulsan cadenas de suministro",
            "description": "La coordinación logística reduce tiempos y costos operativos.",
            "url": "https://example.com/news/mock-004",
            "urlToImage": "https://picsum.photos/seed/mock004/1200/800",
            "publishedAt": now - timedelta(minutes=45),
            "content": "Los actores industriales prevén estabilización de inventarios este trimestre.",
            "source": "World Ledger",
            "sourceId": "world-ledger",
            "category": "business",
            "views": 0,
            "readTime": 4,
            "expectedReadTime": 4,
            "tokensEarned": 0,
            "qualityScore": 0.78,
            "fraudScore": 0.01,
            "rewardEpoch": 1,
            "verifiedImpressionCount": 0,
        },
    ]

    operations = [
        UpdateOne({"articleId": doc["articleId"]}, {"$set": doc}, upsert=True) for doc in mock_docs
    ]
    result = articles.bulk_write(operations, ordered=False)
    total = articles.count_documents({})
    print(
        f"seeded={len(mock_docs)} upserted={result.upserted_count} modified={result.modified_count} total={total}"
    )


if __name__ == "__main__":
    main()

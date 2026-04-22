# 12_DATA_MODEL.md

## 1. Purpose

Este documento define el schema de MongoDB que reemplaza a Firebase Firestore.
El diseño es equivalente en semántica, adaptado al modelo de documentos de Mongo.

---

## 2. Principios de Diseño

### 2.1 Document-first
MongoDB es una base de datos orientada a documentos.
Se prefiere **embed** sobre referencias cuando los datos se leen juntos.
Se usan **referencias** cuando los datos crecen indefinidamente (comentarios, eventos).

### 2.2 Separación de concerns
Los campos derivados (scores, rewards) **no** se almacenan en el artículo base.
Viven en colecciones separadas para poder auditarse y recalcularse.

### 2.3 Escalabilidad horizontal
Todos los documentos tienen `_id` como ObjectId de MongoDB.
Se definen índices para las queries más frecuentes.

---

## 3. Colecciones

### 3.1 `articles`

Colección principal de contenido.

```json
{
  "_id": "ObjectId",
  "author_id": "string (ref → users._id)",
  "author_name": "string",
  "title": "string",
  "description": "string",
  "content": "string",
  "source": "string",
  "category": "string",
  "url": "string | null",
  "thumbnail_url": "string | null",
  "published_at": "ISODate",
  "created_at": "ISODate",
  "updated_at": "ISODate",
  "read_time": 3,
  "views": 142,
  "verified_impressions": 89,
  "quality_score": 0.74,
  "fraud_score": 0.02,
  "reward_epoch": 12,
  "tags": ["política", "economía"],
  "language": "es",
  "is_deleted": false
}
```

**Notas:**
- `tokensEarned` **no existe aquí** — es un valor calculado en `reward_distributions`
- `views` es un contador bruto (incrementado en cada lectura)
- `verified_impressions` es el contador filtrado (solo lecturas válidas)
- `quality_score` y `fraud_score` son derivados del motor de rewards

**Índices:**
```js
db.articles.createIndex({ "published_at": -1 })
db.articles.createIndex({ "category": 1, "published_at": -1 })
db.articles.createIndex({ "author_id": 1 })
db.articles.createIndex({ "reward_epoch": 1 })
```

---

### 3.2 `users`

Perfil y autenticación del usuario.

```json
{
  "_id": "ObjectId",
  "email": "string (unique)",
  "username": "string (unique)",
  "password_hash": "string",
  "display_name": "string",
  "avatar_url": "string | null",
  "bio": "string | null",
  "created_at": "ISODate",
  "updated_at": "ISODate",
  "is_journalist": false,
  "is_verified": false,
  "reputation_score": 0.85,
  "total_tokens_earned": 0,
  "token_balance": 0,
  "articles_published": 0,
  "preferences": {
    "categories": ["tecnología", "ciencia"],
    "language": "es",
    "notifications_enabled": true
  }
}
```

**Notas:**
- `password_hash` usa bcrypt
- `reputation_score` es dinámico, recalculado periódicamente
- `token_balance` se actualiza tras cada distribución semanal

**Índices:**
```js
db.users.createIndex({ "email": 1 }, { unique: true })
db.users.createIndex({ "username": 1 }, { unique: true })
```

---

### 3.3 `read_events`

Eventos de lectura atómicos. Fuente de verdad para el reward engine.

```json
{
  "_id": "ObjectId",
  "user_id": "string (ref → users._id)",
  "article_id": "string (ref → articles._id)",
  "event_type": "READ_PROGRESS | READ_COMPLETE | ARTICLE_OPEN | SCROLL",
  "timestamp": "ISODate",
  "session_id": "string",
  "metadata": {
    "scroll_depth": 0.65,
    "active_time_seconds": 87,
    "interaction_count": 3,
    "device_type": "android",
    "app_version": "1.0.0"
  },
  "epoch": 12,
  "is_flagged": false
}
```

**Notas:**
- No se editan. Solo inserción.
- `epoch` indica la semana de distribución a la que pertenece
- `is_flagged` se activa si el scoring detecta comportamiento sospechoso

**Índices:**
```js
db.read_events.createIndex({ "user_id": 1, "epoch": 1 })
db.read_events.createIndex({ "article_id": 1, "epoch": 1 })
db.read_events.createIndex({ "timestamp": -1 })
```

---

### 3.4 `user_scores`

Score semanal por usuario. Calculado al final de cada epoch.

```json
{
  "_id": "ObjectId",
  "user_id": "string",
  "epoch": 12,
  "calculated_at": "ISODate",
  "read_score": 0.72,
  "engagement_score": 0.54,
  "diversity_score": 0.68,
  "trust_score": 0.91,
  "fraud_penalty": 0.0,
  "final_weight": 0.81,
  "articles_read": 14,
  "valid_reads": 11,
  "comments_made": 3,
  "sources_consumed": 6
}
```

**Índices:**
```js
db.user_scores.createIndex({ "user_id": 1, "epoch": -1 })
db.user_scores.createIndex({ "epoch": 1 })
```

---

### 3.5 `reward_distributions`

Registro de cada distribución semanal de tokens.

```json
{
  "_id": "ObjectId",
  "epoch": 12,
  "week_start": "ISODate",
  "week_end": "ISODate",
  "executed_at": "ISODate",
  "total_pool": 480769,
  "emission": 460000,
  "fees_collected": 20769,
  "total_weight": 8423.5,
  "distributions": [
    {
      "user_id": "string",
      "weight": 0.81,
      "tokens_earned": 142.3
    }
  ],
  "status": "COMPLETED | PENDING | FAILED"
}
```

**Notas:**
- Un único documento por epoch
- `distributions` es un array embebido para queries simples
- Si el número de usuarios crece mucho, migrar a colección separada

---

### 3.6 `comments` (opcional MVP)

```json
{
  "_id": "ObjectId",
  "article_id": "string",
  "user_id": "string",
  "user_name": "string",
  "content": "string",
  "created_at": "ISODate",
  "upvotes": 0,
  "downvotes": 0,
  "is_flagged": false,
  "quality_score": 0.0
}
```

**Índices:**
```js
db.comments.createIndex({ "article_id": 1, "created_at": -1 })
```

---

## 4. Mapa de Equivalencias Firestore → MongoDB

| Firestore | MongoDB |
|---|---|
| Collection | Collection |
| Document | Document |
| Subcollection | Colección separada con referencia |
| Auto-id | ObjectId |
| Timestamp | ISODate |
| Security Rules | FastAPI middleware + validaciones |
| Realtime listeners | Long-polling o WebSocket (futuro) |
| Cloud Storage ref | Campo `thumbnail_url` con URL propia |

---

## 5. Estrategia de Índices

Los índices más críticos para el MVP:

```js
// Queries más frecuentes del feed principal
db.articles.createIndex({ published_at: -1 })
db.articles.createIndex({ category: 1, published_at: -1 })

// Lookup de usuario por credenciales
db.users.createIndex({ email: 1 }, { unique: true })

// Agregación de eventos por época (scheduler semanal)
db.read_events.createIndex({ epoch: 1, user_id: 1 })
```

---

## 6. Migraciones

Para el MVP no se necesita un sistema formal de migraciones.
Se recomienda mantener un directorio `migrations/` con scripts numerados:

```
migrations/
├── 001_create_indexes.js
├── 002_add_reward_epoch_field.js
└── 003_backfill_read_time.js
```

Ejecutar con `mongosh`:
```bash
mongosh symmetry migrations/001_create_indexes.js
```

---

## 7. Seed Data

Para desarrollo, un script de seed:

```python
# scripts/seed.py
import asyncio
from motor.motor_asyncio import AsyncIOMotorClient
from datetime import datetime

async def seed():
    client = AsyncIOMotorClient("mongodb://localhost:27017")
    db = client["symmetry"]

    await db.articles.insert_many([
        {
            "author_name": "Demo Author",
            "title": "Artículo de prueba",
            "description": "Descripción del artículo de prueba para desarrollo.",
            "content": "Contenido completo del artículo...",
            "source": "Symmetry Demo",
            "category": "tecnología",
            "published_at": datetime.utcnow(),
            "created_at": datetime.utcnow(),
            "updated_at": datetime.utcnow(),
            "views": 0,
            "read_time": 2,
            "is_deleted": False
        }
    ])
    print("Seed completado.")

asyncio.run(seed())
```

---

## 8. MVP Scope

**Colecciones requeridas para el assignment base:**
- `articles` — lectura, escritura, listado
- `users` — registro, login

**Colecciones para la extensión de rewards:**
- `read_events`
- `user_scores`
- `reward_distributions`

**Colecciones opcionales:**
- `comments`

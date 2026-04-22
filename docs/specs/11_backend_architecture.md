# 11_BACKEND_ARCHITECTURE.md

## 1. Context and Motivation

El assignment original usa Firebase Firestore como backend.
Este documento especifica una alternativa **self-hosted** basada en:

- **FastAPI** (Python) — capa de API REST
- **MongoDB** — base de datos NoSQL (reemplaza Firestore)
- **Caddy** — reverse proxy con HTTPS automático
- **Motor** — driver async de MongoDB para Python

### 1.1 Por qué este stack

| Decisión | Alternativa descartada | Razón |
|---|---|---|
| FastAPI | Flask, Django | Async nativo, tipado con Pydantic, OpenAPI automático |
| MongoDB | PostgreSQL | Schema flexible, mapeo directo a los documentos de Firestore |
| Motor | PyMongo sync | Compatible con FastAPI async, sin bloquear el event loop |
| Caddy | Nginx | HTTPS automático (Let's Encrypt), Caddyfile legible |

---

## 2. Principios de Diseño

### 2.1 Clean Architecture en el backend

El backend replica la misma separación de capas que el frontend Flutter:

```
API Layer       →  routers FastAPI (equivale a la Presentation Layer)
Domain Layer    →  use cases, entidades, interfaces de repositorio
Data Layer      →  implementaciones MongoDB con Motor
```

### 2.2 El frontend Flutter NO cambia de arquitectura

Solo cambia la implementación del Data Layer:

- **Antes:** `cloud_firestore` SDK
- **Después:** cliente HTTP (`dio`) apuntando a la API REST de Python

BLoC, Cubits, Use Cases y Entities del frontend permanecen intactos.

### 2.3 Stateless API

La API no guarda estado en memoria. Todo el estado vive en MongoDB.
Esto permite escalar horizontalmente si fuera necesario.

---

## 3. Estructura de Directorios del Backend

```
backend/
├── app/
│   ├── main.py                  # Entrada FastAPI, registro de routers
│   ├── config.py                # Variables de entorno (MongoDB URI, secretos)
│   │
│   ├── domain/                  # Capa de dominio (pura, sin dependencias)
│   │   ├── entities/
│   │   │   ├── article.py       # Entidad Article
│   │   │   ├── user.py          # Entidad User
│   │   │   └── read_event.py    # Entidad ReadEvent
│   │   ├── repositories/        # Interfaces (contratos)
│   │   │   ├── article_repo.py
│   │   │   └── user_repo.py
│   │   └── use_cases/           # Lógica de negocio
│   │       ├── create_article.py
│   │       ├── get_articles.py
│   │       ├── get_article_by_id.py
│   │       └── record_read_event.py
│   │
│   ├── data/                    # Capa de datos (implementaciones)
│   │   ├── database.py          # Conexión Motor / MongoDB
│   │   ├── models/              # Documentos MongoDB (Pydantic)
│   │   │   ├── article_model.py
│   │   │   └── user_model.py
│   │   └── repositories/        # Implementaciones concretas
│   │       ├── mongo_article_repo.py
│   │       └── mongo_user_repo.py
│   │
│   └── api/                     # Capa API (routers FastAPI)
│       ├── deps.py              # Dependency injection
│       ├── routes/
│       │   ├── articles.py      # CRUD artículos
│       │   ├── users.py         # Autenticación y perfil
│       │   └── events.py        # Read events para rewards
│       └── schemas/             # Request/Response Pydantic schemas
│           ├── article_schema.py
│           └── user_schema.py
│
├── Caddyfile                    # Configuración del reverse proxy
├── docker-compose.yml           # Orquestación local
├── requirements.txt
└── .env.example
```

---

## 4. Capa de Dominio

### 4.1 Entidad Article

```python
# app/domain/entities/article.py
from dataclasses import dataclass
from datetime import datetime
from typing import Optional

@dataclass
class Article:
    id: str
    author_id: str
    author_name: str
    title: str
    description: str
    content: str
    source: str
    category: str
    url: Optional[str]
    thumbnail_url: Optional[str]
    published_at: datetime
    created_at: datetime
    updated_at: datetime
    views: int = 0
    read_time: int = 0          # minutos estimados
    quality_score: float = 0.0  # derivado, no manual
    fraud_score: float = 0.0    # derivado, no manual
    reward_epoch: Optional[int] = None
    verified_impressions: int = 0
```

### 4.2 Interfaz de Repositorio

```python
# app/domain/repositories/article_repo.py
from abc import ABC, abstractmethod
from typing import List, Optional
from app.domain.entities.article import Article

class ArticleRepository(ABC):

    @abstractmethod
    async def get_all(self, limit: int, offset: int, category: Optional[str]) -> List[Article]:
        ...

    @abstractmethod
    async def get_by_id(self, article_id: str) -> Optional[Article]:
        ...

    @abstractmethod
    async def create(self, article: Article) -> Article:
        ...

    @abstractmethod
    async def update(self, article_id: str, data: dict) -> Optional[Article]:
        ...

    @abstractmethod
    async def delete(self, article_id: str) -> bool:
        ...
```

### 4.3 Use Cases

```python
# app/domain/use_cases/create_article.py
from app.domain.entities.article import Article
from app.domain.repositories.article_repo import ArticleRepository

class CreateArticleUseCase:
    def __init__(self, repo: ArticleRepository):
        self._repo = repo

    async def execute(self, article: Article) -> Article:
        # Reglas de negocio: validaciones, enriquecimiento
        article.read_time = self._estimate_read_time(article.content)
        return await self._repo.create(article)

    def _estimate_read_time(self, content: str) -> int:
        words = len(content.split())
        return max(1, round(words / 225))  # 225 wpm promedio
```

---

## 5. Capa de Datos (MongoDB + Motor)

### 5.1 Conexión a la base de datos

```python
# app/data/database.py
from motor.motor_asyncio import AsyncIOMotorClient
from app.config import settings

client: AsyncIOMotorClient = None

async def connect_db():
    global client
    client = AsyncIOMotorClient(settings.MONGODB_URI)

async def close_db():
    client.close()

def get_db():
    return client[settings.DB_NAME]
```

### 5.2 Implementación del repositorio

```python
# app/data/repositories/mongo_article_repo.py
from bson import ObjectId
from app.domain.repositories.article_repo import ArticleRepository
from app.domain.entities.article import Article

class MongoArticleRepository(ArticleRepository):
    def __init__(self, db):
        self._col = db["articles"]

    async def get_all(self, limit=20, offset=0, category=None):
        query = {}
        if category:
            query["category"] = category
        cursor = self._col.find(query).skip(offset).limit(limit).sort("published_at", -1)
        docs = await cursor.to_list(length=limit)
        return [self._to_entity(d) for d in docs]

    async def get_by_id(self, article_id: str):
        doc = await self._col.find_one({"_id": ObjectId(article_id)})
        return self._to_entity(doc) if doc else None

    async def create(self, article: Article):
        doc = self._to_document(article)
        result = await self._col.insert_one(doc)
        article.id = str(result.inserted_id)
        return article

    def _to_entity(self, doc: dict) -> Article:
        doc["id"] = str(doc.pop("_id"))
        return Article(**doc)

    def _to_document(self, article: Article) -> dict:
        d = article.__dict__.copy()
        d.pop("id", None)
        return d
```

---

## 6. Capa API (FastAPI)

### 6.1 Router de artículos

```python
# app/api/routes/articles.py
from fastapi import APIRouter, Depends, HTTPException, status
from app.domain.use_cases.create_article import CreateArticleUseCase
from app.domain.use_cases.get_articles import GetArticlesUseCase
from app.api.schemas.article_schema import ArticleCreate, ArticleResponse
from app.api.deps import get_article_repo

router = APIRouter(prefix="/articles", tags=["articles"])

@router.get("/", response_model=list[ArticleResponse])
async def list_articles(
    limit: int = 20,
    offset: int = 0,
    category: str | None = None,
    repo=Depends(get_article_repo)
):
    use_case = GetArticlesUseCase(repo)
    return await use_case.execute(limit, offset, category)

@router.get("/{article_id}", response_model=ArticleResponse)
async def get_article(article_id: str, repo=Depends(get_article_repo)):
    use_case = GetArticleByIdUseCase(repo)
    article = await use_case.execute(article_id)
    if not article:
        raise HTTPException(status_code=404, detail="Article not found")
    return article

@router.post("/", response_model=ArticleResponse, status_code=status.HTTP_201_CREATED)
async def create_article(
    data: ArticleCreate,
    repo=Depends(get_article_repo)
):
    use_case = CreateArticleUseCase(repo)
    return await use_case.execute(data.to_entity())
```

### 6.2 Schemas Pydantic

```python
# app/api/schemas/article_schema.py
from pydantic import BaseModel, Field
from datetime import datetime
from typing import Optional

class ArticleCreate(BaseModel):
    author_id: str
    author_name: str
    title: str = Field(..., min_length=5, max_length=300)
    description: str = Field(..., min_length=10)
    content: str = Field(..., min_length=50)
    source: str
    category: str
    url: Optional[str] = None
    thumbnail_url: Optional[str] = None

class ArticleResponse(BaseModel):
    id: str
    author_name: str
    title: str
    description: str
    content: str
    source: str
    category: str
    url: Optional[str]
    thumbnail_url: Optional[str]
    published_at: datetime
    views: int
    read_time: int

    class Config:
        from_attributes = True
```

---

## 7. Caddyfile

```caddyfile
# Caddyfile

# Para desarrollo local (sin dominio)
:8080 {
    reverse_proxy app:8000
}

# Para producción (con dominio y HTTPS automático)
# api.tudominio.com {
#     reverse_proxy app:8000
#     encode gzip
#     header {
#         Access-Control-Allow-Origin *
#         Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS"
#         Access-Control-Allow-Headers "Authorization, Content-Type"
#     }
# }
```

Caddy gestiona automáticamente el certificado TLS si se especifica un dominio real.
No requiere configuración adicional de Let's Encrypt.

---

## 8. Docker Compose

```yaml
# docker-compose.yml
version: "3.9"

services:
  mongo:
    image: mongo:7
    restart: always
    volumes:
      - mongo_data:/data/db
    environment:
      MONGO_INITDB_DATABASE: symmetry

  app:
    build: .
    restart: always
    depends_on:
      - mongo
    environment:
      MONGODB_URI: mongodb://mongo:27017
      DB_NAME: symmetry
      SECRET_KEY: ${SECRET_KEY}
    ports:
      - "8000:8000"

  caddy:
    image: caddy:2
    restart: always
    ports:
      - "80:80"
      - "443:443"
      - "8080:8080"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
      - caddy_data:/data
    depends_on:
      - app

volumes:
  mongo_data:
  caddy_data:
```

---

## 9. Adaptación del Frontend Flutter

El frontend solo necesita cambios en la **Data Layer**.
BLoC, Cubits, Use Cases y Entities se mantienen igual.

### 9.1 Cambio en pubspec.yaml

```yaml
dependencies:
  dio: ^5.4.0          # HTTP client (reemplaza cloud_firestore)
  # cloud_firestore: eliminado
  # firebase_storage: eliminado
```

### 9.2 Implementación del repositorio de artículos

```dart
// data/repositories/article_repository_impl.dart
class ArticleRepositoryImpl implements ArticleRepository {
  final Dio _dio;
  final String _baseUrl;

  ArticleRepositoryImpl({required String baseUrl})
      : _dio = Dio(),
        _baseUrl = baseUrl;

  @override
  Future<List<Article>> getArticles({int limit = 20, int offset = 0}) async {
    final response = await _dio.get(
      '$_baseUrl/articles',
      queryParameters: {'limit': limit, 'offset': offset},
    );
    return (response.data as List)
        .map((json) => ArticleModel.fromJson(json).toEntity())
        .toList();
  }

  @override
  Future<Article> createArticle(Article article) async {
    final response = await _dio.post(
      '$_baseUrl/articles',
      data: ArticleModel.fromEntity(article).toJson(),
    );
    return ArticleModel.fromJson(response.data).toEntity();
  }
}
```

### 9.3 Subida de imágenes

Reemplaza Firebase Storage con un endpoint multipart:

```dart
Future<String> uploadThumbnail(File image) async {
  final formData = FormData.fromMap({
    'file': await MultipartFile.fromFile(image.path),
  });
  final response = await _dio.post('$_baseUrl/upload/thumbnail', data: formData);
  return response.data['url'] as String;
}
```

---

## 10. Autenticación

Para el MVP se recomienda **JWT simple** sin Firebase Auth.

```python
# Flujo básico:
# POST /auth/register  → crea usuario en MongoDB, devuelve JWT
# POST /auth/login     → valida credenciales, devuelve JWT
# Header: Authorization: Bearer <token>
```

Librería: `python-jose` + `passlib[bcrypt]`.

---

## 11. Endpoints API (Referencia rápida)

| Método | Ruta | Descripción |
|---|---|---|
| GET | /articles | Listar artículos (paginado, filtro categoría) |
| GET | /articles/{id} | Detalle de artículo |
| POST | /articles | Crear artículo (auth requerido) |
| PUT | /articles/{id} | Editar artículo (solo autor) |
| DELETE | /articles/{id} | Eliminar artículo (solo autor) |
| POST | /upload/thumbnail | Subir imagen, devuelve URL |
| POST | /events/read | Registrar evento de lectura |
| POST | /auth/register | Registro de usuario |
| POST | /auth/login | Login, devuelve JWT |
| GET | /users/me | Perfil del usuario autenticado |

---

## 12. Variables de Entorno (.env)

```env
MONGODB_URI=mongodb://mongo:27017
DB_NAME=symmetry
SECRET_KEY=supersecretkey_cambiar_en_produccion
ACCESS_TOKEN_EXPIRE_MINUTES=60
ALLOWED_ORIGINS=http://localhost,https://tudominio.com
```

---

## 13. MVP Scope

**Implementar:**
- Conexión MongoDB con Motor
- CRUD de artículos
- Endpoint de subida de imagen (guardado local o S3-compatible)
- JWT básico
- Caddyfile funcional para desarrollo

**Diferir:**
- Sistema de rewards completo
- Scheduler semanal de distribución
- Scoring de fraude
- Gobernanza

---

## 14. Alignment con el Assignment

Este stack reemplaza Firebase con una arquitectura equivalente y más controlable:

| Firebase | Este stack |
|---|---|
| Firestore | MongoDB + Motor |
| Firebase Storage | Endpoint `/upload` + almacenamiento local/S3 |
| Firebase Auth | JWT con python-jose |
| Firebase Rules | FastAPI middleware + dependencias de auth |
| Firebase SDK Flutter | `dio` HTTP client |

La Clean Architecture del frontend se preserva al 100%.
Solo cambia la implementación del Data Layer.

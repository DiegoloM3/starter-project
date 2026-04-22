# Symmetry prototype API (FastAPI + MongoDB)

Backend REST del **prototipo** descrito en [symmetry_specs/docs/ADR_001_prototype_rest_mongo_vs_firestore.md](../symmetry_specs/docs/ADR_001_prototype_rest_mongo_vs_firestore.md).

## Requisitos

- [Docker](https://docs.docker.com/get-docker/) y Docker Compose v2

## Arranque rápido

Desde esta carpeta (`api/`):

```bash
docker compose up --build
```

- API FastAPI: [http://127.0.0.1:9000/docs](http://127.0.0.1:9000/docs) (OpenAPI; puerto **9000** en el host → 8000 en el contenedor)
- Health: `GET http://127.0.0.1:9000/health`
- Artículos mock: `GET http://127.0.0.1:9000/articles`
- Caddy (reverse proxy): `GET http://127.0.0.1:9080/health` (host **9080** → 8080 en el contenedor)
- MongoDB: `mongodb://127.0.0.1:27017`

## Desarrollo local sin Docker (Python)

```bash
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
set MONGODB_URL=mongodb://127.0.0.1:27017
uvicorn app.main:app --reload
```

(Necesitas MongoDB escuchando en `localhost:27017`.)

## Validar schema e insertar noticias mock

Con el stack levantado:

```bash
docker compose exec api python scripts/seed_mock_news.py
```

Para comprobar la implementación en Mongo:

```bash
docker compose exec mongodb mongosh symmetry --eval "db.getCollectionInfos({name:'articles'})[0].options.validator"
docker compose exec mongodb mongosh symmetry --eval "db.articles.getIndexes()"
docker compose exec mongodb mongosh symmetry --eval "db.articles.find({}, {_id:0, title:1, category:1, articleId:1}).limit(4).toArray()"
```

## Flutter

Configure la base URL del backend, por ejemplo:

- Equipo local: `--dart-define=API_BASE_URL=http://127.0.0.1:9000`
- Emulador Android apuntando al host: `--dart-define=API_BASE_URL=http://10.0.2.2:9000`
- Tras Caddy en el compose: `http://127.0.0.1:9080`

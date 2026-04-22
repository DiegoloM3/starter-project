import logging
import time
from fastapi import FastAPI, APIRouter, Request
from contextlib import asynccontextmanager
from motor.motor_asyncio import AsyncIOMotorClient


# Configure Logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
logger = logging.getLogger("SymmetryAPI")

from app.core.config import settings
from app.mongo_schema import initialize_mongo_schema
from app.api.v1.endpoints import articles, ollama, ingest, rewards, debug

@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info("Starting up Symmetry Nexus Systems...")
    # Startup: Connect to MongoDB
    app.state.motor_client = AsyncIOMotorClient(settings.mongodb_url)
    app.state.db = app.state.motor_client[settings.mongodb_db_name]
    
    # Verify connection
    await app.state.motor_client.admin.command("ping")
    logger.info("MongoDB Connection Verified.")
    
    # Initialize schema/indexes
    await initialize_mongo_schema(app.state.db)
    logger.info("Schema Initialization Complete.")
    
    yield
    
    # Shutdown: Close connection
    logger.info("Shutting down Nexus Systems...")
    app.state.motor_client.close()

from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(
    title="Symmetry Platform API",
    version="1.0.0",
    lifespan=lifespan,
    docs_url="/api/docs",
    openapi_url="/api/openapi.json"
)

# Enable CORS for professional interoperability
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Debug Middleware: Log every request
@app.middleware("http")
async def log_requests(request: Request, call_next):
    start_time = time.time()
    response = await call_next(request)
    process_time = (time.time() - start_time) * 1000
    formatted_process_time = "{0:.2f}".format(process_time)
    logger.info(
        f"Method: {request.method} Path: {request.url.path} "
        f"Status: {response.status_code} Duration: {formatted_process_time}ms"
    )
    return response

# Base Router
api_router = APIRouter(prefix="/api/v1")
api_router.include_router(articles.router, prefix="/articles", tags=["Articles"])
api_router.include_router(ollama.router, prefix="/ollama", tags=["Ollama"])
api_router.include_router(ingest.router, prefix="/ingest", tags=["Ingestion"])
api_router.include_router(rewards.router, prefix="/rewards", tags=["Rewards"])
api_router.include_router(debug.router, prefix="/debug", tags=["Debug & Diagnostics"])

app.include_router(api_router)

@app.get("/health")
async def health():
    return {"status": "ok", "service": "symmetry-platform-api"}

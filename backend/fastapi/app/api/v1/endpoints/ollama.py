import httpx
import hashlib
import json
from fastapi import APIRouter, Request, Response, Depends
from app.core.config import settings
from app.repositories.cache_repository import CacheRepository

router = APIRouter()

def get_cache_repository(request: Request) -> CacheRepository:
    return CacheRepository(request.app.state.db)

@router.api_route("/{path:path}", methods=["GET", "POST", "PUT", "DELETE"])
async def proxy_ollama(path: str, request: Request, cache: CacheRepository = Depends(get_cache_repository)):
    url = f"{settings.ollama_host}/{path}"
    
    # Check if we should cache (only for specific POST endpoints)
    should_cache = request.method == "POST" and path in ["api/generate", "api/chat"]
    content = await request.body()
    
    if should_cache:
        # Create cache key from path and body
        cache_input = f"{path}|{content.decode()}"
        cache_key = hashlib.md5(cache_input.encode()).hexdigest()
        
        cached_response = await cache.get(cache_key)
        if cached_response:
            return Response(
                content=json.dumps(cached_response),
                media_type="application/json",
                headers={"X-Cache": "HIT"}
            )

    async with httpx.AsyncClient() as client:
        # Collect headers
        headers = dict(request.headers)
        headers.pop("host", None)
        
        # Forward request to Ollama
        response = await client.request(
            method=request.method,
            url=url,
            headers=headers,
            content=content,
            params=request.query_params,
            timeout=None 
        )
        
        # Save to cache if successful and applicable
        if should_cache and response.status_code == 200:
            try:
                resp_json = response.json()
                # Create cache key again (to be sure)
                cache_input = f"{path}|{content.decode()}"
                cache_key = hashlib.md5(cache_input.encode()).hexdigest()
                await cache.set(cache_key, resp_json)
            except:
                pass
        
        # Return response to client
        return Response(
            content=response.content,
            status_code=response.status_code,
            headers=dict(response.headers)
        )


from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    mongodb_url: str = "mongodb://localhost:27017"
    mongodb_db_name: str = "symmetry"
    ollama_host: str = "http://localhost:11434"

    class Config:
        env_file = ".env"

settings = Settings()

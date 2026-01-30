from fastapi import FastAPI

from app.controllers.api_router import api_router
from app.core.database import db_healthcheck
from app.core.logging import configure_logging


def create_app() -> FastAPI:
    configure_logging()

    app = FastAPI(
        title="ICU Sepsis Decision Support API",
        version="0.1.0",
    )

    @app.get("/health", tags=["health"])
    def health() -> dict:
        """
        Lightweight health endpoint.
        Includes a DB connectivity check to confirm the app can reach Postgres.
        """
        db = db_healthcheck()
        status = "ok" if db["ok"] else "degraded"
        return {"status": status, "database": db}

    app.include_router(api_router)
    return app


app = create_app()

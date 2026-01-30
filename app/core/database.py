from __future__ import annotations

from collections.abc import Generator

from loguru import logger
from sqlalchemy import create_engine, text
from sqlalchemy.orm import Session, declarative_base, sessionmaker

from app.core.config import settings


engine = create_engine(
    settings.database_url,
    pool_pre_ping=True,
    future=True,
)

SessionLocal = sessionmaker(
    bind=engine,
    autocommit=False,
    autoflush=False,
    class_=Session,
)

Base = declarative_base()


def get_db() -> Generator[Session, None, None]:
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def db_healthcheck() -> dict:
    """
    Attempt a trivial query to confirm DB connectivity.
    Keep this sync and lightweight for local dev and readiness checks.
    """
    try:
        with engine.connect() as conn:
            conn.execute(text("SELECT 1"))
        return {"ok": True}
    except Exception as e:  # pragma: no cover
        logger.warning("DB healthcheck failed: {}", e)
        return {"ok": False, "error": str(e)}

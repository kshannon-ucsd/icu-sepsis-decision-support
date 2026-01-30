from __future__ import annotations

import os
import sys

from loguru import logger


def configure_logging() -> None:
    """
    Minimal structured-ish logging setup.
    Safe to expand later (JSON logs, request IDs, etc.).
    """
    logger.remove()

    level = os.getenv("LOG_LEVEL", "INFO").upper()
    logger.add(
        sys.stdout,
        level=level,
        backtrace=False,
        diagnose=False,
        enqueue=True,
    )

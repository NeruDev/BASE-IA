"""Canonical pytest fixtures and deterministic testing environment."""

from __future__ import annotations

import random
from typing import Generator
import pytest


@pytest.fixture(autouse=True)
def set_deterministic_seed() -> Generator[None, None, None]:
    """Ensures deterministic random seed for repeatable test runs."""
    random.seed(42)
    yield
    random.seed(None)


@pytest.fixture
def mock_clock() -> str:
    """Provides a fixed ISO 8601 timestamp for time-dependent unit tests."""
    return "2026-08-29T21:00:00Z"

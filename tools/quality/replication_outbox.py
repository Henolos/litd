#!/usr/bin/env python3
"""Durable SQLite outbox used to shadow-sync knowledge history to Supabase."""
from __future__ import annotations

import json
import sqlite3
from dataclasses import dataclass
from datetime import datetime, timezone
from typing import Any


@dataclass(frozen=True)
class OutboxEvent:
    id: int
    event_type: str
    event_key: str
    payload: dict[str, Any]
    attempts: int


def init_outbox(connection: sqlite3.Connection) -> None:
    connection.executescript(
        """
        CREATE TABLE IF NOT EXISTS replication_outbox (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            event_type TEXT NOT NULL,
            event_key TEXT NOT NULL UNIQUE,
            payload_json TEXT NOT NULL,
            created_at TEXT NOT NULL,
            delivered_at TEXT,
            attempts INTEGER NOT NULL DEFAULT 0,
            last_error TEXT
        );
        CREATE INDEX IF NOT EXISTS replication_outbox_pending_idx
        ON replication_outbox(delivered_at, id);
        """
    )


def enqueue_event(
    connection: sqlite3.Connection,
    *,
    event_type: str,
    event_key: str,
    payload: dict[str, Any],
) -> bool:
    if not event_type.strip():
        raise ValueError("empty_event_type")
    if not event_key.strip():
        raise ValueError("empty_event_key")

    payload_json = json.dumps(payload, sort_keys=True, separators=(",", ":"), ensure_ascii=False)
    existing = connection.execute(
        "SELECT payload_json FROM replication_outbox WHERE event_key=?",
        (event_key,),
    ).fetchone()
    if existing is not None:
        if existing[0] != payload_json:
            raise ValueError("outbox_event_key_payload_mismatch")
        return False

    connection.execute(
        "INSERT INTO replication_outbox(event_type, event_key, payload_json, created_at) "
        "VALUES (?, ?, ?, ?)",
        (
            event_type,
            event_key,
            payload_json,
            datetime.now(timezone.utc).isoformat(),
        ),
    )
    return True


def pending_events(connection: sqlite3.Connection, *, limit: int = 100) -> list[OutboxEvent]:
    if limit < 1:
        raise ValueError("invalid_outbox_limit")
    rows = connection.execute(
        "SELECT id, event_type, event_key, payload_json, attempts "
        "FROM replication_outbox "
        "WHERE delivered_at IS NULL "
        "ORDER BY id "
        "LIMIT ?",
        (limit,),
    ).fetchall()
    return [
        OutboxEvent(
            id=int(row[0]),
            event_type=str(row[1]),
            event_key=str(row[2]),
            payload=json.loads(row[3]),
            attempts=int(row[4]),
        )
        for row in rows
    ]


def mark_delivered(connection: sqlite3.Connection, event_id: int) -> None:
    connection.execute(
        "UPDATE replication_outbox "
        "SET delivered_at=?, attempts=attempts+1, last_error=NULL "
        "WHERE id=? AND delivered_at IS NULL",
        (datetime.now(timezone.utc).isoformat(), event_id),
    )


def mark_failed(connection: sqlite3.Connection, event_id: int, error: str) -> None:
    connection.execute(
        "UPDATE replication_outbox "
        "SET attempts=attempts+1, last_error=? "
        "WHERE id=? AND delivered_at IS NULL",
        (error[:1000], event_id),
    )


def pending_count(connection: sqlite3.Connection) -> int:
    row = connection.execute(
        "SELECT COUNT(*) FROM replication_outbox WHERE delivered_at IS NULL"
    ).fetchone()
    return int(row[0])

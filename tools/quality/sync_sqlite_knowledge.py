#!/usr/bin/env python3
"""Operational CLI for SQLite -> Supabase shadow synchronization."""
from __future__ import annotations

import argparse
import json
import os
import sys

from tools.quality.evidence_ledger import EvidenceLedger
from tools.quality.knowledge_supabase_sync import (
    PostgresKnowledgeRemote,
    connect_postgres,
    prepare_existing_history,
    sync_knowledge_once,
    verify_parity,
)
from tools.quality.provenance_chain import ProvenanceChain


def _parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser()
    parser.add_argument("--ledger-db", required=True)
    parser.add_argument("--provenance-db", required=True)
    parser.add_argument("--backfill", action="store_true")
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--limit", type=int, default=100)
    parser.add_argument("--max-batches", type=int, default=1000)
    parser.add_argument(
        "--database-url-env",
        default="HENOLOS_KNOWLEDGE_DB_URL",
        help="Environment variable containing the PostgreSQL DSN.",
    )
    parser.add_argument(
        "--sslmode-env",
        default="HENOLOS_KNOWLEDGE_SSLMODE",
        help="Environment variable containing sslmode (defaults to require).",
    )
    return parser


def main(argv: list[str] | None = None) -> int:
    args = _parser().parse_args(argv)
    if args.limit < 1 or args.max_batches < 1:
        raise SystemExit("limit and max-batches must be positive")

    ledger = EvidenceLedger(args.ledger_db)
    chain = ProvenanceChain(args.provenance_db)
    connection = None
    try:
        if args.backfill:
            backfilled = prepare_existing_history(ledger, chain)
        else:
            backfilled = (0, 0)

        if args.dry_run:
            print(
                json.dumps(
                    {
                        "mode": "dry-run",
                        "backfilled": {
                            "ledger": backfilled[0],
                            "provenance": backfilled[1],
                        },
                        "pending": {
                            "ledger": ledger.pending_replication_count(),
                            "provenance": chain.pending_replication_count(),
                        },
                    },
                    sort_keys=True,
                )
            )
            return 0

        dsn = os.environ.get(args.database_url_env)
        if not dsn:
            print(
                f"missing required environment variable: {args.database_url_env}",
                file=sys.stderr,
            )
            return 2

        sslmode = os.environ.get(args.sslmode_env, "require")
        connection = connect_postgres(dsn, sslmode=sslmode)
        remote = PostgresKnowledgeRemote(connection)

        for _ in range(args.max_batches):
            ledger_report, provenance_report = sync_knowledge_once(
                ledger,
                chain,
                remote,
                limit=args.limit,
            )
            if ledger_report.failed or provenance_report.failed:
                print(
                    json.dumps(
                        {
                            "status": "sync_failed",
                            "ledger": ledger_report.__dict__,
                            "provenance": provenance_report.__dict__,
                        },
                        sort_keys=True,
                    ),
                    file=sys.stderr,
                )
                return 3
            if (
                ledger_report.remaining == 0
                and provenance_report.remaining == 0
            ):
                break
        else:
            print("maximum sync batches reached before drain completed", file=sys.stderr)
            return 4

        parity = verify_parity(ledger, chain, remote)
        print(
            json.dumps(
                {
                    "status": "parity_ok" if parity.matches else "parity_mismatch",
                    "local": parity.local.__dict__,
                    "remote": parity.remote.__dict__,
                },
                sort_keys=True,
            )
        )
        return 0 if parity.matches else 5
    finally:
        if connection is not None:
            connection.close()
        chain.close()
        ledger.close()


if __name__ == "__main__":
    raise SystemExit(main())

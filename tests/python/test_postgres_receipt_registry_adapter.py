from tools.quality.postgres_receipt_consumption_registry import (
    PostgresReceiptConsumptionRegistry,
)


H1 = "a" * 64
H2 = "b" * 64
H3 = "c" * 64


class FakeCursor:
    def __init__(self, connection):
        self.connection = connection
        self.row = None

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc, tb):
        return False

    def execute(self, sql, params):
        self.connection.calls.append((" ".join(sql.split()), params))
        if "consume_receipt" in sql:
            self.row = (True, "ACCEPTED", "consumed_once", H3)

    def fetchone(self):
        return self.row


class FakeConnection:
    def __init__(self):
        self.calls = []
        self.commits = 0
        self.rollbacks = 0

    def cursor(self):
        return FakeCursor(self)

    def commit(self):
        self.commits += 1

    def rollback(self):
        self.rollbacks += 1


def test_adapter_uses_private_rpc_only():
    connection = FakeConnection()
    registry = PostgresReceiptConsumptionRegistry(
        connection, project_id="LITD", target_route="LITD_LIBRARY"
    )

    registry.register_receipt(
        receipt_id="r1",
        receipt_hash=H1,
        receipt_kind="KIND",
        source_hash=H2,
        context_hash=H3,
        expected_consumer="GUARDIAN",
    )
    result = registry.consume(
        H1,
        consumer="GUARDIAN",
        actor="human-reviewer",
        current_context_hash=H3,
    )

    sql = "\n".join(call[0] for call in connection.calls)
    assert "governance_private.register_receipt" in sql
    assert "governance_private.consume_receipt" in sql
    assert "insert into governance_private" not in sql.lower()
    assert result.accepted is True
    assert result.reason == "consumed_once"
    assert result.receipt_hash == H1
    assert result.audit_entry_hash == H3
    assert connection.commits == 2
    assert connection.rollbacks == 0


def test_adapter_rejects_empty_scope_before_database_access():
    connection = FakeConnection()
    try:
        PostgresReceiptConsumptionRegistry(
            connection, project_id="", target_route="LITD_LIBRARY"
        )
    except ValueError as exc:
        assert str(exc) == "project_id required"
    else:
        raise AssertionError("empty project scope must fail closed")

    assert connection.calls == []

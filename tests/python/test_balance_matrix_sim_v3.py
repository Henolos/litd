from __future__ import annotations

import json
from pathlib import Path

from tools.qa import balance_matrix_sim_v2 as v2
from tools.qa.balance_matrix_sim_v3 import (
    NORMAL_ENEMY_IDS,
    _apply_campaign_duration_guardrails,
    extract_runtime_campaign_profiles,
)


ROOT = Path(__file__).resolve().parents[2]








def test_campaign_duration_guardrails_accept_clear_three_step_hierarchy() -> None:
    result = v2.base.MatrixResult(
        payload={
            "monte_carlo": {
                "encounters": {
                    "campaign:normal": {"average_rounds": 4.0},
                    "campaign:miniboss": {"average_rounds": 4.8},
                    "campaign:boss": {"average_rounds": 7.3},
                }
            }
        },
        alerts=[],
    )

    _apply_campaign_duration_guardrails(result, ROOT)

    assert result.alerts == []
    assert result.payload["campaign_duration_guardrails"]["average_rounds"] == {
        "normal": 4.0,
        "miniboss": 4.8,
        "boss": 7.3,
    }


def test_campaign_duration_guardrails_reject_inverted_rhythm() -> None:
    result = v2.base.MatrixResult(
        payload={
            "monte_carlo": {
                "encounters": {
                    "campaign:normal": {"average_rounds": 6.6},
                    "campaign:miniboss": {"average_rounds": 3.5},
                    "campaign:boss": {"average_rounds": 7.2},
                }
            }
        },
        alerts=[],
    )

    _apply_campaign_duration_guardrails(result, ROOT)
    codes = {row["code"] for row in result.alerts}

    assert "campaign_normal_round_window" in codes
    assert "campaign_miniboss_round_window" in codes
    assert "campaign_miniboss_not_distinct_from_normal" in codes

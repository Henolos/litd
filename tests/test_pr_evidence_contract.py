"""Regression tests for PR evidence declaration validation."""
from tools.qa.validate_pr_evidence import validate

GOOD = """## Changement et question
Sauvegardes sûres et critères de réussite définis.

## Preuves et recherche (niveau C)
Godot API : https://docs.godotengine.org/en/stable/

## Vérifications réellement exécutées
Inspection statique ; test Godot non exécuté.

## Scénarios d'échec et risques résiduels
Corruption et panne électrique non testées.

## Conclusion
Statut : PARTIEL
"""


def test_complete_declaration_is_accepted():
    assert validate(GOOD) == []


def test_missing_sections_are_rejected():
    assert any("Section manquante" in error for error in validate("## Conclusion\nStatut : PARTIEL"))


def test_status_is_required():
    assert any("Statut explicite" in error for error in validate(GOOD.replace("Statut : PARTIEL", "Statut : inconnu")))


def test_empty_body_is_rejected():
    assert len(validate("")) >= 5

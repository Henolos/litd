# Bibliothèque LITD — index des études de psychologie narrative

**2026-11-18 | statut : experimental / revalidate | non canonique**

Cet index regroupe les études dans la structure existante `docs/research/`, sous le protocole de bibliothèque vivante `docs/knowledge/LIVING_LIBRARY_PROTOCOL.md`. Le catalogue historique `docs/knowledge/CATALOG.md` est protégé par l'audit de reconstruction : **il n'est pas modifié**. Ce document sert d'index documentaire spécialisé en attendant une décision de gouvernance sur son référencement central.

## Études originales conservées à empreinte identique

- [Conker, LISA, Disco Elysium : personnages](DOSSIER_APPROFONDI_CONKER_LISA_AUTRES.md)
- [LISA : Buzzo, Rando, compagnons](LISA_SCENES_BUZZO_RANDO_COMPAGNONS_002.md)
- [Scénarios comparatifs](SCENARIOS_COMPARATIFS_CONKER_LISA_DISCO_001.md)
- [Chronologies et causalité](SCENARIOS_CHRONOLOGIES_CAUSALITE_002.md)
- [Fiches de scènes causales](SCENARIOS_FICHES_SCENES_CAUSALES_003.md)
- [Graphe causal et embranchements](SCENARIOS_GRAPHE_CAUSAL_EMBRANCHEMENTS_004.md)
- [BG3 : Astarion, Shadowheart et grille QS-004](QUETES_SECONDAIRES_BG3_EMBRANCHEMENTS_GRILLE_004.md)

## Expérimentation distincte

- [Quête pilote à trois trajectoires](QUETE_PILOTE_TROIS_TRAJECTOIRES_V0_1.md), corrigée sur papier, non canonique, non implémentée.

## Règles d'admission

Les études sont des **recherches documentaires**, non des faits de gameplay LITD vérifiés. Les limites des sources sont conservées ; aucun scénario de référence n'est déclaré rejoué. Avant toute promotion : vérifier les contradictions, les règles actuelles de LITD, les tests et les preuves. Aucune duplication du système `docs/knowledge/` n'est créée.

## Point de blocage explicite

Le test `tests/python/test_reconstruction_audit.py` refuse une modification de `docs/knowledge/CATALOG.md` (`reference_changed`). Le catalogue a été restauré. Toute inscription dans ce catalogue exige d'abord de vérifier et respecter le manifeste de reconstruction, sans le contourner ni modifier ses empreintes pour faire passer la CI.

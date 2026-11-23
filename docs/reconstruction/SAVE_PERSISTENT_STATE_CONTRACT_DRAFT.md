# LITD 1 — Contrat provisoire des données persistantes (issue #638)

Statut : **inventaire audité du SaveManager 0.31, schéma métier non encore validé**. Document de conception technique, sans modification du format de sauvegarde en production.

## Source vérifiée
- `scripts/core/save_manager.gd` sur la branche `feat/issue-638-canonical-save-state`.
- Le gestionnaire conserve aujourd'hui un `_snapshot` opaque et ajoute `version` et `metadata`. Il ne possède pas de schéma métier exhaustif.
- `_migrate` garantit la présence des clés listées ci-dessous, mais **ne prouve ni leur contenu ni leur statut métier**.

## Inventaire des clés existantes

| Clé racine | Traitement observé | Classement pour le futur contrat |
| --- | --- | --- |
| `version` | Ajoutée par `_build_payload` (`0.31`) | Enveloppe / version de format, hors état canonique métier |
| `metadata` | Horodatage et durée de session | Métadonnées volatiles, hors empreinte métier |
| `qa_snapshot` | Marqueur des sauvegardes QA | Hors campagne de production |
| `campaign_memory` | Valeur par défaut `{}` | Candidate persistante ; schéma interne à confirmer |
| `remanence` | Valeur par défaut `{}` | Candidate persistante ; schéma interne à confirmer |
| `veilleurs` | Valeur par défaut ou conversion de `veilleurs_vs001` | Candidate persistante ; schéma interne à confirmer |
| `veilleurs_vs001` | Déplacée vers `veilleurs.legacy_vs001`, puis supprimée | Entrée héritée, ne pas réintroduire comme champ courant |
| `expedition_reports` | Valeur par défaut `{}` | Candidate persistante ; schéma interne à confirmer |
| `preparation_presets` | Valeur par défaut `{}` | Candidate persistante ; schéma interne à confirmer |
| `living_exploration` | Valeur par défaut `{}` | Candidate persistante ; schéma interne à confirmer |
| `progression_scope` | Valeur par défaut `{}` | Candidate persistante ; schéma interne à confirmer |
| `main_narrative_script` | Valeur par défaut `{}` | Candidate persistante ; schéma interne à confirmer |
| `base_game_enrichment` | Valeur par défaut `{}` | Candidate persistante ; schéma interne à confirmer |
| `systemic_cross` | Valeur par défaut `{}` | Candidate persistante ; schéma interne à confirmer |
| `systemic_cross_narrative` | Valeur par défaut `{}` | Candidate persistante ; schéma interne à confirmer |

Les clés supplémentaires sont actuellement préservées par le snapshot opaque, y compris des modules inconnus. **Ne pas les supprimer** par une liste blanche prématurée.

## Politique provisoire de projection canonique

1. **Identité et versionnement** : `campaign_id`, `revision`, `schema_version` dans l'enveloppe canonique ; aucune de ces valeurs ne doit être déduite d'un horodatage.
2. **État métier à inclure après vérification** : identité et état des héros, mort définitive, succession et état `pending`, ressources et inventaire, progression personnelle/collective, Guilde, expédition et combat confirmé, événements irréversibles, état aléatoire requis à la reprise. Les noms réels des clés et leurs producteurs restent à retrouver.
3. **À exclure** : horodatages, temps de session, marqueurs QA, caches de rendu, animations, état purement visuel, journaux de diagnostic. Les exclusions imbriquées doivent être définies par chemin, pas par nom générique.
4. **Inconnues** : préserver intégralement le format 0.31 et refuser la certification transactionnelle tant que les champs métier inconnus ne sont pas classés. Ne pas transformer silencieusement une donnée inconnue en donnée jetable.
5. **Nombres** : définir une politique de flottants (NaN/infini interdits, zéro signé, précision et représentation), ainsi que la normalisation Unicode avant toute promesse de compatibilité interversions.
6. **Reprise** : empreinte SHA-256 seule = intégrité de représentation, pas preuve de continuité, de non-retour arrière ou d'authenticité ; ces garanties exigent journal durable, révisions et invariants.

## Critères de validation avant raccordement

- Inventaire des producteurs/consommateurs de chaque champ et exemples de snapshots réels anonymisés.
- Schéma versionné documenté, classification explicite de toutes les clés imbriquées.
- Jeux d'essai couvrant morts multiples, succession, capture, progression, inventaire, effets différés et états RNG.
- Tests de compatibilité avec les sauvegardes 0.31 et les données inconnues, sans écriture sur les originaux.
- Tests d'interruption et essais Windows réels sur copies.

**Décision de sécurité :** ne pas raccorder `canonical_body` et `canonical_sha256` à `save_game` ou `load_game` avant satisfaction de ces critères.

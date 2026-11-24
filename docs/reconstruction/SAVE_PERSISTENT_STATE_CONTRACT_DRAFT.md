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

## Audit des producteurs et consommateurs du runtime courant (23 novembre 2026)

**Périmètre inspecté :** arborescence Git `scripts/**/*.gd` de la branche de la PR #639 (20 scripts de production, hors `scripts/tests`), fichiers `scripts/core/save_manager.gd`, `scripts/core/data_loader.gd`, `scripts/ui/game_hub.gd`, `scripts/world/dungeon_run_seed.gd`, `scripts/world/dungeon_event_director.gd`, `scripts/ui/bestiary_screen.gd`, `data/heroes.json`, `tests/godot/test_save_roundtrip_headless.gd`, ADR-0007 et ADR-0009. Ce relevé **ne remplace pas une recherche de toutes les références dynamiques ou non GDScript**.

| Domaine | Producteur confirmé dans les sources inspectées | Consommateur confirmé | Statut du schéma |
| --- | --- | --- | --- |
| Stockage de snapshot | `SaveManager.set_snapshot(payload)` accepte un dictionnaire opaque ; `_build_payload` ajoute `version` et `metadata` | `SaveManager.get_snapshot()`, `load_game()` et `_apply_payload()` | **API de stockage vérifiée**, aucun contrat métier |
| Héros | `scripts/core/data_loader.gd` lit `res://data/heroes.json` comme données de catalogue, non comme sauvegarde | `DataLoader.heroes` est alimenté ; consommation de cette donnée dans une sauvegarde **non démontrée** | Catalogue statique ≠ état vivant de héros |
| Combat, décès définitifs, succession | Aucun producteur de mutations persistantes confirmé dans les scripts inspectés | Aucun consommateur de journal durable confirmé | **Non démontré**, ne pas déclarer implémenté |
| Expédition | `scripts/world/dungeon_run_seed.gd` lit `campaign_seed` depuis un dictionnaire d'exécution/configuration | Génération d'une graine de donjon ; raccordement à `SaveManager` non démontré | Contrat de reprise d'expédition **à établir** |
| Progression collective / Guilde | `SaveManager._migrate` initialise `campaign_memory`, `progression_scope` et autres champs, sans définir leurs structures | `SaveManager` conserve ces valeurs opaques | **Valeurs par défaut uniquement**, pas de validation métier |
| Données de tests | `tests/godot/test_save_roundtrip_headless.gd` produit une fixture `gold`, `party`, `equipment`, `future_module` | Le même test relit les valeurs après `save_game` et `load_game` | **Fixture synthétique**, ne pas promouvoir en schéma canonique |

### Contradictions et limites documentées

- L'ADR-0007 décrit une boucle roguelike et une sérialisation historique via `ExpeditionManager` (PR #70), mais porte le statut **revalidate**. L'arborescence de production inspectée ne contient pas `scripts/core/expedition_manager.gd`. **Preuve historique ≠ producteur courant vérifié.**
- L'ADR-0009 précise que Mathilde, Marec, Anouk et Aurélien ne constituent plus le quatuor de départ et qu'aucun nouveau quatuor n'est défini. `data/heroes.json` ne doit donc pas être utilisé pour inventer un état initial canonique.
- Le test de roundtrip démontre la conservation d'un dictionnaire arbitraire et des clés inconnues. Il ne démontre ni la mort permanente ni la succession transactionnelle.
- L'absence d'un producteur confirmé dans cet audit n'est **pas** une preuve générale de son inexistence : des ressources historiques, scripts retirés, branches, tests ou intégrations externes peuvent exister.

### Contrat vérifiable : ce qui est établi et ce qui reste bloqué

**Établi et testable maintenant :** format enveloppe `version=0.31`, `metadata`, snapshot opaque, conservation de clés inconnues, fonctions `canonical_body(campaign_id, revision, persistent_state)` et `canonical_sha256` non raccordées, refus des types non JSON et des champs transitoires racine listés.

**Non établi :** identité persistante des héros et de la campagne, provenance des révisions, état de mort permanente, événements confirmés, succession `pending`, économie idempotente, captures, RNG, schéma de combat, règles de reprise. Aucun champ ne peut être déclaré obligatoire en production sans producteur et consommateur prouvés.

**Porte de sortie :** reconstruire ou identifier un producteur runtime actuel pour chaque domaine, collecter des exemples de snapshot réels sur copies, définir invariants et versions, puis tester migrations, journaux et interruptions. En attendant, ne pas bloquer ni transformer les sauvegardes 0.31 existantes.

## Contrat versionné expérimental — 24 novembre 2026

Le fichier `save_canonical_envelope_v1.schema.json` décrit uniquement l'enveloppe produite par `canonical_body` (JSON Schema 2020-12). Il ne valide pas les sauvegardes 0.31. Les champs inconnus de l'état sont conservés ; les cinq exclusions racine correspondent au code actuel. Les nombres non finis sont rejetés avant sérialisation par Godot ; le schéma ne garantit ni la précision numérique ni la canonicalisation Unicode.

### Projection métier proposée (non normative)

| Domaine | Invariants à prouver avant raccordement |
| --- | --- |
| Campagne et héros | Identités stables, décès irréversibles, succession après perte du groupe actif ; aucun roster inventé |
| Guilde et bestiaire | Connaissances collectives persistantes, maîtrise personnelle non héritée |
| Exploration | Clés consommées une seule fois, passages et transformations persistants, retour contextuel au refuge |
| Combat et capture | Résultat confirmé atomique, aucune répétition des tirages, récompenses uniques |
| Monde et économie | Quêtes, conséquences différées, inventaire et ressources cohérents avec les transactions |
| Journal | Révisions contiguës, identités uniques, empreintes avant/après, détection de perte de fin de journal à concevoir |

Les noms et structures métier restent à valider contre les producteurs réels. Le schéma d'enveloppe ne certifie aucun invariant métier. Les tests de schéma utilisent des fixtures synthétiques ; ils ne remplacent pas les tests Godot, les interruptions réelles ou les migrations sur copies. Aucun raccordement au runtime ni modification des sauvegardes utilisateur autorisé à ce stade.

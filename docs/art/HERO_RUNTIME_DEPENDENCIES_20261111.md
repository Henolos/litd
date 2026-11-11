# Intégration des six planches officielles — 2026-11-11

## Révisions et gouvernance contrôlées

| Référence | Commit recontrôlé au début de la reprise | État |
| --- | --- | --- |
| main | ee634021eb0e31334a63bf94d3889d36862e53a6 | Protégée |
| #606 | aa51751008e9807024f117816e4a2d0edacdf440 | Brouillon ouvert |
| #607 | 7d0428e8feb1732473dd7371d166606994e75ca2 | Brouillon ouvert |
| #608 | f6e1193abaa25e3cfd42a72c82149582486eaff2 | Brouillon ouvert |
| #609 | ab5ac3bb2f3525052ccc5fcc7ca2e24dc402faa9 | Brouillon ouvert |
| #610 | d59b263308ddb406d3869e780701d2140efa3c20 | Brouillon ouvert |

Le ruleset actif `23145847` impose une PR, la résolution des discussions, les contrôles stricts `quality`, `godot-smoke`, `guardian`, `validate`, `remanence-smoke`, `Merge Execution Gate`, et une merge queue ALLGREEN. Aucun acteur ne peut contourner ces règles. L’endpoint historique de protection renvoie 403 à la connexion intégrée ; les règles actives ont été lues séparément. Aucun ref temporaire de file n’était visible au contrôle initial ; cela ne constitue pas une lecture exhaustive de son état GraphQL.

## Originaux importés et vérifiés

Archive exacte : `LITD_HEROS_6_PLANCHES_WORK (15).zip` (4 061 056 octets). Les six SHA-256 ont été mesurés depuis les membres du ZIP et correspondent au manifeste. Import sans retouche, sans recompression et sans modification des dimensions au commit `dd8de4963e9b5445370aff22acabba298881aa5b`. Les six fichiers ont ensuite été téléchargés depuis raw.githubusercontent.com sur ce commit immuable : six empreintes à nouveau conformes. Les octets importés restent inchangés dans les commits suivants.

| Personnage | Chemin | Octets |
| --- | --- | --- |
| Mathilde | art/library/heroes/mathilde/reference.jpg | 631931 |
| Marec | art/library/heroes/marec/reference.jpg | 733565 |
| Anouk | art/library/heroes/anouk/reference.jpg | 792554 |
| Aurélien | art/library/heroes/aurelien/reference.jpg | 538071 |
| Éffrie | art/library/heroes/effrie/reference.jpg | 620653 |
| Lya | art/library/heroes/lya/reference.jpg | 744724 |

Les empreintes complètes, dimensions et statuts binaires sont dans `validated_heroes_manifest_20261111.json`. La validation artistique du propriétaire est acquise. Éffrie et Lya restent des références artistiques ; `data/heroes.json` conserve exactement Mathilde, Marec, Anouk et Aurélien.

## Dépendances auditées et migration

Audit de tous les fichiers suivis décodables en UTF-8 (2 516 fichiers texte au commit `23bd6a7d8b1c3a8bb385276e1de607b6c644cea6`), couvrant scripts, scènes, ressources, JSON, configurations, workflows, outils, tests et documents. Les branches main, #606, #607, #608, #609 ont été récupérées et contrôlées pour les ressources candidates au nettoyage. Les chargements dynamiques de portraits identifiés ont été suivis jusqu’à leurs données. Aucun `.uid` ou `.import` n’était suivi dans l’arbre initial ; les fichiers générés localement ne sont pas ajoutés en masse.

- `project.godot` → `scenes/Main.tscn` → `scripts/ui/main_v52.gd` reste le chemin de démarrage.
- `scripts/ui/main.gd::hero_art()` choisit d’abord l’identité canonique du héros (y compris `canonical_id` des sauvegardes), puis la carte de classe pour les recrues génériques. Cela couvre aussi les appels hérités de `main_v30.gd` et `main_v38.gd`.
- `main_v52.gd` utilise les quatre JPEG et reconnaît les emplacements par les deux préfixes, ancien et officiel ; les métadonnées, l’ordre des rangs et le comportement responsive sont conservés. Portraits affichés sans recadrage.
- `data/classes.json` conserve ses dix références utiles ; une classe ne reçoit pas arbitrairement l’identité d’un héros. Ces dix WEBP et le repli Inquisiteur sont conservés.
- `data/canonical_art_v41.json::portrait.active_hero` résout `art/library/heroes/{entity_id}/reference.jpg` ; `CanonicalArtRegistry` conserve son repli sûr pour une identité absente.
- `tools/blender/generate_character_jobs.py` et `data/blender/character_jobs.json` pointent les quatre jobs héros vers les planches officielles. Les 52 jobs restent cohérents ; aucune production Blender exécutée par cette PR.
- Tests Python des portraits migrés ; ajout de contrôles d’intégrité, unicité, chemins, roster et jobs. Le test Godot artistique charge les six textures et vérifie les identités héritées et génériques. Le parcours joueur utilise les quatre nouveaux chemins.
- `.github/workflows/build.yml` surveille désormais `art/**` et charge les six textures depuis le PCK Web exporté via `scripts/tests/hero_art_export_check.gd` avant publication de l’artefact CI.

## Nettoyage limité

Neuf variantes `_2.webp` et les quatre SVG `assets/heroes/canonical/` ont été retirés après audit sans consommateur retrouvé (hors mentions historiques d’inventaire), contrôle des branches pertinentes et premiers tests réussis. Liste exacte, SHA-256 et mentions historiques conservés dans `hero_cleanup_evidence_20261111.json`. Suppression par commit normal ; aucun historique réécrit.

Conservés : dix cartes de classes, 39 images ennemis, la planche conceptuelle ennemis et les cinq arrière-plans. Inventaire résultant : 61 images, dont six JPEG officiels et dix WEBP de classes. Les anciens chemins mentionnés dans les sections historiques des audits ne sont pas des liens de chargement actifs.

## Contrôles effectivement exécutés

| Contrôle | Résultat et portée |
| --- | --- |
| SHA-256 avant et après GitHub | 6/6 conformes au manifeste au commit d’import dd8de496 |
| Dimensions JPEG | Contrôlées par lecture des originaux ; aucune image transformée |
| Python ciblé après nettoyage | 211 tests réussis |
| Générateur Blender `--check` | 52 jobs courants |
| Import Godot 4.7.2 après nettoyage | Réussi, code 0 ; pas d’erreur GDScript détectée |
| Catalogue Godot après nettoyage | `CANONICAL_ART_V41_SMOKE_OK` |
| Parcours joueur avant nettoyage | `UI_PLAYER_JOURNEY_SMOKE_OK`, code 0, quatre portraits officiels vérifiés |
| Suite Python CI au commit 23bd6a7d | 1 831 tests réussis, deux avertissements Python préexistants |
| CI et cinq domaines Godot au commit 23bd6a7d | Réussis ; 21 workflows terminés avec succès |
| Exports Web, Windows, Linux au commit 23bd6a7d | Réussis |
| Paquet Web au commit 23bd6a7d | `EXPORTED_HERO_ART_OK` : six textures chargées depuis le paquet exporté |
| PWA générée au commit 23bd6a7d | Artefact téléchargé et service worker inspecté : `index.pck` et `index.wasm` cacheables, version `1794390060|17255168`, suppression des anciens caches du même préfixe à l’activation |
| Dernier commit incluant suppressions et documentation | CI à recontrôler après son envoi ; aucune fusion annoncée à ce stade |

Limites explicites : la première tentative de suite Python locale sous Windows n’était pas valide (encodage système, puis absence de bash). Avec UTF-8, 693 tests passent avant l’arrêt sur un test nécessitant bash ; la suite Linux CI fournit la validation complète. L’audit QA global lancé directement dans le dossier importé échoue sur le répertoire `.godot` traité comme un fichier par son parcours ; ce problème local n’est pas présenté comme un audit réussi. Les smokes Godot signalent des objets/ressources encore utilisés à la fermeture malgré leurs marqueurs de réussite ; l’export Linux signale également l’absence de fontconfig dans le conteneur. Aucun contrôle visuel humain ou mise à jour effective d’un ancien cache de navigateur installé n’est affirmé. Aucun déploiement Web déclenché manuellement.

## Suivi

Chantier : Bibliothèque artistique LITD 1. Statut : 🟠 EN COURS, validation finale du nettoyage et fusion protégée à effectuer. Avancement du chantier actuel : À évaluer (la réconciliation du bestiaire reste ouverte). Avancement du projet global LITD 1 : À évaluer.

Prochaine étape : valider le dernier commit sur GitHub, contrôler les discussions et protections à nouveau, puis utiliser la merge queue sans contournement. Les PR #606–#609 restent distinctes et ne sont ni fusionnées ni fermées dans cette opération.

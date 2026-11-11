# Dépendances vérifiées des portraits — 2026-11-11

Source : `scripts/ui/main_v52.gd` lu sur `main` (avant fusion de #610).

- Ligne 8 : `LEGACY_CARD_PREFIX = "res://assets/heroes/"`.
- Lignes 16–20 : `CANONICAL_PORTRAITS` lie `mathilde` à `duelist.webp`, `marec` à `breaker.webp`, `anouk` à `mystic.webp` et `aurelien` à `surgeon.webp`.
- Ligne 36 : chargement des textures à partir de cette table.
- Ligne 40 : commentaire indiquant que le profil hérité peut appeler `hero_art()` et revenir sur une ancienne carte.
- Ligne 125 : autre utilisation de `CANONICAL_PORTRAITS`.

## Conséquences
Les quatre fichiers WEBP sont **encore référencés par le code actif** : ne pas les supprimer avant import et migration des JPEG validés. La table doit pointer vers `art/library/heroes/{hero}/reference.jpg` après récupération et contrôle des six fichiers.

Les deux autres héros validés, Éffrie et Lya, ne sont pas dans cette table à quatre entrées : leur ajout au catalogue artistique ne signifie pas leur activation dans le quatuor jouable.

## Étapes non effectuées
- Aucun JPEG transféré dans GitHub ni récupéré pour contrôle SHA-256.
- Aucun chemin runtime modifié.
- Aucune suppression d'image.
- Aucun test Godot exécuté.

La lecture exhaustive de toutes les références (autres scripts, scènes, ressources, tests et PWA) reste à faire avant nettoyage.

## Recontrôle effectué le 2026-11-11

### Révisions observées avant modification documentaire
| Référence | Dernier commit | État GitHub |
| --- | --- | --- |
| main | ee634021eb0e31334a63bf94d3889d36862e53a6 | Branche protégée |
| #606 | aa51751008e9807024f117816e4a2d0edacdf440 | Brouillon, fusion possible sans conflit signalé |
| #607 | 7d0428e8feb1732473dd7371d166606994e75ca2 | Brouillon, fusion possible sans conflit signalé |
| #608 | f6e1193abaa25e3cfd42a72c82149582486eaff2 | Brouillon, fusion possible sans conflit signalé |
| #609 | ab5ac3bb2f3525052ccc5fcc7ca2e24dc402faa9 | Brouillon, fusion possible sans conflit signalé |
| #610 | c0359c120b81266ab984497b72ca981c5ae47f22 | Brouillon, fusion possible sans conflit signalé |

Le ruleset actif `23145847` impose PR, résolution des discussions, contrôles stricts `quality`, `godot-smoke`, `guardian`, `validate`, `remanence-smoke`, `Merge Execution Gate`, et merge queue ALLGREEN. Aucun acteur de contournement. L'endpoint historique de protection renvoie 403 à la connexion intégrée ; le ruleset actif a bien été lu séparément.

### Dépendances supplémentaires lues directement
Lecture de 57 fichiers : les 53 scripts `scripts/ui/main*.gd`, `project.godot`, `export_presets.cfg`, `scenes/Main.tscn` et `tests/python/test_combat_canonical_portrait_layout.py`. Lecture complémentaire de `data/classes.json`, `data/heroes.json`, `data/canonical_art_v41.json`, `scripts/visual/canonical_art_registry.gd` et `scripts/core/canonical_art_v41_smoke_test.gd`.

- `project.godot:3` démarre `scenes/Main.tscn`, dont la ressource script ligne 59 est `main_v52.gd`.
- `scripts/ui/main.gd:341-343` définit `hero_art()` depuis `data/classes.json`, avec repli sur `inquisitor.webp`. Appels aux lignes 372 et 668.
- Autres appels hérités : `main_v30.gd:161` et `main_v38.gd:213`. Une simple modification de CANONICAL_PORTRAITS n'élimine donc pas les anciennes références.
- `data/classes.json` conserve dix champs `art` : inquisitor, vestal, mystic, ranger, breaker, surgeon, watcher, scout, occultist et duelist, tous WEBP. Ne pas attribuer arbitrairement les six héros à toutes ces classes : préserver les identités et le gameplay.
- `main_v52.gd` détecte les emplacements de combat par le préfixe `res://assets/heroes/`. Une migration de `hero_art()` doit aussi adapter cette détection, faute de quoi les portraits et leurs métadonnées risquent de ne plus être traités.
- `tests/python/test_combat_canonical_portrait_layout.py:39-46` impose encore les quatre anciens chemins WEBP ; le test doit migrer avec le code et contrôler les chemins officiels.
- `data/heroes.json` contient les quatre héros canoniques Mathilde, Marec, Anouk et Aurélien ; aucune activation d'Éffrie ou Lya effectuée.
- `data/canonical_art_v41.json:93` déclare aussi le chemin dynamique optionnel `assets/art/v41/portraits/{entity_id}.webp` : examiner ses consommateurs lors de la migration complète.
- Export Web : PWA activée, shell HTML personnalisé vide, `all_resources`, filtres inclusion/exclusion vides. Aucun service worker ni fichier `.uid` ou `.import` versionné dans l'arbre consulté. Cela ne valide pas les caches générés, les UID locaux ou l'export Web.
- Sur la branche #607, `scripts/ui/main.gd:343-345` conserve le même chargement par classe. Cette PR modifie 22 fichiers, dont du code et des tests : elle ne constitue pas un lot purement documentaire. #608 et #609 ne modifient que leur registre ; #606 reste un chantier gameplay séparé.

### Intégrité et disponibilité
Le manifeste JSON a été parsé : six entrées, identifiants et empreintes uniques, empreintes au format SHA-256, chemins conformes à `art/library/heroes/{hero}/reference.jpg`, six statuts `pending_import`. Aucun fichier n'existe encore sous `art/library/heroes/` dans l'arbre de #610 consulté. Ce contrôle structurel ne vérifie pas les octets des images.

Une archive candidate nommée `LITD_HEROS_6_PLANCHES_WORK.zip` a été retrouvée parmi les fichiers transmis précédemment. Sa récupération locale échoue sur DNS ; le clonage HTTPS du dépôt échoue aussi sur DNS. `gh auth status` signale par ailleurs un jeton local invalide, tandis que la connexion GitHub intégrée permet les lectures effectuées. Aucun écart SHA-256 ne peut être affirmé ou exclu sans les octets. Importation, migration et suppressions suspendues à ce contrôle préalable.

### Contrôles et limites
- Inventaire recontrôlé sur l'arbre complet non tronqué de main : 23 images héros (19 WEBP et 4 SVG), 39 WEBP ennemis, 1 planche conceptuelle ennemis. Le contenu de ces répertoires est identique dans l'arbre #610 consulté.
- Au commit c0359c1, sept exécutions Actions trouvées, toutes terminées avec succès : CI, Merge Execution Enforcement, Knowledge Governance, Trieur Safe Archive, Knowledge Guardian, Trieur Governance, Remanence Smoke. Ce résultat précède la présente mise à jour et ne valide aucun import d'image.
- Aucun test Godot exécuté : aucun exécutable Godot trouvé dans PATH ; pas de copie locale complète ni d'images récupérées. Aucun affichage, import de textures, UID ou cache PWA validé.
- Recherche indexée GitHub sans résultat, y compris pour des chaînes présentes dans le code lu : ces résultats négatifs ne prouvent aucune absence. L'audit exhaustif de tous les scripts, scènes, ressources, configurations, tests, documents et branches reste à terminer.
- Aucun binaire ajouté ou supprimé, aucun chemin runtime modifié, aucune fusion effectuée.

Chantier : Bibliothèque artistique LITD 1. Statut : 🟠 BLOQUÉ sur la récupération des originaux. Avancement du chantier actuel : À évaluer. Avancement du projet global LITD 1 : À évaluer.

Prochaine priorité : récupérer l'archive, confronter les six SHA-256 au manifeste, importer les octets inchangés et les revérifier depuis GitHub avant toute migration ou suppression.

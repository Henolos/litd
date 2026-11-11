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

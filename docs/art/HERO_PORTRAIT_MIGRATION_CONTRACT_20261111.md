# Contrat de migration des portraits LITD 1 — audit complémentaire

## État historique de main avant la migration (2026-11-11)

- `scripts/ui/main_v52.gd` référence `res://assets/heroes/{duelist,breaker,mystic,surgeon}.webp` pour Mathilde, Marec, Anouk, Aurélien. Les références sont chargées dans le profil et l'interface de combat.
- `data/canonical_art_v41.json` définit `portrait.active_hero` via `res://assets/art/v41/portraits/{entity_id}.webp` (entrée dynamique, `required_at_runtime=false`).
- `scripts/visual/canonical_art_registry.gd` charge ce second manifeste.
- Cet inventaire décrit main avant la fusion de #610. Sur la branche de la PR, les six JPEG ont depuis été importés et vérifiés ; voir l’état courant ci-dessous.

## Décisions techniques provisoires

1. Conserver les six JPEG originaux dans `art/library/heroes/<id>/reference.jpg` avec contrôle SHA-256. Ces planches sont les **sources de vérité artistiques**, pas nécessairement les textures optimisées à afficher en combat.
2. Prévoir une couche d'assets runtime dérivés distincte, générée et traçable, pour les portraits affichés en jeu. Ne pas substituer arbitrairement une planche entière à un portrait recadré sans contrôle de lisibilité.
3. Réconcilier les deux mécanismes de portraits (`main_v52.gd` et `canonical_art_v41.json`) ; définir un seul registre de résolution des identités et chemins actifs.
4. Maintenir le quatuor jouable existant ; Éffrie et Lya restent dans la bibliothèque tant qu'une décision gameplay ne les active pas.
5. Avant toute suppression de WebP/SVG, inventorier leurs références dans scripts, scènes, ressources, tests, documentation et caches PWA.
6. Ajouter des tests : unicité des identités, existence des ressources, cohérence entre registre et interface, absence de référence active supprimée, import Godot et vérification visuelle lorsque disponible.

## État courant vérifié dans #610

Les six originaux ont été importés au commit `dd8de4963e9b5445370aff22acabba298881aa5b` et leurs six SHA-256 revérifiés après récupération depuis GitHub. La migration `23bd6a7d` couvre `hero_art()`, la table et la détection des emplacements v52, le slot dynamique v41 et les références Blender. Les identités, statistiques et quatuor jouable sont conservés.

Les planches originales sont affichées sans recadrage ni transformation du fichier source. Une production séparée de portraits optimisés reste une proposition ultérieure ; sa lisibilité n’est pas présentée comme validée visuellement par ces tests automatisés.

Le nettoyage `c9c5dc80` retire seulement les neuf variantes `_2.webp` et quatre SVG sans consommateur retrouvé. Dix cartes de classes et toutes les ressources ennemis sont conservées. Les 211 tests ciblés, l’import Godot, le catalogue et le parcours joueur passent après nettoyage ; la CI du dernier commit et la merge queue restent à contrôler avant fusion.

Preuves, limites et état de suivi détaillés : `HERO_RUNTIME_DEPENDENCIES_20261111.md` et `hero_cleanup_evidence_20261111.json`. Les propositions ci-dessus ne signifient pas que des textures dérivées ont été produites ou qu’un playtest visuel a eu lieu.

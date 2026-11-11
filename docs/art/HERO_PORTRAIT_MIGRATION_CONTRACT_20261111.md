# Contrat de migration des portraits LITD 1 — audit complémentaire

## État vérifié sur main (2026-11-11)

- `scripts/ui/main_v52.gd` référence `res://assets/heroes/{duelist,breaker,mystic,surgeon}.webp` pour Mathilde, Marec, Anouk, Aurélien. Les références sont chargées dans le profil et l'interface de combat.
- `data/canonical_art_v41.json` définit `portrait.active_hero` via `res://assets/art/v41/portraits/{entity_id}.webp` (entrée dynamique, `required_at_runtime=false`).
- `scripts/visual/canonical_art_registry.gd` charge ce second manifeste.
- La PR #610 est ouverte en brouillon ; les six JPEG validés ne sont pas encore importés.

## Décisions techniques provisoires

1. Conserver les six JPEG originaux dans `art/library/heroes/<id>/reference.jpg` avec contrôle SHA-256. Ces planches sont les **sources de vérité artistiques**, pas nécessairement les textures optimisées à afficher en combat.
2. Prévoir une couche d'assets runtime dérivés distincte, générée et traçable, pour les portraits affichés en jeu. Ne pas substituer arbitrairement une planche entière à un portrait recadré sans contrôle de lisibilité.
3. Réconcilier les deux mécanismes de portraits (`main_v52.gd` et `canonical_art_v41.json`) ; définir un seul registre de résolution des identités et chemins actifs.
4. Maintenir le quatuor jouable existant ; Éffrie et Lya restent dans la bibliothèque tant qu'une décision gameplay ne les active pas.
5. Avant toute suppression de WebP/SVG, inventorier leurs références dans scripts, scènes, ressources, tests, documentation et caches PWA.
6. Ajouter des tests : unicité des identités, existence des ressources, cohérence entre registre et interface, absence de référence active supprimée, import Godot et vérification visuelle lorsque disponible.

## Statut

Audit des deux systèmes : **vérifié par lecture de fichiers**.
Architecture cible : **proposée, non implémentée**.
Import JPEG, génération runtime, tests Godot et nettoyage : **non réalisés**.

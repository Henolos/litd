# LITD 1 — Contrats de données : compagnie et feu de camp V0.1

**18 novembre 2026 — Proposition technique documentaire, non validée, non implémentée.**

## Vérifications du socle (lecture seule)
- `project.godot` sur `main` déclare l'autoload `SaveManager` depuis `res://scripts/core/save_manager.gd`.
- `scripts/core/save_manager.gd` sur `main` : `SAVE_VERSION = "0.31"`, trois slots, autosauvegarde, `set_snapshot(Dictionary)`, `get_snapshot()`, `save_game()`, `load_game()`. Le snapshot est opaque et copié profondément. Le gestionnaire n'est pas couplé à l'ancien gameplay.
- `docs/reconstruction/RESET_20261112.md` décrit la suppression de 842 fichiers de gameplay et la conservation du socle technique. Les tests historiques y sont documentés, mais **n'ont pas été réexécutés pendant cet audit**.
- `tools/qa/validate_project.py` existe et sélectionne le contrôle de reconstruction si le manifeste est présent.
- L'inventaire **exhaustif** des scripts/scènes et des tests SaveManager **reste à faire** : l'interface de recherche de fichiers n'a pas fourni d'arborescence complète. L'absence de résultat n'est pas une preuve d'absence de code.

## Contrat conceptuel proposé (ne pas coder avant validation)
Un seul état de campagne, produit par le futur runtime de jeu, sera transmis au `SaveManager` via `set_snapshot()`. Aucun second service de sauvegarde.

Exemple **illustratif et non figé** :
```json
{
  "party": {
    "members": [
      {"id": "hero", "hp": 60, "max_hp": 100, "resource": 8, "max_resource": 12, "injuries": []}
    ]
  },
  "supplies": {
    "rations": 3,
    "ingredients": {},
    "remedies": 1,
    "fuel": 2
  },
  "camp": {
    "location_id": "forest_rest_01",
    "rest_uses": 0,
    "last_meal_id": null,
    "dialogue_flags": {}
  },
  "quest": {
    "mushrooms_collected": 0,
    "mushrooms_carried": 0
  }
}
```

**Important :** ces clés et chiffres sont des exemples, pas des valeurs de jeu validées ; le gestionnaire de sauvegarde ajoutera sa propre version et ses métadonnées. Les champs de quête distinguent **récolte accomplie** et **champignons réellement rapportés**, puisqu'une partie est perdue pendant l'attaque du Némésis.

## Invariants à préserver
1. Identifiants stables des personnages et objets ; aucune dépendance à l'ordre des membres.
2. Santé et ressources bornées entre 0 et leurs maxima ; aucune récupération automatique totale.
3. Les repas et soins débitent les ressources exactement une fois ; action annulée = aucun débit.
4. Repos et cuisine ne ressuscitent pas un compagnon mort et ne suppriment pas les blessures persistantes sans règle spécifique.
5. Les bonus temporaires possèdent une durée et un mode d'expiration explicites, à décider.
6. Un état de campement et ses consommations survivent à un cycle sauvegarde/chargement.
7. Un feu de camp ne crée pas de sauvegarde autonome parallèle ; il utilise le snapshot du runtime et le `SaveManager` existant.
8. Le tutoriel de feu de camp se situe **avant** la récolte du dernier champignon et ne déclenche pas l'embuscade.

## Décisions de conception ouvertes
- Emplacements prédéfinis ou campements improvisés.
- Coût et disponibilité du combustible, recettes, ingrédients et rations.
- Pourcentages de récupération, ressources restaurées, durée du repos.
- Risque d'interruption, veille de nuit et zones sûres.
- Soins des afflictions et blessures persistantes.
- Fréquence des haltes, prévention des exploits de repos.
- Dialogues de compagnie et conséquences éventuelles sur les relations.
- Choix exact du moment de sauvegarde (manuel/automatique) et migration des futurs schémas de jeu.

## Plan de vérification avant implémentation
1. Obtenir un inventaire complet de l'arbre Git à une révision précise, avec les chemins `scripts/`, `scenes/` et `tests/`.
2. Lire les tests SaveManager conservés et établir une matrice couverture/risques ; ne pas extrapoler les tests historiques à la révision actuelle.
3. Vérifier les usages actuels du snapshot et les contrats de version/migration.
4. Faire valider les règles de gameplay ; fixer ensuite le schéma minimal.
5. Implémenter sur une branche dédiée, tester les invariants, le round-trip de sauvegarde, les limites et les régressions ; playtest dans Godot.

**Statut : 🟡 À CONSOLIDER. Aucun changement de gameplay, aucun test Godot exécuté.**

# Architecture UI consolidée

La scène principale conserve provisoirement une chaîne numérotée comme couche de compatibilité comportementale : chaque fichier ajoute une règle de combat testée et l’héritage empêche la duplication de toute la boucle.

Constat au 15 octobre 2026 sur `fd785096` : malgré l'objectif historique d'arrêt à `main_v34.gd` (aucun nouveau `main_v35.gd`), les changements déjà fusionnés ont étendu la chaîne jusqu'à `main_v52.gd`, avec une variante `main_v50_ge01.gd`. Cette extension est une dette d'architecture existante, pas une architecture approuvée pour les ajouts futurs. La CI vérifie désormais cette borne exacte et le raccordement réel des couches cliniques par héritage. Aucune couche supplémentaire ne doit être créée ; la consolidation reste à réaliser avec sa validation runtime/visuelle.

À partir de cette version, les nouvelles fonctions sont séparées :

- `ui_section_registry.gd` : navigation et titres du menu unifié ;
- `game_menu_ui.gd` : composition des sections hors combat ;
- `combat_preview_director.gd` : prévision des actions ;
- `action_timeline_director.gd` : ordre et intentions ;
- `effect_tooltip_formatter.gd` : descriptions des effets ;
- `expedition_preparation_director.gd` : formations et contrôles ;
- `expedition_report_director.gd` : bilans ;
- `campaign_memory_director.gd` : chronique et codex ;
- `accessibility_director.gd` : application des réglages.

Règles :

1. aucune nouvelle logique métier dans `game_menu_ui.gd` ;
2. aucune nouvelle variante numérotée de `main.gd` ;
3. les composants doivent être testables sans rendu ;
4. les inspections et prévisions ne mettent jamais le combat en pause ;
5. la suppression de la chaîne historique attend le PC, une scène de remplacement et une validation visuelle complète.

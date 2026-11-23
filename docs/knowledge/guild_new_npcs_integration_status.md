# Prototype d'intégration : tavernier et médecin

Branche : feature/guild-illustrated-hub-design-20261122 (PR #633).

## Réalisé
- Deux fiches PNJ structurées dans data/guild_new_npcs.json.
- Écran Godot dans scenes/hub/guild_new_npcs_screen.tscn, script scripts/ui/guild_new_npcs_screen.gd.
- Bouton d'accès depuis le hub existant (scripts/ui/game_hub.gd).
- Raccordement des identifiants de PNJ aux lieux tavern et infirmary dans data/guild_illustrated_hub_design.json.
- Contrat de recherche dans data/guild_bestiary_research.json, sans modifier le catalogue canonique des espèces. Les connaissances sont propres au protagoniste ; la maîtrise de chaque compagnon est suivie individuellement.
- Manifeste d'images avec empreintes SHA-256.

## Non réalisé / non testé
- Les deux planches PNG sont présentes dans `main`, base de la PR. Leurs empreintes SHA-256 et tailles ont été recalculées dans l’arbre de travail synchronisé avec `main` et correspondent au manifeste de livraison.
- Aucun test d'exécution Godot 4.x ; vérifier compilation, chargement de la scène, boutons et dialogues.
- Aucun effet réel de soins, quêtes, affinité ou déblocage de faiblesses. L'écran est un prototype de navigation et de dialogues.
- Les deux portraits n'apparaissent pas encore dans l'interface, faute de ressources binaires dans le dépôt.
- La recherche anatomique de Mei Ling et les connaissances historiques de Wei Shan alimentent **un seul catalogue de définitions d'espèces** ; le niveau de connaissance est conservé dans le bestiaire de chaque protagoniste. Ne pas créer de second catalogue de monstres ni partager automatiquement la progression entre protagonistes.
- Les noms Han Lu et Dr Mei Ling restent à confirmer séparément des planches artistiques validées.

## Validation à faire
1. Vérifier le rendu intégral des deux planches dans l’écran Godot, sans recadrage des originaux.
2. Inspecter les systèmes réels de sauvegarde, quête et bestiaire, puis raccorder des déblocages persistants après validation de leur schéma.
3. Revoir les documents de navigation selon la carte à nœuds et valider la boucle jouable.
4. Revoir et fusionner la PR après tests, sans fusion automatique.

## Reprise du 2026-11-22
- État antérieur de la branche : les deux PNG étaient absents.
- Dans `main`, les deux PNG sont présents et leur SHA-256 correspond aux valeurs archivées (tavernier 3 119 445 octets ; médecin 2 943 072 octets).
- Le prototype UI affiche désormais la planche complète lorsqu'elle existe et un message explicite lorsqu'elle manque. L'écran distingue les recherches anatomiques prévues des fonctionnalités opérationnelles.
- Importateur vérifié par conception ajouté : `python tools/import_guild_tavernier_medecin.py /chemin/vers/LITD1_guilde_tavernier_medecin_assets_a_integrer.zip`. Il refuse les empreintes incorrectes et les conflits de fichiers existants. **Son exécution dans un clone du dépôt n'a pas été testée ici.**
- Le 23 novembre 2026, Godot 4.7.2 a chargé `scenes/hub/guild_new_npcs_screen.tscn` en headless sans erreur ; `tools/qa/validate_project.py` a renvoyé `RECONSTRUCTION_ALL_AUDIT_OK`. Ce contrôle ne remplace pas une revue visuelle du rendu ou un test de navigation en fenêtre. Ne pas fusionner sans ces validations et la vérification des systèmes de sauvegarde.

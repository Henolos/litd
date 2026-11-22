# Prototype d'intégration : tavernier et médecin

Branche : feature/guild-illustrated-hub-design-20261122 (PR #633).

## Réalisé
- Deux fiches PNJ structurées dans data/guild_new_npcs.json.
- Écran Godot dans scenes/hub/guild_new_npcs_screen.tscn, script scripts/ui/guild_new_npcs_screen.gd.
- Bouton d'accès depuis le hub existant (scripts/ui/game_hub.gd).
- Raccordement des identifiants de PNJ aux lieux tavern et infirmary dans data/guild_illustrated_hub_design.json.
- Contrat commun de recherche bestiaire dans data/guild_bestiary_research.json, sans modifier le catalogue canonique.
- Manifeste d'images avec empreintes SHA-256.

## Non réalisé / non testé
- Images binaires **non transférées dans GitHub**. Le ZIP de livraison doit être importé en conservant les chemins et SHA-256 du manifeste.
- Aucun test d'exécution Godot 4.x ; vérifier compilation, chargement de la scène, boutons et dialogues.
- Aucun effet réel de soins, quêtes, affinité ou déblocage de faiblesses. L'écran est un prototype de navigation et de dialogues.
- Les deux portraits n'apparaissent pas encore dans l'interface, faute de ressources binaires dans le dépôt.
- La recherche anatomique de Mei Ling et les connaissances historiques de Wei Shan doivent enrichir **un seul** bestiaire ; ne pas créer de second catalogue de monstres.
- Les noms Han Lu et Dr Mei Ling restent à confirmer séparément des planches artistiques validées.

## Validation à faire
1. Transférer les deux PNG, comparer les empreintes du manifeste.
2. Lancer Godot 4.x, ouvrir le hub puis les deux PNJ, contrôler les retours.
3. Ajouter les portraits validés en lecture seule et vérifier leur cadrage sans recadrer les originaux.
4. Inspecter les systèmes réels de sauvegarde, quête et bestiaire, puis brancher des déblocages persistants après validation de leur schéma.
5. Revoir et fusionner la PR après tests, sans fusion automatique.

## Reprise du 2026-11-22
- Vérification directe GitHub : les deux PNG attendus renvoient 404 sur la branche de la PR.
- Vérification locale du ZIP : les deux fichiers PNG existent et leurs tailles et SHA-256 correspondent au manifeste (tavernier 3 119 445 octets ; médecin 2 943 072 octets).
- Le prototype UI affiche désormais la planche complète lorsqu'elle existe et un message explicite lorsqu'elle manque. L'écran distingue les recherches anatomiques prévues des fonctionnalités opérationnelles.
- Importateur vérifié par conception ajouté : `python tools/import_guild_tavernier_medecin.py /chemin/vers/LITD1_guilde_tavernier_medecin_assets_a_integrer.zip`. Il refuse les empreintes incorrectes et les conflits de fichiers existants. **Son exécution dans un clone du dépôt n'a pas été testée ici.**
- Aucun test Godot exécuté. Ne pas fusionner sans validation d'ouverture de scène, rendu des images, navigation et sauvegarde.

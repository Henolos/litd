# LITD 1 — Héros débloqués par l'histoire

Décision validée : **Anouk → Marec → Mathilde**. Ce sont trois personnages canoniques existants, distincts du quatuor de départ. Les IDs canoniques sont réutilisés.

## Recrutement et progression

- Le niveau de chaque héros est aligné sur le niveau courant du protagoniste au recrutement.
- Les choix des arbres de compétences et les choix de compétences évolutives sont remis à zéro au recrutement. Les arbres de conception eux-mêmes restent des références ; le calcul des points suit la règle canonique LITD 1 lorsqu'elle sera vérifiée.
- L’ordre est soutenu par les événements canoniques existants `formation.anouk_rank_2`, `formation.marec_rank_3` et `formation.mathilde_rank_4` dans `universe/lore/legendary_seven_formation.json`. Ils décrivent l’arrivée successive des héros et du groupe déjà formé.
- Les conditions de conception sont fixées : le jalon canonique correspondant doit être achevé, dans l’ordre Anouk → Marec → Mathilde ; le drapeau d’accès des héros précédents doit exister pour le jalon suivant. La présence effective des héros précédents dans l’équipe n’est pas requise.
- Le dépôt n’a pas de gestionnaire d’événements de campagne ni de recrutement des héros jouables : le bouton Nouvelle partie de `game_hub.gd` est désactivé et aucune scène de boucle de jeu n’est présente. Le raccordement aux missions/chapitres ne peut donc pas encore être testé sans construire la boucle de jeu. Aucun système parallèle n’est ajouté.
- Les drapeaux de héros débloqués persistent après Game Over ; la mort individuelle reste définitive et ne réinstancie pas le héros. Ces règles sont préparées dans les données, pas raccordées au runtime dans cette PR.

## Planches et portraits

- La planche d'Anouk est identique octet pour octet à `art/library/heroes/anouk/reference.jpg` ; cette ressource existante est réutilisée.
- La planche de Marec est identique octet pour octet à `art/library/heroes/marec/reference.jpg` ; cette ressource existante est réutilisée.
- La planche Mathilde fournie dans l'archive diffère de la planche canonique déjà présente. Elle est ajoutée comme référence de conception complémentaire sous `story_unlock/`, sans remplacement de l'original existant.
- Les trois PNG sont des recadrages provisoires. Le contrôle visuel montre du lettrage au bord gauche du portrait d’Anouk et au coin supérieur gauche de celui de Mathilde ; aucun fragment de lettrage évident n’a été repéré sur celui de Marec. Aucun n’est approuvé par l’utilisateur ni raccordé au combat.
- Le manifeste conserve les SHA-256 de l'archive et des ressources. Aucun doublon de planche Anouk/Marec n'est ajouté.

## Statut

- Ordre et règles de progression : documentés ; données contractuelles préparées, non raccordées au runtime.
- Binaires : les planches Anouk/Marec sont réutilisées ; la planche distincte de Mathilde et les trois portraits provisoires sont importés.
- Tests automatisés de contrat, de correspondance avec les événements canoniques, d’intégrité et de persistance des déblocages : ajoutés dans cette PR.
- Les candidats de recadrage ont été contrôlés pour l’absence de lettrage de bord ; les planches restent intactes. L’intégration runtime et l’essai en jeu restent bloqués par l’absence de boucle de jeu et de gestionnaire de recrutement.
- Les portraits et tests Godot ne sont pas une condition à la fusion des seules références de conception, mais aucun portrait ne doit servir en combat avant approbation visuelle.

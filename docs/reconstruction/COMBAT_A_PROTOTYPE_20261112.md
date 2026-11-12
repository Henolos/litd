# LITD 1 — Combat A, première expérience de reconstruction

## Décision de portée

L'intention du joueur est de comprendre **qui agit, qui peut être visé et ce que chaque action a produit**. L'hypothèse à tester est qu'un joueur sans explication extérieure distingue ces trois informations après un tour. Ce prototype suit `docs/veilleurs/FIRST_PLAYTEST_SLICE.md` (Combat A) et `docs/veilleurs/PRODUCTION_PLAYBOOK.md` (gate 1). Ce n'est pas la tranche de playtest complète.

Lancer la scène `res://scenes/prototype/combat_a.tscn` dans Godot. Le projet conserve volontairement l'absence de scène principale : l'ancien jeu ne doit pas redevenir lançable par inadvertance.

Quatre héros sont chargés depuis `data/veilleurs/canonical_roster.json`, dans l'ordre canonique Mathilde, Marec, Anouk, Aurélien. Deux adversaires anonymes servent à tester le choix de cible. Chaque héros peut attaquer une cible vivante ou se protéger. Les adversaires ripostent à la fin du tour ; la garde réduit une seule attaque. L'interface indique l'acteur, les rangs affichés, les PV, la cible, un aperçu et un journal. Le redémarrage repart d'un état neuf. **Les rangs sont affichés, mais leur effet tactique n'est pas encore implémenté.**

Les deux ennemis, les points de vie, les dégâts et la présentation textuelle sont des **fixtures d'expérience**, sans validation de contenu ou de direction artistique. Les originaux visuels sont conservés et ne sont pas utilisés comme portraits provisoires. Les documents historiques de combat qui nomment Malvor, Darius ou Lysandra ne définissent pas le quatuor actuel ; `docs/STARTING_QUARTET_RESET.md` et le registre canonique prévalent.

## Critères de l'expérience

- Un joueur identifie l'acteur et la cible sélectionnée avant de confirmer.
- L'attaque affecte uniquement la cible choisie ; une cible hors combat n'est plus sélectionnable.
- La garde a un coût d'action et réduit la prochaine attaque reçue.
- Les ripostes, la victoire et la reprise à zéro sont visibles.
- Aucune scène ou script retiré au reset ne revient, et les 977 références préservées gardent leurs empreintes.

Les quatre premiers points sont **testés techniquement** par `tests/godot/test_combat_a_headless.gd` ; la compréhension d'un joueur extérieur reste **non testée**. Les métriques de playtest seront : erreurs de cible, demandes d'explication sur l'acteur ou la conséquence, et capacité à décrire le choix après un round.

## Socle et limites

- Le registre canonique existant fournit l'identité des héros ; le prototype ne copie pas les identités dans une nouvelle donnée canonique.
- Les 17 scripts techniques conservés restent contrôlés par la suite Godot. Le nouveau script et la scène sont explicitement listés dans `COMBAT_A_PROTOTYPE_MANIFEST.json`, sans modifier le manifeste de conservation initial.
- `SaveManager` possède des contrats réussis pour les instantanés et la récupération, mais **aucune sauvegarde réelle n'est encore raccordée à ce prototype**. Un emplacement isolé et une migration de schéma devront être définis avant son usage pour une partie. Aucun fichier de sauvegarde utilisateur n'est écrit par la scène.
- Aucun effet anatomique, peur, capture, compétence propre aux héros, déplacement, équipement, hub ou export n'est implémenté ici. Les rajouter dépendra de l'observation du premier combat.

## PR antérieures examinées le 12 novembre 2026

| PR | Contenu observé | Décision pour cette reconstruction |
| --- | --- | --- |
| #613, #612 | Ancien HUD, portraits, menus, gameplay et intégration du bestiaire | Ne pas fusionner telles quelles : elles réintroduisent des scripts retirés. Reprendre séparément les références ou observations utiles. |
| #607, #606, #604, #602, #601 | Documentation anatomique mêlée à l'ancien runtime ; ciblage, HUD et IA d'avant reset | Ne pas fusionner telles quelles. Examiner les décisions de conception individuellement pour une phase future. |
| #600 | Ancien test de matrice de combat | Garder comme source historique de questions d'équilibrage ; test non applicable à cette expérience. |
| #608 | Registre documentaire provisoire du bestiaire | Examiner la provenance et les validations avant toute reprise documentaire. |
| #596 | Marqueur de playtest et modification de `project.godot` | Ne pas fusionner telle quelle ; instrumenter plus tard si le besoin est confirmé. |

Cette revue porte sur les noms et chemins modifiés de ces PR. Elle n'est pas un audit complet des diffs ni une clôture de ces PR.

## Vérifications et prochaine décision

Sur la branche locale, Godot 4.6.3 a réussi le test `COMBAT_A_EXPERIMENT_OK`, l'import, les six contrôles techniques et la suite `GODOT_CI_STRICT_OK`. L'audit des références renvoie `RECONSTRUCTION_ALL_AUDIT_OK`. La scène a été ouverte dans une fenêtre Godot et une cible a été attaquée en cliquant : le tour est passé de Mathilde à Marec, les PV de la bonne cible sont passés de 8 à 4 et le journal a affiché la conséquence. La CI distante 4.7.2 et le playtest d'un nouveau joueur restent à faire.

Décision après le premier playtest : **garder, modifier ou supprimer** cette interface et ces règles de base avant de construire Combat B.

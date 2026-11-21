# Audit des associations du bestiaire runtime — 2026-11-21

## Décision de référence canonique

`data/enemies.json` reste la source canonique des identifiants et noms de monstres : ces noms sont aussi utilisés par les définitions de capture, les profils corporels, les mouvements et les tâches de production Blender. Les titres incrustés dans les 39 WEBP ne sont pas une source de vérité déclarée. L’audit d’images du 11 novembre indique que les images ennemies ont été conservées sans modification, mais n’atteste pas leur identité artistique ni leur association individuelle aux espèces.

En conséquence, aucune entrée de gameplay n’est renommée et aucun fichier actif n’est remappé dans cet audit. Une illustration titrée différemment est traitée comme une discordance à résoudre, pas comme une autorisation de renommer l’espèce.

## Résultat de rapprochement par nom

Les 8 références ci-dessous ont un sujet dont le nom correspond clairement à une espèce du runtime. Cela établit une référence d’espèce disponible, mais ne valide pas que le WEBP runtime actuel représente cette référence ni que son cadrage convienne au jeu.

| ID | Nom canonique du jeu | Référence archivée correspondante | Image runtime actuelle | Conclusion |
|---:|---|---|---|---|
| 01 | Goule affamée | ghoul/reference.png | `assets/enemies/enemy_01.webp` | Référence d’espèce trouvée; portrait runtime non vérifié |
| 02 | Cultiste fanatisé | — aucune planche correspondante identifiée par nom | `assets/enemies/enemy_02.webp` | Référence validée correspondante à fournir ou identifier |
| 03 | Chevalier déchu | — aucune planche correspondante identifiée par nom | `assets/enemies/enemy_03.webp` | Référence validée correspondante à fournir ou identifier |
| 04 | Ver des profondeurs | — aucune planche correspondante identifiée par nom | `assets/enemies/enemy_04.webp` | Référence validée correspondante à fournir ou identifier |
| 05 | Écorcheur | — aucune planche correspondante identifiée par nom | `assets/enemies/enemy_05.webp` | Référence validée correspondante à fournir ou identifier |
| 06 | Gorgone | gorgon/reference.jpeg | `assets/enemies/enemy_06.webp` | Référence d’espèce trouvée; portrait runtime non vérifié |
| 07 | Minotaure | minotaur/reference.jpeg | `assets/enemies/enemy_07.webp` | Référence d’espèce trouvée; portrait runtime non vérifié |
| 08 | Oni | oni/reference.jpeg | `assets/enemies/enemy_08.webp` | Référence d’espèce trouvée; portrait runtime non vérifié |
| 09 | Tengu | karasu_tengu/reference.jpeg | `assets/enemies/enemy_09.webp` | Référence d’espèce trouvée; portrait runtime non vérifié |
| 10 | Jorōgumo | jorogumo/reference.jpg | `assets/enemies/enemy_10.webp` | Référence d’espèce trouvée; portrait runtime non vérifié |
| 11 | Yuki-Onna | yuki_onna/reference.jpeg | `assets/enemies/enemy_11.webp` | Référence d’espèce trouvée; portrait runtime non vérifié |
| 12 | Anubis | LITD1_BEST_EGY_ANUBIS_PESEUR_DES_AMES_V2_VALIDEE.png | `assets/enemies/enemy_12.webp` | Référence d’espèce trouvée; portrait runtime non vérifié |
| 13 | Prêtre momifié | — aucune planche correspondante identifiée par nom | `assets/enemies/enemy_13.webp` | Référence validée correspondante à fournir ou identifier |
| 14 | Scarabée funéraire | — aucune planche correspondante identifiée par nom | `assets/enemies/enemy_14.webp` | Référence validée correspondante à fournir ou identifier |
| 15 | Nécrophage | — aucune planche correspondante identifiée par nom | `assets/enemies/enemy_15.webp` | Référence validée correspondante à fournir ou identifier |
| 16 | Porte-Cierge | — aucune planche correspondante identifiée par nom | `assets/enemies/enemy_16.webp` | Référence validée correspondante à fournir ou identifier |
| 17 | Veuve du Voile | — aucune planche correspondante identifiée par nom | `assets/enemies/enemy_17.webp` | Référence validée correspondante à fournir ou identifier |
| 18 | Pèlerin creux | — aucune planche correspondante identifiée par nom | `assets/enemies/enemy_18.webp` | Référence validée correspondante à fournir ou identifier |
| 19 | Mange-Rêves | — aucune planche correspondante identifiée par nom | `assets/enemies/enemy_19.webp` | Référence validée correspondante à fournir ou identifier |
| 20 | Chien d’Os | — aucune planche correspondante identifiée par nom | `assets/enemies/enemy_20.webp` | Référence validée correspondante à fournir ou identifier |
| 21 | Sangsue royale | — aucune planche correspondante identifiée par nom | `assets/enemies/enemy_21.webp` | Référence validée correspondante à fournir ou identifier |
| 22 | Gardien aveugle | — aucune planche correspondante identifiée par nom | `assets/enemies/enemy_22.webp` | Référence validée correspondante à fournir ou identifier |
| 23 | Oracle brisé | — aucune planche correspondante identifiée par nom | `assets/enemies/enemy_23.webp` | Référence validée correspondante à fournir ou identifier |
| 24 | Enfant de suie | — aucune planche correspondante identifiée par nom | `assets/enemies/enemy_24.webp` | Référence validée correspondante à fournir ou identifier |
| 25 | Masque hurlant | — aucune planche correspondante identifiée par nom | `assets/enemies/enemy_25.webp` | Référence validée correspondante à fournir ou identifier |
| 26 | Dévoreur de lumière | — aucune planche correspondante identifiée par nom | `assets/enemies/enemy_26.webp` | Référence validée correspondante à fournir ou identifier |
| 27 | Porte-Peste | — aucune planche correspondante identifiée par nom | `assets/enemies/enemy_27.webp` | Référence validée correspondante à fournir ou identifier |
| 28 | Moiré | — aucune planche correspondante identifiée par nom | `assets/enemies/enemy_28.webp` | Référence validée correspondante à fournir ou identifier |
| 29 | Géant des cryptes | — aucune planche correspondante identifiée par nom | `assets/enemies/enemy_29.webp` | Référence validée correspondante à fournir ou identifier |
| 30 | Nonne renversée | — aucune planche correspondante identifiée par nom | `assets/enemies/enemy_30.webp` | Référence validée correspondante à fournir ou identifier |
| 31 | Éclat vivant | — aucune planche correspondante identifiée par nom | `assets/enemies/enemy_31.webp` | Référence validée correspondante à fournir ou identifier |
| 32 | Charognard cuirassé | — aucune planche correspondante identifiée par nom | `assets/enemies/enemy_32.webp` | Référence validée correspondante à fournir ou identifier |
| 33 | Loup du Voile | — aucune planche correspondante identifiée par nom | `assets/enemies/enemy_33.webp` | Référence validée correspondante à fournir ou identifier |
| 34 | Semeur de cendres | — aucune planche correspondante identifiée par nom | `assets/enemies/enemy_34.webp` | Référence validée correspondante à fournir ou identifier |
| 35 | Miroir mort | — aucune planche correspondante identifiée par nom | `assets/enemies/enemy_35.webp` | Référence validée correspondante à fournir ou identifier |
| 36 | Prêtre du Néant | — aucune planche correspondante identifiée par nom | `assets/enemies/enemy_36.webp` | Référence validée correspondante à fournir ou identifier |
| 37 | Colosse sans nom | — aucune planche correspondante identifiée par nom | `assets/enemies/enemy_37.webp` | Référence validée correspondante à fournir ou identifier |
| 38 | Ange inversé | — aucune planche correspondante identifiée par nom | `assets/enemies/enemy_38.webp` | Référence validée correspondante à fournir ou identifier |
| 39 | Mère des Souffrances | — aucune planche correspondante identifiée par nom | `assets/enemies/enemy_39.webp` | Référence validée correspondante à fournir ou identifier |

## Contrôle des formats

- Les 39 images runtime mesurées sont en 480 × 760 px (ratio 12:19, environ 0,632), et non en 3:4.
- Les 36 images de la bibliothèque du bestiaire sont en 1536 × 1024 px (ratio 3:2), à l’exception du Sphinx en 1535 × 1024 px, également proche de 3:2.
- Il faut donc un dérivé portrait 3:4 validé pour chacune des 39 entrées. Les sources archivées doivent rester intactes.

## Limites et prochaine étape

- Le texte incrusté dans certains WEBP diffère du nom canonique. Exemples lisibles : `enemy_13.webp` porte « Géant putride », tandis que l’ID 13 est « Prêtre momifié »; `enemy_19.webp` porte « Chevalier funéraire », tandis que l’ID 19 est « Mange-Rêves »; `enemy_39.webp` porte « Revenant », tandis que l’ID 39 est « Mère des Souffrances ».
- La discordance ne suffit pas à décider si le WEBP est une mauvaise affectation, une ancienne version ou une illustration de placeholder. Cette intention n’est pas documentée.
- Prochaine étape : établir, à partir des sources artistiques validées, l’identité visuelle des 31 espèces sans planche correspondante et confirmer les 8 autres références. Produire ensuite les dérivés 3:4, les lier par identifiant de créature et contrôler l’affichage réel en jeu.

## Contrôles effectués

- Source : `main` au commit `7354938b` (21 novembre 2026).
- 39 entrées de `data/enemies.json` et les 39 chemins `assets/enemies/enemy_01.webp` à `enemy_39.webp` présents.
- 21 références validées de créatures mythologiques / folkloriques dans `docs/research/litd1_personnages`; 21 références documentées dans `docs/art/reconciled_bestiary_manifest_20261111.json`; 15 références communes supplémentaires recensées dans `docs/art/LITD1_BEST_COMMUNS_15_SHA256_20261121.csv`.
- Les contrôles de ce rapport sont documentaires et dimensionnels; aucun import Godot ni affichage visuel en jeu n’a été testé.

# LITD — inventaire des analyses de jeux et de mods

- ID : RESEARCH-GAME-CODE-INVENTORY-20261003
- Date : 2026-10-03
- Domaine : game design, programmation, génération procédurale, traçabilité
- Niveau : R0 pour cet inventaire interne ; aucune nouvelle étude externe réalisée
- Statut : active pour le constat au snapshot ci-dessous ; analyses externes à vérifier
- Confiance : high pour le périmètre inspecté
- Snapshot audité : `2b3f06621096e222b6e04e21ecf0bb86177e861b` (`Henolos/litd`, `main`)
- Revalidation : après ajout d'une analyse, récupération d'une source ou modification des documents indexés

## Question et périmètre

Retrouver les analyses de code/mods annoncées pour les quatre listes de jeux demandées,
les classer dans la bibliothèque LITD existante et distinguer les preuves conservées
des annonces conversationnelles. Les quatre listes représentent 25 entrées,
soit **19 jeux distincts** après déduplication.

Cet index enrichit `docs/research/` et le catalogue vivant existants. Il ne crée
aucune bibliothèque, aucun registre ou moteur supplémentaire. Les documents
présents restent à leur emplacement canonique ; les liens ci-dessous constituent
leur rangement commun.

## Sources et méthode

1. Arbre GitHub récursif complet : 2 645 entrées, `truncated=false`.
2. Clone du même commit : 2 466 fichiers suivis ; recherche des titres de jeux et
   des outils/mods annoncés dans les fichiers textuels suivis.
3. Historique accessible par les 549 références distantes du clone, dont
   `origin/HEAD` : inspection de **6 114 blobs textuels uniques** accessibles par
   `git rev-list --all --objects`. Extensions inspectées : `.md`, `.txt`, `.json`,
   `.yml`, `.yaml`, `.py`, `.gd`, `.lua`, `.cs`, `.nut`.
4. Relecture des descriptions de PR [#510](https://github.com/Henolos/litd/pull/510),
   [#515](https://github.com/Henolos/litd/pull/515),
   [#517](https://github.com/Henolos/litd/pull/517),
   [#520](https://github.com/Henolos/litd/pull/520),
   [#521](https://github.com/Henolos/litd/pull/521),
   [#522](https://github.com/Henolos/litd/pull/522),
   [#525](https://github.com/Henolos/litd/pull/525) et
   [#526](https://github.com/Henolos/litd/pull/526).
   Ces descriptions concernent l'implémentation LITD et ne fournissent pas une
   étude traçable des mods des jeux de référence.
5. Recherche complémentaire dans les fichiers ChatGPT : requêtes LITD/bibliothèque,
   Darkest Dungeon/mods, mods, analyse/jeux, BaseMod et génération procédurale.
   Aucune fiche d'analyse de code externe correspondante n'a été identifiée dans
   les résultats ; les bibles, prototypes et références visuelles ne constituent
   pas de telles fiches.
6. Les listes ci-dessous sont reprises des demandes et de leur contexte antérieur.
   Une annonce antérieure « étudié » n'est jamais comptée comme preuve technique.

Termes techniques recherchés en complément des titres : `Pitch Black`, `BaseMod`,
`ModTheSpire`, `ExpandTheGungeon`, `Alexandria`, `DeadCellsTools`, `ddrand`,
`Player Balance`. Aucun de ces termes n'a permis de récupérer une analyse de mod
dans le dépôt au snapshot audité.

Limites : cet audit n'inspecte pas les branches supprimées devenues inaccessibles,
les archives binaires de mods, tous les commentaires de PR ou tous les artefacts
temporaires Actions. La recherche de fichiers n'est pas une preuve d'absence
universelle. Une analyse conservée sous un nom sans aucun marqueur recherché
pourrait échapper à l'inventaire.

## Documents déjà conservés — classement canonique

| Document | Contenu conservé | Niveau réellement attesté |
|---|---|---|
| [Bibliothèque création de jeu vidéo](BIBLIOTHEQUE_CREATION_JEU_VIDEO.md) | Production, architecture Godot, UX, QA, sources générales | Méthodes de production ; aucune analyse de mod par jeu |
| [Benchmark roguelike / dungeon crawler](ROGUELIKE_DUNGEON_CRAWLER_BENCHMARK.md) | Darkest Dungeon et Shattered Pixel Dungeon ; lumière, stress, ressources, extraction, hypothèses LITD | Synthèse de design ; aucun fichier/fonction de mod analysé |
| [Observations de runs](ROGUELIKE_RUN_OBSERVATIONS.md) | Darkest Dungeon, Shattered Pixel Dungeon ; compléments Battle Brothers, Iratus, Into the Breach | Observations déclarées ; runs non identifiés par URL/date ; preuve de code absente |
| [Combat tactique et rangs](../COMBAT_TACTIQUE_RANGS.md) | Règles LITD, distinction avec Darkest Dungeon | Document LITD ; aucune analyse de mod |
| [Validation du graphe hybride](HYBRID_GRAPH_CONNECTIVITY_VALIDATION_2026-10-02.md) | Correction du générateur LITD, tests, références Godot et dominance de graphe | Validation interne ; aucune étude de code externe |

Origines des deux documents comparatifs :
`4edd2c9f268fada765ab8d63fb528c1e3ea0d546` et
`1930da2568bb5c0143b71726e03cfc3b50e4a2fb`, tous deux datés du 2026-09-09.
Ils précèdent les demandes du 2026-10-02 et ne prouvent pas que ces demandes ont
été exécutées.

## Couverture des quatre listes

Groupes : **A** = dix jeux proches de Darkest Dungeon / Battle Chasers ;
**B** = cinq roguelike difficiles ; **C** = cinq dungeon crawlers hardcore ;
**D** = cinq jeux à donjons procéduraux.

« Non retrouvée » signifie qu'aucune fiche traçable n'a été récupérée dans le
périmètre inspecté, et ne signifie pas que le jeu serait techniquement inaccessible.

| Jeu | Groupes | Éléments présents | Analyse de code/mod traçable |
|---|---|---|---|
| Darkest Dungeon | A, D | Benchmark + observations de runs | Non retrouvée |
| Battle Chasers: Nightwar | A | Aucun document comparatif retrouvé | Non retrouvée |
| Ruined King | A | Aucun document comparatif retrouvé | Non retrouvée |
| Iratus: Lord of the Dead | A, B, C | Complément de design dans les observations | Non retrouvée |
| Darkest Dungeon II | A, C | Aucun document comparatif retrouvé | Non retrouvée |
| For the King | A | Aucun document comparatif retrouvé | Non retrouvée |
| Octopath Traveler II | A | Aucun document comparatif retrouvé | Non retrouvée |
| Chained Echoes | A | Aucun document comparatif retrouvé | Non retrouvée |
| Slay the Spire | A, B | Aucun document comparatif retrouvé | Non retrouvée |
| Battle Brothers | A, B | Complément blessures/moral dans les observations | Non retrouvée |
| Into the Breach | B | Complément télégraphie dans les observations | Non retrouvée |
| FTL: Faster Than Light | B | Aucun document comparatif retrouvé | Non retrouvée |
| Stoneshard | C | Aucun document comparatif retrouvé | Non retrouvée |
| Legend of Grimrock II | C | Aucun document comparatif retrouvé | Non retrouvée |
| Dungeon of the Endless | C | Aucun document comparatif retrouvé | Non retrouvée |
| Enter the Gungeon | D | Aucun document comparatif retrouvé | Non retrouvée |
| Dead Cells | D | Aucun document comparatif retrouvé | Non retrouvée |
| The Binding of Isaac: Rebirth | D | Aucun document comparatif retrouvé | Non retrouvée |
| Spelunky 2 | D | Aucun document comparatif retrouvé | Non retrouvée |

Shattered Pixel Dungeon est présent dans les deux documents comparatifs mais ne
fait pas partie de ces quatre listes. Il reste indexé sans gonfler leur couverture.

**Bilan au snapshot :** observations de design pour 4/19 jeux demandés ;
aucune observation comparative retrouvée pour 15/19 ;
**0/19 analyses de code/mod traçables retrouvées**.
Un titre cité, une recommandation de mod ou une PR LITD verte ne valident pas une
analyse externe.

## Analyses manquantes — admission dans la bibliothèque existante

Les 19 lignes restent à compléter avec des preuves techniques. Pour chaque jeu :

1. récupérer la fiche originale si elle existe ; sinon réaliser l'étude avant
   de la déclarer terminée ;
2. identifier la source primaire réellement accessible : dépôt de mod, SDK,
   documentation de modding ou code ouvert ; préciser auteur, licence, version,
   URL et commit/hash quand disponibles ;
3. relever les fichiers et fonctions effectivement lus, leurs responsabilités,
   le flux de données, les contraintes et les limites d'interprétation ;
4. distinguer le code du mod de ce qu'il permet seulement d'inférer sur le jeu ;
5. consigner résultat, contre-preuves, hypothèse LITD et test dans `docs/research/`
   suivant le [format Research Record](../knowledge/templates/research.md),
   puis relier la fiche depuis cet index ;
6. laisser les pistes sans source accessible au statut `revalidate`, avec le
   blocage exact, plutôt que remplacer une preuve technique par une synthèse de
   gameplay.

Les noms de mods évoqués dans les échanges sont des pistes à vérifier ; cet audit
ne certifie ni leur existence, ni leur compatibilité, ni leur contenu. Aucun code
tiers n'est importé et aucun statut de connaissance n'est promu automatiquement.

## Contradictions et décisions

L'annonce que toutes les analyses sont déjà rangées n'est pas étayée par les
preuves récupérées. Cet inventaire corrige ce constat sans inventer les études
manquantes. Les observations existantes sont conservées, mais leur niveau de
preuve reste explicite.

Le ciblage des parties du corps, les rangs, les afflictions, les rencontres et les
générateurs existants ne sont pas modifiés par cet audit. Une étude externe future
devra suivre [le protocole vivant](../knowledge/LIVING_LIBRARY_PROTOCOL.md) et
[le pipeline du Veilleur](../knowledge/LITD_VEILLEUR_RESEARCH_PIPELINE.md) avant
de proposer une modification du jeu.

## Vérification finale et avancement

- Accès GitHub et bibliothèque existante : vérifiés.
- Inventaire et classement des documents récupérés : terminés au snapshot.
- Analyses techniques externes retrouvées et admissibles : 0/19.
- Études manquantes : explicitement identifiées ; aucune réalisation présumée.
- Changement proposé : documentation uniquement, par PR dédiée ; validation CI
  consultable sur la PR. Cet inventaire ne certifie pas une fusion.
- Avancement du jeu et du projet global : aucun nouvel avancement d'implémentation
  attribuable à cet audit ; aucun pourcentage global recalculé.

Relations : `source_for` → audit de couverture ; `contradicts` → annonce de
complétude sans fiches ; `depends_on` → snapshot Git audité ; `validated_by` →
inspection Git et contrôles de documentation de la PR ; `influences` → reprise
des études manquantes. Aucune écriture dans le Core.

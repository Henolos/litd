# Inventaire vérifié des études de jeux et de mods LITD

- ID : RR-LITD-GAME-STUDIES-20261003
- Date : 2026-10-03
- Domaine : recherche de game design / architecture / provenance
- Niveau : R1 pour les pistes externes ; audit Git pour la présence documentaire
- Statut : revalidate
- Confiance : high pour l'inventaire du commit ; low pour les conclusions historiques sans pièces
- Base auditée : `Henolos/litd`, `2b3f06621096e222b6e04e21ecf0bb86177e861b`
- Revalidation : modification des dossiers audités, récupération d'une étude originale ou nouvelle lecture de code source.

## Conclusion

La bibliothèque existe. La présence de toutes les analyses de code/mods annoncées en conversation n'est pas confirmée dans le commit audité. Une observation de gameplay, une page de mod et une analyse de code sont des niveaux de preuve différents. Aucune étude de code/mods détaillée des jeux ci-dessous n'a été retrouvée dans les fichiers textuels recherchés ; cela ne prouve pas qu'elle n'existe dans aucune autre source.

Les observations existantes sont conservées à leur emplacement. Les conclusions historiques non étayées sont rangées ci-dessous comme pistes `revalidate`, sans promotion en canon. Ce document et son [manifeste](GAME_STUDIES_INVENTORY_2026-10-03.json) enrichissent `docs/research/` ; ils ne constituent pas une autre bibliothèque.

## Qui ? Quoi ? Où ? Pourquoi ? Comment ?

Audit du dépôt réel après rétablissement de l'accès GitHub : arbre Git récursif non tronqué, clone, inventaire des fichiers suivis, recherche textuelle des titres et outils, lecture des points d'entrée et des documents correspondants. La liste des chemins historiques des trois dossiers a également été consultée avec `git log --all --format= --name-only` ; elle ne remplace pas une lecture de toutes les versions historiques.

Le manifeste conserve les 142 fichiers suivis des dossiers ci-dessous, leurs SHA de blob Git, la base auditée, les termes et les limites de recherche. Le dépôt contient 2 466 fichiers suivis à cette base (2 645 entrées dans l'arbre Git en comptant les répertoires).

## Emplacements existants

| Emplacement | Fichiers à la base | Fonction vérifiée |
|---|---:|---|
| `litd_universe/libraries/` | 85 | 19 bibliothèques communes de références et d'assets, politique de droits et index |
| `docs/research/` | 5 | Recherches génériques : production, boucle roguelike, observations, trieur et connectivité |
| `docs/knowledge/` | 52 | Catalogue humain, protocoles, décisions, registres et gouvernance |

Les 19 catégories partagées sont : artistic_references, cultures_architecture, sculptures, paintings, mosaics_drawings, materials_textures, environments, vegetation, creatures, anatomy, clothing_armor, weapons_objects, sound_music, animation_movement, visual_effects, shared_lore, symbols, philosophies et technologies. Le statut de maturité déclaré dans leur README n'est pas une preuve de présence des études de mods.

| Document existant | Contenu constaté | Limite |
|---|---|---|
| [Bibliothèque création de jeu vidéo](BIBLIOTHEQUE_CREATION_JEU_VIDEO.md) | Méthodes de production, sources Godot/mobile/accessibilité | Pas une étude des mods des jeux |
| [Benchmark roguelike](ROGUELIKE_DUNGEON_CRAWLER_BENCHMARK.md) | Darkest Dungeon et Shattered Pixel Dungeon ; hypothèses Lumière, attrition et extraction | Pas de version de code, fichiers/fonctions analysés ni preuve d'exécution des mods |
| [Observations de runs](ROGUELIKE_RUN_OBSERVATIONS.md) | Les deux jeux précédents ; compléments Battle Brothers, Iratus et Into the Breach | Pas de liens horodatés vers les runs, ni étude technique détaillée des mods |
| [Recherche trieur](FILE_SORTER_RESEARCH.md) | Références d'architecture du trieur | Hors études de jeux |
| [Connectivité hybride](HYBRID_GRAPH_CONNECTIVITY_VALIDATION_2026-10-02.md) | Validation du graphe LITD | Preuve interne LITD, pas analyse du code d'un jeu tiers |

## Analyses présentes / manquantes et rangement des pistes

Le périmètre est l'union des jeux explicitement retrouvés dans l'historique pertinent et des cinq jeux cités dans les documents actuels. Les listes procédurales dont les cinq titres n'ont pas été récupérés restent un écart de périmètre ; aucun titre n'est inventé pour les compléter.

| Jeu | Pièce actuelle dans le dépôt | Piste historique à revalider | Pièce manquante pour une étude technique vérifiée |
|---|---|---|---|
| Darkest Dungeon | Benchmark §3 et observations §§1, 4–6 ; référence de rangs dans `docs/COMBAT_TACTIQUE_RANGS.md` | Pitch Black Dungeon ; rangs, attrition et lisibilité | Version du mod, fichiers de données réellement lus, règles comparées, limites et tests LITD |
| Shattered Pixel Dungeon | Benchmark §4 ; observations §§2 et 4 | Gestion des ressources et connaissance | Commit du code source, fonctions examinées, trace de reproduction et licence |
| Battle Brothers | Observations §8 et introduction | MSU / Modern Hooks / Modding Script Hooks / Legends ; blessures et moral | Mod et commit précis, fonctions/hooks examinés, interactions et contre-exemple |
| Iratus | Observations §5 et introduction | États mentaux ; Player Balance JSON cité antérieurement | Provenance et version exactes du JSON, champs examinés, portée réelle de l'observation |
| Into the Breach | Observations §7 et introduction | Télégraphie des intentions | Source primaire et preuve technique ; aucune analyse de mod n'est déduite de cette mention |
| Battle Chasers: Nightwar | Aucune occurrence du titre dans la recherche actuelle | BepInEx / logging cités, à rattacher précisément ; combat tour par tour | Mod attribué, URL, version, code lu et preuve de compatibilité |
| Slay the Spire | Aucune occurrence du titre | BaseMod ; extensions et builds | Commit, abonnements/patches examinés et test d'application à LITD |
| Octopath Traveler II | Aucune occurrence du titre | Arena Battle Mode / stopRNG cités antérieurement | Attribution confirmée des mods, version et code réellement consulté |
| Chained Echoes | Aucune occurrence du titre | Étude annoncée, détail technique non récupéré | Source précise, fichiers, conclusions et limites |
| For The King | Aucune occurrence du titre | FTKAPI | Commit, API réellement examinées et portée par rapport au jeu propriétaire |
| Darkest Dungeon II | Aucune occurrence du titre | Modify / Inherit / New | Documentation primaire/version et exemple réel de données ; ne pas transférer les règles DD1 |
| Ruined King | Aucune occurrence du titre | Étude restant à terminer dans l'historique | Source/mod identifié et fiche complète |
| Stoneshard | Aucune occurrence du titre | Membres/blessures | Code ou données du mod réellement lus et comparaison avec l'anatomie LITD |
| Legend of Grimrock II | Aucune occurrence du titre | Entity / Component | Documentation/mod/version et fonctions consultées |
| Dungeon of the Endless | Aucune occurrence du titre | Contexte → sélection pondérée | Source/version et preuve du mécanisme ; aucune déduction de l'algorithme propriétaire |

Les annonces historiques « terminé », « clôturé » ou « 65 % » ne deviennent pas des statuts techniques vérifiés. Les noms d'outils historiques sont des pistes, pas une preuve qu'ils ont été lus ni qu'ils s'appliquent au bon jeu.

## Sources externes retrouvées le 3 octobre

Cette passe vérifie la disponibilité de pages primaires ; elle n'est pas une lecture complète de leur code. Les dates de version/commit restent à fixer avant analyse.

| Source | Auteur / type | Constat limité | Suite nécessaire |
|---|---|---|---|
| https://www.nexusmods.com/darkestdungeon/mods/57 | Page de publication Pitch Black Dungeon / auteur du mod | Page d'un overhaul retrouvée | Lire les fichiers publiés et relever leur version |
| https://github.com/MSUTeam/MSU | MSUTeam / dépôt de framework Battle Brothers | Dépôt primaire retrouvé | Fixer un commit et lire les hooks pertinents |
| https://github.com/daviscook477/BaseMod | Mainteneurs BaseMod / dépôt de modding Slay the Spire | README : hooks et console ; compilation nécessitant le JAR du jeu | Distinguer code du framework et code propriétaire, choisir un commit |
| https://github.com/ftk-modding/FTKAPI | ftk-modding / dépôt de framework | Dépôt primaire retrouvé | Fixer version et API étudiées |

Fiabilité : primaire pour ce que les auteurs publient ; insuffisante pour une conclusion sur le moteur propriétaire, l'équilibrage ou une adoption dans LITD. Ces liens ne sont pas ajoutés aux flux automatiques du Veilleur : une piste de recherche n'autorise pas une nouvelle ingestion.

## Résultats concordants

Les README et le protocole vivant convergent : références partagées dans `litd_universe/libraries/`, recherches génériques dans `docs/research/`, décisions et preuves dans `docs/knowledge/`. Les fichiers de gameplay retrouvés produisent déjà des hypothèses et des critères de playtest ; ils restent les sources de ces observations.

## Contradictions / limites

L'affirmation antérieure « toutes les analyses sont rangées » n'est pas démontrée par les pièces retrouvées. L'inventaire textuel ne couvre pas les binaires, les contenus de fichiers HTML/SVG, les imports Godot, les scènes/ressources Godot, les fichiers de verrouillage, les pièces jointes externes, les bases Supabase, les conversations complètes ni tous les contenus historiques des branches. Les exclusions exactes et les termes recherchés sont dans le manifeste. Les alias inconnus et titres absents peuvent échapper à une recherche par mots-clés.

## Recherche opposée

Avant de conclure à un manque, les trois emplacements existants ont été confrontés au README du dépôt, aux documents de design du générateur, au catalogue Knowledge et aux chemins historiques disponibles. Le pipeline de génération possède désormais une [documentation propre](../design/DUNGEON_GENERATION_PIPELINE_V1.md), avec sources Godot et validations déclarées. L'ancien blocage d'accès et les anciens chiffres d'implémentation ne décrivent donc pas nécessairement le dépôt actuel. Cette passe ne rerun pas ses smokes de gameplay.

## Ce qui est vérifié dans LITD

Accès en lecture, commit, chemins, nombres de fichiers, références documentaires et résultats de recherche. Aucun changement de combat, rangs, ciblage des parties du corps, afflictions, rencontres, données de génération, canon narratif ou autorisation de fusion.

## Ce qui reste inconnu

Le contenu intégral des études annoncées sans fichier récupéré ; les titres des listes procédurales non récupérées ; leur conservation éventuelle hors Git ; les versions de mods, fonctions analysées, résultats reproductibles et droits applicables.

## Décisions influencées

Conserver les observations existantes, indexer ce rapport dans les points d'entrée actuels, puis remplacer chaque piste par une preuve originale récupérée ou une nouvelle étude sourcée. Une étude technique complète doit identifier URL/auteur, version/commit, fichiers/fonctions lus, mécanisme observable, limites/contre-preuve, adaptation LITD et test. Si seuls des paramètres sont accessibles, annoncer une analyse de données ; si seuls des comportements sont observés, annoncer une étude de gameplay.

## Date ou condition de revalidation

Recalculer l'inventaire si la base change. Réviser la ligne d'un jeu lors de la récupération de sa fiche originale ou d'une nouvelle étude. Ne promouvoir aucune conclusion historique sans ses pièces.

## Relations Knowledge Graph

Validation locale du changement documentaire : `python tools/quality/validate_knowledge.py` PASS (12 règles, 9 écarts canoniques préexistants suivis) ; `PYTHONPATH=. python tools/qa/validate_project.py` PASS (59 contrôles, 0 échec) ; vérification des 142 SHA de blob contre la base et des liens Markdown locaux PASS ; `git diff --check` PASS. La commande du template sans `PYTHONPATH=.` échoue à importer `tools` dans cet environnement ; l'exécution avec le chemin du dépôt réussit. Aucun smoke Godot ni test de jeu tiers exécuté pour cet audit documentaire. La CI distante est à vérifier sur le commit de PR.

- source_for : inventaire documentaire des études LITD ; aucune promotion automatique du registre Knowledge.
- contradicts : affirmation non prouvée de rangement complet des études de code/mods.
- validated_by : manifeste des blobs et vérification des liens locaux ; contrôle Guardian existant.
- influences : benchmark roguelike et plan de récupération des études manquantes.

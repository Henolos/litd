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

**État courant — 6 octobre 2026 :** 20/20 fiches documentées ; **19/20 titres avec code, données ou scripts de patch versionnés lus**. Catégories exclusives : 6 règles, 7 définitions/configurations, 3 extensions et 3 outils/patchs. Battle Chasers et Ruined King disposent de scripts mémoire Switch inspectés ; leurs règles natives ne sont pas reconstruites. Iratus reste documentaire. La recherche accessible est arrêtée avec ces limites explicites ; les pièces manquantes deviennent des compléments non bloquants pour l'exploitation de la bibliothèque. Aucune analyse exhaustive certifiée.

La bibliothèque existe. La présence de toutes les analyses de code/mods annoncées en conversation n'est pas confirmée dans le commit audité. Une observation de gameplay, une page de mod et une analyse de code sont des niveaux de preuve différents. Aucune étude de code/mods détaillée des jeux ci-dessous n'a été retrouvée dans les fichiers textuels recherchés ; cela ne prouve pas qu'elle n'existe dans aucune autre source.

Les observations existantes sont conservées à leur emplacement. Les conclusions historiques non étayées sont rangées ci-dessous comme pistes `revalidate`, sans promotion en canon. Ce document et son [manifeste](GAME_STUDIES_INVENTORY_2026-10-03.json) enrichissent `docs/research/` ; ils ne constituent pas une autre bibliothèque.

**Complément du 3 octobre — récupération inter-conversations :** les recherches ciblées ont retrouvé des résumés techniques, noms de fonctions/formats, sources citées et listes de jeux dans les échanges du 2 octobre. Leur synthèse est conservée dans la section « Travaux récupérés des autres conversations » ci-dessous. Le manque initial concernait leur présence dans Git ; il ne signifie pas que tout le travail devait être refait. La récupération est une synthèse d'extraits retrouvés, pas un export intégral des conversations ni une vérification indépendante du code tiers.

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

Le tableau ci-dessous conserve le constat de la première passe, limité à 15 jeux. La récupération suivante résout la liste procédurale manquante et ajoute FTL, Enter the Gungeon, Dead Cells, The Binding of Isaac: Rebirth et Spelunky 2 : périmètre consolidé de 20 titres distincts, en incluant Shattered Pixel Dungeon déjà documenté. La colonne « Pièce actuelle » décrit la base Git auditée, avant ce complément.

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

Le contenu intégral des études, leur conservation éventuelle hors Git, les versions/commits des mods, les résultats reproductibles et droits applicables. Les titres des listes sont désormais récupérés, ainsi que plusieurs fonctions/formats rapportés ; leur présence dans un ancien message ne prouve pas leur exécution ni leur lecture complète.

## Travaux récupérés des autres conversations

### Provenance et périmètre retrouvés

Les dates ci-dessous sont celles des messages historiques, en UTC. Les références permettent de retrouver le travail par titre de conversation et plage temporelle ; aucune URL de conversation ni transcription complète n'a été retournée. Cette section conserve uniquement les résultats utiles à LITD, pas des données personnelles ni des échanges sans rapport avec ces études.

| Corpus du 2 octobre 2026 | Liste exacte retrouvée | Messages sources retrouvés (UTC) |
|---|---|---|
| « Analyser le code du jeu » | Darkest Dungeon ; Battle Chasers: Nightwar ; Ruined King ; Iratus ; Darkest Dungeon II ; For The King ; Octopath Traveler II ; Chained Echoes ; Slay the Spire ; Battle Brothers | 12:31:29–13:39:30 ; détails successifs à 12:38:24, 12:40:49, 12:46:26, 13:03:15, 13:05:11, 13:06:49, 13:08:14, 13:09:30, 13:22:07–13:22:31 |
| « Liste jeux donjons procéduraux » | Darkest Dungeon ; Enter the Gungeon ; Dead Cells ; The Binding of Isaac: Rebirth ; Spelunky 2 | Liste 14:58:53 ; études 14:59:51, 15:00:14, 15:00:45, 15:01:10 ; synthèse 15:01:48 |
| « Recommandation de jeux roguelike » | Battle Brothers ; Slay the Spire ; Into the Breach ; FTL: Faster Than Light ; Iratus | Demande/liste 15:09:44–15:10:56 ; sources 15:11:03 ; synthèse 15:12:17 ; rappel anatomique et adaptations 15:38:29–15:50:55 |
| « Liste dungeon crawlers hardcore » | Stoneshard ; Iratus: Lord of the Dead ; Legend of Grimrock II ; Dungeon of the ENDLESS ; Darkest Dungeon II | Liste 16:06:30 ; détails 16:09:54 ; synthèse 16:13:46 |

Le passage de synthèse roguelike traite aussi Darkest Dungeon, alors que la liste demandée contient Iratus. Cet écart est conservé : une synthèse annoncée « 5/5 » ne démontre pas une couverture homogène des cinq titres demandés.

### Combat, compétences, ressources et modificateurs

Les mécanismes de cette table sont **ce que les réponses historiques rapportaient**. Les noms de classes/pipelines proposés pour LITD ne sont pas présentés comme des classes réellement trouvées dans le code propriétaire de ces jeux.

| Jeu | Résultats techniques récupérés | Adaptation LITD déjà proposée | Source citée récupérée / limite |
|---|---|---|---|
| Darkest Dungeon | `.info.darkest`, `.effects.darkest`, `launch`, `target`, `.move`, effets/résistances, `death_class`, `monster_brain`, `raid/ai`, initiative et trinkets | Formation → compétence → ciblage → résolution → effets → mort/compactage → événements ; même moteur pour joueur, preview et IA | [Pitch Black Dungeon](https://www.nexusmods.com/darkestdungeon/mods/57), [mod Nexus 2096](https://www.nexusmods.com/darkestdungeon/mods/2096), [DarkestDungeonParser](https://github.com/eraether/DarkestDungeonParser), [darkest-parser](https://github.com/syrinka/darkest-parser), [Blindest Dungeon](https://github.com/Vicorin/Blindest-Dungeon). Données/outils communautaires, pas source propriétaire complète |
| Battle Brothers | Modern Hooks/MSU/Modding Script Hooks/Legends ; composition des hooks ; skills/perks/effects, blessures, équipement, UI et décisions IA | `Definitions → ModifierPipeline → ActionRequest → Resolvers → Hooks/Events` ; phases BEFORE/AFTER explicites ; blessures persistantes | [MSU](https://github.com/MSUTeam/MSU), [Modular Vanilla](https://github.com/Battle-Modders/mod_modular_vanilla), [Hardened](https://github.com/Darxo/Hardened). Commits et fonctions réellement lus non récupérés |
| Battle Chasers: Nightwar | Enhanced Combat Logs / VERBOSE, BepInEx, dnSpy mentionné ; ability → cible/script → hit/dodge → dégâts/critique → shield → DOT/HOT → delay ; initiative et Overcharge | Distinguer `AbilityDefinition` et opérations, timeline/récupération, ressources et preview | [Enhanced Combat Logs, Nexus 3](https://www.nexusmods.com/battlechasersnightwar/mods/3). Le pipeline était une hypothèse issue de traces/observations, explicitement non confirmé par code officiel |
| Slay the Spire | BaseMod, événements/cartes/statuts/reliques ; Smart Enemy AI et AscensionAI cités ; comportement/intention distincts de l'affichage | Actions légales d'abord, scoring pondéré ensuite ; effets déclenchés par événements ; intentions lisibles | [BaseMod](https://github.com/daviscook477/BaseMod), [ModTheSpire issue 164](https://github.com/kiooeht/ModTheSpire/issues/164), [AscensionAI](https://github.com/JustinoChan/AscensionAI). URL de Smart Enemy AI et commits non récupérés |
| Octopath Traveler II | New Dawn, stopRNG, Arena Battle Mode, UassetGUI/FModel ; Shield Points/Break, faiblesses, multi-hit séquentiel et Boost | `ActionGroup`, `AffinityResolver`, ordre explicite des impacts et consommation des ressources | Noms retrouvés, URLs complètes et fichiers/version non récupérés ; le « 100 % » historique n'est pas une preuve de code complet |
| Chained Echoes | BepInEx cité ; Overdrive global, TP, formes de combat/Sky Armor et portée des modificateurs | `BattleState`, `ModifierScope`, `CombatForm` ; provenance explicite d'un modificateur | Aucun mod précis/URL/commit récupéré ; conclusions issues d'observations, pas preuve du moteur interne |
| For The King | Randomizer, FTKEasier, FTK Easy Targetting et FTKAPI ; seed, coûts/prix/stocks, stats d'objets, jets d'armes, loot, précision/casse, ciblage IA et classes custom rapportés | `RunState`, `CheckResolver`, `EncounterResolver`, `RunModifier` | [Randomizer](https://www.nexusmods.com/fortheking/mods/10), [FTKEasier](https://www.nexusmods.com/fortheking/mods/11), [FTKAPI Thunderstore](https://thunderstore.io/c/for-the-king/p/Amadare/FTKAPI/). Ne pas lui attribuer les positions R1–R4 d'Iratus : un extrait récupéré mêlait ces sujets |
| Iratus | Player Balance ; `StreamingAssets/DB/Mods/playerBalance/monsters/*_balance.json`, `StreamingAssets/DB/buffs.json` ; positions de lancement/cible, AOE, coûts, dégâts, stun ; variantes de chemins citées | `SkillDefinition`, `UpgradeDefinition`, `Effect + Trigger + Conditions + Actions` ; ciblage distinct du compactage | [Player Balance](https://www.nexusmods.com/iratuslordofthedead/mods/6). Nightsister cité sans URL exacte ; version et lecture réelle des JSON restent à confirmer |
| Darkest Dungeon II | Tokens/Combo/DOT, stress/relations, Death's Door, Mastery ; BepInEx/Harmony, namespaces `Assets.Code.*` ; `ScriptableObject`, CSV et Modify/Inherit/New | Effets séparés des ressources/seuils et des améliorations de compétences ; overrides de données explicites | [Plugin-DD2](https://github.com/Binarizer/Plugin-DD2). La source exacte du modèle Modify/Inherit/New et les fichiers/version restent à vérifier |
| Ruined King | Actions Instant/Lane/Ultimate ; Speed/Balance/Power, délai/puissance ; Hazards/Boon sur la timeline ; triggers de passifs et ressource Overcharge/Mana rapportés | La lane fournit des modificateurs à la compétence ; zones de timeline avec conditions/actions ; ne pas surcharger le DamageResolver | Réponse 13:22:07–13:22:31 : observation de gameplay, écosystème de mods jugé peu documenté ; URLs récupérées tronquées (League of Legends, jeuxvideo.fr, Gamepur, InvenGlobal), non reconstruites |

### Donjons, salles et peuplement

| Jeu | Résultats récupérés | Adaptation LITD déjà proposée | Source récupérée / limite |
|---|---|---|---|
| Darkest Dungeon | Paramètres `base_room_number`, `base_corridor_number`, `gridsize`, `spacing`, `connectivity`, `min_final_distance` ; pools ; ddrand, seeds et salles/couloirs | Profil et contenu séparés du générateur ; graine reproductible | [ddrand](https://github.com/melocene/ddrand), [Darkest-Dungeon-Unity](https://github.com/Reinisch/Darkest-Dungeon-Unity). Le second était présenté comme réimplémentation communautaire GPL-3.0, pas code original ; licence à vérifier avant réutilisation |
| Enter the Gungeon | `DungeonFlows`, `DungeonAPI`, `CustomRoomData`, `debugflow`, chargement de flows et étages secrets ; Alexandria/Custom Rooms cités | Séparer Flow, Room et Encounter ; métadonnées sémantiques sur salles artisanales | [ExpandTheGungeon](https://github.com/ApacheThunder/ExpandTheGungeon). Commits/fichiers non récupérés ; pas le générateur propriétaire complet |
| Dead Cells | Monde macro manuel ; biome reconstruit à partir de chunks, entrées/sorties et concept graph ; longueur, spéciales, complexité/distances ; `.pak`, `CDBTool`, `PAKTool` cités | Graphe d'intention puis résolution en composants artisanaux compatibles | [alivecells](https://github.com/N3rdL0rd/alivecells), [DeadCellsToolsDecompilation](https://github.com/LukeWarnut/DeadCellsToolsDecompilation), [core](https://github.com/dead-cells-core-modding/core). Liens Deepnight/ModDB tronqués ; outils communautaires, pas moteur Motion Twin confirmé |
| The Binding of Isaac: Rebirth | Basement Renovator, StageAPI, IsaacScript ; type/forme/portes (`RoomConfigRoom.Doors`), poids/difficulté ; pools RoomType/subtype, compatibilité et fallback | Résoudre une salle selon topologie/portes avant population ; repli explicite | [Xalum/Basement-Renovator](https://github.com/Xalum/Basement-Renovator), [Basement-Renovator/basement-renovator](https://github.com/Basement-Renovator/basement-renovator), [IsaacScript](https://isaacscript.github.io). Version Rebirth/Repentance des API à distinguer ; liens StageAPI/wofsauge incomplets |
| Spelunky 2 | Chunks/salles, grille typique 4×4 ; chemin principal traversable et branches de risque ; Modlunky 2, Overlunky Lua ; objets et ennemis séparés dans CustomLevels | Construire le chemin critique avant branches/secrets, puis résoudre salles/population/loot et valider | [CustomLevels](https://github.com/jaythebusinessgoose/CustomLevels), [wiki cité](https://spelunky.fandom.com/wiki/Level_Generation/2). Détails de traversabilité rapportés historiquement, non revalidés dans cette récupération ; wiki secondaire |
| Stoneshard | ModShardLauncher ; `InjectTableSkillsStat`, `InjectTableEnemyBalance`, `InjectTableWeapons`, `InjectTableArmor` ; `Load → Match → Replace/Insert → Save` ; `Room/Layers/GameObjects`, `AddRoomJson` | Définitions de compétences et règles corporelles séparées ; salles paramétrées à contenu explicite | [ModShardLauncher](https://github.com/ModShardTeam/ModShardLauncher). Documentation modshardteam.github.io citée avec chemin incomplet ; aucune trace d'exécution récupérée |
| Legend of Grimrock II | Lua `defineObject`/`baseObject`, entités/composants ; `onAttack`, `onAttackHit`, `onDealDamage`, `onProjectileHit` | Composition des comportements ; hooks typés plutôt que duplication de résolveurs | [Modding officiel](https://www.grimrock.net/modding/), [Scripting reference](https://www.grimrock.net/modding/scripting-reference/). Fiche/code/version examinés non récupérés |
| Dungeon of the ENDLESS | `Dungeon.SpawnMobs`, `roomDifficultyValue`, `spawnType`, `eligibleMobs`, `OpeningIndex`, `SpawnProbWeight`, `CurrentFloor`, `CurrentMobs` ; Partiality/MonoMod/BepInEx | Contexte → candidats éligibles → pondération → sélection → spawn ; ne pas confondre sélection de définition et matérialisation | [DungeonOfTheEndless-Mod](https://github.com/sc2ad/DungeonOfTheEndless-Mod). Fonction/contexte rapportés dans l'ancien message ; commit et extrait original du code non récupérés |
| Into the Breach | ITB-ModLoader, IntelligentAI ; scoring IA et télégraphie | Énumérer les actions légales avant notation ; rendre l'intention lisible | [ITB-ModLoader](https://github.com/itb-community/ITB-ModLoader), [IntelligentAI](https://github.com/Compartany/IntelligentAI). Équilibrage et fonctions exactes non récupérés |
| FTL: Faster Than Light | Hyperspace XML/Lua et hooks événementiels | Séparer définition, événement et conséquence ; budgets de rencontres et variations bornées | [FTL-Hyperspace](https://github.com/FTL-Hyperspace/FTL-Hyperspace). Fichiers, commit et tests non récupérés |
| Shattered Pixel Dungeon | Déjà documenté dans les deux notes Git existantes : faim/PV, timing des ressources, identification et attrition | Coût d'opportunité et connaissance utile à la décision d'extraction | Pas de nouvelle étude technique récupérée dans les quatre corpus du 2 octobre ; conserver les notes existantes sans fabriquer un complément |

### Synthèses et invariants LITD récupérés

Le 2 octobre à 15:01:48 UTC, la synthèse procédurale proposait `Seed → DungeonProfile → FlowGenerator → CriticalPathValidator → RoomResolver → Encounter/Reward-Event Directors → validation finale`. Son intention : procédural contraint, composants artisanaux, données séparées, seed déterministe et rapport de génération. C'est une proposition d'architecture historique ; les classes et contrats actuels restent ceux du dépôt, notamment [la tranche intégrée](../design/DUNGEON_GENERATION_PIPELINE_V1.md).

La synthèse difficulté (15:11:03–15:12:17 UTC) proposait sous-seeds indépendantes, budget de menace, composition de rencontres, `PartyThreatEvaluator/PartyThreatScore` avec bornes, scoring pondéré des actions légales selon dégâts/cible/position/affliction/synergie, et télégraphie. Ces propositions ne justifient pas de rajouter automatiquement une difficulté adaptative au runtime actuel : les règles récentes du directeur de rencontres restent la référence.

Le ciblage anatomique était explicitement rappelé par l'utilisateur. Les propositions récupérées séparent **compétence → rang → ennemi → partie du corps → effets/résolution** : `allowed_body_parts`, BodyPart avec santé/armure/seuils/conséquences, et afflictions indépendantes. Le contrat `rang + ennemi + zone`, les API `body_zones_for_action`, `requires_body_zone`, `can_target_body_zone`, `validate_target_contract`, et le partage des verdicts entre UI, joueur et IA sont rapportés dans les messages de 15:38:29–15:50:55 UTC. Les noms/API ne sont pas renommés ou implémentés à nouveau par cette récupération.

L'historique mentionne ensuite les PR [#511](https://github.com/Henolos/litd/pull/511) (mort/compactage), [#512](https://github.com/Henolos/litd/pull/512) (ciblage unique), [#517](https://github.com/Henolos/litd/pull/517) (zone anatomique/runtime/UI) et [#522](https://github.com/Henolos/litd/pull/522) (génération). Ce sont des pointeurs récupérés, pas une nouvelle certification de leur état courant. Leurs statuts historiques « fusionnée », « draft » ou « tests en cours » ne sont pas promus sans lecture actuelle.

### État après récupération

Les quatre listes sont retrouvées et les résultats utiles disponibles sont désormais rangés dans le même rapport, avec leurs dates, sources et limites. Les URLs complètes sont conservées sans paramètres de suivi ; les URLs tronquées ne sont pas inventées. Les anciens pourcentages d'étude ne sont pas repris comme preuve.

La récupération documentaire réduit le besoin de refaire les études : repartir des formats, fonctions, sources et hypothèses ci-dessus. Restent à obtenir pour une certification technique : extraits complets de code effectivement lus, versions/commits, attribution exacte de certains outils, contre-preuves et traces reproductibles. Cette passe n'effectue aucune nouvelle lecture de code tiers, aucune exécution de mod ni aucun changement de gameplay.

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


## Revalidation ciblée du 4 octobre 2026

Cette passe ne refait pas les vingt études. Elle revalide en priorité les mécanismes ayant un impact direct sur l'architecture LITD.

### Battle Brothers — hooks, dépendances et ordre de chargement

Sources primaires/mainteneurs relues :
- https://github.com/MSUTeam/MSU
- https://bbmodding.enduriel.com/docs/modern-hooks/introduction/
- https://bbmodding.enduriel.com/docs/modern-hooks/basic-hooks/
- https://bbmodding.enduriel.com/docs/modern-hooks/queuing/

Constats revalidés :
- Modern Hooks permet de cibler une classe précise et d'ajouter/envelopper fonctions et champs sans remplacer le fichier complet.
- L'enregistrement des mods, les dépendances, incompatibilités et contraintes d'ordre de chargement sont explicites.
- La documentation décrit la file d'exécution comme un mécanisme de compatibilité entre modifications concurrentes.

Conséquence LITD : conserver des points d'extension typés et un ordre de résolution explicite autour des résolveurs existants, plutôt que dupliquer ou remplacer des systèmes complets. Cela renforce l'orientation `Definitions -> Request -> Resolver -> Events/Hooks` déjà proposée, sans justifier une nouvelle couche parallèle.

Niveau de preuve : documentation mainteneur + dépôt public du framework ; ne prouve pas le comportement du moteur propriétaire complet de Battle Brothers.

### Slay the Spire — abonnement aux événements

Sources relues :
- https://github.com/daviscook477/BaseMod
- https://github.com/daviscook477/BaseMod/blob/master/mod/src/main/java/basemod/BaseMod.java
- https://github.com/daviscook477/BaseMod/blob/master/TESTING.md

Constats revalidés :
- BaseMod expose explicitement de nombreux abonnés/subscribers et hooks de cycle de vie.
- Le dépôt sépare l'enregistrement des abonnés des systèmes qui consomment ces événements.
- TestMod est utilisé comme couverture de compatibilité fonctionnelle lors des évolutions du framework.

Conséquence LITD : les afflictions, réactions, preview UI et intentions IA doivent privilégier des événements/contracts partagés autour d'un noyau de résolution unique. Le pattern est pertinent comme architecture d'extension ; il ne démontre pas à lui seul l'algorithme interne d'IA du jeu.

Niveau de preuve : code et documentation publics de BaseMod ; aucune déduction du code propriétaire Slay the Spire.

### Stoneshard — correction de confiance

Source relue :
- https://github.com/ModShardTeam/ModShardLauncher/releases

Constats revalidés :
- ModShardLauncher documente bien la création de salles via `AddRoomJson` et le support Room/Layers/GameObjects dans ses versions publiées.
- Une release récente avertit toutefois que les API liées aux tables n'ont pas toutes été vérifiées/corrigées pour la branche actuelle et que les mods qui en dépendent peuvent ne pas fonctionner.

Conséquence LITD : conserver l'idée générale de données séparées et de composition de salles, mais ne pas citer les injections de tables Stoneshard comme preuve stable d'une API actuelle sans figer une version compatible et la tester.

Niveau de preuve : changelog/release mainteneur ; confiance abaissée pour les assertions historiques sur les injections de tables non versionnées.

### Priorité de revalidation suivante

1. Darkest Dungeon : figer versions des fichiers de données/mods utilisés et vérifier rangs/ciblage/IA.
2. Battle Chasers: Nightwar : distinguer logs observables et structures réellement prouvées.
3. Iratus : vérifier les JSON de positions/cibles/afflictions et leur version.
4. Enter the Gungeon / Binding of Isaac : revalider flow, compatibilité des salles et fallback pour la génération.
5. Into the Breach : revalider scoring des actions légales et télégraphie sans extrapoler l'IA propriétaire.


## Revalidation prioritaire complémentaire — 4 octobre 2026

### Darkest Dungeon — rangs, ciblage, effets, IA et rencontres

Source primaire :
- https://steamcommunity.com/sharedfiles/filedetails/?id=819597757

Constats revalidés depuis le guide officiel de modding Red Hook :
- les compétences exposent explicitement `.launch` (rangs d'utilisation), `.target` (rangs ciblables), `.move`, dégâts, critique et liste d'effets ;
- les effets possèdent leur propre ciblage, chances, conditions hit/miss et ordre de queue ;
- les ennemis référencent un `monster_brain`, une initiative et éventuellement une `death_class` ;
- l'IA documente séparément les désirs de sélection de compétence et de cible, avec critères de santé, statut, allié vivant/mort, rang ou cible marquée ;
- les rencontres utilisent des groupes et pondérations, tandis que la génération de donjon est documentée séparément.

Conséquence LITD :
- confirmer la séparation existante rangs -> cible -> résolution -> effets -> mort/compactage ;
- ne pas fusionner sélection de compétence, sélection de cible et résolution des dégâts ;
- conserver la prévisualisation UI à partir des mêmes règles canoniques que le runtime ;
- garder l'IA comme consommateur du même contrat de légalité que le joueur, avec scoring séparé.

Niveau de preuve : documentation officielle de modding Red Hook ; forte pour les formats exposés, insuffisante pour affirmer l'implémentation interne exacte du moteur.

### Battle Chasers: Nightwar — logs observables, pas moteur reconstitué

Source :
- https://www.nexusmods.com/battlechasersnightwar/mods/3

Constats revalidés :
- le mod VERBOSE v0.53 expose les scripts d'abilities parsés/exécutés par le jeu, les jets de dés, le détail des dégâts, DOT/HOT, critique, esquive, time multiplier, recovery delay et shield HP ;
- il remplace `Assembly-CSharp.dll`, ce qui montre une instrumentation du code managé du jeu mais ne constitue pas un dépôt source officiel ;
- la meilleure preuve récupérable est donc le comportement instrumenté et les paramètres observables, pas une reconstruction certifiée du pipeline interne.

Conséquence LITD :
- conserver `AbilityDefinition` séparée des opérations/résolveurs ;
- garder timeline/recovery, shield, DOT/HOT et preview comme données/résultats observables ;
- ne pas présenter l'ancien pipeline ability -> cible -> hit -> dégâts -> shield -> DOT/HOT -> delay comme code propriétaire confirmé.

Niveau de preuve : instrumentation de mod communautaire ; moyen pour les phénomènes observables, faible pour l'architecture interne exacte.

### Iratus — positions, coûts, dégâts et buffs data-driven

Source :
- https://www.nexusmods.com/iratuslordofthedead/mods/6

Constats revalidés :
- la page Player Balance documente explicitement des changements de positions de lancement/ciblage, AOE, coûts d'Ire et coefficients de dégâts ;
- elle fournit le chemin `StreamingAssets/DB/Mods/playerBalance/monsters/*_balance.json` pour modifier les capacités/statistiques ;
- elle référence `StreamingAssets/DB/buffs.json` pour les données de buffs ;
- l'historique de version mentionne également des corrections ayant affecté l'IA, ce qui rappelle qu'une modification de données peut casser des comportements indirects.

Conséquence LITD :
- renforcer la séparation `SkillDefinition`, `Effect`, conditions, coûts et targeting ;
- maintenir les afflictions/buffs dans des données distinctes quand possible ;
- tester les interactions IA après toute évolution des définitions de compétences, même si la modification semble seulement data-driven.

Niveau de preuve : page et fichiers décrits par l'auteur du mod ; fort pour les chemins/formats exposés, non suffisant pour l'algorithme propriétaire complet.

### Enter the Gungeon — flow de donjon explicitement chargeable

Source :
- https://github.com/ApacheThunder/ExpandTheGungeon

Constats revalidés :
- ExpandTheGungeon expose explicitement le chargement de `DungeonFlow` via la commande `load_flow` ;
- le projet ajoute des étages secrets complets et manipule des flows distincts du contenu visuel et des ennemis.

Conséquence LITD :
- confirmer la séparation FlowGenerator / RoomResolver / Directors ;
- garder la topologie et le choix de salles comme responsabilités distinctes ;
- les secrets/branches doivent être des extensions du flow validé, pas des salles arbitrairement greffées après coup.

Niveau de preuve : dépôt communautaire public ; fort pour son architecture de mod, insuffisant pour déduire l'algorithme interne original du jeu.

### The Binding of Isaac — salles artisanales + compatibilité explicite

Sources :
- https://github.com/Basement-Renovator/basement-renovator
- https://github.com/Meowlala/BOIStageAPI15

Constats revalidés :
- Basement Renovator est un éditeur open source de salles et niveaux utilisé pour créer des rooms compatibles avec plusieurs générations d'Isaac ;
- la documentation avertit que les IDs/compatibilités varient selon Rebirth/Afterbirth+/Repentance ;
- StageAPI convertit et intègre des salles custom dans des stages, avec hooks de sauvegarde/test.

Conséquence LITD :
- résoudre d'abord la compatibilité topologique/métadonnées d'une salle, puis la population ;
- versionner les formats de RoomDefinition si leur contrat évolue ;
- prévoir un fallback ou un rejet explicite lorsqu'aucune salle compatible n'est disponible.

Niveau de preuve : outils communautaires publics ; fort pour le pipeline d'édition/intégration, pas pour le générateur propriétaire complet.

### Into the Breach — scoring pondéré et télégraphie à traiter séparément

Sources :
- https://github.com/itb-community/ITB-ModLoader
- https://github.com/Compartany/IntelligentAI

Constats revalidés :
- le mod loader expose un environnement Lua extensible ;
- IntelligentAI documente explicitement l'augmentation/diminution de probabilités selon cibles, terrain, dégâts, positions et risques ;
- le mod traite donc bien un modèle de scoring pondéré de décisions, mais ce scoring appartient au mod et ne doit pas être présenté comme l'algorithme vanilla officiel.

Conséquence LITD :
- conserver l'idée `legal actions -> scoring pondéré -> choix` pour l'IA ;
- intégrer position, dégâts, afflictions, synergies et risques dans le score, sans modifier les règles de légalité ;
- la télégraphie UI doit représenter le résultat/intention de l'IA, pas exposer ses pondérations internes.

Niveau de preuve : code/documentation communautaires ; fort pour IntelligentAI, faible pour l'IA propriétaire originale d'Into the Breach.

### Synthèse après cette passe

Les six revalidations convergent vers les mêmes frontières architecturales déjà utiles à LITD :
1. définitions de données ;
2. validation des actions/cibles ;
3. résolution déterministe ;
4. effets/afflictions déclenchés autour du résolveur ;
5. IA qui consomme les actions légales puis les score ;
6. génération topologique séparée des salles et de leur population ;
7. UI/preview calculées depuis les mêmes contrats que le runtime.

Aucun de ces constats ne justifie de créer un second moteur de combat, un second générateur de donjon ou une IA parallèle.


## Synthèse finale LITD — conserver / améliorer / rejeter

### À conserver

1. **Un seul pipeline de combat canonique**
   - définition de compétence ;
   - validation rang/cible/zone anatomique ;
   - résolution ;
   - dégâts/soins/boucliers ;
   - afflictions/effets ;
   - mort et compactage ;
   - événements/feedback.
   - Raison : Darkest Dungeon, Iratus et Battle Chasers convergent vers une séparation nette des responsabilités. LITD possède déjà cette direction ; il ne faut pas créer un moteur parallèle.

2. **Même contrat de légalité pour joueur, IA et UI**
   - le joueur, l'IA et la prévisualisation doivent interroger les mêmes règles de ciblage ;
   - l'IA score uniquement les actions déjà légales.
   - Raison : réduit les divergences entre preview, exécution et comportement ennemi.

3. **Ciblage anatomique comme couche explicite**
   - conserver le contrat rang -> ennemi -> partie du corps -> résolution ;
   - ne pas fusionner les zones anatomiques avec les afflictions ;
   - chaque zone peut exposer santé, armure, seuils et conséquences.
   - Raison : c'est une différenciation forte de LITD et les références étudiées renforcent la nécessité de séparer ciblage, dégâts et effets.

4. **Afflictions data-driven**
   - définitions, résistances, durée, déclencheurs et règles de rafraîchissement doivent être données/contrats quand possible ;
   - le moteur applique les règles, il ne porte pas de logique spéciale dispersée par affliction.
   - Raison : Iratus, Darkest Dungeon et les frameworks modding montrent la valeur de règles séparées des effets.

5. **IA : actions légales -> score -> choix**
   - générer d'abord les actions/cibles valides ;
   - scorer ensuite selon dégâts, position, affliction, synergie, risque et priorité ;
   - garder la télégraphie séparée du calcul.
   - Raison : modèle robuste et testable, confirmé par les patterns étudiés autour d'Into the Breach et Slay the Spire.

6. **Donjons : topologie avant contenu**
   - seed déterministe ;
   - profil ;
   - flow/graphe ;
   - validation du chemin critique ;
   - résolution des salles compatibles ;
   - encounter/event directors ;
   - validation finale.
   - Raison : convergence Darkest Dungeon / Gungeon / Isaac / Spelunky / Dead Cells.

7. **Salles artisanales réutilisées par un générateur contraint**
   - préférer des composants conçus et testés à des salles entièrement générées ;
   - faire dépendre le choix d'une salle de métadonnées/topologie explicites.
   - Raison : meilleure qualité, lisibilité et contrôle de la difficulté.

### À améliorer

1. **Centraliser encore davantage la validation de cible**
   - toute règle de portée, rang, cible, zone anatomique et état doit avoir une seule source de vérité ;
   - supprimer progressivement les duplications UI/runtime si elles existent encore.

2. **Formaliser un `ActionRequest` / résultat canonique**
   - une action devrait transporter acteur, compétence, cible, zone anatomique, coûts et contexte ;
   - son résultat doit être sérialisable/testable pour faciliter preview, IA et replay de tests.
   - À adapter à l'architecture actuelle sans renommer inutilement les classes déjà stables.

3. **Scoring IA explicable**
   - conserver les facteurs de score séparés et observables en debug ;
   - ajouter des bornes et garde-fous contre les stratégies absurdes ;
   - tests dédiés aux rangs, parties du corps et afflictions.

4. **Afflictions : règles de renouvellement et immunité**
   - expliciter stacking, refresh, immunité temporaire, résistance, durée minimale/maximale ;
   - priorité particulière à l'étourdissement pour empêcher le stun-lock ;
   - garder les interactions entre états dans une table de règles, pas dans des exceptions dispersées.

5. **RoomResolver avec compatibilité explicite**
   - chaque salle doit annoncer portes/connexions, tags, biome, difficulté, contenu autorisé et contraintes ;
   - si aucune salle compatible n'existe : fallback contrôlé ou échec explicite, jamais correction silencieuse arbitraire.

6. **Seeds séparées par sous-système**
   - dériver des sous-seeds pour flow, salles, rencontres, loot et événements ;
   - conserver la reproductibilité tout en évitant qu'un changement de loot bouleverse toute la topologie.

7. **Preuves et observabilité**
   - conserver les décisions critiques sous forme de rapports de génération/combat en mode debug ;
   - utiliser ces traces pour les tests déterministes et les régressions.

### À rejeter

1. **Deuxième moteur de combat**
   - rejeté : créer une architecture inspirée d'un jeu étudié à côté du système LITD existant.
   - Motif : duplication, divergence et coût de maintenance.

2. **Deuxième générateur procédural**
   - rejeté : ajouter un système parallèle au pipeline actuel.
   - Motif : le pipeline validé couvre déjà les responsabilités nécessaires.

3. **Copie directe des règles d'un jeu**
   - rejeté : reproduire exactement stress, break, overdrive, tokens, death door, etc.
   - Motif : les études servent à extraire des patterns, pas à cloner les mécaniques.

4. **IA adaptative opaque qui triche**
   - rejeté : modifier dynamiquement les règles de légalité, dégâts ou RNG pour compenser le niveau du joueur.
   - Motif : difficulté difficile mais lisible > correction cachée.

5. **Génération 100 % libre sans validation**
   - rejeté : tirer salles, rencontres et loot indépendamment sans chemin critique ni contraintes.
   - Motif : impossible à équilibrer correctement et difficile à reproduire/tester.

6. **Afflictions codées en exceptions locales**
   - rejeté : logique `if poison`, `if stun`, etc. dispersée dans compétences, IA et UI.
   - Motif : explosion de complexité et incohérences.

7. **Dépendre d'API/mods tiers non versionnés comme preuve**
   - rejeté : considérer une fonction de mod comme invariant du jeu sans version/commit.
   - Motif : plusieurs études, notamment Stoneshard, montrent que ces interfaces peuvent devenir incompatibles.

### Décision finale

Les études comparatives ne justifient **aucun changement d'architecture majeur** pour LITD. Elles valident principalement la direction déjà engagée : noyau déterministe, contrats de ciblage partagés, données séparées des résolveurs, IA fondée sur les actions légales et génération procédurale contrainte.

La priorité d'implémentation doit donc être l'amélioration incrémentale du système existant, avec tests déterministes et suppression des duplications, et non la création de nouvelles couches parallèles.


## Preuves de lecture de code figées — 4 octobre 2026

Statut : **lecture statique vérifiable, périmètre partiel**. Six fichiers de sources communautaires ont été récupérés intégralement ; les fonctions et plages ci-dessous ont été inspectées. Aucun jeu ou mod tiers exécuté, aucun code tiers copié dans le runtime LITD. Ces preuves remplacent des pistes historiques pour ces mécanismes seulement, sans certifier les vingt études complètes.

### Slay the Spire / BaseMod

- Commit : `26de1afc1a8ea7595b61f940de0ac29650f2c025` ; blob : `a3311e7427f2c243447cf4717a3026355d621aa5`.
- Fichier : [mod/src/main/java/basemod/BaseMod.java](https://github.com/daviscook477/BaseMod/blob/26de1afc1a8ea7595b61f940de0ac29650f2c025/mod/src/main/java/basemod/BaseMod.java) ; lignes inspectées : 2619–2660, 2891–2942, 3209–3211.
- Symboles lus : `subscribe`, `publishStartBattle`, `publishPostBattle`, `publishOnCardUse`, `unsubscribeLater`.

L'inscription classe les abonnés selon leurs interfaces. Chaque publication parcourt sa liste et appelle la méthode de réception ; les retraits différés sont traités après publication. Cela prouve le routage événementiel du framework, pas le calcul propriétaire des dégâts.

Pour LITD : effets et feedback peuvent consommer les événements du résolveur existant. Cette preuve ne garantit ni un ordre de priorité configurable ni la pureté des callbacks.

### Enter the Gungeon / ExpandTheGungeon

- Commit : `a7ff72a68cc66c6df64cf2d2a272bd93ce1c986e` ; blob : `93eb357bc861062c9be0fd38d609ce228ba78fd0`.
- Fichier : [ExpandTheGungeon/ExpandDungeonFlows/DungeonFlows/test_customroom_flow.cs](https://github.com/ApacheThunder/ExpandTheGungeon/blob/a7ff72a68cc66c6df64cf2d2a272bd93ce1c986e/ExpandTheGungeon/ExpandDungeonFlows/DungeonFlows/test_customroom_flow.cs) ; lignes inspectées : 19–85.
- Symboles lus : `m_Test_CustomRoom_Flow`, `GenerateDefaultNode`, `Initialize`, `AddNodeToFlow`, `FirstNode`.

Le constructeur crée des nœuds de catégories différentes, choisit des salles exactes ou des tables, puis relie les nœuds avec des parents. Il désigne une entrée et construit notamment une branche boutique → foyer → boss → sortie.

Pour LITD : distinguer graphe et sélection de salles. Ce flow de test fixe n'établit pas un générateur aléatoire déterministe ni une validation automatique du chemin critique ; sa table de fallback est null.

### The Binding of Isaac / StageAPI

- Commit : `de45764d2d04e18d260b4539f7821c51c703d30c` ; blob : `acf70a109e2bf202c0fe70368bab1b707cac09dd`.
- Fichier : [scripts/stageapi/room/roomsList.lua](https://github.com/Meowlala/BOIStageAPI15/blob/de45764d2d04e18d260b4539f7821c51c703d30c/scripts/stageapi/room/roomsList.lua) ; lignes inspectées : 16–74.
- Symboles lus : `RoomsList:Init`, `RoomsList:AddRooms`, `RoomsList:GetRooms`.

Le catalogue normalise les layouts, conserve une liste globale et les indexe par Shape. GetRooms(-1) retourne toutes les salles ; une autre forme retourne l'index correspondant, qui peut être absent.

Pour LITD : filtrer les salles compatibles avant tirage. Ce fichier ne vérifie pas les portes ni la traversabilité et ne fournit pas un fallback garanti. StageAPI courant ne certifie pas les API de Rebirth.

### Into the Breach / IntelligentAI

- Commit : `e4722508edefe69aa9a7c6e1bf3e682cb9bf0655` ; blob : `959ba2567e44a91847bbccddc2c01f5fc06659c4`.
- Fichier : [scripts/ai.lua](https://github.com/Compartany/IntelligentAI/blob/e4722508edefe69aa9a7c6e1bf3e682cb9bf0655/scripts/ai.lua) ; lignes inspectées : 92–224, 371–376.
- Symboles lus : `Skill_ScoreList`, `Skill_ScoreList_Target`, `Skill:ScoreList`.

Le score distingue dégâts, déplacement, équipe, bouclier, acidité, armure et bâtiments. La protection d'une capsule peut retourner -100 ; une mauvaise position peut remplacer le score d'attaque. L'enveloppe ScoreList revient à l'ancienne fonction pour les unités non concernées.

Pour LITD : séparer facteurs et garde-fous du score. Board:IsValid vérifie une case, pas l'ensemble du contrat de légalité d'une action : la règle actions légales → score demeure une décision LITD, non une propriété certifiée ici du moteur vanilla.

### Spelunky 2 / CustomLevels

- Commit : `0d5cc502d7cb549d60400ad0dd91971920c7ba0e` ; blob : `d73fb75ba2b8bd3e52d31472f799c216365634ae`.
- Fichier : [custom_levels.lua](https://github.com/jaythebusinessgoose/CustomLevels/blob/0d5cc502d7cb549d60400ad0dd91971920c7ba0e/custom_levels.lua) ; lignes inspectées : 134–300.
- Symboles lus : `unload_level`, `load_level`, `override_level_files`, `ON.POST_ROOM_GENERATION`, `set_post_entity_spawn`.

Le chargement remplace les fichiers de niveau, fixe des templates après génération des salles et installe des filtres de population selon les flags. Les spawns de scripts sont explicitement épargnés par plusieurs filtres. unload_level efface les callbacks mémorisés.

Pour LITD : distinguer composition et population. Ce fichier n'établit pas l'algorithme du chemin principal vanilla. Le champ procedural_spawn_callback est affecté deux fois dans load_level : on ne peut pas affirmer que le nettoyage de tous les callbacks est garanti.

### FTL / Hyperspace

- Commit : `db570d728321a5a2c70add0988153373fd4ec08a` ; blob : `f1a59f4e7a8dae4241c5568df34da11896947fc9`.
- Fichier : [lua/InternalEvents.cpp](https://github.com/FTL-Hyperspace/FTL-Hyperspace/blob/db570d728321a5a2c70add0988153373fd4ec08a/lua/InternalEvents.cpp) ; lignes inspectées : 10–70.
- Symboles lus : `HOOK_METHOD(CApp, OnLoop)`, `MainMenu::Open`, `SpaceManager::DangerousEnvironment`, `StarMap::GetLocationText`.

Les hooks de boucle et de menu appellent le comportement original puis publient des événements Lua. DangerousEnvironment transmet le résultat original et permet à un callback de le remplacer. GetLocationText utilise une priorité explicite et une substitution temporaire du contexte.

Pour LITD : formaliser phases et contrat des retours. Il s'agit d'une extension qui peut modifier le comportement ; ce fichier ne démontre pas le budget des rencontres ni l'indépendance des sous-seeds.

### Reproduction et portée

Pour chaque source : récupérer le dépôt cité, extraire le fichier au commit indiqué avec `git show <commit>:<chemin>`, vérifier son blob avec `git rev-parse <commit>:<chemin>`, puis inspecter les plages et symboles listés. Les liens figés permettent aussi une vérification sans installation du jeu. Le SHA identifie la version lue ; il ne constitue pas un test d'exécution.

Cette passe apporte six preuves de lecture ciblées sur les vingt titres inventoriés. Les autres titres, les portes de StageAPI, la génération vanilla de Spelunky, les budgets FTL et la légalité complète des actions restent à vérifier. Les constats sont des observations ; leurs conséquences LITD sont des propositions d'adaptation. Aucune promotion automatique dans le canon, aucune modification gameplay, aucune fusion.

### Validation de cette passe

`python tools/quality/validate_knowledge.py` : PASS, 12 règles, 9 écarts canoniques préexistants suivis. `PYTHONPATH=. python tools/qa/validate_project.py` : 59 PASS, 0 échec. `git diff --check` : PASS. Les checks distants doivent être relus sur le nouveau commit ; les anciens résultats ne le valident pas.


## Deuxième passe de preuves et correction des attributions — 4 octobre 2026

Sept autres titres ont maintenant une lecture de code ciblée. Les références ci-dessous sont figées aux commits et blobs inspectés. Les constats portent sur le code cité, et leurs implications LITD restent des hypothèses de conception.

### Battle Brothers — MSU et Modular Vanilla

- Commit : `22679bd0ccf8fb9d167f5f698ddeab904aced3dd` ; fichier : [msu/hooks/skills/skill.nut](https://github.com/MSUTeam/MSU/blob/22679bd0ccf8fb9d167f5f698ddeab904aced3dd/msu/hooks/skills/skill.nut) ; blob : `ada8a59a77fdef4917ce241b49d25e2768d073a8` ; lignes lues : 38–110.
- Observation : Le hook de compétence ajoute des champs, un pré-aperçu et des ajustements de coût ; certaines branches dépendent de la version vanilla. Le hook de Modular Vanilla multiplie la valeur de ciblage par des modificateurs de compétences de l'attaquant et de la cible.
- Portée : La formule est propre à ces mods. Elle démontre un point d'extension et des modificateurs composables, pas la stratégie de l'IA originale.

### For The King — FTKAPI

- Commit : `30a28e13ae17cae1f25b4ebaf984f488ce7c17b4` ; fichier : [Managers/ItemManager.cs](https://github.com/ftk-modding/FTKAPI/blob/30a28e13ae17cae1f25b4ebaf984f488ce7c17b4/Managers/ItemManager.cs) ; blob : `0e8a447b29aa01826efc08e58c4c0938cfe9e303` ; lignes lues : 29–122.
- Observation : GetItem lit les tables d'objets et d'armes ; AddItem insère un CustomItem dans des dictionnaires/tables ; ModifyItem remplace des entrées existantes. CustomItem expose rareté, emplacement, type et propriétés d'armes.
- Portée : Cette source couvre l'extension de l'équipement. Elle ne prouve ni l'algorithme de seed, ni le ciblage ou le loot que l'ancien inventaire attribuait au Randomizer.

### Darkest Dungeon II — Plugin-DD2

- Commit : `38e8877f5cc775cbf766e43e7b29696afdc3d8c5` ; fichier : [DD2_Plugin_Binarizer/Hooks/HookGenerals.cs](https://github.com/Binarizer/Plugin-DD2/blob/38e8877f5cc775cbf766e43e7b29696afdc3d8c5/DD2_Plugin_Binarizer/Hooks/HookGenerals.cs) ; blob : `37816abbba3574d836fd65ac4b77c4f2a2329701` ; lignes lues : 110–142.
- Observation : ModSupportPrefix intercepte GatherResources, enregistre des dossiers de ressources Excel et affiche leur ordre ; un postfix ajoute des ressources à l'initialisation de campagne.
- Portée : Cela prouve l'injection de données du plugin ; les règles de tokens, Combo et Death's Door restent des observations historiques sans code lu ici.

### Dead Cells — outil ScriptTool

- Commit : `c20bbf2afbc03be42e290271b3930fefcc505864` ; fichier : [ScriptTool/BuildMainRooms.cs](https://github.com/LukeWarnut/DeadCellsToolsDecompilation/blob/c20bbf2afbc03be42e290271b3930fefcc505864/ScriptTool/BuildMainRooms.cs) ; blob : `002ec257279e3f9e14f77a55386e103642a55cb3` ; lignes lues : 5–21.
- Observation : Le générateur de squelette émet un exemple de buildMainRooms avec entrée obligatoire, salle de combat chaînée et sortie. BuildSecondaryRooms est présenté comme optionnel.
- Portée : Il s'agit d'un modèle de script d'outil communautaire, pas d'une lecture du générateur de Motion Twin. Les paramètres de complexité, validité et seed restent non prouvés.

### Stoneshard — ModShardLauncher

- Commit : `368dfb0602945ea88ef675204d7e4ed10497de64` ; fichier : [ModUtils/RoomUtils.cs](https://github.com/ModShardTeam/ModShardLauncher/blob/368dfb0602945ea88ef675204d7e4ed10497de64/ModUtils/RoomUtils.cs) ; blob : `30729848ae5c2af86a6746957365b4717c60e357` ; lignes lues : 19–55.
- Observation : AddRoomJson lit dimensions, arrière-plans, vues, objets, tuiles et couches ; la salle est ajoutée seulement si son nom n'existe pas. DungeonsSpawn construit une ligne avec tier, faction et jusqu'à six ennemis, puis l'insère sous un hook identifié.
- Portée : Le code démontre des API de mod et leur structure, pas la stabilité sur la branche actuelle de Stoneshard ; une absence de hook lève une exception et aucune validation de chemin n'est visible.

### Dungeon of the Endless — DungeonModifications

- Commit : `6d308ed169a79175a5b33bce5d03ccaf7dc92434` ; fichier : [DotE_Patch_Mod/DungeonModifications-Mod/DungeonModificationsMod.cs](https://github.com/sc2ad/DungeonOfTheEndless-Mod/blob/6d308ed169a79175a5b33bce5d03ccaf7dc92434/DotE_Patch_Mod/DungeonModifications-Mod/DungeonModificationsMod.cs) ; blob : `0c02f6cdb88ea2b72337c70861a03b67a523b0eb` ; lignes lues : 20–88.
- Observation : Le mod intercepte GenerateDungeonCoroutine, ajuste DungeonRoomCountMax et DungeonRoomCountMin par réflexion si la génération runtime est active, puis appelle l'original.
- Portée : Correction de confiance : cette lecture ne retrouve pas Dungeon.SpawnMobs ni la pondération des ennemis annoncée dans l'inventaire historique. Une preuve séparée est nécessaire pour le directeur de rencontres.

### Shattered Pixel Dungeon — source du jeu

- Commit : `e9defd0444c96d2fce3de5ec297c3398be8b7c55` ; fichier : [core/src/main/java/com/shatteredpixel/shatteredpixeldungeon/actors/buffs/Hunger.java](https://github.com/00-Evan/shattered-pixel-dungeon/blob/e9defd0444c96d2fce3de5ec297c3398be8b7c55/core/src/main/java/com/shatteredpixel/shatteredpixeldungeon/actors/buffs/Hunger.java) ; blob : `f8ac0525cb317295970031b635461f200e5469d8` ; lignes lues : 38–126.
- Observation : Hunger définit des seuils faim/famine, avance avec les ticks sauf exceptions, et inflige progressivement des dégâts à la famine. ItemStatusHandler attribue des étiquettes aléatoires aux classes d'objets, conserve l'ensemble des catégories connues et sérialise ces états.
- Portée : Ces deux fichiers prouvent précisément l'attrition et l'identification de catégories d'objets dans la version figée ; ils ne prouvent pas à eux seuls l'équilibre global de la difficulté.

Pour Battle Brothers, [Modular Vanilla / behavior.nut](https://github.com/Battle-Modders/mod_modular_vanilla/blob/43b6ce9c4cd3544c61ac3b6c123bf589140f63db/mod_modular_vanilla/hooks/ai/tactical/behavior.nut) (blob `bc1ae47914448bca92f80dbfe4e519575164b3fa`, lignes 1–10) complète le premier fichier. Pour Stoneshard, [DungeonsSpawn.cs](https://github.com/ModShardTeam/ModShardLauncher/blob/368dfb0602945ea88ef675204d7e4ed10497de64/ModUtils/TableUtils/DungeonsSpawn.cs) (blob `1cad658ac521412e878a1b0edd0f12033481390b`, lignes 48–92) ; pour Shattered Pixel Dungeon, [ItemStatusHandler.java](https://github.com/00-Evan/shattered-pixel-dungeon/blob/e9defd0444c96d2fce3de5ec297c3398be8b7c55/core/src/main/java/com/shatteredpixel/shatteredpixeldungeon/items/ItemStatusHandler.java) (blob `ecbf502207ea533cd9b4e803b7c010065768ceaa`, lignes 35–75 et 175–205) complètent leurs preuves.

### Trois sources documentaires vérifiées, sans archive de code examinée

- **Darkest Dungeon** : [guide officiel Red Hook](https://steamcommunity.com/sharedfiles/filedetails/?id=819597757), sections compétences (paramètres `.launch`, `.target`, `.effect`), monstres (`monster_brain`, `death_class`), rencontres et désirs de sélection de compétence/cible. Il prouve le contrat de données exposé aux moddeurs. Aucun commit de moteur propriétaire ou fichier `.darkest` du jeu n'a été lu dans cette passe. La séparation des rangs, effets et IA reste un enseignement de ce contrat, pas une reconstruction du moteur.
- **Iratus** : [page Player Balance écrite par l'auteur du mod](https://www.nexusmods.com/iratuslordofthedead/mods/6), changelog de positions de lancement/ciblage et de dégâts ; le chemin des JSON de monstres est documenté. Les fichiers JSON téléchargés et le code du jeu ne sont pas disponibles dans cette passe. Le contenu annoncé par l'auteur n'est pas promu au rang d'analyse de code vérifiée.
- **Legend of Grimrock II** : [référence Lua de l'éditeur](https://www.grimrock.net/modding/scripting-reference/) : `defineObject`, `baseObject`, composants et `defineSkill` sont des API documentées. La page du manuel n'expose pas un commit figé ; cette passe ne contient ni mod Lua téléchargé ni test de hook. L'ancien inventaire mentionne `onDealDamage` et `onAttackHit` sans lecture de fichier de mod versionné, à garder en attente.

### Quatre titres sans preuve de code retrouvée

| Jeu | État vérifiable après cette passe | Pour certifier l'analyse annoncée |
|---|---|---|
| Battle Chasers: Nightwar | Page VERBOSE et phénomènes instrumentés ; pas de source du mod ni journal d'exécution figé | Récupérer l'archive autorisée ou des logs avec version, puis relever des observations reproductibles ; ne pas attribuer le pipeline interne au jeu. |
| Octopath Traveler II | Noms d'outils/mods historiques sans fichiers ou versions lus | Obtenir les assets modifiés ou le dépôt du mod, versionner et comparer les champs de compétences et Break. |
| Chained Echoes | BepInEx/Overdrive cités historiquement sans mod gameplay lu | Obtenir un mod de règles accessible avec commit ; un chargeur seul ne prouve pas la logique Overdrive. |
| Ruined King | Synthèse de gameplay des lanes ; pas de code de mod ni fichier de données récupéré | Classer comme observation de gameplay jusqu'à une source technique réellement consultable. |

### État de la couverture

Les 20 jeux de l'inventaire ont désormais un statut explicite : 13 avec lecture ciblée d'au moins un fichier de code (les six de la passe précédente et sept ici), trois avec documentation primaire/mainteneur examinée, quatre sans preuve de code retrouvée. « Fichier lu » ne signifie pas « étude complète du jeu » : les mécanismes non abordés conservent leurs réserves. La correction Dungeon of the Endless retire la prétention non étayée sur `SpawnMobs` du statut certifié. Les sources externes ne modifient ni le canon LITD ni le runtime.

Reproduction des sept sources de code : `git show <commit>:<chemin>` puis `git rev-parse <commit>:<chemin>` sur les dépôts liés. Cette passe est une revue statique ; aucun binaire ou mod tiers exécuté.


## Troisième passe de preuves — 2026-10-04

Cette passe remplace le statut courant « quatre titres sans preuve de code » de la section précédente par **deux**. Les résultats précédents restent conservés comme historique. Deux dépôts de randomiseurs ont été lus à des commits figés ; aucune exécution de jeu, mod ou binaire tiers n'a été effectuée.

### Octopath Traveler II : données de faiblesses et variantes de puissance

Source : [MarvinXLII/OT2R](https://github.com/MarvinXLII/OT2R/tree/1865d46344d2885b10e2e125ea9dfda238ac8635), commit `1865d46344d2885b10e2e125ea9dfda238ac8635` (2 août 2026, release v0.5.5).

| Fichier et repères | Blob | Constat vérifiable |
|---|---|---|
| [src/Databases/EnemyDB.py](https://github.com/MarvinXLII/OT2R/blob/1865d46344d2885b10e2e125ea9dfda238ac8635/src/Databases/EnemyDB.py), lignes 71–97, `shields`, `weapon_shields`, `magic_shields` | `564d22ba924fec992753beecb05c2ad5de770dd8` | L'accesseur concatène six résistances d'armes et six résistances d'attributs ; le setter impose douze entrées et les redistribue. |
| [src/Shields.py](https://github.com/MarvinXLII/OT2R/blob/1865d46344d2885b10e2e125ea9dfda238ac8635/src/Shields.py), lignes 214–216, `Shields.run` | `988c718a3030fe844a8373df5a9db140f2148f99` | Le randomiseur mélange ce tableau. Les branches précédentes excluent plusieurs boss, notamment pour des verrouillages scriptés ou des cas non testés. |
| [src/AbilityPower.py](https://github.com/MarvinXLII/OT2R/blob/1865d46344d2885b10e2e125ea9dfda238ac8635/src/AbilityPower.py), `AbilityPower.run` | `69d43a927817aec8f17d6ffecfcdded61f8f39b1` | Pour les ensembles retenus dont le dernier niveau a un ratio non nul, un facteur uniforme de 0,7 à 1,3 est tiré puis appliqué par la méthode de l'ensemble. |
| [src/Databases/AbilitySetDB.py](https://github.com/MarvinXLII/OT2R/blob/1865d46344d2885b10e2e125ea9dfda238ac8635/src/Databases/AbilitySetDB.py), lignes 22–26 et 59–62 | `22fbdcef286a8ff3aec323dc1ddf9ca9da238d41` | Les variantes NoBoost/BoostLv1/2/3 disponibles sont regroupées ; la mise à l'échelle multiplie puis convertit en entier le ratio des variantes d'attaque ou de soin. |

**Limite décisive :** le nom `shields` désigne ici un tableau de résistances/faiblesses, pas le nombre de points de bouclier ni son décrément. Ces fichiers ne prouvent ni la résolution du Break, ni les tours de récupération, ni l'IA du moteur propriétaire. La présence de cas de boss exclus interdit de conclure à la compatibilité générale du mélange.

**Adaptation proposée pour LITD, non implémentée :** représenter séparément affinités, compteur de rupture et états temporaires ; regrouper les variantes d'une compétence pour contrôler leurs changements ensemble ; conserver une liste explicite d'exceptions scriptées. Ces propositions sont des déductions de conception, pas des mécanismes LITD déjà livrés.

### Chained Echoes : graine et compétences de méchas

Source : [Samupo/ChainedEchoesRandomizer](https://github.com/Samupo/ChainedEchoesRandomizer/tree/f57935bcd99deb88908f8ddfe669d482df9c9e7a), commit `f57935bcd99deb88908f8ddfe669d482df9c9e7a` (1er juin 2026).

| Fichier et repères | Blob | Constat vérifiable |
|---|---|---|
| [RandomGen.cs](https://github.com/Samupo/ChainedEchoesRandomizer/blob/f57935bcd99deb88908f8ddfe669d482df9c9e7a/RandomGen.cs), lignes 7–35 | `45a5808132cf7a0ce101af8821333f71986d3093` | Affecter `Seed` recrée un unique `System.Random`. Les fonctions Range/Next consomment ce même flux. Ce fichier n'établit pas l'initialisation de la graine par tous les appelants. |
| [MechRandomizer.cs](https://github.com/Samupo/ChainedEchoesRandomizer/blob/f57935bcd99deb88908f8ddfe669d482df9c9e7a/MechRandomizer.cs), lignes 43–69 | `597a5104088429bd254026c5ba6cdf1dd717cc29` | Les compétences dont `skillUser >= 100` fournissent le pool de méchas. Chaque remplacement est retiré du pool : le dictionnaire associe les identifiants par permutation sans remise, sous réserve de données valides. |
| Même fichier, lignes 72–99 | Même blob | Trois préfixes Harmony concernent l'équipement, les compétences après niveau et la compétence de profession. Une méthode introuvable est journalisée ; le drapeau global de pose est néanmoins activé après les tentatives. |

**Limites :** un flux aléatoire unique ne prouve pas des sous-graines indépendantes, ni une reproductibilité entre versions de runtime et ordres d'appel différents. Les préfixes ciblent une version des signatures de jeu ; ils ne garantissent pas la compatibilité d'une installation actuelle. Les méthodes lues concernent la configuration des méchas, pas le calcul de l'Overdrive. Un hook nommé `SkillFunctions.UseSkill` ne suffit pas à certifier l'intégralité de la résolution du combat.

**Adaptation proposée pour LITD, non implémentée :** rendre les pools de compétences propres aux formes explicites, préserver les permutations par tirage sans remise et enregistrer le résultat de chaque pose de hook plutôt qu'un succès global implicite. La séparation des flux aléatoires reste une recommandation de conception à tester, pas une propriété démontrée par ce mod.

### Sources restantes : statut sans surcertification

- **Battle Chasers: Nightwar** : [VERBOSE](https://www.nexusmods.com/battlechasersnightwar/mods/3), version 0.53 annoncée, mise à jour le 8 septembre 2021. La page de l'auteur décrit l'instrumentation et distribue une DLL de remplacement (`BC_Data/Managed/Assembly-CSharp.dll`). Aucun code source ni log figé n'a été examiné ; une description d'instrumentation ne certifie pas le pipeline interne.
- **Ruined King** : aucune source pertinente pour les lanes ou la résolution du combat retrouvée dans cette passe. Les correctifs d'affichage/ultrawide repérés sont hors du mécanisme étudié et ne sont pas comptés comme preuve gameplay.
- **Darkest Dungeon, Iratus, Legend of Grimrock II** : les trois preuves documentaires de la passe précédente conservent leur statut. Aucun fichier de code supplémentaire n'est certifié ici.

### Couverture courante consolidée

| Niveau de preuve | Nombre de jeux | Portée |
|---|---:|---|
| Lecture ciblée de code avec commit et blob | **15 / 20** | Les treize titres précédents, plus Octopath Traveler II et Chained Echoes ; preuve partielle des mécanismes nommés, aucune étude exhaustive certifiée. |
| Documentation primaire ou auteur de mod | **3 / 20** | Darkest Dungeon, Iratus, Legend of Grimrock II. |
| Sans preuve de code gameplay consultée | **2 / 20** | Battle Chasers: Nightwar, Ruined King. |

L'avancement de couverture de code est donc passé de 13 à 15 titres (65 % à 75 %). Ce pourcentage compte des titres avec au moins une preuve ciblée ; il ne mesure ni la profondeur des études, ni le pourcentage de mécanismes du jeu reconstruits. Les vingt titres ont un statut explicite. Les anciennes affirmations sur Break, Overdrive et lanes restent non certifiées tant que leurs mécanismes précis n'ont pas de preuve correspondante.

Reproduction : récupérer les deux dépôts, lire `git show <commit>:<chemin>` et comparer `git rev-parse <commit>:<chemin>` aux blobs ci-dessus. Cette mise à jour porte uniquement sur le rapport existant dans la bibliothèque du dépôt ; aucun code tiers copié, aucun changement de runtime ou de canon LITD.


## Revue des vingt jeux et preuves gameplay — 5 octobre 2026

Cette section est l'état courant ; les sections précédentes décrivent les étapes historiques. Chaque titre reçoit une analyse ciblée, une pièce identifiable, une limite et une condition de revalidation. « Documenté » signifie que ces éléments sont présents ; cela ne signifie pas que l'intégralité du jeu est reconstruite.

### Classification de la preuve réellement lue

- **Règle** : code exécutant une décision ou un changement de paramètres gameplay (score IA, faim, permutation, protection, etc.).
- **Définition** : données de compétences/objets/salles ou code de configuration du contenu ; pas la résolution interne du moteur.
- **Extension** : routage de hooks ou chargement de ressources ; pas une preuve du mécanisme gameplay annoncé.
- **Outil** : squelette d'exemple produit par un outil ; pas le générateur du jeu.
- **Document** : page primaire ou de l'auteur décrivant les fonctionnalités ; aucun fichier gameplay lu.

La classification retient la preuve la plus pertinente déjà examinée pour chaque titre. Les références figées et plages des quinze premières lectures restent dans les sections précédentes ; les deux nouvelles lectures sont détaillées après la matrice.

| ID | Jeu | Pièce de référence examinée | Type | Analyse vérifiée / mécanisme encore non prouvé |
|---|---|---|---|---|
| J01 | Darkest Dungeon | The-Miko : `miko.info.darkest`, `miko.effects.darkest` ; nouvelle preuve ci-dessous | Définition | Rangs, paramètres de compétence et conditions hit/miss ; compactage après mort et résolveur natif non prouvés. |
| J02 | Battle Chasers: Nightwar | VERBOSE et trace AP auteur ; script Switch `d0222f29ab9bb64c.txt`, commit `abd55774c369b9c3a4df960e7afdb0391cb52056` | Outil | Chaînes de pointeurs et écritures PV/mana/argent inspectées ; version Switch 1.0.2 annoncée ; résolution native et DLL VERBOSE non lues. |
| J03 | Ruined King | Riot ; patchs Switch `62EB499A85240245.txt`, crédits Eiffel2018, commit `abd55774c369b9c3a4df960e7afdb0391cb52056` | Outil | Script de patch mémoire combat/ressources lu ; version Switch 1.6 annoncée ; moteur, lanes et délais natifs non reconstruits. |
| J04 | Iratus: Lord of the Dead | [Player Balance 0.526](https://www.nexusmods.com/iratuslordofthedead/mods/6) | Document | Modifications de positions et d'effets décrites par l'auteur ; JSON et plugin non examinés. |
| J05 | Darkest Dungeon II | Plugin-DD2 : `HookGenerals.cs`, `ModSupportPrefix` | Extension | Injection de dossiers de ressources ; Tokens, Combo, Death's Door et relations non prouvés par ce fichier. |
| J06 | For The King | FTKAPI : `ItemManager.cs`, `CustomItem.cs` | Définition | Lecture/insertion/remplacement d'objets ; jets, précision, casse et loot restent sans preuve correspondante. |
| J07 | Octopath Traveler II | OT2R : `EnemyDB.py`, `Shields.py`, `AbilityPower.py`, `AbilitySetDB.py` | Règle | Permutation d'affinités et facteur de puissance commun aux variantes ; compteur Break et séquence des impacts non prouvés. |
| J08 | Chained Echoes | CERandomizer : `RandomGen.cs`, `MechRandomizer.cs`, `HarmonyPatches.cs` | Règle | Flux à graine, permutation ; contribution Overdrive et jets de groupe de deux skills lus ; fonctions natives non reconstruites. |
| J09 | Slay the Spire | BaseMod : `BaseMod.java` | Extension | Abonnements, publication et retrait différé ; ordre des dégâts/blocs et décision IA non prouvés par ce framework. |
| J10 | Battle Brothers | MSU : `skill.nut` ; Modular Vanilla : `behavior.nut` | Règle | Modificateurs de coût/preview et multiplication du score de ciblage ; moral/blessures et stratégie vanilla non prouvés. |
| J11 | Enter the Gungeon | ExpandTheGungeon : `test_customroom_flow.cs` | Définition | Graphe fixe, entrée, parents et salles/tables ; validation du chemin critique et RNG natif non prouvés. |
| J12 | Dead Cells | ScriptTool : `BuildMainRooms.cs` | Outil | Squelette entrée → combat → sortie ; aucune preuve du générateur Motion Twin, de la complexité ou du tirage natif. |
| J13 | The Binding of Isaac: Rebirth | StageAPI15 : `roomsList.lua` | Définition | Catalogue normalisé et index par forme ; portes, traversabilité et compatibilité de l'API avec Rebirth non prouvées. |
| J14 | Spelunky 2 | CustomLevels : `custom_levels.lua` | Définition | Remplacement de niveaux, templates et filtres de spawn ; chemin principal vanilla et nettoyage complet non garantis. |
| J15 | FTL: Faster Than Light | Hyperspace : `InternalEvents.cpp` | Extension | Appel original, callbacks et remplacement de résultat ; budgets et sous-graines de rencontres non prouvés. |
| J16 | Stoneshard | ModShardLauncher : `RoomUtils.cs`, `DungeonsSpawn.cs` | Définition | Structure des salles et injection des tables tier/faction/ennemis ; anatomie, blessures et chemin critique non prouvés. |
| J17 | Legend of Grimrock II | KnightMods : `reskilled.lua`, `set_bonuses.lua`, `tweaks.lua` ; nouvelle preuve ci-dessous | Règle | Traits, bonus conditionnels, esquive et protection de partie corporelle des projectiles ; résolution native complète non prouvée. |
| J18 | Dungeon of the Endless | DungeonModifications : `DungeonModificationsMod.cs` | Définition | Configuration du nombre minimum/maximum de salles avant génération originale ; pondération des ennemis non prouvée. |
| J19 | Into the Breach | IntelligentAI : `ai.lua` | Règle | Scoring tactique moddé selon conséquences et garde-fous ; légalité complète des actions et IA vanilla non prouvées. |
| J20 | Shattered Pixel Dungeon | `Hunger.java`, `ItemStatusHandler.java` | Règle | Attrition par ticks, seuils et identification/serialization des catégories ; équilibre global non déduit de deux fichiers. |

### Nouvelle preuve J01 — Darkest Dungeon : contrat gameplay de The-Miko

Dépôt auteur : [Genso-Necromancer/The-Miko](https://github.com/Genso-Necromancer/The-Miko/tree/6c10b5aacff17faaa607ca91cd3f5b6dab5717ac), commit `6c10b5aacff17faaa607ca91cd3f5b6dab5717ac`.

- [heroes/miko/miko.info.darkest](https://github.com/Genso-Necromancer/The-Miko/blob/6c10b5aacff17faaa607ca91cd3f5b6dab5717ac/heroes/miko/miko.info.darkest), blob `419f347bd754a02e4a5e64a638a5e027d51850a6`, lignes 1–36 : résistances et équipement, puis compétences avec niveau, précision, dégâts, critique, lancement, cible et identifiants d'effets. `extermination` déclare launch 21/target 123 ; `persuasion_needle` déclare launch 432/target 234 et un déplacement ; `evil_sealing_circle` référence un effet de stun distinct.
- [effects/miko.effects.darkest](https://github.com/Genso-Necromancer/The-Miko/blob/6c10b5aacff17faaa607ca91cd3f5b6dab5717ac/effects/miko.effects.darkest), blob `edc43f16fa91b83aad5b465ba1acd6031860b6a5`, lignes 20–23 et 156–161 : `Miko Rhythm` et `Miko Miss Rhythm Break` déclarent des conditions hit/miss opposées ; les variantes `Miko Strong Stun` déclarent une chance croissante, une cible, stun et queue.

**Analyse :** la définition d'une compétence relie plusieurs opérations plutôt que d'incorporer toute leur logique. Rangs de lancement, rangs de cible, déplacement et déclenchement sont des dimensions distinctes. Une chance de stun déclarée supérieure à 100 % ne prouve pas la probabilité finale : la résistance et l'interprétation du moteur doivent être vérifiées séparément.

**Contre-preuve :** les lignes suivantes du fichier info répètent plusieurs fois le même identifiant `homing_amulet` pour un même niveau. Sans connaître la règle de chargement du moteur, on ne peut pas affirmer si ces lignes fusionnent, remplacent ou entrent en conflit. Ce dépôt ne prouve pas l'absence de doublons ni la bonne exécution du mod.

**Conclusion LITD :** cette source renforce l'intérêt de contrats distincts pour rangs/cibles et effets. Le ciblage des parties du corps LITD reste une contrainte propre au projet, non démontrée par ce mod. La mort/compactage doit conserver sa propre preuve et ses tests. Aucune règle de stun du mod n'est transposée automatiquement.

### Nouvelle preuve J17 — Grimrock II : traits, équipement et parties du corps

Dépôt auteur : [KnightMiner/GrimrockKnightMods](https://github.com/KnightMiner/GrimrockKnightMods/tree/5e7c80db7b677cecabd28a6ba30a9b39d6518f59), commit `5e7c80db7b677cecabd28a6ba30a9b39d6518f59`.

| Fichier figé | Blob | Plages / constat |
|---|---|---|
| [knight/reskilled.lua](https://github.com/KnightMiner/GrimrockKnightMods/blob/5e7c80db7b677cecabd28a6ba30a9b39d6518f59/knight/reskilled.lua) | `dcef01d5d7c84aa67e925dc2afbadeedd7fcc042` | 32–41 : trait `km_heavy_crit`, retour 10 uniquement si niveau positif, attaque melee et trait heavy_weapon. |
| [knight/set_bonuses.lua](https://github.com/KnightMiner/GrimrockKnightMods/blob/5e7c80db7b677cecabd28a6ba30a9b39d6518f59/knight/set_bonuses.lua) | `4755edd0f600d565f08578eb08c98bfe55e5acb8` | 9–38 : pose d'un callback sur EquipmentItem ; 69–85 : bonus d'esquive 10 conditionné par l'ensemble rogue, avec branche distincte pour The Guardians. |
| [knight/tweaks.lua](https://github.com/KnightMiner/GrimrockKnightMods/blob/5e7c80db7b677cecabd28a6ba30a9b39d6518f59/knight/tweaks.lua) | `da18f746baf164447d576ab5cbbcde32c199abb3` | 25–34 : coût après ancien modificateur multiplié par 0,8 selon équipement/configuration ; 47–83 : projectiles, esquive bornée, tirage de partie corporelle et protection. |
| [README.md](https://github.com/KnightMiner/GrimrockKnightMods/blob/5e7c80db7b677cecabd28a6ba30a9b39d6518f59/README.md) | `dec03337cf8e67a0c19c414851fe493bd6f44b43` | L'auteur limite la compatibilité à une branche beta et signale des mods/donjons non testés. |

**Analyse du projectile :** la chance de toucher calculée est bornée entre 5 et 95, puis comparée à un tirage. En cas de touche sur la party, un second tirage attribue poitrine 31 %, tête 22 %, jambes 25 % ou pieds 22 %. La protection de cette partie est réduite par la pénétration sans descendre sous zéro ; la moitié de la protection restante alimente une fonction de réduction des dégâts, puis le résultat est arrondi vers le bas.

**Limites et contre-preuves :** ce ciblage corporel est aléatoire et propre au mod, alors que LITD prévoit une sélection par le joueur. Le calcul de `computeDamageReduction` n'est pas reconstruit ici. Le wrapper appelle le précédent callback avant ses changements, donc les autres mods peuvent influencer le résultat. Les lignes 12–19 de `tweaks.lua` comparent `skill` à des chaînes puis tentent `skill + 1` : cela constitue un risque apparent de type sur ces branches, non un bug observé en exécution. Plusieurs traits portent seulement le commentaire hardcoded ; leur description seule ne prouve pas leur implémentation.

**Conclusion LITD :** séparer choix de partie corporelle, esquive, pénétration et réduction rend chaque phase vérifiable. Les bonus d'équipement et de traits ont des conditions explicites. Les valeurs numériques de ce mod ne sont pas une recommandation de calibrage pour LITD.

### Analyses documentaires J02, J03, J04 — résultat des recherches supplémentaires

**J02 — Battle Chasers.** La fiche publiée par l'éditeur confirme combat au tour par tour, survoltage/Bursts, exploration et donjons aléatoires. L'auteur de VERBOSE annonce des traces de scripts de compétences, jets, dégâts, DOT/HOT, récupération et boucliers ; la distribution indiquée remplace une DLL. L'onglet [Files](https://www.nexusmods.com/battlechasersnightwar/mods/3?tab=files) indique explicitement une connexion nécessaire au téléchargement. Le schéma ability → hit → dégâts → shield → DOT reste une hypothèse à confronter à des traces : ni l'ordre ni les formules ne sont certifiés. Pour le confirmer, il faut une archive accessible légalement ou des logs versionnés et un scénario reproductible ; aucun besoin de répertorier arbitrairement tous les fichiers du jeu.

**J03 — Ruined King.** La présentation [Riot du 11 décembre 2020](https://www.leagueoflegends.com/fr-fr/news/dev/ruined-king-gameplay-deep-dive/) décrit initiative, compétences instantanées/de voie/ultimes, santé/mana/survoltage, statistiques et personnalisation. Elle documente aussi l'équipement arme/armure/accessoires et les compétences d'exploration propres aux champions. C'est une présentation antérieure à la sortie : elle ne prouve pas les formules de la version jouable. La page Steam du guide officiel a été retrouvée mais sa restitution consultable ne fournit pas de texte de règles exploitable. Les résultats « Blade of the Ruined King » concernent souvent un objet de League ou des mods d'autres jeux : ils sont exclus. Les lanes, délais et zones de timeline nécessitent une source technique ou un jeu de traces ; les correctifs graphiques ne remplissent pas cette condition.

**J04 — Iratus.** La page auteur et l'onglet Files identifient Player Balance 0.526, variante avec BepInEx et variante sans chargeur. Le changelog décrit notamment des positions de lancement, déplacements et dégâts/stress pour des compétences de serviteurs. Cela permet une analyse du contrat annoncé : positions, coût, effet et amélioration doivent être traités séparément. Le JSON effectif peut toutefois différer du texte de présentation. Le lien manuel repéré (`file_id=38`) n'a pas livré l'archive dans la restitution consultable ; aucun hash ni contenu de JSON n'est certifié. La validation du stress, de la folie et du déplacement runtime reste ouverte.

### Analyse ciblée des dix-sept autres titres — ce que les preuves permettent de retenir

**J01 Darkest Dungeon :** contrats de rangs et effets déclaratifs réellement présents ; contrôler séparément unicité des variantes et interprétation du moteur. L'étude exhaustive de génération/IA/mort reste ouverte.

**J05 Darkest Dungeon II :** séparer l'enregistrement de données de leur résolution évite d'attribuer les tokens à un chargeur. La prochaine preuve utile est une définition de compétence et son consommateur runtime, pas un autre hook d'initialisation.

**J06 For The King :** le mod fait des objets des définitions modifiables ; l'existence d'une rareté ne démontre pas la distribution du loot. Il faut suivre un tirage effectif pour analyser probabilités et casse.

**J07 Octopath II :** garder les affinités distinctes du compteur de rupture évite une mauvaise lecture d'un nom de variable. Pour certifier Break, suivre l'impact, le décrément et l'état déclenché ; l'ordre multi-hit reste ouvert.

**J08 Chained Echoes :** permutation, graine et contribution Overdrive de deux skills sont démontrées dans le mod ; voir le complément ci-dessous. La fonction native de mise à jour de la jauge reste à lire.

**J09 Slay the Spire :** le framework permet des effets réactifs aux événements. Une publication ne démontre ni la priorité des effets ni leur composition déterministe. Il faut suivre un effet réel et sa file d'actions pour étudier ces règles.

**J10 Battle Brothers :** score d'action et modificateurs de l'acteur/cible sont composables dans les mods lus. Le maintien des actions légales demeure une condition distincte ; les mécanismes de moral et de blessures ne sont pas couverts.

**J11 Enter the Gungeon :** un flow encode l'intention topologique et délègue les salles à des overrides/tables. Ce cas fixe prouve la séparation des données ; il faut une génération et une validation de connectivité pour conclure sur la robustesse.

**J12 Dead Cells :** le squelette d'outil explicite des salles principales et secondaires. Il aide à lire un contrat d'auteur, mais ne certifie aucune distribution de layouts. Une source du script de biome réel reste requise.

**J13 Isaac :** grouper par forme facilite la sélection de candidats ; une forme compatible n'assure pas des portes compatibles. Le nom Rebirth de l'inventaire ne doit pas faire passer une API de version ultérieure pour preuve de cette édition.

**J14 Spelunky 2 :** configuration et population sont deux étapes observables du mod. Un filtre de spawn ne prouve pas que la sortie est accessible ; l'affectation répétée d'un identifiant de callback empêche de conclure au nettoyage intégral.

**J15 FTL :** l'appel au comportement original puis l'extension Lua expose un contrat de phase et de retour. Les budgets d'événements doivent être prouvés par leur sélection ; les hooks de menu ne démontrent pas le directeur de rencontres.

**J16 Stoneshard :** le contenu d'une salle et les tables d'ennemis sont manipulables, mais l'outil n'est pas le résolveur d'anatomie du jeu. La comparaison au ciblage corporel LITD reste une question nécessitant des règles de blessure précises.

**J17 Grimrock II :** la chaîne projectile/esquive/partie/protection est une preuve gameplay directe de mod. Elle illustre des phases testables ; le tirage aléatoire de partie ne remplace pas la sélection corporelle LITD.

**J18 Dungeon of the Endless :** changer les bornes de taille avant l'appel original concerne la configuration de génération. Cette lecture ne justifie toujours pas l'ancienne affirmation de sélection pondérée des ennemis.

**J19 Into the Breach :** le score évalue plusieurs conséquences d'une action, avec garde-fous susceptibles de remplacer la valeur. Il s'agit de l'IA du mod ; la télégraphie et la légalité complète ne se déduisent pas de ce score.

**J20 Shattered Pixel Dungeon :** le coût temporel des ressources et l'identification sont des mécanismes dont le code est public. Leur présence ne mesure pas le niveau de difficulté juste ; cet équilibre doit être observé ou testé séparément.

### Bilan exact et conditions de poursuite

- **20/20 jeux documentés avec analyse ciblée**, référence, limite et mécanisme restant à vérifier.
- **17/20 jeux avec code ou données versionnés lus**, contre 15 lors de la passe précédente.
- Parmi ces 17 : **6 règles**, **7 définitions/configurations**, **3 extensions**, **1 outil**. Ces catégories sont exclusives dans cette matrice.
- **3/20 sans code gameplay consulté** : Battle Chasers, Ruined King et Iratus, malgré leurs sources documentaires.
- Aucune étude exhaustive ni compatibilité runtime générale certifiée. Les vérifications locales/CI de LITD ne valident pas le fonctionnement des mods externes.

Les recherches web ont comparé pages d'auteurs, dépôts, documentation officielle et résultats contradictoires. La recherche de dépôts globale via le connecteur GitHub a été refusée par le périmètre d'URL de cet outil ; les dépôts nommés ont pu être lus normalement. Ce refus n'est pas interprété comme absence de dépôt. Les noms homonymes et correctifs graphiques sont exclus de la preuve gameplay. Pour les trois sources manquantes, la condition utile est un fichier ou une trace accessible et versionné, pas une nouvelle estimation de pourcentage.

La clôture globale reste conditionnée à la définition du mécanisme étudié, la lecture de sa preuve, un contre-exemple et une reproduction adaptée. Les vingt jeux ne sont pas déclarés « analysés à 100 % ». Les enseignements ci-dessus documentent la bibliothèque existante ; aucun changement de gameplay LITD ni fusion de PR.

## Approfondissement des preuves J02 et J08 — 5 octobre 2026

Cette passe complète la matrice précédente. Les nombres restent **20 jeux documentés / 17 avec code ou données versionnés lus** : une trace publiée par un auteur n'est pas comptée comme lecture de code. Iratus et Ruined King restent sans fichier gameplay consulté.

### J02 — Battle Chasers : trace publique, portée historique

Source primaire : [peddroelm, 31 décembre 2017](https://steamcommunity.com/app/451020/discussions/0/1621724915810895620/). L'auteur publie des valeurs d'AP mesurées avant application des dégâts : 1184,548 → 1362,230 → 1566,565 → 1801,549. Pour trois perks et 15 survoltage consommé, elles concordent à l'arrondi avec trois multiplications successives par 1,15. **Inférence vérifiable :** cet exemple soutient un cumul multiplicatif, plutôt qu'une addition unique des trois bonus. Le multiplicateur cumulé calculé est 1,520875.

**Limites :** build, protocole et fichier brut non fournis ; observation ancienne, non reproduite ici. Ce cas ne prouve ni la formule générale actuelle ni l'ordre bouclier/DOT. L'auteur indique lui-même devoir retester son observation de soin final. Le statut demeure **Document, avec trace auteur historique**, sans code gameplay lu.

Une [publication du même auteur en 2021](https://steamcommunity.com/app/451020/discussions/0/3042732979961911118/) précise la DLL remplacée et nomme `BattleManager.OnBattleCompleteSequenceDone()` et `ShufflePartyAfterCombat()`. Elle fournit un emplacement annoncé d'instrumentation ; elle ne permet pas d'inspecter son implémentation. Aucun téléchargement authentifié ni fichier binaire obtenu.

**Apport LITD :** une trace utile doit consigner valeur avant/après, survoltage effectivement consommé, perks actifs et version. Pour invalider l'hypothèse multiplicative, comparer notamment zéro perk et plusieurs perks à coût constant. Ces cas sont un protocole proposé, pas des tests exécutés.

### J08 — Chained Echoes : règle du préfixe, Overdrive et statuts

Source lue : [`HarmonyPatches.cs`](https://github.com/Samupo/ChainedEchoesRandomizer/blob/f57935bcd99deb88908f8ddfe669d482df9c9e7a/HarmonyPatches.cs), commit `f57935bcd99deb88908f8ddfe669d482df9c9e7a`, blob `780a948f05a3ab18cd603de101b27d3a26821fad`.

| Zone | Règle observée statiquement |
|---|---|
| 29, 36–54 | Enregistrement d'un préfixe Harmony sur `SkillFunctions.UseSkill`. |
| 401–407, 594–596 | `PreUseSkill` laisse passer les skills autres que 153/205 ; garde anti-réentrée, rétablie en fin de méthode ; retour final false. |
| 465–485 | Skill 153 : parcourt les ennemis vivants, vérifie la touche, appelle le calcul d'attaque physique puis les dégâts ; ajoute ensuite l'état 145 à l'utilisateur. |
| 488–513 | Skill 205 : niveau retrouvé par utilisateur/skill ; chance `0.25 * (niveau + 1)` ; tirage d'un état parmi quatre et un seul tirage de succès pour l'ensemble des ennemis vivants. |
| 517–563 | Combat hors mécha : si le type du skill correspond à `ODInfluencer`, appel `ChangeOverDrive(-12)`, puis remise à zéro des variables et de l'affichage concernés. Sinon, appels +7/+6/+5 selon taille de groupe ≥4/3/≤2. |
| 566–569 | Branche mécha : appel `ChangeOverDrive(7)`. |

**Interprétation limitée :** le mod démontre une contribution demandée à l'Overdrive pour ces deux skills, ainsi qu'une règle de sélection et d'application de statuts. Il appelle le moteur pour les dégâts, les états et la jauge ; le corps de `ChangeOverDrive` n'est pas présent dans ce fichier. Bornes de jauge, zones de surchauffe, résistances aux états et réduction des dégâts restent non reconstruits.

**Contre-exemples et risques visibles :**

- L'alternative `ChangeOverDrive(-15)` est derrière le `else` d'un `if (true)` : elle est inatteignable dans cette source et ne constitue pas une règle active.
- Le skill 205 réutilise le même état tiré et le même résultat de succès pour toutes les cibles vivantes ; ce code ne démontre pas des jets indépendants par cible. Les identifiants d'état 26/27/30/31 ne sont pas renommés en maladies sans leurs définitions.
- La section hors mécha parcourt toute la liste des skills ; elle ne quitte pas la boucle après un identifiant correspondant. La contribution unique suppose donc l'unicité de cet identifiant.
- Les branches d'animation mécha `skill >= 300` ne sont pas atteintes après la garde limitant ce préfixe à 153/205 ; elles ne prouvent pas la résolution d'autres skills.
- Une exception avant la remise à true peut laisser la garde désactivée : aucune protection `finally` n'est visible. C'est un risque de lecture statique, pas une panne reproduite.
- Le tirage de statuts utilise `UnityEngine.Random`, tandis que `RandomGen` utilise `System.Random`. La graine de permutation des méchas ne certifie donc pas la reproductibilité de ces jets de combat.

**Apport LITD :** expliciter la phase de contribution à une jauge collective, le partage ou l'indépendance des jets de groupe et l'identité des générateurs aléatoires. Les valeurs de ce mod restent des observations externes, sans modification du gameplay LITD.

### Recherche des trois fichiers manquants : exclusions vérifiées

Les recherches supplémentaires n'ont livré aucun fichier gameplay lisible pour Iratus ou Ruined King. Les résultats homonymes de League of Legends et les correctifs d'affichage sont exclus. Pour Battle Chasers, la trace ci-dessus améliore la provenance documentaire sans donner accès à la DLL.

Les pistes de dépôts d'applications/cartes, d'automatisation de sauvegarde et de jeu scolaire ne sont pas assimilées au code des titres commerciaux. Un nom de dépôt ressemblant au titre ne remplit pas l'obligation de preuve. Les trois titres demeurent sans code gameplay consulté ; cette limite est documentée dans la même bibliothèque.

## Recherche complémentaire des trois sources manquantes — 5 octobre 2026

**Résultat : aucun nouveau fichier gameplay obtenu ; couverture inchangée, 17/20.** Les liens de téléchargement consultés restituent des pages HTML, sans archive ni contenu des fichiers. Les descriptions ci-dessous sont des pistes de vérification ; elles ne sont pas promues en preuves de code.

### Iratus — trois archives supplémentaires identifiées

| Source auteur | Contenu annoncé et intérêt de lecture | Pièce encore manquante |
|---|---|---|
| [Nightsister 1.4](https://www.nexusmods.com/iratuslordofthedead/mods/5), scorpiovaeden | Classe séparée, variante de support/soin ; compétence de sommeil interrompu par dégâts annoncée ; compatibilité indiquée avec 176.02. L'auteur signale des limitations d'attributs associés aux extensions. | Archive et définitions réelles de classe/états ; le texte ne certifie pas le consommateur du sommeil. |
| [StatsHolic 1v5](https://www.nexusmods.com/iratuslordofthedead/mods/9), A100N | Deux JSON remplacés ; accès annoncé aux onze statistiques et réorganisation de leur arbre. Version 181.xx+ ; anciennes sauvegardes déclarées incompatibles. | [Fichier 52](https://www.nexusmods.com/iratuslordofthedead/mods/9?file_id=52&tab=files), 8 KB, puis schéma et différences des deux JSON. |
| [Playable Enemies 1.0](https://www.nexusmods.com/iratuslordofthedead/mods/13), Tbonex28b | Ennemis utilisables dans l'équipe ; l'auteur propose de changer `nodeSize` de 2 à 1 pour les grandes unités. Il signale également des tours perdus en équipe mixte, cause inconnue. | [Variante Two Slots, fichier 53](https://www.nexusmods.com/iratuslordofthedead/mods/13?file_id=53&tab=files), 382 KB, et définitions de taille/rangs/tours. |

**Portée :** `nodeSize` est ici un fragment publié dans une instruction d'auteur, pas un JSON complet inspecté. Sa relation aux rangs et à l'occupation d'espace reste à vérifier dans les fichiers et leur consommateur. L'observation de tours perdus ne démontre pas un défaut précis du moteur. Ces pistes sont pertinentes pour les rangs, la capture et les afflictions de LITD, sans règle de combat LITD modifiée.

La [piste GitHub lawrakina/Battler-2D-Unfrozen-Iratus](https://github.com/lawrakina/Battler-2D-Unfrozen-Iratus) a également été examinée : arborescence Unity de prototype, modèle de combat limité dans le fichier lu à une propriété réactive de changement d'état. Aucune provenance de mod branché au jeu commercial établie ; exclu du compte de preuves. Référence arbre Git `31eccef1e8e4a75b63b5ce7983a42af3a82029be`, fichier `Assets/Code/Data/Models/FightProcessModel.cs`, blob `16e21820d7ace1de9b1005f9a96604294d11e156`.

### Battle Chasers — patch d'affichage distinct des règles de résolution

[Display Damage-Shield Text 1.1](https://www.nexusmods.com/battlechasersnightwar/mods/1), Eugenii10 : le programme annoncé `BCN-DST-Mod.exe` modifie l'affichage numérique des boucliers, avec sauvegarde/restauration de `Assembly-CSharp.dll`. L'auteur indique la version de jeu 24037 et l'arrêt du support. Le programme et ses modifications n'ont pas été obtenus. Même une lecture de son patch d'affichage ne certifierait pas à elle seule le calcul d'absorption.

La pièce prioritaire reste [VERBOSE 0.53](https://www.nexusmods.com/battlechasersnightwar/mods/3?tab=files) : archive de l'auteur et, idéalement, traces de combat associées à une version et un scénario. La trace AP historique déjà documentée ne remplace pas cette lecture.

### Ruined King — dépôts homonymes écartés

| Dépôt examiné | Pièce lue | Pourquoi exclu de la preuve du jeu commercial |
|---|---|---|
| [WashingtonAlbuquerque/RuinedKing](https://github.com/WashingtonAlbuquerque/RuinedKing) | README blob `53c6737261393c73088c4772a7f8233abc311c4a` ; arbre Git `6ee926878ece248d37040539bd3f7d00586c1bfd` | Présentation HTML/CSS/JavaScript ; aucune implémentation de mod gameplay établie. |
| [SkyKhoala/RuinedKing](https://github.com/SkyKhoala/RuinedKing) | README blob `65fabb592b365c00ee2e55d979283c5054360288` ; arbre Git `90969f8fe1836136235b4d467d6f0cb5084f881e` | Projet CMI Pygame avec déplacement/saut ; distinct du RPG d'Airship. |

Les résultats liés à Viego ou à l'objet Blade of the Ruined King dans d'autres jeux restent exclus. Aucun mod public lisible de résolution des lanes n'a été identifié dans cette passe. Cela décrit les résultats consultés, sans affirmer qu'aucun mod n'existe.

### Déblocage concret

Pour **Iratus**, une seule archive pertinente suffit à lancer l'inventaire automatique : Player Balance sans BepInEx, StatsHolic ou Playable Enemies. Pour **Battle Chasers**, l'archive VERBOSE est la piste prioritaire. Ces archives peuvent être jointes directement au chantier après téléchargement normal depuis le compte de l'utilisateur ; il n'est pas nécessaire de fournir chaque chemin séparément.

Pour **Ruined King**, aucune archive gameplay fiable n'est encore identifiée : il faut un mod clairement rattaché au jeu, ou des fichiers de données provenant d'une installation autorisée avec version indiquée. Aucun accès à l'installation du PC de l'utilisateur n'est disponible dans cet espace.

À réception : inventorier l'archive sans exécuter ses binaires, calculer les empreintes, identifier les définitions et leurs consommateurs accessibles, suivre une règle concrète et noter ses contre-exemples. Jusqu'à cette réception, les trois obligations de lecture de code restent ouvertes ; aucune clôture exhaustive.

## Ruined King — première source de patch gameplay lue, 5 octobre 2026

**Cette passe remplace le statut documentaire exclusif de J03.** Le bilan atteint **18/20 avec code, données ou scripts de patch versionnés lus**, en incluant explicitement ce patch Switch parmi les outils. Il ne devient pas 18 moteurs analysés. Les catégories exclusives sont désormais : 6 règles, 7 définitions/configurations, 3 extensions, 2 outils/patchs ; Battle Chasers et Iratus restent documentaires.

### Provenance et fichiers réellement consultés

Dépôt [ADEMOLA200/Switch-Emulator-Mod-Database](https://github.com/ADEMOLA200/Switch-Emulator-Mod-Database), commit `abd55774c369b9c3a4df960e7afdb0391cb52056`. Arbre récursif non tronqué ; fichier gameplay relu avec cette référence épinglée.

| Fichier | Blob Git | Portée |
|---|---|---|
| [Titles/0100947013122000/cheats/62EB499A85240245.txt](https://github.com/ADEMOLA200/Switch-Emulator-Mod-Database/blob/abd55774c369b9c3a4df960e7afdb0391cb52056/Titles/0100947013122000/cheats/62EB499A85240245.txt) | `bb76ce08d1dbf59922a5a35e3fc31a46ea1e23d6` | Douze blocs nommés, dont invincibilité, dégâts, mana, ultime, ressources, progression et fabrication. |
| [Titles/0100947013122000/credits.txt](https://github.com/ADEMOLA200/Switch-Emulator-Mod-Database/blob/abd55774c369b9c3a4df960e7afdb0391cb52056/Titles/0100947013122000/credits.txt) | `1a84fa704f6a072398c77abb3756b428c7032fa2` | Attribution Eiffel2018, titre commercial et version 1.6 annoncée. |
| [Patchs FPS, build 9FC46F388F6C684C](https://github.com/ADEMOLA200/Switch-Emulator-Mod-Database/blob/abd55774c369b9c3a4df960e7afdb0391cb52056/NX-60FPS-RES-GFX-Cheats/titles/0100947013122000/cheats/9FC46F388F6C684C.txt) | `178b995145bea5692cc385fe95048ac14732e32b` | 30/60 FPS, autre build : exclu des preuves de règles de combat. |

Documentation primaire du format : [Atmosphère, Store Static Value to Memory](https://github.com/Atmosphere-NX/Atmosphere/blob/c8b7316581a8081e5b9f7d767c27db5c0a4db906/docs/features/cheats.md), section Code Type 0x0, blob `465ded946971ffd089807c52b928419444d7c960`. Le format décrit largeur, région mémoire, registre d'offset, offset immédiat et valeur écrite.

### Analyse statique précise

| Bloc du script | Ce que le fichier prouve | Ce qu'il ne prouve pas |
|---|---|---|
| Infinite Mana / Infinite Ultimate | Chaque bloc contient une écriture d'un octet `62`, respectivement avec offsets immédiats `0259D730` et `0254A710`. | Nom/signature de fonction native, nature exacte de l'instruction remplacée, modèle de consommation de ressources. |
| 5x Damage | Trois écritures de huit octets dans `0329DE14–0329DE2B`, puis une écriture de quatre octets en `0259FE44`. | Multiplication par cinq effectivement exécutée, filtrage joueur/ennemi, ordre critique/armure/bouclier : le libellé seul ne certifie pas ces effets. |
| Infinite Upgrade Points / Rune Shards | Deux séquences distinctes, chacune avec écriture de huit octets puis quatre octets. | Coûts natifs, caps, règles d'arbres et persistance en sauvegarde. |
| Infinite Potions and Meals / 100% Successful Crafting | Même valeur littérale `D503201F` écrite à deux offsets différents. | Consommation ou probabilité native ; le désassemblage et les octets originaux restent à obtenir. |

Ces commandes sont des écritures statiques du format Atmosphère. Pour les commandes commençant par `010E/040E/080E`, la région indiquée est Main NSO et le registre d'offset est E : les nombres cités sont donc des **offsets immédiats**, pas des adresses absolues ni des noms de fonction.

**Conclusion de preuve :** un script de modification lié au gameplay du titre commercial est maintenant inspecté et traçable. Son contenu montre les opérations de patch ; les noms des options demeurent des déclarations d'auteur tant que les instructions remplacées et le contexte d'appel ne sont pas reconstruits. Aucun binaire ni patch exécuté, aucune ROM téléchargée, aucune compatibilité PC déduite de la version Switch.

### Limites et contre-exemples

- Le build ID `62EB499A85240245` ne se confond pas avec le build du patch FPS. Des offsets d'un build ne sont pas transférables à l'autre.
- Aucun octet original ou test d'identité du code ciblé n'est fourni dans les blocs lus ; appliquer ces nombres à une autre version ne constituerait pas une preuve valable.
- Des écritures proches et des intitulés liés aux ressources ne démontrent pas qu'une seule classe ou un seul résolveur gère mana, ultime et dégâts.
- Un patch d'invincibilité retire une contrainte du combat ; il ne documente pas son équilibrage normal.
- Les lanes, l'initiative, les délais, les zones de timeline et les afflictions restent des obligations de lecture native ouvertes.

**Apport LITD :** la première leçon exploitable concerne la provenance : associer toute preuve de combat à la plateforme, la version et le fichier réel. La séparation des ressources ne doit pas être inférée de noms d'options. Aucun calibrage ni règle LITD ne change sur la base de ces patchs.

Une page primaire [ColonelRVH, table PC du 17 novembre 2021](https://www.thecheatscript.com/2021/11/ruined-king-league-of-legends-story.html) annonce également l'inspection des PV et des options de mana/survoltage/ultime. La table PC elle-même n'a pas été lue ; elle reste une piste documentaire distincte. La prochaine preuve utile est son script complet ou les instructions originales entourant une cible du patch Switch, avec version et scénario précis.

## Solution de poursuite — Battle Chasers et limites non bloquantes, 6 octobre 2026

L'utilisateur accepte de poursuivre si les dernières pièces ne sont pas accessibles. Cette décision concerne le blocage du chantier ; elle n'autorise pas à certifier les preuves manquantes ni à fusionner la PR.

### Battle Chasers : source publique effectivement lue

Dépôt [ADEMOLA200/Switch-Emulator-Mod-Database](https://github.com/ADEMOLA200/Switch-Emulator-Mod-Database), commit `abd55774c369b9c3a4df960e7afdb0391cb52056`.

| Fichier | Blob Git | Provenance/portée |
|---|---|---|
| [Titles/0100551001D88000/cheats/d0222f29ab9bb64c.txt](https://github.com/ADEMOLA200/Switch-Emulator-Mod-Database/blob/abd55774c369b9c3a4df960e7afdb0391cb52056/Titles/0100551001D88000/cheats/d0222f29ab9bb64c.txt) | `145a7d388f7bd0dfcccada43a30500763a996338` | Quatre blocs : argent, PV, mana et un second bloc nommé PV All. |
| [Titles/0100551001D88000/credits.txt](https://github.com/ADEMOLA200/Switch-Emulator-Mod-Database/blob/abd55774c369b9c3a4df960e7afdb0391cb52056/Titles/0100551001D88000/credits.txt) | `5682a577f09f27ddb05f4b476e0b7ff80cc1c72d` | Battle Chasers: Nightwar v1.0.2 ; attributions merlin555 et arismendy64. |

Format vérifié dans la [documentation primaire Atmosphère](https://github.com/Atmosphere-NX/Atmosphere/blob/c8b7316581a8081e5b9f7d767c27db5c0a4db906/docs/features/cheats.md), sections 0x5 (lecture/déréférencement), 0x6 (écriture à l'adresse d'un registre), 0x7 (arithmétique).

**Lecture statique :** les blocs PV et mana partent du même pointeur Main NSO à l'offset `03234D30`, suivent les mêmes déréférencements successifs (+A0, +0, +30, +18), puis ajoutent respectivement +48 et +5C avant une écriture de quatre octets. Si le champ est un float IEEE 754, `43020000` encode 130 et `43160000` encode 150. Cette interprétation numérique est vérifiée localement par conversion binaire ; le type réel des champs n'est pas démontré sans leur consommateur.

Le bloc nommé Inf Hp All reprend exactement la chaîne du bloc PV et le même offset final +48 ; seule la valeur passe à `461C3C00` (9999 si float). **Contre-preuve :** aucune boucle sur les combattants n'est présente ; le mot All ne suffit donc pas à prouver l'application à toute l'équipe.

Le bloc argent utilise une autre racine `0327F5A0` et une chaîne plus courte. L'écriture de huit octets contient deux mots `000F423F` (999999 en entier non signé). L'identité des deux champs n'est pas reconstruite ; il serait injustifié de leur attribuer deux devises particulières.

**Portée exacte :** script de modification mémoire versionné réellement consulté, sans exécution. Ni calcul des dégâts, ni ordre bouclier/DOT, ni survoltage, ni fonctionnement de la DLL VERBOSE ne sont prouvés par ce script. Les chaînes et valeurs ne sont pas transposables au PC ou à une autre version. Aucun fichier du jeu complet obtenu.

### Iratus et règles natives : arrêt des recherches répétitives

La dernière recherche de `unitBalance.json` et de Player Balance n'a pas fourni de JSON Iratus accessible. Les résultats de fichiers homonymes liés à Warcraft ne sont pas des preuves d'Iratus. Les sources auteur déjà rangées restent disponibles avec leurs limites.

La solution retenue est de **poursuivre avec les preuves accessibles**, plutôt que de rendre toute la bibliothèque dépendante de ces archives. Les lectures manquantes sont conservées comme compléments :

| Complément | Statut | Déclencheur de reprise |
|---|---|---|
| JSON/classe/résolveur Iratus | Différé, non bloquant ; documentaire seulement | Réception d'une archive ou découverte d'un fichier public pertinent. |
| DLL et logs VERBOSE Battle Chasers | Différé ; patch Switch et trace historique disponibles | Archive auteur accessible et version précisée. |
| Fonctions natives Ruined King : lanes, dégâts, afflictions | Différé ; patch Switch disponible | Source technique complète ou fichiers d'une installation autorisée. |

**Bilan mis à jour :** 20 jeux documentés ; 19 avec code/données/scripts de patch lus, dont 3 outils/patchs. Le nombre de preuves directes de règles reste 6 : ajouter un script mémoire ne transforme pas un outil en moteur analysé.

La recherche publique effectuée peut être considérée terminée dans ce périmètre, avec ces limites. L'analyse exhaustive des vingt jeux n'est pas déclarée CLOS. Les enseignements déjà établis peuvent être exploités dans la bibliothèque existante en gardant leur niveau de preuve ; aucun changement de gameplay LITD ni fusion dans cette passe.


## Confrontation des preuves avec LITD — 7 octobre 2026

**Statut : comparaison documentaire terminée sur le périmètre ci-dessous ; validation dynamique non réalisée.** Référence LITD : `a3aeb94f87a0bd3d31da824ec5f9464d76f367d9` (main, fusion #556). Les preuves externes restent celles des fiches J01–J20, avec leurs commits, fichiers et limites. Ce complément n'introduit aucune règle gameplay ni promotion du canon.

### Périmètre et chemins réellement distincts

Le sandbox `scripts/core/veilleurs_combat_sandbox_runtime.gd` délègue la résolution à `scripts/core/combat/veilleurs_combat_sandbox_canonical_adapter.gd`. Ses héros utilisent des actions et des zones ; sa phase ennemie cible le héros vivant aux PV absolus les plus faibles, puis appelle une attaque simplifiée.

Le chemin tactique possède notamment `scripts/core/veilleurs_enemy_ai_v2.gd`, `veilleurs_enemy_ai_v3.gd` et les contrats tactiques de `VeilleursTargetResolver`. L'ancien `scripts/core/enemy_combat_director.gd` sélectionne des compétences pondérées et utilise des tirages globaux. Ces observations ne prouvent pas que chaque scène utilise chacun de ces chemins. Il faut identifier le consommateur avant toute correction.

La passerelle physique du Premier Accord est maintenant présente : `scripts/world/first_accord_playable_world.gd`, fonctions `interact_current_room`, `_show_combat` et `_on_combat_finished`. Elle capture la position, ouvre le combat, restaure la transformation et empêche une interaction sur une salle déjà terminée. Ce constat statique ne certifie pas le parcours complet, la persistance ni le playtest PC.

### Les vingt études face au code actuel

« Correspondance » indique une structure comparable, pas une copie ni une preuve d'équivalence de gameplay. « Non établi » signifie que cette inspection ciblée n'apporte pas de preuve suffisante.

| Étude | Preuve externe réellement utilisable | Correspondance LITD inspectée et limite |
|---|---|---|
| J01 Darkest Dungeon | Rangs et effets déclaratifs du mod | TargetResolver/targeting_rules ; compactage via DeathResolver et position_runtime. Le compactage est prouvé dans LITD, pas par les fichiers externes lus. |
| J02 Battle Chasers | Écritures mémoire PV/mana/argent | Les mutations LITD passent par les résolveurs et leur orchestration. Un patch mémoire ne fournit aucune formule transposable ni contrat AP natif. |
| J03 Ruined King | Scripts mémoire combat/ressources | Pas de preuve exploitable pour comparer lanes ou délais ; aucune adoption proposée. |
| J04 Iratus | Description de mod | Pas de fichier gameplay externe lu : aucune comparaison de formule certifiée. |
| J05 Darkest Dungeon II | Injection de ressources | Comparaison architecturale seulement ; Tokens, Combo et Death's Door non prouvés par cette source. |
| J06 For The King | Définition et insertion d'objets | EquipmentProcResolver lit les bonus d'équipement ; loot, précision et casse FTK non prouvés. |
| J07 Octopath II | Affinités permutées et facteur de puissance | StatusResolver distingue résistance de durée et de dégâts. Ces résistances ne sont pas un compteur Break ; aucun portage de Break déduit. |
| J08 Chained Echoes | Flux à graine, permutation, Overdrive de deux skills | DungeonRunSeed et HitResolver rendent certains tirages reproductibles. Pas d'équivalence avec Overdrive ni avec les jets groupés de statuts du mod. |
| J09 Slay the Spire | Publication/abonnement d'événements | CombatEvent/Inspector distinguent observation et résolution ; BaseMod ne prouve pas l'ordre dégâts/bloc ou la décision IA. |
| J10 Battle Brothers | Coûts/preview et score modifié | IA V2 score distance, PV, blessures et rôle ; V3 ajoute mémoire et sélection corporelle. Pas d'équivalence avec l'IA vanilla ni preuve globale de légalité. |
| J11 Enter the Gungeon | Graphe de salles fixe | HybridDungeonGenerator construit et valide un graphe ; le fichier externe ne prouve pas la validation native. |
| J12 Dead Cells | Outil de squelette de salles | Les profils et graphes LITD sont inspectables ; l'outil externe n'est pas une preuve du générateur natif. |
| J13 Isaac Rebirth | Catalogue par forme | DungeonRoomResolver filtre et trie les modules avant tirage pondéré. Portes/traversabilité de StageAPI non prouvées. |
| J14 Spelunky 2 | Templates et filtres de spawn | RoomResolver/MapBuilder emploient des modules ; pas de garantie externe de chemin principal ou nettoyage des callbacks. |
| J15 FTL | Callbacks et remplacement de résultat | Pipeline et adaptation de résultat sont comparables ; budgets et sous-graines FTL ne sont pas démontrés. |
| J16 Stoneshard | Tables de salles/ennemis | Module et encounter data LITD sont distincts de l'anatomie ; aucune preuve externe d'anatomie issue de ces fichiers. |
| J17 Grimrock II | Projectile, esquive, partie corporelle, protection | Target/Hit/Damage/AnatomyResolver séparent ces phases. La sélection volontaire des zones LITD doit être conservée ; le tirage de partie du mod ne la remplace pas. |
| J18 Dungeon of the Endless | Minimum/maximum de salles | DungeonProfile contrôle les plages ; RoomResolver réalise un tirage pondéré de modules. Ne pas attribuer ce dernier à la preuve externe. |
| J19 Into the Breach | Score de conséquences avec garde-fous | IA V2/V3 possède des scores/heuristiques ; une évaluation exhaustive des conséquences et la télégraphie ne sont pas établies ici. |
| J20 Shattered Pixel Dungeon | Ticks d'attrition et identification sérialisée | StatusResolver possède des ticks et expirations. Ce n'est pas la preuve d'un système LITD complet de faim/identification ni de son équilibre. |

### Constats précis et validations restantes

**Rangs et mort déjà implémentés.** `VeilleursDeathResolver.resolve_actor` déclenche `CombatPositionRuntime.compact_enemy_formation` pour les ennemis ; cette fonction trie les vivants par position puis les compacte dès R1. Le ciblage lit ces positions. Attention : le mouvement manuel consulte les cadavres, mais le compactage ne consulte pas `_slot_blocked_by_corpse`. La coexistence compactage/cadavres doit être validée selon le contrat canonique ; ne pas changer la règle sur la seule base de Darkest Dungeon.

**Sélection corporelle déjà implémentée.** TargetResolver possède six zones et un contrat de cible/zone ; AnatomyResolver enregistre blessures et perte fonctionnelle. Une zone inconnue est normalisée en torso : vérifier séparément le comportement attendu des commandes invalides. Grimrock ne justifie pas de remplacer la sélection du joueur par un tirage aléatoire.

**Étourdissement : protection après expiration, rafraîchissement actif encore possible.** StatusResolver accorde une immunité d'un tour de l'acteur lorsque stun expire. Mais `apply_affliction` utilise `max(durée restante, durée demandée)` pour toutes les afflictions ; une nouvelle demande de deux tours lorsque stun n'a plus qu'un tour le ramène à deux. La protection après expiration ne garantit donc pas à elle seule l'absence de verrouillage par rafraîchissements avant expiration. EquipmentProcResolver demande toujours un tour : répéter ce proc sur un stun d'un tour ne l'allonge pas ; il n'existe pas de branche spéciale « stun déjà actif ». Le test de procs ne couvre pas tous les producteurs de stun. Aucun correctif dans ce lot.

**Afflictions et silence.** Dix afflictions sont définies ; poison/burn/freeze restent explicitement prototype, sept sont actives. Les résistances signées durée/dégâts sont bornées de -100 à +100. Silence bloque une action avec coût de trame ou effet préfixé trame ; le test existant couvre ce blocage héros. L'attaque ennemie simplifiée du sandbox ne porte pas de coût de trame : une démonstration de silence contre une véritable action ennemie de trame n'est pas fournie par ce chemin. Aucun arbitrage gel/brûlure n'est établi par les fonctions StatusResolver inspectées ; le statut prototype doit être conservé.

**Aléatoire et IA.** DungeonRunSeed expose layout/room/encounter/event/loot/ai ; RoomResolver consomme un générateur room par salle et trie ses candidats. Cette présence ne prouve pas que chaque consommateur utilise son flux : EnemyCombatDirector appelle encore randi/randf globaux, tandis que HitResolver emploie des hashes de commandes. Séparer audit de topologie, combat, IA et replay. La documentation officielle Godot consultée le 7 octobre confirme qu'un générateur peut posséder son propre état/graine et que la reproductibilité ne doit pas être promise à travers des versions du moteur : [RandomNumberGenerator](https://docs.godotengine.org/en/4.7/classes/class_randomnumbergenerator.html), [génération aléatoire](https://github.com/godotengine/godot-docs/blob/master/tutorials/math/random_number_generation.rst).

### Vérification effectuée et décision de suite

Inspection des fonctions et tests existants, sans exécution de mod tiers. Godot et pytest sont absents de cet environnement. Les 33 fonctions sans paramètres de cinq fichiers existants ont été exécutées directement via Python/runpy : **32 réussites, 1 échec**. Fichiers : `tests/test_combat_formation_contract.py`, `tests/test_combatant_inspection.py`, `tests/test_first_accord_hybrid_data.py`, `tests/python/test_hybrid_dungeon_generation.py`, `tests/python/test_physical_first_veil_dungeon.py`. Cela vérifie leurs assertions documentaires/données, pas un combat Godot.

Échec préexistant sur le main inspecté : `test_preview_and_detail_show_stats_afflictions_and_skills`, assertion de présence du libellé « AFFLICTIONS, BUFFS ET DEBUFFS » dans le fichier HUD. Ce test textuel ne démontre pas une panne gameplay. Le lot ne modifie ni le test ni le HUD.

Ordre de validation proposé, sans règle nouvelle imposée : (1) reproduire les rafraîchissements de stun actifs avec plusieurs producteurs ; (2) vérifier compactage et cadavres ; (3) tester silence sur une action ennemie de trame ; (4) inventorier les consommateurs du flux ai et les entrées nécessaires au replay ; (5) exécuter la boucle physique/combat/retour en Godot. Les règles déjà présentes ne doivent pas être réimplémentées. Tout changement de contrat devra être distinct de cette comparaison documentaire.

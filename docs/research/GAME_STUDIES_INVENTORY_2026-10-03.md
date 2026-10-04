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

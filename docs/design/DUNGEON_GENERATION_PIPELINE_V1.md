# Génération de donjons — première tranche intégrée

Base : `main` ba51ba4. Le générateur de graphe et le planner Premier Accord
existants sont étendus ; aucune géométrie procédurale ni moteur parallèle.

## Graines et assemblage

`DungeonRunSeed.compose` conserve exactement la graine historique de topologie,
avec les mêmes composantes campagne, donjon, visite, difficulté, époque et tentative.
Les flux nommés `room`, `encounter`, `event`, `loot`, `ai` dérivent séparément de cette
graine. Les graines par salle utilisent son ID, sans dépendre de l'ordre des tirages
ou des salles. La reproductibilité suppose les mêmes données, la même version du
générateur et la même version Godot ; aucune garantie entre versions du moteur.

Le planner choisit les pools compatibles avec le rôle selon leurs poids, puis un
module dans le pool selon son poids (1 par défaut). Les poids nuls/négatifs excluent
un candidat. Les salles obligatoires et le boss conservent leurs pools imposés.
Les variantes utilisent une graine indépendante par salle.

Deux pools logiques préexistaient sans module physique. La configuration déclare
explicitement `accord_service_rooms → accord_guardroom` et
`accord_forgotten_chamber → accord_sealed_archive`. Le pool logique est conservé
pour les tables de rencontre ; `module_source_pool` identifie le catalogue réellement
utilisé et `module_pool_fallback` signale ce recours. Il ne s'agit pas de deux nouvelles
salles physiques. Tout module, même optionnel, doit exister et appartenir au pool
source attendu ; sinon le planner revient à la carte authored existante.

## Rapport et validation

`generation_report` décrit le plan final : graine/version, moteur, flux, tentative,
nombres de salles, boucles, secrets, retraites, recours aux pools de repli et résultat
de validation. Un repli authored comporte sa raison et ne prétend pas avoir produit
un plan procédural valide. Aucun changement des PV, des dégâts, du ciblage anatomique
ou des règles de Rémanence.

Le smoke `dungeon_generation_pipeline_smoke.tscn` vérifie 1 000 plans reproduits à
l'identique, l'isolation des tirages, les pools accessibles, les poids 1:9, les poids
exclus et les modules invalides. Il rejoint le domaine CI `veilleurs` existant.

## Suite du chantier global

Les graines encounter/event/loot/ai sont exposées comme contrat pour les étapes
suivantes. Cette tranche ne sélectionne ni ne matérialise de rencontres : le planner
conserve les tables de candidats existantes. L'Encounter Director, les contraintes de
capacité, les événements et le butin restent à brancher. Les modules physiques restent
à produire dans leur chantier existant ; ce changement valide leurs définitions.

Sources primaires consultées :
- https://docs.godotengine.org/en/4.7/classes/class_randomnumbergenerator.html
- https://docs.godotengine.org/en/latest/tutorials/math/random_number_generation.html

## Validation locale du 2 octobre 2026

Godot 4.7.2 : import complet sans erreur de script ; nouveau smoke 1 000 plans PASS ;
smoke graphe existant 200 graphes + 100 plans PASS ; Premier Accord 80 cas reproduits
+ 1 000 graines de stress PASS (aucun module non résolu). Tests Python ciblés : 26 PASS.
Le projet complet signale à la fermeture trois ressources encore utilisées, signal
également reproduit sur le commit de base non modifié. Le test isolé du générateur
passe sans ce signal. La CI distante doit encore confirmer les domaines complets.

## Deuxième tranche : planification des rencontres après Rémanence

`FirstAccordHybridRuntimePlan.build` appelle `FirstAccordEncounterPlanner.populate`
après projection des cicatrices et décoration du monde. Il conserve les affectations
Némésis existantes, les salles et toutes les connexions. Un flux encounter par ID de
salle sélectionne les candidats pondérés admissibles. Le boss authored reste fixe,
les rôles entry/rest/secret ne reçoivent pas de rencontre, les branches optionnelles
respectent leur probabilité et leur candidat vide explicite. Les quatre rencontres
non-boss du chemin critique doivent respecter le quota 4–7, sinon retour authored
avec motif explicite. Les budgets de profondeur plafonnent la menace ; une pression
blessure élevée ou des réserves basses sélectionnent la menace admissible la plus
faible, sans modifier PV/dégâts ni supprimer le chemin critique.

Les tags de formation doivent tous être acceptés par l'ancre. Une composition avec
`enemy_count` dépassant sa capacité est rejetée. Le catalogue actuel ne donne pas
ces effectifs : `composition_pending` signale cette absence ; `capacity_limit` est
une contrainte transmise au futur compositeur, pas une preuve que le groupe est
matérialisé. Avec les tags actuels, plusieurs alternatives sont incompatibles : elles
sont exclues plutôt que placées dans une salle non prévue pour leur formation.

`encounter_report` est ajouté au rapport final : quota, sélection, soulagement,
erreurs et `physical_spawn_pending`. Cette tranche produit des plans uniquement.
Le planner de base reste indépendant de l'état global de Rémanence ; le wrapper
runtime dépend aussi des cicatrices et entités mémorielles courantes.

Restent : groupes d'ennemis référencés et matérialisation des rencontres, événements,
butins, scènes physiques manquantes, connexion de l'exploration jouable au plan.
Aucune affirmation de générateur jouable complet ne découle de ces tests.

Validation locale du 3 octobre 2026, Godot 4.7.2 : import sans erreur de script ;
pipeline étendu 1 000 plans PASS ; wrapper runtime 80 cas + 1 000 graines PASS ;
17 tests Python de données/génération PASS. La fermeture du projet complet signale
encore des instances ObjectDB et trois ressources en usage. Les trois ressources
sont également signalées sur le worktree bc28beb non modifié : défaut préexistant,
pas une validation de propreté complète du projet.

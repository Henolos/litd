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
suivantes. La deuxième tranche ci-dessous sélectionne désormais les définitions de rencontres
dans le runtime, après la Rémanence. La matérialisation des ennemis, les événements
et le butin restent à brancher. Les modules physiques restent
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


## Deuxième tranche — sélection des rencontres

`FirstAccordHybridRuntimePlan.build` applique la Rémanence, valide le plan décoré,
puis appelle une méthode pure ajoutée au `VeilleursEncounterDirector` existant.
Son ancien chemin de génération des 64 templates demeure inchangé. Le directeur
copie le plan, filtre les candidats puis sélectionne selon leurs poids avec la graine
encounter de la salle. Les IDs triés stabilisent le résultat si la table est réordonnée.
La profondeur des branches reflète désormais celle du point d'attache réel.

Contraintes appliquées : budget authored de la bande de profondeur, poids positif,
blacklist contextuelle, nombre d'emplacements déclaré, capacité de l'ancre et maximum
quatre ennemis (R1–R4). `required_formation_tags` exprime des contraintes physiques
strictes ; `formation_tags` reste une description tactique et n'impose pas à elle seule
un filtrage. Le boss est imposé, hors budget normal, sur son ancre d'un emplacement.
Entrées, repos, sorties et secrets sont exempts de rencontres. Le quota critique
compte les quatre rencontres protégées et le boss. Une table vide reste autorisée
pour une salle sans rencontre ; une table critique sans candidat valide produit un
repli authored, avec le rapport d'échec conservé.

Les seuils de blessures/ravitaillement déjà présents dans les données ne suppriment
que les rencontres optionnelles, si `injury_pressure` ou `supplies_ratio` sont fournis
par l'appelant. Aucune lecture implicite de la puissance de l'équipe, aucune modification
des PV/dégâts et aucune mutation des métadonnées Rémanence/Némésis.

Les tailles 2/3/4 des groupes déclarent les emplacements réservés dans les tables
Premier Accord ; elles ne définissent pas encore une composition de combattants.
Chaque sélection porte `materialization_status: definition_only`. Les identifiants
Premier Accord ne possèdent pas encore tous des compositions d'ennemis : aucun acteur
n'est créé et aucune rencontre jouable supplémentaire n'est annoncée. Les scènes
physiques et l'appel depuis l'exploration restent les prochaines intégrations.

`encounter_report` et `generation_report.encounters` exposent, pour chaque salle,
les candidats éligibles, les rejets, la décision et les comptes finalisés.

Sources primaires complémentaires :
- https://dev.epicgames.com/documentation/en-us/unreal-engine/environment-query-system-overview?application_version=4.27
- https://docs.godotengine.org/en/4.4/classes/class_randomnumbergenerator.html

Validation du 3 octobre : 1 000 plans de rencontres, contraintes et repli runtime ;
pondération 1:9 sur 10 000 tirages ; 1 080 plans Premier Accord ; ancien smoke
Veilleurs v0.6.1 ; 27 tests Python ciblés. Les résultats CI de la première tranche
sont tous PASS (16 workflows) ; les contrôles du nouveau commit doivent être relancés.

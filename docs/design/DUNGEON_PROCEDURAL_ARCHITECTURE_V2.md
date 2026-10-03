# Architecture procédurale intégrée v2 — Premier Accord

Base inspectée : `Henolos/litd`, main `5b06d64f` (PR #522 incluse).
Entrée conservée : `FirstAccordHybridRuntimePlan.build(run_state)`.
Le format du graphe reste v1 ; la version du générateur dans le rapport est v2.

## Réutilisation de l'existant

| Étape | Implémentation | Source |
| --- | --- | --- |
| Seed déterministe | `DungeonRunSeed` existant | campagne, donjon, visite, difficulté, époque, tentative |
| DungeonProfile | normalisation de `hybrid_generation_rules.json` et des overrides du donjon | aucun second catalogue |
| FlowGenerator | `scripts/world/hybrid_dungeon_generator.gd` existant | graphe abstrait, pas de géométrie nouvelle |
| Chemin critique | `validate_graph` + domination des salles protégées, avant résolution des modules | contraintes authored |
| RoomResolver | extraction des méthodes existantes vers `DungeonRoomResolver` | `first_accord_module_library.json` |
| Encounter Director | `VeilleursEncounterDirector.populate_dungeon_plan` existant | tables Premier Accord après Rémanence |
| Event Director | `DungeonEventDirector` | variantes, lore et ressources des modules existants |
| Validation finale | `FirstAccordHybridRuntimePlan.validate_final` | structure, profils, rencontres, ancres, variantes, graines |

Les autres générateurs déjà présents (`scripts/core/hybrid_dungeon_generator.gd`,
les slices v06/v07 et leurs bridges) restent utilisés par leurs consommateurs.
Aucun nouveau point d'entrée concurrent, autoload, catalogue ou runtime de combat
n'est ajouté. La bibliothèque narrative et la bibliothèque d'inspirations demeurent
les sources de conception ; elles ne deviennent pas des tables de contenu jouable.

## Profil et chemin protégé

Les bornes des profils sont validées avant tout tirage : tableaux de deux entiers,
valeurs finies, non négatives, ordonnées, limite de 1 000, taille compatible avec
les salles obligatoires. Les nombres JSON sont normalisés en entiers. Un profil
inconnu est rejeté, plutôt que substitué implicitement par medium.

Premier Accord déclare explicitement `critical_length: [6,6]`, conformément à ses
six salles narratives protégées. Le reste du profil medium reste à 13–19 salles,
1–2 boucles et 1–2 secrets. Le planner conserve les salles générées, puis reconstruit
le nombre validé de boucles en rejoignant seulement la salle protégée suivante.
Le compteur final est dérivé des arêtes réelles : des compteurs périmés ne peuvent
pas valider un graphe. Les secrets ne sont jamais nécessaires et ne contournent
pas les salles protégées. Un verrou sur le seul passage obligatoire est rejeté.
Le raccourci de retraite profonde doit réellement exister, être visible et se
réouvrir depuis le côté profond ; un simple drapeau retreat ne suffit pas.

## Salles, rencontres et événements

La résolution de salles conserve les pools, leurs poids et les deux fallback pools
explicitement déclarés dans #522. Elle trie les pools/modules par ID avant tirage,
exclut les poids non finis ou désactivés, exige des connecteurs déclarés et un biome
commun avec le donjon. La validation rejette aussi les IDs de modules dupliqués.
Les méthodes historiques du planner délèguent au resolver pour compatibilité.

Le directeur de rencontres garde le budget de profondeur authored, les réservations
de quatre rangs maximum, la capacité et les tags stricts de l'ancre, les salles
sûres, le boss fixe et le soulagement des rencontres optionnelles. Une validation
indépendante relit les sélections finales : définition exacte, quota critique,
boss unique, ancre, capacité, budget et graine. Elle ne reroule pas le plan et ne
fait pas confiance à son rapport. Rémanence et métadonnées Némésis sont conservées.

Le directeur d'événements choisit une variante autorisée par slot, avec un flux
isolé par salle et slot. L'ordre du catalogue, des slots et des variantes n'affecte
pas le résultat. Lore et ressources restent des réservations des ancres existantes,
sans inventer un objet ni accorder un butin. Une sélection d'événement ne modifie
ni les arêtes ni l'état de combat. Les stages travaillent sur des copies.

## Rejeu et limites de production

Le rapport contient la version du générateur, la version Godot, les graines, les
stages exécutés, le run_state, sept SHA-256 des données et une empreinte des entrées
logiques Rémanence/Némésis de la campagne chargée. `replay(report)` exige les mêmes
versions, données et campagne chargée, reconstruit puis compare le rapport complet.
Il refuse explicitement les divergences. Aucune mutation de sauvegarde ou snapshot
de scène n'est introduit. La graine ne garantit pas la compatibilité entre versions
Godot, conformément à sa documentation officielle.

Cette intégration produit des **plans validés de définitions**. Les compositions
Premier Accord, scènes de modules encore absentes, application des variantes dans
le monde et distributions de butin restent des intégrations de contenu distinctes.
L'exploration physique authored conserve son générateur actuel : aucun plan abstrait
n'est présenté comme une nouvelle carte navigable ou un combat jouable.
Les rangs, cibles anatomiques, afflictions, compétences et statistiques de combat
ne sont pas modifiés par cette PR.

## Validation

- Nouveau smoke : 1 000 plans complets reproduits, profils finaux, ordre des données,
  validité des événements, corruption du graphe, rencontres, graines et retraite.
- Rejeu du rapport et rejet de données/campagne différentes.
- Smokes existants : 1 000 plans de modules, 1 000 plans de rencontres,
  200 graphes + 100 plans, 80 cas Premier Accord + 1 000 stress seeds.
- Tests Python : 1 428 PASS, 47 sous-tests PASS.
- Cinq domaines Godot exécutés ; le domaine Veilleurs est relancé sur les ajouts finaux.
- Contrats ciblage, anatomie et synergies exécutés ; afflictions et résolveurs de
  combat sont lancés par scènes afin de compiler avec les autoloads du projet.
  La scène d'autorité du ciblage retourne désormais après quit(0), pour ne pas
  écraser son résultat avec quit(1). Ces contrats rejoignent le domaine CI strict.
- Le workflow Combat Sandbox se déclenche aussi pour les fichiers du générateur.

Les warnings de ressources à la fermeture sont observés sur le projet existant ;
ils ne sont pas masqués et le filtre strict GDScript du runner reste inchangé.
La CI distante doit confirmer le commit proposé avant toute fusion.

Sources primaires :
- https://docs.godotengine.org/en/4.7/classes/class_randomnumbergenerator.html
- https://github.com/godotengine/godot-docs/blob/master/tutorials/math/random_number_generation.rst

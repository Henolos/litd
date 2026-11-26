# ARCH-12 — audit de liaison des oracles au runtime

Date : 26 novembre 2026  
Statut : constat technique en lecture seule; aucun mécanisme de jeu modifié.  
Base examinée : main à e9be0c5959077d748793d68b275fee5d1cc75aaa.  
Document maître : blob e791e4d0bd1a21b8202a75eb18053d9deef3b35d.  
Spécification candidate : branche docs/arch12-test-spec-readiness-20261126, blob f6836df7ec43358f1d33bbccac02ec43515ce12919.

## Conclusion exécutive

Le dépôt contient une tranche jouable LITD 1 avec combat 2D provisoire, mais aucun runtime ARCH-12 approuvé n’a été identifié. La tranche ne conserve que les PV, des actions d’attaque/garde et un journal d’affichage court. Elle n’expose ni attribution causale, ni Némésis, ni invocations, ni recrutement, ni Archives, ni historique persistant des événements.

Par conséquent, **0/39 oracles O sont actuellement exécutables comme scénarios fonctionnels ARCH-12 sur un runtime approuvé**. Les 31 oracles P demeurent conditionnels et ne sont pas transformés en assertions. Aucun des cas ni aucune règle n’est modifié par ce constat.

## Cibles examinées

| Élément | Révision | Constat |
|---|---|---|
| Document maître | main, blob e791e4d0bd1a21b8202a75eb18053d9deef3b35d | Source des décisions ARCH-12 à ARCH-12.5. |
| Projet Godot | project.godot, blob f925c98892bdc8613d59960b8f5df03cfe72dfce | Projet LITD 1, scène principale du hub; aucune intégration ARCH-12 déclarée. |
| Boucle prototype | scripts/prototype/litd1_node_map_loop.gd, blob a93abd36ccdfce46313e8f04995f9ba1b813d5ab | Tranche explicitement provisoire; combat et fixtures de démonstration. |
| Définition du prototype | docs/reconstruction/LITD1_NODE_MAP_LOOP_PROTOTYPE.md, blob 9871315ee3383e63e30c59df425c48fbc0926f40 | Indique que PV/dégâts ne sont pas approuvés, et que campagne, recrutement et Game Over ne sont pas raccordés. |
| Données de rencontre | data/prototypes/litd1_node_map_loop.json, blob ebaee2d9704da0dfc3dd9b92a5fc310dffb73a4e | Statut explicite : fixture de tranche jouable, pas runtime de campagne. |
| Test de scène | tests/godot/test_litd1_node_map_loop.gd, blob 7595838291477e6776f80ca0a39958a5823c10ec | Teste la boucle guilde/carte/combat, garde, attaque, victoire, revisite et retour; n’asserte pas ARCH-12. |
| Runner Godot CI | tools/build/run_godot_ci.sh, blob e87f4178414c30b24cd71a95e44fe5877dfb61d8 | Les commandes directes couvrent compilation, fondation technique et stockage; le fichier ne lance pas test_litd1_node_map_loop.gd. Il ne lance aucun scénario ARCH-12. |

Les recherches de l’arbre Git complet (2 095 chemins), des scripts GDScript et des termes de résolution causale/Némésis n’ont pas révélé de runtime ARCH-12 ni d’API de test correspondante. Le répertoire Unreal trouvé dans le dépôt porte LITD2 et n’est pas substitué au runtime LITD 1.

## Runtime historique fusionné : repère uniquement, exclu de la cible courante

Une recherche complémentaire a retrouvé un système plus complet que les prototypes : la PR #160 « Implémenter la Rémanence persistante des Veilleurs » a bien été fusionnée (merge commit `70741133c77f9cc1703a39e305a28f1548aa689a`). Les fichiers `scripts/core/remanence_runtime.gd`, `remanence_combat_bridge.gd` et `veilleurs_tactical_combat_runtime.gd` sont lisibles à cette révision historique. Les trois chemins renvoient 404 sur `main` au SHA de base actuel : ils ne constituent donc pas un runtime utilisable en l’état sur la branche de production courante.

**Interfaces réelles observées à la révision historique :**
- Le runtime tactique expose `setup_first_combat`, `resolve_skill`, `enemy_step`, `serialize` et `deserialize`; il utilise des `entity_id` stables, un `action_log`, et un tir déterministe fondé sur les identifiants et le round. Le résultat d’une action contient acteur, cible, compétence, dégâts et état corporel.
- `RemanenceRuntime` expose `record_event`, `entity_state`, `recent_events`, `serialize` et `deserialize`, avec une timeline séquencée et les liens d’Archives.
- Le bridge de Rémanence est cependant couplé à des singletons de l’ancienne architecture et détecte certains changements par scrutation. Lorsqu’un héros tombe, il attribue l’événement au dernier acteur ennemi signalé, avec repli sur le premier ennemi vivant. Ce n’est pas une chaîne de causalité complète avec liste de contributeurs.
- Le test smoke historique couvre rencontres, mutilation, survie/retraite, mort laissant un cadavre persistant, réapparition, adaptations et sérialisation. Il ne couvre pas les 39 oracles O ARCH-12 et n’est pas une preuve de conformité à la version actuelle des règles.

**Garde-fou utilisateur :** ne rien reprendre de ce qui a été supprimé de `main` pour la remise à zéro. En conséquence, l’implémentation #160 est exclue des cibles, bases de portage et sources d’architecture pour la suite. Elle reste citée uniquement comme preuve historique de l’existence d’un runtime antérieur et de son retrait. Aucune de ses interfaces, données ou règles ne sera réintroduite. Aucun fichier supprimé n’est restauré ou adapté.

Cela distingue désormais trois catégories : ancien runtime fusionné mais explicitement exclu par la remise à zéro; prototypes présents ou proposés mais provisoires; aucun runtime courant approuvé couvrant ARCH-12.

## Candidate historique examinée après la première passe

La recherche a été étendue aux branches et aux PR, et non limitée à `main`. Une candidate LITD 1 existe dans la PR brouillon #616, branche `feat/litd1-combat-prototype-20261112`, head `6989c08621c7b40cb23f88ad23125cd0c7d0cbe0`. Elle reste ouverte, non fusionnée et explicitement décrite comme une expérience jetable de Combat A; elle demande encore une décision issue du playtest avant de construire Combat B.

- **Injection actuellement possible dans le prototype :** appeler `start_encounter()`, `select_target(index)`, `attack()` et `guard()` sur la scène. Le test headless instancie la scène, appelle ces méthodes, puis lit directement les dictionnaires `heroes`/`enemies`, `actor_index`, `phase` et les PV. Ce sont des points de commande propres à cette expérience, pas un contrat d’injection ARCH-12.
- **Observation actuellement possible :** états en mémoire (PV, garde, acteur, phase) et `log_lines`. Les adversaires sont anonymes et n’ont pas d’identifiants stables; le journal tronque son historique à sept messages. Le test confirme les dégâts ciblés, la garde, les ripostes, la victoire et le redémarrage.
- **Capacités absentes :** événement causal structuré, auteur/contributeurs, liens parent-enfant entre effets, état de maître à l’instant de l’action, résolution ARCH-12 du décès, Némésis, Archives, snapshots persistants, sauvegarde/rechargement, contrôle déterministe de l’horloge ou de l’aléatoire.
- **Décision de liaison :** candidate rejetée comme runtime ARCH-12 approuvé. Le prototype pourrait servir d’essai UX ou de source de commandes de test, mais l’étendre pour lui faire porter ces règles créerait un moteur parallèle aux fixtures et violerait son périmètre déclaré. Aucun code ni aucune règle de cette PR n’a été modifié.

Ce résultat précise la recherche précédente : une expérience de combat candidate existe dans une branche de travail, mais aucun runtime de production ou runtime approuvé conforme aux besoins ARCH-12 n’a été trouvé. La conclusion reste donc **0/39 O raccordables à une cible approuvée**.

## Liaison des oracles O

Les 39 scénarios O sont regroupés ci-dessous par dépendance technique. Dans chaque ligne, « non raccordable » signifie qu’un contrôle de la seule tranche prototype ne pourrait pas vérifier l’oracle attendu. Une animation de PV à zéro ou un texte de journal n’est pas une preuve d’attribution ARCH-12.

| Scénarios O | Capacités requises par l’oracle | État des éléments examinés | Liaison |
|---|---|---|---|
| S01–S06, S15, S17, S20–S25, S27–S28 | Attribution d’une mort; afflictions persistantes/neutralisées; déplacement forcé; environnement sans auteur; égalité causale; contributeurs; statuts antérieurs; persistance | Le prototype baisse des PV et journalise les attaques; il n’implémente pas ces règles, leurs sources d’événements ou leur stockage. | Non raccordable |
| S29–S31, S34, S38, S41–S44 | Invocation comme auteur physique, maître à l’instant de l’action, transferts, effets persistants, disparition/révocation et absence de double attribution | Aucun système d’invocation ni historique de maîtrise identifié. | Non raccordable |
| S48–S51, S54 | Recrutement, reconnaissance historique, absence de bonus/promotion et identité unique | Le document de prototype exclut explicitement le recrutement; aucune fiche d’Archives/identité correspondante dans ce runtime. | Non raccordable |
| S57–S62, S67–S69 | Snapshot au décès, reconnaissance posthume, listes de victimes, absence de résurrection/récompenses, historique sans doublon et déterminisme | Le prototype n’a ni persistance de campagne ni système d’Archives; son journal conserve au plus sept lignes d’affichage. | Non raccordable |

**Bilan : 39 O spécifiés; 0 raccordé au runtime; 0 exécuté.** Les traces de combat du prototype peuvent servir d’exemple d’interface provisoire, mais ne sont pas réutilisées comme source d’oracles ni comme preuves fonctionnelles.

## Pourquoi le prototype n’est pas le runtime d’exécution retenu

La documentation du prototype le décrit comme un test de parcours à fixtures anonymes. Elle précise que les valeurs et actions ne sont pas approuvées, que la sauvegarde de campagne, le recrutement et le Game Over ne sont pas raccordés. Le code se contente de réduire les PV et d’ajouter des chaînes à un journal visuel; il ne conserve pas l’auteur causal, les contributeurs ou un événement de mort durable.

Le faire évoluer en banc ARCH-12 supposerait d’ajouter une architecture de provenance, un moteur d’états et des hooks qui ne sont pas présents. Ce serait créer une implémentation parallèle et pourrait faire passer des règles provisoires pour la conception réelle. Aucun changement de ce type n’est effectué ici.

## Conditions nécessaires à la liaison ultérieure

Avant d’écrire un adaptateur ARCH-12, il faut identifier ou approuver le runtime cible, puis vérifier que le système réel permet :
1. d’injecter des événements de fixture avec identifiants stables;
2. d’observer acteur physique, maître/faction au moment de l’action, cible, cause parent et chaîne d’effets;
3. d’observer la résolution du décès, les contributeurs, le principal éventuel, l’état Némésis et les Archives;
4. de contrôler ou figer le temps, l’ordre des événements et l’aléatoire pour les cas déterministes;
5. de sauvegarder, recharger et comparer les états pertinents sans confondre reprise technique et résolution de conception.

Ces éléments sont des prérequis d’observabilité du banc, pas des décisions nouvelles de gameplay. Si le runtime approuvé ne fournit pas ces interfaces, préparer une instrumentation de test dans le runtime lui-même après validation de son architecture; ne pas émuler le comportement manquant dans le validateur.

## Séparation des cas O, P et décisions ouvertes

- **O** : les résultats attendus déjà déterminés restent des attentes de spécification. Ils ne sont pas convertis en tests réussis tant qu’un runtime approprié n’existe pas.
- **P** : conserver leurs préconditions et paramètres ouverts; ne pas relier les cas conditionnels à un comportement de prototype.
- **D / décisions ouvertes** : aucune valeur, pondération, seuil ou règle de départage n’est ajoutée. Les points ouverts ne bloquent pas les contrôles documentaires qui ne les utilisent pas, mais interdisent de figer les oracles concernés.

## Prochaine étape et preuve attendue

La recherche des branches et PR a trouvé #616, mais son prototype est disqualifié comme cible ARCH-12 pour les raisons ci-dessus. La prochaine étape est donc une décision d’architecture : approuver explicitement un futur runtime de combat LITD 1 qui portera ARCH-12, ou identifier une autre cible de production déjà autorisée. Cette décision n’est pas déduite de la PR #616. Une fois la cible déterminée et approuvée, vérifier ses hooks réels avant d’écrire l’adaptateur.

La preuve de liaison devra associer au même commit le runtime, l’adaptateur, les fixtures, les journaux d’exécution et les résultats par scénario. La CI générale, le test de boucle provisoire et le modèle de référence abstrait ne remplaceront pas ces preuves.

# Audit transversal borné — Persistance et évolution du monde

28 novembre 2026 — cycle 1, révision 97101f092a77ee23ddad3ab5abc300ff16c99f57.

## Périmètre et clôture
160 règles PER/TEM/ECO/DEP/RES/STR/EVT/SIM, cohérence avec décisions antérieures, intégrité documentaire. Trois cycles maximum : identification, correction et vérification, décision finale. Clôture documentaire conditionnée à la résolution des contradictions bloquantes, traçabilité des réserves et contrôles CI applicables réussis sur la révision finale. Aucun test runtime ni autorisation d'implémentation.

## Preuves du cycle 1
Relecture après écriture exacte ; contrôle par extraction regex des identifiants : 160 uniques, aucun manquant ni inattendu, ordre conforme. CI EVT 46134024085 et six autres workflows réussis sur d3308c1f3c36f033e9c44c672c7231d88e4f2320. Sept workflows SIM en cours lors de la consultation, CI 46138568751. Ces résultats ne prouvent pas la sémantique ni le gameplay.

## Constats initiaux
- AUD-PER-01 (majeur documentaire) : V5.1 conserve la clause de renouvellement par nouvelle mission, remplacée par ARCH-02. Clarifier la préséance sans effacer la provenance.
- AUD-PER-02 (majeur documentaire) : V5.1 laisse ouvertes les modalités temporelles au hub et hors connexion désormais tranchées par TEM-05 à TEM-15 ; durées numériques ouvertes.
- AUD-PER-03 (majeur, ambiguïté) : SIM-15 ne doit pas effacer les identités persistantes exigées par PER-09, ECO-07/08 et SIM-08. Représentation collective uniquement si aucune identité individuelle nécessaire n'est perdue.
- AUD-PER-04 (modéré, articulation) : TEM-01/13/14/16 ; horloges dimensionnelles compatibles avec chronologie mondiale, conversion et paramètres non décidés.
- AUD-PER-05 (modéré, articulation) : TEM-18, EVT-08/09/17, SIM-10/11/16/17 ; traitement par lots sans changement causal ni répétition.
- AUD-PER-06 (modéré, articulation) : DEP-02/09, PER-10, ECO-07, ARCH-10 ; réanimation hostile distincte de résurrection et recrutement du héros décédé.

Constats initiaux non exhaustifs. Reste à examiner les interactions restantes et les contrats de sauvegarde, retour, recrutement, génération et ressources avant clôture du cycle 1. Les clarifications ci-dessus sont des déductions proposées, non des règles nouvelles validées. Aucun contrôle indépendant spécifique ni test de simulation exécuté.

## Fin du cycle 1 — revue documentaire des 28 couples

Chaque ligne constate une articulation conceptuelle ; aucun test comportemental effectué.

| Couple | Références | Invariant attendu |
|---|---|---|
| PER/TEM | PER-02/15/20; TEM-15/19/20 | Pas de reset ni progression hors ligne |
| PER/ECO | PER-09/10/12; ECO-07/08/18 | Identité et renouvellement admissible |
| PER/DEP | PER-03/06/07; DEP-02/11/20 | Mort et possession conservées |
| PER/RES | PER-08/15; RES-13/18/20 | Pas de duplication de ressources uniques |
| PER/STR | PER-18/20; STR-16/17/18 | Transformations et accès conservés |
| PER/EVT | PER-01/16/20; EVT-04/11/20 | Conséquences causales persistantes |
| PER/SIM | PER-09/17; SIM-08/15/19 | Abstraction sans perte d'identité |
| TEM/ECO | TEM-17/18; ECO-18/20 | Temps seul insuffisant pour renouveler |
| TEM/DEP | TEM-16/20; DEP-17/20 | Décomposition sans nouveau tirage |
| TEM/RES | TEM-15/17; RES-02/06/18 | Horloge applicable et réserves |
| TEM/STR | TEM-16/18; STR-02/03 | Échéances et causes des changements |
| TEM/EVT | TEM-14/16/18; EVT-05/09 | Horloges et ordre causal |
| TEM/SIM | TEM-19/20; SIM-09/10/16 | Actualisation sans avance supplémentaire |
| ECO/DEP | ECO-04/13; DEP-06/07/17 | Consommation et déplacement compatibles |
| ECO/RES | ECO-03/16; RES-08/16 | Ressources liées aux populations |
| ECO/STR | ECO-10/11/12; STR-06/13 | Repaires et reconstruction contextualisés |
| ECO/EVT | ECO-14/15; EVT-07/11 | Événements et équilibres régionaux |
| ECO/SIM | ECO-07/08/17; SIM-14/15 | Pas de réapparition par agrégation |
| DEP/RES | DEP-10/11; RES-08/14 | Butin et ressources animales distincts |
| DEP/STR | DEP-19/20; STR-16/17 | Pas de suppression arbitraire des dépouilles |
| DEP/EVT | DEP-17/20; EVT-08/11 | Transformation causale des corps |
| DEP/SIM | DEP-18/20; SIM-08/11 | Persistance des corps et détenteurs |
| RES/STR | RES-07/15; STR-02/16 | Nouveaux accès aux gisements justifiés |
| RES/EVT | RES-15/20; EVT-04/14 | Approvisionnement admissible |
| RES/SIM | RES-17/20; SIM-11/18 | Quantités préservées lors des transitions |
| STR/EVT | STR-02/18; EVT-08/15 | Transformation valide et causale |
| STR/SIM | STR-18/20; SIM-12/19 | Actualisation validée ou reprise sûre |
| EVT/SIM | EVT-17/20; SIM-10/11/16/17 | Ordre, bornes et résolution unique |

Six constats initiaux traités par REC-PER-01 à 06 ; REC-PER-07 à 09 explicitent recrutement, cartes et sauvegarde. Réserves techniques : paramètres, conversion des horloges, conservation des identités agrégées, reprise atomique et budgets à tester avant implémentation. Cycle 1 clos au périmètre documentaire des couples ; cycle 2 engagé. CI de la révision 5bfc151 : sept workflows réussis, CI 46138609451. Les corrections suivantes nécessitent leurs propres contrôles.

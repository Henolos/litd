# LITD 1 — Guilde : hub illustré interactif (décision validée)

Date de validation utilisateur : 2026-11-22
Statut : **VALIDÉ pour le mode de navigation et la conservation de la planche architecturale** ; agencement interactif, interfaces et comportements détaillés : **propositions à tester**.

## Décision ferme
- La Guilde utilise un **hub illustré interactif**, inspiré de la navigation par lieux de Darkest Dungeon, et **non un hub 3D librement explorable**.
- **Conserver sans modification la planche architecturale déjà validée** : bâtiment sino-gothico-dark fantasy, trois niveaux conceptuels, espaces fonctionnels, ambiance noire/bordeaux/or.
- La vue générale du bâtiment sert de carte illustrée interactive. La sélection d'une zone ouvre une scène illustrée, le portrait du PNJ, les dialogues et les services associés.
- Cette décision ne remplace **pas** l'exploration 3D isométrique prévue hors de la Guilde ni les combats 2D.
- Les planches et portraits des six personnages restent leurs références officielles. Ne pas régénérer les personnages existants.

## Zones et responsables
| Zone | Personnage | Service envisagé |
| --- | --- | --- |
| Hall principal / tableau des contrats | Maître de la Guilde (interventions scénarisées) | annonces, départs, événements et quêtes |
| Administration | Kélia Anzora | contrats, rangs, primes, dossiers |
| Recrutement | Lian Yue | compagnie, recrutement, histoires des aventuriers |
| Commerce | Soleyman | achat/vente, équipement, relations et améliorations |
| Entraînement | Maîtresse d'armes (nom non fixé) | apprentissage, techniques, évaluation |
| Archives | Wei Shan | codex, bestiaire, histoire, documents |
| Bureau du maître | Maître de la Guilde | dialogues et événements spécifiques |
| Espaces complémentaires | aucun responsable fixé | repos/préparation, logistique, cour intérieure |

Les trois niveaux sont une **organisation architecturale illustrée**, pas trois scènes 3D obligatoires. Les lieux accessibles et leur placement exact sur la carte interactive restent à définir.

## Parcours minimal (proposition)
1. Arrivée à la vue générale de la Guilde avec lieux sélectionnables et indications de disponibilité.
2. Sélection d'un lieu : transition courte vers son illustration dédiée.
3. Affichage du PNJ, du dialogue contextuel et des services autorisés par la progression.
4. Retour direct à la carte de la Guilde, sans déplacement 3D.
5. Raccourcis vers compagnie, équipement, journal et départ en expédition, sous réserve de cohérence avec l'interface existante.

## Prologue : exigences narratives
- Présenter et caractériser les trois compagnons avant « La cueillette ».
- Lian Yue accueille la compagnie ; Kélia enregistre le rang S ; Soleyman prépare les équipements ; la maîtresse d'armes peut introduire l'entraînement ; Wei Shan peut introduire les archives/codex.
- **Ne pas révéler** avant le retour de « La cueillette » que S signifie « Stagiaire », ni la raison de l'omelette.
- Après la perte des trois compagnons, adapter dialogues, portraits contextuels et présence dans les illustrations pour marquer leur absence.
- Conserver les deux secrets distincts du maître et de l'origine de la Guilde.

## Architecture technique visée (non implémentée)
- Données de zones (identifiant, illustration, PNJ, services, conditions d'accès, badges d'événements).
- Contrôleur d'écran de Guilde ; sélecteur de lieux ; vue de lieu ; adaptateur vers dialogues, quêtes, inventaire, recrutement et sauvegarde **existants**.
- Support souris, clavier et manette ; navigation accessible et retour cohérent.
- Aucune duplication du système de quêtes, de sauvegarde ou de dialogue sans inspection des consommateurs réels.
- Les images finales doivent être transférées dans GitHub, comparées aux SHA-256 et testées dans Godot avant toute affirmation d'intégration.

## Plan d'exécution
1. Auditer les scènes, scripts, systèmes UI, dialogues et sauvegarde déjà présents.
2. Dessiner la carte interactive sur la planche architecturale validée ; identifier les zones et leurs états.
3. Prototyper un **parcours vertical minimal** : carte → Kélia → dialogue → retour carte.
4. Ajouter les autres lieux, puis les interactions et la progression narrative.
5. Tester dans Godot : résolution, clics, manette, accès, états de quête, sauvegarde, performances.
6. Faire valider visuellement les écrans et fusionner seulement après contrôles.

## Limites de validation
Ce document enregistre une décision de conception. Il ne prouve ni la présence des binaires de la planche architecturale dans GitHub, ni l'existence d'un hub illustré jouable, ni le succès de tests Godot.

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
| Taverne de la Guilde | Tavernier ou tavernière à créer | rencontres, rumeurs, événements, compagnons et missions informelles (services détaillés à définir) |
| Infirmerie de la Guilde | Médecin à créer | soins, récupération, séquelles et éventuelles quêtes médicales (mécaniques à définir) |
| Espaces complémentaires | aucun responsable fixé | repos/préparation, logistique, cour intérieure |

La taverne et l'infirmerie font désormais partie du périmètre du hub principal, décision ajoutée à la demande de l'utilisateur. Leur position architecturale, leurs personnages responsables et leurs mécaniques précises restent à concevoir. La planche architecturale précédemment validée est conservée comme référence : son extension doit faire l'objet d'une planche complémentaire ou d'une nouvelle validation, sans altérer l'original.

Les trois niveaux sont une **organisation architecturale illustrée**, pas trois scènes 3D obligatoires. Les lieux accessibles et leur placement exact sur la carte interactive restent à définir.

## Parcours minimal (proposition)
1. Arrivée à la vue générale de la Guilde avec lieux sélectionnables et indications de disponibilité.
2. Sélection d'un lieu : transition courte vers son illustration dédiée.
3. Affichage du PNJ, du dialogue contextuel et des services autorisés par la progression.
4. Retour direct à la carte de la Guilde, sans déplacement 3D.
5. Raccourcis vers compagnie, équipement, journal et départ en expédition, sous réserve de cohérence avec l'interface existante.

## Prologue : exigences narratives
- Présenter et caractériser les trois compagnons avant « La cueillette », notamment via des rencontres possibles à la taverne.
- Prévoir un rôle narratif possible pour le médecin après le retour du prologue, sans imposer de mécanique de blessures non validée.
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

## Extension validée : le village comme hub principal (2026-11-22)
- **Village illustré interactif = hub principal du jeu** ; **Guilde illustrée = sous-hub central du village**.
- Deux planches distinctes : (1) vue interactive du village et de ses bâtiments/habitants ; (2) planche de la Guilde précédemment validée, conservée telle quelle et complétée pour taverne et infirmerie.
- Les autres bâtiments et personnages du village devront proposer dialogues, interactions et éventuellement quêtes ; **liste précise des bâtiments et services non validée**.
- Parcours cible : village → bâtiment → scène illustrée/dialogue/service → retour village ; Guilde → salle → interaction → retour Guilde/village.
- Les personnages de taverne et de médecine sont à créer. **Noms, âges, origines, apparences et histoire non validés** ; toute représentation générée reste un concept exploratoire, même si une planche affiche des noms.
- La maîtresse d'armes conserve un **nom non fixé** ; ne pas entériner les noms visibles sur des concepts générés.
- La planche architecturale originale validée ne doit pas être remplacée par un concept généré ultérieurement.
- Les deux planches devront faire l'objet de validations visuelles séparées avant intégration.

## Tavernier : ancien aventurier, cicatrices et affinité (validé le 2026-11-22)
- Le tavernier est un **ancien aventurier**. Son apparence doit comporter des **cicatrices visibles**, traces cohérentes de ses expéditions.
- Il raconte des **anecdotes de quêtes vécues**, de tonalités diverses ; certaines peuvent nourrir la connaissance du monde et annoncer des pistes narratives.
- Comme les autres PNJ importants, il dispose de **quêtes spéciales propres** et de **déblocages spécifiques conditionnés par l'affinité** avec le joueur.
- Les noms (dont « Han Lu »), âge, rang antérieur, compagnie d'origine, cicatrices exactes, secrets, récompenses et seuils d'affinité **ne sont pas encore validés**.
- Proposition non validée : échelonner anecdotes, confidences, missions et récompenses selon la confiance ; ne pas bloquer arbitrairement l'histoire principale derrière l'affinité.
- La planche graphique du tavernier doit être mise à jour pour montrer ce passé d'aventurier, sans altérer les autres personnages ni considérer une image de concept comme une ressource Godot intégrée.

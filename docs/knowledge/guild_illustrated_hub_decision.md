# LITD 1 — Guilde : hub illustré interactif (décision validée)

Date de validation utilisateur : 2026-11-22 ; décision d'exploration actualisée le 2026-11-23.
Statut : **VALIDÉ pour le mode de navigation du hub, la carte à nœuds d'expédition et la conservation de la planche architecturale** ; agencement interactif, interfaces et comportements détaillés : **propositions à tester**.

## Décision ferme
- La Guilde utilise un **hub illustré interactif**, inspiré de la navigation par lieux de Darkest Dungeon, et **non un hub 3D librement explorable**.
- **Conserver sans modification la planche architecturale déjà validée** : bâtiment sino-gothico-dark fantasy, trois niveaux conceptuels, espaces fonctionnels, ambiance noire/bordeaux/or.
- La vue générale du bâtiment sert de carte illustrée interactive. La sélection d'une zone ouvre une scène illustrée, le portrait du PNJ, les dialogues et les services associés.
- Le 23 novembre 2026, l'utilisateur a tranché la contradiction : **la carte à nœuds remplace entièrement l'exploration 3D**. Aucun espace 3D explorable n'est conservé hors de la Guilde.
- Les expéditions utilisent une grande carte à embranchements et nœuds ; le joueur peut revenir sur les nœuds déjà visités. Les combats restent tactiques, en 2D et au tour par tour. Les règles de génération des nœuds restent à spécifier.
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

Les trois niveaux sont une **organisation architecturale illustrée**, pas trois scènes 3D obligatoires. Les lieux accessibles et leur placement exact sur la carte interactive restent à définir. La carte d'expédition est une interface de progression distincte de cette carte illustrée du hub.

## Parcours minimal (proposition)
1. Arrivée à la vue générale de la Guilde avec lieux sélectionnables et indications de disponibilité.
2. Sélection d'un lieu : transition courte vers son illustration dédiée.
3. Affichage du PNJ, du dialogue contextuel et des services autorisés par la progression.
4. Retour direct à la carte illustrée de la Guilde, sans déplacement libre dans un espace 3D.
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
2. Dessiner la carte interactive de la Guilde sur la planche architecturale validée ; identifier les zones et leurs états.
3. Concevoir séparément la carte d'expédition à nœuds ; permettre de choisir un embranchement et de revenir aux nœuds déjà visités. La génération procédurale ou déterministe et les règles de progression ne sont pas encore décidées.
4. Construire le parcours vertical minimal : hub → carte à nœuds → rencontre/combat → retour au hub. Un prototype isolé est ouvert en PR #637 ; sa CI et sa revue visuelle restent à terminer.
5. Ajouter les autres lieux, puis les interactions et la progression narrative, en raccordant les systèmes seulement après validation de leurs contrats.
6. Tester dans Godot : résolution, clics, manette, accès, états de quête, sauvegarde, performances.
7. Faire valider visuellement les écrans et fusionner seulement après contrôles.

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

## Médecin de la Guilde — nouvelle validation utilisateur (2026-11-22)
- **Planche artistique de la médecin validée** (portrait, silhouettes et direction visuelle). Le nom affiché « Dr Mei Ling » figurait sur la planche validée ; conserver cette désignation comme référence de travail, sans inférer que tous les chiffres, biographies et mécaniques de la planche ont été approuvés.
- **Personnalité validée :** médecin hors pair, passionnée par la dissection et l'anatomie, avec une propension comiquement excessive à vouloir amputer même pour une coupure bénigne.
- **Rôle de gameplay souhaité et validé dans son principe :** ses missions peuvent améliorer le bestiaire, notamment en débloquant la connaissance des faiblesses des ennemis en récompense.
- **Propositions à valider :** types d'échantillons, niveaux de recherche, progression d'affinité, catégories précises de faiblesses/résistances, effets en combat, récompenses exactes et partage des données entre Wei Shan et la médecin.
- **Garde-fou de cohérence proposé :** les amputations disproportionnées relèvent surtout de l'humour noir et de la caractérisation, tandis que les actes médicaux effectifs restent fiables, sauf décision narrative explicite ultérieure.
- **État d'exécution :** spécification textuelle uniquement ; aucune modification des systèmes de bestiaire, aucun test Godot, aucun binaire graphique importé par cette mise à jour.

## Correction validée — placement de la création de personnage (2026-11-23)
La **cinématique d'ouverture précède** la création du héros ou de l'héroïne. Le créateur de personnage intervient **pendant l'inscription officielle comme aventurier à la Guilde**, avant la formation de la compagnie et la quête « La cueillette ». L'inscription peut servir de cadre narratif à l'interface ; l'intervention précise de Kélia reste une proposition. Préserver les révélations tardives sur le rang S et l'omelette.

## Règles actives après succession — source V8.3 (23 novembre 2026)

Les règles plus récentes du document maître V8.3 remplacent les formulations de ce fichier qui prévoyaient la reprise avec le même protagoniste et le partage du bestiaire uniquement par protagoniste.

- **Game Over :** après l'anéantissement des quatre combattants de l'expédition, la tentative prend fin et un nouveau protagoniste succède au précédent. La fréquence de répétition du prologue n'est pas fixée par cette décision; les épreuves de la Guilde précèdent la reprise des missions.
- **Persistance collective :** le monde, la trame narrative, les quêtes principales et les quêtes secondaires générales conservent leur état selon V8.1. Les connaissances collectives du bestiaire sont transmises par les archives de la Guilde.
- **Successeur :** il hérite du niveau numérique et des points de compétence correspondants, mais possède une nouvelle classe/identité et reconstruit sa maîtrise et ses choix personnels. Les emplacements passifs personnels sont à regagner conformément aux règles V8.2; ils ne sont pas automatiquement hérités.
- **Réserves et survivants :** les réservistes survivants conservent leur progression et restent disponibles selon les règles V8.1.
- **Bestiaire :** distinguer les connaissances collectives archivées et transmises du bestiaire de la maîtrise individuelle. La maîtrise personnelle du successeur est reconstruite; elle ne doit pas être confondue avec la conservation des connaissances collectives.
- **Portée technique :** ces règles sont validées en conception. Le modèle de données, le runtime et les tests de sauvegarde restent à réaliser et valider; ce document ne les certifie pas.

## Prototype de boucle à nœuds — état au 2026-11-23
La PR #637 fournit un parcours expérimental de démonstration depuis le hub de test vers une carte fixe, une rencontre 2D au tour par tour et un retour à la Guilde. Son test Godot headless passe localement ; la CI de la PR et une revue visuelle restent en attente. La route, les acteurs et les chiffres sont des fixtures. Le prototype ne raccorde ni le recrutement, ni la sauvegarde de campagne, ni la génération de cartes, ni le Game Over validé.

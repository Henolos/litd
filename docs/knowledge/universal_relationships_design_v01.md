# LITD 1 — Affinité universelle simplifiée V0.2

## Correction explicite du joueur
**Une seule barre par personnage** : l'affinité englobe la confiance. Pas de seconde jauge, pas de simulation de gestion sociale.

## Principes retenus
- Une valeur d'affinité unique par personnage (0 à 100 proposé, seuils non encore validés).
- Progression individuelle : quêtes, décisions importantes, interactions scénarisées.
- Cinq paliers provisoires ; les récompenses et les conditions restent propres à chaque PNJ.
- Un événement peut augmenter ou diminuer l'affinité selon les valeurs du personnage.
- Pas de diminution automatique en cas d'absence, ni de cadeaux quotidiens ou d'entretien répétitif.
- Pas de relations entre PNJ à gérer par le joueur.
- Les quêtes et événements accomplis sont des **états de progression du jeu**, pas une seconde jauge relationnelle.
- Une récompense peut nécessiter à la fois un palier d'affinité et l'accomplissement d'une quête ; aucun compteur de confiance séparé.
- Une relation négative ne requiert pas d'axe supplémentaire : l'affinité peut baisser et certaines scènes peuvent changer.
- Utiliser le SaveManager existant pour enregistrer le score et les événements déjà accomplis, sans système parallèle.
- Appliquer le moteur aux PNJ de Guilde, compagnons et habitants selon leurs besoins narratifs, sans imposer une mécanique sociale à tous.

## Exemples
- Han Lu : affinité acquise lors d'expéditions et de choix ; anecdotes, quêtes personnelles et récompenses.
- Mei Ling : affinité acquise par missions et choix ; recherches anatomiques enrichissant le bestiaire commun.
- Wei Shan : affinité acquise par découvertes et quêtes ; archives et révélations.
- Compagnons : réactions aux décisions et scènes marquantes, sans obligation de maintenance quotidienne.

## Retrait de la V0.1
La distinction chiffrée affinité/confiance, les relations orientées A→B, les paires de PNJ et le système de confiance indépendant **ne font plus partie du périmètre**. Le modèle V0.1 est remplacé par cette correction.

## État
Décision de conception enregistrée ; moteur Godot non implémenté et non testé. Valeurs numériques et paliers à confirmer.

## Principe narratif validé : l'attachement avant le butin (2026-11-23)
- Chaque personnage important doit avoir un **passé**, une **personnalité propre**, des **motivations**, des **contradictions**, des **relations au monde** et une **évolution possible**.
- Le joueur doit vouloir approfondir la relation pour le personnage lui-même, non uniquement pour le butin ou les bonus.
- Les dialogues, anecdotes, comportements et événements personnels doivent porter la progression ; les récompenses matérielles restent secondaires.
- Ne pas imposer de passé tragique universel : diversité des tempéraments, vies et situations.
- Avant d'écrire une biographie, **auditer les fiches, dialogues et décisions déjà présents** pour conserver les éléments validés et éviter les contradictions.
- Chaque personnage doit disposer d'une fiche de caractérisation distinguant : **canon validé**, **éléments existants à vérifier**, **propositions nouvelles**, **éléments ouverts**.
- Déployer la caractérisation par ordre de priorité narrative : les trois compagnons du prologue en premier pour rendre leur disparition marquante ; personnages majeurs de la Guilde ensuite ; habitants et personnages secondaires selon leur importance.
- Une seule jauge d'affinité par personnage demeure la règle ; la profondeur narrative n'ajoute aucune jauge ni routine de gestion sociale.
- Les confidences et changements de comportement doivent pouvoir constituer des récompenses narratives à part entière.

### Exemples non validés
- Tavernier : un épisode d'expédition qu'il évite d'évoquer malgré son humour habituel.
- Médecin : un événement ayant nourri sa passion pour l'anatomie, sans fixer pour l'instant son origine.

### Contrôle qualité des fiches
Vérifier pour chaque personnage : voix reconnaissable, au moins une contradiction crédible, motivation indépendante du joueur, cohérence avec l'univers, scène d'introduction marquante, évolution possible, réactions aux événements majeurs, absence de dépendance exclusive au butin.

## Principe directeur confirmé pour le document maître (2026-11-23)
**« Le personnage est la récompense principale de la relation. Le butin n'est qu'un complément. »**
Ce principe s'applique à la construction du passé, de la personnalité et de l'évolution de chaque personnage important. L'intérêt de progresser en affinité doit reposer principalement sur l'attachement, les découvertes narratives et les conséquences humaines, et non sur l'optimisation de récompenses.

## Chantier suivant : création du protagoniste
Décision antérieure à préserver : le joueur crée son héros ou son héroïne **après la cinématique d'ouverture**, lors de son inscription comme aventurier à la Guilde, avant l'intégration à la compagnie de quatre. Périmètre précis du créateur (apparence, identité, origine, classe, voix, pronoms, options de personnalisation) à concevoir et valider. Aucune implémentation n'est revendiquée.

## Ordre du prologue corrigé (décision utilisateur 2026-11-23)
Cinématique d'ouverture → arrivée à la Guilde → inscription comme aventurier et création du héros/héroïne → validation de l'inscription → formation de la compagnie → quête « La cueillette ». Les modalités d'inscription et le rôle exact de Kélia restent à préciser. Ne pas révéler le sens du rang S ni l'omelette avant le retour de quête.

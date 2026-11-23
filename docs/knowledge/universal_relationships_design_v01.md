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

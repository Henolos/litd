# LITD 1 — Système universel de relations : spécification V0.1

Statut : **proposition de conception structurée**, non validée définitivement et non implémentée dans Godot.
Périmètre : tous les PNJ, compagnons et relations entre personnages. Le moteur doit rester indépendant du hub et du bestiaire.

## Inspirations de conception
- Persona 5 : événements de rang et récompenses distinctives.
- Baldur's Gate 3 : réactions aux choix et conséquences relationnelles.
- Fire Emblem : soutiens entre compagnons.
Ces références sont des inspirations, non des règles copiées.

## Modèle canonique proposé
- **Identité** : ID immuable du personnage ; nom et portrait modifiables sans perte de progression.
- **Affinité** : 0..100, appréciation/attachement. Valeur initiale configurable par relation.
- **Confiance** : 0..100, propension à se confier, à coopérer ou à confier des responsabilités.
- **Progression narrative** : ensemble d'IDs d'événements accomplis, quêtes et étapes personnelles. Ne jamais inférer ces étapes des scores.
- **Relation orientée** : une relation A→B peut différer de B→A ; le héros est un acteur parmi d'autres. Ne pas calculer tous les couples de PNJ : instancier seulement les liens narrativement pertinents.
- **États qualitatifs facultatifs** : rivalité, respect, méfiance, dette, traumatisme, loyauté ; ne pas les réduire à un score unique.
- **Rangs d'affinité** : cinq paliers provisoires ; seuils à équilibrer. Un rang ne valide pas automatiquement une quête ni un secret.

## Événements et règles
1. Les variations proviennent d'événements identifiés : choix, aide, trahison, dialogue unique, mission, combat, conséquence narrative.
2. Chaque événement porte un ID stable, une cible, des conditions, des variations bornées et une politique de répétition (unique/par chapitre/répétable plafonné).
3. Les actions répétables ne doivent pas permettre de maximiser mécaniquement une relation sans contenu narratif.
4. Les relations ne décroissent pas automatiquement par absence ; une dégradation doit correspondre à une conséquence narrative explicite.
5. Les choix peuvent améliorer l'affinité et réduire la confiance, ou inversement.
6. Les réconciliations existent seulement si la fiction et les conditions du personnage le permettent.
7. Aucun personnage ne doit exiger que le joueur approuve systématiquement toutes ses opinions pour progresser.
8. Les événements peuvent affecter plusieurs relations, sans imposer un même effet à toutes.
9. Les personnages morts, absents ou indisponibles gardent leur historique ; leur disponibilité est une condition narrative, pas une suppression de sauvegarde.
10. Les récompenses de relation sont déclenchées par conditions explicites (rangs, confiance, quêtes, choix), attribuées une seule fois si uniques.

## Séparation des responsabilités
- **Définitions statiques** : personnages, profils de préférences, étapes, récompenses, règles de déclenchement.
- **État de campagne** : valeurs et événements par relation, journal des récompenses acquises.
- **Service d'événements** : applique des variations atomiques et vérifie les conditions.
- **Dialogue / quêtes** : émettent des événements ; ne modifient pas directement les scores.
- **Bestiaire** : reçoit des déblocages de connaissances issus de récompenses validées ; conserve son catalogue canonique.
- **SaveManager** : utiliser le snapshot existant ; ne pas créer de seconde sauvegarde.

## Cas pilotes
### Han Lu — tavernier
Anecdotes et confiance d'ancien aventurier, missions liées à ses expéditions, récompenses spécifiques. Nom provisoire. Les détails et seuils restent à valider.
### Mei Ling — médecin
Affinité et confiance distinctes ; missions anatomiques pouvant débloquer des faiblesses dans le bestiaire commun. Son humour noir sur les amputations caractérise ses dialogues ; aucune mutilation automatique liée à l'affinité.
### Wei Shan — archiviste
Révélations historiques et documentaires ; complémentarité avec les découvertes anatomiques de Mei Ling.
### Compagnons du prologue
Historique de relation préservé après leur disparition ; l'impact narratif ne doit pas dépendre d'une optimisation artificielle des scores.

## Cas limites à tester avant implémentation
- Événement reçu deux fois (idempotence).
- Sauvegarde/chargement sans duplication de récompense.
- Valeurs hors bornes, événement inconnu, personnage absent.
- Choix contradictoires et variations de signe opposé.
- Relation A→B distincte de B→A.
- Récompense conditionnée à une quête, même avec 100 d'affinité.
- Événements du prologue après la mort des compagnons.
- Anciennes sauvegardes sans état de relations.
- Conservation des identifiants et compatibilité des futurs profils.

## Décisions encore ouvertes
- Nombre définitif de rangs et seuils.
- Visibilité exacte des valeurs au joueur.
- Poids des actes, dialogues, cadeaux et missions.
- Relations romantiques éventuelles, hors périmètre actuel.
- Rivalité et confiance négative : états qualitatifs ou axes supplémentaires.
- Récompenses détaillées et équilibre.
- Politique de réconciliation et d'échec définitif.

## État d'exécution
Spécification uniquement. Aucune scène, aucun système de relations ni test Godot ajouté par ce document.

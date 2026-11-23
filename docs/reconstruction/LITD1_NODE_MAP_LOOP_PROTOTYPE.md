# LITD 1 — boucle jouable carte à nœuds (prototype)

## Portée

Cette verticale de démonstration relie les surfaces suivantes :

1. hub de test de la Guilde ;
2. carte fixe à embranchements ;
3. rencontre 2D au tour par tour, avec choix de cible, attaque et garde ;
4. retour au hub de test.

La carte est un graphe écrit dans `data/prototypes/litd1_node_map_loop.json`. Ses nœuds visités restent sélectionnables ; un événement déjà résolu ne se relance pas au retour. Le parcours reste entièrement fixe : la génération procédurale, les cartes de campagne, les quêtes et les conditions de progression sont hors périmètre. Le combat ne dispose pas encore de grille, de rangs ou de déplacement tactique.

## Fixtures temporaires

- Le protagoniste, les trois alliés et les deux ennemis sont des acteurs anonymes de test. Ils ne constituent pas une équipe de départ canonique.
- Les PV, dégâts, actions et textes ne sont pas équilibrés ni approuvés.
- Aucun art original ou portrait canonique n'est utilisé ou recadré.
- Le parcours reste en mémoire pendant la scène ; aucune sauvegarde de campagne n'est écrite.
- Le recrutement, les arbres de compétences, l'affinité, le bestiaire individuel et les missions de PNJ ne sont pas raccordés.
- Le Game Over et la reprise avec le même protagoniste après le prologue ne sont pas implémentés. La règle de conception validée n'est pas déclarée testée par ce prototype.

## Contrôles d'acceptation

- ouverture du prototype depuis le hub ;
- choix entre deux branches ;
- lancement et résolution du combat ;
- affichage de la progression du groupe, des cibles et du journal ;
- retour sur un nœud visité sans rejouer son événement ;
- accès au nœud de retour et au hub ;
- chargement headless de la scène et tests déterministes du graphe et du combat.

Une réussite technique ne remplace pas une revue visuelle et un essai humain. Ce prototype n'est ni une fusion dans `main`, ni la validation du runtime de campagne.

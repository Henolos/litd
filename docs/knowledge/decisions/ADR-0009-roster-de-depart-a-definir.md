# ADR-0009 — Retrait de l'ancien quatuor de départ

- Statut : active
- Confiance : explicite (décision utilisateur)
- Domaine : canon / personnages / roster
- Date : 2026-11-23

## Décision

Mathilde, Marec, Anouk et Aurélien ne font plus partie du quatuor de départ de LITD 1. L'ancienne ADR-0002 et les garde-fous qui imposaient ces quatre personnages sont supersédés. La nouvelle composition du groupe de départ reste **non définie** ; aucun remplacement n'est inféré.

Les quatre identités restent des personnages connus et leurs données existantes peuvent servir aux systèmes et fixtures qui les référencent. Elles ne doivent plus porter le statut ou l'ordre de héros de départ dans `data/heroes.json`.

## Conséquences

- Le registre canonique indique `starting_roster_unassigned` jusqu'à une décision explicite sur les nouveaux personnages de départ.
- Les garde-fous automatisés vérifient que l'ancien quatuor n'est plus désigné, sans exiger une composition de remplacement.
- Les données tactiques historiques, arbres, loadouts et références de conception sont conservés comme ressources de personnages/fixtures ; ils ne constituent pas la nouvelle source canonique de roster.
- Le self-test de partie qui dépend d'un groupe de départ reste à réaligner avant validation de la verticale jouable.

## Réversibilité

Une nouvelle décision devra nommer et valider explicitement le roster avant qu'un verrou de composition exacte ne soit réactivé.

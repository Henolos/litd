# Sanctuaire : direction du décor du hub

Direction validée par le joueur le 4 octobre 2026 : inspiration asiatique,
principalement chinoise, conformément à `docs/STARTING_QUARTET_RESET.md`.
Le Sanctuaire reste un refuge sombre, habité et réparé après la guerre.

Le fond `assets/backgrounds/sanctuary.png` remplace la cité gothique occidentale
et ses textes, anciens portraits et jauges incrustés. Le nouveau décor comporte
des cours en terrasses, des charpentes apparentes, des toits de tuiles courbes,
des galeries couvertes et une porte monumentale. Les lanternes chaudes contrastent
avec la pierre et la brume froide. Aucun texte ou élément d'interface n'est peint
dans le fond : les contrôles existants restent rendus par Godot.

Le remplacement conserve le chemin de ressource partagé par le hub et ses
sous-écrans, ainsi que le fallback du registre artistique v41. Il ne crée pas
de nouvelle scène de hub et ne modifie ni les lieux disponibles, ni les règles
de soins, économie, expédition ou combat. Les noms internes des lieux restent
compatibles avec leurs actions et les sauvegardes.

Référence architecturale primaire consultée :
[The Astor Chinese Garden Court, Metropolitan Museum of Art](https://www.metmuseum.org/art/collection/search/78870).
Les cours, charpentes, terrasses et tuiles servent de références de matériaux et
de volumes ; le décor de LITD est une création de fantasy, pas une reconstitution.

## Asset et provenance

- Génération : outil intégré de génération d'image, création originale.
- Validation visuelle : réponse « Parfait » après présentation du décor.
- Dimensions : 1672 × 941, composition paysage proche de 16:9.
- SHA-256 : `7a71cadc91c57040395c42822ac110f8ebe125781a88be7180fb9153775430e3`.
- Consommation : `full_texture` existant, `STRETCH_KEEP_ASPECT_COVERED`.
- La validation du décor ne constitue pas une validation ergonomique sur iPhone.

Brief de génération : fond de hub dark fantasy peint, Sanctuaire-refuge sur
terrasses rocheuses au-dessus d'un ravin brumeux, architecture principalement
chinoise cohérente sur tous les bâtiments ; toits gris courbes, poteaux de bois
rouge usé, galeries et cours reliées, ateliers à gauche, auberge à droite,
pavillon et hall civique en hauteur, porte au premier plan ; pierre froide,
lanternes ambrées et éclairages intérieurs chauds. Aucun texte, menu, portrait,
logo, symbole de lore inventé, cathédrale gothique, flèche d'église, colombage
européen ou torii japonais.

## Vérification

Import Godot 4.7.2 et smoke artistique v41 réussis. Le domaine `ui-qa` réussit
les parcours joueur, l'interface canonique, la finition UX, le tactile logique
et la salle QA. Ces tests vérifient la compatibilité technique ; le cadrage et
le confort réels sur appareil restent à observer dans le prochain playtest.

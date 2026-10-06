# Premier Accord — bloc physique de la génération

Cette tranche prolonge la PR #526. `FirstAccordDungeonMapBuilder` reste le point
d'entrée physique : `instantiate_module` instancie le vestibule authored ou un
bloc 3D construit depuis la bibliothèque des modules. Les neuf modules du catalogue
ont désormais un sol avec collision, des ouvertures et marqueurs de connecteurs,
ainsi que des ancres de rencontre, lore, ressources et cicatrices pour les modules
génériques. Le `physical_tier` est `proxy` : ces blocs ne sont pas les scènes ou
apparences définitives.

`generate_from_plan` exige un plan et une validation finale valides. Il place la
colonne protégée et les branches dans des emplacements séparés, instancie tous les
modules du plan et construit les sols des liaisons ouvertes. Les arêtes secrètes
ou verrouillées ne créent aucun passage. La scène
`res://scenes/dungeons/first_accord_playable_blockout.tscn` utilise le contrôleur
d'exploration existant et démarre dans le vestibule. Sa graine exportée est fixe
pour le prototype ; elle ne déclenche pas une expédition ou une sauvegarde.

Les passages sont un blockout géométrique. Leur connexion à la navigation, leur
largeur aux angles, la révélation des secrets et l'ouverture des raccourcis demandent
une validation de déplacement en jeu. Les sélections `encounter` et `room_events`
restent attachées aux salles en métadonnées, sans création d'ennemis ni octroi de
ressources. Le combat anatomique, les rangs et les afflictions ne sont pas modifiés.

Validation locale Godot 4.7.2 : les neuf définitions s'instancient, leurs
connecteurs/ancres sont présents, et cinq graines produisent autant de salles et de
liaisons ouvertes que le plan. Le smoke charge aussi la scène d'exploration et
vérifie le personnage au vestibule. Le contrôle rejoint le domaine CI `veilleurs`.
Le test d'architecture sur 1 000 graines et les contrats existants restent requis.

Restent avant un donjon jouable complet : composition réelle des groupes Premier
Accord, résolution des combats, effets visuels des variantes, récompenses et butins,
interactions, sauvegarde/rechargement, navigation et vérification sur appareil.

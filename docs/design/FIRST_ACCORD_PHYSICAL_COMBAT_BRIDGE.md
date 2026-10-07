# Premier Accord — passerelle physique vers le combat canonique

La scène prototype `scenes/dungeons/first_accord_playable_blockout.tscn` utilise
désormais le plan sauvegardé de `VeilleursRuntime`. Les capteurs de salle demandent
une transition au runtime du donjon ; traverser les volumes ne permet pas de
contourner une salle non résolue. Le bouton INTERAGIR ou l’action `interact` résout
un lieu sans combat, ou ouvre le combat canonique de sa rencontre sélectionnée.

L’interface tactique existante est réutilisée avec les rangs R1–R4, le ciblage des
parties du corps, les compétences, les afflictions et la résolution de Rémanence.
Le groupe d’exploration reste dans la scène, désactivé pendant le combat. La
victoire applique les résultats du runtime, termine la salle et restaure son
transform exact. La retraite ne termine pas la salle et conserve le retour vers
les salles déjà visitées. Une salle terminée refuse une deuxième résolution.

Le singleton canonique sérialise un état physique facultatif (position, orientation,
salle active). Le bouton SAUVEGARDER en exploration utilise SaveManager. Une reprise
d’une sauvegarde physique revient à cette scène et restaure l’éventuel combat
canonique actif ; les anciennes sauvegardes sans état physique restent compatibles.
Le plan n’est pas régénéré au retour ou après modification de la Rémanence.

Validation automatisée : `first_accord_physical_combat_smoke.tscn` couvre le refus
d’un passage prématuré, la première rencontre gagnée par six commandes tactiques
réelles, le retour exact, le refus de rejeu, la Rémanence, la sérialisation d’un
deuxième combat et la retraite avec retour dans la salle précédente. Ce test
s’ajoute au domaine Godot `veilleurs`.

Cette tranche reste un prototype physique. Elle n’active pas le remplacement de
l’entrée joueur principale. Les couloirs, les collisions aux angles, la caméra,
les interactions de secrets/raccourcis, l’interface de récompenses/recrutement et
l’essai sur PC physique restent des validations ou intégrations distinctes.
La PR HUD #551 et son essai sur appareil restent indépendants de cette passerelle.

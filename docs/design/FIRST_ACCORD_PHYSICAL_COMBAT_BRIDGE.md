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
les interactions de secrets/raccourcis et l’essai sur PC physique ont leurs
validations distinctes. L'interface de résultat et de décisions de Rémanence
est décrite dans `FIRST_ACCORD_PHYSICAL_AFTERMATH.md`.
La PR HUD #551 et son essai sur appareil restent indépendants de cette passerelle.

## Découverte physique des passages secrets

FOUILLER LES PASSAGES demande `discover_current_passages` au runtime canonique.
La fouille est refusée pendant un combat ou avant la résolution de la salle.
Les arêtes découvertes sans verrou créent leurs couloirs physiques, y compris
le connecteur caché du module d’archive. Une seconde fouille ne crée aucun doublon.
À la reprise, les passages sont reconstruits depuis `discovered_edges` sauvegardé ;
le plan et sa graine restent inchangés. Les raccourcis verrouillés ne sont pas
ouverts par cette action.

`first_accord_physical_passages_smoke.tscn` vérifie six graines, les refus de
fouille, neuf découvertes, les couloirs, l’entrée et le retour logiques, l’absence
de doublons, les verrous et la sauvegarde/reprise JSON. La fin de salle est une
fixture explicite dans ce test ; les commandes de combat réelles sont couvertes
par le smoke de passerelle. Ce contrôle ne prouve pas un déplacement physique
sur appareil ni l’absence de collision au raccord de chaque couloir.

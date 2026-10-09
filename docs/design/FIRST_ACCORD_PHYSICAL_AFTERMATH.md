# Premier Accord : résultat physique et décisions de Rémanence

La fin du combat restaure immédiatement le transform du groupe, puis affiche
un écran de résultat. Le groupe reste immobile pendant cet écran. Le butin
affiché vient de `campaign.dungeon.rewards` dans le résultat canonique : il
n'est pas crédité une deuxième fois et reste à sécuriser par l'extraction.

Les survivants proviennent de `runtime.recruitment_options()`. Recruter,
épargner et laisser appellent `resolve_recruitment_decision`. Un refus de
recrutement conserve le candidat ; les conditions de famille, de relation,
de connaissance et de places restent celles du runtime existant. Cet écran
n'invente aucun de ces prérequis. Les décisions résolues ne sont plus offertes.

RETOURNER AU DONJON devient disponible lorsque chaque candidat a reçu une
décision. Le groupe retrouve son contrôle à son transform conservé. Un combat,
une transition de salle, un passage ou une extraction ne peut pas remplacer
les candidats pendant l'écran de résultat. Le contrôle des événements des
capteurs vérifie la position actuelle du groupe pour ignorer un ancien
`body_entered` reçu après sa réactivation.

La save physique contient le résultat en attente dans `physical_state.aftermath`.
Les candidats et décisions restent sérialisés par le runtime v0.9 existant.
La reprise restaure le résultat, les décisions restantes et le même transform.
Après confirmation, le champ de résultat est retiré. Une ancienne save sans ce
champ conserve son comportement ; si elle contient des candidats non résolus,
l'écran utilise `runtime.last_resolution` pour les présenter.

## Validation

- `first_accord_aftermath_smoke` vérifie les boutons réels, le refus de recrutement,
  les décisions épargner/laisser, le refus de répétition, une save SaveManager
  partiellement résolue puis rechargée, le retour exact, les gardes de progression
  et un ancien événement de capteur. La victoire avec survivants est une fixture
  de raccordement ; elle ne prouve pas une victoire jouée.
- `first_accord_physical_combat_smoke` garde la victoire par les commandes
  tactiques réelles et la retraite. Le combat physique expose maintenant le
  contrôle canonique de soumission non létale : une cible vulnérable est soumise
  par son bouton, puis épargnée dans le résultat physique. La décision et la
  position exacte sont relues via SaveManager avant le retour au donjon.
- `first_accord_physical_interactions_smoke` conserve cinq graines, huit secrets
  et cinq raccourcis après confirmation explicite des résultats de sa fixture.
- `first_accord_physical_journey_smoke` traverse le vestibule et la galerie :
  combat avec commandes réelles, soumission par le bouton, choix Épargner par
  l'écran de résultat, sauvegarde et reprise au même transform, retour par la
  salle visitée, puis extraction anticipée. Il vérifie le crédit unique du
  butin au refuge, y compris après recharge de la save extraite. Le routage
  de scène jusqu'au Sanctuaire garde son smoke dédié.
- Le nouveau smoke appartient au domaine CI `veilleurs`.

## Recherche utilisée

La séparation entre le groupe désactivé et les contrôles actifs suit les modes
de traitement des nœuds Godot. Le résultat en attente est un état de jeu
sérialisable ; les objets UI sont reconstruits à la reprise.

- [Godot : process modes](https://docs.godotengine.org/en/4.6/tutorials/scripting/pausing_games.html)
- [Godot : sauvegarde de progression](https://docs.godotengine.org/en/4.3/tutorials/io/saving_games.html)

Le blockout et l'essai PC restent distincts de cette validation automatisée.

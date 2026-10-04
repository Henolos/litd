# Premier Accord : raccordement jouable

Le plan de `FirstAccordHybridRuntimePlan` alimente désormais
`VeilleursDungeonRuntimeV07`, utilisé par le singleton de production
`VeilleursRuntime`. Aucun second navigateur ni moteur de combat n'est créé.
L'interface de production ouvre le Premier Accord par défaut ; les six donjons
précédents restent disponibles dans le sélecteur après extraction.

## Contrats

- Les compositions proviennent du résolveur ajouté à la PR #526. Leur nombre,
  menace réelle et profils de formation sont vérifiés indépendamment. Le
  runtime matérialise la composition sélectionnée sans nouveau tirage.
- Le Gardien du Premier Accord conserve son identifiant narratif. Sa définition
  et ses quatre capacités utilisent les index de contenu et les résolveurs
  existants. Sa règle de scellement réutilise le directeur du Gardien ; aucun
  boss existant n'est renommé. Ses valeurs constituent une première passe
  d'équilibrage à évaluer en playtest.
- Une victoire autorise la progression. Un repli ouvre le retour vers une salle
  déjà visitée sans nettoyer la rencontre. Les secrets nécessitent une recherche.
  Les branches en impasse permettent le retour ; le raccourci profond est
  accessible depuis son côté profond. Un retour dans une salle nettoyée ne
  recrée pas ses adversaires.
- Les retours de Némésis utilisent le directeur existant, une chance de 12 %, une
  histoire dans la région et une espèce déjà présente dans la composition. Ils
  remplacent un membre, sans augmenter le nombre ni la menace de définition.
  Chaque identité revient au plus une fois par expédition. Le résultat du premier
  lancement est sauvegardé pour empêcher un nouveau tirage après repli/reprise.
- Les caches utilisent le flux `loot`, avec des montants déclarés dans
  `first_accord_combat.json`. Les récompenses restent en expédition puis sont
  créditées par le refuge à l'extraction. Le bonus de fin exige la victoire sur
  le Gardien. Une seconde résolution/extraction est refusée. Les traces de lore
  utilisent les archives existantes.
- La sauvegarde du navigateur contient le plan validé et les passages découverts.
  Le chargement valide ce plan et les révisions des catalogues au lieu de le
  régénérer dans un monde dont la Rémanence a changé. Les anciennes sauvegardes
  des six donjons restent lisibles.

## Présentation des salles

Les neuf modules possèdent une scène. Les huit salles supplémentaires réutilisent
les gabarits du constructeur de carte auteur existant, avec leurs dimensions
fixes. L'interface instancie la salle courante dans un viewport 3D indépendant et
présente les variantes environnementales choisies par l'Event Director.

La progression jouable utilise les actions de navigation de l'interface Veilleurs.
Ce raccordement ne transforme pas les variantes descriptives en nouvelles règles
physiques ou de dégâts : les combats gardent leurs règles existantes. Il ne
constitue pas une exploration libre de toutes les salles dans un unique monde 3D.
Les salles sont des blockouts auteurs, pas des assets finaux.

## Validation

`dungeon_playable_pipeline_smoke` couvre six expéditions, les neuf scènes,
les combats normaux et le boss, la reprise JSON avant et pendant les combats,
le repli/rejeu, les secrets, les garde-fous de récompenses et le démarrage de
l'interface de production. Les contrats de rangs, ciblage, anatomie, afflictions
et les anciens donjons restent couverts par les domaines Godot existants.
Le stress test de 1 000 générations/replays complets est conservé, avec une
limite de 180 s adaptée à la résolution de compositions.

## Parcours automatisé par les commandes joueur (2026-10-04)

`first_accord_playthrough_smoke.tscn` utilise l'interface de production et ses
commandes de sélection, déplacement adjacent, ciblage anatomique et compétences.
La stratégie choisit l'attaque disponible offrant le plus de dégâts attendus
parmi les quatre compétences affichées ; chaque action déclenche la phase ennemie
existante. Aucun combatant n'est téléporté, aucun jet n'est forcé et aucune victoire
n'est déclarée directement. Les statistiques et règles de combat restent intactes.

Les graines 101 à 106 sont jouées deux fois depuis une Rémanence et une campagne
neuves. Le test exige l'identité des résultats, la légalité des déplacements et
la sélection des ennemis par leur équipe, y compris le Gardien dont l'identifiant
ne commence pas par `ENT_BOSS_`. Un scénario isolé du Gardien utilise une équipe
neuve : victoire en huit actions. Ce scénario est distinct du parcours intégral
et n'établit pas que le boss est accessible avec les blessures de l'expédition.

Résultats de référence avec cette stratégie offensive :

| Graine | Galerie | Débat | Expédition terminée |
| --- | --- | --- | --- |
| 101 | Défaite, 15 actions | Non atteint | Non |
| 102 | Victoire, 21 actions | Défaite, 17 actions | Non |
| 103 | Victoire, 21 actions | Défaite, 17 actions | Non |
| 104 | Défaite, 16 actions | Non atteint | Non |
| 105 | Victoire, 17 actions | Défaite, 22 actions | Non |
| 106 | Défaite, 8 actions | Non atteint | Non |

Le succès de ce test signifie que les contrats de commandes, de déterminisme et
le scénario isolé du boss passent. Il ne signifie pas que l'équilibrage du donjon
est validé. La stratégie n'utilise ni soins, garde, contrôle, équipement ni ultime.
Il faut compléter cette mesure par des stratégies de survie et un playtest humain
avant de régler la pression des rencontres ou de valider la fusion pour livraison.

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
| 101 | Arrêt, 15 actions | Non atteint | Non |
| 102 | Victoire, 21 actions | Arrêt, 17 actions | Non |
| 103 | Victoire, 21 actions | Arrêt, 17 actions | Non |
| 104 | Arrêt, 16 actions | Non atteint | Non |
| 105 | Victoire, 17 actions | Défaite, 22 actions | Non |
| 106 | Arrêt, 8 actions | Non atteint | Non |

Le succès de ce test signifie que les contrats de commandes, de déterminisme et
le scénario isolé du boss passent. Il ne signifie pas que l'équilibrage du donjon
est validé. La stratégie n'utilise ni soins, garde, contrôle, équipement ni ultime.
Il faut compléter cette mesure par des stratégies de survie et un playtest humain
avant de régler la pression des rencontres ou de valider la fusion pour livraison.


## Soins, garde et contrôle (2026-10-04)

Le même test couvre désormais quatre politiques sur les six graines, chaque
parcours étant rejoué : 48 exécutions. Il vérifie aussi l'empreinte des états de
combat après chaque action, la cible et le lanceur réellement inscrits au journal,
et l'exécution effective de soins, garde et contrôle. Les blocages faute d'attaque
accessible aux survivants sont distingués des défaites avec élimination du groupe.
Les « arrêts » du tableau précédent ne prouvent donc pas la mort de tous les
Veilleurs ni l'impossibilité du donjon.

Les politiques sont des heuristiques bornées, pas un joueur optimal :

- `offense` : attaque offrant les meilleurs dégâts attendus.
- `heal` : même attaque, avec soin de l'allié le plus blessé une action sur trois.
- `guard_control` : contrôle ou garde une action sur trois, au maximum deux de
  chaque par combat, puis attaque.
- `mixed` : même cadence, avec priorité au soin urgent, puis contrôle et garde.

L'interface forçait auparavant les soins et soutiens sur le lanceur. Le sélecteur
« Cible alliée » expose désormais la cible acceptée par le moteur existant.
Il conserve le lanceur par défaut, ne présente que les Veilleurs vivants, conserve
le choix lors d'un changement de lanceur et le réinitialise quand la cible meurt.
La portée est vérifiée par le prévisualiseur existant ; la garde reste personnelle.
La CI exige notamment un soin positif appliqué à un autre Veilleur.

| Politique | Galerie franchie | Débat franchi | Boss atteint | Expédition terminée |
| --- | --- | --- | --- | --- |
| Offensive | 3 / 6 | 0 / 6 | 0 / 6 | 0 / 6 |
| Soins alliés | 3 / 6 | 0 / 6 | 0 / 6 | 0 / 6 |
| Garde et contrôle | 3 / 6 | 1 / 6 | 0 / 6 | 0 / 6 |
| Mixte | 3 / 6 | 1 / 6 | 0 / 6 | 0 / 6 |

Ces résultats révèlent une attrition importante pour ces heuristiques. Ils ne
valident pas l'équilibrage et ne prouvent pas qu'une stratégie optimale échouerait.
Le scénario isolé du Gardien reste une victoire en huit actions.

Une expérience réduisant les effectifs critiques de 2/3/3/4 à 1/2/2/2, avec
menaces adaptées aux budgets existants, a également donné zéro expédition complète
sur cette matrice. Cette modification a été écartée : les tables de rencontres,
le boss, les budgets, les règles de Némésis, les récompenses et le moteur de combat
restent identiques. Aucun soin gratuit entre salles ni résurrection n'a été ajouté.

Avant un réglage définitif de difficulté, il reste à mesurer la survie avec une
politique qui concentre les attaques sur les ennemis proches de l'élimination,
exploite les fonctions corporelles et utilise les autres choix disponibles.
Un playtest humain reste nécessaire pour vérifier la lisibilité des choix et
l'intérêt du rythme. La matrice automatique n'autorise pas à elle seule la fusion
pour livraison.

## Concentration et ciblage anatomique (2026-10-04)

La matrice comporte désormais neuf politiques × six graines × deux exécutions,
soit 108 parcours mesurés. Les quatre références précédentes restent inchangées.
Les politiques additionnelles passent toujours par les compétences affichées,
les mouvements adjacents et les phases ennemies de l'interface de production :

- `focus` choisit l'ennemi ayant le moins de PV, puis garde cette cible jusqu'à
  son élimination. Les égalités initiales utilisent les identifiants triés. Si
  nécessaire, le déplacement cherche un chemin vers cette cible précise.
- `limbs` concentre les traumatismes sur le bras gauche jusqu'à L4, puis le bras
  droit, puis les jambes. Le torse sert de repli quand tous les membres sont L4.
- `focus_limbs_mixed` combine ce ciblage des membres avec une cible verrouillée
  et la politique de soins/garde/contrôle précédente.
- `head` cible la tête ; `legs` commence par les jambes avant les bras.

Le test exige des attaques effectivement exécutées vers la cible verrouillée,
les membres, la tête et les jambes. Il vérifie le lanceur, la cible et l'empreinte
complète des états après chaque action. Il relève les blessures L3–L5 et les
ripostes infligeant des dégâts quand un bras empêche l'usage à deux mains.

| Politique | Galerie franchie | Débat franchi | Effondrement franchi | Trois Piliers franchis | Expédition terminée |
| --- | --- | --- | --- | --- | --- |
| Offensive | 3 / 6 | 0 / 6 | 0 / 6 | 0 / 6 | 0 / 6 |
| Soins alliés | 3 / 6 | 0 / 6 | 0 / 6 | 0 / 6 | 0 / 6 |
| Garde/contrôle | 3 / 6 | 1 / 6 | 0 / 6 | 0 / 6 | 0 / 6 |
| Mixte | 3 / 6 | 1 / 6 | 0 / 6 | 0 / 6 | 0 / 6 |
| Concentration | 5 / 6 | 1 / 6 | 1 / 6 | 0 / 6 | 0 / 6 |
| Bras prioritaires | 3 / 6 | 0 / 6 | 0 / 6 | 0 / 6 | 0 / 6 |
| Concentration/membres/mixte | 3 / 6 | 0 / 6 | 0 / 6 | 0 / 6 | 0 / 6 |
| Tête | 3 / 6 | 0 / 6 | 0 / 6 | 0 / 6 | 0 / 6 |
| Jambes prioritaires | 3 / 6 | 0 / 6 | 0 / 6 | 0 / 6 | 0 / 6 |

La concentration permet à la graine 106 d'atteindre les Trois Piliers, où le
parcours s'arrête après neuf attaques. La couverture totale, répétitions incluses,
comprend 708 attaques sur cible verrouillée, 988 attaques sur membres (dont 326
sur jambes), 478 attaques sur tête et 112 ripostes infligeant des dégâts alors
que `can_use_two_handed` est faux. Le Gardien isolé reste vaincu en huit actions.

Ces ripostes ne prouvent pas à elles seules une violation d'une règle : un bras
L4 limite l'usage à deux mains, ce qui n'interdit pas toute attaque. Les formules
actuelles de dégâts tactiques (`VeilleursDamageResolver`) ne consomment ni cet
indicateur ni `weapon_use_penalty`. Le test constate les états et les actions ;
il n'introduit aucun malus automatique ni nouvelle interdiction corporelle.
La politique ciblant les membres n'améliore pas la progression sur cet échantillon.

L'échantillon de six graines et ces heuristiques ne constituent ni une stratégie
optimale ni une preuve d'impossibilité. L'équilibrage reste non validé. Les tables,
budgets, compétences, règles de combat, afflictions et récompenses sont conservés.
Avant de modifier la difficulté, il faut rapprocher les exigences corporelles des
compétences des règles auteur et des résolveurs existants, puis mesurer les effets
fonctionnels attendus et l'attrition sur un échantillon élargi.

## Raccordement des limitations corporelles

La validation tactique commune consomme désormais `VeilleursBodyComponent` :
`alive` conditionne les actions et les cibles ; `can_walk` les déplacements
joueur, IA et compétences de déplacement ; `can_guard` la garde ;
`can_use_two_handed` les attaques avec une instance équipée explicitement
marquée `two_handed`. Une blessure L4 d'un bras ne bloque pas les attaques à
une main ou naturelles. L3 d'une jambe bloque le sprint selon le contrat du
corps, sans interdire la marche. Aucun sprint distinct n'est ajouté.

Les acteurs morts corporellement restent indisponibles même avec des PV
positifs, y compris après sauvegarde. Les ultimes, phases du boss, recrutement
et mémoire de Rémanence respectent cette mort. Le test
`veilleurs_body_action_contract_smoke` vérifie aussi qu'une action refusée ne
modifie ni l'état ni le journal, et que la propriété de l'arme équipée rejoint
le combat. La validation de cible est partagée par aperçu et exécution.

Les champs historiques `weapon_use_penalty`, `mobility_penalty`,
`perception_penalty` et `vigor_penalty` restent descriptifs : aucune unité ou
formule de conversion n'est établie dans ce chemin tactique. Leur raccordement
numérique demanderait une règle explicite. `can_react` reste utilisé par le
résolveur Hémocorde existant ; les observations de motifs de l'IA ne sont pas
transformées en nouvelle action de réaction.

Nouvelle mesure sur les mêmes six graines, chaque parcours répété à
l'identique (108 parcours ; chiffres précédents conservés comme historique) :

| Politique | Galerie gagnée | Débat gagné | Passage gagné | Trois Piliers gagnés | Donjon terminé |
|---|---:|---:|---:|---:|---:|
| offense | 3/6 | 0/6 | 0/6 | 0/6 | 0/6 |
| heal | 3/6 | 0/6 | 0/6 | 0/6 | 0/6 |
| guard_control | 4/6 | 1/6 | 0/6 | 0/6 | 0/6 |
| mixed | 4/6 | 1/6 | 0/6 | 0/6 | 0/6 |
| focus | 4/6 | 1/6 | 1/6 | 0/6 | 0/6 |
| limbs | 3/6 | 0/6 | 0/6 | 0/6 | 0/6 |
| focus_limbs_mixed | 4/6 | 0/6 | 0/6 | 0/6 | 0/6 |
| head | 5/6 | 0/6 | 0/6 | 0/6 | 0/6 |
| legs | 3/6 | 0/6 | 0/6 | 0/6 | 0/6 |

Couverture : 2622 attaques, 128 soins dont 92 soins d'alliés avec gain de PV,
98 gardes, 96 contrôles, 628 attaques concentrées, 946 attaques sur membres,
256 sur tête et 316 sur jambes. Les 122 ripostes après un bras L4 restent
possibles pour des ennemis sans exigence explicite d'arme à deux mains.
Le boss isolé est vaincu en huit actions. Aucun réglage de difficulté,
statistique, budget, récompense ou règle d'affliction n'est modifié.

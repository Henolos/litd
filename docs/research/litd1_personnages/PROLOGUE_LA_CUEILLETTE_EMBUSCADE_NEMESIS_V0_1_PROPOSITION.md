# LITD 1 — Embuscade et fuite de la Némésis : séquence jouable V0.1

**18 novembre 2026 — Proposition de conception, NON VALIDÉE, NON IMPLÉMENTÉE, NON TESTÉE.**

## Contraintes narratives déjà retenues
La récolte est entièrement accomplie avant l'embuscade sur le retour. Wei, Mara et Sami meurent définitivement ; le protagoniste survit. Le monstre élite évolue en Némésis/mini-boss après les morts et fuit, sans nécessairement épargner volontairement le protagoniste. Une partie des champignons est perdue dans le combat. Les trois carnets sont récupérés après la fuite et ne débloquent leurs fonctions qu'après la scène finale à la Guilde.

## Solution principale proposée : retraite brisée, transformation déstabilisante

### Phase A — Attaque et diagnostic (scènes 12–13)
Une présence interrompt la conversation. L'élite surgit sur le chemin du retour et ouvre par une attaque lisible, dangereuse mais non arbitrairement létale. Les premières actions du joueur restent effectives. Mara reconnaît la disproportion des forces et ordonne le repli.

**MARA :** « Ce n'est pas un combat qu'on peut gagner. Reculez, ensemble ! »

Le jeu communique alors clairement un **objectif de retraite/survie** plutôt qu'une victoire par réduction des PV de l'élite. L'interface exacte et les conditions d'apparition de cet objectif restent à concevoir.

### Phase B — Résister pour ouvrir un passage (scène 14)
La compagnie cherche à rejoindre un passage étroit connu sur le chemin. Les actions normales (défense, compétences, protection, placement) restent déterminantes : elles affectent la durée de résistance, les blessures et les possibilités de déplacement. Éviter une seconde mécanique de combat ou une jauge artificielle de « temps de scénario ». Le passage et la carte sont des hypothèses à vérifier dans l'exploration existante.

### Phase C — Rupture de formation (scène 15)
La créature déjoue la retraite. Les trois compagnons sont tués dans des actions qui reflètent leurs personnalités : Wei tente de tenir une position, Mara organise le repli et Sami cherche une issue. **Ces gestes sont des intentions de mise en scène, non un ordre de décès fixé.** Les actions du joueur peuvent influer sur le détail de la résistance mais ne doivent pas prétendre permettre de sauver définitivement les compagnons si aucune branche de scénario ne le permet. La perte d'une partie des champignons est visible pendant cette phase, non à la récolte.

### Phase D — Mutation (scène 16)
Les trois morts provoquent l'évolution de l'élite en Némésis. La mutation entraîne une désorientation physiologique temporaire : mouvements désordonnés, rupture de l'attaque, retrait vers les bois. **Cette causalité est une hypothèse narrative**, non une règle générale canonisée du système Némésis. Il faudra expliquer pourquoi l'évolution produit cet effet ici, et vérifier que cela ne contredit pas les règles futures de la Némésis.

### Phase E — Survie et retour au contrôle (scène 17)
La créature s'éloigne sans décider consciemment d'épargner le héros. Le survivant reste dans un état jouable ; le contrôle lui est rendu après la fin de l'affrontement. Les carnets et les champignons récupérables sont examinés dans le silence. Aucun message de victoire, butin joyeux ou récompense d'XP affichée.

## Agence réelle du joueur : propositions et limites

| Dimension | Variable possible | Fixe |
|---|---|---|
| Résistance | Actions tactiques et nombre de tours tenus | Pas de victoire contre l'élite |
| Protagoniste | Blessures et ressources conservées, bornées pour rester jouable | Survie |
| Compagnons | Gestes, protections et répliques contextuelles | Trois morts |
| Récolte | Variation bornée du panier récupérable, si compatible avec le contrat | Livraison incomplète et demi-prime |
| Némésis | Observation de signes de mutation | Évolution puis fuite |

**Risque critique :** un joueur très performant peut se sentir puni par une transition scriptée. Il faut annoncer la retraite de façon crédible, rendre les décisions tactiques visibles, éviter les immunités silencieuses, et tester les stratégies extrêmes. La survie garantie du protagoniste et les trois morts imposées restent une concession scénaristique : ne pas prétendre que la proposition l'élimine totalement.

## Alternatives comparées

1. **Mutation physiologiquement déstabilisante (proposition principale).** Avantage : relie directement la fuite à l'évolution et ne suppose pas de clémence. Risque : mécanisme arbitraire si aucune règle du bestiaire ne le soutient.
2. **Obstacle environnemental.** Avantage : cause visible et spatiale, compatible avec une retraite. Risque : déclenchement opportuniste ou obstacle incohérent avec la carte.
3. **Comportement territorial.** Avantage : logique animale et réutilisable. Risque : pourquoi l'élite poursuit-elle les quatre aventuriers jusque-là ? Nécessite des indices préalables.
4. **Interruption extérieure.** Avantage : mise en scène spectaculaire. Risque : sauvetage providentiel et déplacement de l'attention vers un nouvel acteur.

**Préférence provisoire :** mutation déstabilisante avec éléments visuels préalables et passage étroit comme élément de retraite, sous réserve de validation de la causalité et du bestiaire.

## Critères de validation et tests futurs

- Le joueur comprend avant le verrouillage de l'issue que l'objectif n'est plus de vaincre le monstre.
- Aucune action valide n'est ignorée silencieusement ; les choix ont des effets observables.
- Aucun cas extrême (contrôle, défense, dégâts élevés, fuite anticipée, abandon de ressources) ne provoque de softlock ni ne contourne arbitrairement la scène.
- L'issue est compatible avec la persistance de l'état, les blessures, l'XP invisible et la conservation des trois carnets.
- Le motif de fuite est compréhensible à l'écran et ne suppose pas de compassion de l'élite.
- Les trois morts ne sont pas célébrées par l'interface ; aucun faux message de victoire.
- La quantité de champignons récupérée reste inférieure à la quantité requise.
- La scène est évaluée en playtest : sentiment d'agence, compréhension du danger, lisibilité de la transformation, émotion des pertes.

**À décider avant tout code :** cause exacte de la fuite, possibilité d'interagir avec la retraite, conditions de déclenchement de la rupture, rôle du terrain et effets conservés sur le survivant. Aucun script ou test Godot exécuté.

## Décisions utilisateur complémentaires — combat 2D continu (18 novembre 2026)

**VALIDÉ PAR L'UTILISATEUR, prévaut sur les propositions contradictoires ci-dessus :**

1. **Aucune cinématique entre l'embuscade et la fin du combat.** Toute la rencontre se déroule dans le combat **2D au tour par tour**. Les phases A–D décrites plus haut ne sont que des repères logiques, pas des transitions cinématiques ni des changements de mode de jeu.
2. **Priorité de ciblage de l'élite :** Wei, Mara et Sami. La majorité de ses attaques sont destinées aux trois compagnons. Le protagoniste peut néanmoins être ciblé et subir des dégâts.
3. **Protection de scénario :** le protagoniste ne peut pas être tué par l'élite durant cette rencontre du prologue. Le mécanisme technique exact (plancher de PV, prévention des effets létaux différés, etc.) est **à concevoir et tester**, et ne doit pas modifier les combats ordinaires.
4. **Dégâts réels :** le groupe peut blesser l'élite. Le ciblage des parties du corps peut potentiellement provoquer la perte d'un membre si l'équipe concentre ses attaques, sous réserve des règles effectives du système de membres et de leurs tests.
5. **Issue conservée :** les trois compagnons meurent, l'élite évolue en Némésis puis fuit. Les dégâts, amputations et afflictions ne doivent pas être effacés arbitrairement ; leur persistance et leurs conséquences sur l'évolution et la fuite sont **à définir**.
6. **Mutation déstabilisante :** explication provisoire de la fuite acceptée comme direction de conception, **mais sa causalité exacte et son comportement dans le combat 2D restent à valider**. Ne pas imposer une cinématique ou une rupture de combat pour la montrer.

**Corrections des propositions antérieures :** la « retraite vers un passage étroit », l'objectif obligatoire de repli et toute interruption cinématique entre embuscade et fin de combat ne sont **pas des décisions retenues**. Le joueur combat avec les règles 2D existantes. Les éléments antérieurs qui les présentent comme solution principale sont supplantés par cette section.

### Risques techniques ouverts

- Empêcher une mort par dégâts directs, afflictions, dégâts sur la durée, contrecoups ou effets de membres sans rendre le héros invulnérable ni créer de boucle infinie.
- Définir le comportement si le groupe réduit les PV de l'élite à zéro ou neutralise un membre critique avant la mort des compagnons : ne pas masquer les dégâts, ne pas prétendre à une victoire qui n'existe pas.
- Vérifier les règles de ciblage, de rangs, de membres amputés, de contrôle et d'afflictions avant d'écrire l'IA du prologue.
- Montrer l'évolution et la fuite **dans la présentation du combat 2D**, avec les animations/effets compatibles, sans cinématique intermédiaire.
- Définir les probabilités ou priorités de ciblage réelles par des tests ; « majorité » est une intention, pas encore une valeur numérique validée.

**État :** décisions narratives et contraintes de combat consignées ; implémentation et tests Godot non réalisés.

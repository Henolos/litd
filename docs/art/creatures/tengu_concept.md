# Tengu — fiche de conception V1

**Projet :** LITD 1, lot japonais (Oni, Tengu, Jorōgumo, Kappa, Yuki-onna). **État :** proposition écrite, non validée visuellement ; aucune image générée.

## Référence et parti pris
Les tengu du folklore japonais présentent plusieurs iconographies, notamment le karasu-tengu à traits de corbeau et le daitengu au visage humanoïde et au long nez. **Proposition LITD : karasu-tengu**, pour créer un contraste anatomique net avec l'Oni massif. Il ne faut pas présenter cette interprétation artistique comme une description exhaustive de la tradition.

## Silhouette et anatomie
- Buste humanoïde sec et nerveux, posture de rapace penché vers l'avant, tête aviaire noire avec bec court et puissant, yeux profonds.
- **Deux bras indépendants et deux ailes dorsales distinctes** : six appendices locomoteurs/prehensiles au total (deux bras, deux jambes, deux ailes). Pas d'aile fusionnée avec les avant-bras, pour éviter les ambiguïtés de ciblage et de rigging.
- Deux jambes à jarrets légèrement marqués, pieds griffus ; doigts des mains capables de tenir une arme. Plumage anthracite à reflets bleus très retenus, lambeaux de vêtement de montagne et éléments rituels sobres.
- Ailes repliées : silhouette triangulaire compacte ; déployées : grande envergure lisible. Ne pas confondre plumes arrachées et amputation d'une aile entière.

## Carte de ciblage proposée, non implémentée
Tête, torse, bras gauche/droit, jambe gauche/droite, aile gauche/droite ; sous-zones optionnelles : bec, mains, pieds. Chaque aile a un identifiant distinct ; une aile perdue n'est plus ciblable. Le moteur générique actuel ne possède pas de profil Tengu à huit zones : créer un profil d'espèce avant intégration.

**Conséquences à définir et tester :** perte d'aile = vol et attaque plongeante indisponibles, avec animation au sol adaptée ; perte d'un bras = restrictions d'armes ; perte de jambe = mobilité dégradée ; perte de bec = attaques de morsure réduites. Les effets sont des intentions de design, non du gameplay existant démontré.

## Apparences
1. **Normal — Éclaireur des cimes** : corps élancé, plumage sombre, armes légères.
2. **Élite — Gardien des vents** : ailes plus développées, protection légère, marques rituelles anciennes.
3. **Mini-boss — Maître du col** : stature et envergure augmentées, parure cérémonielle usée, anatomie inchangée.
4. **Némésis** : blessures, plumes manquantes et amputations héritées des combats réels.
5. **Recruté** : signe d'allégeance discret, blessures conservées, pas de restauration automatique des ailes.

Les trois premiers sont des niveaux ; Némésis et recruté sont des statuts transversaux.

## Direction artistique
Dark fantasy japonais sans éclats dorés dominants : pierre volcanique, bleu nuit, bronze terni, contre-jour froid ; maintenir la lisibilité des ailes, des bras et des jambes. Vues face, profil, trois quarts, ailes ouvertes et fermées nécessaires avant validation finale.

## Décisions à valider
Choix karasu-tengu plutôt que daitengu, implantation de deux ailes dorsales séparées des bras, proportions des jambes et du bec, et taille de l'envergure. Aucune planche approuvée à ce stade.

## Décision utilisateur du 9 novembre 2026

**Karasu-tengu à tête de corbeau validé** plutôt que Daitengu au long nez humain. Cette validation porte sur le **type de tête et la direction de silhouette**, pas sur les proportions finales, le détail des ailes, les planches visuelles ou l'intégration Godot. Conserver la proposition des deux ailes dorsales séparées comme hypothèse anatomique à confirmer à l'étape suivante.


## Consolidation anatomique des ailes — décision du 9 novembre 2026

L'utilisateur a confirmé la poursuite de la consolidation des ailes dorsales. **Architecture retenue pour la fiche de conception : deux ailes indépendantes des deux bras**, articulées à une ceinture scapulaire dorsale adaptée. Cette décision valide le principe anatomique ; les proportions exactes et le visuel restent à approuver.

### Articulations et implantation
- Chaque aile possède une racine dorsolatérale, une articulation proximale mobile, un segment porteur et une extrémité de rémiges. Les racines doivent rester distinctes des épaules des bras et ne pas masquer les deux membres supérieurs en vue trois quarts.
- Déploiement symétrique possible, mais chaque aile peut être blessée ou repliée séparément. En position de repos, les ailes se replient vers le dos, sans se confondre avec une cape.
- L'armature thoracique est élargie dans le haut du dos ; musculature pectorale et dorsale renforcée, taille étroite et centre de gravité cohérent avec les phases au sol.
- La proposition reste une **anatomie de fantasy**, pas une démonstration de faisabilité biomécanique du vol avec une masse humanoïde.

### États à illustrer
1. Neutre au sol, ailes repliées, bras et mains visibles.
2. Menace, ailes semi-ouvertes, arme tenue en main.
3. Vol ou attaque plongeante, ailes déployées et jambes libres.
4. Aile gauche lésée, amplitude réduite.
5. Aile droite absente, silhouette asymétrique et posture terrestre compensée.

### Contrat de ciblage à implémenter ultérieurement
IDs de conception : `head`, `torso`, `left_arm`, `right_arm`, `left_leg`, `right_leg`, `left_wing`, `right_wing`. Le profil anatomique spécifique et le rigging ne sont pas créés. Les règles souhaitées sont : chaque aile a trauma et état propres ; aile amputée exclue du ciblage ; perte d'une aile interdit le vol soutenu et l'attaque plongeante, mais ne supprime pas les attaques au sol ; bras amputé bloque les actions qui exigent la main correspondante. Ces conséquences ne sont **pas validées par tests Godot**.

### Critères de validation visuelle
Vues face, dos, profil, trois quarts, ailes repliées et déployées. Vérifier que les quatre attaches (deux bras, deux ailes) restent lisibles, que les ailes ne traversent ni vêtements ni équipement, et que l'asymétrie d'amputation reste identifiable. Le visage corvidé est déjà approuvé ; aucune planche finale approuvée.


## Nouvelle règle de conception — plafond de sept zones ciblables (2026-11-09)

**Décision utilisateur :** limiter à **sept zones de ciblage affichées au maximum** par créature. Pour le Karasu-tengu, les deux ailes partagent **une seule zone de sélection** `wings` ; les six autres sont `head`, `torso`, `left_arm`, `right_arm`, `left_leg`, `right_leg`. La proposition précédente de huit zones visibles est remplacée par ce plafond.

**Séparer l'interface de l'état anatomique :** deux ailes physiques et deux états indépendants `left_wing`/`right_wing` peuvent être conservés dans les données, mais le joueur voit une zone `wings`. La règle précise de répartition des coups sur l'aile gauche/droite (par exemple celle encore intacte, ou choix contextuel) reste **à définir et à tester**, pour éviter un ciblage ambigu. Une zone groupée disparaît seulement si aucun de ses composants ne reste ciblable. Ne pas prétendre que `AnatomyRuntime` implémente déjà cette agrégation.

**Portée du plafond :** s'applique aussi aux futures créatures à nombreux appendices (Jorōgumo notamment) ; les groupes anatomiques doivent rester cohérents avec blessures, amputations et affichage. Le nombre réel de membres, articulations et blessures internes n'est pas plafonné à sept.

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

# Oni V5 rituel — anatomie et ciblage (proposition V1)

**État :** direction d'assombrissement approuvée verbalement le 9 novembre 2026 ; anatomie détaillée ci-dessous proposée, non encore validée visuellement. Aucun visuel généré.

## Invariants visuels
- Conserver la silhouette et les éléments rituels de l'Oni V5 déjà retenu. Pas de refonte gratuite.
- Matières : peau sombre et mate, ombres profondes, métal noirci et touches de bronze discret. Réduire les éclats dorés et effets lumineux ; garder les contours lisibles en éclairage de combat.
- Anatomie bipède humanoïde massive : deux bras, deux jambes, un torse, une tête ; cornes visibles comme repères de silhouette. Toute variation du nombre de cornes ou des ornements doit être vérifiée avec le modèle V5 avant validation.

## Carte anatomique de travail
- **Tête** : crâne, visage, mâchoire, cornes ; distinguer cornes et yeux pour ne pas rendre le ciblage ambigu.
- **Cou et épaules** : transition tête/torse, protection éventuelle par les ornements rituels.
- **Torse** : thorax et abdomen ; séparer visuellement l'armure/les liens rituels des zones biologiques.
- **Bras gauche et droit** : épaule, coude, avant-bras, main, doigts et prise d'arme éventuelle ; silhouettes distinctes en trois quarts.
- **Jambes gauche et droite** : hanche, genou, cheville, pied ; appuis lourds, stabilité en pose neutre et d'attaque.
- **Ornements** : cordes, sceaux et éléments rituels sont des accessoires, pas des membres ni des points vitaux supplémentaires.

## Ciblage et blessures : proposition non implémentée
Zones candidates : tête, torse, bras gauche, bras droit, jambe gauche, jambe droite. Sous-zones possibles : yeux, mâchoire, mains, genoux. Les cornes pourraient être destructibles sans être traitées automatiquement comme des membres amputables.
- Blessure : altération localisée cohérente avec la zone frappée.
- Amputation : supprimer le segment concerné et adapter silhouette, prise d'arme, posture et animation ; ne pas le restaurer lors d'un passage élite/mini-boss ou Némésis/recruté.
- Conserver un squelette compatible entre niveaux de puissance, avec adaptations de proportions sans changer arbitrairement le nombre de membres.
- Les conséquences gameplay, rigging et tests Godot restent à spécifier ; rien n'est annoncé comme implémenté.

## Cinq références d'apparence
1. **Normal** : Oni V5 rituel assombri, anatomie de référence.
2. **Élite** : masse musculaire et équipement renforcés, mais silhouette et articulations inchangées.
3. **Mini-boss** : proportions plus imposantes, parure rituelle plus lourde, zones de ciblage toujours lisibles.
4. **Némésis** : blessures et amputations héritées des confrontations réellement vécues, sans séquelles inventées.
5. **Recruté** : insigne discret d'allégeance ; conserve ses cicatrices, ses membres manquants et son identité inquiétante.

**Important :** les trois premiers sont des niveaux ; les deux derniers sont des statuts superposables, non cinq transformations exclusives.

## Critères avant planche
Vues face, profil et trois quarts ; lecture claire des six zones principales ; comparaison à l'Oni V5 de référence ; contraste réduit sans perte de lisibilité ; validation utilisateur des proportions, de la silhouette et des ornements. Ne pas générer d'image sans demande explicite.


## Revue de cohérence anatomique et blessures — 2026-11-09

**Nature du contrôle :** revue documentaire des règles d'Oni V5 et des décisions LITD connues ; **aucune preuve de compatibilité avec le code Godot**, faute de fichier source de ciblage identifié dans cette revue. Ne pas déclarer les comportements intégrés ou testés.

| Zone anatomique | Blessure représentable | Amputation / destruction | Conséquence à spécifier |
|---|---|---|---|
| Tête | œil, mâchoire, visage | corne brisée ; tête non amputable par défaut | visibilité, intimidation, capacités |
| Torse | thorax, abdomen | non amputable par défaut | résistance, afflictions |
| Bras G/D | épaule, coude, main | main, avant-bras ou bras | armes, attaques et animations accessibles |
| Jambe G/D | genou, cheville, pied | pied ou jambe | mobilité, équilibre, rangs |
| Accessoires rituels | liens, plaques, talismans | destruction d'équipement uniquement | ne pas confondre avec membres |

**Règles de cohérence proposées :**
1. Identifiants stables par zone et par côté ; sous-zones liées à un parent (main → bras, pied → jambe). Une perte parent rend ses sous-zones indisponibles.
2. Chaque attaque valide la présence de la zone ciblée au moment de l'exécution ; retargeting ou annulation selon règle de combat à définir, jamais frappe sur membre absent.
3. Persistance des blessures entre rencontres, changements de niveau et statuts Némésis/recruté ; les prothèses sont des objets explicites, pas une régénération implicite.
4. Les effets « étourdissement », « silence », « gel » et « brûlure » sont des afflictions distinctes des lésions anatomiques ; leurs interactions exactes restent régies par le système de combat.
5. Tester séparément chaque latéralité, chaque segment amputé, l'arme portée, les transitions de pose, le ciblage après perte et la sauvegarde/chargement.
6. En UI, afficher la silhouette anatomique propre à l'espèce et désactiver clairement les zones perdues.

**Résultat :** cohérence *conceptuelle* acceptable sous ces règles ; **compatibilité technique non vérifiée**. Blocage à lever avant validation technique : retrouver les structures effectives de ciblage, blessures, amputations et persistance dans le dépôt, puis ajouter les tests Godot adaptés. Cette revue n'autorise pas la production de planche finale.

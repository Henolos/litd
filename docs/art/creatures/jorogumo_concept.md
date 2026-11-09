# Jorōgumo — proposition anatomique V1 (2026-11-09)

**Statut : proposition à valider**, non implémentée, non testée, aucune planche validée.

## Morphologie proposée
Créature hybride à buste féminin humanoïde (tête, torse et deux bras), rattaché à un céphalothorax arachnéen portant huit pattes articulées et un abdomen postérieur. Anatomie fantastique inspirée de la Jorōgumo, sans prétendre que cette forme soit l'unique représentation folklorique.

## 14 zones ciblables
1. Tête humanoïde
2. Torse humanoïde
3. Bras gauche
4. Bras droit
5. Céphalothorax arachnéen
6. Abdomen arachnéen
7. Patte arachnéenne 1
8. Patte arachnéenne 2
9. Patte arachnéenne 3
10. Patte arachnéenne 4
11. Patte arachnéenne 5
12. Patte arachnéenne 6
13. Patte arachnéenne 7
14. Patte arachnéenne 8

Total : 1 + 1 + 2 + 1 + 1 + 8 = **14 zones**. Les huit pattes ont des identifiants et des blessures indépendants. Numérotation anatomique stable à définir (côté et ordre antéro-postérieur). Aucun plafond universel de zones. La répartition des membres et le rendu en combat restent à valider.

## Effets envisagés
Les pertes de pattes réduisent progressivement mobilité, stabilité et accès à certaines actions, sans déduire automatiquement qu'une patte perdue interdit tout déplacement. Une patte amputée n'est plus ciblable. Les seuils exacts, le ciblage et les sauvegardes devront être testés dans Godot.

## Art à produire après validation écrite
Silhouette face/profil/dos/trois quarts, distinction claire du céphalothorax et de l'abdomen, huit pattes lisibles, poses avec membres amputés, et déclinaisons Normal/Élite/Mini-boss avec statuts Némésis/Recruté transversaux.

## Décision utilisateur — regroupement des huit pattes (2026-11-09)

**Correction validée :** les huit pattes arachnéennes forment **une seule zone de ciblage visible**, nommée `spider_legs`. Le total de zones visibles passe donc de 14 à **7** : tête humanoïde (1), torse humanoïde (1), bras gauche et droit (2), céphalothorax arachnéen (1), abdomen arachnéen (1), groupe des huit pattes (1). Le tableau antérieur de quatorze zones est une proposition **supplantée**, et non la configuration retenue.

**Attention :** ce regroupement est spécifique à la Jorōgumo, **pas un plafond général** pour les autres créatures (Hydre, Tengu). Conserver huit pattes physiques et, si le gameplay l'exige, leurs états de blessure/amputation distincts en interne. L'attribution d'un coup à une patte précise, la disparition de la zone quand toutes les pattes sont perdues et les effets de mobilité restent à spécifier et tester. Aucun code Godot ni visuel validé à ce stade.

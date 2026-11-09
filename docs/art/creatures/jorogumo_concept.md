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


## Proposition V1 — blessures des huit pattes sous une zone commune (2026-11-09)

**État : spécification proposée, pas encore validée par l'utilisateur ni implémentée/testée.**

- Interface : une zone ciblable `spider_legs` ; anatomie interne : huit pattes physiques distinctes `leg_1` à `leg_8`, chacune avec état `intact`, `injured`, `disabled` ou `severed`, trauma et séquelles persistantes. Les huit identifiants restent stables entre combats.
- Résolution d'une attaque sur la zone : ne considérer que les pattes présentes. Priorité proposée : patte réellement intersectée par l'attaque si le moteur dispose d'une information spatiale fiable ; sinon sélection déterministe parmi les pattes présentes via le générateur aléatoire de combat avec seed, sans privilégier automatiquement la plus blessée. Journaliser la patte effectivement touchée et la présenter au joueur.
- Les pattes amputées ne sont plus candidates. Si toutes sont amputées, la zone commune devient non ciblable. La perte d'une patte ne supprime pas la zone si les autres sont encore présentes.
- Mobilité : calculer le nombre de pattes fonctionnelles, et distinguer blessure légère d'incapacité/amputation. Barème **indicatif à équilibrer** : 6 à 8 fonctionnelles = mobilité normale ou légèrement réduite ; 4 à 5 = pénalité modérée ; 2 à 3 = pénalité majeure et interdiction des attaques de bond ; 0 à 1 = immobilisation au sol, mais actions du buste possibles si leurs conditions sont satisfaites.
- Éviter la régénération automatique des membres amputés par soins ordinaires ; la persistance doit être vérifiée dans capture, sauvegarde et recrutement.
- Tests nécessaires : 8 pattes initiales, sélection reproductible à seed fixée, exclusion d'une patte amputée, maintien de la zone tant qu'une patte reste, retrait de la zone à zéro, paliers de mobilité, compatibilité Némésis/Recruté et sauvegarde/chargement.
- Risque identifié : le runtime actuel n'a pas été démontré compatible avec un sélecteur groupé vers huit parties persistantes ; prévoir une couche de résolution sans remplacer les identifiants internes.

**À arbitrer avant implémentation :** mode de choix de la patte effectivement touchée et seuils de mobilité.


## Décision de direction des attaques — 2026-11-09

**Demande utilisateur à appliquer au design :** les attaques latérales/horizontales peuvent atteindre des pattes des **deux côtés**, les attaques verticales atteignent des pattes d'**un seul côté**. Il s'agit d'une règle de conception à implémenter, non d'une fonctionnalité testée.

- Garder une seule zone visible `spider_legs` et huit pattes internes distinctes, quatre à gauche et quatre à droite (affectation latérale stable).
- Attaque `lateral` : ensemble candidat composé de pattes présentes des deux côtés, sous réserve de la portée réelle de l'arme, de l'orientation et de la trajectoire. Ne pas promettre que toutes sont touchées.
- Attaque `vertical` : déterminer le côté frappé à partir de la position/visée ; seuls les membres présents de ce côté sont candidats. Une attaque verticale centrée ou sans côté déterminable doit demander une règle explicite de résolution, pas choisir silencieusement.
- Calcul des dégâts : appliquer un budget de dégâts défini pour l'attaque et le répartir entre les membres effectivement touchés ; ne pas multiplier automatiquement les dégâts totaux par huit. Distinguer effets localisés, coups de zone et éventuels dégâts au corps.
- Priorité à une collision/trajectoire fiable ; sinon sélection déterministe des membres candidats via seed et journalisation de la patte touchée. Ne jamais choisir une patte amputée.
- Cas à tester : attaque latérale atteignant deux côtés, verticale atteignant un seul, attaque d'un côté sans patte, pattes déjà amputées, sauvegarde/chargement, reproductibilité des dégâts et équilibre des attaques de zone.

**Non résolu :** définition exacte de « latérale » dans le référentiel de combat, choix du côté pour une verticale frontale, nombre de pattes réellement touchées et répartition chiffrée. À spécifier avant intégration Godot.

## Début d'intégration dans le runtime existant (2026-11-09)

Commit `230136f` : ajout de `directional_group_candidates` dans `scripts/core/anatomy_runtime.gd`. La fonction filtre des identifiants de membres physiques existants selon l'axe `lateral`/`vertical`, le côté demandé pour `vertical`, et les amputations déjà enregistrées. Elle **ne crée pas de deuxième moteur de blessures** et n'applique aucun dégât. Convention temporaire : identifiants préfixés `left_` ou `right_`.

**Limites bloquantes :** aucun profil Jorōgumo à huit pattes internes encore ajouté à `combat_anatomy_v2.json` ; la zone UI groupée n'est pas reliée au sélecteur ; aucune répartition des dégâts ni collision/trajectoire, aucun test Godot exécuté. La fonction n'est pas encore appelée par le flux de combat. Vérifier la compatibilité des identifiants, ajouter des tests déterministes et intégrer progressivement sans contourner la CI.

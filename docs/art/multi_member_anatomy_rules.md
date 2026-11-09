# LITD 1 — Anatomie multi-membres (proposition transversale)

Statut : règles de conception demandées par l'utilisateur, documentation créée ; implémentation, intégration et tests non validés.

## Principes
- Aucune limite universelle au nombre de zones anatomiques.
- Une créature peut présenter des parties ciblables individuellement ou un groupe visible contenant plusieurs membres physiques avec états indépendants.
- Un seul moteur de trauma/amputation/persistance ; pas de double application des dégâts d'une même attaque.
- Le calcul des membres touchés dépend de la trajectoire, du côté, de la portée et de l'orientation ; les règles directionnelles Jorōgumo sont un cas particulier, non un comportement universel.
- Une partie amputée ne peut plus être ciblée ; les états doivent persister pour Némésis, capture et recrutement si applicables.

## Profils
- Jorōgumo : une zone visible pour huit pattes, quatre de chaque côté, blessures et amputations internes distinctes. Attaque latérale pouvant atteindre les deux côtés, verticale un seul côté. Le code actuel ne modélise pas encore les collisions réelles.
- Cerbère : trois têtes **individuellement ciblables**, avec identifiants stables left_head, center_head, right_head, états et conséquences propres. Un balayage peut atteindre plusieurs têtes seulement si la trajectoire le permet ; une frappe verticale localisée ne touche pas automatiquement les autres.
- Hydre : chaque tête **individuellement ciblable**, avec identifiants stables, nombre de têtes paramétrable par variante, blessures et amputations propres. Repousse éventuelle à concevoir explicitement (délai, conditions, maximum, persistance), non présumée.
- Tengu et autres créatures : découpage spécifique à la morphologie, sans imposer le regroupement des membres.

## Critères de validation
1. Un sélecteur affiche exactement les zones prévues par le profil, sans afficher les membres internes d'un groupe.
2. La tête gauche, centrale et droite du Cerbère sont sélectionnables séparément et ne partagent pas leurs traumatismes.
3. Chaque tête de l'Hydre est ciblable et conserve un état distinct ; amputations et éventuelle repousse respectent le profil.
4. Les coups multi-impacts ne dupliquent pas les dégâts totaux ; aucun impact sur une partie absente.
5. Tests déterministes : direction, trajectoire/portée, état blessé, amputé, sauvegarde/chargement, Némésis et recrutement.
6. Intégration dans le flux de combat existant et CI Godot obligatoires avant fusion.

## État d'implémentation
Les fonctions préparatoires pour la Jorōgumo existent dans anatomy_runtime.gd sur la branche de la PR #607 ; le raccordement effectif au combat, les profils Hydre/Cerbère et les tests ne sont pas vérifiés. Ne pas présenter cette documentation comme une fonctionnalité livrée.

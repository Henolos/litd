# LITD 1 — Destins des compagnons par capacités ennemies — V0.2 (PROPOSITION)

**Statut : non validé en conception ; non implémenté ; non testé.** Document de proposition, sans modification des règles approuvées.

## Sources examinées
- `docs/COMBAT_FAMILLES_ENNEMIES.md` sur `main` : cinq familles tactiques (humanoïdes, bêtes, arachnides, aberrations, constructions), plus élites/boss.
- `docs/research/litd1_personnages/LITD1_DESTIN_COMPAGNONS_PERDUS_DECISIONS_20261121.md` sur `main` : invariants validés.
- `docs/research/litd1_personnages/LITD1_TRANSFORMATIONS_COMPAGNONS_SYSTEME_V0_1_PROPOSITION.md` sur la branche de conception : états et transitions proposés.

## Principe d'architecture
**Ne pas confondre famille tactique et capacité de destin.** Les cinq familles de combat décrivent les comportements en formation, pas nécessairement l'aptitude à réanimer, recruter, piller ou corrompre. Ajouter des **capacités orthogonales** aux acteurs et factions. Une bête, un humanoïde ou une aberration peut posséder zéro ou plusieurs capacités, si la fiction le justifie. Les boss ne reçoivent pas de pouvoirs de transformation par leur seul rang.

## Matrice de capacités — propositions à arbitrer
| Capacité | Conditions causales proposées | Conséquence potentielle | Interdit |
|---|---|---|---|
| `reanimate_dead` | Corps mort accessible ; acteur nécromancien ou pouvoir équivalent ; événement de réanimation | `MORT -> HOSTILE_REANIME` | Réanimation par simple présence d'un ennemi sans capacité |
| `convert_living` | Héros vivant perdu/captif ; faction dotée d'une méthode crédible ; événement de conversion établi | `CAPTIF/PERDU_VIVANT -> HOSTILE_VIVANT` | Conversion automatique de tous les captifs |
| `loot_equipment` | Accès physique à l'objet ; acteur capable de le prendre | Transfert d'un identifiant d'objet unique | Duplication ; restitution magique |
| `corrupt` | Source corruptrice identifiée ; exposition et état compatibles ; événement causal | Mutation hostile vivante ou réanimation d'un mort **uniquement si pouvoir adapté** | Traiter une corruption comme réanimation universelle |
| `consume_or_destroy_remains` | Prédateur ou autre acteur ayant accès au corps | Corps indisponible pour réanimation ultérieure, selon résultat | Effacer rétroactivement un corps déjà déplacé |
| `collect_trophy` | Acteur intelligent ou Némésis capable de récupérer l'objet | Trophée persistant lié à l'acteur | Donner automatiquement cette capacité à tout Némésis |
| `preserve_remains` | Construction/acteur doté d'un comportement de conservation explicite | Corps ou équipement déplacé vers un lieu connu | Faire d'une construction un nécromancien implicite |

**Correspondances indicatives :** humanoïde cultiste nécromancien = `reanimate_dead` ; faction de cultistes = `convert_living` ; gobelin pillard = `loot_equipment` ; aberration corruptrice = `corrupt` ; bête charognarde = `consume_or_destroy_remains` ; automate gardien = `preserve_remains` seulement si défini dans son profil. Ce sont des exemples, pas des affectations vérifiées aux entrées de `data/enemies.json`.

## Ordre de résolution recommandé
1. Enregistrer la perte du héros et son état réel, sans mort implicite.
2. Enregistrer les objets et le corps à leur emplacement effectif.
3. Résoudre les événements causaux en ordre chronologique ; chaque acteur doit posséder la capacité requise et avoir accès à sa cible.
4. Appliquer une transition d'état atomique ; le pillage est un transfert d'objet distinct.
5. Conserver le journal des événements pour la sauvegarde, les rencontres ultérieures et le débogage.
6. Interdire toute transition `HOSTILE_*` vers l'effectif jouable.

## Cas de test de conception (non exécutés)
- Héros abandonné vivant auprès de bêtes sans capacité de conversion : pas de changement d'allégeance automatique.
- Héros mort pillé par un gobelin, puis réanimé par un nécromancien : corps hostile et objet détenu par le gobelin, sans duplication.
- Corps consommé puis réanimateur arrivant plus tard : aucune réanimation de ce corps sans règle surnaturelle explicite supplémentaire.
- Héros captif converti : aucune option de récupération, même après la défaite de la faction.
- Némésis tuant un héros : aucune récupération d'équipement sans accès et capacité ; évolution distincte des pouvoirs de destin.
- Sauvegarde/rechargement : un événement unique ne s'applique pas deux fois.

## Points ouverts
Affectations effectives des capacités à chaque ennemi de `data/enemies.json` ; délais ; seuils ; chances éventuelles ; sauvetage des captifs non hostiles ; persistance du corps ; récupération du butin ; présentation au joueur ; équilibrage.

## Suivi
Chantier : conception des destins par capacités ennemies. Statut : 🟡 À consolider. Avancement chantier : À évaluer. Avancement global LITD 1 : À évaluer.

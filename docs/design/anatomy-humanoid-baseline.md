# Ciblage anatomique : premier profil humanoïde (proposition)

Statut : **proposition de conception, non validée par les visuels et non implémentée**.

## Faits vérifiés
- `data/enemies.json` contient 39 entrées, avec id, nom, statistiques et référence d'image, sans champ de morphologie.
- `scripts/core/veilleurs_combat_sandbox_runtime.gd` initialise actuellement toutes les anatomies ennemies avec les zones `head`, `torso`, `left_arm`, `right_arm`, `left_leg`, `right_leg`.

## Premier lot à faible ambiguïté (classification provisoire)
| ID | Ennemi | Profil proposé | Validation manquante |
|---|---|---|---|
| 2 | Cultiste fanatisé | humanoid_biped | vérifier illustration et fiche de conception |
| 3 | Chevalier déchu | humanoid_biped | vérifier illustration et fiche de conception |
| 13 | Prêtre momifié | humanoid_biped | vérifier illustration et fiche de conception |
| 36 | Prêtre du Néant | humanoid_biped | vérifier illustration et fiche de conception |

Les noms suggèrent un bipède humanoïde, mais ne prouvent ni le nombre de membres ni leur intégrité. Ne pas classer les autres ennemis sans examen.

## Contrat proposé pour AnatomyTargetSelector
- Le profil fournit une liste de zones avec identifiant stable, libellé, état, géométrie cliquable et éventuelles relations fonctionnelles.
- Pour `humanoid_biped`, reprendre initialement les six identifiants du moteur, sans modifier la résolution des coups.
- L'interface reçoit du moteur la probabilité et les raisons d'indisponibilité de chaque zone; elle ne recalcule pas les probabilités.
- La sélection d'une zone met à jour l'aperçu, sans lancer l'attaque; confirmation explicite obligatoire.
- Prévoir souris, clavier et cibles tactiles agrandies; fallback liste pour les zones petites ou masquées.
- Ne jamais supposer que toutes les morphologies ont six zones.

## Critères de validation avant implémentation
1. Contrôler les illustrations et descriptions des quatre ennemis.
2. Vérifier le contrat de ciblage et de dégâts dans les résolveurs canoniques.
3. Tester les six zones, blessures, amputations, changement de cible et confirmation.
4. Vérifier la cohérence entre prévisualisation et résultat avec les tests Godot.

Aucun test Godot n'est déclaré réussi par ce document.

# Rapport d'incident — LITD 1 — Intégration des 15 PNG et prototype Mimique V2
Date : 2026-11-21
Statut : 🟠 BLOQUÉ PARTIELLEMENT — reprise requise
Branche : `docs/litd1-regles-fuite-transformations-20261118`
Périmètre : bestiaire commun, 15 planches artistiques validées, intégration binaire GitHub et exécution Blender.

## Demande
Importer dans GitHub les 15 PNG originaux validés, vérifier leurs empreintes SHA-256 après import, exécuter le prototype Blender de la Mimique V2 et vérifier visuellement l'indiscernabilité avec le coffre normal. Toute interruption doit faire l'objet d'un rapport dans `docs/knowledge`.

## Réalisé et vérifié
- 15/15 planches artistiques validées antérieurement par l'utilisateur.
- 15/15 PNG retrouvés dans la bibliothèque ChatGPT et archivés dans l'artefact de conversation `LITD1_15_planches_communes_validees_originaux.zip`.
- Manifeste `LITD1_15_MONSTRES_COMMUNS_SHA256.csv` existant.
- Contrôle exécuté le 21/11/2026 : 15 entrées CSV, 15 PNG ZIP, 15/15 SHA-256 égaux, tailles identiques, signatures PNG correctes, 15 SHA-256 distincts.
- Syntaxe Python vérifiée pour `LITD1_integrer_15_png_github.py` et `LITD1_Mimique_V2_prototype_blender.py` via `python -m py_compile`.
- Le dépôt `Henolos/litd` est accessible via le connecteur GitHub, branche `main` conservée.
- Sur la branche documentaire, 15 chemins PNG testés sous `docs/research/litd1_personnages/` absents (404) : ce constat ne prouve pas l'absence à d'autres chemins ou branches.

## Blocage 1 — Transfert binaire GitHub
- Le connecteur `create_file/update_file` traite du texte UTF-8 ; les objets Git `create_blob` acceptent du base64, mais les 15 fichiers binaires locaux ne peuvent pas être transmis directement depuis le conteneur à ce connecteur dans le flux actuel.
- Le script local `LITD1_integrer_15_png_github.py` prépare un commit Git sur un clone propre et la branche documentaire, mais **aucun clone authentifié avec push GitHub n'a été établi** dans cette intervention.
- Aucun des 15 PNG n'a été publié par cette intervention ; aucune empreinte distante n'a été comparée. Ne pas confondre le contrôle du ZIP local avec une validation GitHub.

## Blocage 2 — Blender
- `blender` absent du PATH de l'environnement d'exécution.
- Script de blockout disponible, syntaxe valide, mais **non exécuté dans Blender** ; aucun .blend ni rendu produit, aucun test d'indiscernabilité réalisé.
- Le script constitue un blockout de principe, pas un modèle conforme à la planche Mimique V2 validée.

## Impacts
- Le chantier artistique demeure **15/15 validé (100 %)**.
- L'intégration technique GitHub et Blender est **incomplète** ; avancement du chantier technique et du projet global : **À évaluer**.
- Aucun fichier de `main` ni PNG validé n'a été modifié.

## Reprise prioritaire
1. Obtenir un clone Git autorisé avec droits push, ou une voie de transfert binaire compatible ; exécuter `LITD1_integrer_15_png_github.py` avec ZIP et CSV, sur la branche documentaire propre.
2. Après publication, récupérer les 15 objets binaires GitHub et comparer SHA-256 au manifeste. Enregistrer chemins, commit et résultat de chaque contrôle.
3. Disposer d'une installation Blender 4.x, exécuter `blender --background --python LITD1_Mimique_V2_prototype_blender.py`, examiner le .blend et le rendu.
4. Tester l'indiscernabilité des coffres fermés dans des conditions de caméra et d'éclairage identiques, puis seulement décider de la validation technique.

## Règle de suivi
Toute nouvelle interruption doit être ajoutée au rapport d'incident ou documentée par un nouveau rapport daté dans `docs/knowledge`. Ne pas annoncer l'import ni les tests comme achevés sans preuves.

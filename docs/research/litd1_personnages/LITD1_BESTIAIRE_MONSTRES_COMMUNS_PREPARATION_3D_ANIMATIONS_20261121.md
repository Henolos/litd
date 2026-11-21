# LITD 1 — Préparation 3D et animations — 15 monstres communs

## État et périmètre
- **Conception artistique : 15/15 planches explicitement validées (100 %).**
- **Intégration technique : non commencée / à évaluer**, aucun modèle, rig, animation, export ou test en jeu validé par ce document.
- **Référence visuelle :** Anubis V2 (mise en page), direction sino-gothico-dark fantasy.
- **Registre maître :** `docs/research/litd1_personnages/LITD1_BESTIAIRE_PLANCHES_VALIDEES_MONSTRES_COMMUNS_20261121.md`.
- **Branche documentaire :** `docs/litd1-regles-fuite-transformations-20261118`. Ne pas modifier `main` ni les PNG originaux sans autorisation.

## Audit binaire GitHub — 21 novembre 2026
- 15 noms de PNG extraits du registre.
- Vérification directe de chacun des 15 chemins `docs/research/litd1_personnages/<nom>.png` sur la branche documentaire : **15 réponses 404**.
- **Portée de la conclusion :** fichiers absents de ces chemins précis uniquement. Leur présence éventuelle dans d'autres répertoires, branches ou via Git LFS reste à vérifier. Aucun transfert binaire effectué.
- **Priorité :** retrouver les emplacements des 15 originaux dans la bibliothèque ChatGPT, transférer les fichiers binaires exacts par une méthode compatible, puis vérifier leur présence et leur SHA-256 dans GitHub. Ne pas substituer une image générée à un original approuvé.

## Préparation de production (spécification, non implémentée)
1. **Inventaire** : relier chaque créature à son PNG approuvé, ses 4 rotations, études de matériaux et variantes ; définir échelle relative, encombrement et visibilité isométrique.
2. **Modélisation** : blockout silhouette puis maillage final, UV, textures et matériaux, optimisation LOD selon moteur et plateforme finalement retenus ; pas de décision technique présumée.
3. **Rigging** : rigs différenciés pour humanoïdes, quadrupèdes, arachnide, plante, esprit, armure vide et Mimique ; documenter les contraintes de chaque anatomie.
4. **Animations minimales** : repos, déplacement, détection, attaque(s), impact, mort/disparition ; ajouter émergence, embuscade, contrôle et états spécifiques quand justifiés par le gameplay.
5. **Intégration** : importer un prototype dans une scène d'essai isolée, vérifier lisibilité à l'échelle de caméra isométrique, collisions, timing, performances et cohérence avec le combat 2D.
6. **Validation** : captures comparatives avec la planche originale, revue artistique, tests d'animation et gameplay ; ne pas marquer terminé avant ces preuves.

## Exigences par famille
- **Squelette, goule, leprechaun, gobelin, kobold, noyé, diablotin :** silhouettes et rigs humanoïdes adaptés à la taille, sans uniformiser artificiellement leurs proportions.
- **Épouvantail V2 :** aucune croix/traverse dorsale ; matériaux souples, animation de paille et tissus.
- **Rat pestilentiel et loup corrompu :** quadrupèdes, locomotion et attaques en meute.
- **Araignée des cryptes :** huit pattes et attaques par toile.
- **Armure hantée :** **vide, sans squelette**, éléments métalliques suspendus par énergie spectrale.
- **Feu follet :** esprit flottant sans corps physique ; animation d'énergie.
- **Plante carnivore :** racines, lianes, gueule et attaques de saisie.
- **Oiseau-cadavre :** non retenu dans la série de 15 ; ne pas l'intégrer à ce lot.
- **Mimique V2 :** coffre fermé strictement identique au coffre normal, **même asset fermé et mêmes matériaux, géométrie, dimensions et comportement au repos** ; aucun signe visuel, audio ou animation révélateur. Déployer uniquement après déclenchement deux bras griffus, pattes, gueule et langue. Prévoir tests comparatifs côte à côte, éclairages variés et vues rapprochées. La finition du coffre ordinaire sert de référence aux coffres du jeu.

## Prochaine étape prioritaire
Localiser et vérifier les 15 PNG binaires originaux dans le dépôt (tous chemins/branches pertinents), puis produire une table de correspondance fichier ↔ source ↔ SHA-256. Ensuite seulement ouvrir un prototype technique isolé pour la Mimique V2 et les coffres ordinaires.

## Mise à jour du contrôle des originaux — 21 novembre 2026

- **15/15 fichiers PNG originaux** retrouvés dans la bibliothèque ChatGPT, matérialisés localement et vérifiés par signature PNG ; **15 empreintes SHA-256 calculées** et inventoriées dans `LITD1_15_MONSTRES_COMMUNS_SHA256.csv` (livré comme artefact de conversation, pas encore ajouté au dépôt).
- Archive de livraison des 15 PNG exacts : `LITD1_15_planches_communes_validees_originaux.zip` (artefact de conversation ; non encore importé dans GitHub).
- **GitHub :** 15/15 chemins testés sous `docs/research/litd1_personnages/` renvoient 404 sur la branche documentaire. Recherche globale du dépôt non exhaustive, aucun PNG binaire GitHub vérifié, aucune comparaison SHA-256 GitHub réalisée.
- **Prototype Mimique :** script Blender de blockout préparé `LITD1_Mimique_V2_prototype_blender.py` (artefact de conversation). Vérification de syntaxe Python effectuée ; **Blender indisponible dans l'environnement**, donc génération `.blend`, rendu et test d'indiscernabilité non exécutés. Le script n'est pas une reconstruction fidèle de la planche artistique et ne doit pas être considéré comme un modèle final.
- **Prochaine étape :** importer les PNG exacts dans un emplacement validé du dépôt avec un outil compatible binaire, comparer les SHA-256 ; exécuter le script de blockout dans Blender et vérifier visuellement la forme fermée avant intégration au moteur de jeu.

## Script d'intégration binaire préparé et testé (21 novembre 2026)

- Livrable de conversation : `LITD1_integrer_15_png_github.py`, prenant en entrée un clone Git propre, l'archive ZIP des 15 PNG et le manifeste SHA-256.
- Vérifications locales exécutées : 15/15 correspondances ZIP↔manifeste ; syntaxe Python ; essai complet sur un dépôt Git temporaire avec branche documentaire et commit de 15 PNG ; second passage idempotent (aucun nouveau commit) ; copie de travail propre.
- **Non exécuté sur le vrai dépôt `Henolos/litd`** : le conteneur n'a pas de connectivité réseau vers GitHub et le connecteur disponible ne permet pas de transmettre directement les 42 Mo de binaires locaux.
- **Aucun push distant, aucune comparaison distante, aucun changement de `main`.** Le test sur dépôt temporaire ne valide pas le dépôt réel.
- Étape suivante : exécuter le script sur un clone authentifié de `Henolos/litd` (branche documentaire), pousser la branche puis récupérer les 15 PNG depuis GitHub et comparer leurs SHA-256 au manifeste.

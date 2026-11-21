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

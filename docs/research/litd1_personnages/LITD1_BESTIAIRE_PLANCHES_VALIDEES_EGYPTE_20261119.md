# LITD 1 — Registre des planches artistiques validées : mythologie égyptienne

Date : 2026-11-19

## Règle
Toute planche validée explicitement par l'utilisateur doit être conservée **sans modification**, avec son fichier original, sa version, son empreinte SHA-256 et le périmètre exact de validation. Les variantes non validées restent séparées. Ne pas remplacer les originaux existants ni fusionner dans main sans accord.

## Première planche validée

- Référence mythologique : Seth (Set), Égypte antique.
- Espèce originale LITD 1 : **Écorcheur des Tempêtes**.
- Version : **V2**.
- Statut artistique : **VALIDÉ EXPLICITEMENT PAR L'UTILISATEUR**.
- Périmètre : silhouette, apparence, équipement et direction artistique sino-gothico-dark fantasy.
- Hors périmètre : gameplay, statistiques, équilibrage, comportement, cosmologie, intégration au moteur.
- Fichier PNG original : `LITD1_BEST_EGY_SETH_ECORCHEUR_TEMPETES_V2_VALIDEE.png`.
- SHA-256 : `cfd7b7e28a5e9c418eae7b65d4a4816014e4d8365fd0eab76782d3b10012b423`.
- Archive persistante confirmée : bibliothèque ChatGPT, `/LITD 1/Bestiaire/Planches validées/LITD1_BEST_EGY_SETH_ECORCHEUR_TEMPETES_V2_VALIDEE.png`.
- GitHub : **image binaire non encore téléversée** ; le présent document n'est pas une preuve de présence du PNG dans le dépôt.

## Suite

- Créer les planches Horus, Isis, Sobek, Anubis, puis soumettre chaque planche à validation.
- Après chaque validation, archiver l'original binaire et son SHA-256, mettre à jour ce registre.
- Avant import GitHub des binaires, vérifier les doublons et les conflits de chemin ; ne jamais écraser silencieusement une référence.

Avancement du chantier actuel (25 créatures) : 1/25 validation artistique, soit 4 % ; archivage GitHub binaire en attente.
Avancement du projet global : À évaluer.

## Actualisation — validation des planches au format Hydre

- **Seth / Écorcheur des Tempêtes** : nouvelle planche au format Hydre explicitement validée ; l'image précédemment sauvegardée sous `LITD1_BEST_EGY_SETH_ECORCHEUR_TEMPETES_V2_VALIDEE.png` a été **remplacée dans la bibliothèque ChatGPT** par la nouvelle planche. L'empreinte SHA-256 précédemment indiquée pour cette entrée correspond à l'ancienne image et **ne doit plus être utilisée comme empreinte de la nouvelle version** ; SHA-256 de la nouvelle version : à recalculer et vérifier. Les ajouts textuels (numéro de fiche, lore, profils, variantes) n'ont pas été validés indépendamment de la planche et doivent être réconciliés avec le canon.
- **Horus / Sentinelle du Zénith** : planche V1 au format Hydre explicitement validée ; fichier archivé dans la bibliothèque ChatGPT sous `/LITD 1/Bestiaire/Planches validées/LITD1_BEST_EGY_HORUS_SENTINELLE_ZENITH_V1_VALIDEE.png`.
- **Seth, chemin actuel** : `/LITD 1/Bestiaire/Planches validées/LITD1_BEST_EGY_SETH_ECORCHEUR_TEMPETES_V2_VALIDEE.png`.
- **GitHub** : seules les métadonnées documentaires sont enregistrées ; les deux PNG binaires ne sont pas confirmés présents dans le dépôt.
- **Bilan artistique** : 2/25 planches validées, soit 8 %. Projet global : À évaluer.

## Fiches descriptives artistiques — versions approuvées

### Écorcheur des Tempêtes (Seth) — nouvelle planche au format Hydre
- Statut : planche approuvée explicitement ; nouvelle mise en page remplaçant la V2 précédente dans la bibliothèque.
- Référence : figure égyptienne de Seth ; adaptation originale en espèce LITD, non preuve d'existence du dieu.
- Silhouette : grand humanoïde animalier sombre, tête canidé/séthienne, longues oreilles dressées, queue, mains griffues.
- Matières : peau sombre, plaques d'armure noir/bronze, détails dorés, étoffes rouges et ornements cérémoniels.
- Présentation : illustration principale, vues de rotation, expressions, détails de matières, silhouettes et deux variantes exploratoires.
- Variantes écrites sur la planche : « Briseur des Dunes » et « Prophète du Chaos » ; leur existence canonique et les caractéristiques textuelles restent à confirmer séparément.
- Source binaire validée : `LITD1_BEST_EGY_SETH_ECORCHEUR_TEMPETES_V2_VALIDEE.png` (contenu remplacé dans la bibliothèque par la nouvelle planche).
- Empreinte **de la nouvelle image au format Hydre**, calculée sur le fichier source de génération : `abb110f4d97c4c3698e25dc4b42322cc46f9cff6e6aa7492f9e1026b70da7b43`. À vérifier à nouveau sur l'export bibliothèque puis après import GitHub.
- Empreinte de l'ancienne V2 `cfd7b7e28a5e9c418eae7b65d4a4816014e4d8365fd0eab76782d3b10012b423` : **obsolète pour le fichier remplacé**.

### Sentinelle du Zénith (Horus) — V1
- Statut : planche approuvée explicitement.
- Référence : Horus, dieu faucon de la tradition égyptienne ; adaptation en espèce originale et non dieu du canon.
- Silhouette : humanoïde à tête de faucon, plumage sombre, armure segmentée dorée, épaules et manteau évoquant les ailes, serres.
- Présentation selon le modèle Hydre : illustration principale, vues de rotation, expressions, études de matières, silhouettes et variantes.
- Variantes écrites sur la planche : « Gardien des Remparts » et « Éclaireur du Désert » ; statut canonique et données de gameplay non déterminés.
- Différenciation souhaitée : éviter la confusion avec le Tengu corvidé déjà illustré.
- Source binaire validée : `LITD1_BEST_EGY_HORUS_SENTINELLE_ZENITH_V1_VALIDEE.png` dans la bibliothèque.
- Empreinte SHA-256 calculée sur le fichier source de génération : `5e4bdaf9af2fd74f92e3ccc4bc3357bad8e973b26570058632c1ba37e6aeca40`. À revérifier sur le fichier stocké puis après import GitHub.

## Condition de clôture de l'archivage
Le registre et les descriptions sont présents dans GitHub, **mais les deux fichiers PNG binaires ne le sont pas encore de manière vérifiée**. Ne pas déclarer le chantier achevé avant le transfert, la lecture des PNG depuis la branche GitHub et le contrôle des deux empreintes.


## Isis — La Tisseuse des Âmes — V2 sans couronne (validation artistique)

- **Statut** : 🟢 planche V2 validée explicitement par l'utilisateur le 19 novembre 2026. La V1 est une proposition antérieure non retenue.
- **Fichier original validé** : `LITD1_BEST_EGY_ISIS_TISSEUSE_DES_AMES_V2_VALIDEE.png`
- **Emplacement vérifié dans la bibliothèque ChatGPT** : `/LITD 1/Bestiaire/Planches validées/LITD1_BEST_EGY_ISIS_TISSEUSE_DES_AMES_V2_VALIDEE.png`
- **Format vérifié** : PNG RGB, 1536 × 1024, 2 959 540 octets.
- **SHA-256 du PNG conservé** : `3eeb3d573239ec8add99e92fbb7cffc434a77ada6cc4e5c6d2469fc1ed189688`.
- **Inspiration mythologique** : Isis, déesse égyptienne associée à la protection, la magie, la maternité et la renaissance ; les ailes protectrices et les symboles rituels sont réinterprétés librement.
- **Direction artistique** : sino-gothico-dark fantasy, silhouette féminine élancée et spectrale, visage dégagé, longue chevelure noire, **aucun chapeau ni couronne**, ailes noires et ivoire, ornements d'or patiné, étoffes blanches et rouges, fils rituels, bandelettes et motifs funéraires, fleurs de lotus.
- **Composition de la planche** : illustration principale, quatre vues de rotation, six expressions, études anatomiques et de matériaux, silhouettes, palette et deux variantes exploratoires (« Rituel funéraire », « Renaissance »).
- **Canon** : validation artistique uniquement ; titres, lore, symboles et variantes ne constituent pas automatiquement des validations narratives ou de gameplay.
- **Archivage GitHub binaire** : non vérifié ; la présence du présent registre ne prouve pas que le PNG est transféré.
- **Progression des 25 nouvelles planches** : 3 validées / 25 = 12 %. Projet global LITD 1 : À évaluer.


## Sobek — Le Seigneur des Eaux Noires — V1 (validation artistique)

- **Statut** : 🟢 planche V1 validée explicitement par l'utilisateur le 19 novembre 2026.
- **Fichier original validé** : `LITD1_BEST_EGY_SOBEK_SEIGNEUR_EAUX_NOIRES_V1_VALIDEE.png`.
- **Emplacement bibliothèque ChatGPT vérifié** : `/LITD 1/Bestiaire/Planches validées/LITD1_BEST_EGY_SOBEK_SEIGNEUR_EAUX_NOIRES_V1_VALIDEE.png`.
- **Format contrôlé** : PNG RGB 1536 × 1024, 3 088 643 octets.
- **Empreinte SHA-256 calculée sur l'image archivée** : `77b9d86f3c47b264911a21edafa41dc1cbd7771e820b30f1b043ea70e2ae9e50`.
- **Inspiration mythologique** : Sobek, divinité égyptienne à l'iconographie crocodilienne, associée au Nil, à la puissance et à la protection ; adaptation libre en créature LITD.
- **Direction artistique** : sino-gothico-dark fantasy ; gigantesque humanoïde crocodilien, museau allongé, mâchoire dentée, écailles gris-noir, longue queue épineuse, griffes, armure cérémonielle d'or patiné et de bronze, étoffes rouges, arme d'hast rituelle, environnement de marais et d'eaux noires.
- **Composition** : scène principale, quatre vues de rotation, six expressions, détails tête/main/épaule/queue, études de matières, palette, silhouettes et deux variantes exploratoires (« Tourbière rituelle », « Écailles dorées »).
- **Canon** : approbation de la planche artistique uniquement ; titres, lore, capacités et variantes ne sont pas automatiquement validés comme éléments narratifs ou mécaniques.
- **Archivage binaire GitHub** : non vérifié ; la description dans le registre ne vaut pas transfert du PNG.
- **Progression des 25 nouvelles planches** : 4/25 = 16 % de validations artistiques. Projet global LITD 1 : À évaluer.


## Anubis — Le Peseur des Âmes — V2 au katana blanc (validation artistique)

- **Validation** : planche V2 explicitement approuvée par l'utilisateur le 19 novembre 2026 (« J'adore, sauvegarde tout »). La V1 avec sceptre/balance tenue en main est remplacée comme référence visuelle par cette V2.
- **Fichier validé** : `LITD1_BEST_EGY_ANUBIS_PESEUR_DES_AMES_V2_VALIDEE.png`.
- **Bibliothèque ChatGPT** : `/LITD 1/Bestiaire/Planches validées/LITD1_BEST_EGY_ANUBIS_PESEUR_DES_AMES_V2_VALIDEE.png`.
- **Format source vérifié** : PNG RGB, 1536 × 1024.
- **SHA-256 calculé sur le PNG source de la planche validée** : `7b7b26fd93c0a2e884599bec168efe93b70b671c8272e6e8ce556fbeca0456e4`.
- **Inspiration mythologique** : Anubis, gardien des nécropoles et des rites funéraires, iconographie canidé noir, association à la pesée du cœur et au passage dans l'au-delà. L'interprétation en combattant à katana est une création originale LITD.
- **Silhouette** : grand humanoïde à tête de chacal noir, oreilles hautes, yeux dorés, armure funéraire noire et dorée à plaques acérées, étoffes et bandelettes blanches et rouges couvertes de marques rituelles, allure souveraine et spectrale.
- **Arme validée visuellement** : katana à lame **blanche**, longue et légèrement courbe, avec **inscriptions rouges** sur la lame ; garde dorée travaillée, poignée noire et rouge, fourreau rituel, énergie filamenteuse rouge. **Le sceptre de la V1 est supprimé**.
- **Direction artistique** : sino-gothico-dark fantasy, fusion de formes égyptiennes, chinoises et gothiques ; nécropole monumentale, lune rougeâtre, végétation rouge, lumière dramatique.
- **Composition de la planche** : illustration principale, quatre vues de rotation, six expressions, silhouettes, études tête/griffes/épaule/tsuba/lame/fourreau, palette et deux variantes exploratoires (« Gardien des Tombeaux », « Fléau des Âmes »).
- **Portée de la validation** : validation artistique de l'image et du katana ; pas de validation automatique des statistiques, du lore, des capacités, des numéros ou des variantes comme éléments canoniques.
- **Archivage binaire dans GitHub** : non vérifié ; le présent registre ne vaut pas transfert du PNG.
- **Progression artistique des 25 nouvelles planches** : 5/25 = 20 %. Avancement global LITD 1 : À évaluer.

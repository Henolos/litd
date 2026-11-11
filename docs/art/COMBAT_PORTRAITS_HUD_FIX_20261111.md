# Correction portraits et HUD LITD 1 — 11 novembre 2026

## Périmètre et état de départ

Branche dédiée depuis main `14f214278b26628e8e9b6d8bdc5b79227d169d02`. #610 fusionnée (`23fabf00`) : originaux archivés mais planches complètes affichées, sans portrait dérivé ni validation visuelle. #609 est fusionnée ; #606–#608, #602 et #612 restent distinctes et ouvertes. #612 modifie les ennemis et le même registre ; conserver ses méthodes `enemy_*` lors de la réconciliation du registre. Aucun contenu de ces PR n’est incorporé ici. Les anciennes branches portraits sont déjà dans l’ascendance de main. La branche historique `fix/hud-latest-main-v2` porte sur le sandbox : les fonctions de préparation/focus existent déjà dans le sandbox actuel ; le défaut signalé provient du combat de campagne v30/v52.

La capture Windows fournie a été réellement consultée. Une reproduction depuis main est conservée dans `evidence/combat-hud-20261111/before-main.png`. Le chemin courant d’entrée Windows est `project.godot` → `scenes/Main.tscn` → `main_v52.gd` → pile héritée, dont `main_v30.gd` pour le champ de combat. Le preset Windows exporte toutes les ressources. L’identité exacte du binaire de la capture n’est pas déduite de son titre : son commit n’est pas connu.

## Causes et correction

1. Les chargeurs `hero_art()` et v52 injectaient les JPEG complets. Quatre ressources AtlasTexture cadrent les bustes dans les originaux, sans toucher à leurs octets. Les portraits restent issus de la planche exacte : aucune génération ni substitution. `hero_portrait_bindings` centralise les chemins pour le profil, le combat et le slot v41.
2. Les séparations négatives des rangées faisaient chevaucher les emplacements. Les rangées, marqueurs de rang et zones d’inspection utilisent des espacements positifs cohérents.
3. Les compétences cumulaient nom, rangs et cibles ; leur hauteur atteignait 92 px et recouvrait la rangée de commandes. Le nom reste sur une ligne, avec une hauteur logique minimale de 48 px. Portée et rangs apparaissent au survol/focus, dans l’aide contextuelle et dans le choix de cible ; les callbacks métier sont conservés.
4. `crypts.webp` est un concept avec personnages, PV et compteur de vague imprimés. Il ne peut servir de décor derrière les combattants vivants. Le combat utilise la surface sombre existante, en attendant un décor sans interface approuvé. Le fichier conceptuel reste intact. Ce choix est visible et réversible, sans inventer de nouvel environnement.
5. Les contrôles supprimés restaient attachés jusqu’à la fin de l’image ; une reconstruction pouvait retrouver les anciens portraits/boutons puis masquer les nouveaux. `clear_content()` détache immédiatement les anciens enfants avant leur libération différée.
6. Les menus Objets/Position conservaient une hauteur transitoire excessive produite avant calcul de la largeur des textes. Après la mise en page, ils sont ajustés à leur minimum réel et restent au-dessus des compétences.
7. Les états focus/pressed/disabled disposent de styles sombres explicites et les cibles d’un bronze moins lumineux. Les PV réels restent visibles avec l’identité et le rang. Aucun changement des identités jouables, statistiques, formules, inventaires ou anatomies.

## Traçabilité artistique

Les six SHA-256 ont été recalculés et comparés à `validated_heroes_manifest_20261111.json`. Les six JPEG, leurs noms et leur manifeste sont inchangés. Les ressources dérivées ne contiennent que des références et régions en pixels :

| Héros | Région x, y, largeur, hauteur |
| --- | --- |
| Mathilde | 250, 22, 188, 282 |
| Marec | 240, 18, 200, 300 |
| Anouk | 300, 20, 230, 345 |
| Aurélien | 260, 24, 220, 330 |

Référence technique consultée : [Godot AtlasTexture](https://docs.godotengine.org/en/stable/classes/class_atlastexture.html), propriétés `region` et `filter_clip`. Les deux moteurs de recherche renvoyaient 503 ; la documentation officielle a été récupérée directement par HTTPS. La correction découle principalement de l’inspection du code et des rendus réels, pas d’une recommandation artistique externe.

## Contrôles et limites

Les preuves finales sont ajoutées après l’exécution sur le commit de correction. Le script `combat_portrait_hud_capture.gd` charge la vraie scène et vérifie identités/cadrages, non-chevauchement, commandes dans le viewport, clics compétences/inspection/objets/position et absence de mutation des héros lors de la préparation. Il couvre fenêtres 960×540, 1280×720, 1920×1080, format compact 844×390 et plein écran pour le rendu. Le format compact conserve le ratio du jeu : le viewport rendu est 693×390, sans redimensionnement artificiel des preuves. Cela démontre le cadrage et les interactions simulées, pas une ergonomie tactile physique validée. La réconciliation des images d’ennemis reste dans #612.

Le workflow de rendu existant conserve ses huit captures sandbox et ajoute 21 captures du vrai combat de campagne. Les exports vérifient aussi le chargement des quatre AtlasTexture dans le paquet. Les résultats CI et le fonctionnement du binaire Windows doivent être contrôlés avant toute validation finale. Aucun succès Linux ne prouve une exécution native Windows. Les avertissements ObjectDB/ressources à la fermeture sont consignés, sans les confondre avec une erreur de script ou les déclarer résolus.

Chantier : Correction portraits et HUD LITD 1 — 🟠 EN COURS. Avancement du chantier actuel : À évaluer avant consolidation des preuves finales. Avancement du projet global : À évaluer. Pas de fusion tant que les validations obligatoires manquent.

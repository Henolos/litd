# Audit des images actives — LITD 1 — 2026-11-11

## Méthode
Lecture de l'arbre GitHub REST `/repos/Henolos/litd/git/trees/main?recursive=1` sur main `ee634021eb0e31334a63bf94d3889d36862e53a6`. Réponse non tronquée : 2 756 entrées. Filtre des extensions PNG/JPEG/JPG/WEBP/SVG/TGA/BMP/GIF.

## Résultat
68 images : 23 dans `assets/heroes/`, 39 dans `assets/enemies/`, 5 arrière-plans (dont sanctuary), 1 dans `docs/concept_art/enemies/`.

### Héros — 23 images à auditer avant suppression
`assets/heroes/{breaker,breaker_2,duelist,duelist_2,inquisitor,inquisitor_2,mystic,mystic_2,occultist,occultist_2,ranger,ranger_2,scout,surgeon,surgeon_2,vestal,vestal_2,watcher,watcher_2}.webp`
et `assets/heroes/canonical/{anouk,aurelien,marec,mathilde}.svg`.

### Ennemis — 39 images à auditer avant suppression
`assets/enemies/enemy_01.webp` à `assets/enemies/enemy_39.webp`.

### Autre référence ennemis
`docs/concept_art/enemies/first_level_enemy_palette.webp`.

## Références approuvées reçues
Six planches JPEG distinctes : Aurélien, Marec, Anouk, Mathilde, Éffrie, Lya. Les SHA-256 et chemins cibles sont dans `docs/art/validated_heroes_manifest_20261111.json`. Validation artistique utilisateur acquise ; octets non encore archivés dans GitHub.

## Sécurité de migration
1. Retrouver les dépendances exactes des 23 images héros et 39 ennemis dans les scènes, scripts, ressources et tests.
2. Importer les six JPEG originaux sans retouche, contrôler les SHA-256 récupérés de GitHub.
3. Modifier le registre de portraits pour viser les chemins canoniques ; conserver les identités de gameplay.
4. Tester import Godot, affichage des héros, ciblage, sauvegardes, web/PWA et merge_group.
5. Supprimer uniquement les anciennes images devenues sans référence, en conservant les images d'ennemis utiles jusqu'à leur remplacement validé.

**Aucune suppression ni migration runtime effectuée à ce stade.**
- Avancement chantier : À évaluer.
- Avancement global : À évaluer.

# Premier Accord : vestibule physique

La scène `res://scenes/dungeons/first_accord_entry_vestibule.tscn` matérialise
`accord_entry_vestibule_v1` : sol de 20 × 14 m, murs et collisions statiques,
ouverture nord de 4 m, sortie sud de 4 m et région de navigation à polygones
prédéfinis. Son origine est au centre du sol. Les marqueurs
`Connectors/north` et `Connectors/exit` se trouvent respectivement en
`(0, 0, -7)` et `(0, 0, 7)`. Le catalogue porte son `scene_path`.

Exécuter depuis la racine du projet :

```bash
godot --headless --path . res://scenes/tests/first_accord_entry_physical_smoke.tscn
```

Le test charge la scène, confronte ses connecteurs au catalogue, lance des
rayons contre le sol et le mur nord, vérifie que la porte est libre et
interroge NavigationServer3D pour traverser le seuil vers un tronçon de
réception. Il attend la synchronisation du serveur avant la requête.
La scène est également testée dans le domaine CI `veilleurs`.

Ce premier module n'est pas encore substitué à la salle du niveau fixe.
Dans `first_map_hall_of_first_accord_map.json`, le vestibule est centré en
`(0, -6, 48)` ; `c01` rejoint la galerie en diagonale et descend d'un mètre.
Les connexions `c02` et `c12` rencontrent aussi le vestibule. Avant
l'intégration au niveau jouable, créer la galerie et les raccords physiques
de ces trois liaisons, puis vérifier collisions, pente, navigation et retour
en arrière avec un personnage dans Godot. Le test actuel prouve le seuil
modulaire droit, pas le trajet complet de la carte fixe.

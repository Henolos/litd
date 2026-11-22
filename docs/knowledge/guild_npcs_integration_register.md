# LITD 1 — Registre de préparation des personnages de la Guilde

Statut : dix fichiers répartis sur cinq personnages dans la branche PR #631. Les six premiers chargent sous Godot 4.7.2 ; les quatre ajoutés le 22 novembre sont transférés avec leurs SHA-256 contrôlés, import Godot et revue visuelle des portraits encore à faire. PR non fusionnée, scènes non raccordées.
Référence : décisions de validation du 22 novembre 2026. Ne pas remplacer les originaux artistiques par des images recréées.

| Identifiant stable proposé | Nom validé | Rôle | Validation artistique | Fichiers contrôlés dans la branche PR | Import/chargement Godot |
|---|---|---|---|---|---|
| kelia_anzora | Kélia Anzora | À reprendre de la fiche validée | Oui, selon validation utilisateur | Planche + portrait 3:4, SHA-256 conformes | Importés et chargés ; scènes non raccordées |
| lian_yue | Lian Yue | Responsable du recrutement | Oui, selon validation utilisateur | Planche + portrait 3:4, SHA-256 conformes | Importés et chargés ; scènes non raccordées |
| soleyman | Soleyman | Marchand de la Guilde | Oui, selon validation utilisateur | Planche + portrait 3:4, SHA-256 conformes | Importés et chargés ; scènes non raccordées |
| maitresse_armes | Shen Yulan | Maîtresse d’armes | Planche validée ; recadrage du portrait à confirmer | Planche + portrait 3:4, SHA-256 conformes | Import Godot et revue du recadrage en attente |
| wei_shan | Wei Shan | Archiviste | Planche validée ; recadrage du portrait à confirmer | Planche + portrait 3:4, SHA-256 conformes | Import Godot et revue du recadrage en attente |

## Contraintes impératives

- Soleyman remplace « Rashid al-Khârim » sans changement de son identité visuelle validée.
- Lian Yue gère le recrutement ; ses relations peuvent débloquer des héros et leurs histoires/quetes propres.
- Soleyman peut proposer des quêtes exceptionnelles ; l'amélioration du commerce et la relation sont deux axes distincts de déblocage.
- Ne pas inventer les caractéristiques non retrouvées de Kélia Anzora.
- Les planches, noms et personnalités validés sont des sources maîtresses, non des brouillons à redessiner.
- Conserver les fichiers binaires d'origine et vérifier leurs empreintes avant toute affirmation d'intégrité.
- Vérifier les chemins et conventions des ressources existantes du maître de la Guilde avant de créer les fiches runtime, scènes ou références.
- Aucun personnage ne doit être annoncé « prêt pour le jeu » avant la présence contrôlée des ressources, la résolution des références et un test d'import Godot.

## Étapes restant à exécuter

1. Les quatre nouvelles ressources (deux planches et deux portraits) ont été ajoutées à leurs dossiers ; leurs empreintes de l’archive sont contrôlées.
2. Faire importer et charger les nouveaux portraits dans Godot 4.7.2 ; le test du catalogue couvre désormais les cinq PNJ.
3. Confirmer visuellement les deux recadrages de portraits.
4. Raccorder les personnages aux scènes de Guilde et valider leur affichage en jeu après décision de fusion.

Les quatre nouveaux fichiers sont présents dans la branche PR #631 ; cette PR reste ouverte et non fusionnée.

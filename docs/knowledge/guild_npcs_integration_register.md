# LITD 1 — Registre de préparation des personnages de la Guilde

Statut : six fichiers transférés et contrôlés dans la branche ouverte de la PR #631 ; import/chargement Godot validé. PR non fusionnée et scènes de Guilde non raccordées au runtime.
Référence : décisions de validation du 22 novembre 2026. Ne pas remplacer les originaux artistiques par des images recréées.

| Identifiant stable proposé | Nom validé | Rôle | Validation artistique | Fichiers contrôlés dans la branche PR | Import/chargement Godot |
|---|---|---|---|---|---|
| kelia_anzora | Kélia Anzora | À reprendre de la fiche validée | Oui, selon validation utilisateur | Planche + portrait 3:4, SHA-256 conformes | Importés et chargés ; scènes non raccordées |
| lian_yue | Lian Yue | Responsable du recrutement | Oui, selon validation utilisateur | Planche + portrait 3:4, SHA-256 conformes | Importés et chargés ; scènes non raccordées |
| soleyman | Soleyman | Marchand de la Guilde | Oui, selon validation utilisateur | Planche + portrait 3:4, SHA-256 conformes | Importés et chargés ; scènes non raccordées |

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

1. Ressources (3 planches et 3 portraits) transférées dans la branche PR #631 ; les six empreintes GitHub ont été comparées aux originales et correspondent.
2. Les six ressources ont été importées et chargées dans Godot 4.7.2 ; test du catalogue runtime ajouté.
3. La PR reste ouverte et non fusionnée, selon la consigne.
4. Reste à raccorder les personnages aux scènes de Guilde et à valider leur affichage en jeu après décision de fusion.

Ce registre n'est **pas** une preuve que les fichiers images sont sauvegardés dans GitHub.

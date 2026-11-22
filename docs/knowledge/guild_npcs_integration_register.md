# LITD 1 — Registre de préparation des personnages de la Guilde

Statut : préparation documentaire, **non intégrés au runtime Godot**.
Référence : décisions de validation du 22 novembre 2026. Ne pas remplacer les originaux artistiques par des images recréées.

| Identifiant stable proposé | Nom validé | Rôle | Validation artistique | PNG original contrôlé dans le dépôt | Intégration Godot |
|---|---|---|---|---|---|
| kelia_anzora | Kélia Anzora | À reprendre de la fiche validée | Oui, selon validation utilisateur | Non vérifié | Non effectuée |
| lian_yue | Lian Yue | Responsable du recrutement | Oui, selon validation utilisateur | Non vérifié | Non effectuée |
| soleyman | Soleyman | Marchand de la Guilde | Oui, selon validation utilisateur | Non vérifié | Non effectuée |

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

1. Localiser les trois PNG originaux validés et leurs fiches complètes ; transférer les binaires manquants.
2. Calculer les empreintes SHA-256 et vérifier les images réellement présentes dans GitHub.
3. Créer les fiches de données au format du projet, sans doublonner les systèmes existants.
4. Associer les ressources aux scènes de Guilde et vérifier les références.
5. Lancer l'import Godot et les tests de chargement, puis documenter les résultats.

Ce registre n'est **pas** une preuve que les fichiers images sont sauvegardés dans GitHub.

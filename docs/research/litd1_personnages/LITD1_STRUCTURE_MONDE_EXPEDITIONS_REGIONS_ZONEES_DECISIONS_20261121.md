# LITD 1 — Structure du monde : expéditions par quête et régions zonées

Date : 2026-11-21
Statut : 🟢 DÉCISIONS DE CONCEPTION EXPLICITEMENT VALIDÉES ; aucune implémentation.

## Décisions utilisateur
1. Le joueur ne progresse dans une région qu'après avoir choisi une quête.
2. Les régions se débloquent progressivement avec la progression du jeu.
3. Chaque région est divisée en zones à la manière de Monster Hunter.
4. Les régions comprennent notamment des donjons et des événements aléatoires.

Ces décisions remplacent, pour la structure de progression, l'hypothèse antérieure d'un monde ouvert ou de régions librement parcourues indépendamment des quêtes.

## Boucle d'expédition proposée, NON VALIDÉE dans ses détails
Choix de quête → préparation de compagnie → départ vers région accessible → exploration de zones → objectifs, donjons et événements → retour et progression.

## Points à arbitrer
- Une quête permet-elle l'exploration de toutes les zones de la région ou seulement d'un sous-ensemble ?
- Les zones sont-elles reliées sans chargement apparent, par transitions ou par carte ?
- Peut-on poursuivre l'exploration après l'objectif principal de la quête ?
- Événements aléatoires : tables, conditions, persistance et fréquence.
- Donjons : fixes, variantes procédurales ou mélange.
- Conditions de déblocage des régions : quête principale, rang de Guilde ou autre.
- Gestion de l'échec, retraite, temps d'expédition et conservation des ressources.
- Accès aux régions précédentes via de nouvelles quêtes.

## Règle de traçabilité
Ne pas confondre les quatre décisions validées ci-dessus avec les exemples et hypothèses non validés. Aucun code, aucune carte, aucun niveau ni test Godot n'ont été créés à cette étape.

Avancement du chantier actuel : À évaluer.
Avancement du projet global LITD 1 : À évaluer.

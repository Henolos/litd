# LITD 1 — Personnages de la Guilde : continuité et interactions

Statut : **référence de conception sauvegardée**. Les caractéristiques des planches validées ne doivent pas être réécrites ; les dialogues ci-dessous sont des propositions, non des validations narratives.

## Décisions conservées
- Maître de la Guilde : autorité, missions, secret personnel révélé tardivement et secret distinct de l'origine de la Guilde.
- Kélia Anzora : administration, contrats, rangs, primes et archives ; prototype d'inscription de quatre aventuriers au rang S.
- Lian Yue : recrutement, constitution des compagnies, accompagnement et déblocage possible d'histoires individuelles.
- Soleyman : marchand, fournisseur et antiquaire ; relations, amélioration du commerce et quêtes exceptionnelles ; ancien nom Rashid al-Khârim abandonné.
- Ne jamais révéler la signification du rang S ni l'omelette avant le retour de « La cueillette ».
- Les originaux visuels et portraits doivent conserver des empreintes SHA-256 vérifiées. L'intégration binaire et les tests Godot restent des contrôles séparés.

## Architecture cible (non implémentée)
Réutiliser DataLoader, data/dialogues.json et data/quests.json après examen de leurs consommateurs. Éviter de créer un second système d'état ou de quêtes.
- Dialogue : identifiant de PNJ, noeuds, choix, conditions, conséquences.
- Effets : dispatcher vers les systèmes existants de quêtes, inventaire, relations et sauvegarde, après identification des API.
- Présentation : portrait, texte, choix et fermeture ; fonctionnement clavier/manette.
- Validation : tests de schéma, branches de dialogue, persistance et absence de révélations prématurées.

## Prochaines études de personnages
1. Lian Yue : accueil de la compagnie, explication du recrutement et premières interactions.
2. Soleyman : rencontre et présentation de la boutique sans révéler le motif de la quête de cueillette.
3. Kélia : cohérence des contrats et du rang S avec les événements de fin du prologue.
4. Maître de la Guilde : articuler ses interventions sans divulguer ses secrets.

Aucune ligne proposée ci-dessous n'est canonique sans validation.

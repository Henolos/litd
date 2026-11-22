# LITD 1 — Registre de préparation des personnages de la Guilde

Statut : sept personnages référencés dans la branche de la PR #631. Les planches validées de Han Lu et Dr Mei Ling sont ajoutées et leurs SHA-256 contrôlés. Les deux planches doivent être importées sous Godot ; leurs portraits dédiés et le raccordement aux scènes de Guilde restent à faire. PR ouverte, non fusionnée.
Référence : décisions de validation et archive d’intégration du 22 novembre 2026. Ne pas remplacer les originaux artistiques par des images recréées.

| Identifiant | Nom | Rôle | Ressources | État |
|---|---|---|---|---|
| kelia_anzora | Kélia Anzora | Administration de la Guilde | Planche + portrait | Importés et chargés ; scènes non raccordées |
| lian_yue | Lian Yue | Recrutement | Planche + portrait | Importés et chargés ; scènes non raccordées |
| soleyman | Soleyman | Marchand | Planche + portrait | Importés et chargés ; scènes non raccordées |
| maitresse_armes | Shen Yulan | Maîtresse d’armes | Planche + portrait | Recadrage du portrait à revoir ; scènes non raccordées |
| wei_shan | Wei Shan | Archiviste | Planche + portrait | Recadrage du portrait à revoir ; scènes non raccordées |
| han_lu | Han Lu | Tavernier, ancien aventurier | Planche validée (1536×1024) | SHA-256 vérifié ; import Godot et portrait dédié en attente |
| dr_mei_ling | Dr Mei Ling | Médecin | Planche validée (1536×1024) | SHA-256 vérifié ; import Godot et portrait dédié en attente |

## Éléments validés pour les deux nouveaux personnages

- Han Lu est un ancien aventurier marqué par des cicatrices. Il raconte des anecdotes de quêtes et pourra proposer des quêtes spéciales et des déblocables liés à l’affinité.
- Dr Mei Ling est une médecin hors pair, passionnée par la dissection et l’anatomie. Son humour noir la pousse à recommander l’amputation pour une simple coupure. Ses missions pourront enrichir le bestiaire, notamment en débloquant les faiblesses des ennemis.
- Les quêtes, affinités et récompenses sont enregistrées comme systèmes prévus ; leurs détails de gameplay ne sont pas encore définis.
- Les planches complètes ne sont pas utilisées comme portraits de dialogue ou de combat. Il faut fournir et valider des crops dédiés avant de renseigner `art_path`.
- Soleyman remplace « Rashid al-Khârim » sans changement de son identité visuelle validée.
- Ne pas inventer les caractéristiques non retrouvées de Kélia Anzora. Conserver les fichiers binaires d’origine et contrôler leurs empreintes.
- Aucun personnage ne doit être annoncé prêt pour le jeu avant le chargement contrôlé des ressources, la résolution des références et le test des scènes.

## Étapes restantes

1. Importer et charger sous Godot les deux planches de Han Lu et Dr Mei Ling.
2. Créer puis faire valider des portraits individuels adaptés aux interfaces et au combat.
3. Raccorder les sept personnages aux scènes de la Guilde et vérifier leur affichage en jeu.
4. Réexécuter la CI de la PR avant toute décision de fusion.

# LITD 1 : frontière archive / nouvelle bibliothèque

Décision du 12 novembre 2026 : l'ancien code devient une archive historique en lecture seule, jamais une source d'implémentation pour le nouveau jeu.

## Autorisé
- Lore des deux bibles fournies, avec provenance et contradictions préservées.
- Décisions narratives et artistiques validées.
- Originaux des héros et du bestiaire après identification, preuve de validation, droits et contrôle SHA-256.
- Concepts de gameplay retenus, à reconcevoir sans copier le code historique.

## Interdit
- Copier ou importer les anciens scripts, scènes Godot, autoloads, configurations, tests, workflows, binaires et systèmes.
- Utiliser data/canonical_art_v41.json comme configuration du nouveau jeu : ce registre est une source historique de provenance seulement.
- Remplacer un original manquant par une image générée ou déduire une identité d'une ressemblance.
- Considérer une CI historique comme validation du nouveau jeu.

## Procédure de reconstruction
1. Identifier et figer le commit de l'ancien dépôt privé, sans toucher à main.
2. Inventorier les originaux avec identifiant, source, statut de validation, chemin, SHA-256 recalculé, droits et destination.
3. Créer un nouveau projet Godot vierge et une bibliothèque de contenu indépendante.
4. Contrôler l'absence de dépendances ou d'import de code de l'ancien projet.
5. Valider les ressources visuellement dans le nouveau projet.

## Preuves et limites au 12 novembre 2026
- METHODE_TRAVAIL_REFERENCE.md lu sur main.
- docs/art/hero_cleanup_evidence_20261111.json lu sur main.
- docs/art/BESTIARY_RUNTIME_MAPPING_20261111.md lu au commit 79d67181.
- Quatre JPEG héros accessibles sur GitHub : Mathilde, Anouk, Marec et Aurélien. SHA-256 non recalculés.
- PR #609 fusionnée : archivage de 21 originaux documenté ; pas de nouveau contrôle indépendant des binaires.
- Cinq correspondances confirmées par le document : Gorgone ID 6 planche 5 ; Minotaure ID 7 planche 4 ; Oni ID 8 planche 15 ; Jorōgumo ID 10 planche 17 ; Yuki-Onna ID 11 planche 19.

Statut : À CONSOLIDER. Avancement du chantier actuel : À évaluer. Avancement du projet global : À évaluer.
Ce document n'autorise aucune suppression ni migration automatique.
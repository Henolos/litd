# LITD 1 — Fondation de la bibliothèque artistique

Statut : six originaux importés et vérifiés depuis GitHub ; migration technique réalisée, nettoyage des ressources inutilisées en validation CI. La réconciliation du bestiaire reste ouverte.

## Objectif
Un registre canonique unique pour les planches, personnages secondaires, équipements, objets, décors et interfaces. Les PR #607, #608 et #609 restent des sources historiques tant que leurs données ne sont pas réconciliées. Ne pas supprimer ni fermer ces PR avant reprise vérifiée.

## Validation artistique du propriétaire
Toute planche artistique transmise par le propriétaire du projet est considérée comme validée et devient la référence officielle du personnage concerné. Une planche plus récente fournie par le propriétaire remplace la référence artistique antérieure. Les anciennes versions ne doivent plus être présentées comme officielles. Cette validation artistique est acquise indépendamment des contrôles d'intégrité, d'archivage et d'intégration technique, qui restent obligatoires.

Les références officielles actuelles sont Mathilde, Marec, Anouk, Aurélien, Éffrie et Lya, selon le manifeste `validated_heroes_manifest_20261111.json`. Éffrie et Lya restent des entrées artistiques : aucune activation dans le quatuor jouable sans décision spécifique du propriétaire.

## Règles
1. Une ressource reçoit un identifiant immuable indépendant de son numéro de planche imprimé, de son nom et de son chemin.
2. Conserver distincts : espèce/sujet, planche, fichier original, version, variante, état de validation artistique, état d'archivage, état d'intégration Godot.
3. Une validation de conception ne valide ni un rendu précis ni son archivage. Un texte ou une empreinte seule ne constitue pas un fichier binaire archivé.
4. Conserver le nom original, le format, les dimensions, le SHA-256 complet, la provenance, les droits à vérifier, le chemin canonique et la preuve de validation.
5. Préserver les octets originaux sans recompression ni retouche. Comparer les empreintes avant import, puis après récupération de GitHub. Une référence plus récente fournie par le propriétaire remplace le fichier courant par commit normal, sans réécrire l'historique Git.
6. Ne pas déplacer les ressources Godot existantes sans audit des références, UID et tests.
7. Les PR de lots artistiques sont séparées des PR gameplay. Le catalogue est unique, mais chaque PR doit rester cohérente et contrôlable.
8. Vérifier en CI les schémas, l'unicité des identifiants, les chemins et les empreintes disponibles ; respecter pull_request et merge_group si requis.
9. Aucun statut « archivé » sans vérification du fichier réellement récupéré ; aucune fusion hors protections de main et merge queue.

## Inventaire documentaire initial (non audit des binaires)
- PR #607 : registre de 40 espèces et décisions de direction artistique ; neuf espèces déclarées validées historiquement, sans correspondance binaire démontrée.
- PR #608 : 21 planches distinctes identifiées dans le suivi documentaire ; toutes signalées non archivées dans GitHub.
- PR #609 : réconciliation partielle ; archive locale de sept images signalée, non importée dans la PR.
- PR #606 : anatomies pilotes Oni, Manticore et Jorōgumo ; travail gameplay distinct à ne pas incorporer dans la PR de bibliothèque.

## Conflits ouverts
| Sujet | Conflit | Action requise |
| --- | --- | --- |
| Kitsune | n°21 sur une source, n°26 canonique décidé ensuite ; versions corrigées divergentes | Identifier et contrôler les octets de la version n°26 |
| Draugr | n°16 historique, n°21 sur une planche ultérieure | Rapprocher la source visuelle et l'identifiant stable |
| Oni V5 | assombrissement demandé dans #607, validation déclarée dans #608 | Dater les décisions et identifier le fichier exact |
| Golem runique | attente imprimée puis validation déclarée ultérieurement | Relier validation et fichier exact |
| Wendigo / Loup décharné | dénominations et variantes distinctes | Ne pas substituer la variante à tête de cerf à celle à tête de loup |
| Valkyrie n°23 | plusieurs fichiers candidats | Départager la version finale |
| Référence graphique | Basilic initial, Hydre n°13 ensuite | Documenter la chronologie et la portée |

## Schéma cible minimal
```json
{
  "asset_id": "LITD-ENM-0001",
  "subject": "example",
  "category": "enemy",
  "plate_number_printed": null,
  "plate_number_canonical": null,
  "version": null,
  "source_filename": null,
  "sha256": null,
  "storage_path": null,
  "provenance": null,
  "rights_status": "to_review",
  "art_approval": "unverified",
  "binary_archived": false,
  "godot_integrated": false,
  "approval_evidence": null
}
```
Exemple de structure uniquement : l'identifiant illustratif n'est attribué à aucun ennemi réel.

## Séquence d'exécution
1. Vérifier les contenus et dépendances des PR #606 à #609, et retrouver les originaux.
2. Construire un inventaire dédoublonné par SHA-256 et un tableau de correspondance des numéros historiques.
3. Définir puis tester un schéma de catalogue et un importateur en simulation.
4. Importer un petit lot sans écrasement et vérifier les empreintes après récupération.
5. Ajouter les contrôles CI, y compris merge_group si nécessaire.
6. Appliquer les validations artistiques du propriétaire déjà acquises, vérifier les correspondances des fichiers et l'intégration technique, puis proposer la fusion selon les protections.

## Suivi
- Avancement du chantier actuel : À évaluer.
- Avancement global LITD 1 : À évaluer.
- Six planches originales importées (SHA-256 avant/après GitHub conformes) ; portraits canoniques et références Blender migrés ; contrôles automatiques du catalogue et du paquet Web ajoutés. Les validations sont détaillées dans l’audit technique ; les contrôles du dernier commit restent requis avant fusion.
- Audit technique actualisé : `HERO_RUNTIME_DEPENDENCIES_20261111.md`.

# LITD 1 — Fondation de la bibliothèque artistique

Statut : proposition de gouvernance, sans import d'images et sans validation artistique supplémentaire.

## Objectif
Un registre canonique unique pour les planches, personnages secondaires, équipements, objets, décors et interfaces. Les PR #607, #608 et #609 restent des sources historiques tant que leurs données ne sont pas réconciliées. Ne pas supprimer ni fermer ces PR avant reprise vérifiée.

## Règles
1. Une ressource reçoit un identifiant immuable indépendant de son numéro de planche imprimé, de son nom et de son chemin.
2. Conserver distincts : espèce/sujet, planche, fichier original, version, variante, état de validation artistique, état d'archivage, état d'intégration Godot.
3. Une validation de conception ne valide ni un rendu précis ni son archivage. Un texte ou une empreinte seule ne constitue pas un fichier binaire archivé.
4. Conserver le nom original, le format, les dimensions, le SHA-256 complet, la provenance, les droits à vérifier, le chemin canonique et la preuve de validation.
5. Ne jamais écraser un original ; importer d'abord en zone de revue, comparer les empreintes, puis promouvoir une version exacte après vérification.
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
6. Faire valider les correspondances visuelles, puis proposer la fusion selon les protections.

## Suivi
- Avancement du chantier actuel : À évaluer.
- Avancement global LITD 1 : À évaluer.
- Aucun binaire importé, aucune CI ajoutée, aucune validation artistique nouvelle.

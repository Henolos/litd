# Trieur V4 — gouvernance canonique et cycle de vie

Le Trieur V4 unifie trois niveaux auparavant séparés :

1. le **Canon Freshness Gate**, qui empêche une build de rejouer un canon périmé ;
2. le **Trieur lifecycle**, qui décide si un contenu est `canonical`, `active`, `superseded` ou `archived` ;
3. le **LITD File Sorter**, qui analyse physiquement les fichiers, leurs versions, références et éventuels candidats à l'archivage/suppression.

Le principe central est qu'aucune heuristique de classement ne peut, à elle seule, déclasser ou supprimer une vérité canonique.

## Registre vivant

`governance/trieur_policy.json` est désormais un registre réel, et non plus vide. La première source gouvernée est `data/heroes.json`, enregistrée sous la clé canonique `litd.starting_quartet` pour Mathilde, Marec, Anouk et Aurélien.

Chaque entrée possède au minimum :

- `id` ;
- `path` ;
- `status`.

Elle peut aussi déclarer :

- `canonical_key` et `canon_version` ;
- `replaced_by` ;
- `runtime_tokens` ;
- `archive_enabled` et `archive_target` ;
- `archive_state`, `previous_path` et `archived_sha256` après déplacement.

## Validation du cycle de vie

`tools/ci/trieur_governance_gate.py` vérifie notamment :

- statuts et identifiants ;
- chemins relatifs confinés au dépôt et aux racines gouvernées ;
- unicité des clés canoniques ;
- existence des cibles `replaced_by` ;
- interdiction des auto-remplacements et cycles de remplacement ;
- cohérence des champs d'archive ;
- confinement des contenus déjà déplacés sous `archive/` ;
- absence de références runtime déclarées vers des contenus inactifs.

## Pont avec le File Sorter

`tools/ci/trieur_file_sorter_bridge.py` impose que toute entrée `canonical` du Trieur soit également présente dans `data/maintenance/canonical_files.json` sous `canonical_paths`.

Inversement, une entrée `superseded` ou `archived` du Trieur ne peut pas rester protégée comme canonique par le File Sorter. Une même ressource ne peut donc plus être « canonique » pour un système et « obsolète » pour l'autre.

Le manifeste du File Sorter protège également les fichiers de gouvernance du Trieur eux-mêmes.

## Archivage physique sécurisé

`tools/ci/trieur_safe_archive.py` reste en dry-run par défaut. L'application réelle exige toujours :

1. `status: archived` ;
2. `archive_enabled: true` ;
3. une destination sous `archive/` ;
4. aucune collision ;
5. une branche autre que `main` / `master` ;
6. `TRIEUR_ARCHIVE_ACK=I_UNDERSTAND_ARCHIVE_MOVE` ;
7. une vérification SHA-256 de la copie.

V4 ajoute deux protections :

- les sources ou descendants symboliques sont refusés ;
- après un déplacement réussi, le registre est mis à jour automatiquement (`previous_path`, nouveau `path`, `archive_state: moved`, `archive_enabled: false`, SHA-256). Si cette mise à jour échoue, le déplacement est restauré vers sa source.

## CI

Le workflow `Trieur Governance` exécute désormais dans la même chaîne :

1. le contrôle lifecycle ;
2. le pont Trieur ↔ File Sorter ;
3. le dry-run de l'archivage physique.

Le workflow `LITD File Sorter Audit` conserve en parallèle ses tests de maintenance, son audit d'intelligence du dépôt et ses garanties anti-suppression automatique.

Cette séparation des responsabilités reste volontaire : le Trieur décide du statut canonique, le File Sorter inspecte la réalité physique, et la CI bloque toute contradiction entre les deux.

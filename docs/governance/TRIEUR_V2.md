# Trieur V2 — gouvernance du cycle de vie

Le Trieur V2 complète le Canon Freshness Gate. Son rôle est de gérer explicitement le cycle de vie des contenus afin qu'une ancienne vérité ne puisse pas redevenir active par accident.

## Statuts

- `canonical` : source de vérité officielle pour une clé canonique donnée.
- `active` : contenu valide et utilisable, sans être l'unique source canonique.
- `superseded` : contenu remplacé. Il doit déclarer `replaced_by`.
- `archived` : contenu conservé pour historique, non utilisable comme vérité runtime.

## Registre

Le fichier `governance/trieur_policy.json` est le registre de politique. Les contenus nécessitant un suivi de cycle de vie y sont déclarés avec au minimum :

- `id`
- `path`
- `status`

Les entrées peuvent aussi déclarer :

- `canonical_key` pour garantir qu'une seule entrée est canonique pour un sujet donné ;
- `replaced_by` pour relier une version remplacée à son successeur ;
- `runtime_tokens` pour empêcher les fichiers runtime de continuer à référencer une entrée inactive ;
- `archive_enabled: true` pour autoriser explicitement un déplacement physique ;
- `archive_target` pour indiquer la destination sous `archive/`.

## Contrôles CI

`tools/ci/trieur_governance_gate.py` vérifie :

1. la validité des statuts ;
2. l'unicité des identifiants ;
3. l'existence des chemins déclarés ;
4. l'unicité des clés canoniques ;
5. la présence d'un remplacement pour toute entrée `superseded` ;
6. l'absence de références runtime déclarées vers des contenus `superseded` ou `archived`.

Le workflow `Trieur Governance` s'exécute sur les changements touchant le registre, les données, les scènes, les scripts et la documentation gouvernée.

## Archivage physique sécurisé

`tools/ci/trieur_safe_archive.py` est en **dry-run par défaut**. Il ne déplace rien tant que `--apply` n'est pas demandé.

Un déplacement physique n'est autorisé que si toutes les conditions suivantes sont vraies :

1. l'entrée est déjà marquée `archived` ;
2. `archive_enabled` vaut explicitement `true` ;
3. `archive_target` est présent et reste strictement sous `archive/` ;
4. la source existe et reste à l'intérieur du dépôt ;
5. la destination n'existe pas encore ;
6. l'application ne s'exécute pas sur `main` ou `master` ;
7. la variable `TRIEUR_ARCHIVE_ACK` vaut exactement `I_UNDERSTAND_ARCHIVE_MOVE` ;
8. la copie est vérifiée par SHA-256 avant retrait de la source.

Le workflow `Trieur Safe Archive` n'exécute **que le dry-run** en CI. Il valide le plan mais n'a pas de permission d'écriture.

## Garde-fou principal

Le Trieur ne supprime jamais définitivement un contenu. Un archivage physique est un déplacement vers `archive/`, réalisé uniquement sur une branche dédiée et destiné à passer par une PR révisable. Si une vérification d'intégrité échoue, la copie cible est annulée et la source reste intacte.

Cette architecture sépare volontairement :

- la décision de cycle de vie (`canonical` / `active` / `superseded` / `archived`) ;
- la validation CI ;
- le déplacement physique ;
- la fusion finale dans `main`.

Ainsi, une erreur du trieur ne peut pas directement effacer une donnée canonique du projet.

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
- `runtime_tokens` pour empêcher les fichiers runtime de continuer à référencer une entrée inactive.

## Contrôles CI

`tools/ci/trieur_governance_gate.py` vérifie :

1. la validité des statuts ;
2. l'unicité des identifiants ;
3. l'existence des chemins déclarés ;
4. l'unicité des clés canoniques ;
5. la présence d'un remplacement pour toute entrée `superseded` ;
6. l'absence de références runtime déclarées vers des contenus `superseded` ou `archived`.

Le workflow `Trieur Governance` s'exécute sur les changements touchant le registre, les données, les scènes, les scripts et la documentation gouvernée.

## Principe de sécurité

Le Trieur V2 ne déplace et ne supprime aucun fichier automatiquement. Les mouvements destructifs ou les archivages physiques restent des opérations explicites et révisables. La CI bloque d'abord les incohérences ; une automatisation de déplacement pourra être ajoutée plus tard une fois les règles de routage stabilisées.

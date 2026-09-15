# GLOBAL PROJECT BOUNDARY P0

Ce contrat formalise l'isolation inter-projets pour la gouvernance globale.

## Invariant

Tout artefact de gouvernance doit être lié explicitement à une identité de projet et à une route cible. Un artefact LITD ne doit jamais être accepté par un chemin entreprise, ni l'inverse.

## LITD

- `project_id = LITD`
- `target_route = LITD_LIBRARY`

## COMPANY

- `project_id = COMPANY`
- `target_route = COMPANY_LIBRARY`

Le consommateur PostgreSQL COMPANY est lié en dur à ce couple et ne permet pas à l'appelant de substituer l'identité ou la route. Le registre PostgreSQL partagé conserve en plus une liste privée de couples projet/route autorisés ; toute tentative d'enregistrer un reçu sous un couple non autorisé échoue avant que le reçu entre dans la chaîne gouvernée.

Ces valeurs doivent être incluses dans les hashes canoniques, propagées dans les reçus et conservées dans le ledger de preuve.

## Règle fail-closed

Tout événement, reçu ou preuve dont le `project_id` ou la route ne correspondent pas au consommateur local est refusé avant routage, promotion, décision Guardian, implémentation ou application. La création d'un nouveau reçu est elle-même bloquée si le couple projet/route n'est pas explicitement autorisé par migration gouvernée.

## Autorité

La frontière projet/route n'accorde aucune écriture Core, aucune fusion automatique, aucune application automatique et aucune propagation inter-projets. L'ajout ou le retrait d'un couple projet/route exige une modification de schéma séparée, revue et auditable.

## Preuves P0

La certification PostgreSQL live doit couvrir au minimum :

- consommation COMPANY native sur `COMPANY / COMPANY_LIBRARY` ;
- refus LITD → COMPANY ;
- refus COMPANY → LITD ;
- refus d'une mauvaise route ;
- refus de création d'un reçu sous un couple projet/route non autorisé ;
- replay, stale context, révocation, supersession et concurrence ;
- protections append-only et intégrité complète de la chaîne d'audit.

## Portée

Ce contrat complète la frontière LITD déjà propagée de l'ingress au checkpoint final et la frontière durable du registre Supabase multi-projets. Les consommateurs applicatifs propres à chaque projet restent responsables de conserver la même identité jusqu'à leur fermeture locale.

# GLOBAL PROJECT BOUNDARY P0

Ce contrat formalise l'isolation inter-projets pour la gouvernance globale.

## Invariant

Tout artefact de gouvernance doit être lié explicitement à une identité de projet et à une route cible. Un artefact LITD ne doit jamais être accepté par un chemin entreprise, ni l'inverse.

## LITD

- `project_id = LITD`
- `target_route = LITD_LIBRARY`

## COMPANY / HENOLOS

- `project_id = COMPANY`
- `target_route = COMPANY_LIBRARY`

L'identité `COMPANY` est l'identité technique stable du projet entreprise dans la gouvernance ; HENOLOS est son nom métier. Les deux frontières utilisent le même registre durable PostgreSQL, mais chaque consommateur local doit refuser tout projet ou toute route ne correspondant pas à son propre périmètre.

Le consommateur PostgreSQL COMPANY est lié en dur à ce couple et ne permet pas à l'appelant de substituer l'identité ou la route. Le registre PostgreSQL partagé conserve en plus une liste privée de couples projet/route autorisés ; toute tentative d'enregistrer un reçu sous un couple non autorisé échoue avant que le reçu entre dans la chaîne gouvernée.

Ces valeurs doivent être incluses dans les hashes canoniques, propagées dans les reçus et conservées dans le ledger de preuve. Les reçus COMPANY couvrent les points de contrôle ingress, revue Bibliothèque, Guardian, implémentation bornée, décision d'application et checkpoint de provenance. Aucun de ces reçus n'accorde à lui seul une écriture Core, une fusion automatique ou une application automatique.

## Registre partagé

Le registre `governance_private` dans PostgreSQL/Supabase fournit l'enregistrement durable, la consommation unique, la révocation/supersession, l'audit hash-chaîné et les protections append-only. Le registre est multi-projets ; l'autorité locale reste bornée par `project_id` et `target_route`.

La table privée `authorized_project_routes` autorise explicitement uniquement `LITD / LITD_LIBRARY` et `COMPANY / COMPANY_LIBRARY`. Elle est protégée contre les modifications runtime ; tout ajout ou retrait exige une migration séparée, revue et auditable.

## Règle fail-closed

Tout événement, reçu ou preuve dont le `project_id` ou la route ne correspondent pas au consommateur local est refusé avant routage, promotion, décision Guardian, implémentation ou application. Un reçu re-hashé pour un autre projet, un changement de route, un changement de consommateur ou une altération de contexte doit également être refusé avant toute autorité aval.

La création d'un nouveau reçu est elle-même bloquée si le couple projet/route n'est pas explicitement autorisé par la migration gouvernée.

## Autorité

La frontière projet/route n'accorde aucune écriture Core, aucune fusion automatique, aucune application automatique et aucune propagation inter-projets. L'ajout ou le retrait d'un couple projet/route exige une modification de schéma séparée, revue et auditable.

## Preuves P0

La certification PostgreSQL live doit couvrir au minimum :

- consommation COMPANY native sur `COMPANY / COMPANY_LIBRARY` ;
- refus LITD → COMPANY ;
- refus COMPANY → LITD ;
- refus d'une mauvaise route ;
- refus de création d'un reçu sous un couple projet/route non autorisé ;
- replay, contexte périmé, révocation, supersession et concurrence ;
- protections append-only et intégrité complète de la chaîne d'audit.

## Portée

Ce contrat P0 fixe les frontières LITD et COMPANY de l'ingress jusqu'au checkpoint final et au registre Supabase multi-projets. Les consommateurs applicatifs propres à chaque projet restent responsables de conserver la même identité jusqu'à leur fermeture locale.

La clôture du chantier d'isolation exige des preuves reproductibles de rejet LITD↔COMPANY et mauvaise route sur le registre réel.

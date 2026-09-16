# GLOBAL GOVERNANCE — LIVE RECOVERY RUNBOOK

Ce runbook complète #407 et le chantier maître #315. Il décrit une procédure de containment, rollback et recovery pour une compromission totale supposée du niveau global de gouvernance.

## Principe d'autorité

La récupération doit rester indépendante du composant global supposé compromis. Le chemin normal `service_role` conserve uniquement une capacité bornée de tentative de mutation synthétique. Il ne peut pas démarrer un exercice, déclencher le containment, effectuer le rollback, reprendre l'activité ni clôturer l'incident.

Le chemin d'urgence est séparé du consommateur normal et requiert une intervention opérateur sur l'environnement autorisé. Il ne donne aucun droit d'écriture dans un Core, aucun merge automatique, aucune application automatique et aucune propagation inter-projet automatique.

## Portée du test live

Le test utilise uniquement des hashes synthétiques dans `governance_private.recovery_drill_state`. Aucun Core LITD ou COMPANY/HENOLOS, aucune donnée client, aucun gameplay et aucun secret applicatif ne sont modifiés.

Le couple de portée doit déjà être explicitement autorisé par `governance_private.authorized_project_routes`. Pour l'entreprise, la portée de référence est `COMPANY / COMPANY_LIBRARY`. Les routes LITD et COMPANY restent incompatibles et sont retestées pendant le containment.

## Séquence opératoire

1. Identifier le SHA exact audité et vérifier que la migration de recovery correspond à ce SHA.
2. Démarrer un drill live borné avec un état de référence synthétique et une génération de capacité initiale.
3. Appliquer un changement synthétique représentatif par le chemin normal borné et conserver les hashes avant/après.
4. Déclencher le containment par le chemin d'urgence indépendant. Le containment fait tourner la génération de capacité afin de révoquer immédiatement la génération précédente.
5. Pendant le containment, tenter un replay avec l'ancienne génération, une substitution LITD↔COMPANY et une mauvaise route. Toutes ces tentatives doivent échouer sans modifier l'état actif.
6. Exécuter le rollback vers le hash de référence. Le rollback doit vérifier explicitement le hash de l'état à annuler avant de restaurer le baseline.
7. Maintenir le système en phase `RECOVERING` et vérifier qu'une mutation normale reste impossible.
8. Reprendre uniquement après vérification du baseline. La reprise fait tourner une nouvelle fois la génération de capacité ; les générations antérieures restent invalides.
9. Vérifier qu'un appel borné avec la nouvelle génération peut fonctionner sans quitter le baseline.
10. Clôturer le drill en état `CLOSED`, baseline restauré, puis vérifier la chaîne d'audit cryptographique complète.
11. Conserver l'artefact de certification 90 jours et rattacher la preuve au SHA fusionné.
12. Toute reprise réelle d'un service compromis reste soumise à une décision humaine séparée ; le workflow de preuve ne peut pas décider de cette reprise.

## Critères fail-closed

Le drill est invalide si l'un des points suivants survient : hash avant rollback inattendu, baseline non restauré, mutation acceptée pendant `CONTAINED` ou `RECOVERING`, génération périmée acceptée après reprise, mauvaise route acceptée, scope LITD/COMPANY substitué, chaîne d'audit invalide, privilège d'urgence exposé au `service_role`, accès direct du `service_role` aux tables privées, ou preuve non liée au SHA audité.

## Ce que cette preuve peut certifier

Une exécution live réussie démontre un rollback réellement exécuté sur un changement gouverné synthétique représentatif, une rotation/révocation de capacité par génération, un containment indépendant du chemin normal, une récupération bornée, le maintien de l'isolation LITD↔COMPANY et une chaîne d'audit reproductible.

Elle ne prouve pas à elle seule la rotation d'un secret externe Hetzner, Infisical ou authentik. Si un incident réel compromet l'un de ces systèmes, sa propre procédure de rotation doit être exécutée et jointe comme preuve additionnelle avant toute décision humaine de reprise.

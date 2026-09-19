# GLOBAL GOVERNANCE — LIVE RECOVERY RUNBOOK

Ce runbook complète #407 et le chantier maître #315. Il décrit une procédure de containment, rollback et recovery pour une compromission totale supposée du niveau global de gouvernance.

## Principe d'autorité

La récupération doit rester indépendante du composant global supposé compromis. Le chemin normal `service_role` conserve uniquement une capacité bornée de tentative de mutation synthétique. Il ne peut pas démarrer un exercice, déclencher le containment, effectuer le rollback, reprendre l'activité ni clôturer l'incident.

Le chemin d'urgence est séparé du consommateur normal et requiert une intervention opérateur sur l'environnement autorisé. Il ne donne aucun droit d'écriture dans un Core, aucun merge automatique, aucune application automatique et aucune propagation inter-projet automatique.

Une compromission du chemin normal est donc traitée comme une hypothèse explicite de l'exercice : le `service_role` doit rester incapable d'exécuter les RPC d'urgence et incapable de modifier directement les tables privées de recovery.

## Portée du test live

Le test utilise uniquement des hashes synthétiques dans `governance_private.recovery_drill_state`. Aucun Core LITD ou COMPANY/HENOLOS, aucune donnée client, aucun gameplay et aucun secret applicatif ne sont modifiés.

Le couple de portée doit déjà être explicitement autorisé par `governance_private.authorized_project_routes`. Pour l'entreprise, la portée de référence est `COMPANY / COMPANY_LIBRARY`. Les routes LITD et COMPANY restent incompatibles et sont retestées pendant le containment.

Chaque drill est lié au SHA Git audité. Le SHA est conservé dans l'état de recovery et dans chaque entrée de la chaîne d'audit ; un appel portant un autre SHA doit être refusé comme `stale_source_sha`.

## Séquence opératoire

1. Identifier le SHA exact audité et vérifier que la migration de recovery correspond à ce SHA.
2. Démarrer un drill live borné avec un état de référence synthétique, le SHA audité et une génération de capacité initiale.
3. Avant tout changement, tenter un stale SHA et une substitution du hash actif attendu. Les deux doivent être rejetés sans mutation.
4. Appliquer un changement synthétique représentatif par le chemin normal borné et conserver les hashes avant/après.
5. Déclencher le containment par le chemin d'urgence indépendant. Le containment fait tourner la génération de capacité afin de révoquer immédiatement la génération précédente.
6. Pendant le containment, tenter un replay avec l'ancienne génération, un changement de projet LITD↔COMPANY et une mauvaise route. Toutes ces tentatives doivent échouer sans modifier l'état actif.
7. Tenter une altération directe du ledger de recovery. Le trigger append-only doit la refuser.
8. Tenter un rollback avec un hash source substitué. Le rollback doit échouer avant toute restauration.
9. Exécuter ensuite le rollback avec le hash exact de l'état à annuler. Le baseline doit être réellement restauré.
10. Maintenir le système en phase `RECOVERING` et vérifier qu'une mutation normale reste impossible.
11. Reprendre uniquement après vérification du baseline. La reprise fait tourner une nouvelle fois la génération de capacité ; les générations antérieures restent invalides.
12. Rejouer une capacité pré-containment : elle doit être refusée comme périmée.
13. Vérifier qu'un appel borné avec la nouvelle génération peut fonctionner sans quitter le baseline.
14. Clôturer le drill en état `CLOSED`, baseline restauré et SHA inchangé, puis vérifier la chaîne d'audit cryptographique complète.
15. Vérifier qu'un `service_role` supposé compromis ne possède aucune autorité begin/contain/rollback/resume/close et aucun accès direct aux tables privées.
16. Conserver l'artefact de certification 90 jours et rattacher la preuve au SHA fusionné.
17. Toute reprise réelle d'un service compromis reste soumise à une décision humaine séparée ; le workflow de preuve ne peut pas décider de cette reprise.

## Couverture adversariale obligatoire

La preuve live doit couvrir explicitement : source/chemin normal compromis, ledger altéré, replay, substitution de hash, stale SHA, stale génération/contexte, changement de projet cible, mauvaise route et tentative de bypass des autorités d'urgence. Une absence de scénario est un blocage de certification, même si le chemin nominal de rollback réussit.

## Critères fail-closed

Le drill est invalide si l'un des points suivants survient : stale SHA accepté, hash actif substitué accepté, hash avant rollback inattendu accepté, baseline non restauré, mutation acceptée pendant `CONTAINED` ou `RECOVERING`, génération périmée acceptée après reprise, mauvaise route acceptée, scope LITD/COMPANY substitué, altération du ledger acceptée, chaîne d'audit invalide, privilège d'urgence exposé au `service_role`, accès direct du `service_role` aux tables privées, ou preuve non liée au SHA audité.

## Ce que cette preuve peut certifier

Une exécution live réussie démontre un rollback réellement exécuté sur un changement gouverné synthétique représentatif, une rotation/révocation de capacité par génération, un containment indépendant du chemin normal, une récupération bornée, le maintien de l'isolation LITD↔COMPANY, le rejet d'un stale SHA et d'une substitution de hash, l'append-only réel du ledger de recovery et une chaîne d'audit reproductible liée au SHA.

Elle ne prouve pas à elle seule la rotation d'un secret externe Hetzner, Infisical ou authentik. Si un incident réel compromet l'un de ces systèmes, sa propre procédure de rotation doit être exécutée et jointe comme preuve additionnelle avant toute décision humaine de reprise.

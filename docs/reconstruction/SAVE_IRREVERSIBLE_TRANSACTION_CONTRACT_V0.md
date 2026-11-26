# LITD 1 — Contrat transactionnel des événements irréversibles, V0 (issue #638)

**Statut : spécification proposée, non implémentée, non validée en runtime.** Ce document formalise les arbitrages de conception #30–40 et le contrat provisoire de persistance. Il ne prétend pas que les producteurs de combat, de capture ou de succession existent dans le runtime actuel.

## Frontière transactionnelle

Une action résolue constitue **une transaction métier unique** couvrant tous ses effets persistants : dégâts multi-cibles, morts permanentes, captures, inventaire, récompenses, ressources, progression personnelle/collective, conséquences différées déjà déterminées et état RNG nécessaire. Les effets non encore résolus sont enregistrés comme engagements persistants, jamais recalculés implicitement après redémarrage.

Une succession peut être une transaction séparée **uniquement si** la mort confirmée a créé un état durable `succession.pending` et si l'application de succession est idempotente.

## Enveloppe candidate du journal (noms provisoires)

```json
{
  "journal_schema_version": 1,
  "campaign_id": "campaign-id",
  "transaction_id": "stable-id",
  "sequence": 42,
  "base_revision": 41,
  "result_revision": 42,
  "pre_state_sha256": "64-hex",
  "post_state_sha256": "64-hex",
  "action_id": "resolved-action-id",
  "mutations": [],
  "permanent_events": [],
  "deferred_effects": [],
  "rng_state_after": {},
  "commit_state": "committed"
}
```

Ce JSON est un **exemple de structure**, pas un enregistrement généré ni un schéma figé. Les mutations doivent décrire des opérations déterministes avec préconditions, identités stables et valeurs finales. Aucun algorithme de combat, IA, RNG ou tirage de capture ne doit être réexécuté pendant la reprise. L'intégrité doit porter sur le contenu canonique du journal et ses relations aux révisions.

## Invariants métier proposés

| Domaine | Condition de validation |
| --- | --- |
| Ordre | `base_revision` égale la révision validée précédente ; `result_revision` avance strictement selon la règle de version définie ; `sequence` ne présente ni trou non expliqué ni doublon |
| Idempotence | Un `transaction_id` confirmé n'est appliqué qu'une seule fois ; doublon avec contenu différent = conflit bloquant |
| Décès permanent | Un héros marqué mort ne peut réapparaître vivant par restauration d'un ancien snapshot ; son identifiant et l'événement de décès restent traçables |
| Capture | Identifiant de capture stable, cible et résultat déjà résolus ; aucune deuxième attribution au rechargement |
| Récompenses | Une même attribution confirmée ne crédite qu'une fois ressources, inventaire et progression |
| Succession | Mort et `succession.pending` confirmés ensemble ; un successeur ne peut être créé deux fois pour la même succession |
| Effets différés | Les effets déterminés sont conservés avec identifiant, échéance/condition et statut ; aucun double déclenchement |
| Progression | Aucune progression personnelle posthume non autorisée ; progression collective confirmée non effacée |
| Cohérence | Empreintes avant/après, préconditions et état résultant concordent ; sinon arrêt contrôlé |

Les règles de résurrection autorisée par le design, s'il en existe, doivent être explicitement modélisées comme **événement exceptionnel distinct**, jamais inférées d'un vieux snapshot.

## Séquence de validation et de reprise (proposition à éprouver)

1. Résoudre l'action **une seule fois** en mémoire, sans rendre ses conséquences irréversibles visibles comme confirmées.
2. Construire la transaction complète, vérifier préconditions, identifiants et invariants.
3. Écrire une entrée de journal préparée, synchroniser selon les garanties réelles de la plateforme.
4. Confirmer durablement l'entrée par un protocole de commit vérifiable ; une simple écriture JSON ou un renommage ne suffit pas à garantir la tenue à une coupure électrique.
5. Publier l'état confirmé en mémoire, puis écrire un snapshot canonique à la révision correspondante et mettre à jour son manifeste.
6. Au redémarrage, sélectionner un snapshot **vérifié** et appliquer dans l'ordre les mutations **confirmées**, sans rejouer l'action ; détecter les lacunes, contradictions et retours arrière.
7. Si la continuité n'est pas prouvable, proposer une récupération guidée sans restaurer silencieusement un état qui annulerait une mort ou un gain confirmé.

**Point d'attention :** le protocole de commit exact, l'ordre des `fsync`/renommages et le comportement Windows doivent être conçus et testés avant de prétendre à la durabilité. Les garanties matérielles absolues ne sont pas possibles.

## Scénarios minimaux de validation

- Mort de deux héros et capture d'une créature dans une seule action, avec récompense et consommation de ressources : tout ou rien.
- Coupure simulée avant préparation, après préparation, avant commit, après commit, pendant snapshot, pendant manifeste.
- Même transaction rejouée deux fois ; même ID avec contenu différent ; séquence manquante ; empreinte incorrecte.
- Mort confirmée, ancien snapshot présent : jamais de résurrection implicite.
- Succession `pending` persistante et application unique après redémarrage.
- Effet différé et RNG : résultat identique sans relancer l'IA ni le tirage.
- Migration sur copie d'une sauvegarde 0.31 avec clés inconnues : aucune perte silencieuse.
- Tests Godot headless, injections de fautes, essais réels Windows sur copies.

## Prérequis bloquants

Le `SaveManager` actuel stocke un snapshot opaque et ne démontre pas les producteurs/consommateurs métier requis. **Ne pas raccorder ce protocole au runtime** tant que le schéma d'état, les points de confirmation des actions, les identifiants stables et les producteurs des événements n'ont pas été identifiés ou créés, puis testés. Ne pas réintroduire `ExpeditionManager` historique ou un moteur de combat retiré sans décision d'architecture explicite.

## Périmètre

Aucun fichier artistique, aucun gameplay et aucun format de sauvegarde utilisateur n'est modifié par cette spécification. Pas de fusion automatique.

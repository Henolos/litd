# Formulaire de revue indépendante MC-007 — ARCH-12

Ce formulaire permet de documenter une revue indépendante **sans compte GitHub**. Le reviewer peut examiner les deux documents indiqués, remplir ce formulaire hors dépôt et le remettre au responsable du projet, qui pourra ensuite le joindre à la PR #663.

La revue ne vaut que pour les versions exactes examinées. Si l'un des fichiers change après la revue, indiquer si les conclusions restent valides ou refaire les contrôles affectés.

## Identification de la revue

- Reviewer (nom ou identifiant professionnel) :
- Compétence pertinente pour cette revue :
- Déclaration d'indépendance : je n'ai pas rédigé cette spécification et je n'ai pas participé aux décisions ARCH-12 examinées : ☐ Oui ☐ Non
- Relation éventuelle avec l'auteur/la conception :
- Date :
- Référence de la PR : https://github.com/Henolos/litd/pull/663
- SHA du commit examiné :
- SHA de la spécification `ARCH12_FUNCTIONAL_TEST_SPEC_2026-11-26.md` :
- SHA du document maître `LITD1_DOCUMENT_MAITRE.md` :

**Sources à examiner**

1. `docs/conception/LITD1_DOCUMENT_MAITRE.md`, section ARCH-12 à ARCH-12.5.
2. `docs/qa/ARCH12_TRACEABILITY_AND_SCENARIOS_2026-11-26.md`.
3. `docs/qa/ARCH12_FUNCTIONAL_TEST_SPEC_2026-11-26.md`.

## Verdict

Cocher un seul choix :

- ☐ **Acceptée** : pas d'écart bloquant; les réserves ouvertes sont correctement signalées.
- ☐ **Acceptée avec corrections** : corrections listées ci-dessous avant clôture.
- ☐ **Refusée / incomplète** : défauts importants ou preuves manquantes.

## Contrôles de revue

Pour chaque point, indiquer **Conforme**, **Écart**, ou **Non vérifiable**, et référencer les lignes/scénarios.

| Contrôle | Résultat | Scénarios / preuve / commentaire |
|---|---|---|
| Les références des 70 scénarios pointent vers les règles citées. |  |  |
| Les oracles suivent les décisions validées et ne créent pas de règle nouvelle. |  |  |
| Les effets différés, neutralisations et ruptures de causalité sont couverts sans contradiction. |  |  |
| Pièges, dangers environnementaux et interventions indépendantes sont traités avec les limites d'intention clairement indiquées. |  |  |
| L'unicité du principal, les contributeurs et l'égalité irréductible respectent ARCH-12.4. |  |  |
| Les transferts de maître, l'autonomie, la mort et la disparition d'une invocation respectent ARCH-12.5. |  |  |
| Recrutement, reconnaissance posthume, Archives, sauvegarde/reprise et absence de duplication sont couverts. |  |  |
| Les cas O/P/D distinguent bien oracle normatif, paramètre technique et décision non résolue. |  |  |
| Les limites runtime et les affirmations « 0/70 exécuté » sont exactes et non présentées comme des succès. |  |  |
| Les cas manquants, contradictoires ou hors périmètre sont identifiés. |  |  |

## Écarts et corrections demandées

| ID / emplacement | Type (erreur, omission, contradiction, ambiguïté) | Référence source | Correction demandée / justification |
|---|---|---|---|
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |

## Conclusion motivée

- Résumé des principaux constats :
- Scénarios à corriger ou à reclasser :
- Décisions de conception réellement nécessaires (si applicable) :
- Limites de la revue :
- Cette revue permet-elle de traiter MC-007 comme satisfaite pour le périmètre ci-dessus ? ☐ Oui ☐ Non

Signature ou attestation du reviewer :  
Date :

---

**Note de statut** : remplir ou joindre ce formulaire ne vaut pas à lui seul preuve de revue. MC-007 ne pourra être marqué terminé qu'après retour d'un reviewer distinct, rattachement du rapport aux SHAs examinés, examen des écarts et vérification des corrections.
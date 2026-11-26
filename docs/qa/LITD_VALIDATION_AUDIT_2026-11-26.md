# Audit du contrat de validation LITD — 26 novembre 2026

## Périmètre et référence contrôlée

- Révision de base utilisée : 154a80717a78fcd3d3bb02af445429be1524cc01 (branche main).
- Document maître actuel : docs/conception/LITD1_DOCUMENT_MAITRE.md, blob 993f533285b1b37c50fc16dc1e09accd767673a7.
- Contrat examiné : inventaire QA V1, branche feat/litd-qa-validation-contract-v1, commit d59dae8646d1111d43f3e78c9da282e35b0af55c.
- Méthode appliquée : fichiers V2.3 et guide d’application joints à la demande.

## Résultats vérifiés

1. L’inventaire contient 129 identifiants uniques répartis en neuf familles.
2. Les 129 lignes portent encore PENDING_RECONCILIATION, NOT_RUN, PROPOSED et blocking=false. Ces états ne démontrent aucune validation du gameplay.
3. 73 lignes n’ont pas de source canonique renseignée ; 121 n’ont pas de canal de revue défini.
4. Les 56 sources renseignées nommaient un document qui n’existe pas sous ce chemin. Le document maître actuel est dans docs/conception/LITD1_DOCUMENT_MAITRE.md ; la source V8.3 du 23 novembre est conservée sous docs/conception/archive/LITD1_DOCUMENT_MAITRE_V8.3_SOURCE_2026-11-23.md.
5. Le validateur initial contrôlait l’existence des cinq fichiers de référence et les identifiants, mais ne vérifiait pas qu’une source canonique citée figurait dans les références du contrat. Les localisateurs de section restent des propositions non authentifiées.
6. Pour le commit contrôlé d59dae8, les statuts GitHub observés étaient : job quality réussi, godot-smoke réussi, quality-full ignoré. Cette CI valide uniquement ses étapes exécutées ; elle ne valide pas les 129 règles de conception.
7. La PR #643 reste ouverte en brouillon, créée sur une base antérieure au main actuel. Elle n’a pas été fusionnée.
8. Le document maître affirme que les décisions de conception V8.3 et ARCH-12 sont validées, mais non implémentées et non testées en runtime. ARCH-12.3 et ARCH-12.4 figurent avec 10 règles chacune (20 au total) ; ARCH-12.5 figure avec 20 règles. Les preuves consultées ne justifient pas de déclarer ces décisions opérationnelles.
9. La règle de fuite la plus récente retrouvée réserve la fuite volontaire aux Némésis sous conditions ; les ennemis non Némésis ne fuient pas. La correction du 18 novembre est explicitement remplacée sur ce point. Aucun test runtime n’est revendiqué.
- Contrôle de contenu séparé : le patch fusionné #650 contient 20 lignes (10 ARCH-12.3, 10 ARCH-12.4) et toutes 20 apparaissent textuellement dans le document maître de main ; le patch #651 contient 20 lignes ARCH-12.5 et les 20 apparaissent. Ce contrôle vérifie la présence après fusion, pas le verbatim des propositions utilisateur originales.
- Réconciliation des contrats Les Veilleurs : les cinq systèmes du registre sont au niveau technique ; leurs preuves joueur, mobile et production sont vides. Le modèle joueur exige 8 gates et le contrat matériel 8 gates ; aucun rapport de session matériel n’est présent dans l’arbre main. Le template joueur reste entièrement NOT_RUN. Les audits statiques empêchent explicitement la CI de promouvoir ces états.


## Correction préparée dans cette branche

- Base d’inventaire mise à jour au SHA 154a80717a78fcd3d3bb02af445429be1524cc01.
- Les 56 sources proposées pointent vers le document maître effectivement présent.
- Le document maître est ajouté aux références contrôlées.
- Le validateur refuse désormais une source canonique absente de la liste de références.
- Un test négatif couvre ce refus.
- Les statuts des 129 contrôles restent inchangés et non validés. Aucun code de gameplay n’a été modifié.

## Revue des PR brouillons ouvertes (26 novembre 2026)

| PR | État observé | Limite de validation |
|---|---|---|
| #652 | Brouillon d’audit, base main à 154a807 | Aucun examen indépendant ni fusion |
| #643 | Brouillon, base enregistrée ea922120 | Inventaire 129 incomplet ; chemins/localisateurs à réconcilier |
| #639 | Brouillon, base enregistrée ea922120 | Tests du prototype de sauvegarde réussis, mais fonctions non raccordées à save_game/load_game selon la description |
| #632 | Brouillon, base enregistrée e9d3a5d | Prototype narratif ; effets proposés, non raccordés à la progression |
| #622 | Brouillon, base enregistrée 21e9987 | Documentation de recherche ; playtest de la quête non exécuté |
| #616 | Brouillon, base enregistrée b405f50 ; GitHub indique dirty | Prototype Combat A ; compréhension par joueur non testée |

Les SHA de base des anciennes PR sont antérieurs au main courant ; elles doivent être relues contre la base actuelle avant toute fusion. Cette revue de métadonnées/descriptions n’est pas une inspection complète de leurs diffs.

## Limites et travaux requis avant toute validation

- Les 73 sources manquantes doivent être retrouvées dans des décisions authentifiées ou rester explicitement non mappées.
- Les 56 localisateurs proposés doivent être contrôlés contre les sections exactes ; le changement de chemin ne les certifie pas.
- Les 121 canaux de revue manquants doivent être définis par nature de contrôle.
- Les critères, données d’entrée, résultat attendu, préconditions et preuves restent à associer à chaque règle avant de prétendre à une couverture exécutable.
- Les décisions ARCH-12.1 à 12.5 doivent être incluses explicitement dans l’inventaire QA si celui-ci se présente comme couvrant les règles actuelles ; leur réconciliation historique et leurs tests runtime restent ouverts.
- Aucun audit intégral de toutes les ressources et de toutes les validations utilisateur du dépôt n’est certifié par ce rapport. Les sources historiques non accessibles restent à vérifier.

## Vérifications après ouverture de la PR

- Sur le commit 9fecb221c7efa53285f301cca691c1e70bbf7d01, le job `quality` s’est terminé avec succès : 1 467 tests Python réussis et deux `SyntaxWarning` existants sur les séquences `\\d` dans `tools/ci/generate_godot_status.py` (lignes 154–155, hors diff).
- Le job `godot-smoke` a réussi ; `quality-full` a été ignoré.
- Le contrôle déclaratif non bloquant de la PR a échoué sur la description initiale, qui ne comportait pas les rubriques et le statut requis. La description a été corrigée ; le pilote a réussi au run 45774604164 sur le commit fc2c03444520d31854e18398e45323ed6e794cf1.
- Les contrôles réussis ci-dessus portent sur la CI de la branche ; ils ne valident pas les 129 propriétés métier et n’établissent pas leur conformité en jeu.

## État

Correction documentaire et garde-fou de traçabilité préparés pour revue. Sur le commit 33f68a4, quality (1 467 tests Python), godot-smoke et le pilote déclaratif ont réussi ; quality-full a été ignoré. Aucune fusion ni validation gameplay.

## Réconciliation détaillée — passe 2

Le contrat a été enrichi pour rendre les lacunes visibles par règle, sans faire passer une proposition pour une validation :

- Chaque contrôle des 129 porte maintenant un canal de revue proposé, un état de source et un état du critère d’acceptation.
- Canaux proposés : F8 106; human 16; measurement_and_human 3; physical_windows 1; visual 3.
- Les 56 pointeurs de source existants sont marqués `LINKED_UNVERIFIED` : leur chemin est désormais présent, mais le locator et la pertinence de chaque section n’ont pas encore été attestés individuellement.
- Les 73 contrôles qui n’avaient pas de source restent `MISSING`.
- Les 129 critères d’acceptation sont explicitement `NOT_DEFINED`. Le titre d’un contrôle ou la présence d’un test d’audit ne suffit pas à définir un résultat métier attendu.
- Ces canaux sont des propositions de revue, pas une exécution : F8 pour revue d’interaction/runtime, visual pour revue visuelle, human pour évaluation qualitative, measurement_and_human pour performance et lisibilité mesurée, physical_windows pour le test matériel Windows.
- Le schéma exige désormais ces trois champs. Un test empêche de perdre silencieusement ces indicateurs sur une ligne.

### Contradiction de conception repérée

`docs/COMBAT_ANATOMIE_AVANCEE.md` indique qu’une créature ordinaire affaiblie ayant perdu plusieurs parties peut tenter de fuir (section 5, ligne 103). Cette règle contredit la décision utilisateur plus récente consignée dans le contexte LITD : aucun ennemi ne peut fuir, sauf les Némésis dans les conditions prévues. Le document de combat doit donc être corrigé ou explicitement supersédé et les validations COM-13/COM-15/INT correspondantes mises à jour. Aucun correctif n’est encore appliqué à ce document de gameplay dans cette PR.

### État de la réconciliation

Les canaux de revue sont maintenant renseignés au niveau du contrat, mais aucun des 129 critères d’acceptation n’est encore réconcilié. Les sources se limitent aux pointeurs vers le document maître déjà inventoriés ; les autres documents techniques inspectés restent des candidats de corroboration jusqu’à vérification de leur autorité et de leur cohérence avec les décisions validées. La couverture demeure donc partielle et non exécutable comme certification de conformité.


## Correction appliquée — règle de fuite des ennemis

- La phrase contradictoire de `docs/COMBAT_ANATOMIE_AVANCEE.md` (section 5) autorisant la fuite d’une créature ordinaire affaiblie a été remplacée par la règle ARCH-05 du document maître : seuls les Némésis peuvent fuir volontairement, sans fuite systématique ; les cas Némésis devenus boss ou en transformation restent ouverts.
- COM-15 pointe maintenant vers ARCH-05 et vers le document anatomique corrigé ; COM-13 partage le critère partiel lié au comportement de l’IA.
- 2 contrôles (COM-13, COM-15) portent un critère partiel explicite ; 127 restent sans critère d’acceptation formulé. La règle d’exclusion des non-Némésis est testable, mais le système de fuite demeure incomplet tant que les cas ouverts et les conditions précises ne sont pas arbitrés.
- Le schéma et le validateur vérifient désormais que toute source secondaire est déclarée, qu’un critère partiel existe lorsque son statut l’affirme et qu’aucun critère n’est dissimulé sous un statut `NOT_DEFINED`. Des tests dédiés couvrent ces cas.
- Le statut de la correction est documentaire et non runtime : aucune validation du comportement en jeu n’est revendiquée.


### Intégrité du document de référence protégé

Le contrôle `remanence-smoke` a d’abord rejeté la correction, car `docs/COMBAT_ANATOMIE_AVANCEE.md` est dans le manifeste des références gelées. La correction est maintenant inscrite dans `docs/reconstruction/AUTHORIZED_REFERENCE_REVISIONS_20261123.json`, avec empreinte originale conservée, empreinte corrigée et preuve explicative sous `docs/qa/evidence/ARCH-05_FUITE_NEMESIS_2026-11-26.md`. Le passage du contrôle après cette autorisation reste à attendre ; l’échec initial ne constitue pas un résultat final de la branche.


## Extension de la réconciliation UX/UI

La Bible UX/UI du dépôt fournit des critères textuels pour UI-01, UI-02, UI-03, UI-04, UI-05, UI-06, UI-08, UI-09 et UI-10. Ces neuf lignes sont maintenant reliées à `docs/BIBLE_UX_UI_LITD.md` avec une proposition de critère d’acceptation ; leurs sources restent `SUPPORTING_SOURCE_UNVERIFIED` et leurs critères `PARTIAL`, car leur autorité face au document maître et leur réalisation en jeu n’ont pas été contrôlées. UI-07 reste sans critère, car la Bible consultée ne permet pas d’interpréter sûrement le titre « Signalement ».

Le contrat compte donc 10 critères partiels (COM-13, COM-15, UI-01 à UI-06, UI-08 à UI-10) et 119 contrôles sans critère défini. Les règles de canal, source et statut restent descriptives : aucun canal n’a encore été exécuté pour certifier ces contrôles.

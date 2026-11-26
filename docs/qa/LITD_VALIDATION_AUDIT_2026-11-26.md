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

Correction documentaire et garde-fou de traçabilité préparés pour revue. La CI du commit fc2c034 a réussi pour quality et godot-smoke, avec quality-full ignoré. Aucune fusion ni validation gameplay.
# ARCH-12 — oracles de scénarios et revue MC-007

Date : 26 novembre 2026. Complément documentaire à la matrice mise à jour dans la PR #659. Aucun test runtime ou scénario ARCH-12 n'a été exécuté.

## Sources historiques retrouvées

| Ensemble | Proposition/source versionnée | Validation utilisateur retrouvée | Limite |
|---|---|---|---|
| ARCH-12 | Assistant c0, 25-11-2026 20:30:58; texte complet dans la source #649, commit 5307dae. | Message c0 20:32:41 : validation explicite option C et des vingt règles. | 80/80 textes versionnés comparés par #657; le fil brut complet n'est pas exporté ici. |
| ARCH-12.1/.2 | Propositions présentées ensemble; texte source #649. | « oui », c0 22:07:37, après présentation des deux options C et des vingt règles. | Validation commune aux ensembles, pas vingt approbations séparées. |
| ARCH-12.3/.4 | Proposition c0 22:23:05/22:24:05; texte source #650. | Message c0 22:24:29 : validation explicite des deux options C et des vingt règles. | Le transcript brut complet n'est pas exporté ici. |
| ARCH-12.5 | Proposition c0 22:33:32; texte source #651. | Choix C à 22:33:58; validation séparée option C + vingt règles à 22:34:30. | Le premier choix C seul ne valait pas validation des règles. |
| ARCH-12 règle 19 antérieure | Messages utilisateur c0 16-11-2026 16:44:33 à 16:46:31. | Le code nom rouge/tête de mort rouge est formulé à 16:44:33; l'entrée Némésis reste rouge dans les Archives après décès à 16:45:12; l'historique des héros morts est ajouté aux Archives à 16:46:31. | La permanence après la propre mort du Némésis est explicitée dans ARCH-12 validé le 25-11; la source antérieure ne prouve que le code visuel et l'archivage. |

La PR #657 a comparé les 80 formulations normatives provenant des propositions versionnées #649–#651 au document maître main à 6dafa218b2aa7c403edd64507f6487d18b8112d4. Résultat documenté : 80/80 identiques après normalisation des seuls espaces. La comparaison porte sur les sources versionnées du dépôt, non sur le verbatim conversationnel complet.



## Contrat commun pour les futurs oracles

Les fixtures devront fournir des identifiants stables, journal causal (auteur physique, maître/faction à l'action, source, transmissions, interventions, mort, principal zéro-ou-un, contributeurs, écritures Archive, statistiques et récompenses) et snapshots avant/après. Les scénarios de sauvegarde compareront aussi l'état après reprise. La méthode technique de comparaison causale reste ouverte : les cas d'égalité ne peuvent à ce stade vérifier que l'enregistrement de tous les contributeurs, l'absence de départage par dégâts seuls/chronologie, l'absence de gain artificiel et la persistance; l'identité du principal est bloquée tant que l'algorithme n'est pas arbitré.

## Oracles candidats S01–S70

Précondition générale de chaque ligne : fixture isolée avec identifiants et état initial connus, événements consignés, règle applicable activée. Tous les oracles sont à valider avant implémentation; aucun n'a été exécuté.

| ID | Stimulus de fixture | Oracle attendu |
|---|---|---|
| S01 | Coup direct létal par un ennemi A. | Archive relie la mort à A; un principal au plus. |
| S02 | Poison A appliqué; combat terminé; poison tue. | Auteur/poison conservés après combat. |
| S03 | Saignement A appliqué; sortie de combat; décès différé. | Cause et source restent reliées au décès. |
| S04 | Brûlure transmise puis létale. | Chaîne et sources de chaque transmission conservées. |
| S05 | Affliction A neutralisée avant décès dû à B. | A est exclu de la chaîne létale indépendante. |
| S06 | Guérison complète puis nouvelle cause létale B. | Aucun crédit à l'affliction antérieure. |
| S07 | Affliction transmise de A vers cible B puis létale. | Origine A et chaîne de transmission traçables. |
| S08 | A et B appliquent la même affliction létale. | Contributions des deux conservées; principal conditionné à causalité. |
| S09 | Deux effets simultanés causent le décès. | Résultat déterministe, sans priorité d'ordre d'itération. |
| S10 | Cumul d'effets de A/B, décès après fin de combat. | Sources cumulées restent visibles et attribuables. |
| S11 | A pose piège et s'absente; piège tue plus tard. | A demeure candidat installateur malgré son absence. |
| S12 | A pose; B déclenche volontairement le piège létal. | B peut être principal; pas d'attribution automatique à A. |
| S13 | A installe, B déclenche, mort s'ensuit. | A/B tracés; départage limité à la causalité établie. |
| S14 | A utilise volontairement un feu de décor létal. | Utilisation et responsabilité A consignées. |
| S15 | A pousse héros dans une chute létale. | Poussée et auteur A attachés au décès. |
| S16 | A projette héros dans danger environnemental. | Chaîne projection→danger→mort conservée. |
| S17 | Danger environnemental autonome, aucun auteur identifiable. | Aucun Némésis/responsable artificiel. |
| S18 | Chaîne à plusieurs étapes avec événements identifiés. | Chaque relation causale jusqu'à la mort reste enregistrée. |
| S19 | B intervient indépendamment et devient cause décisive. | B peut être principal; antécédents restent contributeurs si causaux. |
| S20 | Effet différé létal après fermeture combat. | Fermeture ne rompt pas l'attribution. |
| S21 | Chaîne neutralisée puis cause indépendante fatale. | Chaîne initiale interrompue; la nouvelle cause est traitée séparément. |
| S22 | Deux candidats équivalents, aucun critère objectif distinctif. | Tous contributeurs, zéro principal possible; aucun tirage. |
| S23 | Contributions équivalentes avec dégâts numériques différents. | Dégâts seuls ne départagent pas; égalité enregistrée. |
| S24 | Deux effets nécessaires conjointement au décès. | Deux contributeurs enregistrés sans pondération inventée. |
| S25 | Inverser premier/dernier entre causes autrement équivalentes. | Aucun avantage chronologique automatique. |
| S26 | A faible dégât non déterminant; B apporte cause nécessaire. | B principal si la fixture rend sa causalité déterminante. |
| S27 | Deux Némésis préexistants sont égaux contributeurs. | Statuts préservés; aucun statut/bonus artificiel nouveau. |
| S28 | Sauvegarde/chargement après égalité enregistrée. | Contributeurs et justificatifs identiques après reprise. |
| S29 | Invocation contrôlée par A inflige le coup létal. | Invocation auteur physique, A maître responsable; pas deux principaux. |
| S30 | Invocation sous A pose effet différé; transfert à B; mort. | Effet reste imputable à A. |
| S31 | Invocation agit sous A puis transfert à B avant résolution. | Action passée garde A, aucun transfert rétroactif. |
| S32 | Actions sous A puis B contribuent à la même mort. | Chaque action associée au maître de sa période. |
| S33 | B prend contrôle temporaire et fait agir l'invocation. | Action de l'intervalle attribuée au contrôle effectif B. |
| S34 | B agit durant contrôle temporaire; A reprend ensuite. | Reprise A ne modifie pas responsabilité de l'action B. |
| S35 | Transferts A→B→C, une action à chaque étape. | Historique ordonné complet, actions liées à leur maître. |
| S36 | Deux contrôleurs influencent simultanément; invocation tue. | Aucun maître choisi arbitrairement; comparaison causale nécessaire. |
| S37 | A maître agit; A meurt; effet persistant tue plus tard. | Origine sous A conservée; archivage posthume sans bonus. |
| S38 | A crée effet; transfert à B; effet tue. | Effet conserve A comme origine responsable. |
| S39 | Invocation autonome éligible cause mort. | Invocation peut être reconnue pour ses nouvelles actions autonomes. |
| S40 | Invocation autonome non éligible cause mort. | Causalité journalisée mais statut Némésis non accordé. |
| S41 | Invocation détruite après avoir créé effet létal persistant. | Destruction ne supprime ni effet ni source. |
| S42 | Invocation révoquée avant résolution d'une attaque différée. | Révocation ne supprime pas la conséquence passée. |
| S43 | Invocation change de faction/recrutement après action passée. | Pas de réattribution des actions antérieures. |
| S44 | Mort liée à la fois à invocation et à son maître. | Un principal au plus, aucun double bénéfice. |
| S45 | Invocation initie chaîne, ennemi intervient ensuite. | Invocation et intervention restent traçables; cause déterminante évaluée. |
| S46 | Sauvegarde pendant transfert, chargement, puis action. | État cohérent sans perte/double transfert; transaction à spécifier. |
| S47 | Action hostile pré-recrutement tue après recrutement de l'auteur. | Reconnaissance historique possible; héros reste recrue. |
| S48 | Recrue reconnue décède ensuite. | Identité et historique restent sur la fiche existante. |
| S49 | Effet hostile pré-recrutement se résout après recrutement. | Ancienne cause persistante; pas de rupture automatique. |
| S50 | Reconnaissance historique, comparer statistiques avant/après. | Aucun bonus Némésis nouveau. |
| S51 | Reconnaissance historique, vérifier rang hostile. | Aucune promotion ennemie post-recrutement. |
| S52 | Recrue reconnue demande retraite. | Règles retraite héros; pas fuite ennemi Némésis. |
| S53 | Recrue continue progression après reconnaissance. | Progression selon système des héros recrutés. |
| S54 | Reconnaissance, compter identifiants/fiches. | Une entité et une fiche enrichie, aucun doublon. |
| S55 | Sauvegarde, chargement, Game Over après reconnaissance. | Historique identique et idempotent. |
| S56 | Effet persistant d'ennemi mort tue plus tard. | Reconnaissance historique si causalité prouvée, sans réapparition. |
| S57 | Comparer statistiques après reconnaissance posthume. | Valeurs figées à l'instant du décès. |
| S58 | Vérifier gains après reconnaissance posthume. | Aucun bonus ou récompense automatiques. |
| S59 | Vérifier promotion après reconnaissance posthume. | Aucune promotion posthume. |
| S60 | Examiner monde après archivage d'ennemi mort. | Aucun ennemi actif recréé par l'archive. |
| S61 | Archiver sans événement de récompense distinct. | Aucune récompense spontanée. |
| S62 | Némésis décédé reçoit une nouvelle victime confirmée. | Liste enrichie sur l'entrée existante, sans doublon. |
| S63 | Sauvegarder/charger archive posthume. | Même fiche, causes, victimes; pas de duplication. |
| S64 | Mort connue, ouvrir Archives. | Héros, cause, responsable et circonstances apparaissent. |
| S65 | Lire nom d'entrée avant/après décès du Némésis. | Nom rouge conservé selon règle 19; absence de statut actif indu. |
| S66 | Lire tête de mort rouge avant/après décès du Némésis. | Marqueur permanent selon règle 19 validée le 25-11. |
| S67 | Némésis existant cause nouvelle mort. | Même identité/statut; nouvelle victime ajoutée sans doublon. |
| S68 | Même responsable cause deux morts distinctes. | Deux événements/victimes distincts sur la même fiche. |
| S69 | Rejouer snapshot et actions identiques. | Même attribution, journaux et Archives; aucun hasard. |
| S70 | Interrompre après journal causal puis reprendre. | Résolution poursuivie une fois, sans resimulation ni double écriture. |



## Paquet de revue indépendante MC-007 — validateur V1.10

Cette section prépare la revue indépendante; elle ne la réalise pas et ne fait pas passer la certification de 90 % à 100 %.

### Pièces à remettre au réviseur

- Rapport de preuves : tools/qa/litd_exploration_validator/v1_10/CERTIFICATION-EVIDENCE-2026-11-26.md, intégré sur la branche feat/litd-exploration-validator-v18 par #655.
- Proposition initiale : PR #642; SHA de tête 42f9b16541dae2046a0824dc0d99629948b7ec6e; commit effectivement extrait par Actions bc7ffcd406e3e67b211ba06a1b84379d27fe8b9e (`refs/remotes/pull/642/merge`); commit de fusion final dans la branche dédiée 547e8153a45ea87005829b8f220f2ace8852610e.
- Run CI 45410435324, tentative 2; job 139560963765; 84 tests réussis, Python 3.12 et jsonschema 4.26.0.
- Manifeste de 43 fichiers, identifiant dda5c8839e4df653860bb514a47b544d463a8591; hash recalculé au contrôle du 26-11 : 43/43 correspondances.
- Les arbres du commit extrait par Actions, du SHA de tête et du commit de fusion final sont tous `c1895a2d004e427cae0736e34bbcf15c7c83070c`. Contrôle contradictoire réalisé le 26-11 : égalité constatée; cette passe n'est pas la revue indépendante MC-007.

### Questions obligatoires de revue

1. Confirmer indépendamment que le run a extrait `bc7ffcd` (merge ref) alors que `42f9b16` est la tête de PR, puis reproduire l'identité d'arbre avec `547e815`; confirmer que les 43 fichiers du manifeste sont les mêmes octets, sans se fier uniquement au présent rapport.
2. Recalculer les empreintes à partir des blobs et du manifeste; documenter l'outil, la version et le résultat. Le contrôle contradictoire a obtenu 43/43 avec Python `hashlib.sha256` sur les octets décodés de l'API GitHub; le reviewer doit refaire ce contrôle et consigner son propre environnement.
3. Examiner les journaux CI et vérifier que les 84 tests correspondent au commit indiqué, à la dépendance jsonschema épinglée et aux tests revendiqués.
4. Contrôler la suite, le schéma, les règles d'inclusion/exclusion et les rapports; relever les fichiers reconstruits V0 dont la provenance originale n'est pas authentifiée.
5. Confirmer que l'égalité d'arbre couvre les fichiers de la PR #642 et que le rapport de preuve ultérieur n'est pas inclus à tort dans le périmètre de test initial.
6. Énoncer séparément ce qui est démontré, ce qui est seulement documenté, ce qui reste sans preuve et les critères qui justifient (ou refusent) les 10 % finaux.

### Indépendance et décision

Le réviseur doit être une personne distincte de l'auteur des changements et du présent contrôle, capable d'examiner les preuves Git/CI. Il doit effectuer une vérification indépendante plutôt que relire seulement le rapport. Consigner son identité, sa date, le commit examiné, les commandes/versions utilisées, les écarts et une conclusion pass/fail. La clôture MC-008 ne peut intervenir qu'après résolution des écarts et décision documentée. Aucun réviseur n'a été identifié ou sollicité dans cette étape; la revue indépendante et les 10 % finaux restent ouverts.

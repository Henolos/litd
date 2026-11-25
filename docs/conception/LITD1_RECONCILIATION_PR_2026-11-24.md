# Réconciliation des PR documentaires LITD 1 — 24 novembre 2026

**Référence cible de conception :** document maître V8.3 daté du 23 novembre 2026.  
**PR de consolidation documentaire :** [#644](https://github.com/Henolos/litd/pull/644), brouillon.  
**Règle de preuve :** une affirmation dans une PR ou un résumé d’assistant ne suffit pas à prouver une validation utilisateur. Les éléments non attestés restent en attente ou en proposition.

## Décisions directes retrouvées et reprises dans l’addendum du document maître

### Recherche comparative avant arbitrage

- **Validation utilisateur retrouvée :** 17 novembre 2026 à 14:26:20 UTC (15:26:20, heure de Paris); intégration demandée à 14:27:08 UTC.
- **Texte normatif attesté :** « Recherche comparative obligatoire avant chaque arbitrage de conception à choix multiples ».
- **Statut :** règle méthodologique active; elle ne valide aucune mécanique de gameplay particulière.
- **Limite :** les six sous-étapes détaillées dans la PR #619 (sources, comparaison, avantages/risques/coûts, recommandation, etc.) ne sont pas chacune prouvées comme texte utilisateur approuvé. Les principes plus généraux de méthode déjà présents en V8.3 s’appliquent; ne pas traiter toutes les élaborations de PR #619 comme des décisions additionnelles.
- **Disposition :** conserver la règle courte dans cette réconciliation; la PR #619 est clôturée comme doublon documentaire après transfert de la règle confirmée. Sa branche et son historique restent disponibles.

### Némésis et fuite

- **Orientation C :** le contexte récupéré date l’approbation au 17 novembre 2026 à 15:11 UTC (16:11 Paris) : éviter les fuites répétitives tant que le Némésis reste crédible. Le verbatim complet du message d’approbation n’est pas disponible; les détails d’implémentation restent ouverts.
- **Option A :** le 17 novembre 2026 à 17:29:42 UTC (18:29:42 Paris), l’utilisateur a approuvé « A — Rivalité par exploit » et précisé : « Comme les ennemis ne peuvent fuir sauf s’ils deviennent némésis » et « Comme seul les némésis peuvent fuir, nous n’aurons jamais l’opportunité de rencontrer plusieurs fois un meme ennemis ».
- **Statut :** la rivalité par exploit reste validée. La règle de fuite du 17 novembre (« seuls les Némésis peuvent fuir ») a été remplacée par la correction utilisateur du 18 novembre 2026 à 14:48 UTC : ennemis normaux, élites et mini-boss peuvent fuir; les boss établis ne fuient pas; un mini-boss évoluant en boss peut fuir exceptionnellement pendant sa transformation. Cette décision plus récente prévaut.
- **À définir :** sens opérationnel de « éviter les fuites répétitives » pour le Némésis et articulation des fuites avec les situations de combat. Ne pas réintroduire l’interdiction générale visant les ennemis normaux.
- Les sources retrouvées ne suffisent pas à confirmer les seuils, bonus de puissance, chaîne de grades, déclenchement automatique ni tous les détails de fuite présents dans #620.
- **Disposition de la PR #620 :** ne pas considérer tous les ajouts de sa section V8.0 comme approuvés. Garder la PR en brouillon jusqu’à récupération de la preuve directe des détails; seul le noyau ci-dessus est repris dans la présente réconciliation.

## Carte d’exploration et PR #641

- **Décision active en V8.3, arbitrage n°1 (socle V8.1) :** carte d’exploration à nœuds ramifiés, retours et chemins cachés; elle remplace l’exploration 3D isométrique; combats 2D conservés.
- **Conséquence :** la phrase de la PR #641 indiquant que l’articulation carte/isométrique reste à arbitrer est dépassée et ne doit pas prévaloir sur V8.3.
- **Détails de la section V7.14 de la PR #641 :** la grande carte, les types et fréquences des nœuds, le monde évolutif, le renouvellement hybride et la distribution des événements ne sont pas attestés ici par un verbatim utilisateur complet. Ils restent des propositions/directions à tracer, non des validations automatiques.
- **Demande utilisateur du 23 novembre 2026 à 20:47:25 UTC (21:47:25 Paris) :** étendre le prototype/validateur aux clés consommables et blocages irréversibles, passages secrets, retour contextuel au refuge, conséquences persistantes, transformations dynamiques, dépassement de budget de calcul et validation effective du schéma JSON. Il s’agit du périmètre de tests à couvrir, pas d’une approbation normative de chacune de ces mécaniques.
- **Fichiers schema/fixtures/tests de #641 :** propositions de validation synthétique isolée; ils ne prouvent ni l’implémentation canonique ni la validation des règles. Les conserver sans fusion pendant la comparaison avec le validateur V1.10 et le périmètre protégé V0.
- **Disposition :** conserver #641 en brouillon pour la revue de ses fichiers QA; corriger son descriptif pour refléter V8.3 et distinguer choix validé, propositions et tests.

## État des PR après réconciliation

| PR | Traitement |
|---|---|
| #644 | Brouillon central : V8.3 proposé comme document maître du dépôt; copie exacte de V7.9 archivée; ce fichier décrit les arbitrages croisés. |
| #619 | Noyau de règle confirmé repris dans l’addendum du document maître; PR doublon clôturée sans fusion, branche historique conservée. |
| #620 | Le 17 novembre « seuls les Némésis fuient » est remplacé par la validation du 18 novembre (normaux/élites/mini-boss peuvent fuir; boss établis non; exception de transformation mini-boss → boss). Les détails non prouvés restent en attente; PR à corriger ou clôturer comme dépassée, sans fusion du texte obsolète. |
| #641 | Le choix carte à nœuds remplaçant l’isométrique vient de V8.3; phrase « non arbitré » à corriger. Les détails et fixtures V0 restent isolés pour revue, PR maintenue en brouillon. |

## Contradictions retrouvées dans la PR #633\n\n- `docs/knowledge/guild_illustrated_hub_decision.md` et `data/guild_illustrated_hub_design.json` décrivent une reprise avec le même protagoniste après Game Over et la conservation de ses compétences, passifs et bestiaire. Cela contredit les décisions V8.1 n°4, 5 et 7, puis V8.2 n°11 et 19 : après l’anéantissement des quatre combattants, un nouveau protagoniste succède au précédent; les acquis collectifs du monde et du bestiaire sont transmis selon V8.1, tandis que la maîtrise personnelle et les emplacements passifs personnels sont reconstruits/regagnés selon V8.2.\n- `data/guild_bestiary_research.json` et `docs/knowledge/guild_new_npcs_integration_status.md` interdisent tout partage automatique du bestiaire entre protagonistes. Cela contredit la transmission des connaissances collectives par les archives de la Guilde prévue par V8.1 n°5; distinguer ces connaissances de la maîtrise personnelle du successeur.\n- `data/universal_relationships_design.json` marque un ensemble de paramètres comme « user validated », alors qu’aucune validation utilisateur directe n’a été retrouvée pour la barre unique, les cinq rangs, les conséquences négatives, l’absence de décroissance, les règles de persistance ou les conditions de récompense. Ces paramètres doivent rester des propositions.\n- **Disposition :** corriger ces fichiers sur la branche #633 avant toute fusion; ne pas interpréter le statut vert de la CI comme validation des mécaniques ou visuels.\n\n## Séparation des statuts

- **Conception :** V8.3 n°1, règle comparative (texte court ci-dessus), principes Némésis/fuite directement attestés ci-dessus.
- **Implémentation :** les PR #620/#641 restent des propositions documentaires ou QA en brouillon; la PR #619 est clôturée après transfert de sa règle confirmée. Aucun de ces états ne signifie raccordement au runtime.
- **Tests :** les fixtures et tests ajoutés par #641 sont des tests synthétiques du contrat qu’ils encodent; aucun test n’a été exécuté dans cette réconciliation.
- **Validation technique :** pas de preuve ici d’un playtest carte, d’un runtime Némésis validé ni d’un comportement de fuite testé.

**Aucune PR n’est fusionnée. Aucune ressource artistique, aucun fichier Godot et aucun gestionnaire de sauvegarde ne sont modifiés par ce document.**

# ARCH-12 — protocole candidat d’assurance automatisée MC-007

Date : 26 novembre 2026  
PR : https://github.com/Henolos/litd/pull/663  
Statut : proposition documentaire non normative; protocole non implémenté, non exécuté et non validé.

## 1. Objet

Définir une voie d’évaluation distincte sans reviewer humain externe pour contrôler la spécification logique ARCH-12 et, lorsqu’un runtime de jeu sera disponible, sa conformité technique.

Le protocole vise à produire des preuves reproductibles par outils déterministes et modèles formels séparés de l’implémentation du jeu. Une IA peut chercher des défauts supplémentaires, mais son avis ne constitue jamais seul le résultat MC-007.

Ce protocole ne modifie pas les règles de conception, ne tranche aucune décision O/P/D ouverte et ne certifie pas le gameplay tant que les scénarios ne sont pas exécutés sur un runtime approuvé.

## 2. Lecture de MC-007 et portée

MC-007 indique qu’une seconde lecture par le même assistant, un script auto-alimenté ou une CI verte ne constitue pas automatiquement une évaluation indépendante. Il demande, pour le risque critique, une revue réellement distincte adaptée à l’objet, avec des preuves vérifiables. Le texte ne prescrit pas explicitement que cette évaluation soit faite par une personne tierce.

La voie ci-dessous interprète « distincte » comme une séparation démontrable entre :
- les sources normatives et les attentes déclarées;
- le modèle abstrait de référence;
- les contrôles exécutés;
- l’implémentation du jeu, lorsqu’elle sera contrôlable.

Cette interprétation est un choix d’application de MC-007, pas une modification de la méthode. Elle ne constitue pas une IV&V au sens strict du glossaire NIST, qui définit l’IV&V comme une revue, analyse et campagne de tests effectuées par une tierce partie.

## 3. Architecture des contrôles

### A. Référentiel figé

Pour chaque campagne, enregistrer les SHA de :
- la branche source contenant le document maître;
- la spécification des 70 scénarios;
- la matrice de traçabilité;
- le code du validateur et du modèle abstrait;
- l’environnement et les dépendances d’exécution.

Les attentes sont dérivées des règles approuvées et conservées dans une table d’oracles versionnée. Elles ne sont pas lues depuis les sorties du jeu ni générées automatiquement à partir du code contrôlé.

### B. Validateur documentaire déterministe

Un programme indépendant du jeu contrôle au minimum :
- présence et unicité des 70 identifiants S01–S70;
- références de règles valides et couverture des règles applicables;
- cohérence des catégories O/P/D avec les réserves et dépendances;
- absence de cas déclaré exécuté sans journal et révision vérifiables;
- conservation des états distincts : réussi, échoué, ignoré, non exécuté, non applicable justifié;
- cohérence des liens entre matrice, spécification et rapports de campagne.

Le validateur doit échouer sur les données invalides et produire un rapport machine lisible. Un message « PASS » sans détail de couverture n’est pas une preuve suffisante.

### C. Modèle de référence et vérification de propriétés

Pour les règles dont l’oracle est déterminé, construire un modèle abstrait fini, séparé du code de production. Le modèle reçoit des événements symboliques et retourne attribution, contributeurs, statut et provenance attendus.

Propriétés minimales à vérifier :
- au plus un responsable principal pour un décès;
- tous les contributeurs causaux identifiés restent enregistrés;
- aucune priorité fondée uniquement sur le total de dégâts ou l’ordre chronologique;
- égalité irréductible : aucun nouveau principal ou statut Némésis dû à l’égalité, sans effacer les statuts préexistants;
- maître attribué selon la maîtrise au moment de l’action, sans transfert rétroactif;
- reconnaissance posthume sans résurrection, bonus ou promotion;
- absence de responsable inventé lorsque la cause reste inconnue;
- persistance et déterminisme de l’état aux opérations de sauvegarde/reprise modélisées.

Le modèle ne calcule pas une pondération causale que les décisions validées ne définissent pas. Les cas P restent conditionnels; les cas D ne reçoivent aucune assertion inventée.

### D. Contrôles négatifs et mutations

Injecter volontairement des variantes fautives du modèle de référence ou de l’adaptateur de test, puis vérifier que les contrôles les détectent. Mutations minimales :
- autoriser deux responsables principaux;
- choisir systématiquement l’auteur des dégâts les plus élevés;
- choisir systématiquement le dernier ou le premier attaquant;
- transférer rétroactivement une ancienne action au nouveau maître;
- recréer une entité décédée à la reconnaissance posthume;
- ajouter un bonus ou une promotion après décès;
- effacer un contributeur ou dupliquer une entrée d’Archives;
- produire un responsable par défaut pour une mort environnementale sans auteur.

Chaque mutation doit avoir un résultat attendu explicite : détectée, équivalente avec justification, ou non détectée. Toute mutation pertinente non détectée bloque la conclusion positive.

### E. Exécution contre le jeu

Cette couche reste fermée jusqu’à ce que le runtime ARCH-12, ses points d’injection, ses observables et son système de sauvegarde soient identifiés et approuvés.

À son ouverture, l’adaptateur de test exécutera chaque cas O applicable contre le runtime exact et comparera les sorties au référentiel figé. Les cas P devront avoir leurs préconditions et paramètres définis; les cas D resteront hors exécution jusqu’à décision. Les résultats devront être rattachés au commit, build, données, configuration et journaux de cette campagne.

## 4. Rôle limité de l’IA

Une revue IA séparée peut analyser les sources et signaler des omissions, contradictions ou interprétations non étayées. Pour limiter l’ancrage :
- fournir les mêmes sources figées et une grille publiée avant l’examen;
- lui demander des constats falsifiables, chacun lié à une règle et à un scénario;
- ne pas lui donner les conclusions précédentes comme référence;
- conserver modèle/version, date, prompt, sources et sortie;
- faire trancher automatiquement les points mécaniques par les contrôles déterministes et classer les autres comme non résolus.

Un autre modèle, plusieurs modèles concordants ou une réponse favorable ne suffit pas à établir l’indépendance : les erreurs des modèles peuvent être corrélées. Aucun score IA ne remplace un contrôle formel, un test négatif ou une preuve de runtime.

## 5. Critères d’acceptation du dossier automatisé

Un rapport peut conclure « conforme au périmètre vérifié » seulement si :
1. les SHA et versions des sources et outils sont consignés;
2. le validateur documentaire couvre les exigences listées et ses cas négatifs échouent comme prévu;
3. le modèle de référence satisfait les propriétés annoncées sur l’espace d’états couvert;
4. toutes les mutations pertinentes sont détectées ou justifiées comme équivalentes;
5. les écarts sont corrigés et les contrôles affectés rejoués;
6. le rapport sépare clairement vérification de la documentation, vérification du modèle, exécution runtime, limites et éléments non vérifiés.

Le rapport ne pourra indiquer « 70 scénarios fonctionnels exécutés » qu’après exécution réelle des 70 scénarios applicables sur le jeu. L’état actuel demeure 0/70 scénarios exécutés.

## 6. Rapport de preuve à conserver

Pour chaque exécution, produire un artefact contenant :
- identifiants et SHA des sources, modèles, scripts, configuration et build;
- versions des outils, système, dépendances et commande exacte;
- couverture par règle et par scénario;
- résultats positifs, négatifs, ignorés, non exécutés et non applicables justifiés;
- résultats de chaque mutation et motifs des équivalences;
- sortie machine complète, empreinte SHA-256 et emplacement de conservation;
- incidents, écarts, corrections, contrôles rejoués et limites restantes.

Le rapport doit être obtenu directement depuis l’exécution. Un statut déclaré par l’agent ou par le script testé n’est pas, à lui seul, une preuve indépendante.

## 7. État de la PR #663 au démarrage du protocole

Vérification du 26 novembre 2026 :
- PR #663 ouverte, en brouillon, tête bb0a8168edc2e2b472b3f400729f41ff4ba93a9d;
- 70 scénarios spécifiés; 39 avec oracle O et 31 avec oracle P dans la spécification actuelle;
- 0/70 scénarios exécutés;
- validateur documentaire déterministe ajouté dans tools/qa/arch12_spec_validator.py, couvert par 7 tests structurels/négatifs;
- modèle abstrait fini ajouté dans tools/qa/arch12_reference_model.py, couvert par 8 tests incluant l’exploration exhaustive des branches définies et trois mutations fautives;
- CI sur le SHA 684cd58942bbf25da8c3f5214907d679ee974965 : 1472 tests Python réussis, 2 avertissements; godot-smoke réussi; quality-full ignoré selon la configuration PR;
- ces résultats valident l’inventaire documentaire et le modèle abstrait seulement, pas les scénarios du jeu;
- aucun résultat MC-007 automatisé n’est encore disponible;
- la CI existante contrôle le dépôt, mais ne prouve pas l’exécution fonctionnelle d’ARCH-12.

## 8. Limites et conclusion de statut

Les contrôles automatisés peuvent établir la cohérence des règles formalisées, la couverture déclarée et la conformité du modèle ou du runtime à ces règles. Ils ne peuvent pas déterminer si une interprétation ambiguë du texte source est juste sans règle suffisamment précise. Ils ne valident pas une implémentation absente.

MC-007 : EN ATTENTE. Ce document définit une voie proposée sans reviewer humain externe; il ne constitue pas encore son exécution ni sa preuve. La validation pourra être requalifiée uniquement après mise en œuvre des contrôles, examen des résultats sur les SHA exacts et confirmation que cette forme d’évaluation distincte est adaptée à la classification de risque applicable.

## 9. Sources de méthode consultées

- NIST AI RMF — Measure: https://airc.nist.gov/airmf-resources/airmf/5-sec-core/ — principes de TEVV objective, répétable et documentée. Cadre mobilisé par analogie; il ne gouverne pas LITD.
- NIST CSRC — independent verification and validation: https://csrc.nist.gov/glossary/term/independent_verification_and_validation/ — distinction avec l’IV&V formelle.
- OpenAI — Evaluation best practices: https://developers.openai.com/api/docs/guides/evaluation-best-practices — définition préalable d’objectifs, de jeux de cas et d’évaluations continues.
- Correlated Errors in Large Language Models: https://arxiv.org/abs/2506.07962 — erreurs partagées entre modèles et effets sur l’évaluation par jugement IA.
- Nine Judges, Two Effective Votes: https://arxiv.org/abs/2605.29800 — limites d’une majorité de juges IA lorsque les erreurs sont corrélées.

## Point de reprise

Prochaine action technique : relier les oracles déterminés à un runtime ARCH-12 approuvé et ajouter un adaptateur d’exécution; tant que ce runtime et ses hooks sont absents, maintenir les 70 scénarios fonctionnels à 0/70. Ne pas prétendre valider le gameplay tant que le runtime et les hooks ARCH-12 restent absents.

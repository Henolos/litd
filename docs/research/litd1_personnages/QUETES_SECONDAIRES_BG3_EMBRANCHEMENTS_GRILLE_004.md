# QS-004 — Astarion, Shadowheart et grille commune des quêtes LITD 1
**18 novembre 2026 | 🟡 À consolider | spoilers.**
**Méthode :** vérification documentaire de conditions d'embranchement à partir de bg3.wiki, source communautaire détaillée ; **aucun test en jeu ni contrôle du code de Baldur's Gate 3**. Les seuils documentés peuvent dépendre de versions et présenter des anomalies. Le présent dossier ne valide aucune mécanique LITD 1.

## Astarion : rituel de Cazador
| Condition / décision | Issue rapportée | Lecture narrative |
|---|---|---|
| Astarion présent et rituel possible, aide accordée | Ascension, sacrifice de Cazador et des captifs | La liberté recherchée se transforme en domination |
| Persuasion réussie pour renoncer | Cazador tué, Astarion reste vampire non ascendant et libre | Le protagoniste de l'arc change de projet |
| Refus d'aider sans persuasion | Astarion quitte le groupe définitivement | Le joueur n'est pas propriétaire de sa loyauté |
| Rituel commencé puis interrompu | Astarion devient hostile | Le choix du joueur a un coût relationnel extrême |
| Un participant sacrificiel meurt pendant le combat | Rituel impossible, Astarion tue Cazador sans ascension | Un état du monde rend une issue inaccessible |
| Astarion absent | Autre traitement du rituel et des prisonniers | Présence du protagoniste change la scène |
**Nuance importante :** tuer un participant au rituel peut conduire à des réactions de PNJ comme si Astarion avait volontairement renoncé. Cette disjonction entre état et interprétation doit être vérifiée, non reproduite automatiquement.
Sources : https://bg3.wiki/wiki/Investigate_Cazador%27s_Palace ; https://bg3.wiki/wiki/The_Pale_Elf ; https://bg3.wiki/wiki/Astarion/Romance .

## Shadowheart : Nightsong et autonomie conditionnelle
| Condition / choix | Issue rapportée | Limite |
|---|---|---|
| Approbation >= 40, laisser Shadowheart décider ou se taire | Peut épargner Nightsong sans test | Certaines formulations de dialogue forcent d'autres issues |
| Approbation < 40 | Peut tuer Nightsong sans persuasion réussie | Les seuils et options dépendent du dialogue |
| Approbation 20–39 avec suffisamment de Nightsong Points | Certaines options de persuasion disparaissent et elle peut tuer Nightsong | Wiki signale un **bug possible**, non établi par nous |
| Empêcher Shadowheart de décider | Départ définitif possible | Le personnage revendique sa décision |
| Nightsong épargnée ou tuée | Arcs de loyauté et d'identité divergents | Conséquences ultérieures à documenter précisément |
Sources : https://bg3.wiki/wiki/Nightsong_Point ; https://bg3.wiki/wiki/Nightsong%27s_Prison .
**Attention :** les Nightsong Points ne sont pas un compteur magique garantissant une issue ; conditions d'approbation et choix de dialogue interagissent. Ne pas généraliser à tous les patchs sans tests.

## Comparaison des cinq arcs étudiés
| Arc | Qui porte le récit ? | Décision appartenant au personnage | Influence du joueur | Persistance |
|---|---|---|---|---|
| Baron/Anna/Tamara | Famille et personnes affectées | Tamara agit et cherche sa mère | Enquête, choix dans une autre quête | Destins familiaux |
| Astarion | Astarion et victimes du rituel | Accepter ou renoncer à l'ascension | Persuasion, aide, interruption, état du combat | Liberté, départ, morts |
| Shadowheart | Shadowheart, Aylin, parents | Choix concernant Nightsong sous conditions | Relation, persuasion, silence | Loyauté et identité |
| Judy | Judy, Evelyn, travailleuses de Clouds | Initiative contre Clouds | Soutien, rémunération, choix politiques | Relations et conséquences sociales |
| Panam | Panam et Aldecaldos | Projet contre la stratégie de Saul | Soutien ou dénonciation | Suite de quêtes et alliance |

## Grille commune d'évaluation proposée pour LITD 1
**Proposition de recherche, non règle de production validée.** Noter chaque critère **0 absent / 1 faible / 2 correct / 3 fort / NÉ non évalué**, avec preuve et commentaire. **Ne pas additionner les notes sans pondération et vérification.**
1. **Protagoniste PNJ identifiable :** la quête appartient-elle à un habitant, et non au héros jouable ?
2. **Vie antérieure :** le conflit existe-t-il avant l'arrivée du joueur ?
3. **Motivation cohérente :** désir, peur, contradictions, intérêts propres ?
4. **Initiative du PNJ :** agit-il sans attendre une instruction du joueur ?
5. **Autonomie décisionnelle :** prend-il au moins une décision importante, même si le joueur peut l'influencer ?
6. **Conflit humain/social :** autres personnages dotés d'intérêts incompatibles ?
7. **Révélations préparées :** le retournement modifie-t-il la compréhension sans arbitraire ?
8. **Influence lisible du joueur :** limites et conséquences des interventions compréhensibles ?
9. **Conséquences persistantes :** relations, lieux, morts, mémoire du monde ?
10. **Rythme et émotion :** alternance de tension, calme, humour, intimité et dénouement ?
11. **Absence de frustration artificielle :** pas de délai ou d'échec caché et injuste ?
12. **Faisabilité et testabilité :** états limités, branches vérifiables, cohérence avec les systèmes existants ?
**Exigence spéciale :** Anouk, Marec, Mathilde et Aurélien conservent leur statut particulier ; les autres héros jouables sont des accès aux récits, sans absorber l'agence des habitants.

## Test narratif de référence proposé
Pour toute quête candidate, rédiger trois synopsis séparés :
- **Sans intervention du joueur :** trajectoire hypothétique des habitants, explicitement conçue (pas prétendue déjà simulée).
- **Intervention minimale :** le joueur découvre, aide ou témoigne sans décider à leur place.
- **Intervention forte :** le joueur modifie des conditions, mais les PNJ conservent des objectifs et des réactions cohérents.
Comparer le résultat avec la grille, puis seulement estimer coût de développement et tests.

## Contrôles restants
- Tester les embranchements BG3 sur une version identifiée et sauvegardes reproductibles.
- Examiner les scripts, les conséquences à long terme, les éventuelles contradictions de wiki et les patchs.
- Appliquer la grille à une quête pilote LITD 1 sans la déclarer approuvée.
- Faire valider explicitement l'intégration de la grille au document maître.

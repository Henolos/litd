# Registre de preuves historiques — capture et recrutement

27 novembre 2026. Transcription des ajouts des commits originaux, à valeur de preuve historique, NON réactivation normative automatique. Toute clause remplacée reste historique. ARCH-07 impose capture et recrutement NG+ pour mini-boss, Némésis et boss ; V7.60/69 remplacent le refus définitif des captifs éligibles extraits ; bloc 12.2 interdit transport assisté des héros, non celui des captifs ennemis. ARCH-09 conserve possession réelle. V7.56 : clauses relatives aux anciennes classes, spécialisations, maîtrise et emplacements suspendues pour réexamen ; V7.54 : exemple d'organe ne réintroduit pas un système d'organes vitaux (CIB-19). V7.64 texte intégral non retrouvé. Aucun barème ni nouvel arbitrage validé.

Source : https://github.com/Henolos/litd/commit/17dfe289ae16bdf4d70d8b696959d9cb6b6add5c

---
## V7.46 — Capture hybride par familles et particularités individuelles (23 novembre 2026)

**VALIDÉ EN CONCEPTION : option C, capture hybride par familles et particularités individuelles, avec les douze règles complémentaires explicitement approuvées.**

1. Distinguer éligibilité, tentative de capture et recrutement.
2. Respecter nature et anatomie des créatures.
3. Plusieurs méthodes compatibles possibles pour certaines espèces.
4. Particularités individuelles possibles au sein d'une espèce.
5. Aucun seuil de PV universel.
6. Immobilisation ne signifie pas nécessairement capturabilité.
7. Connaissances ou équipements spécifiques éventuellement nécessaires.
8. Aucun spécialiste indispensable à toutes les captures.
9. Respecter les restrictions de recrutement des cinq boss principaux en NG+.
10. Capture réussie ne garantit pas recrutement.
11. Réutiliser les familles de mécaniques pour limiter les coûts.
12. Résultats conservés dans la sauvegarde transactionnelle, sans duplication ni nouveau tirage au rechargement.

Familles indicatives non encore validées individuellement : immobilisation physique, neutralisation non létale, affaiblissement chimique, soumission, confinement magique, scellement spirituel, désactivation. Méthodes détaillées, probabilités, coûts et tests restent ouverts. Validation documentaire uniquement.

---

Source : https://github.com/Henolos/litd/commit/16ce7fe802f0b3ef0d53d6ff11a94e429b60e4ae

---
## V7.47 — Méthodes de capture indépendantes ou combinables (23 novembre 2026)

**VALIDÉ EN CONCEPTION : option C, méthodes de capture indépendantes ou combinables selon la créature, sept familles et douze règles complémentaires explicitement approuvées.** Familles : immobilisation physique, neutralisation non létale, affaiblissement alchimique, soumission, confinement magique, scellement spirituel, désactivation.

1. Retenir les sept familles.
2. Autoriser leur utilisation indépendante ou combinée.
3. Respecter les compatibilités anatomiques, biologiques et surnaturelles.
4. Permettre la neutralisation non létale.
5. Distinguer neutralisation temporaire et capture effective.
6. Plusieurs héros peuvent contribuer à une capture.
7. Les blessures anatomiques peuvent faciliter ou compromettre la capture.
8. Une créature définitivement morte ne peut être capturée vivante.
9. Une méthode incompatible ne devient pas efficace par répétition.
10. Certaines méthodes nécessitent équipements, consommables ou compétences particulières.
11. Les méthodes découvertes sont consignées dans le bestiaire collectif.
12. Coûts, durées, résistances et probabilités à déterminer lors des arbitrages et tests.

Les combinaisons illustratives ne sont pas des recettes définitives par espèce. Préserver V7.46 et V8.3. Validation documentaire uniquement.

---

Source : https://github.com/Henolos/litd/commit/f3f3b6b6ae8dfff70c54a4dcb037a2d3adfe87cd

---
## V7.48 — Moteur commun de calcul des probabilités de capture (23 novembre 2026)

**VALIDÉ EN CONCEPTION : option C, moteur commun de calcul des probabilités de capture avec coefficients contextuels, affichage de la probabilité réelle et douze règles complémentaires explicitement approuvées.**

1. Moteur commun avec coefficients contextuels.
2. Conserver les cinq facteurs : PV, états de combat, nature de l'ennemi, équipement de capture, moral et volonté.
3. Adapter leur importance à chaque famille de méthodes.
4. Prendre en compte les caractéristiques individuelles.
5. Vérifier l'éligibilité avant calcul probabiliste.
6. Afficher la probabilité réelle avant confirmation.
7. Actualiser la probabilité à chaque changement pertinent.
8. Distinguer capture impossible et difficile.
9. Réussite garantie possible si conditions spécifiques justifiées.
10. Ne pas révéler automatiquement les caractéristiques secrètes par les coefficients détaillés.
11. Enregistrer durablement les résultats résolus, sans nouveau tirage au rechargement.
12. Formules, coefficients, plafonds et seuils définitifs après simulations et tests de combat.

Simulation et maquette HUD indicatives, aucun coefficient, coût ou seuil numérique validé. Préserver V7.46–V7.47 et V8.3. Validation documentaire uniquement.

---

Source : https://github.com/Henolos/litd/commit/b6ca07f91e96c0efdaf4f83bdac01110e2ffe75a

---
## V7.51 — Résistance hybride, progressive et contextuelle après échec de capture (23 novembre 2026)

**VALIDÉ EN CONCEPTION : option C, résistance hybride, progressive et contextuelle après échec de capture, conséquences contextuelles et douze règles complémentaires explicitement approuvées.** Résistance spécifique à la méthode et résistance générale de vigilance/comportement lorsque compatible avec la nature de la cible ; temporaires, cumulatives et plafonnées.

1. Une tentative ratée peut augmenter temporairement les résistances.
2. Distinguer résistance générale et spécifique à une méthode.
3. Adapter les résistances à la nature et aux capacités de la créature.
4. Accumulation dans des limites définies.
5. Diminution progressive selon temps et événements du jeu.
6. Changer de méthode peut contourner certaines résistances.
7. Une simple alternance ne doit pas annuler artificiellement toutes les résistances.
8. Nouvelle préparation tactique pouvant améliorer les chances.
9. Actualisation immédiate de la probabilité réelle affichée.
10. Conséquences contextuelles supplémentaires possibles après échec.
11. Conservation des résistances actives après sauvegarde et rechargement, sans réinitialisation artificielle par déplacements.
12. Plafonds, durées, coefficients et conséquences définitives après simulations et tests.

Conséquences possibles, non systématiques ni obligatoirement cumulées : rupture d'entrave, consommation de l'équipement utilisé, agressivité accrue, réaction défensive immédiate, perte d'occasion favorable, tentative de fuite réservée aux Némésis selon V7.41. Réactions par famille et simulation numérique indicatives. Préserver V7.46–V7.48 et V8.3. Validation documentaire uniquement.

---

Source : https://github.com/Henolos/litd/commit/0b9ee847c510aaa498e3c774ffcb5e77d4d22891

---
## V7.52 — Apprentissage hybride, expérimental et documentaire des méthodes de capture (23 novembre 2026)

**VALIDÉ EN CONCEPTION : option C, apprentissage hybride, expérimental et documentaire des méthodes de capture, cinq niveaux de connaissance et douze règles complémentaires explicitement approuvés.** Sources complémentaires : observation, combats, expérimentation, ouvrages, dialogues, recherches à la Guilde. Niveaux par méthode et espèce : inconnu, suspecté, identifié, confirmé, documenté. Une incompatibilité confirmée constitue une information, non un sixième niveau.

1. Apprentissage hybride par plusieurs sources.
2. Conserver les connaissances dans le bestiaire collectif.
3. Distinguer connaissance théorique et maîtrise individuelle.
4. Découverte par expérimentation possible.
5. Apprentissage par réussites et échecs significatifs.
6. Distinguer les cinq niveaux de connaissance.
7. Confirmation par recoupement des sources.
8. Informations partielles ou erronées si narrativement justifiées.
9. Valoriser recherches et compétences des PNJ de la Guilde.
10. Préserver connaissances collectives après morts et Game Over.
11. Empêcher acquisition illimitée par répétition identique sans nouvelle information.
12. Afficher probabilité réelle sans révéler automatiquement les caractéristiques secrètes.

La connaissance ne remplace pas les capacités d'exécution. Attributions précises des PNJ, seuils, coûts et conditions de déblocage restent proposés ou ouverts. Préserver V7.46–V7.48, V7.51 et V8.1–V8.3. Validation documentaire uniquement.

---

Source : https://github.com/Henolos/litd/commit/903f6cbc9e3c3b7cef477d41498a9b5fecb59b1f

---
## V7.54 — Missions de recherche de la médecin et apprentissage de la capture (23 novembre 2026)

**VALIDÉ EN CONCEPTION : intégration explicite des missions de recherche de la médecin comme source d'apprentissage des méthodes de capture et d'enrichissement du bestiaire collectif, avec exemples de missions et répartition des responsabilités approuvés.** Complète V7.52 et le rôle validé dans docs/knowledge/guild_illustrated_hub_decision.md (PR #633).

Exemples approuvés : rapporter des échantillons biologiques (résistances alchimiques), un organe particulier (faiblesses anatomiques), une créature vivante (méthodes de neutralisation), un cadavre (physiologie et anatomie), observer une réaction en combat (résistances et comportements), étudier plusieurs individus (particularités intra-espèce).

Responsabilités : médecin — recherche expérimentale, anatomie, physiologie, faiblesses et méthodes de capture ; Wei Shan — conservation, documentation, recherches historiques et mythologiques ; maîtresse d'armes — apprentissage pratique des techniques. Les récompenses de connaissance alimentent le bestiaire collectif et persistent après succession selon V8.1, qui prévaut sur les anciennes règles de bestiaire propre au protagoniste et de reprise avec le même protagoniste figurant dans la PR #633. Les exemples ne fixent pas les quêtes individuelles, coûts, modalités de transport ni récompenses chiffrées. Validation documentaire uniquement.

---

Source : https://github.com/Henolos/litd/commit/1a8112fac222cc15f66a397696c9c8371fcb3ffd

---
## V7.56 — Maîtrise commune et spécialisations complémentaires de capture (23 novembre 2026)

**VALIDÉ EN CONCEPTION : option C, maîtrise commune et spécialisations complémentaires de capture, douze règles complémentaires et réutilisation du système de maîtrise existant explicitement approuvées.**

1. Héros compatibles capables d'utiliser des méthodes élémentaires de capture.
2. Prévoir une classe spécialisée dans la capture.
3. Certaines autres classes peuvent posséder des compétences complémentaires de capture.
4. Créatures recrutables pouvant disposer d'aptitudes naturelles favorables à la capture.
5. Aucun spécialiste indispensable à l'ensemble des captures.
6. Limiter et plafonner les bonus individuels de probabilité.
7. Privilégier avantages tactiques plutôt que seuls bonus statistiques.
8. Réutiliser la maîtrise fondamentale et avancée existante.
9. Reconnaître les contributions directes et indirectes significatives à une capture.
10. Respecter limites d'emplacements et règles de spécialisation avant et après NG+.
11. Préserver maîtrise des survivants et réservistes, sans transmettre celle des morts aux successeurs.
12. Compétences, bonus, coûts en PA et conditions particulières à déterminer après conception détaillée des classes et tests d'équilibrage.

Pas de jauge d'expérience parallèle ni d'emplacement supplémentaire. Les missions de la médecin enrichissent les connaissances collectives, sans remplacer la maîtrise pratique. Respecter V8.1–V8.3, notamment les contributions réelles, causalité et absence de crédit posthume. Profils et techniques illustratifs non validés individuellement. Validation documentaire uniquement.

---

Source : https://github.com/Henolos/litd/commit/08ee7e50b5b9ab598520c50198778c5f8dde44ee

---
## V7.58 — Transport contextualisé et surveillance simplifiée des créatures capturées (23 novembre 2026)

**VALIDÉ EN CONCEPTION : option C, transport contextualisé et surveillance simplifiée des créatures capturées, avec quatorze règles complémentaires explicitement approuvées.**

1. Distinguer capture réussie, sécurisation, transport, extraction et recrutement.
2. Interdire transfert automatique à la Guilde.
3. Adapter moyens de transport à la nature et aux dimensions des créatures.
4. Capacité de contention limitée, distincte de l'inventaire ordinaire.
5. Captifs non comptabilisés parmi les quatre combattants actifs.
6. Poursuite de l'expédition possible après capture.
7. Retour immédiat au refuge selon conditions déjà validées.
8. Risques contextuels d'évasion, blessure ou perte des captifs.
9. Informer le joueur de l'état des contentions et risques connus.
10. Libération ou abandon volontaire possible, avec conséquences persistantes.
11. Préserver identité, blessures et particularités individuelles des créatures transportées.
12. Prendre en compte les captifs lors d'une défaite ou Game Over, sans transfert automatique ni duplication.
13. Remise des spécimens à la médecin pour ses missions de recherche.
14. Capacités, coûts, contraintes de surveillance et probabilités d'incidents à déterminer après simulations et tests.

L'évasion d'un captif est une rupture de contention distincte de la fuite volontaire en combat réservée aux Némésis. Moyens de transport, états et chiffres de la maquette indicatifs. Respecter retour conditionnel au refuge, V7.46–V7.56 et V8.1–V8.3, sauvegarde transactionnelle. Validation documentaire uniquement.

---

Source : https://github.com/Henolos/litd/commit/ee57227b352dfe15df2307d349efa1bf372c60a6

---
## V7.59 — Système commun et parcours de recrutement contextuels (23 novembre 2026)

**VALIDÉ EN CONCEPTION : option C, système commun avec parcours de recrutement contextuels, sept familles, cinq états relationnels et seize règles complémentaires explicitement approuvés.**

Familles : apprivoisement, persuasion, allégeance, pacte, purification, liaison spirituelle, réactivation. États relationnels lorsque compatibles : hostile, méfiant, réceptif, coopératif, loyal. Loyauté maximale non nécessaire au recrutement ; constructions artificielles pouvant relever de conditions fonctionnelles plutôt que relationnelles.

1. Distinction stricte capture et recrutement.
2. Moteur commun avec conditions contextuelles.
3. Retenir les sept familles.
4. Plusieurs méthodes compatibles possibles par créature.
5. Recrutement narratif sans capture préalable possible.
6. Installations adaptées de détention et prise en charge, capacité limitée et évolutive.
7. Intégrer soins, recherches et contributions des PNJ.
8. Cinq états relationnels lorsque la nature le justifie.
9. Capture ne garantit pas recrutement.
10. Refus, libération, remise à la recherche ou maintien en détention selon circonstances.
11. Conserver identité, histoire et particularités individuelles.
12. Cinq boss principaux recrutables uniquement en NG+.
13. Préserver conséquences persistantes, empêcher duplications et résurrections artificielles.
14. Empêcher augmentation illimitée de confiance par interactions identiques répétées.
15. Intégrer les créatures recrutées aux réserves de combattants sous réserve des capacités disponibles.
16. Coûts, durées, seuils, capacités et effets de loyauté après simulations et tests.

Installations illustratives : ménagerie, quartier de détention, laboratoire, chambre de confinement, sanctuaire, atelier ; organisation architecturale non arrêtée, aucune modification des planches validées. Missions médicales complémentaires indicatives, préserver V7.54, V7.56, V7.58 et V8.1–V8.3. Validation documentaire uniquement.

---

Source : https://github.com/Henolos/litd/commit/01c725fd6d4f3571ddd54dff3fb68f041befaf93

---
## V7.60 — Correction : garantie de recrutement après capture (23 novembre 2026)

**Décision utilisateur explicite : la capture garantit le recrutement ; le niveau de loyauté et de confiance détermine le délai avant intégration au groupe, exprimé en nombre d'expéditions.** Cette correction remplace les clauses contraires de V7.46 et V7.59 (notamment règle 9 et refus définitif de recrutement après capture). Conserver la distinction capture, extraction, détention et recrutement ainsi que les restrictions d'éligibilité, notamment les cinq boss principaux recrutables uniquement en NG+. La garantie concerne le recrutement futur d'un captif éligible ramené vivant ou dans un état compatible, et ne supprime pas les risques de transport ni les décisions volontaires de libération ou remise à la recherche. Les recrutements narratifs sans capture restent possibles. Barème d'expéditions, événements comptabilisés, évolution de confiance et loyauté et modalités de disponibilité à préciser ; aucune valeur numérique validée. Validation documentaire uniquement.

---

Source : https://github.com/Henolos/litd/commit/70b4131c711746a0560691045a2c7a394da335db

---
## V7.69 — Délai garanti et progression relationnelle évolutive (24 novembre 2026)

**VALIDÉ EN CONCEPTION : option C et dix-huit règles complémentaires explicitement approuvées.**

1. Recrutement garanti après capture et extraction éligibles.
2. Distinguer confiance et loyauté.
3. Conserver cinq états relationnels validés.
4. Délai initial exprimé en nombre d'expéditions.
5. Adapter délai aux particularités individuelles.
6. Garantir délai maximal fini, sans prolongation indéfinie.
7. Progression naturelle à chaque expédition admissible.
8. Soins, recherches et interactions pertinentes peuvent réduire délai.
9. Adapter progression aux sept familles de recrutement.
10. Exclure expéditions artificielles sans activité significative.
11. Comptabiliser chaque expédition admissible une seule fois.
12. Décompte après arrivée effective du captif à la Guilde.
13. Afficher nombre d'expéditions restantes.
14. Intégration automatique aux réserves à échéance, contraintes de disponibilité et capacité traitées séparément.
15. Cinq boss principaux recrutables uniquement en NG+.
16. Préserver progression lors des successions pour captifs conservés à la Guilde.
17. Conserver caractéristiques relationnelles après recrutement.
18. Barèmes, seuils, effets relationnels et critères précis d'admissibilité après simulations et tests.

Respecter V7.59–60 et V8.3. Confiance : perception de sécurité et fiabilité ; loyauté : attachement et volonté de servir. Compatibilité fonctionnelle pour constructions non conscientes. Barème illustratif hostile 5, méfiant 4, réceptif 3, coopératif 1, loyal 0 non validé numériquement. Expéditions significatives réussies ou non, y compris retraite ou Game Over, candidates au crédit ; critères précis ouverts. Pas de crédit pour expédition de capture du nouveau captif, rechargement ou simple aller-retour. Plusieurs missions dans une expédition ne multiplient pas le crédit. Aucun refus aléatoire d'ordre en combat approuvé. Aucun code ni test modifié. Prochain arbitrage : priorités des réactions et interceptions.

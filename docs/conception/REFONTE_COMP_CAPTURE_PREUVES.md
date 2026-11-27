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


## Préséance du 27 novembre 2026 — CAP-HUB

Accords utilisateur : « Tous les captifs sont envoyés au hub à la fin du combat » ; « Je valide l'option A pour le transfert automatique des captifs au hub. Réconcilie toutes les règles concernées. » Les transcriptions historiques ci-dessus restent intactes, mais V7.58 et V7.60/69 ne prescrivent plus de transport en exploration : transfert automatique de tous les captifs encore détenus après victoire uniquement, jamais automatiquement après retraite, défaite ou Game Over. Voir la table de préséance CAP-HUB du document maître et le commit https://github.com/Henolos/litd/commit/639d91bd0883627b6a5546454c58aea55a3655f5 . Contention tactique, éligibilité ARCH-07, détention au hub, recrutement différé, possession ARCH-09 et persistance V8.3 conservés. Aucun test runtime ni assurance indépendante.


## MC-007 — Journal de contrôle partiel du bloc 12.4 (27 novembre 2026)

Révision inspectée : bc686a79fcb0ac2cd89a4b3db5a5b8d362abfea6. CAP-J : 7d749b6869470a7e0a5ec2055201b0e0eccee91c ; CAP-I : ee68587581db9c58a397023de29255aea6676570 ; statuts : b4c8634070780172c8f069b5f9cedfbe7c997a08 ; CAP-K : bc686a79fcb0ac2cd89a4b3db5a5b8d362abfea6 (nouvelle validation explicite remplaçant le texte original introuvable). 152 identifiants uniques, 13 contrôles structurels réussis lors de l'intervention précédente.

Relecture ciblée : anciennes mentions de transport aux lignes 2617, 2726, 3526, 3528 ; réserves historiques aux lignes 3714 et 3732. Préséance CAP-HUB/I/J/K applicable ; renvois locaux à consolider. ARCH-07 : mini-boss, Némésis et boss capture/recrutement NG+ uniquement, éligibilité individuelle maintenue. Recherche indexée branche principale (captifs transport, ARCH-07, CAP-HUB) sans résultat ; couverture dépôt non démontrée.

Modèle abstrait exploratoire : 2 états NG+, 5 catégories, 2 états éligibilité, 4 issues, 2 états saturation, soit 160 combinaisons ; zéro violation des invariants encodés. Modèle construit à partir des règles, non indépendant, non connecté au moteur ; ne constitue ni preuve d'implémentation ni validation MC-007. Aucun test runtime. AUD-CAP-08 réservé au bloc 12.5. Clôture non autorisée ; audit exhaustif et contrôles indépendants reproductibles restent ouverts.


## MC-007 — Mutations ciblées (27 novembre 2026)

Index de préséance consolidé : e5ad0fe1dbd1f739615e4b3da4d4e7c5a2597fc1. Suite documentaire autonome : docs/conception/audit/capture_mutations.mjs, commit 1d02c7a210bdd9b6155a8cb72a95bfb33f8a61b9. Relecture du fichier et exécution de sa logique équivalente en JavaScript : 8 assertions de référence réussies, 8 mutations détectées (ng, defeat, full, delay, rank, pa, duplicate, transport). Exécution directe Node.js et CI non réalisées ; modèle et assertions conçus ensemble, indépendance non démontrée ; aucun test moteur. Couverture exhaustive du dépôt non démontrée. MC-007 reste ouvert.


## MC-007 — Preuves CI vérifiées (27 novembre 2026)

Commit testé 1a5b2e18aef0674fbc4649282b000b2a3f7ddf11 ; CI https://github.com/Henolos/litd/actions/runs/46005655585 ; job quality 140528024867 réussi, godot-smoke réussi, quality-full ignoré selon configuration PR. Archive 15201970923 téléchargée et SHA-256 recalculé conforme : e0df6c983fcaf54e42dcd5b0d482f0aeaf41b557822169625aa0758b73f2e71d. XML analysé : 1473 tests, 0 échec, erreur ou skip ; 16 cas MC-007 identifiés individuellement réussis dont 8 mutations détectées. Deux SyntaxWarning invalid escape sequence dans tools/ci/generate_godot_status.py lignes 154–155, hors périmètre, non corrigés. Séparation physique du modèle et des assertions aux commits a139d30d94f865077f6a7658c95a2a39742b858f et ce0fa593b3872d2505c8b3f680749398225d2a05 ; nouvelle exécution CI nécessaire. Indépendance de conception et couverture exhaustive non démontrées ; aucun test gameplay capture. MC-007 ouvert.


## MC-007 — Audit transversal résiduel (27 novembre 2026)

Révision 46fc52866f706429caa4e11c2f7ef9c3cfc72531 : sept workflows réussis, CI https://github.com/Henolos/litd/actions/runs/46005960627 ; artefact 15201117043 disponible, XML non inspecté lors de cette intervention. Registre précédent préservé. Arborescence récursive non tronquée, 2100 entrées ; inspection ciblée et non exhaustive du contenu. Écarts candidats : data/veilleurs/v07/recruitment_rules.json (bosses_recruitable false, target_not_boss, refuge_has_slot, limite 2 par expédition) ; data/world/ngplus_boss_recruits.json (tout boss vaincu, paramètres historiques) ; data/capture_wound_rules.json (barèmes historiques à vérifier) ; ADR-0008 (revalidate, exception Ange protégée à préserver). Usage runtime et statut des données après remise à zéro non démontrés. Ne pas réactiver ni supprimer ces données sans classification. Contrôles indépendants de conception non achevés ; MC-007 et clôture 12.4 restent ouverts.


## MC-007 — Dépendances historiques confirmées (27 novembre 2026)

Inspection à e9beeb1819ef73200166a2c86c0f5a84eac154d5 : tests/python/test_ngplus_boss_recruitment.py charge directement data/world/ngplus_boss_recruits.json et impose au moins 34 recrues, des identifiants historiques, la synchronisation party_average et des comparaisons de seuils/coûts Essence. Dépendance de test confirmée, usage moteur non démontré. Recherche indexée main sur ngplus_boss_recruits.json, capture_wound_rules.json, recruitment_rules.json et refuge_has_slot vide, malgré la dépendance constatée : index insuffisant pour prouver l'absence de consommateurs. Guardian angel-not-capturable à préserver. Ne pas réintroduire les catalogues historiques ni supprimer les tests avant inventaire des consommateurs et classification. MC-007 reste ouvert ; contrôles de non-réactivation à concevoir et exécuter.


## MC-007 — LEG-CAP et dépendances indirectes (27 novembre 2026)

Révision 3deb8d72abebc2394dad51121b87cc8a79ca7f0e : CI https://github.com/Henolos/litd/actions/runs/46006588322 ; job 140531197326, journal 1490 passed, 2 warnings in 12.05s. Six workflows complémentaires réussis, godot-smoke en cours à la consultation. XML nominatif non inspecté. Classification conservatoire : catalogues NG+ et V0.7 historiques non normatifs ; barèmes blessures non reconfirmés ; tests historiques de données préservés conformément au reset ; invariant Ange préservé ; document maître et CAP validés prioritaires. 25 scripts GDScript recensés. project.godot déclare DataLoader en autoload ; _ready appelle reload_all, qui charge notamment data/capturable_creatures.json. bestiary_screen.gd utilise DataLoader.bestiary_catalog ; aucun usage de capturable_creatures démontré dans ce composant. Chargeur générique conservé, chargement distinct d'une activation gameplay. Inspection ciblée ; tentative de balayage complet interrompue par limite du nombre d'appels. Dépendances dynamiques et autres consommateurs non exclus. Aucun changement moteur ou données ; MC-007 ouvert.


## MC-007 — Vérification LEG-CAP et catalogue capturable (27 novembre 2026)

CI du commit 3deb8d72abebc2394dad51121b87cc8a79ca7f0e : https://github.com/Henolos/litd/actions/runs/46006588322 ; journal quality 140531197326 : 1490 passed, 2 warnings in 12.05s ; Godot smoke confirmé réussi ; XML individuel non inspecté. Catalogue data/capturable_creatures.json inspecté à 674d00d8fbccb0eb118a1553b627ec148a398f1c : 3 entrées, 3 avec paramètres de capture, 3 avec arbres de compétences. Référence historique mixte chargée par data_loader.gd ; chargement ne prouve pas exécution du gameplay. Ne pas réactiver les anciens barèmes ou arbres sans validation. Analyse exhaustive des consommateurs interrompue par limite d'appels du connecteur ; MC-007 ouvert.

> **Révision proposée : V8.3 complétée par l’addendum de réconciliation du 24 novembre 2026 ci-dessous. La source V8.3 du 23 novembre est archivée sans modification.**

# LITD 1 — Document maître V8.3 — clôture des 40 arbitrages

**Date : 23 novembre 2026.** **Statut : conception validée, non implémentée et non testée.** La V8.2 et son socle historique V8.1 sont conservés intégralement après cette section. Les règles récentes prévalent seulement sur les contradictions expressément tranchées. **Clôture : série des arbitrages n° 1 à 40 close en conception ; chantier d'implémentation non clos.**

## Registre des décisions complémentaires

| N° | Décision | Statut |
|---|---|---|
| 37 | Vérification des invariants métier et empreinte SHA-256 canonique de l'état persistant reconstruit. | 🟢 Validé en conception |
| 38 | Migrations versionnées et sécurisées ; original préservé ; conversion sur copie ; validation avant publication. | 🟢 Validé en conception |
| 39 | Mode de récupération sécurisé et guidé ; aucune reconstruction inventée ni modification des originaux ; restauration uniquement d'états démontrablement cohérents. | 🟢 Validé en conception |
| 40 | Validation progressive : tests automatisés, interruptions simulées, migrations et essais réels sur Windows avant validation technique. | 🟢 Validé en conception |

## Règles techniques consolidées des arbitrages 30 à 40

1. **Unité atomique :** une action entièrement résolue avec toutes ses conséquences interdépendantes (dégâts multi-cibles, morts, captures, effets, ressources et crédits). Une succession peut constituer une transaction séparée si un état durable `succession_pending` garantit son achèvement exactement une fois.
2. **Journal durable :** une transaction irréversible confirmée doit inclure son identité de campagne, son ordre, sa révision de départ, ses préconditions, les modifications d'état nécessaires à une reprise complète, les événements permanents, l'état aléatoire nécessaire, les identifiants de crédits et une preuve d'intégrité. Ne jamais appliquer un marqueur de mort isolé à un état incompatible.
3. **Validation :** préparer, écrire, synchroniser durablement les données et la preuve de confirmation, puis publier l'instantané et le manifeste. La méthode exacte de synchronisation des fichiers et répertoires doit être adaptée à Windows et au système de fichiers. Une écriture non durable ne peut être garantie après coupure.
4. **Reconstruction :** partir du dernier instantané vérifiable, rejouer dans l'ordre uniquement les modifications d'état confirmées, sans resimuler les actions ; vérifier préconditions, unicité des transactions et continuité des révisions ; refuser les divergences.
5. **Invariants :** aucun héros unique dupliqué, aucune résurrection interdite, succession unique, pas de crédit personnel posthume, pas de double attribution, causalité et durée des effets conservées, ressources et équipement non dupliqués, acquis collectifs et quêtes persistants, ordre des transactions strict.
6. **Empreinte canonique :** représentation stable et documentée de l'état persistant (ordre des clés et collections, encodage, nombres, null, champs facultatifs, versions) ; exclure les données purement transitoires. Comparer SHA-256 attendu et calculé **en plus** des invariants. Une empreinte ne protège pas contre la modification volontaire du fichier et de son empreinte.
7. **Migrations :** versions distinctes du schéma de sauvegarde, des données de jeu et des règles ; chaîne explicite de migrations testées ; conversion non destructive sur copie ; conservation de l'original ; contrôle des invariants et empreintes avant publication ; version future inconnue non écrasée.
8. **Récupération guidée :** inspecter manifestes, instantanés et journaux ; ne proposer que des révisions entièrement vérifiables ; conserver les originaux ; ne jamais reconstruire artificiellement une mort, une succession ou un inventaire manquant ; si aucune reprise cohérente n'existe, bloquer la reprise de cette campagne avec diagnostic clair.
9. **Limites :** pas de garantie absolue contre la perte de données non synchronisées, panne matérielle, corruption de tous les supports ou copie manuelle d'anciennes sauvegardes hors ligne. Les garanties ne sont pas prouvées avant tests réels.

## Plan du chantier d'implémentation (proposé, non exécuté)

| Phase | Travaux | Preuve exigée |
|---|---|---|
| P0 — Audit | Examiner `Henolos/litd`, branche `main`, PR ouvertes, architecture de sauvegarde, scènes/scripts et environnement Windows ; ne pas créer de système parallèle | Inventaire des fichiers et écarts sourcé par commits |
| P1 — Contrat | Définir schémas de transaction, invariants, canonicalisation, versionnement et scénarios de référence | Spécifications revues + jeux de données de test |
| P2 — Prototype | Implémenter journal, instantanés, confirmation durable, restauration idempotente et secours sur branche isolée | Tests unitaires et d'intégration reproductibles |
| P3 — Résilience | Injecter des interruptions à chaque frontière ; corruptions, doublons, pertes de manifeste, attaques multi-cibles et succession | Matrice de tests automatisés, résultats et logs |
| P4 — Migration | Tester sauvegardes anciennes, futures et migrations interrompues ; garantir la conservation des originaux | Corpus de sauvegardes et rapports comparatifs |
| P5 — Windows | Produire un build identifiable ; vérifier fermeture forcée, reprise, sauvegardes sur disque réel et interface de récupération | Captures/logs, build et observations d'essai réels |
| P6 — Validation | Réconcilier les anomalies, contrôler les non-régressions, documenter limites et décider l'intégration | Rapport de validation, PR revue, décision explicite |

**Critères de passage :** zéro duplication/résurrection non autorisée ; aucune transaction partielle reconnue ; reprise identique à l'état persistant attendu ; corruption détectée sans modification des originaux ; migrations réversibles par préservation des sources ; essais Windows documentés. Aucun taux de réussite ni pourcentage de progression ne peut être annoncé sans résultats mesurés.

**État réel au 23/11/2026 :** décisions n° 1 à 40 closes en conception ; intégration documentaire réalisée dans cette V8.3 ; aucune implémentation ni campagne de tests attestée dans cette opération. **Avancement du chantier d'implémentation : À évaluer. Avancement du projet global : À évaluer.**

---

# Archive intégrale : V8.2 et socle V8.1

# LITD 1 — Document maître de conception V8.2 — consolidation des arbitrages 11 à 36

**Date : 23 novembre 2026**  
**Statut : décisions validées en conception ; intégration documentaire uniquement. Aucune implémentation ni validation en jeu attestée.**  
**Socle : V8.1 conservée intégralement ci-dessous.** Cette section nouvelle prévaut sur les passages historiques incompatibles pour les points expressément arbitrés. Les paramètres présentés comme indicatifs restent à équilibrer.

## Registre complémentaire des arbitrages validés

| N° | Décision validée en conception |
|---|---|
| 11 | Successeur : points de compétence correspondant au niveau hérité ; emplacements passifs personnels à regagner par maîtrise et défi. |
| 12 | Successeur : attributs de base de sa classe et points liés au niveau hérité à répartir dans les contraintes de classe. |
| 13 | Successeur : traits personnels initiaux compatibles, développement personnel sans héritage des traits du défunt. |
| 14 | Deux emplacements passifs de progression personnelle obtenus par accomplissements de classe/rôle, non par niveau numérique seul. |
| 15 | Deux jalons de maîtrise, fondamental et avancé ; contribution réelle en expédition obligatoire, entraînement de refuge complémentaire. |
| 16 | Objectifs de maîtrise mesurables et spécifiques à la classe/spécialisation, comptage automatique des contributions réelles. |
| 17 | Fondamental : 3 situations distinctes sur ≥2 expéditions et ≥2 catégories ; avancé : 6 situations supplémentaires sur ≥3 expéditions et ≥3 catégories, avec danger significatif ; pas de réutilisation. |
| 18 | Bonus d’entraînement évolutifs avec bâtiments, plafonnés ; ne remplacent pas diversité des expéditions et catégories. |
| 19 | Crédits et déblocages reconnus immédiatement en jeu, conservés après retraite/échec si le héros survit ; mort efface sa progression personnelle jouable. |
| 20 | Capture non létale réussie = victoire pour défi personnel si contribution active et héros vivant à résolution ; pas de coup final requis. |
| 21 | Progression par situations tactiques résolues, non par nombre brut d’actions. |
| 22 | Crédit individuel si contribution significative et vérifiable ; plusieurs héros peuvent être crédités pour une même situation. |
| 23 | Seuils hybrides selon rôle : 15 % des PV max de la cible indicatif pour soin/protection/dégâts OU conséquence tactique significative démontrable ; contrôle/capture par résultat effectif. |
| 24 | Pas de plafond arbitraire par combat ; seules menaces réellement distinctes comptent ; anti-farming. |
| 25 | Nouvelle menace reconnue par signature ou changement significatif du contexte tactique ; identifiant seul insuffisant. |
| 26 | Seuils de changement contextuel indicatifs (30 % PV alliés, 25 % dégâts potentiels entrants, 50 % ressource pertinente perdue) OU événement déterminant objectivable. |
| 27 | Traçabilité causale directe/indirecte/différée ; au plus un crédit par héros et situation ; sans plafond par combat. |
| 28 | Effets suivis durant leur activité et conséquences directement attribuables, sans limite arbitraire de tours ; corrélation seule insuffisante. |
| 29 | Aucun nouveau crédit personnel après mort définitive ; effets persistants possibles selon règles ; faits antérieurs archivables, non hérités. |
| 30 | Sauvegardes automatiques sécurisées en expédition ; attribution idempotente des crédits et états cohérents. |
| 31 | Reprise du combat au dernier état sécurisé à frontière cohérente ; événements déjà validés préservés. |
| 32 | Sauvegarde active + secours technique protégé ; registre cohérent des conséquences permanentes. |
| 33 | Registre transactionnel associé aux instantanés par révisions et validations cohérentes. |
| 34 | Journal durable prioritaire des morts définitives et transitions de succession, récupération transactionnelle cohérente. |
| 35 | Journal des conséquences permanentes et des données de résolution nécessaires à une reprise cohérente et déterministe. |
| 36 | Reconstruction par réapplication ordonnée des modifications d’état validées, sans resimulation des actions déjà résolues. |

## Spécification consolidée : maîtrise, succession et sauvegarde

### Succession et maîtrise individuelle
- Après l'anéantissement des quatre combattants, la succession narrative et la persistance du monde suivent les arbitrages 4 à 10 de V8.1.
- Le successeur reçoit le niveau numérique et les points de compétence correspondants, avec attributs et traits personnels propres à sa classe. Les emplacements passifs personnels doivent être regagnés ; les acquis collectifs restent acquis.
- La maîtrise se fonde sur des situations tactiques **résolues**, des contributions causales significatives, la diversité des expéditions et des objectifs, et des jalons distincts. Les seuils de 15 %, 30 %, 25 % et 50 % restent des **repères indicatifs**, pas des paramètres équilibrés par playtest.
- Une situation peut créditer plusieurs héros distincts, mais jamais plusieurs fois le même héros pour la même situation et le même jalon. Les contributions différées sont suivies sans limite arbitraire de tours, sous réserve d'une causalité démontrable.
- Une mort définitive interdit les nouveaux crédits personnels ; un effet déjà créé peut se poursuivre si les règles le permettent. Les accomplissements passés peuvent rester archivés sans être transmis au successeur.

### Architecture de sauvegarde validée
- Une sauvegarde active, un secours technique protégé et un registre transactionnel des conséquences permanentes sont associés par identifiants de campagne, transactions et révisions.
- Les conséquences irréversibles (morts définitives, transitions de succession) nécessitent une journalisation durable prioritaire, avant de permettre la poursuite des actions qui en dépendent.
- Les transactions enregistrent les modifications d'état et les données de résolution indispensables pour reconstruire un état cohérent, y compris lorsque les conséquences sont différées ou aléatoires.
- La reconstruction réapplique **dans l'ordre** les modifications d'état confirmées ; elle ne recalcule pas les attaques ni les tirages déjà résolus. La réapplication doit être idempotente.
- La confirmation d'une transaction doit désigner un ensemble cohérent ; une écriture incomplète ne peut pas être présentée comme validée. Une coupure antérieure à toute écriture durable peut faire perdre l'événement encore uniquement en mémoire vive.
- Une sauvegarde de secours n'autorise pas un retour arrière libre annulant des conséquences irréversibles confirmées. Si une reconstruction cohérente ne peut pas être prouvée, le jeu doit refuser la restauration plutôt qu'inventer des données.

### Invariants de reconstruction proposés, non encore arbitrés séparément
1. Identité unique des héros et absence de résurrection d'un héros définitivement mort.
2. Successeur unique par transition de succession confirmée.
3. Crédits de maîtrise attribués une seule fois par héros, situation et jalon ; pas de crédits posthumes.
4. Conservation de la causalité, des auteurs et des durées des effets différés.
5. Cohérence des inventaires, ressources, formations, captures, blessures et équipements.
6. Persistance des connaissances collectives, quêtes générales, bâtiments et conséquences narratives.
7. Application des seules transactions confirmées, dans l'ordre, une seule fois.

### Points encore ouverts, à ne pas considérer comme validés
- Arbitrage 37 : validation par invariants et empreinte canonique de l'état persistant (option B recommandée, non validée à ce stade).
- Arbitrages 38 à 40 : sérialisation/versionnement, migrations/récupération, et critères de recette/gel du périmètre (ordre de travail proposé, non validé).
- Granularité précise des checkpoints ordinaires, détails des transactions, garanties de synchronisation propres aux plateformes et comportement UX en cas de corruption.
- Les autres questions de gameplay et de production signalées dans V8.1 restent ouvertes lorsqu'elles ne sont pas explicitement résolues par les arbitrages 11 à 36.

### Statut d'exécution
- **Réalisé :** consolidation documentaire des arbitrages 11 à 36 sur socle V8.1.
- **Non réalisé :** audit du code de sauvegarde dans GitHub, implémentation, exécution des tests, vérification des performances, validation sur build jouable.
- **Avancement du chantier actuel : À évaluer. Avancement du projet global : À évaluer.**

---

# Socle V8.1 conservé intégralement (archive et références antérieures)

# LITD 1 — Document maître V8.1 : arbitrages de succession et persistance

**Statut : validé en conception, non implémenté ni testé.** Cette section est prioritaire sur les passages historiques contradictoires de la V8.0, conservée intégralement en annexe. Aucun point non tranché ne doit être considéré comme validé.

## Registre des décisions

| N° | Décision | Statut |
|---|---|---|
| 1 | Exploration par grande carte à nœuds ramifiés, retours et chemins cachés ; remplace la 3D isométrique. Combats 2D conservés. | Validé |
| 2 | Bestiaire persistant et maîtrise individuelle des compagnons ; précisé par le n° 5. | Validé |
| 3 | Même protagoniste survivant après Game Over. | **Remplacé par n° 4** |
| 4 | Après anéantissement des quatre combattants, nouveau protagoniste et nouvelle compagnie. Monde, narration, quêtes principales et secondaires générales conservent leur progression. Épreuves de Guilde avant reprise des missions. | Validé |
| 5 | Bestiaire transmis par les archives consultables de la Guilde ; maîtrise individuelle du successeur à reconstruire. | Validé |
| 6 | Réservistes survivants, progression intacte et disponibilité immédiate selon leur état normal. | Validé |
| 7 | Nouveau protagoniste au niveau numérique du précédent ; classe, identité, maîtrise et choix personnels nouveaux. Points de compétence à répartir. | Validé |
| 8 | Réputation et acquis relationnels permanents conservés ; liens personnels du successeur à construire ; souvenirs et relations des survivants préservés. | Validé |
| 9 | Quêtes personnelles d'un héros unique mort définitivement interrompues ou inaccessibles ; quêtes déjà terminées et acquis conservés. | Validé |
| 10 | Quêtes principales et quêtes personnelles/secondaires propres aux héros uniques sans dépendances de progression réciproques. | Validé |

## Règles actives après Game Over

1. **Mort définitive.** L'anéantissement des quatre combattants actifs entraîne la mort du protagoniste et des trois compagnons engagés, même si des réservistes survivent. Aucun héros unique mort ne revient ni ne peut être recruté de nouveau.
2. **Succession narrative.** Un nouveau protagoniste prend la relève, sans remise à zéro du monde, des choix, des conséquences, ni de l'état des quêtes principales et secondaires générales. Les épreuves spécifiques de la Guilde constituent une condition temporaire d'autorisation de reprise, **pas** une réinitialisation des quêtes. Le maître de la Guilde peut relever une ressemblance avec un héros disparu ; sa signification n'est pas fixée.
3. **Niveau du successeur.** Le niveau numérique du précédent protagoniste est transmis, pas sa classe, son identité, sa maîtrise pratique ni ses choix de spécialisation. Les points de compétence du nouveau personnage sont à répartir selon sa classe. Le calcul exact des points, des attributs, des traits et des emplacements passifs reste à arbitrer.
4. **Réservistes.** Les héros demeurés à la Guilde survivent et restent immédiatement disponibles, sous réserve des restrictions ordinaires liées à leur état. Ils conservent leurs niveaux, compétences, traits, équipements, blessures, souvenirs, affinités et maîtrise individuelle. Les héros morts ne sont pas replacés en réserve.
5. **Bestiaire.** Toutes les découvertes acquises restent accessibles dans les archives de la Guilde. Le successeur développe sa maîtrise propre ; les survivants gardent la leur.
6. **Hub et biens.** Bâtiments et améliorations du hub, coffre et biens/or qui y ont été déposés persistent, conformément aux règles V8.0. L'équipement porté par les combattants anéantis n'est pas transféré magiquement au coffre ; la récupération éventuelle dans le monde obéira aux règles des corps et du butin encore à préciser.
7. **Réputation et relations.** Réputation de la compagnie et conséquences collectives conservées. Les PNJ et compagnons se souviennent de leurs liens avec le héros mort, mais le nouveau protagoniste ne reçoit pas automatiquement ses affinités personnelles. Les survivants gardent leurs relations. Les déblocages permanents issus des relations (lieux, services, accès, récompenses déjà obtenues) restent acquis, sans faire revenir un personnage mort.
8. **Héros uniques.** Un héros unique vivant, déjà recruté et présent à la Guilde reste recruté et disponible. Un héros unique mort ne peut être recruté une seconde fois. Les héros uniques ne sont jamais dupliqués par le renouvellement du tableau de recrutement.

## Indépendance des quêtes et exception des héros uniques

- **Quêtes principales :** elles ne dépendent jamais de l'accomplissement d'une quête personnelle d'un héros unique. Aucun objet, personnage, accès ou événement exclusivement fourni par une telle quête ne peut bloquer la progression principale.
- **Quêtes personnelles/secondaires propres aux héros uniques :** elles ne dépendent pas réciproquement de la progression de la quête principale. Elles peuvent refléter le contexte du monde sans dépendance bloquante.
- **Si le héros unique meurt :** ses quêtes personnelles non commencées deviennent définitivement inaccessibles, celles en cours sont définitivement interrompues, celles achevées restent achevées. Les conséquences et déblocages permanents déjà obtenus restent acquis ; les récompenses jamais obtenues ne sont pas attribuées rétroactivement.
- **Quêtes secondaires générales :** leur état persiste après succession. Le sort de ces quêtes si un PNJ non héroïque indispensable meurt demeure une question ouverte.

## Contradictions historiques explicitement résolues

- La survie du même protagoniste après Game Over est **obsolète** : le nouveau protagoniste succède au défunt.
- Le bestiaire exclusivement personnel sans transmission est **obsolète** : archives persistantes de la Guilde, maîtrise individuelle non héritée.
- Toute remise à zéro des quêtes principales ou secondaires générales après Game Over est **obsolète**.
- La poursuite des quêtes personnelles d'un héros unique mort est **interdite**.
- Les dépendances de progression entre quêtes principales et quêtes personnelles des héros uniques sont **interdites**.
- L'exploration 3D isométrique comme système actif est **remplacée** par la carte à nœuds.

## Points ouverts et contrôles nécessaires

- Calcul exact des points de compétence, attributs, traits et passifs du successeur au niveau hérité.
- Contenu et conditions des épreuves de succession ; distinction entre accès temporairement verrouillé et progression des quêtes conservée.
- Règles de récupération des équipements et corps, notamment après Game Over.
- Réactions relationnelles détaillées, exceptions liées à la présence physique d'un héros mort, et destin des héros uniques jamais recrutés.
- Vérification des scénarios : aucune dépendance bloquante entre trame principale et quêtes personnelles des héros uniques.
- Équilibrage en prototype : successeur de niveau hérité, vétérans conservés, difficulté des épreuves.
- Le NG+ après victoire reste distinct de la succession après défaite.

**État d'exécution :** consolidation documentaire uniquement. Aucune implémentation, aucun test en jeu, aucune modification GitHub réalisés par cette mise à jour.

---

# Annexe historique : V8.0 intégrale, conservée pour traçabilité

# LITD 1 — DOCUMENT MAÎTRE DE CONCEPTION
**Version courante : 8.0 — document maître évolutif (conception) ; sections historiques conservées**  
**Date : 17 novembre 2026**  
**Périmètre : huit documents sources identifiés dans la conversation ; aucun dépôt ni jeu audité.**

## A. Règles de lecture et statut

- **Validé en conception** : décision explicitement confirmée, sans preuve de fonctionnement.
- **Préférence provisoire** : choix envisagé mais non arrêté définitivement.
- **Hypothèse / étude** : option proposée, non approuvée.
- **À arbitrer** : conflit, exception ou paramètre non résolu.
- **Non testé** : aucune preuve de fonctionnement en jeu dans les sources.
- Les arbitrages **explicites récents** de la fiche V2.1 et de la référence UI du 16 novembre prévalent sur les anciennes questions ouvertes uniquement sur le point précis qu’ils tranchent.
- Les anciennes idées (V0.5–V1.9) restent provisoires sauf validation explicite ultérieure ; leur répétition n’est pas une approbation.
- Les anciennes versions ne sont pas effacées du disque ; elles ne sont plus nécessaires pour la lecture quotidienne du présent document.

## B. Vision de travail et piliers

**LITD 1** : RPG tactique dark fantasy / dungeon crawler, exploration 3D isométrique en temps réel et combats au tour par tour ; atmosphère sombre orientée Berserk et rendu d’exploration évoquant No Rest for the Wicked. Ces références sont des intentions artistiques, pas des preuves de faisabilité.

**Piliers évoqués** : création des personnages ; gore systémique et conséquences corporelles ; philosophie et psychologie ; profondeur humaine accessible ; narration forte ; interconnexion des jeux ; rémanence de la connaissance. La cohérence narrative est transversale.

**Boucle de travail proposée, non validée par playtest** : préparation au refuge → exploration → affrontement / capture / choix de retraite → conséquences, butin et connaissances → retour au refuge ou perte de campagne.

## C. Arbitrages explicites récents : défaite, retraite et progression intercampagnes

**Source principale : fiche de vision V2.1 du 16 novembre. Les modalités non tranchées restent ouvertes.**

## 1. Vision maintenue
LITD 1 est un RPG tactique dark fantasy, dungeon crawler à exploration renouvelée et compagnie persistante. Les donjons peuvent changer de disposition entre expéditions tout en conservant la mémoire des morts, objets perdus et ennemis rencontrés. Les héros meurent définitivement. Les ennemis ayant tué un héros peuvent revenir renforcés dans le même donjon. Les corps abandonnés peuvent être retrouvés, pillés, disparaître ou être réanimés sous forme hostile. Ces orientations restent à spécifier et à tester.

## 2. Décisions explicitement confirmées
### Game Over
- La mort des quatre combattants engagés dans une expédition termine définitivement la campagne, même si des recrues restent au refuge.
- Tant qu'au moins un combattant survit, une retraite peut préserver la campagne.

### Retraite
- La retraite est possible et doit avoir un coût ou des conséquences clairs, non arbitraires.
- Les ennemis disposent d'attaques de capture ou d'immobilisation.
- Si un allié est immobilisé, les autres peuvent le libérer à l'aide d'un moyen approprié (par exemple bombe fumigène ou objet spécial) et fuir ensemble, **ou** fuir en l'abandonnant.
- En l'absence d'entrave, la fuite est libre selon l'intention exprimée ; le détail de son coût reste à spécifier.
- Le sort exact du héros abandonné (captivité, décès, récupération éventuelle) n'est **pas** automatiquement décidé par l'abandon.

### Butin et équipement à la retraite
- Les survivants conservent ce qu'ils emportent effectivement.
- L'équipement et le butin du héros abandonné restent avec lui dans le donjon, susceptibles de suivre les règles de pillage et de récupération.
- Il n'y a pas de transfert magique des objets d'un héros abandonné vers le refuge.

### Progression entre campagnes après Game Over
- Le bestiaire et les découvertes qui y figurent persistent.
- Les bâtiments du hub déjà débloqués et leurs niveaux d'amélioration persistent **à l'identique**.
- Un coffre du hub conserve d'une campagne à l'autre les objets et l'or qui y ont été déposés.
- La capacité du coffre augmente avec l'évolution du hub.
- Les ressources et objets **non déposés dans le coffre** disparaissent lors du Game Over ; les héros de la campagne perdue ne reviennent pas.
- Les améliorations de bâtiments et les connaissances du bestiaire sont des exceptions explicites à cette perte.

## 3. Tableau de vérification des cas
| Cas | Résultat attendu |
|---|---|
| Retraite sans immobilisation | Survivants et biens effectivement emportés reviennent |
| Retraite avec héros immobilisé, libéré | Groupe peut fuir avec le héros libéré |
| Retraite avec héros immobilisé, abandonné | Survivants fuient ; biens du héros restent avec lui |
| Mort des quatre combattants | Game Over définitif |
| Nouvelle campagne après Game Over | Bestiaire, bâtiments/niveaux, contenu du coffre conservés |
| Or ou objet hors coffre au Game Over | Perdu |
| Équipement porté par les héros au Game Over | Perdu |
| Corps/objets abandonnés avant Game Over | Persistance possible dans le donjon tant que la campagne se poursuit |

## 4. Points ouverts, non décidés
1. Coût exact de la retraite libre : temps, action, risque ou autre.
2. Moyens précis de libération et interactions avec immobilisation, capture et capacités.
3. Sort du héros abandonné vivant : capturé, prisonnier, tué, délivrable ; ne pas assimiler automatiquement à un cadavre.
4. Règles d'accès au coffre, capacité initiale, paliers d'agrandissement, éventuels plafonds pour l'or.
5. Statut des ressources engagées dans les améliorations de bâtiments et du contenu du coffre lors d'un NG+ après victoire.
6. Détails de la génération procédurale, de la réapparition des Némésis et de la réanimation hostile.
7. Équilibrage de la progression permanente pour éviter de neutraliser le risque du Game Over.
8. Audit juridique du mécanisme d'ennemis persistants avant commercialisation.

## 5. Cohérence et priorité
**Cohérence conceptuelle :** la perte des héros reste définitive, tandis que la progression du hub et les biens volontairement mis à l'abri persistent. Le coffre devient une décision stratégique avant chaque expédition.

**Risque majeur :** la conservation du coffre et des bâtiments peut réduire la difficulté des nouvelles campagnes. À mesurer en prototype, sans inventer de chiffres.

**Prochaine priorité :** préciser le sort d'un héros immobilisé abandonné vivant, puis définir le coût exact d'une retraite ordinaire.

## D. Navigation, fiche du héros, HUD et systèmes associés

**Source principale : référence de conception du 16 novembre. « Validé » signifie validé en conception uniquement.**

## Portée et fiabilité
Ce document rassemble les décisions explicitement retenues dans la discussion récente et les décisions antérieures disponibles dans le contexte de continuité. Il ne constitue ni une preuve d'implémentation, ni un audit du dépôt, ni une validation de gameplay. Les détails numériques non arrêtés sont indiqués comme provisoires.

## 1. Principes directeurs
- RPG dungeon crawler dark fantasy exigeant, atmosphère proche de Berserk, exploration 3D isométrique et combats tactiques au tour par tour.
- Quatre héros en expédition, rangs R1 à R4 et ciblage anatomique.
- Difficulté punitive mais non arbitraire ; priorité à la compréhension des conséquences et à la lisibilité.
- Sept piliers narratifs connus : création des personnages ; gore systémique et conséquences corporelles ; philosophie et psychologie ; profondeur humaine accessible ; narration forte ; interconnexion des jeux ; rémanence de la connaissance. Cohérence narrative transversale.

## 2. Menus et visibilité — VALIDÉ EN CONCEPTION
- La visibilité du jeu, des personnages, des décors et des menaces prime sur la taille des menus.
- Barre de navigation horizontale **compacte en haut au centre**, inspirée de No Rest for the Wicked ; abandon de la navigation latérale précédemment proposée.
- Icônes discrètes, noms accessibles au survol ; pas de grands titres persistants. Panneaux contextuels dimensionnés selon le besoin, détails à la demande.
- Menu principal unique : inventaire, héros/groupe, compétences, bestiaire, bibliothèque/manuscrits, carte, options (organisation fine encore adaptable).
- Pendant l'exploration, **le monde continue d'évoluer quand le menu est ouvert** : déplacements, détection et événements.
- Le menu se ferme automatiquement au déclenchement d'un combat ; aucune pénalité artificielle liée à sa consultation ; initiative et surprise suivent les règles normales.
- Le dernier sous-menu consulté est mémorisé. Lorsqu'on sélectionne un autre héros, **le même sous-menu et les mêmes filtres** restent ouverts mais les informations correspondent immédiatement au nouveau héros.
- Les informations collectives, notamment le sac commun, ne changent pas selon le héros sélectionné.
- Éviter les informations périmées lors du changement de héros ; un détail inexistant chez le nouveau héros doit s'effacer.
- Une seule commande ouvre/ferme le menu ; options de taille et d'accessibilité à définir.

## 3. Fiche du héros et anatomie — VALIDÉ EN CONCEPTION
- Dans l'inventaire, montrer **le héros en entier** plutôt que de simples pictogrammes d'arme et de protection.
- La représentation anatomique doit correspondre au héros choisi et, autant que possible, refléter blessures, amputations, protections et prothèses.
- **Survol d'une partie du corps** : informations rapides sur la zone, blessures, protection, afflictions et état connu.
- **Clic** : informations approfondies et, sous réserve de règles à préciser, gestion de l'équipement de la zone.
- Onglet unifié **États et effets** : passifs, buffs et debuffs avec filtres, origine, conséquences et durée si connue. Les passifs secrets non découverts restent invisibles.
- Fiche de caractéristiques : afficher d'abord la valeur effective ; détails de la valeur de base, équipement, blessures et autres effets à la demande. La formule, les caractéristiques définitives et les règles de cumul restent à déterminer.
- Une même blessure doit être explicable depuis l'anatomie et depuis les statistiques modifiées.

## 4. HUD de combat et ciblage — VALIDÉ EN CONCEPTION
- HUD minimaliste ; informations tactiques essentielles visibles sans survol, autres informations au survol, détails au clic.
- Références ergonomiques retenues : **Darkest Dungeon** (sélection des compétences et cibles), **Battle Brothers** (probabilités tactiques), **Darkest Dungeon II** (icônes d'états), **Slay the Spire** (lisibilité des menaces).
- Afficher en permanence les éléments essentiels : combattant actif, points de vie, points d'action, rangs, cibles accessibles, états critiques. Position et densité exactes à concevoir.
- Après sélection d'une compétence, mettre en évidence les cibles et parties du corps accessibles.
- Survol d'une cible/zone : probabilité de toucher, conséquences et informations **connues** ; pas de révélation des secrets ennemis.
- **Clic gauche sur un membre valide avec compétence offensive sélectionnée : exécution directe**, sans confirmation systématique supplémentaire.
- **Clic droit / commande d'inspection** : fiche détaillée, sans attaque et sans dépense de PA.
- Échap annule le ciblage. Des confirmations exceptionnelles pour actes irréversibles restent à définir.
- Menaces ennemies perceptibles lorsqu'elles sont télégraphiées, sans révéler automatiquement toutes les intentions futures.
- Les données ennemies révélées doivent respecter les connaissances du groupe et du bestiaire.

## 5. Compétences, combos et protection — DÉCISIONS ANTÉRIEURES CONSOLIDÉES
- Les compétences de héros respectent les familles d'armes compatibles. Les attaques spéciales conférées par armes épiques/légendaires prennent une place parmi les attaques équipées.
- Le héros peut connaître davantage de compétences qu'il n'en équipe ; cible de **4 à 6 attaques équipées**, plafond exact à déterminer. Changements hors combat, pas pendant.
- Combinaisons d'attaques découvertes par expérimentation et afflictions, invisibles avant découverte, connaissances permanentes et collectives.
- De 1 à 4 participants ; chacun dépense 1 PA lorsqu'il s'engage ; préparation et résolution au cours d'un même round ; initiative ennemie respectée.
- Les participants en préparation sont plus vulnérables, peuvent être interrompus ; PA déjà engagés perdus, PA non engagés conservés. Combinaison réduite possible si ses conditions sont remplies.
- Protection des préparateurs uniquement avec compétence appropriée : interception physique dépendant de la position/mobilité ou protection à distance selon la compétence.
- Interception anatomique : frappe reçue sur la partie correspondante ; bras absent -> torse ; jambe absente -> autre jambe, ou torse si les deux manquent. Blessures et amputations possibles.

## 6. Équipement, forge et inventaire — DÉCISIONS ANTÉRIEURES CONSOLIDÉES
- Pas d'usure progressive ordinaire. Dégradation ou destruction seulement par événements/attaques explicitement prévus et lisibles.
- Équipement ordinaire : intact, endommagé, cassé (réparable), détruit (irrécupérable). Destruction permanente annoncée avec possibilité tactique de réaction.
- Objets uniques/légendaires : **indestructibles**, mais endommageables et affaiblis ; réparation avec composants spéciaux spécifiques.
- Forge au refuge : réparation, amélioration, prothèses, fabrication limitée à partir de plans trouvés. Plans appris définitivement, même si expédition échoue.
- Recyclage **uniquement à la forge du refuge**, rendement fixe et connu ; équipement cassé : aucun rendement ; destruction irréversible.
- Sac commun unique en grille : chaque arme/armure/bouclier occupe une case ; composants empilables avec limites par famille, aucune poche gratuite séparée.
- Capacité initiale **12 cases**, améliorations envisagées **16, 20, 24** via forge, valeurs provisoires ; dernière amélioration exige notamment un composant de boss.
- Tri automatique hors combat, regroupement et consolidation des piles sans perte.
- Sac plein : possibilité de laisser un objet au sol ou de renoncer à la nouvelle trouvaille ; pas de recyclage en donjon.

## E. Registre historique des mécaniques et de la vision (préférences et études)

**ATTENTION :** les sections ci-dessous reproduisent une seule fois les contenus substantiels du registre V2.0, qui consolidait déjà V0.5 à V1.9. Leurs statuts provisoires d’origine demeurent. Les décisions récentes des parties C et D prévalent uniquement lorsqu’elles sont explicites.

## 1. Campagne et narration (V0.5)
**Préférence utilisateur :** première campagne de 10 à 20 heures, forte rejouabilité, Nouvelle Partie+ (NG+). Enquêtes principales et secondaires substantielles, quêtes à conséquences, variations d'expéditions et de trajectoires des héros.
**Hypothèses de travail :** viser environ 15 heures pour étudier le rythme, structure en trois actes, budget de temps réparti entre intrigue, quêtes, préparation et exploration ; chiffres purement illustratifs. Production par tranche verticale avant extension. Les quêtes secondaires peuvent influer sur les informations, les alliances et certains dénouements. Ne pas rendre une information indispensable définitivement inaccessible à cause de la mort d'un héros.
**Risques :** campagne trop courte pour les ramifications, gonflement du nombre de scènes, répétition procédurale, NG+ limité à une hausse de statistiques.

## 2. NG+ hybride (V0.6)
**Préférence utilisateur :** NG+ hybride, avec continuité possible de certains survivants et renouvellement de l'équipe (modalités non tranchées). Recrutement des ennemis ordinaires dès la première campagne ; recrutement des ennemis ET des boss en NG+.
**Hypothèses :** boss recrutés avec compétences adaptées au rôle d'allié, pas de copie brute de statistiques de boss ; conditions spéciales possibles liées à l'enquête ; mort permanente également pour les recrues ; traitement des blessures selon l'anatomie. Limiter les exemplaires uniques si nécessaire.
**Risques :** déséquilibre, incohérences narratives, complexité des animations/compétences, multiplication des unités jouables.

## 3. Recrutement hybride (V0.7)
**Préférence utilisateur :** combiner capture tactique en combat et recrutement narratif selon les circonstances.
**Hypothèses :** certaines recrues obtenues par dialogue, enquête, décision ou mission ; conditions spéciales pour les boss en NG+ ; un mécanisme d'intégration commun plutôt que des systèmes concurrents.
**Risques :** capture systématique, échec opaque et frustrant, incohérences de motivations, charge de production excessive.

## 4. Capture distincte du recrutement (V0.8)
**Préférence utilisateur :** modèle B : capture puis recrutement, distincts. La capture ou le recrutement dépend de plusieurs éléments, notamment de la vie (PV) de l'ennemi.
**Hypothèses :** tentative en combat ; captif à ramener après mission ; soins/évaluation avant intégration ; refus ou échec possibles. Loyauté simplifiée en trois états proposés (méfiant, coopératif, loyal), NON VALIDÉS. Capacité de transport et de détention limitée, NON VALIDÉE.
**Risques :** gestion trop lourde, prisonniers perdus lors d'une défaite, mort accidentelle de la cible, capture sans motivation crédible pour rejoindre l'équipe.

## 5. Facteurs de capture (V0.9)
**Sélection explicite de l'utilisateur :** (1) points de vie ; (2) états de combat ; (3) nature de l'ennemi ; (4) équipement de capture ; (5) moral et volonté.
**Modèle théorique étudié :** vérifier d'abord éligibilité et compatibilité de l'équipement ; puis calculer une chance illustrative P = clamp(B + V + E + M - R, 5 %, 90 %), avec B équipement, V bonus PV, E états, M moral, R résistance de la cible. Formule, seuils et coefficients : EXEMPLES NON VALIDÉS, pas d'équilibrage. La nature et l'équipement peuvent déterminer la possibilité même de capture ; les autres facteurs modulent les chances.
**Cas limites à tester :** 100 % PV, 1 PV, 0 PV/mort, étourdissement, immobilisation, cumul d'états, immunité, équipement incompatible, moral brisé et reddition, boss hors NG+, boss en NG+, échec d'extraction, capacité saturée, tentatives répétées et accumulation excessive de bonus.
**Risques :** farming par essais répétés, formule opaque, frustration aléatoire, capture trop facile à faible PV, attaques létales involontaires.

## 9. V1.0 — Apprentissage des méthodes de capture
**Préférences utilisateur provisoires :** neutralisation non létale = oui ; après capture ratée, résistance temporaire accrue ; afficher la probabilité exacte de capture. Les méthodes sont apprises dans les livres, par les dialogues et à force de combattre la même espèce.
**Étude :** bestiaire centralisé, apprentissage progressif, distinction entre informations découvertes et conditions réelles de capture. L'affichage exact ne doit pas annoncer un taux trompeur. Échecs répétés : plafonnement et durée des résistances à tester.
**Non tranché :** seuils, durée du malus, effets de neutralisation, accès aux informations erronées ou partielles, rythme d'apprentissage.

## 10. V1.1 — Connaissances collectives et expérience individuelle
**Préférence utilisateur provisoire :** modèle hybride C. Le bestiaire collectif conserve les découvertes ; chaque héros acquiert sa propre maîtrise.
**Étude :** la mort permanente efface l'expérience personnelle mais pas nécessairement les informations du bestiaire. En NG+, conservation envisagée des connaissances collectives et, sous conditions, de la maîtrise des survivants. Éviter une compétence distincte par espèce ; favoriser quelques compétences transversales.
**Non tranché :** lieu de conservation du bestiaire après défaite totale ; règles exactes de transmission et de NG+.

## 11. V1.2 — Spécialistes de capture et groupes d'exploration
**Préférences utilisateur provisoires :** maîtrise individuelle C = bonus modéré et techniques spécialisées ; créer une classe de personnage et des ennemis dotés d'aptitudes favorables à la capture ; permettre plusieurs groupes d'exploration.
**Étude :** complémentarité héros/créatures recrutées, techniques de contention, contrôle, neutralisation et extraction. Éviter une classe obligatoire et des bonus sans coût tactique.
**Non tranché :** noms et nombre de classes, arbres de compétences, coefficients, éventuelles missions simultanées.

## 12. V1.3 — Plusieurs formations, une seule expédition active
**Préférence utilisateur provisoire :** plusieurs formations préparées au refuge, une seule expédition active. Formations adaptées aux objectifs de farm, capture ou loot.
**Étude :** réserve commune, formations enregistrées par identifiants de personnages, inventaire partagé, prévention des duplications. Les morts, blessures et indisponibilités doivent se répercuter dans toutes les formations. Le farm ne devrait pas être obligatoire pour terminer une campagne de 10 à 20 h.
**Non tranché :** capacité du refuge, économie, fatigue, récupération, nombre de formations, modalités d'extraction.

## 13. V1.4 — Quatre combattants et quatre rangs
**Préférence utilisateur provisoire :** départ en expédition avec exactement quatre combattants, pas trois, compte tenu de la difficulté recherchée. Une équipe peut perdre des membres pendant l'expédition.
**Étude :** rôles complémentaires non obligatoires ; créatures recrutées occupant en principe l'une des quatre places ; quatre rangs R1 avant à R4 arrière. Les boss recrutés en NG+ devraient avoir une version jouable équilibrée.
**Non tranché :** initiative, retraite, encombrement des créatures gigantesques, règles d'invocation.

## 14. V1.5 — Resserrement automatique des rangs
**Préférence utilisateur provisoire :** modèle B, resserrement automatique.
**Étude :** après retrait définitif d'un combattant, compacter les survivants vers R1 en préservant leur ordre relatif, pour les deux camps. L'étourdissement ou l'immobilisation ne retire pas la position. Les morts multiples doivent être résolues avant un resserrement unique. Les compétences doivent cibler des identifiants stables, puis revérifier leur portée au moment de l'exécution. Le resserrement peut être une abstraction tactique, y compris pour un combattant immobilisé.
**Non tranché :** déplacements forcés, réapparition éventuelle, unités multirangs, effets de capture et extraction sur la présence en combat.

## 15. V1.6 — Déplacement volontaire coûteux et mobilité spéciale
**Préférence utilisateur provisoire :** modèle C, déplacement ordinaire coûteux et compétences de mobilité particulières.
**Étude :** déplacement normal envisagé comme échange avec un allié adjacent consommant une action principale ; resserrement automatique gratuit ; techniques spéciales de mobilité personnelle, collective ou de manipulation des positions ennemies. Les techniques doivent avoir des contreparties. Les blessures, amputations, prothèses et immobilisations peuvent restreindre la mobilité volontaire, sans bloquer le resserrement abstrait.
**Non tranché :** choix entre mobilité personnelle, collective ou mixte ; coûts exacts, cooldowns, déplacements forcés, exceptions des créatures, rythme des combats.

## 16. Risques transversaux et critères de vérification
- **Équilibrage :** ni capture automatique, ni classe indispensable, ni mobilité gratuite dominante, ni farm obligatoire.
- **Mort permanente :** disparition des unités des formations enregistrées ; expérience individuelle perdue ; bestiaire collectif conservé selon règles à préciser.
- **Rangs :** vérifier décès en R1/R2/R3/R4, morts multiples, capture, permutation, immobilisation, amputation, unités imposantes, déplacement forcé.
- **Ciblage :** identifiants d'unité stables, portée recalculée après déplacements, résolution déterministe.
- **Sauvegarde :** restauration fidèle des formations, équipements, captifs, rangs et connaissances ; aucune duplication.
- **Tests :** tests unitaires et intégration Godot, puis contrôle visuel et playtest ; une CI verte ne prouve pas la qualité en jeu.
- **Production :** commencer par une équipe de quatre, une espèce capturable, une recrue, deux formations, un déplacement ordinaire et quelques mobilités spéciales. Ne pas multiplier les systèmes avant validation.

## 18. V1.7 — Mobilité personnelle, collective et contrôle ennemi
**Préférence utilisateur provisoire :** modèle C : mobilité personnelle, mobilité collective et contrôle de l'ennemi. Étudier les interactions avec membres, afflictions, capture, classes et coût de production.
**Étude :** un moteur de positions partagé ; mouvement volontaire avec coût, compression automatique après retrait ; compétences de poussée, attraction, permutation, protection et repositionnement. Éviter les blocages infinis. Règles de collisions non validées.

## 19. V1.8 — Poussées et collisions
**Préférences exprimées :** système hybride servant la tactique ; la corpulence de la créature ou du héros poussé doit intervenir ; les dégâts doivent être proportionnels à l'impact ; le déséquilibre réduit les capacités mais ne retire pas l'action.
**Hypothèses proposées, non validées :** poussée simple = réorganisation possible des rangs ; compétences spécifiques = collision ; impact contre limite R4 sans sortie du combat ; catégories de corpulence légère/moyenne/lourde/massive ; puissance, protections et résistance influencent les dégâts ; impacts légers/modérés/violents ; étourdissement exceptionnel et non renouvelable à l'infini ; blessures localisées, fractures possibles, amputations exceptionnelles. Aucun coefficient, formule ni seuil validé.
**Risques :** cumul de dégâts, collision en chaîne, contrôle excessif, incohérences anatomiques, surcharge d'interface.

## 20. V1.9 — Retour à la vision générale
**Décision de méthode exprimée :** définir d'abord les grandes lignes du jeu avant d'approfondir les collisions et les mécaniques. Les études détaillées restent des pistes, pas des règles validées.
**Préférence utilisateur provisoire explicite :** C, équilibre entre stratégie, exploration et narration. Étudier la promesse joueur et les piliers avant validation.
**Promesse joueur proposée (non validée) :** dans un univers de dark fantasy dangereux et mystérieux, diriger un groupe, explorer, prendre des décisions aux conséquences durables, survivre par la stratégie et découvrir l'univers.
**Quatre piliers proposés (non validés) :** 1. Combat tactique et préparation ; 2. Exploration et découverte ; 3. Narration et choix significatifs ; 4. Conséquences persistantes. Le quatrième relie les trois premiers.
**Interaction exemplaire :** une découverte en expédition ouvre un dialogue, qui peut conduire à un recrutement, lequel modifie les options tactiques. Exemple conceptuel, non implémenté.
**Questions ouvertes :** place relative des trois dimensions, boucle de jeu, rythme, cible joueur, plateformes, limites de contenu, périmètre première version, validation des piliers.

## 23. Cadre général et identité (orientations provisoires)
- LITD 1 : RPG tactique, dungeon crawler dark fantasy à inspiration roguelike, destiné d'abord au PC et à des joueurs appréciant les défis exigeants mais lisibles.
- Compagnie comme protagoniste collectif ; exploration et combat sont deux sources de plaisir autonomes et importantes ; la narration relie les conséquences de leurs interactions.
- Exploration semi-ouverte, lieux conçus avec variations procédurales ; refuge évolutif mais sans simulation de gestion lourde ; première campagne indicative de 10 à 20 heures, rejouabilité et NG+ à étudier.
- Catastrophes parfois radicales, transformation durable de la trajectoire, reconstruction difficile mais généralement possible, sans effacer les pertes irréversibles. L'éventuelle défaite définitive de campagne reste non tranchée.
- Les situations d'expédition, les combats et les histoires ne doivent pas dépendre uniquement d'événements narratifs écrits. Éviter la multiplication incontrôlée de branches.

## 24. Quatre héros initiaux, recrues et mémoire collective
- Quatre héros de départ : parcours personnels et origines géographiques, culturelles/ethniques et sociales approfondis. Leur mort définitive peut interrompre leurs histoires individuelles ; elle n'efface pas les actes déjà accomplis.
- Recrues ordinaires et ennemis recrutés : personnages remplaçables, sans obligation d'un arc écrit complet pour chacun ; une recrue ordinaire peut toutefois acquérir une renommée exceptionnelle par ses actes.
- Distinction proposée : mémoire des faits, réputation selon les témoins et communautés, héritage des conséquences. Les actes, sacrifices, fautes et faits d'armes peuvent être interprétés différemment après la mort.
- Trois échelles proposées : mémoire de la compagnie, mémoire des communautés, mémoire historique exceptionnelle. Éviter les stéréotypes fondés sur les origines et la célébrité systématique de chaque mort.
- La répercussion dans le monde peut être narrative ou réellement transformatrice ; fréquence et portée non définies. Le temps nécessaire à l'évolution des légendes reste une contrainte de cohérence.

## 25. Réussite, échec, renoncement et expéditions rejouables
- Préférence explicite : réussite d'une expédition dépendant des circonstances et des décisions, et pas seulement de la victoire au combat. Distinguer accomplissement de l'objectif, survie, gains, pertes et conséquences.
- Une mission peut être abandonnée puis recommencée, comme dans Darkest Dungeon. Ne pas confondre mission rejouable et annulation des pertes.
- Distinction analytique proposée : victoire complète, victoire coûteuse, échec avec gain significatif, défaite majeure ; catégories non validées comme interface ou règles.
- La retraite doit être possible dans le cadre des missions rejouables ; ses modalités, coûts et éventuelles exceptions ne sont pas définis.

## 26. Persistance entre expéditions : précisions utilisateur
- La disposition du même donjon change lors des nouvelles expéditions.
- Les blessures des survivants, les objets trouvés et l'expérience acquise sont conservés. Point non résolu : les objets sont-ils conservés immédiatement ou seulement lorsqu'ils sont effectivement rapportés ? Ne pas imposer la seconde interprétation sans arbitrage.
- Les morts des héros sont définitives. La compagnie et certains événements du donjon persistent malgré la recomposition spatiale.
- La disposition renouvelée et la mémoire des événements doivent coexister ; ne pas exiger le retour d'un corps dans une salle géométriquement identique.

## 27. Ennemis persistants et rivalités de type Némésis
- Préférence explicite : un ennemi qui tue un héros peut être retrouvé dans le même donjon lors d'une expédition suivante, plus fort.
- Les rencontres répétées et la mémoire de la compagnie peuvent créer des rivalités émergentes, sans quête écrite obligatoire.
- Hypothèses non validées : évolution de capacités, équipement ou statut ; possibilité de plusieurs retours ; conditions de sélection des ennemis persistants ; limites de puissance ; possibilité de recruter un ancien adversaire meurtrier.
- Vigilance : risque de multiplication des Némésis, équilibrage, lisibilité et vérification juridique des brevets associés à certains systèmes commerciaux. Aucun avis juridique ou examen de revendications de brevets effectué ici.

## 28. Corps abandonnés, équipement et réanimation hostile
- Préférence explicite : les corps des héros laissés sur le champ de bataille peuvent être retrouvés lors d'expéditions suivantes pour récupérer leur équipement.
- Variantes exprimées : (1) corps retrouvé et équipement récupérable ; (2) corps pillé par des ennemis du donjon, équipement retrouvé sur ces ennemis ; (3) corps disparu ; (4) corps ressuscité/réanimé et devenu adversaire que la compagnie peut combattre.
- La réanimation hostile ne doit pas être assimilée sans décision explicite au retour du héros jouable ; principe de mort définitive à préserver, modalités surnaturelles à définir.
- Un ennemi Némésis peut potentiellement porter l'équipement du héros tué ; la circulation des objets et leur histoire propre sont des pistes, pas un système validé.
- Questions ouvertes : persistance et durée des corps, devenir des objets si plusieurs ennemis les portent successivement, fréquence des réanimations, conditions de récupération, effet des donjons recomposés, objets perdus à l'abandon, prévention du farming et des duplications.

## 29. Cohérence, limites et risques de périmètre
- Conserver une exploration intéressante sans combat et un combat intéressant sans événement narratif exceptionnel.
- Les conséquences doivent être significatives, mais les pertes ne doivent pas toujours devenir catastrophiques ; les échecs ne doivent pas être automatiquement requalifiés en réussites.
- Priorité à un modèle conceptuel unifié de persistance : personnages, compagnie, donjon, ennemis, corps, équipements, expérience et blessures ; ne pas créer de systèmes parallèles sans nécessité.
- Éviter les explosions combinatoires : héros initiaux narrativement profonds, recrues plus légères, Némésis et résurrections hostiles non nécessairement systématiques.
- Les études antérieures V0.5–V1.9 sur capture, recrutement, quatre rangs, déplacements et collisions restent archivées comme préférences/hypothèses provisoires, sans revenir aux détails techniques avant consolidation de la vision.

## F. Méthode de création de LITD 1

Le texte ci-dessous est la méthode spécifique LITD 1 issue du PDF du 12 novembre, conservée une seule fois ; elle fixe les jalons et preuves de passage.

LITD 1 - Parcours de création et règles de
 travail
 Référence de projet | version 1.0 | 12 novembre 2026

 Portée. Ce document complète la Méthode de travail permanente - règles consolidées du 11 novembre
 2026, applicable à tous les projets. Il fixe un parcours et des règles propres à LITD 1. En cas de doute, vérifier
 les décisions récentes et les preuves de la version concernée ; ce texte ne valide aucun ancien contenu
 artistique, narratif ou gameplay par lui-même.

 Point de départ. La reconstruction de LITD 1 est un nouveau chantier. Les idées, les références conservées
 et les services techniques réutilisables doivent être inventoriés et réconciliés avant de les intégrer. Le code
 existant et une CI réussie ne suffisent pas à valider le résultat joué.


 1. Parcours adapté à LITD 1
 Les étapes ci-dessous sont des jalons de décision, non une chaîne automatique. Une preuve défavorable peut ramener à
 une étape antérieure. Les critères sont proposés pour notre projet, à partir de pratiques décrites par Ubisoft et de guides de
 test et d’accessibilité [S1-S4].

 01 | Vision
 Formuler l’expérience recherchée, le public et les plateformes cibles ; choisir quelques piliers de jeu.

 Preuve de passage : Note courte arbitrable : promesse joueur, piliers, limites de périmètre.

 02 | Préproduction
 Réconcilier décisions et références ; identifier les risques, dépendances et coûts de production.

 Preuve de passage : Inventaire sourcé et registre des questions ouvertes ; premier ordre des prototypes.

 03 | Prototypes
 Tester une question risquée à la fois dans une petite scène : combat, ciblage, lisibilité ou boucle de progression.
 Preuve de passage : Version jouable, observations et décision conserver / modifier / abandonner.

 04 | Tranche verticale
 Assembler une boucle courte représentative : jeu, interface, art, audio, sauvegarde et chaîne de fabrication.

 Preuve de passage : Parcours intégral essayé sur la cible ; qualité et coût de fabrication mesurés.

 05 | Production
 Créer le contenu à l’échelle avec les procédés éprouvés, sans empiler de nouveaux systèmes fragiles.
 Preuve de passage : Contenu intégré, revue de qualité et rythme de production tenable.

 06 | Alpha puis bêta
 Alpha : parcours et systèmes prévus accessibles. Bêta : stabilité, ergonomie, équilibre, performances et correction.
 Preuve de passage : Tests de régression, essais joueurs, problèmes restants classés et résolus selon leur gravité.

 07 | Sortie et suivi
 Préparer les builds cibles, les droits, les informations de distribution, la migration des sauvegardes et les correctifs.

 Preuve de passage : Build et dossier de sortie contrôlés ; suivi des incidents et mises à jour prêt.


 Application immédiate
 Commencer par une vision courte et l’inventaire des décisions réellement conservées, puis cibler le prototype
 de combat de base. La PR de prototype éventuellement ouverte reste une proposition à examiner, pas une
 tranche verticale ni une validation de l’expérience joueur.




LITD 1 | Référence de méthode | v1.0                                                                                              1
 2. Règles LITD 1 complémentaires
 Ces règles s’ajoutent à la méthode permanente. Les huit premières reprennent le socle proposé pour la reconstruction ; les
 règles 9 à 18 précisent le parcours de création étudié. Chaque contrôle doit être lié à une version identifiable.

 1. Une question par prototype
 Énoncer la question, l’hypothèse et le résultat attendu. Limiter la scène et décider après l’essai.

 2. Références identifiées
 Séparer les décisions validées, les archives historiques, les hypothèses et les idées nouvelles. Ne rien réintroduire par
 simple ancienneté.

 3. Périmètre avant code
 Écrire le comportement et les cas limites avant de l’implémenter ; décider explicitement ce qui est hors champ du
 prototype.

 4. Validation à plusieurs niveaux
 Contrôler la conformité à la conception, la technique, le rendu réel dans Godot et l’expérience de joueur lorsque nécessaire.
 Une CI verte ne couvre pas ces niveaux à elle seule.

 5. Décision après essai
 Documenter ce qui est observé ; conserver, modifier ou retirer la mécanique selon des critères annoncés.

 6. Art et lore préservés
 Protéger les originaux approuvés, leur provenance et leur intégrité. Une nouvelle image ou histoire requiert une validation
 distincte.

 7. Changements isolés
 Un objectif compréhensible par PR, contrôles de branche et retour arrière possible. Vérifier les dépendances avant
 suppression.

 8. Avancement prouvé
 Mesurer le progrès par livrables terminés et vérifiés. Signaler séparément ce qui reste à tester et ce qui dépend d’une
 décision.



 9. Vision qui arbitre
 Maintenir la promesse joueur, la cible, les plateformes et les piliers dans une page de référence. Différer les idées qui ne
 servent pas cette vision.

 10. Risques prioritaires
 Tenir un registre des inconnues de gameplay, interface, art et production. Choisir le prochain essai par le risque qu’il peut
 réduire.

 11. Prototype et tranche distincts
 Un prototype peut employer des éléments temporaires pour une seule question. La tranche démontre une boucle
 représentative et un procédé répétable ; elle précède la production massive.

 12. Coût de contenu mesuré
 Chronométrer création, intégration et contrôle d’un héros, ennemi, salle et compétence représentatifs avant de multiplier
 les variantes.

 13. Tests continus sur cible
 Tester les règles usuelles et limites, sauvegarde et chargement, interface, performance et appareil visé. Noter séparément
 automatisation et essai humain.

 14. Observation de joueurs
 Préparer une question par séance, identifier le build, laisser jouer sans guidage et relever actions, erreurs et propos.
 Recruter autant que possible des joueurs de la cible.




LITD 1 | Référence de méthode | v1.0                                                                                             2
 15. Accessibilité précoce
 Dès les premières interfaces, contrôler taille et espacement des commandes, lisibilité du texte, contraste et informations
 essentielles transmises par plus que la seule couleur ou le seul son. Essayer le tactile sur appareil si retenu.

 16. Scènes Godot autonomes
 Limiter les dépendances implicites aux anciennes scènes ; expliciter les données fournies par le contexte parent. Réutiliser
 les services techniques conservés lorsqu’ils conviennent.

 17. Passages documentés
 Pour chaque jalon, garder version, preuves, problèmes ouverts et décision de périmètre. Une date ou un intitulé de phase
 ne vaut pas validation.

 18. Sortie préparée
 Avant une publication : vérifier droits et licences, builds et appareils annoncés, informations exactes de boutique,
 sauvegardes et migration, plan de correctifs. Si Steam est retenu, suivre son examen de page et de build [S5].


 3. Contrôle d’un jalon
 À chaque passage : (1) nommer le livrable et son commit ou build ; (2) joindre les résultats techniques et les
 observations en jeu ; (3) relever les écarts ; (4) décider du passage, du retour en prototype ou du report ; (5)
 mettre à jour les deux indicateurs d’avancement sans pourcentage inventé.


 Sources consultées
 Les sources décrivent des pratiques générales ; le découpage et les critères propres à LITD 1 sont des propositions de méthode,
 non des obligations de ces organismes.

 [S1] Ubisoft, « Comment nous créons nos jeux »
 https://www.ubisoft.com/fr-fr/company/how-we-make-games/creative-process

 [S2] Unity, « Testing and quality assurance tips »
 https://unity.com/how-to/testing-and-quality-assurance-tips-unity-projects

 [S3] Godot, « Scene organization »
 https://docs.godotengine.org/en/stable/tutorials/best_practices/scene_organization.html

 [S4] Game Accessibility Guidelines, « Basic »
 https://gameaccessibilityguidelines.com/basic/

 [S5] Steamworks, « Review Process »
 https://partner.steamgames.com/doc/store/review_process

 Consultation : 12 novembre 2026. Référence interne complémentaire : « Méthode de travail permanente - règles consolidées »,
 version du 11 novembre 2026.




LITD 1 | Référence de méthode | v1.0                                                                                               3

## G. Méthode permanente de travail

Règles transversales reprises du fichier du 11 novembre ; elles restent applicables à la conception.

# Méthode de travail permanente — règles consolidées

Version du 11 novembre 2026. Référence commune à toutes les conversations et à tous les projets d’Aurélien Fabre, notamment Henolos et LITD.

Applique ces règles sans que j’aie à te les rappeler.

## 1. Respect des consignes et des décisions

Avant d’agir, prends en compte mes instructions, les décisions validées, les références approuvées et l’état réel du chantier. Ne remplace pas une décision ou une référence par une invention. Signale les contradictions importantes et résous-les avant l’action concernée.

Si une règle ne peut pas être appliquée, explique précisément la limite rencontrée. Ne prétends jamais l’avoir respectée sans l’avoir fait.

## 2. Continuité entre les conversations

Réutilise les informations, autorisations et résultats déjà disponibles. Avant de me redemander un document ou une information, recherche-les dans les sources accessibles.

Vérifie l’état actuel des fichiers, dépôts et services lorsque cela conditionne la suite. Une ancienne déclaration de réussite ne constitue pas une preuve de leur état présent.

Ne réinitialise pas arbitrairement le suivi. Ne prétends pas travailler en arrière-plan ou avoir mémorisé durablement une information sans confirmation réelle.

## 3. Recherche Internet adaptée à la demande

Avant une recommandation technique, professionnelle, commerciale, de sécurité, de gouvernance ou d’outillage, effectue une recherche Internet actuelle et pertinente.

Privilégie les sources primaires et officielles. Confronte plusieurs sources lorsque l’enjeu le justifie ; recherche les contradictions et les hypothèses alternatives. Ne te limite pas à GitHub ou aux documents d’un éditeur : examine aussi les sources indépendantes, retours d’expérience et forums publics autorisés lorsque c’est utile.

Évite les recherches inutiles pour les échanges simples et les tâches purement rédactionnelles.

## 4. Analyse fondée sur les preuves

Distingue clairement :

- Les faits vérifiés.
- Les déductions et leur justification.
- Les hypothèses.
- Les éléments non vérifiés ou incertains.

Compare les solutions pertinentes selon leurs avantages, inconvénients, coûts, risques et limites dans mon contexte. Fournis les sources utiles. Ne présente jamais une affirmation comme vérifiée sans contrôle réel.

## 5. Exécution jusqu’au résultat ou au blocage réel

Lorsque je dis « go », « continue » ou « la suite », reprends le chantier et avance dans le périmètre autorisé.

Ne t’arrête pas à un plan ou à une promesse lorsque tu peux exécuter le travail. Poursuis jusqu’au résultat vérifié ou à un blocage réel. Ne redemande pas une autorisation déjà donnée pour la même action et le même périmètre.

Si mon intervention est indispensable, indique l’obstacle exact, les tentatives effectuées et l’action minimale attendue. Continue les travaux indépendants du blocage lorsque c’est possible.

## 6. Distinction entre réalisation et validation

Distingue systématiquement ce qui est planifié, en cours, réalisé, testé et validé.

Une installation ne prouve pas l’efficacité du système. Un test partiel ne valide pas l’ensemble. Une CI réussie ne remplace pas un contrôle visuel ou un essai réel lorsque ceux-ci sont nécessaires.

Ne prétends jamais avoir exécuté un test, consulté une source, transféré un fichier ou modifié un service sans l’avoir effectivement fait.

## 7. Préservation des planches et références validées

Toute planche ou image que j’ai validée constitue une référence à préserver. Ne la recrée pas, ne la remplace pas par une image ressemblante et ne présente jamais une génération comme l’original validé.

Conserve son identité, sa provenance, sa version et la trace de ma validation lorsqu’elle est disponible. Si cette trace manque, signale-le sans inventer une validation.

Distingue ces étapes :

- Référence identifiée.
- Original retrouvé.
- Fichier accessible.
- Transfert effectué.
- Intégrité vérifiée.
- Import réalisé.
- Affichage en jeu contrôlé.

La réussite d’une étape ne prouve pas celle des suivantes. Une archive retrouvée n’est pas une archive transférée ; un fichier importé n’est pas un affichage validé.

Lors des transferts, compare les empreintes SHA-256 des sources et destinations lorsque possible. Complète le contrôle d’intégrité par une vérification visuelle de la correspondance avec les références validées.

Si un original est inaccessible ou qu’un transfert échoue, recherche une solution de récupération, préserve l’existant et précise le blocage. Ne compense jamais l’absence du fichier par une invention.

Préserve les originaux. Identifie séparément les versions dérivées et leur source. Avant toute suppression, vérifie les dépendances, l’absence d’usage et la conservation de la référence nécessaire.

## 8. Architecture, rangement et conservation

Réutilise les dépôts, bibliothèques et architectures existants. Évite les systèmes parallèles et les doublons.

Les bibliothèques constituent notre laboratoire : range les analyses, références et preuves pour permettre leur consultation et la reprise du travail. Respecte les emplacements convenus et vérifie que les livrables ont réellement été enregistrés.

## 9. Sécurité et séparation des données

Les données clients ne nous appartiennent pas. Respecte leur séparation stricte entre clients et avec les projets internes, notamment LITD. Ne les réutilise pas sans base légale et autorisation appropriées.

Applique le chiffrement prévu dès l’entrée, pendant le transport et au repos, y compris pour les sauvegardes, exports et fichiers temporaires. Vérifie les mesures effectives avant de les déclarer opérationnelles. Ne divulgue pas de secrets dans les réponses, journaux ou preuves.

## 10. Tests, corrections et preuves

Adapte les contrôles à l’importance du changement. Corrige les échecs et examine les avertissements pertinents avant de conclure.

Conserve les preuves utiles : résultats de tests, journaux, rapports, captures, empreintes et références de commits. Relie les validations à la version réellement contrôlée.

Pour les dépôts, respecte les protections convenues et vérifie les contrôles requis avant une fusion. Pour les interfaces et les jeux, réalise les contrôles visuels nécessaires sans les déduire des seuls tests automatisés.

## 11. Suivi obligatoire de l’avancement

À chaque bilan significatif concernant un projet, précise :

- Le nom du chantier et son statut.
- Avancement du chantier actuel : XX %.
- Avancement du projet global : XX %.
- Les actions terminées et vérifiées.
- Les actions restantes.
- La prochaine étape prioritaire.

Calcule les pourcentages à partir d’étapes terminées et vérifiées. Identifie explicitement toute estimation. Si les informations sont insuffisantes, indique « À évaluer ».

Réutilise les derniers états fiables. N’annonce jamais 100 % tant que toutes les étapes et validations nécessaires ne sont pas achevées.

## 12. Statuts communs

- 🟢 TERMINÉ / VALIDÉ : travail achevé et vérifié.
- 🔵 AUTOMATISÉ : processus automatisé et opérationnel.
- 🟣 EN ATTENTE : décision, validation ou intervention attendue.
- 🟠 EN COURS / BLOQUÉ : travail en cours ou obstacle précisément identifié.
- 🟡 À CONSOLIDER : fonctionnement partiel nécessitant des vérifications, à nommer explicitement.
- ⚪ NON COMMENCÉ : chantier volontairement non ouvert.
- 🟤 CLOS : réalisation, validations et preuves achevées, sans suivi restant.

## 13. Communication et autocontrôle

Communique clairement, avec des détails proportionnés à la demande. Pendant les travaux longs, donne des nouvelles utiles sur les résultats, les incertitudes et les obstacles.

Avant de conclure, contrôle la cohérence entre tes affirmations, les preuves recueillies et les actions réellement effectuées. Corrige les contradictions identifiées.

Ne présente jamais une intention comme une réalisation, un résultat partiel comme une validation complète ou un chantier incomplet comme terminé.

## H. Registre unique des contradictions, révisions et décisions ouvertes

| ID | Sujet | Constat de réconciliation | Statut / suite |
|---|---|---|---|
| ARB-01 | Game Over | V2.0 envisageait plusieurs issues et persistances ; V2.1 tranche explicitement la mort des quatre engagés = Game Over, même avec recrues au refuge. | **Décision récente prioritaire**, sans test |
| ARB-02 | Retraite | V2.1 confirme retraite possible, sauvetage ou abandon d’un immobilisé ; le coût exact reste ouvert. | **À arbitrer** : coût et risque |
| ARB-03 | Héros abandonné | Les textes anciens évoquent corps, pertes et récupération ; V2.1 interdit d’assimiler automatiquement l’abandon à la mort. | **À arbitrer** : captivité, décès, récupération |
| ARB-04 | Persistance | V2.1 fixe bestiaire, bâtiments et niveaux, contenu effectivement déposé au coffre entre campagnes ; le reste perdu au Game Over. | **Validé en conception** ; NG+ après victoire à préciser |
| ARB-05 | Quatre héros et rangs | V1.4–V1.6 qualifient les règles de préférences provisoires ; référence récente réaffirme quatre héros, R1–R4. | **Principe confirmé** ; coûts de mobilité et exceptions ouverts |
| ARB-06 | Capture | V0.5–V1.9 propose capture, recrutement, pourcentage exact et apprentissage ; aucune formule chiffrée approuvée. | **Préférence provisoire** ; test et arbitrage |
| ARB-07 | Navigation | Ancienne option de menu latéral écartée ; barre compacte horizontale centrée en haut retenue. | **Validé en conception** |
| ARB-08 | HUD | Clic direct sur membre valide, inspection gratuite, informations connues et HUD discret ; dimensions et commandes non figées. | **Validé sur le principe**, détails à concevoir |
| ARB-09 | Inventaire | Sac commun de 12 cases et extensions 16/20/24 envisagées ; piles et coût d’agrandissement non équilibrés. | **Paramètres provisoires** |
| ARB-10 | Combos et interception | Principes documentés ; coûts exacts, interruption, afflictions transmises, prothèses et collisions demandent spécification de cas limites. | **À consolider** |
| ARB-11 | Forge | Pas d’usure ordinaire ; objets légendaires indestructibles mais endommageables ; détails de coût de réparation et rendements à tester. | **À consolider** |
| ARB-12 | Ennemis persistants | Némésis, corps réanimés, récupération et reconfiguration du donjon encore spéculatifs. | **Hypothèses**, faisabilité et droits à examiner |
| ARB-13 | Boucle et périmètre | Boucle synthétisée pour travailler, pas encore éprouvée ; tranche verticale non délimitée. | **À arbitrer**, prioritaire après réconciliation |
| ARB-14 | Tests / moteur | Aucun test Godot, essai joueur ou audit de dépôt dans ce travail. | **Non testé** |

## I. Décisions restant à prendre : ordre de travail

1. Définir les conséquences d’un héros immobilisé abandonné vivant et les conditions de récupération.
2. Fixer les règles et coûts d’une retraite ordinaire.
3. Définir les limites de persistance des corps, objets et ennemis lors de la régénération des donjons.
4. Délimiter la boucle jouable minimale et les critères de succès d’un prototype.
5. Finaliser la disposition du HUD sans masquer le terrain, avec critères d’accessibilité et de lisibilité.
6. Arbitrer les cas limites des rangs, captures, déplacements, combos et interceptions.
7. Équilibrer ultérieurement capacités du sac, forge, coûts, probabilités et progression persistante.
8. Vérifier les contraintes juridiques et artistiques avant exploitation commerciale.

## J. Traçabilité de la fusion et contrôles

**Sources inspectées (8)** : méthode permanente (11/11), parcours LITD 1 (12/11), registres V0.5–V0.9, V0.5–V1.6, V0.5–V1.9, registre consolidé V2.0, fiche de vision V2.1, référence de conception du 16/11.

**Déduplication :** les versions V0.5–V1.9 étant déjà incluses dans V2.0, seul V2.0 fournit les chapitres historiques. Les anciennes sections de suivi obsolètes et anciennes listes de tâches ont été remplacées par les parties H à K. Les décisions V2.1 et UI figurent chacune une seule fois comme chapitres actifs.

**Limite :** cette fusion est une réconciliation documentaire par priorité explicite, pas une vérification mot à mot de chaque échange oral ni de tous les documents éventuellement conservés ailleurs. Aucun test en jeu n’a été réalisé.

## K. Suivi

- **Chantier :** réconciliation du document maître de conception LITD 1.
- **Statut :** 🟡 À CONSOLIDER, car les arbitrages ouverts restent à décider.
- **Réalisé :** document maître unique, déduplication des sources successives, séparation des décisions récentes et des études provisoires, registre des contradictions.
- **Vérification :** contrôle de présence des sections sélectionnées et contrôle structurel du fichier.
- **Non réalisé :** validation du gameplay, audit GitHub, prototype, playtest, mise à jour de la bibliothèque ou du dépôt.
- **Avancement du chantier actuel : À évaluer**
- **Avancement du projet global : À évaluer**
- **Prochaine priorité :** arbitrer le sort d’un héros abandonné vivant, puis le coût de la retraite.


---

## Mise à jour de conception — 16 novembre 2026 : expéditions mixtes (V3.2)

**VALIDÉ EN CONCEPTION PAR L’UTILISATEUR :** LITD 1 adopte un modèle mixte : chaque expédition peut avoir un objectif identifiable tout en permettant l’exploration libre, les découvertes secondaires, le choix de poursuivre après un objectif, ou la retraite. Une réussite de mission n’équivaut pas automatiquement à une expédition sans pertes ; un retour sans objectif atteint peut conserver une valeur en connaissances, butin ou découvertes.

**Conséquences déduites, à spécifier :** journal distinguant objectif, survie, gains, pertes et conséquences ; opportunités secondaires ; exposition accrue aux dangers lors de la prolongation ; choix de ressources à transporter ; répercussions sur donjons persistants et narration.

**PROPOSITIONS NON VALIDÉES :** pas de chronomètre général par défaut ; urgences locales seulement si annoncées clairement ; objectifs pouvant être poursuivis par plusieurs voies ; écran de bilan structuré par dimensions de réussite.

**À ARBITRER :** modalités d’obtention des objectifs ; possibilité de quitter après objectif ; coûts précis de la retraite ; pression dynamique des donjons ; objectifs secondaires qui persistent ; limites du prototype initial ; interaction avec Game Over et héros abandonnés.

**Non réalisé :** implémentation, tests joueurs, équilibrage, modification du dépôt.


---

## Mise à jour de conception — 16 novembre 2026 : retour immédiat sous conditions (V3.3)

### Décision explicitement validée en conception
Le joueur peut demander un **retour immédiat au refuge sous conditions**, sans obligation systématique de parcourir physiquement le trajet inverse jusqu'à la sortie. Cette possibilité s'inscrit dans le modèle mixte d'expéditions, avant comme après l'accomplissement de l'objectif, sous réserve des conditions à définir. Le retour n'annule ni les blessures, ni les pertes, ni les conséquences de l'expédition.

### Distinction impérative
- **Retour volontaire** : mécanisme de sortie hors situation de crise, sous conditions à arbitrer.
- **Retraite en situation dangereuse ou en combat** : reste régie par la fiche de vision V2.1 ; possibilité de sauver ou d'abandonner un allié immobilisé ; coûts et modalités non tranchés.
- Le retour immédiat ne doit pas être interprété comme une téléportation universelle, ni comme une interdiction de la fuite en combat.

### Proposition de conditions, NON encore validées
1. Retour volontaire possible en exploration hors combat, en l'absence de menace immédiate ou de contrainte scénarisée clairement communiquée.
2. Retour possible même si l'objectif principal n'est pas accompli ; la mission demeure alors inachevée, sauf autre règle décidée ultérieurement.
3. En combat, la commande de retour volontaire ne remplace pas la mécanique de retraite.
4. Les héros immobilisés, capturés ou séparés imposent un traitement explicite avant extraction ; ne pas déclarer automatiquement mort un héros abandonné.
5. Une restriction temporaire de retour doit être lisible, compréhensible et anticipable ; pas de blocage arbitraire.
6. Les biens rapportés au refuge ne deviennent persistants entre campagnes qu'après dépôt effectif dans le coffre, conformément à V2.1.

### Conséquences de conception
- Interface : commande de retour, indication de disponibilité et motif précis en cas d'indisponibilité ; confirmation éventuelle des conséquences irréversibles à arbitrer.
- Mission : bilan distinct de l'objectif, du butin rapporté, des blessures, des pertes et des connaissances acquises.
- Donjon : mémoriser les événements persistants malgré la sortie immédiate ; modalités de retour au même lieu à définir.
- Équilibrage : empêcher l'extraction gratuite en pleine menace sans imposer une marche de retour répétitive ; tests joueurs nécessaires.
- Exploitation des ressources : seuls les biens réellement transportés reviennent ; aucun transfert magique depuis un compagnon abandonné.

### Cas limites à arbitrer et tester
- Groupe séparé ; héros inconscient mais transportable ; héros capturé ; poursuite ennemie ; déclenchement du combat pendant l'ouverture du menu ; piège en cours ; boss en cours ; sortie au milieu d'une action ; coffre plein ; objet de quête non transportable ; retour depuis une zone temporairement verrouillée ; interruption de connexion / sauvegarde.

### Suivi
- **Validé en conception** : principe de retour immédiat sous conditions.
- **Proposé, non validé** : liste détaillée des conditions et exceptions.
- **Non réalisé** : implémentation Godot, essais utilisateurs, audit GitHub, tests et équilibrage.
- **Avancement du chantier actuel : À évaluer**.
- **Avancement du projet global : À évaluer**.


---

## Mise à jour — 16 novembre 2026 : états d’extraction et prototype logique V3.4

**Règle validée précédemment :** retour immédiat sous conditions. **Les conditions détaillées ci-dessous restent des propositions NON validées par l’utilisateur.**

### États proposés
- Exploration sans danger immédiat : retour autorisé, que l’objectif soit achevé ou non.
- Combat : retour volontaire bloqué ; retraite de combat distincte.
- Poursuite active : retour bloqué jusqu’à rupture de poursuite.
- Piège actif, événement en cours ou verrouillage de zone : retour bloqué jusqu’à résolution.
- Héros capturé, immobilisé, séparé ou inconscient : retour collectif bloqué jusqu’à résolution explicite de son sort. Cette règle de prototype ne préjuge PAS de la possibilité définitive d’abandonner un héros vivant ni des moyens de transport.
- Ennemi simplement présent au loin : ne bloque pas par principe.

### Prototype exécuté
- Fichiers : `litd_extraction_prototype/extraction.py` et `test_extraction.py`, hors dépôt du jeu.
- 13 tests unitaires Python exécutés avec succès le 16 novembre 2026.
- Contrôles : exploration objectif terminé/non terminé ; combat ; poursuite ; piège ; verrouillage ; événement ; capture ; immobilisation ; séparation ; inconscience ; priorités de motifs de blocage.
- **Limites :** aucune intégration Godot, aucune scène jouable, aucun test ergonomique ou joueur, aucune mesure de performance, aucune validation des règles de retraite en combat.

### Arbitrages prioritaires
1. Quand une poursuite commence et se termine : ligne de vue, distance, durée, recherche.
2. Gestion des héros capturés, abandonnés vivants, inconscients et séparés.
3. Sortie si une attaque ou un piège survient pendant la confirmation.
4. Traitement des objets de quête et des inventaires pleins.
5. Présentation du motif de blocage et des conséquences irréversibles.

**Statut :** 🟡 À CONSOLIDER. **Avancement du chantier actuel : À évaluer. Avancement du projet global : À évaluer.**


---

## Mise à jour V3.5 — Suppression de la poursuite et objets de fuite (16 novembre 2026)

### Décisions explicites de l’utilisateur — VALIDÉES EN CONCEPTION
1. **Aucune mécanique de poursuite ennemie** : supprimer du modèle de conception la poursuite active, les états de recherche, la rupture de ligne de vue et les distances ou délais destinés à semer un poursuivant.
2. **Marchand d’objets de fuite** : un marchand vendra notamment des fumigènes et d’autres objets destinés à faciliter la fuite.
3. **Choix stratégique d’exploration** : ces objets font partie intégrante de la préparation, de la gestion des ressources et des décisions pendant l’expédition.
4. Les décisions antérieures restent en vigueur : **retour immédiat sous conditions** hors des situations qui l’empêchent ; **retraite de combat distincte** ; règles de héros immobilisés ou abandonnés non automatiquement mortels.

### Conséquences et propositions à arbitrer (NON VALIDÉES)
- Définir quels objets agissent pendant le combat, hors combat, ou dans les deux situations ; ne pas supposer qu’un fumigène téléporte automatiquement le groupe au refuge.
- Déterminer si la fumée protège une tentative de retraite, neutralise une attaque d’opportunité, aide à libérer un allié, ou remplit une autre fonction.
- Définir prix, disponibilité, rareté, empilement, poids en cases d’inventaire et nombre d’utilisations.
- Définir les conditions exactes qui bloquent le retour immédiat (combat, piège en cours, verrouillage scénarisé, etc.) **sans réintroduire une poursuite**.
- Déterminer les conditions de retraite sans objet : les consommables doivent être utiles sans devenir arbitrairement obligatoires.
- Préciser les règles d’usage avec un héros capturé, inconscient, immobilisé ou abandonné.
- Prévoir un affichage compréhensible du résultat et du coût avant consommation de l’objet.

### Correction du référentiel technique
- **La section V3.4 décrivant un état « poursuite active » est désormais OBSOLÈTE sur ce point.** Ses tests Python de poursuite ne constituent plus des critères d’acceptation du jeu.
- Le prototype logique V1 n’a **pas** été modifié ni retesté dans cette mise à jour ; il devra être refondu pour supprimer l’état de poursuite et introduire les effets des objets de fuite une fois ceux-ci arbitrés.
- Les 13 tests réussis en V3.4 restent un fait historique limité à l’ancienne spécification, **pas une validation de V3.5**.

### Suivi
- **Validé en conception** : absence de poursuite, marchand et objets de fuite stratégiques.
- **À consolider** : effets, coût, disponibilité, interactions avec retraite et extraction.
- **Non réalisé** : implémentation Godot, refonte du prototype Python, tests de gameplay.
- **Avancement du chantier actuel : À évaluer. Avancement du projet global : À évaluer.**


---

## Mise à jour V3.6 — Guet-apens en remplacement des poursuites (16 novembre 2026)

### Décisions explicites — VALIDÉES EN CONCEPTION
1. Les **guet-apens remplacent les poursuites ennemies** dans l’exploration : il n’existe pas de système de chasse continue, de recherche ou de distance pour semer un ennemi.
2. Des ennemis peuvent **tendre des embuscades** au groupe pendant l’exploration.
3. Le **marchand d’objets de fuite**, notamment de fumigènes, reste prévu ; ces objets sont intégrés aux choix stratégiques de préparation et d’expédition.
4. Le **retour immédiat sous conditions** reste une règle de conception ; les règles de retraite en combat et de héros immobilisés restent distinctes.

### Propositions à arbitrer — NON VALIDÉES
- Déclenchement : salles, passages, événements, pièges, ennemis dissimulés ; modalités précises non arrêtées.
- Signaux précurseurs et moyens de détection : indices environnementaux, connaissances, compétences ou équipement.
- Effets d’un guet-apens : initiative, surprise, positionnement, verrouillage temporaire de l’extraction ; aucune valeur chiffrée arrêtée.
- Retraite : conditions d’utilisation des fumigènes et autres objets ; fuite sans objet ; protection et extraction des alliés immobilisés.
- Déclenchement d’un guet-apens pendant l’ouverture d’un menu : cohérence avec le monde qui continue à évoluer ; interface fermée à l’entrée en combat.
- Persistance et fréquence : éviter les embuscades répétitives, arbitraires ou exploitables.

### Compatibilité et limites de validation
- Les sections antérieures décrivant la **poursuite active** restent historiques et **obsolètes** sur ce point.
- L’affirmation « retour bloqué pendant un guet-apens » est une **proposition de cohérence**, non une règle explicitement validée.
- Le prototype Python V1 et ses 13 tests ne valident ni les guet-apens ni les fumigènes ; aucune modification du code Godot n’est attestée.

### Suivi
- **Validé en conception :** remplacement de la poursuite par les guet-apens.
- **À consolider :** déclencheurs, avertissements, résolution, effets des objets et conditions de sortie.
- **Avancement du chantier actuel : À évaluer. Avancement du projet global : À évaluer.**


---

## Mise à jour V3.7 — Typologie et anticipation des guet-apens (16 novembre 2026)

### Rappel des décisions VALIDÉES EN CONCEPTION
- Les guet-apens remplacent la poursuite continue ; aucun système de chasse/recherche de poursuivants.
- Un marchand vend notamment des fumigènes et objets de fuite, éléments stratégiques de préparation.
- Retour immédiat au refuge sous conditions, distinct de la retraite en combat.

### Propositions de conception NON ENCORE VALIDÉES
**Quatre familles de guet-apens :**
1. **Passage** : couloirs, portes, croisements ; traces, barricades, silence suspect ; désavantage potentiel de position.
2. **Appât** : coffre, relique, cadavre ; butin exposé, mécanismes, scène anormale ; inspection ou contournement possibles.
3. **Créatures** : pièges et cachettes propres à une espèce ; os, griffures, toiles, odeurs ; connaissances du bestiaire utiles.
4. **Narratif** : négociation ou événement hostile ; contradictions, témoignages, manuscrits ; anticipation par enquête.

**Trois niveaux de perception envisagés :** danger non identifié, suspicion (inspection/contournement/préparation), danger identifié (contre-mesures ciblées). Les indices ne garantissent pas une révélation complète. Prévoir des signes exploitables pour les guet-apens aux conséquences les plus graves ; éviter le piège arbitraire.

**Effets tactiques possibles :** surprise, placement initial défavorable, menace sur un membre, tentative d'immobilisation. Ne pas fixer de bonus, probabilité ou dégâts avant prototype et playtest.

**Fumigènes et retraite :** un fumigène pourrait créer une occasion de fuite ou couvrir le sauvetage d'un allié ; il ne doit pas être supposé téléporter automatiquement le groupe. Les règles de fuite sans objet, le coût en actions, les limitations face aux boss et les cas d'abandon restent à arbitrer.

**Retour immédiat :** proposer un blocage uniquement pendant la résolution active d'un guet-apens (ou un combat/événement incompatible), jamais par une poursuite réintroduite. Une fois l'événement résolu, les conditions ordinaires du retour s'appliquent. Non validé à ce stade.

### Critères de prototype envisagés (NON TESTÉS)
- Un guet-apens possède un déclencheur reproductible et des indices accessibles avant l'engagement.
- L'inspection ou une connaissance du bestiaire peut modifier l'information disponible ou les options tactiques.
- Le joueur peut décider de contourner ou de se préparer lorsqu'une telle option est annoncée.
- L'activation d'un guet-apens ferme le menu d'exploration conformément à la règle UI existante.
- Les objets de fuite ne contournent pas automatiquement les règles de retraite et d'abandon.
- Aucune poursuite ennemie n'est créée après la résolution du guet-apens.
- Mesurer fréquence, lisibilité, frustration et diversité en tests joueurs.

### Statut
**Validé :** principes antérieurs rappelés. **À consolider :** classification, indices, détection, effets, fumigènes. **Non réalisé :** implémentation Godot, tests automatisés V3.7 et playtests.
**Avancement du chantier actuel : À évaluer. Avancement du projet global : À évaluer.**


---

## Mise à jour V3.8 — Étude de la détection hybride des guet-apens (16 novembre 2026)

### Décisions déjà validées (inchangées)
- Guet-apens en remplacement des poursuites continues ; aucune mécanique de poursuite.
- Marchand proposant fumigènes et autres objets de fuite ; préparation stratégique.
- Retour immédiat sous conditions, distinct de la retraite en combat.

### Proposition étudiée — NON VALIDÉE PAR L’UTILISATEUR
**Détection hybride** reposant sur trois sources complémentaires :
1. **Observation directe du joueur** : traces, pièges, anomalies du décor et comportements suspects accessibles sans spécialiste obligatoire.
2. **Aptitudes et caractéristiques des héros** : perception d’indices subtils, interprétation et avertissements contextuels, sans révélation systématiquement parfaite.
3. **Connaissances du bestiaire** : reconnaissance des habitudes d’une espèce, amélioration de la qualité des informations et accès à des contre-mesures connues.

**Trois degrés d’information proposés** : danger non identifié ; suspicion ; danger identifié. Ils ne constituent pas des taux de détection ni des valeurs chiffrées validées.

**Règles d’équilibrage proposées** : pas de classe de détection obligatoire ; indices environnementaux exploitables ; aptitudes comme aide à l’interprétation ; connaissance persistante sans immunité ; un guet-apens détecté peut demeurer incontournable mais être préparé ; éviter les inspections répétitives de chaque élément du décor.

**Exemple fictif de test** : des corps suspendus dans un passage, des cordages récents repérés par un héros observateur, puis reconnaissance de la technique ennemie grâce au bestiaire. Exemple illustratif, non contenu narratif validé.

### À arbitrer
- Validation ou rejet du modèle hybride.
- Aptitudes exactes mobilisées et possibilité d’échec.
- Nature des indices accessibles sans compétence ; traitement des passages obligatoires.
- Effet exact de la préparation sur la surprise, l’initiative, la formation et les objets de fuite.
- Lisibilité des alertes et adaptation aux contrôles clavier/manette/tactile.

### Validation technique
Aucune implémentation Godot, aucun test automatisé de ce nouveau modèle et aucun playtest réalisés dans cette mise à jour. Les anciens tests Python de V3.4 ne sont pas applicables à la détection des guet-apens.

**Avancement du chantier actuel : À évaluer. Avancement du projet global : À évaluer.**


---

## Mise à jour V3.9 — Détection hybride validée et préparation tactique (16 novembre 2026)

### Décision explicite — VALIDÉE EN CONCEPTION
L'utilisateur valide le **modèle hybride de détection des guet-apens**, combinant :
1. **Observation directe du joueur** : indices visibles dans l'environnement.
2. **Aptitudes des héros** : découverte et interprétation d'indices supplémentaires.
3. **Connaissances du bestiaire** : reconnaissance de comportements ennemis et des contre-mesures connues.

Cette validation remplace le statut « proposition non validée » de la section V3.8 **uniquement pour le principe hybride**. Les seuils, probabilités, aptitudes exactes, niveaux d'information et effets de la préparation restent à arbitrer. Les poursuites ennemies restent exclues ; le marchand de fumigènes et le retour immédiat sous conditions sont maintenus.

### Suite de conception — PROPOSITIONS NON VALIDÉES
**Après détection d'un danger**, quatre réactions possibles à étudier :
- **Observer davantage** : inspection ciblée des indices et recherche d'informations ; aucune révélation parfaite garantie.
- **Préparer les quatre combattants** : ajuster formation, équipement et stratégie avant l'engagement, sous réserve des règles de changement d'équipement hors combat.
- **Contourner** : chercher un autre passage ou renoncer à une récompense ; certains passages peuvent rester obligatoires, mais doivent offrir une préparation utile.
- **Engager volontairement** : initier le combat avant le déclenchement du piège ; avantage éventuel à préciser, sans « tour gratuit » automatique.

**Transition exploration → combat proposée :**
1. Indice accessible → observation/interprétation selon les trois sources validées.
2. Le joueur choisit une réaction tant que le guet-apens n'est pas déclenché.
3. Le déclenchement ferme les menus conformément à la règle UI déjà validée.
4. Le combat applique la formation et les états réels du groupe ; les effets de surprise/initiative ne sont pas encore chiffrés.
5. Une fois l'affrontement résolu, retour aux règles ordinaires de retraite et d'extraction, sans système de poursuite.

**Précautions :** ne pas rendre un spécialiste obligatoire ; éviter que l'inspection systématique de chaque objet soit optimale ; distinguer la présence d'indices de leur interprétation ; ne pas transformer les fumigènes en téléportation universelle ; préserver les règles d'abandon d'un héros vivant et de Game Over si les quatre combattants meurent.

### Décisions ouvertes prioritaires
1. Quels effets concrets la préparation a-t-elle sur l'initiative, le placement et la surprise ?
2. Un guet-apens identifié peut-il être attaqué préventivement, et à quelles conditions ?
3. Quels coûts ou limites s'appliquent à l'inspection et à la reconfiguration de la formation ?
4. Quels types de guet-apens sont contournables ?
5. Quels effets exacts les fumigènes produisent-ils en combat ou en guet-apens ?

### Vérification et statut
- **Validé en conception** : principe de détection hybride, explicitement approuvé.
- **Étudié, non validé** : quatre réactions et transition détaillée.
- **Non réalisé** : intégration Godot, tests de gameplay, playtests et mesures d'équilibrage.
- **Avancement du chantier actuel : À évaluer. Avancement du projet global : À évaluer.**


---

## Mise à jour V4.0 — Attaque préventive conditionnelle et transition tactique (16 novembre 2026)

### Décision explicite — VALIDÉE EN CONCEPTION
L'utilisateur valide l'**attaque préventive contre un guet-apens uniquement lorsque les ennemis sont à la fois localisés et accessibles**. Cette règle complète la détection hybride déjà validée (observation du joueur, aptitudes des héros, bestiaire). Elle ne valide ni bonus d'initiative, ni tour gratuit, ni coût chiffré.

### Distinctions obligatoires
- **Suspicion / détection d'un guet-apens** : un indice signale un danger potentiel, sans nécessairement révéler l'identité ni la position des ennemis.
- **Localisation** : au moins un ennemi est situé de manière exploitable pour le ciblage ; la simple connaissance de son espèce ou de son comportement ne suffit pas.
- **Accessibilité** : au moins une action offensive réellement disponible peut engager une cible localisée selon la portée, les rangs, les obstacles, les états et les restrictions de la compétence.
- Une attaque préventive n'est donc possible que si les conditions de localisation **et** d'accessibilité sont réunies au moment de son déclenchement.
- L'attaque préventive n'autorise pas automatiquement à viser un membre invisible ou inaccessible : les règles de ciblage anatomique restent applicables.
- Si le guet-apens est déjà déclenché, on utilise le combat ordinaire et ses règles de retraite ; on ne réactive pas rétroactivement une attaque préventive.

### Transition proposée — À ARBITRER
1. Indices et informations issus des trois canaux de détection.
2. Si les ennemis sont localisés et accessibles, le joueur peut choisir une action offensive préventive ; sinon il peut chercher des informations, préparer le groupe ou contourner lorsque c'est possible.
3. L'engagement ferme les menus d'exploration, conformément aux règles UI validées.
4. Le système initialise le combat avec la formation, les états et les ressources réels des quatre combattants ; les restrictions de rang et de ciblage restent en vigueur.
5. **Proposition d'équilibrage, non validée :** l'initiative et la surprise peuvent être influencées par l'anticipation, sans tour gratuit systématique. Définir précisément si l'action qui ouvre le combat consomme des PA et comment elle s'insère dans l'ordre d'initiative.
6. Une fois l'affrontement résolu, les règles de retour immédiat sous conditions et de retraite s'appliquent ; aucune poursuite ennemie n'est introduite.

### Cas limites à tester, non validés techniquement
- Indices visibles mais ennemis non localisés : pas d'attaque préventive.
- Ennemis localisés derrière un obstacle infranchissable : pas d'attaque avec une compétence bloquée ; vérifier les attaques à portée différente.
- Un seul ennemi accessible parmi plusieurs : ciblage limité aux cibles et membres réellement accessibles.
- Changement de formation ou d'équipement avant engagement : respecter les restrictions hors combat ; déterminer si une préparation est possible en présence d'un danger imminent.
- Attaque préventive manquée : préciser si le combat démarre immédiatement et quelles conséquences surviennent.
- Plusieurs groupes ennemis, leurres ou fausses informations : ne pas révéler automatiquement les ennemis non découverts.
- Fumigènes : leur rôle stratégique demeure validé, mais leurs effets précis restent à arbitrer ; aucune extraction universelle automatique.
- Héros immobilisé ou abandonné : conserver les règles déjà validées de retraite et d'équipement ; pas de décès automatique par abandon.

### Arbitrages prioritaires
1. Coût en points d'action et place de l'attaque d'ouverture dans l'initiative.
2. Effet concret de la détection sur surprise, formation et initiative.
3. Modalités de localisation et d'accessibilité en exploration 3D isométrique avant transition vers combat 2D.
4. Réaction des ennemis à une attaque préventive manquée ou partiellement réussie.
5. Conditions et coûts de préparation avant engagement ; types de guet-apens contournables.
6. Effets précis des fumigènes et objets de fuite vendus par le marchand.

### Statut de réalisation
- **Validé en conception :** attaque préventive conditionnelle (localisés ET accessibles), détection hybride, absence de poursuite, marchand et objets de fuite, retour immédiat sous conditions.
- **À consolider :** règles d'initiative, surprise, coût, visibilité, ciblage et résolution des cas limites.
- **Non réalisé :** modification Godot, tests automatisés de cette règle, test en jeu, playtest.
- **Avancement du chantier actuel : À évaluer. Avancement du projet global : À évaluer.**


---

## Mise à jour V4.1 — Action d’ouverture avec coût normal en PA (16 novembre 2026)

### Décision explicite — VALIDÉE EN CONCEPTION
Le joueur valide le modèle **action d’ouverture** pour l’attaque préventive d’un guet-apens : l’attaque est une **véritable action de combat** et consomme son **coût normal en points d’action (PA)**. Elle ne constitue pas une attaque gratuite, et son auteur ne reçoit pas automatiquement un tour ou une action supplémentaire.

La condition préalable déjà validée demeure : **ennemi localisé ET accessible** par l’action sélectionnée. La détection hybride (observation du joueur, aptitudes des héros, connaissances du bestiaire) reste en vigueur.

### Règles de cohérence découlant de la décision
1. Au déclenchement, le système initialise le combat avec les héros, formations, ressources et états réellement présents ; l’interface d’exploration se ferme.
2. Le joueur choisit une compétence offensive effectivement disponible, une cible localisée et une zone anatomique accessible selon les règles ordinaires.
3. Le coût habituel en PA de la compétence est débité **une seule fois** lors de la résolution de l’action d’ouverture ; aucun second débit au passage en combat.
4. Une attaque manquée ou résistée consomme également ses PA, conformément au coût normal d’une action résolue.
5. L’action d’ouverture ne donne pas automatiquement à son auteur un tour complet supplémentaire. Le traitement de ses PA restants et sa place dans l’ordre d’initiative restent à arbitrer.
6. L’action ne révèle pas automatiquement les autres ennemis cachés. Aucun système de poursuite ennemie n’est réintroduit.
7. Les fumigènes et objets de fuite du marchand restent des outils stratégiques ; leurs effets exacts ne sont pas fixés par cette décision.

### Modèle de résolution recommandé — PROPOSITION, NON VALIDÉE
- Initialiser le premier round avant de résoudre l’action d’ouverture.
- Réserver le créneau d’ouverture au héros initiateur, sans lui attribuer un second créneau complet dans ce même round.
- Déduire les PA de l’action ; les PA restants ne peuvent être utilisés que si le modèle d’initiative retenu le permet.
- Résoudre ensuite les autres créneaux selon la règle d’initiative qui sera décidée.
- Une attaque d’ouverture interrompue avant résolution nécessite une règle distincte de dépense ou remboursement de PA : non arbitrée.

### Cas limites à spécifier et à tester
- PA insuffisants ou compétence indisponible avant le déclenchement : action refusée.
- Cible perdue, déplacée ou devenue inaccessible pendant la transition : préciser annulation, nouvelle cible ou échec.
- Attaque manquée : coût normal appliqué ; réaction ennemie et ordre du round à préciser.
- Plusieurs ennemis cachés : aucune révélation automatique.
- Attaque multi-cible, attaque à préparation, coût variable, affliction, interruption : cohérence avec les règles de combat existantes à vérifier.
- Rechargement ou sauvegarde pendant la transition : pas de double exécution ni de double dépense de PA.

### Arbitrage prioritaire suivant
**Choisir comment l’action d’ouverture s’insère dans le premier round** :
A. Elle constitue le créneau d’action du héros initiateur ; les PA restants sont gérés selon les règles normales du round.
B. Elle se produit avant l’ordre d’initiative, mais le héros initiateur ne reçoit pas de second créneau dans le premier round.
C. Autre modèle explicite, à définir.
Ne pas assimiler automatiquement l’action d’ouverture à un tour gratuit ou à un bonus d’initiative validé.

### Statut de réalisation
- **Validé en conception :** action d’ouverture avec coût normal en PA, sans tour supplémentaire automatique.
- **À consolider :** insertion exacte dans le round, traitement des PA restants, interruption et réactions ennemies.
- **Non réalisé :** modification Godot, test automatisé de la V4.1, validation en jeu et playtest.
- **Avancement du chantier actuel : À évaluer. Avancement du projet global : À évaluer.**


---
## V4.2 — Économie d’action : 1 PA par combattant et par tour (DÉCISION VALIDÉE EN CONCEPTION, 16 novembre 2026)

### Règle prioritaire
- Chaque héros et chaque ennemi dispose de **1 point d’action (PA) par tour**.
- Une action ordinaire utilisant ce point consomme le PA disponible du combattant pour son tour.
- Une **attaque préventive** constitue l’action du héros initiateur pour le **premier tour** du combat : elle consomme son unique PA et ne lui donne **aucun second tour ni seconde action** dans ce premier tour.
- Les autres combattants agissent selon l’initiative, dont les modalités précises restent à définir.
- Au tour suivant, le combattant dispose de nouveau de son PA selon le cycle normal de combat, sous réserve des états qui pourraient l’empêcher d’agir (à préciser).
- **Symétrie** : les ennemis disposent également de 1 PA par tour.

### Rectification explicite des propositions précédentes
- Les exemples de **3 PA**, d’attaque à **2 PA**, de **PA restants** ou de compétences à coût de plusieurs PA au cours d’un même tour ne sont **pas compatibles** avec la règle désormais validée. Ils sont **obsolètes** et ne doivent plus guider la conception.
- Les options V4.1 sur la gestion des « PA restants » sont closes sur ce point : il n’y a **aucun PA restant** après une attaque préventive consommant le PA unique.
- Les descriptions antérieures d’une économie de plusieurs PA sont conservées à titre de traçabilité historique uniquement ; **V4.2 prévaut** en cas de contradiction.
- Les combinaisons impliquant plusieurs héros peuvent rester compatibles si chaque participant engage son unique PA pour le tour ; l’ordre de résolution et les interruptions restent à arbitrer.
- Les exceptions éventuelles (actions gratuites, réactions, actions spéciales, déplacement, utilisation d’objets, effets de contrôle) ne sont **pas validées** par la présente décision et exigent une définition explicite.

### Cas de référence à vérifier dans un futur prototype
1. Héros initie une attaque préventive : son PA passe de 1 à 0 ; aucun second créneau d’action au premier tour.
2. L’attaque préventive échoue : le PA reste consommé.
3. Les autres héros et ennemis disposent chacun de leur unique PA au premier tour, sous réserve de leur ordre d’initiative et états.
4. Au tour suivant, le PA est renouvelé une seule fois, sans double crédit.
5. Un combo de deux héros engage au plus le PA disponible de chacun ; aucune création de PA.

### Statut
- **VALIDÉ EN CONCEPTION :** 1 PA par tour pour chaque héros et chaque ennemi ; attaque préventive imputée au premier tour, sans action supplémentaire.
- **À CONSOLIDER :** définition précise de « tour » et « round », initiative, déplacements, utilisation des objets, réactions, combos et interruptions.
- **NON TESTÉ :** aucune modification Godot ou exécution de tests dans cette mise à jour documentaire.
- **Avancement du chantier actuel : À évaluer. Avancement du projet global : À évaluer.**


---
## V4.3 — Guet-apens déjoué : léger bonus collectif d’initiative (DÉCISION VALIDÉE EN CONCEPTION, 16 novembre 2026)

### Décision explicite la plus récente, prioritaire
- **Déjouer un guet-apens accorde un léger bonus d’initiative à l’ensemble de l’équipe de héros.**
- L’initiative demeure déterminée par les règles ordinaires, en tenant compte de cet avantage. Le bonus **ne garantit pas** que tous les héros agissent avant tous les ennemis.
- **Chaque héros et chaque ennemi dispose toujours d’un seul PA par tour**, conformément à V4.2. Le bonus d’initiative ne donne aucun PA ni aucune action supplémentaire.
- La détection hybride reste validée : observation du joueur, aptitudes des héros et connaissances du bestiaire.
- L’attaque préventive reste **possible sous conditions** lorsque les ennemis sont localisés et accessibles ; si elle est effectuée, elle consomme l’unique PA du héros initiateur pour son premier tour, sans seconde action gratuite.
- **Ne pas confondre** le bonus collectif d’initiative obtenu en déjouant un guet-apens avec une action d’ouverture obligatoire ou un créneau gratuit. Un guet-apens peut être déjoué sans attaque préventive.

### Rectification des passages historiques
- Les formulations V4.0 à V4.2 qui privilégient un « créneau d’ouverture » comme **récompense principale ou automatique** de la détection sont **supplantées** sur ce point par la décision V4.3 : la récompense validée est un **léger bonus collectif d’initiative**.
- La description V4.2 du coût de l’attaque préventive demeure applicable **uniquement si le joueur choisit effectivement cette attaque**.
- Les anciens passages restent présents pour la traçabilité, mais **V4.3 prévaut** en cas de contradiction.

### Paramètres encore ouverts, non validés
1. **Valeur** du bonus : pas de chiffre arrêté.
2. **Durée** : **VALIDÉE en V4.4 : uniquement le premier tour / premier round du combat** ; aucune prolongation au deuxième round.
3. Définition opérationnelle de « guet-apens déjoué » : simple détection, identification, neutralisation du piège ou préparation réussie ? À arbitrer.
4. Calcul d’initiative, résolution des égalités et interaction éventuelle avec les malus de surprise ennemis.
5. Transition exacte entre attaque préventive et ordre d’initiative, sans double action.

### Vérification et avancement
- **Validé en conception :** léger bonus collectif d’initiative après guet-apens déjoué ; économie de 1 PA par combattant et par tour maintenue.
- **Réalisé :** correction documentaire V4.3 ; aucune règle chiffrée inventée.
- **Non réalisé / non testé :** modification du prototype Python antérieur, implémentation Godot, tests d’équilibrage ou playtests.
- **Avancement du chantier actuel : À évaluer. Avancement du projet global : À évaluer.**


---
## V4.4 — Durée du bonus d’initiative après guet-apens déjoué (DÉCISION VALIDÉE EN CONCEPTION, 16 novembre 2026)

### Décision explicite
- Le léger bonus collectif d’initiative accordé lorsqu’un guet-apens est déjoué **ne dure qu’un tour**, interprété pour l’initiative collective comme **le premier round du combat**.
- Le bonus concerne les quatre héros éligibles pendant ce premier round, sans garantir leur priorité sur tous les ennemis.
- **Dès le deuxième round**, ce bonus de guet-apens n’est plus appliqué.
- Ce bonus **n’accorde aucun PA supplémentaire** : chaque héros et ennemi conserve **1 PA par tour**.
- L’attaque préventive reste facultative et soumise aux conditions déjà validées (ennemi localisé et accessible). Si utilisée, elle consomme l’unique PA de son auteur pour son premier tour.

### Arbitrages encore ouverts
- Valeur numérique exacte du bonus et formule d’initiative.
- Définition opérationnelle de « guet-apens déjoué » et gestion des égalités.
- Vérification que l’ordre d’initiative peut être recalculé normalement au deuxième round sans conserver l’avantage temporaire.

### Traçabilité et vérification
- Cette décision **remplace** le point V4.3 où la durée était indiquée comme non validée.
- Mise à jour **documentaire seulement** : aucune modification du code Godot ni test en jeu.
- **Avancement du chantier actuel : À évaluer. Avancement du projet global : À évaluer.**


---
## V4.5 — Politique transversale de report des valeurs (DÉCISION VALIDÉE EN CONCEPTION, 16 novembre 2026)

### Règle permanente
Toutes les valeurs numériques de réglage et d’équilibrage de LITD 1 sont **reportées à une phase ultérieure**, sauf si une valeur temporaire est **nécessaire** pour préciser une règle, lever une ambiguïté bloquante, construire un prototype ou exécuter un test utile.

### Application
- Priorité à la définition qualitative : déclencheurs, effets, interactions, limites, exceptions et lisibilité pour le joueur.
- Les valeurs provisoires nécessaires à un test sont clairement identifiées comme **hypothèses de prototype**, jamais comme décisions définitives.
- Les dégâts, probabilités, résistances, amplitudes de bonus, prix, coûts, capacités, seuils et durées encore non décidés sont reportés sans bloquer artificiellement la conception.
- Les **valeurs structurelles déjà explicitement validées** restent applicables : notamment quatre combattants en expédition, rangs R1 à R4, un PA par héros ou ennemi et par tour, bonus de guet-apens déjoué limité au premier round.
- La nécessité éventuelle d'une valeur immédiate doit être justifiée par une dépendance de conception ou un protocole de test concret, non par simple commodité.

### Application immédiate aux guet-apens
- Le bonus d’initiative est **léger, collectif et limité au premier round** : décision validée.
- **Amplitude numérique et formule** : reportées à l’équilibrage, sauf nécessité démontrée pour un prototype.
- **Définition opérationnelle de « guet-apens déjoué »** : reste à concevoir dès maintenant, car il s’agit d’une condition de déclenchement, pas d’une valeur d’équilibrage.

### Portée de la mise à jour
Décision ajoutée au document maître ; aucune modification de Godot, du prototype Python ou aucun test de gameplay n'a été réalisé. Les mentions historiques « valeur à arbitrer » demeurent comme archives, mais doivent désormais être interprétées selon cette politique V4.5.


---
## V4.6 — Guet-apens, pièges mécaniques et coffres ennemis (décisions de conception, 16 novembre 2026)

### Décisions explicites de l'utilisateur
1. **Répartition cible des guet-apens : 35 % détectables et 65 % indétectables.** Il s'agit d'une cible de conception choisie explicitement, non d'un taux mesuré ou implémenté. Elle s'applique aux guet-apens, incluant embuscades et pièges révélant des ennemis ; son extension aux pièges mécaniques autonomes n'est pas décidée.
2. Le terme **guet-apens** englobe les embuscades ennemies et les pièges qui révèlent ou font apparaître des ennemis.
3. **Les pièges mécaniques ne sont jamais directement mortels.** Ils peuvent affecter les statistiques, les capacités, provoquer des malus persistants (par exemple précision ou initiative), empoisonner, transmettre des maladies et détériorer l'équipement.
4. Certains pièges mécaniques peuvent **téléporter le groupe dans une salle secrète avec un ennemi d'élite et un butin important**. Le piège de téléportation n'est pas directement mortel ; le combat qui peut suivre reste dangereux.
5. **Certains coffres sont des ennemis déguisés en coffres** (coffres-créatures / mimics au sens fonctionnel). Le comportement précis de ces ennemis n'est pas encore défini.

### Cohérence avec les décisions antérieures
- **Pas de poursuite ennemie** en exploration ; des guet-apens prennent sa place comme source de tension.
- **Détection hybride** (observation, aptitudes des héros, bestiaire) pour la fraction détectable ; ne pas révéler artificiellement un guet-apens défini comme indétectable.
- Si un guet-apens est **déjoué**, le groupe bénéficie d'un **léger bonus collectif d'initiative pour le premier round seulement**, sans PA supplémentaire. Définition de « déjoué » encore ouverte.
- **Attaque préventive** uniquement si les ennemis sont localisés et accessibles ; elle coûte le PA normal (1 PA par combattant et par tour).
- Le marchand et ses fumigènes/objets de fuite restent des outils stratégiques de préparation et de retraite.
- La détérioration de l'équipement doit respecter la règle antérieure : **pas d'usure ordinaire progressive** ; seuls des événements explicitement prévus et lisibles peuvent endommager l'équipement. Les légendaires restent indestructibles, mais peuvent être endommagés.
- La **non-létalité directe** des pièges doit rester vraie même sur un héros affaibli ; les règles de dégâts périodiques du poison et des maladies doivent être précisées pour éviter une contradiction. Ne pas considérer comme décidée l'immunité à la mort indirecte.

### Études et arbitrages ouverts (non validés)
- Définir précisément le dénominateur du taux de 35 % dans la génération procédurale et les cas particuliers scénarisés ; tester la fréquence ressentie sans fixer d'autres taux maintenant.
- Définir ce qui constitue « déjouer » un guet-apens (détection, évitement, neutralisation, préparation, etc.).
- Définir la résolution et la durée des afflictions, maladies et altérations, sans figer de valeurs avant nécessité de prototype.
- Définir comment un piège peut être non directement mortel lorsqu'il inflige du poison ou une maladie susceptible de provoquer des dégâts ultérieurs.
- Définir les conditions de sortie de la salle secrète, les possibilités de retraite, et éviter toute téléportation qui imposerait automatiquement un combat impossible.
- Définir les interactions entre coffres ennemis, inspection, détection et déclenchement du combat ; ne pas assimiler automatiquement tous les coffres ennemis à des pièges mécaniques.

### Statut et preuve
Décisions **validées en conception** uniquement. Aucun changement Godot, aucune simulation de fréquence et aucun test joueur réalisés pour V4.6. Avancement du chantier actuel : À évaluer. Avancement du projet global : À évaluer.


---
## V4.7 — Vision du monde, expéditions et difficulté (17 novembre 2026)

### Décisions explicitement validées en conception
1. **Finalité générale : orientation C**, combinant mystère du monde, survie/progression de la compagnie et reconstruction/développement du refuge. Le scénario détaillé et le lore ne sont pas fixés.
2. **Régions à identité persistante**, chacune avec son biome propre. Exemples expressément cités : montagnes enneigées, désert aride avec oasis, jungle luxuriante, forêt séculaire. Le nombre de régions n'est pas fixé.
3. **Régions découpées en petites zones**, dans l'esprit de *Monster Hunter*. Les zones contiennent ressources et ennemis ; le véritable défi se concentre dans les donjons.
4. **Agencement des zones variable selon les expéditions** : l'identité de la région persiste, mais les connexions et l'ordre des zones peuvent changer. Les modalités précises de persistance des points de repère restent ouvertes.
5. **Plusieurs donjons par région**, à génération procédurale hybride ; les donjons sont le principal foyer de difficulté.
6. **Une expédition est limitée à une seule région.** Un changement de région implique de terminer l'expédition et de repasser par le refuge. Cette décision annule la proposition antérieure autorisant plusieurs régions au cours d'une expédition.
7. **Une région doit être difficile à explorer entièrement** ; ne pas concevoir sa traversée intégrale comme une formalité.
8. **Les ennemis hors donjon s'adaptent au niveau de la compagnie.**
9. **Les donjons ont une difficulté propre, égale ou supérieure au niveau de la compagnie**, et cette difficulté augmente au fil de la progression de la compagnie. La formulation « niveaux fixes » doit être conciliée avec cette évolution : la méthode précise (paliers, plancher de difficulté, autres) n'est pas encore validée.
10. **Les valeurs d'équilibrage restent reportées**, sauf nécessité démontrée de conception ou de test, conformément à V4.5.

### Propositions discutées, non encore validées explicitement
- Possibilité de parcourir **plusieurs donjons d'une même région au cours d'une expédition** : cohérente avec la vision, mais modalités non définitivement arbitrées.
- Configuration des zones et des donjons **stable pendant une même expédition**, avec renouvellement à l'expédition suivante.
- Conservation de l'état d'un donjon quitté puis revisité pendant la même expédition.
- Donjons revisités librement, avec récompenses narratives uniques non répétables.
- Trois rôles non exclusifs des donjons : ressources, découverte, défi majeur.
- Progression semi-ouverte entre régions et déblocages par histoire, découverte ou développement du refuge.
- Ajustement des donjons par paliers et maintien d'un sentiment de progression malgré l'adaptation des ennemis extérieurs.

### Cohérence et priorités
- La **persistance** porte à ce stade sur l'identité et les acquis majeurs de la région, **pas nécessairement sur la topologie de ses zones**.
- Ne pas confondre la difficulté évolutive des donjons avec un nivellement automatique identique à celui des ennemis extérieurs.
- Les choix de génération doivent garantir les accès nécessaires aux missions et éviter les parcours impossibles ; les règles techniques ne sont pas encore spécifiées.
- **Priorité suivante** : fixer les dernières grandes lignes des expéditions et de la difficulté des donjons, puis les conséquences des issues (réussite, retraite, défaite), sans entrer prématurément dans les valeurs.

### Exécution et état
- **Réalisé et vérifié :** ajout documentaire V4.7 à la suite de V4.6, sans suppression des sections précédentes.
- **Non réalisé :** modification du dépôt Godot, implémentation, tests de génération, simulation d'équilibrage ou validation en jeu.
- **Chantier actuel : 🟡 À CONSOLIDER.** Avancement du chantier actuel : À évaluer. Avancement du projet global : À évaluer.

---
## Note de méthode — 17 novembre 2026 : actualisation à chaque validation

**Instruction explicite de l'utilisateur :** dès qu'une décision de conception LITD 1 est validée, actualiser le document maître, sans attendre la clôture du chantier. Conserver les décisions antérieures et leur traçabilité ; distinguer systématiquement les décisions validées, les propositions non validées, les éléments à tester et les règles remplacées. Ne jamais présenter une proposition comme une décision acquise. Chaque actualisation doit produire une version identifiable.

**État :** règle de suivi documentaire enregistrée dans cette version. La progression de la difficulté des donjons par paliers reste une proposition non validée ; les issues d'expédition doivent encore être examinées à partir des décisions existantes.


---
## V4.9 — Arbitrages validés : difficulté, missions et expéditions (17 novembre 2026)

### Décisions explicites validées en conception
1. **Difficulté hybride des donjons :** la puissance des ennemis augmente progressivement avec la progression de la compagnie, tandis que **de nouvelles menaces apparaissent par paliers**. Cette règle précise la difficulté évolutive déjà décidée en V4.7 ; elle remplace la mention antérieure selon laquelle les paliers restaient entièrement à arbitrer. Les donjons conservent leur identité et leur difficulté propre, au moins égale ou supérieure à celle de la compagnie, selon la règle de V4.7. Les seuils et formules restent ouverts.
2. **Récompenses dépendantes de la mission :** selon l'objectif, une mission accomplie peut apporter des ressources, objets, découvertes, informations narratives ou avancées pour le refuge. Aucun barème uniforme n'est fixé.
3. **Mission abandonnée lors d'une retraite :** elle peut être recommencée **sans pénalité narrative permanente liée au seul abandon**, **tout en conservant la persistance de ce qui s'est réellement passé pendant la mission**. Les événements, actions et conséquences déjà survenus ne sont pas effacés par l'abandon ou la nouvelle tentative. La portée exacte de cette persistance (état des lieux, ennemis, ressources, découvertes, événements) reste à définir. Ne pas interpréter « sans pénalité narrative » comme une remise à zéro du monde, ni comme une annulation des pertes matérielles ou humaines déjà subies.
4. **Mission et expédition sont deux notions distinctes :** une mission peut être accomplie sans retour réussi ; inversement, une retraite avec du butin peut rendre une expédition profitable même si son objectif n'est pas accompli. Ne pas confondre succès d'objectif, survie, retour et gains sécurisés.
5. **Principe de conception transversal, formulation de l'utilisateur : « Les missions servent l’expédition et l’expédition sert les missions. »** Les objectifs structurent et enrichissent l'exploration ; l'exploration permet d'accomplir, découvrir ou faire progresser des missions. Aucun des deux systèmes ne doit être conçu comme entièrement indépendant de l'autre.

### Vérification de cohérence avec les règles antérieures
- **Compatible** avec la limite d'une région par expédition et l'existence de plusieurs donjons par région.
- **Compatible** avec les ennemis extérieurs adaptés à la compagnie : la nouvelle règle hybride vise spécifiquement les donjons.
- **Compatible** avec le retour conditionnel au refuge, les héros abandonnés et le butin effectivement transporté. La possibilité de recommencer une mission ne restaure ni les morts ni l'équipement perdu.
- **Compatible sous réserve de conception** avec la génération procédurale : l'agencement peut changer entre expéditions, mais les faits persistants doivent être représentés indépendamment de cet agencement pour ne pas disparaître arbitrairement. Ce mécanisme est à définir, non implémenté.
- **À clarifier :** « sans pénalité narrative permanente » n'interdit pas les conséquences narratives des actions réellement accomplies ou des événements déclenchés pendant la mission ; cela interdit uniquement une sanction narrative permanente automatique pour l'abandon lui-même.
- **À clarifier :** la mission peut être recommencée, mais les objectifs déjà résolus, ennemis tués, objets uniques pris ou changements irréversibles ne doivent pas être automatiquement réinitialisés ; les règles de reprise seront définies ultérieurement.

### Restent ouverts (ne pas présenter comme validés)
- Seuils des paliers, vitesse de progression des ennemis et mesure du niveau de compagnie.
- Portée exacte de la persistance des événements entre deux tentatives et entre deux expéditions ; articulation avec les variations de topologie.
- Règles de reprise des missions dont certains objectifs ont déjà été réalisés ou sont devenus impossibles.
- Stabilité de la topologie pendant une expédition, revisite des donjons et restrictions exactes de retour.

### Exécution et suivi
- **Réalisé :** intégration des cinq arbitrages ci-dessus dans le document maître V4.9, avec contrôle de cohérence documentaire.
- **Non réalisé :** modification du jeu, tests Godot, vérification en partie, équilibrage.
- **Chantier : 🟡 À CONSOLIDER.** Avancement du chantier actuel : À évaluer. Avancement du projet global : À évaluer.


---
## V5.0 — Persistance par mission et régénération des ressources (17 novembre 2026)

### Décisions explicites validées en conception
1. **Mémoire étendue pour une même mission :** lorsqu'une mission est interrompue puis reprise, ses événements et changements locaux persistent, notamment ennemis éliminés, coffres ouverts, passages débloqués et objectifs accomplis. La reprise conserve l'état antérieur de la mission ; les objectifs déjà atteints ne sont pas annulés.
2. **Nouvelle mission : renouvellement ordinaire :** lorsqu'une autre mission est démarrée, les ennemis ordinaires sont renouvelés et les coffres renouvelables sont à nouveau remplis. Ce renouvellement ne doit pas annuler les événements majeurs persistants, les découvertes importantes, les objets uniques déjà obtenus ou les conséquences narratives effectives. La distinction précise entre coffres renouvelables et uniques reste à concevoir.
3. **Ressources récoltables : temporisation de la repousse :** une ressource collectée n'est pas immédiatement disponible à nouveau après abandon ou changement de mission. Un délai doit séparer deux récoltes afin d'empêcher les boucles de récolte par sorties et retours rapides. La durée, l'horloge de référence et les exceptions ne sont pas décidées. Référence d'intention donnée par l'utilisateur : *No Rest for the Wicked* ; aucune vérification externe des mécaniques exactes de ce jeu n'est revendiquée.
4. **Reprise de mission abandonnée :** la mission reprend son état précédent, avec les objectifs déjà accomplis et les faits persistants. Aucun malus narratif permanent n'est appliqué automatiquement au seul abandon, conformément à V4.9.

### Cohérence et limites
- La mémoire est **indexée au contexte de la mission** pour les changements locaux, mais les faits importants du monde restent persistants au-delà de ce contexte.
- Un nouveau tirage procédural des zones ou des donjons ne doit pas effacer les événements persistants ; leur représentation dans une topologie renouvelée est un problème de conception à résoudre.
- Le renouvellement des ennemis ne ressuscite pas automatiquement un ennemi unique ou narrativement important dont la mort est persistante.
- Le remplissage des coffres ne duplique pas les récompenses uniques, ni les objets de mission déjà acquis.
- Le délai de régénération des ressources doit survivre à la fermeture/reprise de mission ; son modèle temporel exact reste à arbitrer.
- Une **nouvelle mission** n'est pas nécessairement une **nouvelle expédition** : ces deux notions demeurent distinctes conformément à V4.9.

### Questions ouvertes (non validées)
- Définition de l'identité d'une mission, de ses tentatives et des transitions entre missions.
- Durée de régénération, temps réel ou temps du jeu, et comportement lorsque la région est revisitée.
- Classification des ennemis, coffres et ressources renouvelables ou uniques.
- Gestion d'un objectif de mission devenu impossible du fait d'un événement persistant.
- Tests de non-duplication, de cohérence des sauvegardes et de persistance dans les zones procédurales.

### Exécution et suivi
- **Réalisé :** consolidation documentaire des décisions ci-dessus et contrôle logique par rapport aux sections V4.7 et V4.9.
- **Non réalisé :** implémentation Godot, test de sauvegarde, simulation de récolte ou validation en jeu.
- **Chantier : 🟡 À CONSOLIDER.** Avancement du chantier actuel : À évaluer. Avancement du projet global : À évaluer.


---
## V5.1 — Horloge de régénération et exceptions régionales (17 novembre 2026)

### Décisions explicitement validées en conception
1. **Temps du monde de LITD 1 :** les délais de régénération des ressources sont mesurés par le temps qui s'écoule **dans le jeu**. La durée exacte, les modalités d'écoulement au refuge et le comportement lorsque le jeu est fermé ne sont pas spécifiés ; ne pas inférer une progression hors ligne.
2. **Règle commune avec exceptions régionales :** les éléments ordinaires renouvelables suivent une base commune de régénération, modulable selon les régions, biomes et événements. Les objets uniques et les faits majeurs persistants ne sont pas remis à zéro par ce mécanisme.
3. **Conservation des décisions V5.0 :** l'abandon puis la reprise d'une même mission conserve l'état de cette mission ; le lancement d'une mission distincte renouvelle les ennemis ordinaires et coffres renouvelables ; les ressources récoltées ne se renouvellent pas immédiatement du seul fait d'une nouvelle mission.

### Recherche comparative : No Rest for the Wicked (17 novembre 2026)
- Des guides décrivent un renouvellement des ennemis, ressources et trésors lié au passage du temps et à l'éloignement de la zone, avec des vitesses variables selon les catégories ; le brouillard de guerre signale souvent une zone renouvelée.
- Les sources ne concordent pas sur une durée unique ni sur l'horloge exacte : des témoignages de 2026 évoquent des remises à zéro de zone qui progressent même hors connexion, tandis que d'autres guides évoquent le temps en jeu. Des mises à jour ont changé certaines mécaniques temporelles. **Aucune règle universelle actuelle, officiellement confirmée, n'est établie ici.**
- Cette comparaison **n'altère pas** la décision de LITD 1 d'utiliser le temps du monde du jeu. Ne pas présenter les observations sur No Rest for the Wicked comme un test direct.

### À arbitrer plus tard
- Écoulement du temps pendant les pauses, menus, repos, refuge et hors connexion ; règles anti-contournement.
- Délais et catégories exacts des ressources, exceptions régionales, retour visuel de la régénération.
- Persistance des temporisations en sauvegarde et protection contre les duplications.

### Exécution
- **Réalisé et vérifié :** ajout des deux décisions au document maître V5.1, sans effacer V5.0.
- **Non réalisé :** implémentation Godot, essais de régénération, vérification en jeu.
- **Chantier : 🟡 À CONSOLIDER.** Avancement du chantier actuel : À évaluer. Avancement du projet global : À évaluer.


---
## V5.2 — Progression et spécialisation de la compagnie (17 novembre 2026)

### Décisions explicitement validées en conception
1. **Progression hybride :** chaque héros progresse individuellement ; la compagnie bénéficie en parallèle d'améliorations collectives. Leurs sources, effets, limites et valeurs restent à définir.
2. **Classes avec personnalisation encadrée :** chaque héros possède une identité de classe. Les compétences et équipements autorisent différentes spécialisations **à l'intérieur des limites de cette classe**, sans transformation en une autre classe ou en une classe hybride interdite. Exemple explicite donné par l'utilisateur : **un guerrier ne peut devenir ni magicien ni archer-guerrier**. Cette interdiction ne doit pas être interprétée comme une interdiction générale de toute arme à distance pour toutes les classes ; les permissions concrètes restent à définir.

### Cohérence avec les règles antérieures
- Compatible avec une compagnie de quatre combattants actifs et des rangs R1 à R4 : la composition du groupe permet de combiner des rôles sans effacer l'identité de chaque classe.
- Compatible avec l'équipement et la progression individuelle déjà envisagés ; les anciennes hypothèses de multiclassage ou d'hybridation, si elles existent ailleurs dans le document, **ne prévalent pas** sur cette décision explicite.
- La progression collective ne doit pas être confondue avec une autorisation de changer de classe.

### Questions ouvertes, non validées
- Liste des classes et leurs rôles ; spécialisations autorisées et interdites ; règles d'équipement ; possibilité de réattribuer les compétences.
- Nature des améliorations collectives et articulation avec les bâtiments du refuge ; progression des héros absents d'une expédition.
- Équilibrage, implémentation et tests en jeu.

### Exécution et suivi
- **Réalisé :** intégration des deux décisions et de leurs limites au document maître.
- **Non réalisé :** implémentation, tests Godot et validation en partie.
- **Chantier : 🟡 À CONSOLIDER.** Avancement du chantier actuel : À évaluer. Avancement du projet global : À évaluer.


---
## V5.3 — Identité des héros et composition libre (17 novembre 2026)

### Décisions explicitement validées en conception
1. **Héros uniques :** chaque héros possède une identité, une classe et une histoire propres. Il ne s'agit pas de recrues génériques librement interchangeables.
2. **Personnalisation visuelle et tactique :** le joueur peut notamment modifier la couleur des vêtements de ses héros et sélectionner leurs compétences parmi les possibilités de leur arbre de compétences. Ces choix ne remplacent pas leur identité narrative ou leur classe.
3. **Respect strict de l'identité de classe :** les choix de compétences et d'équipement restent limités par les règles de classe validées en V5.2 ; un guerrier ne devient ni magicien ni archer-guerrier. Les arbres, options cosmétiques et permissions précises restent à concevoir.
4. **Composition libre :** le joueur choisit librement les quatre combattants actifs parmi les héros disponibles, sans composition obligatoire imposée par le système.
5. **Expérimentation autonome :** le jeu doit permettre au joueur de tester par lui-même différentes compositions, d'en découvrir les forces et les faiblesses et d'en tirer ses propres conclusions. Ne pas transformer les recommandations de rôles en contraintes de sélection.

### Contrôle de cohérence
- Compatible avec la progression individuelle et les améliorations collectives (V5.2).
- Compatible avec les quatre combattants actifs et les rangs R1 à R4.
- La personnalisation d'un héros unique ne signifie ni création d'une nouvelle identité ni multiclassage.
- Les restrictions liées à des événements narratifs ou à l'indisponibilité réelle d'un héros ne sont pas tranchées ici ; ne pas les inventer comme exceptions déjà validées.

### Questions ouvertes, non validées
- Nombre et liste des héros uniques ; classes, arbres et spécialisations ; limites de la recoloration des vêtements.
- Accès aux héros, progression des héros non sélectionnés, gestion des blessures et indisponibilités.
- Outils éventuels pour comparer ou enregistrer des compositions sans imposer un groupe « optimal ».

### Exécution et suivi
- **Réalisé :** ajout documentaire des cinq décisions dans la V5.3 ; conservation du contenu antérieur.
- **Non réalisé :** modification du dépôt, test Godot, validation de gameplay ou d'interface.
- **Chantier : 🟡 À CONSOLIDER.** Avancement du chantier actuel : À évaluer. Avancement du projet global : À évaluer.


---
## V5.4 — Recrutement à la guilde et héros de réserve (17 novembre 2026)

### Décisions explicitement validées en conception
1. **Tableau de recrutement à la guilde :** un tableau de recrutement est placé à côté du tableau des quêtes. Il propose **quatre héros candidats au départ** ; l'offre de recrutement est renouvelée entre les quêtes. Les règles exactes de renouvellement (après acceptation, accomplissement ou abandon d'une quête) ne sont pas encore fixées.
2. **Salle des héros recrutés non actifs :** une salle dédiée accueille les héros recrutés qui ne participent pas à la quête / expédition en cours.
3. **Repos et activités des réservistes :** les héros non sélectionnés peuvent s'entraîner, récupérer de blessures, guérir de maladies, se reposer et se détendre. Effets, coûts, durées et conditions restent à concevoir.
4. **Composition libre maintenue :** quatre combattants actifs sont choisis librement parmi les héros recrutés et disponibles ; les réservistes ne remplacent pas automatiquement les actifs en expédition.

### Vérification de cohérence et interprétations à ne pas transformer en décisions
- La V5.3 impose des **héros uniques avec identité, classe et histoire propres**. Le tableau présente donc des candidats identifiables, et non des personnages génériques clonés ; les mécanismes de réapparition des candidats non recrutés restent ouverts.
- Les **quatre candidats affichés initialement** ne fixent ni la taille maximale du vivier de recrutement ni celle des réserves.
- Le terme « entre chaque quête » doit être précisé avant toute implémentation ; ne pas supposer qu'abandonner et relancer une quête permet de renouveler gratuitement les candidats.
- Les activités de réserve ne préjugent pas de la progression passive, de la vitesse de guérison ou d'une guérison automatique.

### Questions ouvertes
- Conditions de renouvellement de l'offre ; devenir des candidats non choisis ; recrutement payant ou non ; limites de capacité et éventuelle gestion des doublons.
- Fonctionnement de la salle des héros ; entraînement, soins, détente, récupération, temps du monde et améliorations du refuge.
- Disponibilité des héros blessés et conséquences de leur décès ; équilibre entre recrutement et difficulté.

### Exécution et suivi
- **Réalisé et vérifié :** ajout des décisions de conception à la V5.4, contenu antérieur conservé.
- **Non réalisé :** implémentation Godot, tests de recrutement, de soins ou d'interface.
- **Chantier : 🟡 À CONSOLIDER.** Avancement du chantier actuel : À évaluer. Avancement du projet global : À évaluer.


---
## V5.5 — Renouvellement du recrutement et capacité de la salle (17 novembre 2026)

### Décisions explicitement validées en conception
1. **Renouvellement après conclusion d’une quête :** le tableau de recrutement de la guilde renouvelle ses candidats après chaque quête terminée, qu’elle se conclue par une réussite ou un échec. Les quatre candidats proposés au départ et le positionnement du tableau à côté de celui des quêtes restent inchangés.
2. **Capacité extensible de la salle des héros :** la salle accueille un nombre initial limité de héros recrutés non actifs ; sa capacité peut augmenter grâce aux améliorations du refuge. La capacité chiffrée initiale et les paliers d’agrandissement ne sont pas encore définis.

### Vérification de cohérence
- Compatible avec les héros uniques (V5.3), la composition libre de quatre combattants et les activités des réservistes (V5.4).
- Compatible avec la reconstruction du refuge et sa progression permanente.
- La reprise d’une mission abandonnée conserve son état antérieur (V5.0) : les règles précises qui distinguent conclusion d’une quête, abandon temporaire et reprise restent à définir. Ne pas présumer qu’un simple aller-retour permet de renouveler gratuitement le tableau.
- Le renouvellement des candidats ne crée pas de doublons des héros uniques déjà recrutés ; devenir des candidats non choisis encore ouvert.

### Questions ouvertes, non validées
- Capacité initiale de la salle, coût et conditions des extensions ; recrutement lorsque la salle est pleine.
- Définition exacte de « quête terminée » face à la retraite et à la reprise ; fréquence et composition des offres ; devenir des candidats non recrutés.
- Classes et familles de héros, spécialisations, progression et équilibre du vivier.

### Exécution et suivi
- **Réalisé :** ajout des deux décisions de conception dans le document maître V5.5.
- **Non réalisé :** modification du jeu, validation d’interface ou tests Godot.
- **Chantier : 🟡 À CONSOLIDER.** Avancement du chantier actuel : À évaluer. Avancement du projet global : À évaluer.


---
## V5.6 — Familles de classes et branches de compétences (17 novembre 2026)

### Décisions explicitement validées en conception
1. **Grandes familles de classes :** les classes sont organisées en familles, notamment guerriers, combattants à distance, utilisateurs de magie et autres familles spécialisées. Plusieurs classes distinctes peuvent appartenir à une même famille. La liste exhaustive n'est pas encore validée.
2. **Plusieurs branches par classe :** chaque classe dispose de plusieurs branches de spécialisation. Les choix de compétences et d'équipement personnalisent son style sans effacer ses capacités et limites fondamentales. Les restrictions de la V5.2 restent applicables : un guerrier ne devient ni magicien ni archer-guerrier.

### Étude comparative externe — éléments de référence, non décisions
- **Diablo IV (site officiel Blizzard, consulté le 17 novembre 2026) :** identités de classes fortes et variantes de compétences, avec des styles distincts au sein d'une classe. Source : https://diablo4.blizzard.com/fr-fr/lord-of-hatred et https://diablo4.blizzard.com/fr-fr/
- **Path of Exile (documentation officielle Grinding Gear Games) :** vaste arbre de passifs, gemmes de compétences et classes d'Ascendance ; la grande liberté de combinaison peut augmenter la complexité de lecture et d'équilibrage. Sources : https://fr.pathofexile.com/forum/view-thread/13460 et https://www.pathofexile.com/forum/view-thread/3721171
- **Recommandation non validée :** combiner des branches lisibles et propres à chaque classe avec des synergies profondes entre les quatre héros, leurs équipements, rangs, afflictions et ciblages anatomiques. Ne pas adopter par défaut l'arbre global de Path of Exile.

### Cohérence avec les décisions antérieures
- Compatible avec les héros uniques (V5.3), leur choix de compétences, la composition libre de quatre combattants et la progression individuelle/collective (V5.2).
- Le regroupement en familles sert à organiser les classes, pas à autoriser le multiclassage.
- Les nombres de branches, compétences, points, réinitialisations et limites d'équipement restent ouverts.

### Questions ouvertes
- Organisation concrète des branches : styles distincts, arbre commun avec embranchements, ou solution hybride.
- Choix des compétences actives/passives, interactions entre branches, spécialisation réversible ou non.
- Liste des familles et classes, et critères de diversité des quatre héros.

### Exécution et suivi
- **Réalisé :** décisions intégrées au document maître V5.6 et comparaison de sources officielles.
- **Non réalisé :** modification du jeu, tests Godot ou équilibrage.
- **Chantier : 🟡 À CONSOLIDER.** Avancement du chantier actuel : À évaluer. Avancement du projet global : À évaluer.


---
## V5.7 — Orientation d’accessibilité des arbres de compétences (17 novembre 2026)

### Orientation explicitement retenue
- **Diablo comme référence principale de lisibilité :** privilégier des arbres de compétences digestes pour les joueurs peu expérimentés, sans sacrifier la profondeur attendue par les joueurs exigeants.
- **Profondeur tactique plutôt que complexité visuelle :** rechercher des choix significatifs et des synergies entre compétences, équipement, positions, afflictions et membres de la compagnie. Cette traduction en mécanismes précis est une **proposition de conception**, non une liste de mécaniques nouvellement validées.
- **Identité des classes préservée :** les branches restent propres aux classes et n'autorisent pas un guerrier à devenir magicien ou archer-guerrier (V5.2 et V5.6).

### Points ouverts
- Structure exacte de l'arbre (tronc commun, branches indépendantes, hybride), nombre de branches, points, compétences actives/passives et éventuelle réinitialisation.
- Tests d'utilisabilité auprès de débutants et de joueurs expérimentés : non réalisés.

### Exécution et suivi
- **Réalisé et vérifié :** orientation ajoutée au document maître V5.7, texte de V5.6 conservé.
- **Non réalisé :** implémentation, prototype ou validation par tests utilisateurs.
- **Chantier : 🟡 À CONSOLIDER.** Avancement du chantier actuel : À évaluer. Avancement du projet global : À évaluer.


---
## V5.8 — Branches accessibles dès le départ et styles distincts (17 novembre 2026)

### Décisions explicitement validées en conception
1. **Branches accessibles dès le départ :** chaque classe présente ses différentes branches de spécialisation dès le début, sans imposer un tronc commun obligatoire préalable pour choisir une branche.
2. **Gameplay différencié :** chaque branche doit proposer une manière de jouer réellement distincte, et non seulement une variation de valeurs statistiques.
3. **Identité de classe intangible :** toute spécialisation reste dans les limites de la classe du héros ; un guerrier ne peut pas devenir magicien ni archer-guerrier.
4. **Lisibilité :** la structure doit rester accessible aux joueurs débutants, en conservant Diablo comme référence principale de lisibilité et une profondeur pour les joueurs exigeants.

### Interprétation et cohérence
- L'accès immédiat aux branches **n'implique pas** que toutes leurs compétences soient débloquées immédiatement : la progression interne demeure à définir.
- Compatible avec les grandes familles de classes et plusieurs branches par classe (V5.6), les héros uniques et leur personnalisation (V5.3), ainsi que la progression hybride (V5.2).
- Des exemples de branches guerrières (protection, offensive, contrôle) sont **illustratifs et non validés**.

### Questions ouvertes, non validées
- Possibilité et limites de répartir des points dans plusieurs branches d'une même classe.
- Déblocage des compétences au sein des branches ; compétences actives/passives ; réinitialisation des choix.
- Nombre de branches par classe et mécanismes distinctifs de chaque branche.

### Exécution et suivi
- **Réalisé :** ajout des décisions au document maître V5.8.
- **Non réalisé :** implémentation, tests Godot, tests d'utilisabilité et équilibrage.
- **Chantier : 🟡 À CONSOLIDER.** Avancement du chantier actuel : À évaluer. Avancement du projet global : À évaluer.


---
## V5.9 — Spécialisation exclusive en première partie et mélange des branches en NG+ (17 novembre 2026)

### Décisions explicitement validées en conception
1. **Première partie : spécialisation exclusive.** Chaque héros choisit une seule branche de spécialisation de sa classe ; il ne combine pas les compétences de plusieurs branches pendant la première partie.
2. **New Game Plus (NG+) : mélange autorisé.** Le joueur peut alors combiner des branches de compétences appartenant à la même classe du héros.
3. **Identité de classe conservée.** Le NG+ ne permet pas le multiclassage hors classe : un guerrier ne devient ni magicien ni archer-guerrier.
4. **Branches visibles et accessibles dès le départ.** Le choix de la branche n'exige pas de tronc commun préalable ; l'accès à toutes les compétences de cette branche reste progressif, à définir.

### Cohérence avec les décisions antérieures
- Compatible avec V5.2 (classes strictes), V5.3 (personnalisation de héros uniques), V5.6 (plusieurs branches par classe), V5.7 (lisibilité inspirée de Diablo) et V5.8 (branches immédiatement accessibles, gameplay distinct).
- La liberté accrue du NG+ apporte de la profondeur après la première partie, sans supprimer l'identité tactique des classes.

### Points ouverts, non validés
- La spécialisation peut-elle être changée durant la première partie, et si oui à quelles conditions ?
- Quelles compétences, niveaux, équipements et ressources sont conservés au passage en NG+ ?
- Comment se répartissent les points entre branches en NG+ et quelles restrictions d'équilibrage s'appliquent ?
- Les seuils et modalités d'accès au NG+ restent à définir.

### Exécution et suivi
- **Réalisé et vérifié :** intégration des décisions de conception dans la V5.9, contenu V5.8 conservé.
- **Non réalisé :** implémentation du NG+, tests Godot, tests d'utilisabilité ou équilibrage.
- **Chantier : 🟡 À CONSOLIDER.** Avancement du chantier actuel : À évaluer. Avancement du projet global : À évaluer.


---
## V6.0 — Spécialisation définitive avant NG+ et diversité de la compagnie (17 novembre 2026)

### Décisions explicitement validées en conception
1. **Spécialisation irréversible durant la première partie :** chaque héros choisit une branche de sa classe et ne peut pas en changer avant le NG+. Il ne peut pas non plus mélanger plusieurs branches durant cette première partie.
2. **Liberté supplémentaire en NG+ :** le mélange des branches devient possible dans les limites de la classe du héros, conformément à la V5.9.
3. **Intention de conception :** cette exclusivité encourage le joueur à recruter d'autres héros et à explorer les possibilités de la capture pour découvrir d'autres façons de jouer, tout en renforçant l'attachement aux héros et leur identité.

### Vérification de cohérence
- Compatible avec la progression hybride et les classes strictes (V5.2), les héros uniques (V5.3), le recrutement à la guilde (V5.4–V5.5), les branches distinctes (V5.6–V5.8) et le NG+ (V5.9).
- **Distinction importante :** le rôle exact des créatures capturées, leurs compétences et leurs éventuelles branches ne sont pas définis par cette décision. La capture ne vaut pas automatiquement recrutement d'un héros humain.
- Le renouvellement du recrutement doit continuer à respecter l'unicité des héros ; il ne permet pas de dupliquer un héros déjà recruté pour contourner la spécialisation exclusive.

### Questions ouvertes, non validées
- Moment précis du choix irréversible (recrutement, premier point investi ou autre étape).
- Visibilité préalable des compétences et informations nécessaires à un choix éclairé.
- Fonctionnement exact de la capture et des spécialisations éventuelles des créatures.
- Modalités détaillées de répartition des compétences en NG+.

### Exécution et suivi
- **Réalisé :** ajout des décisions et distinctions à la V6.0 du document maître.
- **Non réalisé :** implémentation, tests Godot, tests d'utilisabilité et équilibrage.
- **Chantier : 🟡 À CONSOLIDER.** Avancement du chantier actuel : À évaluer. Avancement du projet global : À évaluer.


---
## V6.1 — Choix de spécialisation au premier investissement (17 novembre 2026)

### Décisions explicitement validées en conception
1. **Moment du choix irréversible :** le héros choisit sa branche de spécialisation au moment où le joueur investit son premier point de compétence dans cette branche. Avant ce premier investissement, aucune branche n'est verrouillée.
2. **Présentation des branches :** chaque arbre/branche comporte un **court texte explicatif** permettant au joueur de comprendre le style de jeu proposé avant de s'engager.
3. **Maintien des décisions antérieures :** durant la première partie, le héros développe exclusivement la branche choisie et ne peut pas en changer ; le NG+ autorise le mélange de branches dans les limites de la même classe.

### Cohérence vérifiée avec le document maître
- Compatible avec les branches accessibles dès le départ (V5.8), la spécialisation exclusive et le mélange en NG+ (V5.9), ainsi que l'irréversibilité avant NG+ (V6.0).
- L'accès aux branches dès le départ ne signifie pas que toutes les compétences de chaque branche sont immédiatement débloquées.
- L'existence de textes explicatifs n'implique pas la validation de leur rédaction exacte, de leur interface ou de leur efficacité auprès des joueurs.

### Points ouverts, non validés
- Contenu précis des textes de présentation, éventuel aperçu des compétences et confirmation avant dépense du premier point.
- Acquisition et dépense des points de compétence, seuils de progression et structure détaillée des branches.
- Modalités techniques et équilibrage du mélange des branches en NG+.

### Exécution et suivi
- **Réalisé :** ajout de cette décision à la V6.1, en conservant le texte de la V6.0.
- **Non réalisé :** implémentation, tests Godot, tests d'utilisabilité et équilibrage.
- **Chantier : 🟡 À CONSOLIDER.** Avancement du chantier actuel : À évaluer. Avancement du projet global : À évaluer.


---
## V6.2 — Acquisition hybride et compétences à degrés d’évolution (17 novembre 2026)

### Décisions explicitement validées en conception
1. **Acquisition hybride des points :** la montée en niveau accorde des points de compétence ; certains défis ou accomplissements peuvent apporter des améliorations complémentaires. La nature précise de ces récompenses reste à définir.
2. **Profondeur plutôt que quantité :** privilégier un ensemble resserré de compétences, chacune dotée de plusieurs degrés d'évolution, plutôt qu'une accumulation de capacités distinctes.
3. **Identité des branches :** chaque branche conserve un gameplay différent au sein de sa classe ; la spécialisation exclusive en première partie et le mélange en NG+ restent applicables.

### Cible proposée par l'utilisateur, à confirmer avant verrouillage numérique
- Environ **15 compétences par classe**, avec une structure illustrative de **3 branches de 5 compétences**. L'utilisateur formule cette quantité comme une intention approximative (« une quinzaine ») ; elle n'est pas encore une contrainte numérique figée.
- Les degrés d'évolution d'une compétence doivent permettre des améliorations progressives ; nombre de degrés, effets exacts, coûts et éventuels choix mutuellement exclusifs non définis.

### Étude comparative externe (sources consultées le 17 novembre 2026 ; références, pas décisions de LITD 1)
- **Diablo IV**, annonces officielles Blizzard sur les arbres de compétences et leur refonte 2026 : rangs de compétences, branches de modificateurs et variantes ayant un impact sur le gameplay. https://news.blizzard.com/en-us/article/24267729/prepare-for-the-reckoning-lord-of-hatred-draws-near ; https://news.xbox.com/en-us/2026/04/22/diablo-4-skill-tree-overhaul/
- **Last Epoch**, documentation officielle : jusqu'à cinq compétences spécialisées, chacune avec son arbre de progression ; les nœuds peuvent améliorer ou transformer les capacités. https://support.lastepoch.com/hc/en-us/articles/46363203944859-Skill-Specialization ; https://lastepoch.com/skills/
- **Analyse/recommandation, non validée :** prendre Diablo IV pour la lisibilité des rangs et modificateurs, et Last Epoch comme référence secondaire pour les évolutions qualitatives des compétences ; éviter de reproduire sa complexité globale.

### Cohérence et limites
- Compatible avec la progression hybride des héros (V5.2), la structure des branches (V5.8), l'exclusivité initiale puis le NG+ (V5.9), le verrouillage au premier investissement (V6.1).
- Attention à la distinction entre **15 compétences disponibles dans la classe** et **5 accessibles dans la branche choisie en première partie** ; l'équipement simultané de compétences et le nombre de points d'action restent des questions distinctes.
- La formule exacte d'attribution des points, la nature des défis récompensés et le fonctionnement des degrés d'évolution restent à arbitrer.

### Exécution et suivi
- **Réalisé :** décisions et étude comparative ajoutées au document maître V6.2.
- **Non réalisé :** conception détaillée des compétences, implémentation, tests Godot, équilibrage et tests joueurs.
- **Chantier : 🟡 À CONSOLIDER.** Avancement du chantier actuel : À évaluer. Avancement du projet global : À évaluer.


---
## V6.3 — Degrés d’évolution et choix tactiques des compétences (17 novembre 2026)

### Décision explicitement validée en conception
1. **Évolution hybride des compétences :** chaque compétence gagne progressivement en efficacité grâce à des degrés d’évolution et propose, à certaines étapes, des choix tactiques qui modifient son utilisation, ses effets ou ses interactions avec les autres compétences.
2. **Profondeur sans inflation :** ces variations appartiennent à la compétence existante, sans imposer la création d’une nouvelle compétence distincte pour chaque évolution.
3. **Cadre préservé :** branches distinctes, spécialisation exclusive jusqu’au NG+, combinaison de branches de même classe en NG+, choix irréversible de branche au premier investissement.

### Vérification de cohérence
- Compatible avec l’acquisition hybride des points et les compétences à degrés (V6.2), la lisibilité inspirée de Diablo (V5.7), les branches à gameplay différencié (V5.8), le NG+ (V5.9) et le choix irréversible (V6.0–V6.1).
- **À ne pas confondre :** les degrés de puissance et les choix tactiques ne sont pas nécessairement deux monnaies de progression distinctes.
- Les quinze compétences environ par classe et les cinq par branche restent une **cible indicative**, non un nombre définitivement validé.

### Questions ouvertes, non validées
- Les choix tactiques sont-ils exclusifs ou cumulables au sein d’une compétence ?
- Un choix tactique est-il réversible sans changer de branche ?
- Nombre de degrés, seuils, coûts, fréquence des choix et limites d’équilibrage.
- Répartition entre compétences actives et passives, et nombre de compétences équipables.

### Exécution et suivi
- **Réalisé et vérifié :** ajout de la décision à la V6.3 ; texte antérieur conservé, hormis la mise à jour de l’en-tête de version.
- **Non réalisé :** implémentation, tests Godot, équilibrage et tests utilisateurs.
- **Chantier : 🟡 À CONSOLIDER.** Avancement du chantier actuel : À évaluer. Avancement du projet global : À évaluer.


---
## V6.4 — Évolutions mixtes et sélection des compétences (17 novembre 2026)

### Décisions explicitement validées en conception
1. **Évolutions mixtes :** les améliorations de base d’une compétence peuvent se cumuler ; les évolutions tactiques majeures sont soumises à des choix exclusifs.
2. **Structure de référence précisée :** cinq compétences par branche de spécialisation, dont quatre peuvent être sélectionnées pour le combat. La cinquième n’est pas équipée simultanément. Cette règle s’applique au cadre de première partie à branche unique ; l’articulation avec le NG+ reste à définir.
3. **Choix tactique d’équipement :** le joueur choisit quatre compétences parmi les cinq disponibles dans sa branche ; le nombre de points d’action par tour reste une règle distincte.
4. **Identité de classe :** les évolutions et choix d’équipement ne permettent pas de sortir de la classe du héros.

### Ambiguïté explicitement conservée, décision en attente
L’expression de l’utilisateur « nous ne pourrons choisir qu’une évolution de compétence » n’indique pas encore si :
- chaque compétence peut recevoir **une évolution tactique majeure** ; ou
- chaque héros ne peut sélectionner **qu’une seule évolution tactique majeure au total**.
Ne pas présenter l’une de ces interprétations comme validée avant clarification.

### Cohérence et limites
- Compatible avec la spécialisation exclusive en première partie, la progression par degrés, la lisibilité inspirée de Diablo et le recrutement pour découvrir d’autres branches.
- L’utilisation de quatre compétences en combat ne signifie pas quatre actions par tour : la règle du point d’action reste distincte.
- À préciser : choix de l’évolution majeure, réversibilité éventuelle, fonctionnement en NG+, répartition actif/passif, nombre de degrés et coûts.

### Exécution et suivi
- **Réalisé :** intégration documentaire des décisions explicites et de l’ambiguïté restant à trancher.
- **Non réalisé :** implémentation, tests Godot, équilibrage et tests joueurs.
- **Chantier : 🟡 À CONSOLIDER.** Avancement du chantier actuel : À évaluer. Avancement du projet global : À évaluer.


---
## V6.5 — Une évolution tactique majeure par compétence (17 novembre 2026)

### Décision explicitement validée en conception
1. **Une seule évolution tactique majeure par compétence :** chaque compétence peut recevoir au maximum une évolution tactique majeure choisie parmi des variantes mutuellement exclusives. Cette limite s’applique à chaque compétence individuellement, **pas à l’ensemble du héros**.
2. **Améliorations cumulables :** les degrés et améliorations progressives de base restent cumulables, selon les modalités qui seront définies ultérieurement.
3. **Équipement de combat inchangé :** cinq compétences par branche, quatre sélectionnables simultanément en première partie. La limite d’évolution majeure ne modifie ni le nombre de compétences équipables ni le nombre de points d’action.
4. **Spécialisation inchangée :** branche exclusive à partir du premier investissement durant la première partie ; combinaison de branches de même classe possible en NG+.

### Vérification de cohérence
- **Ambiguïté de V6.4 résolue :** « une évolution » signifie une par compétence, et non une par héros. La section V6.4 est conservée à titre historique ; son statut « en attente » sur ce seul point est remplacé par la présente validation.
- Cohérent avec les évolutions mixtes (V6.4), les degrés et choix tactiques (V6.3), et le principe de profondeur plutôt que multiplication des compétences (V6.2).
- Une évolution majeure n’est pas une compétence supplémentaire ni une action supplémentaire.

### Points non décidés
- Réversibilité ou remplacement de l’évolution majeure choisie, sans changer de spécialisation.
- Nombre et nature des variantes proposées pour chaque compétence ; seuils, coûts et nombre de degrés.
- Règles d’équipement et de progression en NG+, répartition des compétences actives et passives.

### Exécution et suivi
- **Réalisé et vérifié :** intégration de la décision dans le document maître V6.5 ; conservation des sections antérieures.
- **Non réalisé :** implémentation Godot, tests en jeu, équilibrage et validation par playtest.
- **Chantier : 🟡 À CONSOLIDER.** Avancement du chantier actuel : À évaluer. Avancement du projet global : À évaluer.


---
## V6.6 — Modification de l’évolution tactique majeure au refuge (17 novembre 2026)

### Décision explicitement validée en conception
1. **Réversibilité au refuge :** le joueur peut remplacer l’évolution tactique majeure choisie pour une compétence lorsqu’il se trouve au refuge.
2. **Une évolution majeure active par compétence :** le remplacement ne permet jamais de cumuler simultanément plusieurs variantes majeures sur la même compétence. Les améliorations de base cumulables restent distinctes.
3. **Spécialisation verrouillée :** changer la variante majeure d’une compétence ne permet pas de changer de branche de spécialisation pendant la première partie ; cette branche reste verrouillée dès le premier point investi, jusqu’au NG+.
4. **Équipement de combat inchangé :** cinq compétences par branche, dont quatre sélectionnables simultanément en première partie ; une évolution tactique ne crée ni une cinquième compétence équipée ni un point d’action supplémentaire.

### Vérification de cohérence
- **Question ouverte en V6.5 résolue :** la réversibilité des évolutions majeures est autorisée au refuge ; les questions historiques correspondantes des versions antérieures sont dépassées sur ce point précis.
- Cette souplesse autorise des ajustements tactiques sans effacer l’identité durable du héros, liée à sa classe et à sa branche.
- La décision ne valide **aucun coût**, aucune restriction de fréquence ni aucun bâtiment préalable : ces paramètres restent à définir, sans les présumer.

### Points non décidés
- Conditions pratiques du remplacement au refuge : libre et gratuit ou soumis à des ressources, délais ou installations.
- Répartition des cinq compétences entre actives et passives, et signification exacte des quatre emplacements de combat.
- Nombre de degrés, seuils et variantes majeures ; modalités NG+ d’équipement lorsque plusieurs branches sont accessibles.

### Exécution et suivi
- **Réalisé :** intégration de la décision dans la V6.6 en conservant les sections historiques.
- **Non réalisé :** implémentation Godot, test en jeu, équilibrage et playtest.
- **Chantier : 🟡 À CONSOLIDER.** Avancement du chantier actuel : À évaluer. Avancement du projet global : À évaluer.


---
## V6.7 — Cinq compétences de nature mixte (17 novembre 2026)

### Décision explicitement validée en conception
1. **Nature mixte :** chacune des branches de spécialisation comprend cinq compétences pouvant être de nature active ou passive ; la répartition exacte n'est pas imposée uniformément à toutes les branches.
2. **Choix d'équipement maintenu :** le principe antérieur de quatre compétences sélectionnables parmi les cinq est conservé. Les règles spécifiques d'activation, d'équipement et de comptabilisation des passives dans ces quatre emplacements **ne sont pas encore décidées**.
3. **Progression maintenue :** degrés d'amélioration cumulables et, au maximum, une évolution tactique majeure active par compétence, remplaçable au refuge. Les adaptations nécessaires pour une compétence passive restent à concevoir.
4. **Spécialisation maintenue :** premier point investi = verrouillage de la branche en première partie ; mélange de branches d'une même classe possible en NG+.

### Vérification de cohérence
- Compatible avec les décisions V6.2 à V6.6 : une branche reste limitée à cinq compétences, sans multiplication incontrôlée de capacités.
- Le caractère passif d'une compétence ne lui attribue pas automatiquement un emplacement gratuit, un effet permanent hors équipement ou une action de combat : ces points sont ouverts.
- Les quatre compétences sélectionnables ne modifient pas la règle d'un point d'action par combattant et par tour.
- La section V6.6 qui mentionnait « répartition des cinq compétences entre actives et passives » comme entièrement ouverte est désormais dépassée **uniquement sur le principe de nature mixte** ; les quantités et les règles d'emplacement restent ouvertes.

### Points à décider ultérieurement
- Les passives occupent-elles un des quatre emplacements de combat, un emplacement séparé, ou sont-elles actives automatiquement après acquisition ?
- Quelles limites évitent le cumul excessif de passives, notamment en NG+ ?
- Répartition active/passive par branche, règles d'activation et d'amélioration des passives, coût du remplacement des évolutions au refuge.

### Exécution et suivi
- **Réalisé :** intégration de la décision validée et conservation des sections antérieures.
- **Non réalisé :** implémentation Godot, tests en jeu, équilibrage et playtests.
- **Chantier : 🟡 À CONSOLIDER.** Avancement du chantier actuel : À évaluer. Avancement du projet global : À évaluer.


---
## V6.8 — Emplacements distincts pour compétences actives et passives (17 novembre 2026)

### Décision explicitement validée en conception
1. **Emplacements séparés :** les compétences actives et les compétences passives disposent de catégories d’emplacements distinctes ; une passive équipée n’occupe pas l’un des emplacements réservés aux compétences actives.
2. **Capacité active :** la limite de quatre emplacements de combat précédemment retenue s’applique aux compétences actives. Il s’agit d’un maximum d’emplacements, et non de l’obligation de posséder quatre compétences actives dans chacune des branches.
3. **Passifs limités :** les compétences passives disposent d’un nombre limité d’emplacements supplémentaires. Leur nombre exact n’est pas validé et reste à décider.
4. **Cinq compétences mixtes par branche :** les cinq compétences de chaque branche peuvent être actives ou passives, sans ratio imposé à ce stade. Les degrés, l’évolution tactique majeure unique par compétence, son remplacement au refuge et le verrouillage de branche jusqu’au NG+ restent applicables.

### Contrôle de cohérence et précision
- La règle V6.7 laissant ouverte l’occupation des emplacements par les passives est désormais tranchée : les emplacements sont séparés.
- Le principe historique « quatre compétences parmi cinq » se lit désormais, pour l’équipement actif, comme **jusqu’à quatre compétences actives** parmi celles disponibles ; le nombre d’emplacements passifs doit encore être fixé. Ce changement de formulation est une conséquence logique de la décision, et non une nouvelle validation de quantité.
- Une branche comprenant des passives peut proposer moins de quatre compétences actives. La variété effective des actions doit être évaluée lors de la conception des branches, sans inventer de compétences supplémentaires.
- Aucune compétence équipée n’ajoute de point d’action : la règle d’un point d’action par unité et par tour demeure.

### Questions ouvertes (non validées)
- Nombre d’emplacements passifs, fixes ou évolutifs ; effets des améliorations du refuge et du NG+.
- Les passives non équipées sont-elles entièrement inactives ? Conditions exactes de changement d’équipement actif et passif.
- Nombre minimal de compétences actives par branche et disponibilité éventuelle d’actions communes à la classe.
- Coût et modalités pratiques de remplacement des évolutions majeures au refuge.

### Exécution et suivi
- **Réalisé et vérifié :** ajout documentaire V6.8, conservation du contenu V6.7 et de l’historique.
- **Non réalisé :** modification du jeu, tests Godot, équilibrage et playtests.
- **Chantier : 🟡 À CONSOLIDER.** Avancement du chantier actuel : À évaluer. Avancement du projet global : À évaluer.


---
## V6.9 — Déblocage progressif des emplacements passifs (17 novembre 2026)

### Décision explicitement validée en conception
1. **Emplacements passifs progressifs :** le héros commence avec **un emplacement passif** et peut en débloquer d’autres au cours de sa progression.
2. **Séparation maintenue :** ces emplacements ne remplacent ni ne consomment les quatre emplacements actifs maximum définis en V6.8.
3. **Limitation maintenue :** les passives ne deviennent pas automatiquement toutes actives ; leur équipement reste soumis au nombre d’emplacements passifs disponibles.

### Contrôle de cohérence
- Cette décision précise le caractère évolutif du nombre d’emplacements, resté ouvert en V6.8, sans changer les cinq compétences de nature mixte par branche.
- Le déblocage progressif peut renforcer le sentiment de progression tout en limitant l’accumulation initiale de bonus ; le risque de cumul en NG+ devra être testé et équilibré.
- Le verrouillage de branche au premier point investi, la possibilité de mélanger les branches en NG+ et la réversibilité des évolutions tactiques majeures au refuge restent inchangés.
- La règle d’un point d’action par combattant et par tour reste inchangée.

### Paramètres non validés
- Nombre maximal d’emplacements passifs ; étapes et conditions de déblocage (niveaux, accomplissements, refuge ou autre).
- Possibilité de modifier l’équipement passif en expédition ou uniquement au refuge.
- Nombre minimal de compétences actives par branche, règles exactes des passives en NG+ et équilibrage des cumuls.

### Exécution et suivi
- **Réalisé et vérifié :** inscription de la décision en V6.9 et conservation du contenu de V6.8.
- **Non réalisé :** implémentation Godot, tests en jeu, équilibrage et playtests.
- **Chantier : 🟡 À CONSOLIDER.** Avancement du chantier actuel : À évaluer. Avancement du projet global : À évaluer.


---
## V7.0 — Plafond et occupation pondérée des emplacements passifs (17 novembre 2026)

### Décisions explicitement validées en conception
1. **Plafond : cinq emplacements passifs maximum par héros.** Cette décision remplace la proposition antérieure de trois emplacements en première partie et quatre en NG+ ; ce plafond de cinq ne dépend pas du NG+.
2. **Occupation variable :** les compétences passives les plus puissantes peuvent occuper plusieurs emplacements passifs, au lieu d'un seul. La somme des emplacements occupés ne peut dépasser la capacité actuellement débloquée.
3. **Progression préservée :** chaque héros commence avec un emplacement passif et débloque progressivement les autres, dans la limite de cinq.
4. **Séparation préservée :** les emplacements passifs restent indépendants des quatre emplacements actifs maximum.

### Contrôle de cohérence
- Compatible avec les cinq compétences de nature mixte par branche : la capacité maximale n'impose pas cinq compétences passives simultanées.
- Compatible avec le verrouillage de spécialisation jusqu'au NG+ et le mélange des branches de la même classe en NG+.
- L'occupation pondérée limite théoriquement l'accumulation de passifs puissants ; l'efficacité réelle de cet équilibrage reste à tester.
- Les quatre emplacements actifs ne donnent pas quatre points d'action : un point d'action par combattant et par tour reste la règle.

### Paramètres non validés
- Barème précis d'occupation des passifs (un, deux, trois emplacements ou autres), critères de puissance et exceptions.
- Conditions et rythme de déblocage des quatre emplacements supplémentaires.
- Lieu et coût éventuel du changement de passifs équipés.
- Nombre de passifs disponibles par branche, compatibilité des passifs entre eux et équilibrage en NG+.

### Exécution et suivi
- **Réalisé :** modification documentaire V7.0 et vérification de conservation intégrale de V6.9.
- **Non réalisé :** implémentation, test Godot, équilibrage et playtests.
- **Chantier : 🟡 À CONSOLIDER.** Avancement du chantier actuel : À évaluer. Avancement du projet global : À évaluer.


---
## V7.1 — Déblocage hybride des emplacements passifs (17 novembre 2026)

### Décision explicitement validée en conception
1. **Déblocage hybride :** les emplacements passifs supplémentaires s'obtiennent par une combinaison de **montées de niveau du héros** et de **défis ou accomplissements**.
2. **Règles préservées :** chaque héros commence avec un emplacement passif et peut en débloquer progressivement jusqu'à **cinq maximum**. Les passifs puissants peuvent consommer plusieurs emplacements ; les quatre emplacements actifs restent séparés.
3. **Distinction des ressources :** les points de compétence et les capacités d'emplacements passifs sont distincts ; la montée de niveau ne donne pas automatiquement un emplacement à chaque niveau.

### Contrôle de cohérence avec V7.0
- La nouvelle décision précise les conditions générales de déblocage laissées ouvertes en V7.0, sans modifier le plafond ni l'occupation pondérée.
- La progression hybride des points de compétence et celle des emplacements passifs sont compatibles mais ne sont pas confondues.
- La spécialisation verrouillée jusqu'au NG+ et le mélange de branches d'une même classe en NG+ restent inchangés.
- L'équilibrage de la fréquence de déblocage et de la disponibilité des passifs doit être testé ultérieurement.

### Questions ouvertes (non validées)
- Répartition des quatre déblocages supplémentaires entre niveaux et accomplissements, ainsi que les seuils et défis exacts.
- Barème de coût en emplacements des différents passifs.
- Conditions de changement des passifs équipés, compatibilités et équilibrage en NG+.

### Exécution et suivi
- **Réalisé :** ajout documentaire V7.1 et contrôle de conservation du texte V7.0.
- **Non réalisé :** implémentation Godot, tests en jeu, équilibrage et playtests.
- **Chantier : 🟡 À CONSOLIDER.** Avancement du chantier actuel : À évaluer. Avancement du projet global : À évaluer.


---
## V7.2 — Répartition des déblocages passifs (17 novembre 2026)

### Décision explicitement validée en conception
1. **Deux emplacements passifs supplémentaires sont débloqués par la progression en niveaux du héros.**
2. **Deux autres emplacements passifs supplémentaires sont débloqués par des accomplissements ou défis.**
3. Le héros dispose initialement d'**un emplacement passif** ; la répartition **1 initial + 2 niveaux + 2 accomplissements = 5 emplacements maximum** respecte le plafond V7.0 et le principe hybride V7.1.

### Contrôle de cohérence avec V7.1
- Les points de compétence restent distincts des emplacements passifs ; aucun gain automatique à chaque niveau n'est impliqué.
- Les passifs puissants peuvent toujours occuper plusieurs emplacements ; les quatre emplacements actifs sont indépendants.
- Le verrouillage de la spécialisation jusqu'au NG+ et la possibilité de mélanger les branches d'une même classe en NG+ sont inchangés.
- La disponibilité réelle des passifs et le rythme d'accès aux cinq emplacements nécessiteront un équilibrage ultérieur.

### Questions ouvertes (non validées)
- Niveaux précis donnant accès aux deux emplacements liés à l'expérience.
- Nature et difficulté des deux accomplissements, leur caractère propre au héros ou commun à la compagnie, et leur rattrapage pour les recrues tardives.
- Coût en emplacements des passifs, modalités de changement des passifs équipés et équilibrage NG+.

### Exécution et suivi
- **Réalisé :** ajout documentaire de la décision V7.2 ; conservation du texte historique V7.1 vérifiée.
- **Non réalisé :** implémentation Godot, tests en jeu, équilibrage et playtests.
- **Chantier : 🟡 À CONSOLIDER.** Avancement du chantier actuel : À évaluer. Avancement du projet global : À évaluer.


---
## V7.3 — Nature des deux accomplissements ouvrant des emplacements passifs (17 novembre 2026)

### Décision explicitement validée en conception
1. Parmi les deux emplacements passifs supplémentaires liés aux accomplissements (V7.2), **un est associé à un défi individuel du héros**.
2. **L’autre est associé à un accomplissement collectif de la compagnie**.
3. La répartition reste **1 emplacement initial + 2 débloqués par niveaux + 1 par défi individuel + 1 par accomplissement collectif = 5 emplacements passifs maximum**.

### Contrôle de cohérence avec V7.2
- La progression demeure hybride, individuelle et collective, sans confondre points de compétence et emplacements passifs.
- Les emplacements actifs restent indépendants ; les passifs puissants peuvent occuper plusieurs emplacements.
- Les spécialisations sont exclusives pendant la première partie ; le mélange intraclasse en NG+ reste autorisé.
- Cette décision ne définit **ni le défi exact, ni l’accomplissement collectif exact, ni les modalités d’attribution aux héros recrutés après sa réalisation**.

### Questions ouvertes (non validées)
- L’accomplissement collectif donne-t-il immédiatement l’emplacement à tous les héros présents et futurs, ou nécessite-t-il une activation individuelle ?
- Conditions et difficulté du défi individuel, notamment pour les recrues tardives.
- Niveaux exacts des deux déblocages, coût des passifs en emplacements, règles de changement d’équipement et équilibrage NG+.

### Exécution et suivi
- **Réalisé :** mise à jour documentaire V7.3 et contrôle de conservation du contenu de V7.2.
- **Non réalisé :** implémentation Godot, tests en jeu, équilibrage et playtests.
- **Chantier : 🟡 À CONSOLIDER.** Avancement du chantier actuel : À évaluer. Avancement du projet global : À évaluer.


---
## V7.4 — Attribution collective automatique et progression personnelle des recrues (17 novembre 2026)

### Décisions explicitement validées en conception
1. L'emplacement passif lié à l'accomplissement collectif est attribué automatiquement à tous les héros, y compris ceux recrutés après l'obtention de cet accomplissement par la compagnie. L'accomplissement collectif demeure acquis pour la compagnie.
2. Pour débloquer les autres emplacements supplémentaires, il faut **jouer avec le héros concerné** : les deux emplacements liés à ses niveaux et celui lié à son défi individuel relèvent de sa progression personnelle, et ne sont pas automatiquement octroyés par les exploits des autres héros.
3. La répartition demeure **1 emplacement initial + 2 par niveaux personnels + 1 par défi individuel + 1 collectif automatique = 5 maximum**.

### Vérification de cohérence avec V7.3
- Compatible avec la progression hybride, la personnalisation des héros et l'importance du recrutement.
- Les quatre emplacements actifs restent séparés et les passifs puissants peuvent occuper plusieurs emplacements.
- Le choix exclusif de spécialisation avant NG+ et les combinaisons intraclasse en NG+ sont inchangés.
- L'accomplissement collectif ne remplace pas la progression personnelle du héros.

### Questions ouvertes (non validées)
- Comment les recrues arrivant avec un niveau initial élevé obtiennent-elles les emplacements liés aux niveaux : selon leurs niveaux atteints ou uniquement après leur recrutement ?
- Conditions et nature du défi individuel ; seuils de niveaux ; définition de l'accomplissement collectif ; coût des passifs en emplacements ; équilibrage.

### Exécution et suivi
- **Réalisé :** décision documentée et historique V7.3 préservé.
- **Non réalisé :** implémentation Godot, tests en jeu, équilibrage et playtests.
- **Chantier : 🟡 À CONSOLIDER.** Avancement du chantier actuel : À évaluer. Avancement du projet global : À évaluer.


---
## V7.5 — Recrues tardives : progression personnelle avec rattrapage (17 novembre 2026)

### Décision explicitement validée en conception
1. Les héros recrutés tardivement obtiennent les emplacements passifs liés aux niveaux au moyen d'une **progression personnelle après leur recrutement**, nécessitant de jouer avec le héros concerné.
2. Un **mécanisme de rattrapage** évite qu'une recrue tardive soit excessivement pénalisée par rapport aux héros déjà développés. Sa forme précise, ses conditions et son intensité ne sont pas encore définies.
3. L'emplacement associé à l'accomplissement collectif demeure attribué automatiquement à toutes les recrues concernées, conformément à V7.4 ; le défi individuel reste propre au héros.
4. La capacité maximale reste **1 initial + 2 liés à la progression personnelle par niveaux + 1 par défi individuel + 1 collectif = 5 emplacements passifs**, avec coût variable des passifs en emplacements.

### Vérification de cohérence avec V7.4
- La progression personnelle requise par V7.4 est maintenue : le rattrapage ne signifie pas l'attribution automatique des deux emplacements liés aux niveaux à l'arrivée d'un héros expérimenté.
- L'acquis collectif ne dépend pas de la participation individuelle de la recrue.
- Les quatre emplacements actifs restent indépendants ; les spécialisations demeurent exclusives avant NG+ et combinables au sein d'une même classe en NG+.
- **À surveiller lors de la conception :** ne pas permettre au rattrapage de contourner le jeu effectif avec le héros ou le défi individuel.

### Questions ouvertes (non validées)
- Nature du rattrapage (expérience accélérée, seuils propres aux recrues, entraînement associé à des expéditions, autre) et ses limites.
- Niveaux exacts de déblocage des deux emplacements, conditions du défi individuel, détails de l'accomplissement collectif et coût en emplacements des passifs.
- Niveau de départ des recrues et éventuelles règles de progression au refuge.

### Exécution et suivi
- **Réalisé :** décision V7.5 intégrée au document maître ; contrôle de conservation du contenu historique V7.4.
- **Non réalisé :** implémentation Godot, tests en jeu, équilibrage, playtests.
- **Chantier : 🟡 À CONSOLIDER.** Avancement du chantier actuel : À évaluer. Avancement du projet global : À évaluer.


---
## V7.6 — Rattrapage hybride, entraînement au refuge et piste de défi individuel (17 novembre 2026)

### Décisions explicitement validées en conception depuis V7.5
1. Le rattrapage des recrues tardives est **hybride** : expérience accélérée lors des expéditions et entraînement au refuge. La progression personnelle et la participation aux expéditions restent nécessaires pour obtenir les emplacements liés aux niveaux ; le défi individuel n'est pas contourné.
2. L'entraînement dépend d'une **installation dédiée du refuge**, susceptible d'être construite ou débloquée au cours de la progression du refuge.
3. Cette installation est **améliorable**. Ses améliorations accroissent à la fois l'efficacité de l'entraînement et le **nombre de recrues pouvant s'entraîner simultanément**.
4. Le **nombre de niveaux de l'installation, les capacités exactes, les coûts et l'équilibrage** sont explicitement **reportés au chantier des bâtiments du refuge**. La suggestion de trois niveaux et les capacités illustratives de 1, 2 et 3 recrues **ne sont pas validées**.
5. L'emplacement collectif demeure attribué automatiquement aux recrues tardives ; les deux emplacements personnels liés aux niveaux et l'emplacement lié au défi individuel nécessitent de jouer avec le héros.

### Orientation exprimée, non encore formalisée comme règle complète
- Pour le défi individuel débloquant un emplacement passif, préférence exprimée pour **vaincre un ennemi précis, élite ou mini-boss, conçu comme une faiblesse / un contre de la classe du héros**. À confirmer et préciser avant de considérer le cahier des charges du défi comme clos.
- **Non validé :** obligation de porter le coup final, simple participation ou contribution active du héros, défi propre à la classe ou à chaque héros, répétabilité, emplacement et accessibilité de l'ennemi, gestion de la mort ou de la capture.

### Contrôle de cohérence documentaire
- Compatible avec les cinq emplacements passifs maximum (1 initial + 2 niveaux personnels + 1 défi individuel + 1 collectif), et avec la progression des héros par participation aux expéditions.
- Compatible avec l'attachement aux héros, les classes distinctes et la progression du refuge.
- **Point de vigilance :** éviter qu'un défi de classe soit impossible pour une classe seule ou qu'une capture non létale rende impossible l'obtention du déblocage ; modalités à décider.

### Exécution
- **Réalisé :** consolidation des décisions explicitement validées depuis V7.5 et conservation de l'historique.
- **Non réalisé :** implémentation Godot, tests en jeu, calibrage des bonus, conception détaillée des bâtiments ou des adversaires de défi.
- **Suivi :** Avancement du chantier actuel : À évaluer ; avancement du projet global : À évaluer.


---
## V7.7 — Validation immédiate du défi individuel lors de la victoire (17 novembre 2026)

### Décisions explicitement validées en conception
1. Pour le défi individuel reposant sur la victoire contre un adversaire désigné, le héros concerné doit **contribuer activement au combat** ; sa simple présence dans l’équipe ne suffit pas.
2. **Porter le coup final n’est pas nécessaire** : une contribution réelle au combat est suffisante sous réserve de critères à préciser.
3. Le défi est **validé dès la victoire contre l’adversaire**, à condition que le héros ait contribué activement et **soit vivant au moment de cette victoire**. Le retour au refuge n’est pas requis pour valider le défi.
4. La mort des héros est définitive : une validation déjà obtenue ne ressuscite pas un héros décédé ensuite et ne transfère pas automatiquement sa récompense à un autre personnage.

### Cohérence avec les versions précédentes
- L’emplacement passif obtenu par défi reste **personnel** au héros, distinct des emplacements liés aux niveaux et de l’emplacement collectif automatique.
- Le retour au refuge ne conditionne pas la validation de ce défi, contrairement à d’autres mécanismes éventuels de sécurisation du butin ; ne pas les confondre.
- L’orientation vers un adversaire particulier opposé à la classe est mentionnée en V7.6 comme **piste**, non comme cahier des charges intégralement validé.

### Questions ouvertes (non validées)
- Critères mesurables de « contribution active » (attaque, soin, soutien, contrôle, etc.) et traitement des cas limites.
- Identité exacte de l’adversaire, lien à la classe ou au héros, accessibilité, répétabilité, victoire par capture et équilibrage.
- Éventuelle conséquence d’une mort ultérieure sur les archives ou la mémoire des exploits, sans transfert de récompense présumé.

### Exécution et suivi
- **Réalisé :** décision ajoutée au document maître, conservation du texte V7.6.
- **Non réalisé :** modification Godot, tests, validation d’équilibrage.
- **Chantier : 🟡 À CONSOLIDER.** Avancement du chantier actuel : À évaluer. Avancement du projet global : À évaluer.


---
## V7.8 — Contribution offensive ou défensive au défi individuel (17 novembre 2026)

### Décision explicitement validée en conception
1. Pour valider sa contribution active contre l’adversaire désigné, le héros peut contribuer **offensivement ou défensivement**.
2. Les actions pertinentes comprennent notamment les **attaques**, l’application d’**altérations d’état**, les **soins utiles** et la **protection effective des alliés** pendant l’affrontement. Ces catégories illustrent le principe validé ; les critères précis de mesure restent à définir.
3. La simple présence dans le groupe ne suffit pas et **le coup final n’est pas obligatoire**.

### Règles antérieures conservées
- Le défi est validé **dès la victoire**, si le héros a contribué activement et est **vivant à ce moment-là** ; aucun retour au refuge n’est requis.
- La mort est définitive ; aucun transfert automatique de récompense à un autre héros.
- Le défi reste personnel, distinct des déblocages par niveaux et de l’accomplissement collectif.

### Questions ouvertes, non validées
- Comment mesurer une action réellement utile (soin sans restauration, protection sans attaque subie, altération résistée, etc.).
- Seuil éventuel de contribution, gestion des actions indirectes et victoire par capture.
- Identité précise de l’adversaire et modalités du défi.

### Exécution et suivi
- **Réalisé :** ajout de la décision V7.8 au document maître et contrôle de conservation intégrale de V7.7.
- **Non réalisé :** implémentation Godot, tests en jeu et équilibrage.
- **Chantier : 🟡 À CONSOLIDER.** Avancement du chantier actuel : À évaluer. Avancement du projet global : À évaluer.


---

## V7.8 — Grandes lignes du prologue, affinité et recrutement lié à la maîtresse d'armes (23 novembre 2026)

### Décisions validées par l'utilisateur
- Le prologue débute par une **cinématique d'ouverture**.
- **Après la cinématique**, le joueur arrive à la Guilde des aventuriers et **crée son héros ou son héroïne au moment de son inscription**.
- La personnalisation détaillée du protagoniste sera conçue ultérieurement : ne pas présenter comme validés les choix de classes, origines, morphologies, voix ou autres options.
- Après l'inscription, la compagnie de **quatre aventuriers** (protagoniste et trois compagnons) se forme avant la quête introductive « La cueillette ».
- Ne révéler **ni la signification du rang S ni l'omelette** avant le retour de cette quête.
- **Une seule jauge d'affinité par personnage**, qui englobe la confiance. Pas de seconde barre ni de jeu de gestion sociale.
- L'affinité progresse par les aventures, les décisions et les interactions scénarisées ; pas d'obligation d'entretien quotidien.
- **Chaque personnage important possède un passé, une personnalité singulière, des motivations, des contradictions et une évolution narrative.** Le joueur doit s'attacher aux personnages pour eux-mêmes, sans que le butin soit la seule motivation.
- **Principe directeur : « Le personnage est la récompense principale de la relation. Le butin n'est qu'un complément. »**
- Le joueur pourra **débloquer des héros grâce à sa relation avec la maîtresse d'armes**. Les modalités précises de rencontre, de disponibilité et de recrutement restent à concevoir.

### Cohérence avec les décisions antérieures
- La maîtresse d'armes a une planche visuelle validée, mais son identité narrative complète et ses mécaniques détaillées restent à préciser.
- Le déblocage de héros par affinité ne doit pas attribuer automatiquement les **deux emplacements passifs liés aux niveaux** ni celui du **défi individuel** : ils exigent une progression personnelle avec le héros concerné.
- L'**emplacement passif collectif** est attribué automatiquement aux recrues tardives concernées, conformément aux décisions V7.4–V7.6.
- Le plafond antérieurement validé demeure **cinq emplacements passifs** (un initial, deux niveaux, un défi individuel, un collectif).
- Les héros recrutés tardivement disposent du **rattrapage hybride** déjà prévu (expéditions et entraînement au refuge), sans contourner leur progression personnelle.

### Questions ouvertes
- Quels héros sont liés à la maîtresse d'armes et pourquoi ?
- L'affinité donne-t-elle accès à une rencontre, à une épreuve ou directement à une proposition de recrutement ?
- Quelles histoires individuelles, motivations et conditions narratives différencient ces héros ?
- Quels seuils et événements d'affinité sont nécessaires ? Rien n'est fixé à ce stade.

### État d'exécution
- **Terminé :** consolidation documentaire des grandes lignes et conservation intégrale des sections antérieures.
- **Non réalisé :** intégration du créateur de personnage, moteur d'affinité et recrutement des héros dans Godot ; aucun test de jeu.
- **Suivi :** avancement du chantier actuel : À évaluer ; avancement du projet global LITD 1 : À évaluer.


---

## V7.9 — Niveau des héros débloqués par la maîtresse d’armes (23 novembre 2026)

**Décision validée :** tout héros débloqué grâce à la relation avec la maîtresse d’armes rejoint le groupe **au même niveau que le héros principal au moment de son recrutement**. Aucun rattrapage de niveau n’est requis pour cette catégorie de héros.

**Périmètre :** cette règle concerne les héros débloqués par la maîtresse d’armes ; elle ne remplace pas les règles de recrutement des autres personnages.

**Distinction importante :** égalité de niveau ne signifie pas attribution automatique de toutes les récompenses, épreuves ou étapes personnelles. Les modalités précises d’accès aux emplacements passifs liés au niveau pour ces héros doivent être arbitrées, afin d’éviter toute contradiction avec les règles antérieures.

**Non décidé :** ajustement des compétences et équipements au recrutement, évolution ultérieure du niveau, modalités des déblocages passifs et histoires individuelles.

**État :** décision de conception enregistrée, aucune implémentation ou validation Godot.


---

## V8.0 — Compétences des héros débloqués par la maîtresse d’armes (23 novembre 2026)

**Décision validée :** ces héros sont recrutés au **même niveau que le protagoniste** et arrivent avec leur **arbre de compétences et leurs compétences évolutives remis à zéro**, sans spécialisation de combat prédéfinie. Le joueur choisit lui-même leur orientation de combat en développant leur arbre.

**Interprétation à confirmer :** pour permettre une répartition équitable, mettre à disposition les points de compétences correspondant à leur niveau actuel. Le barème exact et les éventuelles compétences innées ou contraintes propres au personnage ne sont pas encore arbitrés.

**À préserver :** chaque héros conserve son identité, son histoire, sa personnalité et ses spécificités narratives ; la remise à zéro ne signifie pas suppression de ces caractéristiques.

**À arbitrer :** modalités de distribution des points, compétences initiales indispensables, conséquences sur les passifs et les emplacements liés aux niveaux, compatibilité avec les règles de progression antérieures.

**État :** décision de conception consignée ; aucune modification du gameplay ni test dans Godot.


---

# Addendum de réconciliation — décisions antérieures confirmées (24 novembre 2026)

**Portée :** cet addendum complète la base V8.3 par des décisions utilisateur antérieures retrouvées directement. Il n’actualise pas les détails non prouvés des PR #619/#620/#641. Le texte source V8.3 du 23 novembre est conservé intégralement dans `docs/conception/archive/LITD1_DOCUMENT_MAITRE_V8.3_SOURCE_2026-11-23.md`.

## Méthode de conception — recherche comparative obligatoire

**Date de validation :** 17 novembre 2026 à 14:26:20 UTC (15:26:20, heure de Paris).  
**Règle validée :** « Recherche comparative obligatoire avant chaque arbitrage de conception à choix multiples ».  
**Portée :** règle de méthode; elle ne valide aucune mécanique de gameplay.  
**Paramètres ouverts :** la règle établit le préalable comparatif et l’arbitrage explicite; les sous-étapes plus détaillées de la PR #619 ne sont pas toutes attestées séparément comme texte utilisateur approuvé.

## Némésis — rivalité et droit de fuite

### Orientation de comportement

**Date de validation retrouvée :** 17 novembre 2026 à 15:11 UTC (16:11 Paris).  
**Principe approuvé :** orientation C visant à éviter les fuites répétitives tout en conservant un comportement crédible du Némésis. Le verbatim complet du message d’approbation n’est pas récupéré; aucune modalité d’implémentation n’est déduite.

### Équipement récupéré par les ennemis — décision distincte (16 novembre 2026)

- Les ennemis peuvent récupérer et utiliser des armes et armures abandonnées ainsi que leurs effets, sous réserve de compatibilité morphologique.
- L'équipement récupéré peut modifier leur rôle, leurs caractéristiques, capacités et comportement; un ennemi peut progresser d'ordinaire à élite puis mini-boss tout en conservant l'équipement. Cette évolution ne crée pas à elle seule un Némésis : le statut Némésis nécessite qu'il tue un héros.
- Un ennemi ayant tué un héros peut récupérer un objet choisi aléatoirement parmi les objets de ce héros; les règles d'application des bonus passifs sont distinctes de l'attribution des objets. Les bonus passifs identiques ne s'additionnent pas : retenir la valeur la plus élevée.
- L'équipement récupéré peut être visible si la morphologie le permet. Élites, mini-boss et Némésis ont la même préférence pour les objets de rang élevé. L'ennemi conserve les objets récupérés jusqu'à sa propre mort.
- Les choix de calcul détaillés et leur implémentation/tests restent à vérifier; ne pas présenter ces règles de conception comme déjà opérationnelles.

### Système Némésis — décisions directes retrouvées

- **Déclenchement :** validation du 17 novembre 2026 à 14:37 UTC : seuls les exploits majeurs déclenchent le statut Némésis; tuer définitivement un héros suffit à le déclencher.
- **Puissance initiale :** validation du 17 novembre à 14:41 UTC : le bonus dépend du rang d'origine — élevé pour un ennemi normal, intermédiaire pour une élite, faible pour un mini-boss. Les valeurs restent à équilibrer.
- **Victimes ultérieures :** un Némésis gagne un bonus additionnel après chaque héros tué; ce bonus est indépendant de son rang d'origine. Son montant et ses limites restent ouverts.
- **Promotions :** validation du 17 novembre à 14:47 UTC : progression hybride Ennemi → Némésis → Mini-boss → Boss émergent. Des exploits non létaux peuvent accélérer les promotions. Les chiffres sont reportés.
- **Fuite :** validation du 17 novembre à 14:57 UTC : règle hybride comprenant des fuites annoncées et interceptables, ainsi que des fuites immédiates pour certaines capacités; interruption par contrôle ou dégâts selon des modalités hybrides, paramètres ouverts.
- **Correction ultérieure de catégorie :** le 18 novembre 2026 à 14:48 UTC, l'utilisateur a précisé que les ennemis normaux, les élites et les mini-boss peuvent fuir; les boss établis ne fuient pas; un mini-boss évoluant en boss peut exceptionnellement fuir pendant sa transformation. Cela remplace la règle antérieure selon laquelle seuls les Némésis pouvaient fuir.
- **Rivalité :** l'option A « Rivalité par exploit » reste validée; l'orientation C vise à éviter les fuites répétitives tout en gardant un Némésis crédible. Articuler ces principes sans annuler les catégories de fuite autorisées ci-dessus.
- **À équilibrer / préciser :** valeurs des bonus, seuils et rythme des promotions, définition des exploits majeurs, fréquence des fuites, conditions précises d'interception/interruption et persistance. L'équipement récupéré constitue une décision antérieure séparée, datée du 16 novembre et reprise ci-dessus; ne pas confondre ses règles générales avec le déclenchement du statut Némésis.

## Statut des autres PR

- La carte à nœuds qui remplace l’exploration 3D isométrique et maintient les combats 2D est déjà une décision de V8.3 n°1; la question correspondante de la PR #641 est dépassée.
- Les précisions topologiques, de renouvellement hybride et d’évolution du monde écrites dans #641 restent propositions tant qu’une validation utilisateur directe n’est pas retrouvée.
- La demande utilisateur du 23 novembre d’ajouter des cas de clés consommables, blocages irréversibles, passages secrets, retours contextuels au refuge, conséquences persistantes, transformations de carte, dépassement du budget et validation JSON Schema porte sur le périmètre des tests du validateur; elle ne vaut pas à elle seule approbation des règles de gameplay sous-jacentes.
- Les fixtures et le schéma V0 de #641 restent isolés pour une revue de compatibilité; aucun fichier V0 original n’est remplacé dans cette PR.

---

**Séparation des statuts :** décisions de conception ci-dessus; intégration documentaire proposée; aucune implémentation runtime ni test de gameplay n’est revendiqué par cet addendum.

---

## ARCH-01 — Missions simultanées selon leur compatibilité (25 novembre 2026)

**VALIDÉ EN CONCEPTION — option C.** Accord explicite : « Pour LITD 1, je valide explicitement l'option C de l'arbitrage ARCH-01 concernant les missions simultanées selon leur compatibilité, avec les douze règles complémentaires proposées. »

Le joueur peut poursuivre plusieurs missions pendant une même expédition, à condition que leurs objectifs et leurs conditions soient compatibles.

1. Une expédition peut permettre de poursuivre plusieurs missions.
2. Les missions doivent respecter le périmètre régional de l'expédition.
3. Une mission peut progresser sans être entièrement accomplie.
4. Des missions peuvent être découvertes pendant l'exploration.
5. Une même action peut faire progresser plusieurs missions compatibles.
6. Les missions incompatibles doivent être clairement identifiées.
7. L'accomplissement d'une mission ne termine pas automatiquement l'expédition.
8. L'abandon d'une mission n'entraîne pas automatiquement l'abandon des autres.
9. Chaque mission conserve son propre état de progression.
10. Les conséquences réellement survenues persistent.
11. Une récompense ne peut pas être attribuée plusieurs fois pour le même accomplissement.
12. Les missions personnelles respectent les règles de mort définitive des héros concernés.

Dépendances documentaires : V3.2, V4.9, V7.49, V7.50 et V8.3 ; vérification exhaustive des contradictions et paramètres de compatibilité restant à effectuer. Aucun plafond numérique, algorithme de compatibilité ou nouveau comportement de sauvegarde n'est décidé par cet arbitrage. Implémentation et tests non vérifiés. Aucun changement moteur ni fusion. Avancements chantier/global : à évaluer.

## ARCH-02 — Renouvellement hybride contextuel (25 novembre 2026)

**VALIDÉ EN CONCEPTION — option C.** Accord explicite : « Pour LITD 1, je valide explicitement l'option C de l'arbitrage ARCH-02 concernant le renouvellement hybride contextuel, avec les quinze règles complémentaires et les modifications des décisions antérieures proposées. »

Le renouvellement ordinaire des ennemis et des coffres dépend principalement des nouvelles expéditions. Pendant une même expédition, de nouveaux dangers peuvent apparaître lorsque le contexte du monde le justifie. La simple acceptation d'une mission ne provoque plus de renouvellement automatique.

1. Une nouvelle expédition permet le renouvellement des ennemis ordinaires admissibles.
2. Les coffres renouvelables peuvent être réapprovisionnés entre expéditions.
3. Accepter une nouvelle mission pendant une expédition ne renouvelle pas automatiquement les ennemis.
4. Accomplir une mission ne provoque aucun renouvellement automatique.
5. Abandonner une mission ne provoque aucun renouvellement automatique.
6. Plusieurs missions simultanées partagent le même état effectif du monde.
7. Les ennemis éliminés ne réapparaissent pas simplement parce qu'une autre mission est activée.
8. De nouveaux ennemis peuvent apparaître pendant une expédition si un événement, une mission ou une évolution du monde le justifie.
9. Les chemins sécurisés conservent leur sécurité tant qu'aucun changement contextuel ne la remet en cause.
10. Les destructions de repaires et leurs conséquences persistent.
11. Les ennemis uniques, Némésis, objets uniques et événements persistants restent soumis à leurs propres règles.
12. Les ressources récoltables conservent leur système de régénération fondé sur le temps du jeu.
13. La reprise d'une mission conserve sa progression et ses conséquences, sans imposer la restauration d'une ancienne carte incompatible avec l'état actuel du monde.
14. Aucun changement de mission, aller-retour ou rechargement de sauvegarde ne doit permettre de provoquer artificiellement un renouvellement.
15. Les renouvellements et leurs conséquences sont enregistrés dans la sauvegarde, sans duplication ni nouveau tirage lors de la reprise d'un résultat confirmé.

### Modifications antérieures explicitement approuvées
- V5.0, règle 2 : renouvellement ordinaire principalement lié à l'expédition plutôt qu'à la mission.
- V5.1, règle 3 : adaptation du déclencheur de renouvellement.
- V7.40, règle 1 : suppression du renouvellement automatique à chaque nouvelle mission.
- V7.40, règle 6 : adaptation du renouvellement des coffres.
- V7.50 : actualisation de la spécification consolidée.

Toutes les autres règles compatibles sont conservées. Les références V7.40 et V7.50 désignent les sections historiques du commit f558dbf, restant à réconcilier. Aucun seuil ou algorithme supplémentaire validé. Aucun test runtime.

## Traçabilité de la réconciliation du 25 novembre 2026

ARCH-01 repris intégralement du commit f558dbf08872128f1c22fb8764a9d954ad877c37. ARCH-02 provient de l'accord explicite du 25 novembre. Ces deux décisions constituent des exceptions désormais explicitement validées au statut de proposition des précisions de #641 mentionné dans l'addendum du 24 novembre. Les « go » autorisent la poursuite, jamais la validation métier. Les propositions V7.82–V7.87 fondées uniquement sur ces messages restent en quarantaine ; prototypes combat V0.1–V0.4 expérimentaux, V0.5 suspendue. Rectificatifs historiques : 78a5d4f et 401fd6f. Réconcilier individuellement les autres décisions avec les accords explicites, préserver les archives, ne pas restaurer le master concurrent de #641. Aucun changement moteur. Avancements chantier/global : à évaluer.


---

## Réconciliation des cartes — 25 novembre 2026

Les accords explicites du 22 novembre concernant le contrôle de validité (option C, dix règles) et la stabilité et évolution contextuelle (option C, dix règles) sont attestés dans les échanges utilisateur. Le texte ci-dessous est repris du registre historique du 23 novembre (commit f558dbf08872128f1c22fb8764a9d954ad877c37) ; l'identité mot à mot avec les propositions conversationnelles originales n'est pas vérifiée. Ces sections constituent des exceptions documentées au statut de proposition des précisions #641. Les références historiques non encore réconciliées ne sont pas validées par transitivité.

## V7.38 — Double contrôle de validité des cartes et mécanisme de secours (23 novembre 2026)

**VALIDÉ EN CONCEPTION : option C et dix règles complémentaires, explicitement choisies par l'utilisateur.** Génération sous contraintes puis validation indépendante avant utilisation des cartes régionales et internes des donjons. Contrôles obligatoires : 1. Accessibilité des objectifs obligatoires lorsque leurs prérequis sont réunis ; 2. absence de zones obligatoires accidentellement isolées ; 3. dépendances clés, portes, énigmes et quêtes ; 4. retour et sortie conformément aux restrictions narratives autorisées ; 5. cohérence écologique, territoriale et artistique ; 6. absence de duplication des personnages, objets et événements uniques ; 7. respect intégral des conséquences persistantes ; 8. limites de taille, densité et difficulté ; 9. sauvegarde de la configuration validée et vérification de restitution après interruption ; 10. tentatives limitées, secours compatible lui-même validé ou arrêt sécurisé sans perte de progression. Aucun contournement des contraintes narratives. Prévoir tests automatisés de nombreuses graines, dépendances circulaires, itinéraires conditionnels, régénération après décès/retraite/Game Over, interruptions et reprise, traçabilité des graines et anomalies, puis tests humains d'équilibrage. Ces tests sont planifiés, non exécutés.

**Traçabilité :** validation explicite de l'option C concernant le contrôle de validité des cartes avec les dix règles complémentaires. Huit axes de conception détaillée arbitrés sur huit ; audit transversal et paramètres techniques encore ouverts. Mise à jour documentaire uniquement ; aucun développement ni test en jeu. **Statut : 🟡 À CONSOLIDER avant clôture. Avancement des arbitrages : 8/8 ; avancement du chantier complet et du projet global : À évaluer.**

---

## V7.43 — Structure stable et transformations contextuelles des cartes (23 novembre 2026)

**VALIDÉ EN CONCEPTION : option C et dix règles complémentaires explicitement approuvées.** 1. Conservation de la configuration initiale pendant l'expédition. 2. Toute transformation a une cause identifiable dans le monde. 3. Ouverture, fermeture, restauration ou destruction possibles de passages. 4. Transformation locale ou apparition d'un lieu si le contexte le justifie. 5. Distinction entre transformations temporaires et permanentes. 6. Conservation des découvertes antérieures même obsolètes. 7. Révélation des changements selon les règles de reconnaissance et renseignements. 8. Validation automatique après chaque transformation. 9. Sauvegarde des transformations et conséquences. 10. Aucune recomposition aléatoire globale pendant une même expédition. Les architectures impossibles restent soumises aux contrôles de validité et de sauvegarde. Concilier V7.17, V7.19, V7.36 et V7.38 ; exemples environnementaux indicatifs, non validés individuellement.

**Traçabilité :** validation explicite de l'option C concernant la stabilité et l'évolution contextuelle des cartes avec les dix règles complémentaires. Consolidation : 2/4 arbitrages validés. Mise à jour documentaire uniquement, aucun test runtime. Statut : 🟡 À CONSOLIDER. Avancement global : À évaluer.

### Articulation avec ARCH-01 et ARCH-02

La carte et l'état effectif du monde sont communs aux missions compatibles. Accepter, accomplir ou abandonner une mission ne déclenche pas de régénération automatique. Les transformations contextuelles restent soumises aux contrôles de validité et de persistance. Le renouvellement des rencontres suit ARCH-02 ; il ne constitue pas une autorisation de recomposition globale intra-expédition. Cette articulation est une déduction des décisions existantes, sans nouvel arbitrage. V7.19 et V7.24 retrouvées dans l'historique, à rapprocher des accords originaux avant promotion normative. Algorithmes, limites numériques, critères artistiques et tests runtime restent ouverts. Aucun moteur ni archive modifié.


---

## ARCH-03 — Génération procédurale hybride structurée des cartes (25 novembre 2026)

**VALIDÉ EN CONCEPTION — option C.** Accord explicite : « Pour LITD 1, je valide explicitement l'option C de l'arbitrage ARCH-03 concernant la génération procédurale hybride structurée des cartes, avec les douze règles complémentaires proposées. Enregistre cette décision et réconcilie V7.19 et V7.24. »

1. Chaque région possède sa propre bibliothèque de lieux, rencontres et événements conçus manuellement.
2. Chaque nouvelle expédition produit une nouvelle configuration procédurale.
3. L'assemblage respecte l'identité artistique, écologique et territoriale de la région.
4. Les contraintes narratives prévalent sur les choix aléatoires.
5. Les objectifs obligatoires restent accessibles lorsque leurs prérequis sont réunis.
6. Les itinéraires alternatifs et passages secrets sont pris en compte dans la génération.
7. Les événements uniques et conséquences persistantes sont conservés entre expéditions.
8. La configuration reste stable pendant une même expédition, hors transformations contextuelles autorisées.
9. Le brouillard de guerre intégral permet la découverte progressive de la nouvelle configuration.
10. Les retours sur des nœuds déjà visités conservent les découvertes effectuées pendant l'expédition.
11. La génération et les transformations respectent les dix contrôles de validité V7.38.
12. Les cartes régionales et les donjons respectent les principes de génération hybride, de sauvegarde et de reprise.

Les dimensions, la densité, les algorithmes et les proportions des différents types de nœuds restent à déterminer.

### Réconciliation V7.19 et V7.24

ARCH-03 confirme les principes communs de ces sections historiques : nouvelle configuration par expédition, stabilité intra-expédition, découverte progressive, identité régionale, assemblage sous contraintes et persistance. ARCH-03 fait autorité ; les formulations historiques ci-dessous sont conservées comme provenance, sans prétendre avoir retrouvé leurs accords originaux ni valider par transitivité leurs références. ARCH-01, ARCH-02, V7.38 et V7.43 restent applicables. Aucun changement de mission ne déclenche de recomposition automatique. Aucun code ou test runtime modifié.

### Sources historiques (commit f558dbf)

#### V7.19 — Justification du brouillard intégral : génération procédurale (23 novembre 2026)

L'utilisateur précise que le choix du brouillard de guerre intégral (V7.18) est également motivé par le caractère procédural de la carte à chaque visite. Cette précision rejoint la règle antérieure de configuration stable pendant une même expédition et renouvelée à l'expédition suivante.
- Nouvelle expédition : nouvelle configuration procédurale de la carte, à découvrir progressivement.
- Retour sur un nœud pendant la même expédition : conserver la configuration et les découvertes de cette expédition ; appliquer V7.16 et V7.17.
- Préserver l'identité des régions, les événements uniques résolus et les conséquences persistantes malgré le renouvellement de la disposition.
- L'interprétation de « chaque visite » comme nouvelle expédition, plutôt que chaque passage sur un nœud, découle des règles antérieures ; les modalités exactes de génération et de conservation des connaissances restent à définir.

**Exécution :** précision documentaire, sans implémentation ni test Godot.

#### V7.24 — Génération procédurale hybride structurée des cartes régionales (23 novembre 2026)

**VALIDÉ EN CONCEPTION : option C, explicitement choisie par l'utilisateur.** Bibliothèques régionales de lieux, rencontres et événements conçus manuellement, assemblés procéduralement à chaque nouvelle expédition sous contraintes narratives et régionales. Respecter l'identité artistique et les biomes, l'accessibilité des objectifs obligatoires lorsque leurs prérequis sont remplis, les itinéraires alternatifs et accès secrets, la cohérence des rencontres, la persistance des conséquences et événements uniques, l'absence de blocage involontaire et la stabilité de la configuration pendant l'expédition, sauvegarde et reprise comprises. Conserver les décisions V7.15–V7.23 et la génération hybride des donjons déjà documentée. Dimensions, densité, répartition des nœuds, algorithmes et valeurs restent à spécifier.

**Traçabilité :** validation explicite de l'option C concernant la génération procédurale des cartes régionales. Mise à jour documentaire uniquement ; aucun développement ni test en jeu. **Statut : 🟡 À CONSOLIDER. Avancement du chantier détaillé et du projet global : À évaluer.**


---

## Réconciliation des guet-apens — 25 novembre 2026

Accord explicite retrouvé dans les échanges du 22 novembre : option C concernant l'intégration des guet-apens, avec dix règles complémentaires. Transcription historique du 23 novembre reprise ci-dessous depuis f558dbf08872128f1c22fb8764a9d954ad877c37 ; identité mot à mot avec la proposition conversationnelle originale non vérifiée.

## V7.45 — Intégration hybride contextuelle des guet-apens (23 novembre 2026)

**VALIDÉ EN CONCEPTION : option C et dix règles complémentaires explicitement approuvées.** 1. Ratio cible 35 % détectables / 65 % indétectables sur l'ensemble des guet-apens procéduraux, non par carte. 2. Guet-apens scénarisés soumis aux contraintes narratives et comptabilisés séparément. 3. Caractère détectable fixé à la génération. 4. Détection contextuelle par aptitudes, observation et bestiaire. 5. Aucun spécialiste ne garantit la détection systématique. 6. Détection seule insuffisante pour déjouer. 7. Guet-apens déjoué si évité, neutralisé ou avantage de surprise effectivement supprimé. 8. Attaque préventive seulement si ennemis localisés et accessibles. 9. Si combat après guet-apens déjoué, léger bonus collectif d'initiative au premier round uniquement, sans PA supplémentaire. 10. Aucun nouveau tirage artificiel par aller-retour ou rechargement en contexte inchangé. Pièges mécaniques autonomes hors ratio en attente d'arbitrage spécifique. Aucune poursuite ennemie. Paramètres statistiques et tests restent à définir.

**Traçabilité :** validation explicite de l'option C concernant l'intégration des guet-apens avec les dix règles complémentaires. Consolidation : 3/4 arbitrages validés. Mise à jour documentaire uniquement ; aucun test runtime. Statut : 🟡 À CONSOLIDER. Avancement global : À évaluer.

### Articulation et limites

V7.45 précise V4.6 (dénominateur procédural, scénarisés séparés), V4.3–V4.4 (définition de déjoué, bonus uniquement si combat). La règle historique V4.3–V4.4 de consommation du PA normal du premier tour lors d'une attaque préventive reste à rapprocher des décisions tactiques originales ; aucune action gratuite ajoutée. V3.6 exclut la poursuite continue. ARCH-01/02/03 impliquent que les changements de mission ne relancent pas le tirage et que les guet-apens persistants respectent l'état du monde et les transformations contextuelles validées. V8.3 impose la conservation des résultats confirmés sans nouveau tirage. Cette articulation est déduite des règles existantes, pas un nouvel arbitrage. Les pièges mécaniques autonomes, le montant du bonus, les effets précis de surprise, les familles de guet-apens, les modalités de retraite et le comportement des coffres-créatures restent à réconcilier ou arbitrer ; ne pas promouvoir les propositions V3.7/V3.8 par transitivité. Aucun code ni test runtime modifié.


---

## Réconciliation des secrets et renseignements — 25 novembre 2026

Reprise des sections V7.27, V7.29 et V7.30 du commit historique f558dbf08872128f1c22fb8764a9d954ad877c37, contenant chacune une citation d'accord explicite. Les citations sont attestées par ce registre historique ; les messages originaux et le verbatim intégral des propositions n'ont pas été vérifiés indépendamment.

## V7.27 — Reconnaissance et renseignements hybrides (23 novembre 2026)

**VALIDÉ EN CONCEPTION : option C, explicitement choisie par l'utilisateur.** Combiner découverte physique, reconnaissance des héros, renseignements des PNJ et archives de la Guilde. Un renseignement peut signaler un lieu sans révéler son itinéraire. Préserver le brouillard intégral, la génération procédurale entre expéditions, la stabilité pendant une expédition et les conséquences persistantes. Distinguer connaissances durables et renseignements dépendant de la configuration actuelle ; les anciens itinéraires ne sont pas automatiquement valables. La connaissance et la sécurisation d'un lieu sont distinctes. Les fonctions détaillées des PNJ, niveaux de connaissance, fiabilité, portée, coûts et conditions de reconnaissance restent des propositions à arbitrer, sans validation implicite.

**Traçabilité :** « Je valide l'option C : renseignements hybrides. Enregistre la décision dans le document maître et poursuis les arbitrages. » Mise à jour documentaire uniquement, aucun test en jeu. Statut : 🟡 À CONSOLIDER pour l'implémentation. Avancement du chantier détaillé et du projet global : À évaluer.

---

## V7.29 — Découverte hybride des passages et lieux secrets (23 novembre 2026)

**VALIDÉ EN CONCEPTION : option C et règles complémentaires, explicitement choisies par l'utilisateur.** Combiner aptitudes des héros, observation du joueur, renseignements et interactions contextuelles. Certains secrets sont découvrables sans spécialiste ; les spécialistes facilitent la recherche sans garantir toutes les découvertes. Les secrets peuvent mener à des raccourcis, trésors, créatures, quêtes ou révélations narratives. Les simples allers-retours ne déclenchent pas de nouveaux tirages de détection. Aucun secret facultatif ne doit bloquer involontairement la quête principale. Distinguer découverte et ouverture éventuelle ; les conditions précises, clés, aptitudes, énigmes, seuils et modalités de détection restent à spécifier. Préserver V7.27 et les contraintes de génération et de persistance antérieures.

**Traçabilité :** « Je valide l'option C : découverte hybride des secrets, avec les règles complémentaires proposées. Enregistre et poursuis. » Mise à jour documentaire uniquement ; aucun développement ni test en jeu. Statut : 🟡 À CONSOLIDER pour l'implémentation.

---

## V7.30 — Fiabilité contextuelle des renseignements (23 novembre 2026)

**VALIDÉ EN CONCEPTION : option C, quatre catégories et règles complémentaires explicitement approuvées.** La fiabilité dépend de la provenance, de l'ancienneté, de la nature du renseignement et des motivations de son auteur. Catégories : connaissances permanentes (histoire, mythologie, propriétés des créatures, identité des lieux) conservées ; renseignements géographiques à actualiser selon la génération ; renseignements temporaires (ennemis, embuscades, ressources) susceptibles d'obsolescence ; rumeurs et témoignages partiels, erronés ou mensongers à confirmer. Aucun faux renseignement arbitraire ; mensonges justifiés narrativement ou contextuellement ; affinités susceptibles d'améliorer la qualité ; recoupement des sources possible ; archives conservant les renseignements anciens même obsolètes ; interface distinguant confirmation et rumeur ; aucune erreur ne doit bloquer définitivement la progression principale. Préserver V7.27 et V7.29. Les durées, seuils, règles de présentation et modalités de recoupement restent à spécifier.

**Traçabilité :** « Je valide l'option C : fiabilité contextuelle des renseignements, avec les quatre catégories et les règles complémentaires proposées. Enregistre et poursuis. » Mise à jour documentaire uniquement, sans développement ni test en jeu.

### Articulation avec les décisions réconciliées

ARCH-03 intègre les passages secrets dans la génération ; V7.38 contrôle l'accessibilité des objectifs obligatoires et les dépendances ; V7.43 encadre les transformations et la conservation des découvertes. V7.29 distingue découverte et ouverture et exclut les nouveaux tirages par simples allers-retours. ARCH-01/02 excluent une recomposition ou un renouvellement automatique par changement de mission. V7.27/30 distinguent connaissance durable et itinéraire dépendant de la configuration : conserver les renseignements anciens sans garantir leur validité actuelle. V8.3 impose la persistance des résultats confirmés. Ces articulations sont des déductions documentaires, non des arbitrages supplémentaires. Aucun secret facultatif ne doit bloquer involontairement la quête principale ; ne pas déduire une interdiction générale des prérequis narratifs obligatoires. Les conditions de clés consommables, coûts, seuils, énigmes et conséquences narratives spécifiques restent à préciser ; la demande de tests ne valide pas leurs règles métier. V7.28 retrouvée mais accord original non cité dans cette section, à vérifier séparément. Aucun code ni test runtime modifié.


---

## Réconciliation du retour au refuge — 25 novembre 2026

Accord explicite du 22 novembre : option C concernant le retour immédiat au refuge avec douze règles complémentaires. Transcription historique du 23 novembre reprise depuis f558dbf08872128f1c22fb8764a9d954ad877c37 ; identité mot à mot avec la proposition conversationnelle originale non vérifiée.

## V7.49 — Retour immédiat contextuel au refuge (23 novembre 2026)

**VALIDÉ EN CONCEPTION : option C et douze règles complémentaires explicitement approuvées.** 1. Retour immédiat depuis cartes régionales et donjons. 2. Aucun trajet inverse systématique. 3. Avant ou après accomplissement de mission. 4. Interdit en combat actif, retraite distincte. 5. Bloqué pendant résolution d'une menace immédiate incompatible avec extraction. 6. Restrictions scénarisées justifiées et communiquées. 7. Motif de toute interdiction affiché. 8. Traitement explicite des héros immobilisés, capturés ou séparés avant confirmation, sans mort automatique. 9. Conservation blessures, pertes, équipements et conséquences selon leurs règles. 10. Aucune pénalité narrative permanente liée au seul abandon. 11. Sauvegarde transactionnelle du retour, prévention des duplications et pertes accidentelles. 12. Aucune poursuite ni réapparition artificielle provoquée par la demande. La dangerosité générale ne suffit pas à bloquer. Le retour clôt l'expédition ; une nouvelle expédition génère une nouvelle carte sans effacer les conséquences de mission. Poursuite de l'exploration possible après accomplissement. Les modalités détaillées de traitement des héros séparés restent à spécifier.

### Articulation avec les décisions réconciliées

V7.49 précise V3.3 et les propositions historiques de restrictions. ARCH-01 conserve les états individuels des missions ; la fin d'expédition n'implique pas à elle seule l'abandon de toutes les missions. ARCH-02 gouverne le renouvellement admissible entre expéditions et interdit les renouvellements artificiels ; ARCH-03 gouverne la nouvelle configuration. V7.45 exclut la poursuite et les nouveaux tirages artificiels. V8.3 impose la cohérence transactionnelle et la reprise exactement une fois des conséquences confirmées. Ces articulations sont des déductions documentaires, non des arbitrages nouveaux. La synthèse historique V7.50 contient encore l'ancien renouvellement par nouvelle mission, remplacé par ARCH-02 ; ne pas la réintroduire intégralement comme norme. Le traitement précis des héros immobilisés, capturés ou séparés, les conditions de sauvetage et les modalités d'interface restent à arbitrer ; aucune mort automatique ni extraction universelle déduite. Prévoir vérification de la transaction de retour et interruptions à chaque étape durable conformément à V8.3, sans système de sauvegarde parallèle. Aucun test runtime exécuté ni code modifié.


---

## ARCH-04 — Devenir hybride contextuel des héros abandonnés (25 novembre 2026)

**Accord explicite acquis ; transcription normative incomplète.** « Pour LITD 1, je valide explicitement l'option C de l'arbitrage ARCH-04 concernant le devenir hybride contextuel des héros abandonnés, avec les dix-huit règles complémentaires proposées. Enregistre cette décision et réconcilie les systèmes concernés. »

Le texte exact des dix-huit règles n'a pas été retrouvé. Ne pas les reconstruire ni promouvoir une proposition de remplacement comme règle approuvée. Réconciliation détaillée suspendue jusqu'à récupération du texte. Dépendances à contrôler : V7.49 (retour, héros immobilisés/capturés/séparés, absence de mort automatique), retraite en combat, captivité, mort définitive, devenir des corps et équipements, persistance du monde, missions personnelles et V8.3 (transactions et reprise). Ces dépendances constituent un périmètre d'audit, non de nouvelles règles. Les règles existantes compatibles restent applicables. Aucun code ni test runtime modifié.


---

## ARCH-04 — Nouvelle formulation normative (25 novembre 2026)

**VALIDÉ EN CONCEPTION — option C.** Accord explicite : « Pour LITD 1, je valide explicitement la nouvelle formulation de l'arbitrage ARCH-04, option C, concernant le devenir hybride contextuel des héros abandonnés, avec les dix-huit règles complémentaires présentées. Enregistre le texte intégral et réconcilie les systèmes concernés. »

Cette formulation remplace le contenu normatif introuvable de l'accord précédent, conservé ci-dessus pour traçabilité. Le blocage de transcription est levé pour cette nouvelle formulation.

### Abandon et extraction

1. Un héros vivant abandonné n'est pas automatiquement considéré comme mort.
2. Le joueur peut tenter de libérer, secourir ou transporter un héros lorsque la situation le permet.
3. L'abandon volontaire nécessite une confirmation explicite présentant les risques connus.
4. Les possibilités de sauvetage dépendent de l'état physique du héros, des capacités de ses compagnons et de l'environnement.
5. Le retour immédiat au refuge ne permet pas d'extraire automatiquement un héros inaccessible.

### Devenir du héros

6. Le devenir du héros dépend de ses blessures, de son environnement, des ennemis présents et des circonstances de son abandon.
7. Un héros abandonné peut survivre, être capturé, demeurer introuvable, parvenir à s'échapper ou mourir.
8. Les ennemis peuvent capturer un héros uniquement si leur nature, leurs capacités et leurs motivations le permettent.
9. Le devenir d'un héros peut évoluer avec le temps du jeu et les événements du monde.
10. Un héros dont la mort définitive est confirmée ne peut jamais redevenir un héros jouable.

### Sauvetage et récupération

11. Un héros vivant abandonné ou capturé peut faire l'objet d'une mission de sauvetage lorsque le contexte le permet.
12. La réussite d'un sauvetage n'est jamais garantie.
13. Les renseignements, témoignages et traces peuvent aider à retrouver un héros disparu.
14. L'équipement du héros reste soumis aux règles de possession, de pillage et de récupération, sans transfert automatique au refuge.
15. Un héros récupéré conserve son identité, sa progression personnelle et les conséquences réellement subies pendant son absence.

### Persistance et sauvegarde

16. Le devenir des héros abandonnés persiste entre les expéditions, malgré la génération de nouvelles cartes.
17. Les simples déplacements, changements de mission et rechargements de sauvegarde ne permettent pas de modifier artificiellement un résultat confirmé.
18. Chaque transition importante concernant le héros, son équipement et son état est enregistrée conformément aux règles transactionnelles V8.3, sans duplication ni résurrection interdite.

### Réconciliation documentaire

- V7.49 et V3.3 : traitement explicite avant extraction, confirmation de l'abandon volontaire, absence de mort automatique et absence d'extraction universelle. Retraite en combat distincte ; coûts et conditions tactiques non redéfinis.
- ARCH-01 : missions de sauvetage soumises aux règles de compatibilité ; progression des missions distincte du devenir du héros.
- ARCH-02/03, V7.38/43 : nouvelle carte et renouvellement admissible ne réinitialisent pas le sort du héros ; respecter les contraintes de validité et les conséquences persistantes.
- V7.27/30 : renseignements et traces soumis à leur fiabilité contextuelle.
- V8.1/2 : identité et progression personnelle du héros vivant récupéré conservées ; aucune résurrection jouable après mort définitive. Les règles de succession et missions personnelles restent applicables ; absence ou captivité ne vaut pas preuve de décès. Cas de succession avec héros absent à vérifier séparément.
- Corps et équipements : les règles historiques de pillage et récupération restent applicables selon leur statut de validation ; ne pas assimiler un vivant abandonné à un cadavre. Aucun transfert automatique, aucune duplication.
- Capture : distinguer captivité des héros et capture de créatures pour recrutement ; ne pas appliquer automatiquement les règles de recrutement aux héros capturés.
- V8.3 : enregistrer les transitions et conséquences interdépendantes de manière atomique ; reprise des résultats confirmés exactement une fois, sans nouveau tirage.

Ces articulations sont des déductions des règles validées, pas des arbitrages supplémentaires. Probabilités de survie, délais de captivité, fréquence des missions de sauvetage, conditions précises de transport, comportements par espèce et conséquences psychologiques restent ouverts. Aucun code ni test runtime modifié. La réconciliation exhaustive des contrats et des implémentations reste à effectuer.


---

## ARCH-05 — Exclusivité de la fuite volontaire des Némésis (25 novembre 2026)

**VALIDÉ EN CONCEPTION.** Accords directs successifs : « Pas de fuite des ennemis » puis, en réponse à la question sur l'exception Némésis, « seul les némésis peuvent fuir ».

Seuls les ennemis possédant le statut Némésis peuvent volontairement fuir un combat. La fuite n'est pas systématique. Les ennemis ordinaires, élites et mini-boss sans ce statut ne peuvent pas fuir. La correction du 18 novembre autorisant la fuite des catégories non Némésis est remplacée sur ce point. Le cas des Némésis devenus boss établis et l'exception de transformation restent à clarifier explicitement : l'exclusivité est une condition nécessaire, pas une autorisation universelle de fuite pour tous les rangs Némésis.

Réconciliation documentaire : l'exclusivité de V7.12 et V7.41 est confirmée ; les clauses compatibles de V7.51, V7.58 et V7.64 distinguant évasion de contention et fuite volontaire sont préservées. Les dix règles historiques de V7.41 et les exceptions de fuite immédiate doivent être rapprochées des validations originales avant consolidation détaillée. Aucun des dix-huit nouveaux énoncés ARCH-05 proposés ni des sous-arbitrages ARCH-05.1 à 05.6 n'est réputé approuvé par cette décision. La retraite des héros, les déplacements tactiques et l'évasion de contention ne sont pas redéfinis. Aucun changement moteur ni test runtime.

### ARCH-05 — Restriction des boss établis (25 novembre 2026)

**VALIDÉ EN CONCEPTION : option B.** L'utilisateur répond « oui » à la recommandation explicitement sélectionnée : un Némésis perd sa capacité de fuite lorsqu'il devient définitivement un boss. Seuls les Némésis non devenus boss établis sont éligibles à la fuite volontaire, sous conditions. Les boss principaux et émergents établis ne fuient pas. L'exception historique de transformation ne peut concerner qu'un Némésis avant son établissement définitif comme boss ; ses modalités précises ne sont pas nouvellement validées. Cette décision lève l'incertitude sur les boss établis dans ARCH-05. Aucun changement moteur ni test runtime.


### ARCH-05 — Modalités hybrides de fuite et réconciliation V7.41 (25 novembre 2026)

**VALIDÉ EN CONCEPTION : option C.** Accord direct : « Pour LITD 1, je valide explicitement l'option C concernant les modalités de fuite des Némésis dans ARCH-05. Réconcilie les règles V7.41 en conséquence. »

La fuite ordinaire est annoncée et interruptible. Certaines capacités spécifiques permettent une fuite immédiate, à condition que cette possibilité soit cohérente avec la nature du Némésis et explicitement définie dans ses capacités. Seuls les Némésis non devenus boss établis sont éligibles. Aucune disparition arbitraire.

#### V7.41 — Transcription historique conservée pour traçabilité

Source : commit f558dbf08872128f1c22fb8764a9d954ad877c37. Le registre historique qualifie les dix règles de validées ; les messages originaux n'ont pas été indépendamment retrouvés. Les clauses 3 et 4 sont désormais réconciliées par l'accord direct ci-dessus ; les autres clauses sont conservées sans nouvelle prétention de validation indépendante.

##### V7.41 — Fuite contextuelle, tactique et interruptible des Némésis (23 novembre 2026)

**VALIDÉ EN CONCEPTION : option C, fuite contextuelle, tactique et interruptible des Némésis, avec les dix règles complémentaires explicitement approuvées.** La décision combine état physique, tempérament, circonstances du combat et possibilités réelles de retraite. Le joueur dispose d'une fenêtre de réaction tactique.

1. Aucune fuite automatique après la mort d'un héros.
2. Aucun seuil de santé universel.
3. Intention de fuite identifiable avant exécution.
4. Interruption possible par actions compatibles.
5. Prise en compte des blessures anatomiques et capacités de déplacement.
6. Aucune disparition artificielle pour protéger le Némésis d'une défaite.
7. Limitation des tentatives répétitives.
8. Conservation des blessures, équipements et souvenirs après fuite, sous réserve de leur évolution ultérieure.
9. Recherche du fugitif via reconnaissance et renseignements déjà validés.
10. Résultat enregistré dans la sauvegarde persistante, sans nouveau tirage au rechargement.

Préserver V7.12 et la fuite volontaire réservée aux Némésis. Coûts en points d'action, délais, seuils et mécanismes précis de limitation à déterminer lors des essais. Validation documentaire uniquement, aucun développement ni test en jeu.

#### Préséance normative ARCH-05 sur V7.41

- Règle 3 : intention identifiable avant exécution pour la fuite ordinaire ; exception pour les capacités spécifiques de fuite immédiate explicitement définies.
- Règle 4 : interruption possible par actions compatibles pour la fuite ordinaire ; la fuite immédiate ne garantit pas une fenêtre préalable de réaction. Les interactions précises avec les réactions de combat restent à définir.
- Règles 1, 2, 5 à 10 : conservées sans changement de formulation.
- V7.12 : préserver la crédibilité et la limitation des fuites répétitives.
- V7.51, V7.58, V7.64 : maintenir la distinction entre fuite volontaire et rupture de contention ; aucune fuite volontaire pour les non-Némésis.
- V8.3 : persistance des résultats confirmés sans nouveau tirage.
- Les modalités de transformation en boss, coûts en PA, seuils, délais, capacités admissibles et limites de répétition restent ouverts. Aucun des dix-huit énoncés ARCH-05 précédemment proposés n'est globalement approuvé par cet accord. Aucun changement moteur ni test runtime.



---

## ARCH-06 — Acquisition et évolution du statut Némésis (25 novembre 2026)

**VALIDÉ EN CONCEPTION : option C et vingt règles complémentaires.** Accord direct : « Pour LITD 1, je valide explicitement l'option C de l'arbitrage ARCH-06 concernant l'acquisition et l'évolution du statut Némésis, avec les vingt règles complémentaires proposées. Enregistre le texte intégral et réconcilie les systèmes concernés. »

### Acquisition du statut Némésis

1. Seule la mort définitive d'un héros attribuable à un ennemi permet à celui-ci d'acquérir le statut Némésis.
2. L'acquisition du statut est automatique lorsque cette condition est remplie.
3. Une blessure, une mutilation, une capture ou une victoire non létale ne suffit pas à créer un Némésis.
4. La récupération d'un équipement, quelle que soit sa rareté, ne confère pas le statut Némésis.
5. La mort d'un héros doit être effectivement confirmée et attribuée selon les règles de causalité du combat.

### Progression statistique

6. Le bonus initial dépend du rang de l'ennemi au moment de l'acquisition du statut.
7. Un ennemi ordinaire reçoit un bonus initial supérieur à celui d'une élite, qui reçoit elle-même un bonus supérieur à celui d'un mini-boss.
8. Chaque nouvelle mort définitive d'un héros attribuable au Némésis contribue à sa progression statistique.
9. Les gains statistiques supplémentaires sont décroissants et plafonnés.
10. Les bonus provenant des équipements restent distincts des bonus propres au statut Némésis.

### Promotions et évolution

11. Les promotions constituent une évolution distincte de la progression statistique.
12. Les morts définitives de héros peuvent contribuer aux promotions.
13. Certains exploits majeurs non létaux peuvent accélérer une promotion, sans attribuer automatiquement de bonus statistique lié aux morts de héros.
14. Une simple fuite, une blessure ordinaire ou la survie à un combat ne constitue pas un exploit majeur.
15. Un Némésis conserve au minimum son rang d'origine et peut évoluer jusqu'au rang de boss émergent.
16. Les promotions peuvent modifier son apparence, ses capacités, son comportement et son influence territoriale, selon sa nature.

### Persistance et cohérence

17. Une promotion ne provoque aucune guérison intégrale automatique et ne supprime pas arbitrairement les faiblesses anatomiques.
18. Le Némésis conserve son identité, ses souvenirs, ses victimes, ses promotions et ses bonus après un Game Over.
19. Un Némésis définitivement mort ne peut pas réapparaître artificiellement pour maintenir la difficulté.
20. L'acquisition du statut, les gains, les promotions et leurs conséquences sont enregistrés conformément aux règles transactionnelles V8.3, sans duplication ni nouveau tirage au rechargement.

### Réconciliation documentaire et préséance

- Le déclenchement historique par « exploits majeurs » est remplacé par les règles 1 à 5 pour l'acquisition du statut. Les exploits non létaux ne concernent que les promotions après acquisition, selon les règles 13 et 14.
- V7.44 : distinguer bonus statistiques et promotions ; conserver les clauses compatibles. La restriction historique sur les blessures ne doit pas être interprétée comme excluant tout exploit non létal majeur des promotions. La liste des exploits admissibles reste ouverte.
- V7.34 : la persistance après Game Over est confirmée par la règle 18 ; aucun bonus supplémentaire pour le simple Game Over, selon la règle historique compatible, dont la validation originale reste à vérifier.
- V7.35/37 : séparer pillage, bonus d'équipement et acquisition du statut ; préserver les invariants d'identité et de non-duplication.
- V7.39 : préserver la mobilité territoriale contextuelle ; aucune nouvelle règle de déplacement.
- ARCH-04 : abandon, disparition ou captivité ne valent pas mort définitive confirmée.
- ARCH-05/V7.41 : la fuite est réservée aux Némésis non devenus boss établis ; aucune progression pour simple fuite. Une promotion ne permet pas de contourner les restrictions de fuite.
- V8.3 : acquisition, attribution causale, gains et promotions interdépendants soumis aux transactions confirmées exactement une fois.
- Capture/recrutement : la garantie historique V7.60 ne tranche pas à elle seule l'éligibilité des Némésis ou des boss émergents. Ne pas déduire de nouvelle restriction ou autorisation de recrutement d'ARCH-06.

Ces articulations constituent une réconciliation documentaire, non de nouveaux arbitrages. Les exemples d'exploits non létaux ne sont pas validés individuellement. Attribution des morts indirectes, bonus initiaux des rangs non spécifiés, valeurs, seuils, plafonds, conditions exactes des promotions et recrutement des Némésis/boss émergents restent ouverts. Aucun code ni test runtime modifié ; audit des contrats et implémentations restant à effectuer.


## ARCH-07 — Restrictions de recrutement en NG+ (25 novembre 2026)

**VALIDÉ EN CONCEPTION sur le principe.** Accords directs : « Non némésis et boss émergents recrutables en NG+ comme les boss » ; « Les mini boss ne sont pas recrutables avant le ng+ ». Les mini-boss, les Némésis quel que soit leur rang, les boss émergents et les cinq boss principaux ne sont recrutables qu'en NG+. Cette restriction prévaut sur toute formulation contraire. Les ennemis ordinaires et élites sans statut Némésis restent soumis aux conditions existantes. V7.60 ne garantit le recrutement que pour les captifs éligibles extraits ; ne pas contourner la restriction NG+. La possibilité de capture avant NG+ reste distincte et non arbitrée. Aucun changement moteur ni test runtime.


### ARCH-07 — Extension explicite de la restriction à la capture (25 novembre 2026)

**VALIDÉ EN CONCEPTION.** Accord direct : « La capture et le recrutement des mini-boss, Némésis et boss sont réservés au NG+. » Cette décision complète ARCH-07 : mini-boss, Némésis quel que soit leur rang, boss émergents et boss principaux ne sont ni capturables ni recrutables avant NG+. En NG+, les conditions individuelles d'éligibilité restent applicables. Les ennemis ordinaires et élites sans statut Némésis conservent les conditions existantes. Réconciliation : V7.46/V7.48/V7.64, restriction d'éligibilité avant calcul de capture ; V7.58, étapes de transport et extraction inchangées ; V7.59/V7.60/V7.69, restriction NG+ et garantie de recrutement des captifs éligibles extraits ; ARCH-06, le statut et les promotions déterminent l'application de la restriction, sans modification des règles d'acquisition. V8.3, persistance et non-duplication inchangées. Les cas particuliers (Ange, voies narratives, devenir des bonus et équipements après recrutement) restent à examiner sans présumer de nouvelles décisions. Aucun changement moteur ni test runtime.


## ARCH-08 — Adaptation des ennemis recrutés (25 novembre 2026)

**VALIDÉ EN CONCEPTION : option C et vingt règles complémentaires.** Accord direct : « Pour LITD 1, je valide explicitement l'option C de l'arbitrage ARCH-08 concernant l'adaptation des ennemis recrutés, avec les vingt règles complémentaires proposées. Enregistre le texte intégral et réconcilie les systèmes concernés. »

Le principe consiste à préserver l'identité et l'histoire de la créature recrutée, tout en adaptant ses caractéristiques à son nouveau rôle de héros jouable.

### Identité et continuité

1. La créature recrutée conserve son identité unique, son histoire et ses souvenirs.
2. Elle conserve la mémoire de ses affrontements précédents, notamment des héros qu'elle a tués.
3. Son recrutement ne crée pas une nouvelle entité indépendante de la créature d'origine.
4. Son anatomie, sa morphologie et ses particularités physiques sont conservées.
5. Son apparence conserve les évolutions acquises avant son recrutement, notamment celles résultant de ses promotions.

### Statistiques et progression

6. Les statistiques de combat ennemies sont adaptées aux règles applicables aux héros jouables.
7. Les bonus acquis en tant que Némésis ne sont pas systématiquement supprimés, mais adaptés aux contraintes d'équilibrage.
8. Les promotions obtenues avant le recrutement doivent conserver un intérêt tangible après celui-ci.
9. Les bonus provenant des équipements restent distincts des caractéristiques intrinsèques de la recrue.
10. Après son recrutement, la créature évolue selon le système de progression des héros, et non selon celui des ennemis Némésis.

### Capacités et techniques

11. Les capacités caractéristiques de la créature sont conservées lorsqu'elles sont compatibles avec le système de combat des héros.
12. Les capacités incompatibles peuvent être adaptées sans dénaturer leur identité ni leur fonction principale.
13. Les techniques des mini-boss et boss recrutés respectent les contraintes de points d'action, de rangs, de ciblage et de réactions applicables aux héros.
14. Les particularités anatomiques, résistances et vulnérabilités naturelles restent prises en compte.

### Équipements et état physique

15. Le recrutement ne provoque aucune guérison intégrale automatique.
16. Les blessures, amputations et autres conséquences physiques persistent jusqu'à leur résolution par les mécanismes appropriés.
17. Les équipements détenus par la créature restent soumis aux règles de possession et de compatibilité anatomique. Aucun objet ne peut être dupliqué lors du recrutement.

### Relations et persistance

18. La confiance, la loyauté et les caractéristiques relationnelles acquises pendant la captivité sont conservées après le recrutement.
19. La créature recrutée est soumise aux règles de mort définitive des héros.
20. La transition entre ennemi, captif et héros recruté respecte les règles transactionnelles V8.3, sans duplication, réinitialisation arbitraire ni réapparition simultanée de la créature comme ennemi.

### Réconciliation documentaire et préséance

- ARCH-06/V7.44 : distinguer historique des promotions et bonus ennemis adaptés ; après recrutement, progression des héros exclusivement. Ne pas appliquer une nouvelle acquisition de bonus Némésis au héros recruté.
- ARCH-07 : restrictions de capture et recrutement NG+ inchangées pour mini-boss, Némésis et boss.
- V7.34/V7.39 : conserver identité et souvenirs ; la transition de rôle exclut la présence simultanée hostile et alliée.
- V7.35/V7.37 : possession, compatibilité anatomique et unicité des équipements préservées ; devenir précis des équipements incompatibles et trophées reste ouvert.
- V7.58/V7.60 : capture, transport, extraction et garantie de recrutement éligible inchangés.
- V7.67 : anatomie et morphologie conservées ; techniques adaptées aux contraintes des héros, sans trancher les paramètres encore ouverts.
- V7.69 : caractéristiques relationnelles conservées, sans fixer les réactions psychologiques détaillées.
- V8.1/V8.2 : progression et mort définitive des héros applicables après recrutement ; ne pas déduire un niveau initial ni une règle de succession particulière non validée.
- V8.3 : transition cohérente et unique, sans duplication des entités, objets, bonus ou crédits.
- Les hypothèses historiques de copie brute des statistiques ou de réinitialisation intégrale ne sont pas retenues. Les règles V7.84 et suivantes dont la validation est contestée ne sont pas réhabilitées par cette décision.

### Paramètres et arbitrages ouverts

Niveau initial de la créature recrutée ; coefficients de conversion des statistiques et des bonus Némésis ; nombre de techniques conservées ou adaptées ; possibilité de conserver le titre Némésis comme distinction historique ; conséquences psychologiques du recrutement d'un ancien adversaire meurtrier ; mécanismes empêchant l'exploitation volontaire des morts de héros pour renforcer une future recrue. Cas de l'Ange et devenir précis des équipements capturés restent ouverts. Aucun barème numérique validé. Réconciliation documentaire uniquement ; aucun changement moteur, test runtime ou fusion.


## ARCH-09 — Devenir des équipements des ennemis capturés (25 novembre 2026)

**VALIDÉ EN CONCEPTION : option C et vingt règles complémentaires.** Accord direct : « Pour LITD 1, je valide explicitement l'option C de l'arbitrage ARCH-09 concernant le devenir des équipements des ennemis capturés, avec les vingt règles complémentaires proposées. Enregistre le texte intégral et réconcilie les systèmes concernés. »

Le principe consiste à permettre au joueur de récupérer les équipements détenus par les ennemis capturés, indépendamment de leur recrutement, tout en respectant les contraintes physiques, anatomiques et logistiques.

### Capture et désarmement

1. La capture d'un ennemi n'entraîne pas automatiquement le transfert de ses équipements dans l'inventaire du joueur.
2. Le joueur peut désarmer un ennemi capturé lorsque les conditions de sécurité et d'accessibilité le permettent.
3. Les équipements amovibles peuvent être récupérés indépendamment du recrutement de leur détenteur.
4. Les éléments constitutifs de l'anatomie d'une créature ne sont pas considérés comme des équipements amovibles.
5. Les équipements qui participent au maintien en vie, au fonctionnement ou à la contention d'une créature ne peuvent être retirés sans prendre en compte les conséquences de cette action.

### Possession et récupération

6. Chaque équipement persistant conserve son identifiant unique, son état et son historique de possession.
7. Les équipements pillés sur des héros morts peuvent être récupérés auprès de leur nouveau détenteur.
8. Les objets légendaires uniques restent indestructibles et peuvent être récupérés sans nécessiter obligatoirement la mort de leur détenteur.
9. Les trophées conservés par les Némésis peuvent être récupérés lorsqu'ils constituent des objets physiquement accessibles.
10. Les équipements effectivement récupérés sont soumis aux contraintes normales d'inventaire et de transport.

### Transport et détention

11. Les équipements non récupérés restent associés à la créature, sauf événement justifiant un changement de possession.
12. L'évasion, la libération ou la perte d'un captif ne provoque pas la disparition des équipements qui lui ont déjà été retirés.
13. Les équipements encore détenus par un captif perdu ou évadé suivent les règles contextuelles de possession et de persistance.
14. L'arrivée au refuge permet de gérer les équipements restants selon les conditions de sécurité et d'accessibilité, sans transfert automatique au coffre de la Guilde.

### Recrutement et utilisation

15. Une créature recrutée conserve les équipements compatibles qu'elle détient encore au moment de son intégration.
16. Après recrutement, le joueur peut modifier les équipements de la créature selon les règles applicables aux héros et ses particularités anatomiques.
17. Les équipements incompatibles mais physiquement récupérables peuvent être transférés dans l'inventaire sans être détruits ni dupliqués.
18. Les bonus provenant des équipements restent distincts des statistiques intrinsèques, des promotions et des bonus Némésis adaptés conformément à ARCH-08.

### Persistance et intégrité

19. Les changements de possession, l'état des équipements et les conséquences de leur retrait persistent entre les expéditions et après un Game Over.
20. Toute récupération, confiscation, restitution ou modification de possession respecte les règles transactionnelles V8.3, sans duplication, perte artificielle ni nouveau tirage au rechargement.

### Réconciliation documentaire et préséance

- ARCH-04/V7.35 : les équipements des héros abandonnés ou morts suivent leur possession réelle ; récupération auprès du détenteur sans transfert automatique au refuge. Le devenir contextuel des dépouilles reste distinct.
- ARCH-06/V7.37 : distinguer bonus intrinsèques, promotions et propriétés réellement utilisables des équipements ; trophées accessibles récupérables, identité et historique des objets préservés.
- ARCH-07 : aucune dérogation aux restrictions de capture et recrutement en NG+.
- ARCH-08, notamment règles 9 et 17 : préciser le devenir des objets incompatibles et trophées ; conserver les équipements compatibles non retirés ; aucune duplication.
- V7.58 : distinguer capture, sécurisation, récupération, transport et extraction ; les objets déjà retirés ne suivent plus automatiquement le captif ; leur devenir reste soumis aux règles ordinaires de possession, y compris après Game Over.
- V7.60/V7.69 : la confiscation ne doit pas contourner la garantie de recrutement du captif éligible extrait ; conséquences relationnelles à préciser, sans réintroduire un refus définitif contraire à V7.60.
- V8.3 : enregistrer de manière cohérente les transferts, l'état des objets et les conséquences du retrait, sans duplication ni nouveau tirage.
- Les exemples illustratifs ne valident aucun nouvel équipement ni aucune créature. L'indestructibilité des légendaires ne signifie pas immunité aux dommages ni récupération automatique.

### Paramètres ouverts

Coûts en points d'action du désarmement, modalités de fouille, risques du retrait, conséquences sur confiance et loyauté, modalités de retrait chirurgical des équipements intégrés. Aucun barème numérique validé. Réconciliation documentaire uniquement ; aucun changement moteur, test runtime ou fusion.


## ARCH-10 — Réintégration de V7.35 (25 novembre 2026)

**VALIDÉ EN CONCEPTION.** Accord direct : « Pour LITD 1, je confirme explicitement l'option C de V7.35 et ses dix règles historiques intégrales. Réintègre cette section au document maître dans ARCH-10 et réconcilie les systèmes concernés. »

Source historique : commit f558dbf08872128f1c22fb8764a9d954ad877c37, section V7.35 reproduite intégralement ci-dessous. La confirmation du 25 novembre établit la validation explicite actuelle, indépendamment de la preuve de l'accord original.

## V7.35 — Évolution contextuelle des corps et équipements (23 novembre 2026)

**VALIDÉ EN CONCEPTION : option C, évolution contextuelle sous contraintes des corps et équipements, avec les dix règles complémentaires explicitement approuvées.** Le devenir des dépouilles dépend du lieu, des créatures présentes, de l'environnement et des événements depuis la mort : conservation, pillage, disparition ou réanimation hostile selon le contexte.

1. Le devenir des corps persiste après Game Over.
2. Aucun transfert automatique des équipements au coffre de la Guilde.
3. La recomposition procédurale ne supprime pas arbitrairement les dépouilles.
4. Les ennemis peuvent piller selon leur nature et leur comportement.
5. La réanimation nécessite un contexte compatible avec l'univers.
6. Un héros réanimé hostile reste définitivement mort comme héros recrutable.
7. Aucune duplication d'équipement par récupération.
8. Les objets légendaires uniques conservent leur caractère indestructible déjà validé.
9. Les simples allers-retours ne modifient pas artificiellement le devenir d'un corps.
10. La disparition d'une dépouille n'implique pas nécessairement la destruction de tous ses équipements.

Délais, probabilités et utilisation des équipements pillés par les Némésis restent à arbitrer. Exemples de lieux indicatifs uniquement. Préserver la mort définitive et les invariants de sauvegarde V8.3. Validation documentaire uniquement, aucun développement ni test en jeu.


---

### Réconciliation documentaire ARCH-10

- ARCH-02/ARCH-03, V7.38/V7.43 : renouvellement et transformations des cartes compatibles avec le devenir persistant des dépouilles ; aucune suppression arbitraire ni nouveau tirage par simple aller-retour.
- ARCH-04 : distinguer héros vivant abandonné, décès définitif confirmé et dépouille ; les règles de sauvetage du vivant ne constituent pas une résurrection.
- ARCH-06 : le pillage et la possession d'un équipement ne confèrent pas le statut Némésis ; attribution des morts indirectes encore ouverte.
- ARCH-07/ARCH-08 : la réanimation hostile ne rend pas le héros mort recrutable, même en NG+ ; ne pas contourner la mort définitive par adaptation de recrue.
- ARCH-09/V7.37 : récupération et utilisation des équipements selon leur détenteur réel, leur accessibilité et leur compatibilité ; les règles ARCH-09 complètent les questions historiques de récupération. Aucun transfert automatique, aucune duplication ; indestructibilité des légendaires distincte de leur état ou accessibilité.
- V8.1/V8.3 : préserver mort définitive, identité, conséquences et possession ; enregistrer les transitions de dépouille et d'équipement conformément aux invariants transactionnels, sans réapparition artificielle ni recalcul d'un résultat confirmé.
- Délais, probabilités, conditions précises de réanimation et paramètres de pillage restent ouverts ; aucun nouveau barème ni exemple de bestiaire validé. Les contrats CT-0269 à CT-0278 restent à auditer et tester. Réconciliation documentaire uniquement ; aucun changement moteur, test runtime ni fusion.


## ARCH-11 — Réintégration de V7.39 (25 novembre 2026)

**VALIDÉ EN CONCEPTION.** Accord direct : « Pour LITD 1, je confirme explicitement l'option C de V7.39, ses dix règles historiques intégrales, les six comportements territoriaux et la simulation événementielle. Réintègre cette section au document maître dans ARCH-11 et réconcilie les systèmes concernés. »

Source historique : commit f558dbf08872128f1c22fb8764a9d954ad877c37. Section reproduite intégralement ; la confirmation actuelle établit la validation explicite indépendamment de la preuve de l'accord original.

## V7.39 — Mobilité territoriale contextuelle des Némésis (23 novembre 2026)

**VALIDÉ EN CONCEPTION : option C, mobilité territoriale contextuelle des Némésis, dix règles complémentaires et simulation événementielle explicitement approuvées.** Les déplacements dépendent de la nature, des capacités, du comportement et des événements du monde. Comportements possibles : sédentaire, territorial, migrateur, conquérant, fugitif, chasseur, combinables selon la créature.

1. Territoire d'origine enregistré pour chaque Némésis.
2. Déplacements compatibles avec capacités physiques et habitats.
3. Sédentarité complète possible.
4. Migration justifiée écologiquement, comportementalement ou narrativement.
5. Aucun déplacement arbitraire dû uniquement à la régénération des cartes.
6. Recherche par renseignements, témoignages et traces.
7. Équipements transportés suivant leur détenteur.
8. Identité, souvenirs, grade et puissance conservés.
9. Aucune présence simultanée dans plusieurs lieux.
10. Aucun Némésis lié à un objectif obligatoire définitivement inaccessible du fait d'une migration.

Simulation événementielle des déplacements plutôt que simulation permanente de toutes les créatures. Exemples de biomes et itinéraires indicatifs. Préserver la stabilité intra-expédition, la persistance et les invariants de sauvegarde. Paramètres, déclencheurs et tests restent à définir. Validation documentaire uniquement, aucun développement ni test en jeu.


---

### Réconciliation documentaire ARCH-11

- ARCH-01/V7.38 : préserver l'accessibilité des objectifs obligatoires malgré les migrations, sans imposer de mécanisme de déplacement non validé.
- ARCH-02/ARCH-03/V7.43 : renouvellement procédural et transformations contextuelles ne constituent pas à eux seuls une justification de migration ; préserver la stabilité intra-expédition.
- ARCH-05/V7.41 : distinguer fuite volontaire en combat, migration territoriale et rupture de contention ; le comportement territorial fugitif ne crée aucune dérogation aux restrictions de fuite en combat.
- ARCH-06 : conserver identité, souvenirs, rang, promotions et bonus lors des déplacements ; aucune réapparition d'un Némésis définitivement mort.
- ARCH-07/ARCH-08 : restrictions NG+ inchangées ; aucune présence simultanée hostile et alliée après recrutement ; adaptation des caractéristiques selon ARCH-08.
- ARCH-09/ARCH-10/V7.37 : les équipements suivent leur détenteur réel, sans duplication ni transfert automatique ; les objets déjà retirés ne suivent pas le captif.
- V7.27/V7.30 : recherche par renseignements, témoignages et traces, avec distinction entre informations durables et localisation susceptible d'évoluer.
- V8.3 : transitions territoriales persistantes, identité unique et absence de nouveau tirage des résultats confirmés au rechargement.
- Simulation événementielle confirmée, sans imposer une simulation permanente de toutes les créatures. Paramètres, déclencheurs, distances, fréquences, itinéraires et tests restent ouverts. Aucun exemple de biome ni barème numérique nouvellement validé. Contrats CT-0289 à CT-0298 à auditer et tester. Réconciliation documentaire uniquement ; aucun changement moteur, test runtime ni fusion.


## Index de préséance normative — ARCH-03, ARCH-04 et ARCH-07

Clarification documentaire des décisions déjà validées, sans nouvel arbitrage ni suppression des sources historiques.

- ARCH-03 : la décision explicitement validée fait autorité. Les sections historiques V7.19 et V7.24 sont conservées comme provenance ; leur validation indépendante reste à confirmer. Aucune disposition non confirmée ne devient normative par transitivité.
- ARCH-04 : la section « Nouvelle formulation normative » et ses dix-huit règles explicitement validées font autorité. La première transcription incomplète est conservée uniquement pour traçabilité et ne constitue pas une spécification concurrente.
- ARCH-07 : l'extension explicite de la restriction à la capture prévaut sur la formulation antérieure laissant la capture avant NG+ ouverte. Capture et recrutement des mini-boss, Némésis et boss sont réservés au NG+, sous réserve des conditions individuelles d'éligibilité. Les autres dispositions compatibles restent inchangées.

Les textes historiques sont conservés intégralement. Aucun changement moteur ni validation runtime.


---

## ARCH-12 — Attribution des morts indirectes et acquisition du statut Némésis

**Validation explicite : 25 novembre 2026. Option C : responsabilité causale directe et indirecte. Statut : validé en conception, non testé en jeu.**

### Responsabilité et attribution

**Règle 01 — Unicité du responsable**

Une mort définitive ne peut attribuer le statut Némésis qu'à un seul ennemi. Plusieurs ennemis peuvent néanmoins être enregistrés comme contributeurs.

**Règle 02 — Primauté de la causalité**

La responsabilité de la mort prévaut sur la quantité totale de dégâts infligés.

**Règle 03 — Traçabilité des afflictions**

Chaque affliction conserve l'identité de son responsable, son origine et ses éventuelles transmissions.

**Règle 04 — Afflictions cumulées**

Lorsque plusieurs ennemis appliquent une même affliction, leurs contributions respectives restent identifiables.

**Règle 05 — Transmission des afflictions**

Une affliction propagée conserve sa chaîne de causalité. Une intervention indépendante peut toutefois modifier l'attribution finale.

### Pièges, invocations et environnement

**Règle 06 — Pièges installés**

Un ennemi peut devenir Némésis grâce à un piège qu'il a installé, même en son absence.

**Règle 07 — Pièges déclenchés**

Un ennemi déclenchant volontairement un piège pour tuer un héros peut être reconnu comme responsable principal, même s'il n'en est pas l'installateur.

**Règle 08 — Invocations contrôlées**

La mort provoquée par une invocation contrôlée est attribuée à son maître.

**Règle 09 — Invocations autonomes**

Une invocation devenue indépendante peut être reconnue comme responsable si elle possède les caractéristiques nécessaires à l'acquisition du statut Némésis.

**Règle 10 — Utilisation de l'environnement**

Un ennemi utilisant volontairement le décor, le feu, le vide ou un autre danger environnemental pour tuer un héros peut acquérir le statut Némésis.

### Réactions en chaîne et temporalité

**Règle 11 — Déplacements forcés**

Une poussée, une projection ou une traction entraînant une mort définitive engage la responsabilité de son auteur.

**Règle 12 — Réactions en chaîne**

Le système conserve les relations causales entre les événements successifs jusqu'à la résolution de la mort.

**Règle 13 — Intervention déterminante**

Lorsqu'un autre ennemi intervient de manière indépendante et déterminante dans une chaîne causale, il peut devenir le responsable principal.

**Règle 14 — Mort différée**

La fin d'un affrontement ne supprime pas automatiquement la responsabilité d'un ennemi.

**Règle 15 — Rupture de causalité**

Une guérison complète de l'affliction concernée, sa neutralisation ou une nouvelle cause mortelle indépendante peut interrompre la responsabilité initiale.

### Persistance et cohérence narrative

**Règle 16 — Absence de responsable identifiable**

Aucun Némésis artificiel ne doit être créé lorsque la responsabilité ne peut être établie.

**Règle 17 — Responsable déjà mort**

Un ennemi décédé peut être reconnu à titre posthume comme Némésis si une conséquence persistante de ses actions provoque ultérieurement la mort définitive d'un héros.

**Règle 18 — Némésis préexistant**

Un ennemi déjà Némésis conserve son statut. Toute nouvelle mort définitive dont il est responsable enrichit son historique, sans créer de doublon.

**Règle 19 — Conservation dans les Archives**

Les Archives conservent le héros décédé, la cause de sa mort, son responsable et les circonstances pertinentes.

La décision précédemment validée reste applicable : le Némésis conserve définitivement son nom rouge et sa tête de mort rouge dans les Archives, même après sa propre mort.

**Règle 20 — Résolution déterministe**

À situation identique et données identiques, le système doit produire la même attribution. Aucun choix aléatoire ne doit départager les responsabilités.

### Réconciliation documentaire et limites

- Le déclenchement historique par mort définitive est conservé ; ARCH-12 précise l'attribution indirecte, sans modifier les autres exploits majeurs, promotions, fuites ou paramètres de bonus.
- Les invariants V8.3 de causalité persistante, absence de double attribution, journal durable et reprise sans resimulation s'appliquent à la résolution de la mort et à son inscription aux Archives.
- La reconnaissance posthume aux Archives doit être distinguée des crédits personnels posthumes interdits par V8.3. ARCH-12.2 exclut les bonus et promotions posthumes ; aucune résurrection ni récompense nouvelle n'est autorisée par cet addendum.
- Afflictions, pièges, invocations, combat, simulation du monde, sauvegardes, Archives et Némésis doivent partager la provenance causale. Aucun nouveau système parallèle n'est validé.
- Capture et recrutement : confronter ARCH-08 et ARCH-09 avant de fixer les effets d'un changement d'allégeance ou de propriétaire ; ne pas inventer leurs textes historiques.
- ARCH-10 et ARCH-11 : confronter les textes intégraux avant de déclarer la réconciliation exhaustive. Les sections ARCH-01 à ARCH-11 sont présentes dans main ; leur conformité exhaustive aux validations originales reste à certifier.
- Cas de contrôle à préparer : poison différé, afflictions concurrentes, piège à installateur distinct du déclencheur, invocation contrôlée/autonome, changement de maître, chute forcée, chaîne multi-ennemis, guérison, mort environnementale autonome, responsable décédé, Némésis existant, changement d'allégeance, sauvegarde/reprise et déterminisme. Réserve historique conservée : « Les égalités causales non résolues restent à préciser, sans choix arbitraire. » Cette question est résolue en conception par ARCH-12.4 : contributeurs multiples possibles, sans priorité automatique, et zéro ou un responsable principal. La méthode technique de comparaison des contributions reste ouverte.
- Réserve historique conservée : « intégration documentaire proposée ». Après fusion des PR #649, #650 et #651, l’intégration documentaire d’ARCH-12 et des sous-arbitrages est constatée dans `main` au commit `154a80717a78fcd3d3bb02af445429be1524cc01`. Statut actuel : décisions validées en conception ; aucune implémentation technique ni validation runtime ou fonctionnelle attestée. La matrice de traçabilité des 80 règles et les 70 scénarios préparatoires (non exécutés) figurent dans `docs/qa/ARCH12_TRACEABILITY_AND_SCENARIOS_2026-11-26.md`.



## ARCH-12.1 — Responsabilité après recrutement

**VALIDÉ EN CONCEPTION — option C : responsabilité historique sans progression hostile.** Accord explicite du 25 novembre 2026 sur le texte de validation sélectionné et les vingt règles des deux sous-arbitrages.

1. Le recrutement n'efface aucune responsabilité antérieure.
2. Les effets différés conservent leur auteur d'origine.
3. Le changement d'allégeance ne rompt pas automatiquement la chaîne causale.
4. Une mort définitive résultant d'une ancienne action hostile reste attribuée à son responsable.
5. Cette mort est enregistrée dans les Archives et dans l'historique de la recrue.
6. Aucun nouveau bonus Némésis n'est accordé après le recrutement.
7. Aucune promotion hostile ne peut être déclenchée après le recrutement.
8. Les bonus acquis avant le recrutement restent soumis aux règles d'adaptation d'ARCH-08.
9. La recrue conserve son identité unique.
10. Aucun recrutement ne doit permettre de contourner les règles de responsabilité ou de générer artificiellement des bonus.

## ARCH-12.2 — Reconnaissance posthume

**VALIDÉ EN CONCEPTION — option C : reconnaissance exclusivement historique.**

1. Un ennemi décédé peut acquérir le statut Némésis à titre posthume.
2. La mort définitive du héros doit lui être causalement attribuable.
3. Les Archives enregistrent cette reconnaissance et ses circonstances.
4. Les statistiques de l'ennemi restent figées à leur état au moment de sa mort.
5. Aucun bonus statistique posthume n'est accordé.
6. Aucune promotion posthume n'est possible.
7. Cette reconnaissance ne provoque aucune résurrection ni réapparition.
8. Un Némésis déjà décédé peut voir la liste de ses victimes complétée.
9. Aucune nouvelle récompense ne découle automatiquement de cette reconnaissance.
10. L'enregistrement respecte les invariants de sauvegarde V8.3, sans duplication.

### Réconciliation documentaire des sous-arbitrages

- ARCH-01/02/03/04 : persistance des conséquences, état partagé, stabilité des cartes et distinction entre absence et mort confirmée.
- ARCH-05 : aucune modification des restrictions de fuite volontaire ; seuls les Némésis non devenus boss établis sont éligibles sous conditions.
- ARCH-06 : les gains et promotions hostiles restent applicables aux ennemis vivants éligibles ; les exceptions explicitement validées ARCH-12.1/12.2 prévalent après recrutement ou décès.
- ARCH-07/08 : restrictions NG+ inchangées, identité unique et progression des héros après recrutement ; responsabilité historique distincte de la progression hostile. Réserve historique conservée : « Le titre historique d'une recrue auparavant non Némésis reste à préciser. » Cette question de conception est résolue par ARCH-12.3 ; les autres paramètres ouverts d'ARCH-08 restent ouverts.
- ARCH-09/10/11 : possession réelle des objets, devenir des dépouilles, mobilité et simulation événementielle ne réinitialisent pas la provenance causale ; aucune duplication ni réapparition artificielle.
- V8.3 : enregistrer attribution, historique et éventuels gains admissibles exactement une fois ; aucune progression posthume.
- Ces articulations sont des déductions documentaires, non des arbitrages supplémentaires. Sources ARCH-03 à ARCH-11 : PR #647 fusionnée ; consolidation ARCH-12 fusionnée via #649. Le verbatim des vingt règles initiales ARCH-12 et la provenance du marquage rouge des Archives restent à vérifier. Aucun test runtime ni changement moteur revendiqué.


### Consolidation après fusion de la PR #647

Les sections ARCH-01 à ARCH-11 et l'index de préséance sont conservés intégralement depuis main. La PR #647 est fusionnée (3e853717070ac35e958c3f3d69bc5e73e2a7f45e). Les réserves historiques et les paramètres ouverts restent applicables. ARCH-12.1 et ARCH-12.2 précisent les exceptions de progression d'ARCH-06 sans modifier ARCH-05. Aucun changement moteur.


## ARCH-12.3 — Acquisition historique du statut Némésis après recrutement

**VALIDÉ EN CONCEPTION — option C : acquisition exclusivement historique.** Validation explicite du 25 novembre 2026.

Un ennemi recruté peut être reconnu comme Némésis pour les conséquences de ses anciennes actions hostiles, sans retrouver son statut actif d'ennemi.

| Nº | Règle | Description |
|---:|---|---|
| 1 | Acquisition historique | Une recrue auparavant non Némésis peut acquérir cette reconnaissance historique si une action hostile antérieure au recrutement provoque la mort définitive d'un héros. |
| 2 | Conservation du statut actif | La recrue conserve son statut de héros recruté et ne redevient pas un ennemi. |
| 3 | Antériorité obligatoire | L'action à l'origine de la mort doit avoir été effectuée avant le recrutement, durant une période d'hostilité. |
| 4 | Reconnaissance dans les Archives | Les Archives enregistrent le statut historique de Némésis, l'identité de la victime, la cause de sa mort et les circonstances. |
| 5 | Absence de bonus | Cette reconnaissance n'accorde aucun nouveau bonus statistique Némésis. |
| 6 | Absence de promotion | Elle ne déclenche aucune promotion dans la hiérarchie des ennemis. |
| 7 | Absence de capacité de fuite | Elle ne confère aucune capacité de fuite réservée aux Némésis actifs. Les règles de retraite des héros restent applicables. |
| 8 | Progression inchangée | La recrue continue exclusivement sa progression selon les systèmes applicables aux héros recrutés. |
| 9 | Identité et historique uniques | La reconnaissance complète l'historique de l'entité existante, sans créer de nouvelle entité ni de fiche Némésis indépendante. |
| 10 | Persistance | Cette reconnaissance historique reste conservée après la mort définitive de la recrue, une sauvegarde, un chargement ou un Game Over. |

## ARCH-12.4 — Résolution des responsabilités causales équivalentes

**VALIDÉ EN CONCEPTION — option C : hiérarchie causale déterministe.** Validation explicite du 25 novembre 2026.

Le système doit identifier le véritable responsable d'une mort définitive lorsque plusieurs ennemis y ont contribué, sans attribution arbitraire.

| Nº | Règle | Description |
|---:|---|---|
| 1 | Analyse causale obligatoire | Toute mort définitive impliquant plusieurs responsables potentiels fait l'objet d'une résolution causale. |
| 2 | Cause effective | Le système identifie en priorité les événements et les effets ayant effectivement provoqué la mort. |
| 3 | Responsabilité réelle | La responsabilité est déterminée par la chaîne causale, indépendamment du caractère direct ou indirect de l'attaque. |
| 4 | Intervention déterminante | Une intervention indépendante et décisive peut attribuer la responsabilité principale à son auteur. |
| 5 | Contribution causale | Lorsque plusieurs effets sont conjointement responsables, le système examine leurs contributions respectives à la mort. |
| 6 | Dégâts non prioritaires | La quantité totale de dégâts infligés ne constitue jamais, à elle seule, un critère suffisant de départage. |
| 7 | Chronologie non prioritaire | Le premier ou le dernier attaquant ne bénéficie d'aucune priorité automatique. La chronologie sert uniquement à établir la causalité. |
| 8 | Égalité irréductible | Si aucun responsable principal ne peut être objectivement distingué, tous les responsables identifiés sont enregistrés comme contributeurs. |
| 9 | Absence de récompense artificielle | Une égalité irréductible n'accorde aucun nouveau statut, bonus ou promotion Némésis au titre de cette mort. Les statuts précédemment acquis restent inchangés. |
| 10 | Déterminisme et persistance | La résolution et ses justificatifs sont enregistrés durablement. Une sauvegarde ou un chargement ne doit jamais permettre de recalculer arbitrairement l'attribution. |

### Réconciliation et préséance documentaire

- ARCH-12.3 résout la réserve sur le titre historique d'une recrue auparavant non Némésis dans ARCH-12.1 et la réconciliation ARCH-07/08. Elle ne tranche pas les autres paramètres ouverts d'ARCH-08.
- ARCH-05 : la reconnaissance historique ne donne aucun droit de fuite hostile ; les restrictions des Némésis actifs et des boss établis restent inchangées. La correction historique du 18 novembre autorisant la fuite des ennemis non Némésis est remplacée sur ce point par ARCH-05.
- ARCH-06 : l'acquisition active et les gains hostiles restent réservés aux entités éligibles ; ARCH-12.1 à 12.4 précisent les exceptions historiques et les égalités irréductibles.
- ARCH-12.4 résout la réserve sur les égalités causales dans ARCH-12 : zéro ou un responsable principal, contributeurs multiples possibles ; aucune priorité automatique directe, chronologique ou quantitative.
- ARCH-04/07/09/10/11 : mort définitive, restrictions NG+, possession des équipements, dépouilles et simulation événementielle inchangées.
- V8.3 et Archives : conserver identité, provenance, justification et résolution durable sans duplication ni nouveau tirage au chargement.
- Cas de contrôle à préparer : poison antérieur au recrutement, recrue décédée, deux poisons conjointement mortels, Némésis existants à égalité, intervention indépendante, piège à installateur distinct du déclencheur, environnement sans responsable, sauvegarde/reprise. Aucun test runtime effectué.
- Réserve historique conservée : « La méthode technique de comparaison des contributions causales, le changement de maître d'une invocation et la provenance historique du marquage rouge restent à préciser ou vérifier. » ARCH-12.5 résout en conception la question du transfert de responsabilité selon le maître au moment de l'action. Restent ouverts les paramètres techniques de prise de contrôle, durée, coût, résistance et autonomie, ainsi que la méthode de comparaison causale et la provenance antérieure du marquage rouge. Le verbatim des vingt règles initiales ARCH-12 reste à certifier. Ces réserves ne sont pas de nouvelles décisions.


### Vérification de provenance — règle 19 ARCH-12

La formulation de la règle 19 retrouvée dans la proposition du 25 novembre 2026 correspond au texte enregistré. La validation explicite des vingt règles couvre le nom rouge et la tête de mort rouge permanents dans les Archives, y compris après le décès du Némésis. La source indépendante antérieure à ARCH-12 reste à retrouver ; les dix-neuf autres formulations initiales restent à certifier mot pour mot. Aucun nouvel arbitrage.


## ARCH-12.5 — Changement de maître des invocations

**VALIDÉ EN CONCEPTION — option C : responsabilité du maître au moment de l'action.** Validation explicite du 25 novembre 2026.

Le principe est de conserver la responsabilité causale de chaque action d'une invocation, indépendamment de ses changements ultérieurs de maître, d'allégeance ou d'autonomie.

### Identification et conservation de la responsabilité

| Nº | Règle | Description |
|---:|---|---|
| 1 | Maître au moment de l'action | Chaque action d'une invocation contrôlée est attribuable au maître qui exerce effectivement son contrôle au moment de cette action. |
| 2 | Identification unique | L'invocation et chacun de ses maîtres disposent d'une identité permettant de retracer leurs responsabilités respectives. |
| 3 | Conservation de l'origine | Chaque action conserve son auteur physique, son responsable causal et son contexte de contrôle. |
| 4 | Effets différés | Les afflictions et autres conséquences persistantes restent attribuables au maître responsable de l'action initiale. |
| 5 | Absence de rétroactivité | Un changement de maître ne transfère jamais automatiquement les responsabilités associées aux actions antérieures. |

### Changements de contrôle

| Nº | Règle | Description |
|---:|---|---|
| 6 | Nouveau maître | Les nouvelles actions contrôlées après un transfert relèvent du nouveau maître. |
| 7 | Changements successifs | Une invocation peut changer plusieurs fois de maître sans perdre l'historique de ses responsabilités. |
| 8 | Contrôle temporaire | Une prise de contrôle temporaire attribue au contrôleur effectif les actions réalisées pendant cette période. |
| 9 | Retour au maître précédent | La récupération du contrôle ne modifie pas les responsabilités acquises durant la période intermédiaire. |
| 10 | Contrôle contesté | Lorsque plusieurs entités exercent simultanément une influence, la responsabilité est établie par l'analyse causale réelle, conformément à ARCH-12.4. Aucun maître n'est désigné arbitrairement. |

### Autonomie et disparition du maître

| Nº | Règle | Description |
|---:|---|---|
| 11 | Invocation autonome | Une invocation devenue indépendante assume la responsabilité de ses nouvelles actions autonomes. |
| 12 | Éligibilité au statut Némésis | Une invocation autonome ne peut acquérir le statut Némésis que si elle satisfait aux conditions générales d'éligibilité. |
| 13 | Mort du maître | Le décès du maître ne supprime pas les responsabilités liées aux actions effectuées sous son contrôle. |
| 14 | Reconnaissance posthume | Si une ancienne action contrôlée provoque ultérieurement la mort définitive d'un héros, le maître décédé peut être reconnu conformément à ARCH-12.2. |
| 15 | Disparition de l'invocation | La disparition, la révocation ou la destruction de l'invocation n'efface pas les conséquences persistantes de ses actions antérieures. |

### Recrutement, attribution et persistance

| Nº | Règle | Description |
|---:|---|---|
| 16 | Recrutement du maître | Son recrutement n'efface pas ses anciennes responsabilités hostiles. ARCH-12.1 et ARCH-12.3 restent applicables. |
| 17 | Changement d'allégeance de l'invocation | Le recrutement ou le changement de faction d'une invocation ne réattribue pas ses anciennes actions. |
| 18 | Réactions en chaîne | Les interventions indépendantes ultérieures sont examinées conformément aux règles générales d'ARCH-12 et d'ARCH-12.4. |
| 19 | Unicité de l'attribution | Une même mort définitive ne peut produire plusieurs attributions principales du statut Némésis. L'invocation et son maître ne reçoivent pas simultanément les bénéfices associés à une même responsabilité. |
| 20 | Persistance et déterminisme | L'historique du contrôle, les responsabilités causales et les résultats d'attribution sont conservés durablement, sans duplication ni modification arbitraire lors d'une sauvegarde, d'un chargement ou d'un Game Over. |

### Réconciliation documentaire et préséance

- ARCH-12.5 précise les règles 08 et 09 d'ARCH-12 : le maître pertinent est le contrôleur effectif au moment de l'action, non celui au moment de la mort. La réserve sur le changement de maître est résolue en conception.
- ARCH-05/06 : aucune nouvelle autorisation de fuite ni modification des conditions générales d'acquisition du statut Némésis.
- ARCH-07/08/09 : restrictions NG+, progression des recrues et règles de possession des équipements inchangées ; aucun transfert automatique d'équipement.
- ARCH-11 : conserver les événements et conséquences persistantes.
- ARCH-12.1/12.2/12.3 : responsabilité historique après recrutement ou décès, sans progression hostile ou posthume interdite.
- ARCH-12.4 : contrôle contesté et contributions multiples résolus sans attribution arbitraire ; zéro ou un responsable principal.
- Archives, afflictions et sauvegardes : conserver les identités, le contexte de contrôle, les responsables d'origine et les résultats durables sans duplication.
- Les conditions de prise de contrôle, sa durée, son coût, les résistances et l'accès à l'autonomie restent à concevoir. Aucun mécanisme de contrôle supplémentaire n'est validé.
- Cas de contrôle à préparer : poison avant transfert, attaque après transfert, contrôle temporaire, retour au maître précédent, décès ou recrutement du maître, autonomie, destruction de l'invocation, égalité causale, sauvegarde pendant transfert.
- La comparaison technique des contributions causales, les preuves historiques encore manquantes et les tests runtime restent ouverts. Aucun changement moteur ni validation technique revendiqués.

## REFONTE-COMP-01 — Bloc 02 : initiative hybride (validation utilisateur du 26 novembre 2026)

Modèle E et INIT-01 à INIT-20 explicitement validés en conception. Les identifiants sont locaux à ce bloc.

- INIT-01 : Un tour correspond au créneau individuel d'un combattant.
- INIT-02 : Un round correspond au cycle des tours de tous les combattants admissibles.
- INIT-03 : Chaque combattant dispose normalement d'un seul tour par round.
- INIT-04 : Le PA inutilisé à la fin du tour est perdu.
- INIT-05 : L'initiative est recalculée au début de chaque round.
- INIT-06 : Elle dépend des caractéristiques et de l'état réel du combattant.
- INIT-07 : Une composante aléatoire limitée apporte de l'incertitude.
- INIT-08 : L'ordre d'initiative est visible par le joueur.
- INIT-09 : L'ordre est verrouillé pendant le round.
- INIT-10 : Les modifications ordinaires d'initiative prennent effet au round suivant.
- INIT-11 : Priorité au combattant possédant la meilleure initiative avant aléatoire.
- INIT-12 : En cas d'égalité persistante, tirage de départage reproductible et mémorisé.
- INIT-13 : Aucun avantage systématique accordé aux héros ou aux ennemis.
- INIT-14 : Un combattant mort avant son tour perd définitivement son action.
- INIT-15 : Une incapacité est évaluée lorsque le combattant atteint son tour.
- INIT-16 : Les nouveaux combattants rejoignent normalement l'ordre d'initiative au round suivant.
- INIT-17 : Un changement de contrôle ne renouvelle ni le tour ni le PA du combattant.
- INIT-18 : Les résultats des tirages d'initiative sont conservés dans la sauvegarde.
- INIT-19 : Une reprise de partie ne déclenche aucun nouveau tirage pour le round en cours.
- INIT-20 : Aucun changement d'état, de rang ou de contrôle ne crée automatiquement un PA supplémentaire.

Préséance : complète V4.2–V4.5 ; un PA unique, attaque préventive imputée au premier tour, bonus collectif léger de guet-apens limité au premier round. Compatible avec ARCH-12.5 : aucun renouvellement par transfert de contrôle. Les coefficients, amplitude numérique, réactions, interruptions et exceptions spécifiques restent ouverts. Aucun ancien catalogue de classes, armes, armures ou compétences réintroduit. Aucun test runtime exécuté.

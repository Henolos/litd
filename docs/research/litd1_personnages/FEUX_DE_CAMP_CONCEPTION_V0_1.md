# LITD 1 — Feux de camp : conception V0.1

**2026-11-18 — Principes narratifs du prologue validés ; règles chiffrées et implémentation non validées, non testées.**

## Objectifs
Créer un système de halte qui associe récupération limitée, cuisine, préparation et relations entre compagnons, sans supprimer la difficulté de l'expédition. La présence d'un feu de camp ne garantit pas la sécurité.

## Boucle proposée
1. Trouver un emplacement de campement adapté. Le tutoriel du prologue propose un emplacement fixe ; les conditions de campement ultérieures restent à décider.
2. Installer le camp et consommer les ressources nécessaires (provisions ; combustible si ce coût est retenu).
3. Choisir des actions : manger, soigner, discuter, examiner l'inventaire ; après le prologue, préparer soi-même un repas grâce au carnet de Mara. Pendant le prologue, Mara cuisine pour le groupe.
4. Appliquer les effets de récupération partielle et les éventuels bonus temporaires. Ne pas remettre automatiquement toute la santé ou toutes les ressources à leur maximum.
5. Lever le camp et reprendre l'exploration.

## Règles provisoires
- **Repas :** nécessite des ingrédients ou des rations ; récupération ou bonus selon la recette, valeurs à équilibrer.
- **Sommeil :** action supprimée par décision utilisateur du 18 novembre 2026 ; aucun bouton « Dormir » ni récupération par sommeil.
- **Récupération :** liée aux repas et aux soins selon des valeurs encore à équilibrer ; aucune récupération gratuite illimitée.
- **Soins :** utilisation possible de remèdes ou d'aptitudes ; les blessures persistantes ne disparaissent pas automatiquement.
- **Interactions :** conversations facultatives, contextualisées selon les compagnons, événements et choix ; aucun lien obligatoire avec une jauge de relation.
- **Sécurité :** distinguer les emplacements sécurisés et les camps improvisés ; risque d'interruption à étudier, pas encore validé.
- **Fréquence :** limiter les abus de récupération ; méthode exacte à choisir après tests.
- **Sauvegarde :** ne pas supposer que le camp crée un nouveau système de sauvegarde ; réutiliser et vérifier le système existant avant toute décision.

## Intégration au prologue « La Cueillette »
Après une période d'exploration et quelques combats adaptés au niveau de la compagnie, Mara propose une halte et prépare elle-même le repas. Le joueur ne dispose pas encore de cuisine autonome. Le joueur apprend les actions de base autour du feu (hors cuisine autonome) et partage un repas avec Wei, Mara et Sami (noms provisoires, non validés). Cette scène sert à mieux connaître les compagnons et à présenter la récupération limitée. Le groupe reprend ensuite la cueillette, récupère le dernier champignon, puis commence le chemin du retour. L'élite attaque **plus tard sur le retour**, tue les trois compagnons, évolue en Némésis/mini-boss et fuit. Une partie des champignons est perdue pendant l'affrontement ; le survivant reçoit seulement la moitié de la prime.

## Contraintes de cohérence
- Monde cosmopolite ; direction artistique sino-gothico-dark fantasy dominante, sans uniformiser l'origine des personnages.
- Ne pas modifier les mécaniques de combat, d'afflictions, de sauvegarde ou d'inventaire sans inventaire préalable de l'existant.
- Les coûts, pourcentages de récupération, recettes, modalités de récupération, risques d'embuscade et restrictions d'usage sont **à définir**, pas validés.
- Le camp du prologue ne doit pas déclencher l'embuscade finale ni rendre la mort des compagnons évitable par un simple choix de repos.
- Les compagnons doivent avoir des échanges naturels, et pas seulement exposer des règles.

## Validation et implémentation futures
1. **Validation de conception :** arrêter les règles de coût, sécurité, récupération, fréquence, cuisine et blessures (sans sommeil).
2. **Audit Godot en lecture seule :** repérer scènes, systèmes d'inventaire, soins, ressources, sauvegarde et tests existants ; éviter les systèmes parallèles.
3. **Implémentation minimale :** réutiliser les composants existants, ajouter le camp et ses interactions sans toucher aux références artistiques validées.
4. **Tests :** coûts réellement déduits, récupération plafonnée, impossibilité d'exploits de repos, état persistant après sauvegarde/chargement, interactions, absence de régression du combat, test en jeu du prologue.
5. **Validation visuelle et de difficulté :** contrôle humain et playtest ; aucune validation de production avant preuves.

**Statut :** conception documentaire seulement ; aucune implémentation ou exécution de test revendiquée.

## Décision utilisateur du 18 novembre 2026
L'action **« Dormir » est retirée** du système de feu de camp. La halte reste dédiée à la cuisine, aux repas, aux soins, aux provisions et aux conversations. Ne pas réintroduire de récupération par sommeil lors de l'implémentation.

## Continuité narrative validée : les trois carnets et la fin du prologue

- Au premier feu de camp, **Mara cuisine** et raconte son ambition d'ouvrir une auberge et de devenir une grande cheffe. Son passé dans des cuisines où elle n'était pas reconnue explique pourquoi elle prend des missions dangereuses.
- **Wei** consigne ses exercices et ses rêves de devenir un grand héros dans un carnet de techniques. Il cherche une issue à la précarité.
- **Sami** consigne ses observations dans un carnet de recherches, première pierre de son rêve de partager le savoir avec tous.
- Le joueur peut utiliser les compétences de départ, manger, se soigner et discuter au prologue, mais **ne monte pas de niveau** ; l'XP gagnée est conservée de façon invisible, sans jauge ni notification. **Aucun Journal de quêtes** pendant le prologue.
- Sur le chemin du retour, après la récolte complète, l'élite tue les trois compagnons, évolue en Némésis puis fuit. Le survivant peut récupérer **les trois carnets** dans une séquence grave et sobre. La récupération est nécessaire à la continuité des fonctions, mais la manière de la mettre en scène et les interactions facultatives restent à concevoir.
- **Après la conclusion à la Guilde**, le carnet de Wei débloque Techniques et progression, celui de Mara la cuisine autonome aux feux de camp, celui de Sami Archives, Bestiaire et Journal de quêtes. Les détails d'interface, la répartition des onglets et l'application de l'XP différée relèvent du chantier gameplay, pas du scénario.
- La Guilde n'est pas intrinsèquement corrompue. L'absurdité et le cynisme appartiennent au monde. Le rang S (« Stagiaire », rang le plus bas) et l'omelette personnelle du maître ne sont révélés **qu'au retour final**, jamais pendant le feu de camp ou la récolte.
- **Aucune action « Dormir »**, même après le déblocage de la cuisine.

**Portée :** décisions narratives consignées ; aucun script, écran ou test de gameplay créé par cette modification.

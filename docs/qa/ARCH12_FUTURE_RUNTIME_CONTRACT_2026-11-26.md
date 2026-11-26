# ARCH-12 — contrat d’acceptation du futur runtime (candidat)

Date : 26 novembre 2026  
Statut : proposition technique non normative, à valider avant toute implémentation.  
Base de conception contrôlée : `main` à `e9be0c5959077d748793d68b275fee5d1cc75aaa`.  
Source des décisions : `docs/conception/LITD1_DOCUMENT_MAITRE.md`, blob `e791e4d0bd1a21b8202a75eb18053d9deef3b35d`.  
Scénarios : `docs/qa/ARCH12_FUNCTIONAL_TEST_SPEC_2026-11-26.md`, branche de préparation ARCH-12.  
Garde-fou : ne reprendre aucun code, interface, donnée ou règle supprimé de `main` lors de la remise à zéro.

## 1. Objet et limites

Ce contrat décrit les capacités nécessaires pour qu’un runtime de production LITD 1 puisse porter ARCH-12 et rendre les oracles déterminés vérifiables. Il ne constitue pas un runtime, ne choisit pas une architecture de code définitive et ne valide aucune règle de gameplay supplémentaire.

Le runtime devra être construit sur la base actuelle du dépôt, dans le projet Godot courant, après vérification des composants et responsabilités déjà présents. Il devra devenir l’unique chemin autoritaire de résolution du combat concerné; un validateur ou une simulation séparée ne devra pas se substituer à son comportement.

La spécification actuelle classe 39 oracles O, 31 P et 0 D dans les 70 scénarios candidats. O signifie résultat déterminé sous préconditions satisfaites, pas implémentation déjà disponible. Les P et les décisions ouvertes restent non testables tant qu’elles n’ont pas été décidées.

## 2. Frontière du runtime

Le runtime doit exposer une frontière permettant au harnais de :

1. préparer un état de rencontre avec identifiants de fixture stables;
2. injecter une action ou un événement de domaine par l’API autoritaire du runtime;
3. avancer le traitement jusqu’à un point de résolution explicite, sans utiliser de délai réel;
4. lire le résultat de résolution et l’état durable correspondant;
5. sauvegarder, recharger puis relire ce même état sans rejouer les événements déjà consommés.

Le harnais ne doit pas modifier directement les résultats internes, attribuer lui-même les responsables, ni fabriquer les entrées d’Archives attendues. Les doubles et fixtures sont autorisés uniquement à la frontière d’injection documentée; la résolution reste celle du runtime.

Les noms et types des fonctions sont libres. Leur correspondance avec ces capacités doit être vérifiable sur le code et les tests.

## 3. Contrat minimal d’observation

Pour chaque événement pertinent pour ARCH-12, la sortie observable doit permettre de reconstituer, directement ou par références stables :

- l’identifiant unique de l’événement et son ordre logique;
- l’entité ayant physiquement agi et la cible concernée;
- le maître/propriétaire et la faction effectifs au moment de l’action, s’ils sont pertinents;
- l’effet créé ou modifié et son état au moment observé;
- les liens vers l’événement d’origine et les événements parents nécessaires à la chaîne causale;
- les transitions qui maintiennent, neutralisent, guérissent, remplacent ou terminent l’effet, lorsqu’elles surviennent;
- l’événement de mort définitive et sa résolution;
- la liste des contributeurs identifiés et zéro ou un responsable principal;
- l’entrée d’Archives résultante et son lien vers le héros, le responsable et les circonstances;
- le résultat équivalent après sauvegarde et reprise.

Ces champs sont des exigences d’observabilité. Ils ne dictent ni le format sérialisé, ni le stockage, ni le calcul de responsabilité.

## 4. Invariants testables issus des règles validées

Le runtime et son harnais devront démontrer sur fixtures contrôlées que :

- une mort définitive ne crée jamais plusieurs responsables principaux;
- la responsabilité ne se réduit pas au total des dégâts;
- les sources et transmissions d’afflictions demeurent traçables;
- la fermeture d’un combat n’efface pas une conséquence persistante;
- une cause initiale neutralisée ou guérie ne reste pas créditée automatiquement;
- pièges, invocations, environnement et déplacements forcés peuvent être suivis jusqu’à leurs événements de conséquence lorsqu’un oracle O le détermine;
- l’absence de responsabilité démontrable ne crée pas un Némésis artificiel;
- la reconnaissance historique dans les Archives ne déclenche à elle seule ni résurrection ni bonus posthume;
- un Némésis existant et ses Archives ne sont pas dupliqués par des événements répétés ou une reprise;
- deux exécutions avec mêmes entrées, état et ordre logique produisent le même résultat et les mêmes justifications observables.

La couverture doit être publiée par identifiant S01–S70, avec pour chaque cas son statut O/P/D, ses préconditions, le hook utilisé, l’assertion et la preuve d’exécution.

## 5. Contrôles de persistance et de déterminisme

Les tests doivent inclure des comparaisons avant/après sauvegarde et reprise pour les événements et archives concernés. La reprise doit préserver les identifiants et empêcher le double traitement d’un décès déjà résolu. Le détail des migrations et le format de sauvegarde sont à intégrer au contrat de persistance réellement présent sur `main`, après inspection; ce document n’impose pas de nouvelle version de schéma.

Le moteur doit offrir un contrôle déterministe du temps logique, de l’ordre des événements et des sources aléatoires pertinentes. Les tests comparent aussi les contributeurs, le responsable principal et la chaîne causale, pas uniquement le stade final.

## 6. Points expressément laissés ouverts

Ce contrat ne fixe pas :

- la méthode quantitative ou qualitative de comparaison des contributions causales;
- le traitement de l’égalité ou la frontière exacte de simultanéité;
- le seuil d’une intervention indépendante « déterminante »;
- la preuve en jeu d’une intention volontaire pour le déclenchement d’un piège;
- les seuils, poids, bonus ou paramètres des promotions Némésis;
- les effets d’un changement d’allégeance qui dépendent des règles ARCH-08/09 non réconciliées;
- les oracles P et tout point déclaré ouvert dans le document maître.

Aucun contrôle ne doit inventer ces résultats pour faire passer une suite.

## 7. Intégration et critères d’acceptation

Avant de déclarer une liaison ARCH-12 fonctionnelle, il faut :

1. identifier le runtime réellement utilisé par le combat de production courant et ses responsabilités existantes;
2. présenter une architecture qui s’intègre à ces responsabilités sans créer de seconde autorité de combat, de provenance ou d’Archives;
3. valider cette architecture comme nouveau travail sur la base actuelle, sans restaurer de contenu supprimé au reset;
4. implémenter les hooks nécessaires dans ce runtime autoritaire;
5. relier chaque oracle O à une fixture réellement injectée et à une sortie réellement observée;
6. exécuter les tests dédiés et les contrôles du dépôt, en conservant les logs et les SHA;
7. laisser explicitement P/D en attente et rapporter les limites.

Tant que ces étapes ne sont pas satisfaites, les tests du modèle de référence, les smoke généraux Godot et les anciens artefacts historiques ne constituent pas des preuves d’exécution ARCH-12.

## 8. Décision proposée

**Candidat de contrat technique à examiner** — ne vaut ni approbation du runtime, ni autorisation de modifier le gameplay. La décision suivante est de vérifier la structure actuelle de `main` et de proposer le point d’intégration du nouveau runtime avant toute implémentation.

# LITD 1 — Réconciliation du bestiaire (11 novembre 2026)

> Les sections initiales ci-dessous sont un historique. La mise à jour courante en fin de document remplace leurs demandes de revalidation et leurs statuts techniques dépassés.

## Périmètre et preuves
Contrôle documentaire des registres de PR #607 et #608. Aucun binaire artistique importé ou validé par ce document. Les 68 images existantes dans main et les deux branches ne constituent pas une archive des planches du bestiaire (constat de l'audit Work communiqué par l'utilisateur).

## Divergences à résoudre avant classement validated/
- **Kitsune** : catalogue historique de #607 = n°22 ; décision ultérieure documentée dans `docs/art/validated_plates_20261110.md` = **n°26**. La planche source candidate n'est pas nécessairement la planche corrigée n°26. Ne pas renommer ou valider la candidate automatiquement.
- **Draugr** : catalogue historique de #607 = n°16 ; planches ultérieures signalées n°21. Confirmer la source visuelle exacte et mettre à jour la table canonique, sans réattribuer n°21 au Kitsune.
- **Golem runique** : `docs/art/validated_plates_20261110.md` = en attente ; une validation ultérieure est mentionnée dans la PR #608. Vérifier chronologie, texte exact et **image précise** avant de considérer la planche finale comme validée.
- **Wendigo / Loup décharné** : une tête de loup cadavérique est documentée comme validée ; contrôler la correspondance du fichier et la dénomination canonique, sans substituer une variante à tête de cerf.
- **Valkyrie spectrale** : n°23 documenté comme validé ; correspondance binaire exacte à vérifier.
- **Troll** : pistes artistiques validées, ce qui ne suffit pas à déclarer une planche définitive archivée.
- **Référence de présentation** : registre initial de #607 = Basilic ; une référence Hydre n°13 est également évoquée dans le suivi ultérieur. Vérifier l'ordre et la portée des décisions, ne pas remplacer arbitrairement l'une par l'autre.

## Candidats locaux documentés, non archivés dans GitHub
| Créature | Nom original | SHA-256 |
|---|---|---|
| Kitsune | `a_detailed_ornate_fantasy_bestiary_info_card_in.png` | `507ad80453e5ab1640ff68c264651be6dabe2b7fe0dab7bc1bdfb9a503dde09b` |
| Wendigo | `planche_concept_art_du_wendigo_glacé.png` | `8e8412b4f28471fb65e5d1548b697573cd7a7868484a109ffb786e97976cd9ea` |
| Troll | `56E54133-57CA-41CB-B514-0D740FE55DD2.jpeg` | `8ce2c11e61f917bce5fb62af2fd2bf762383f60329c3f6ae854ff959c781ad9c` |
| Valkyrie | `fiche_de_bestiaire_valkyrie_spectrale.png` | `e43c42f7f0593e32468f4e0400a35af38d96f42917dcc8b3ad1623abc44a2015` |

## Conditions d'archivage et d'automatisation
1. Identifier la version source exacte approuvée ; placer les versions incertaines dans `assets/art/bestiary/to_review/`.
2. Importer les originaux sur une branche dédiée, sans modifier les 68 images préexistantes.
3. Calculer et comparer SHA-256 après récupération depuis GitHub ; enregistrer chemins, numéros, tailles, statut, preuve de décision.
4. Ajouter un contrôle CI des chemins, empreintes et unicité des numéros canoniques. Le déclencher sur `pull_request` et `merge_group` si requis par la merge queue.
5. Fusionner exclusivement via les protections de `main`, puis réaliser une sauvegarde indépendante des fichiers originaux.

## État
- Réconciliation **documentaire partielle** : divergences identifiées ; décisions historiques et images finales non intégralement recoupées.
- Images importées dans ce chantier : **0**.
- Contrôles CI créés : **0**.
- Avancement du chantier actuel : **À évaluer**.
- Avancement global LITD : **À évaluer**.

## Contrôle des sept sources locales — 2026-11-11

Archive locale examinée : `litd_sources_retrouvees_20261111.zip` ; **sept images**, toutes rangées dans `to_review/` dans l'archive. Aucun de ces binaires n'est présent dans cette PR.

- **Kitsune n°26** : `same_layout_and_art_as_the_previous_kitsune_sheet.png` ; 1536 × 1024 ; SHA-256 `64e5abdb0b1e84f6c0c8646bd9f8b380b831bb46b9e310f4ef9b2f6bedb2015b`. La planche porte le numéro et la mention de validation attendus. Correspondance documentaire forte ; la présence dans GitHub reste à vérifier après import.
- **Valkyrie n°23** : trois variantes (`LITD1_Valkyrie_23_harmonisee.jpg`, `LITD1_Valkyrie_spectrale_23.jpg`, `LITD1_Valkyrie_spectrale_23.png`). Version définitive non départagée.
- **Golem runique** : `bestiaire_du_golem_runique.png` ; version affichant une attente de validation, décision ultérieure à rapprocher.
- **Wendigo** : `planche_concept_art_du_wendigo_glacé.png` ; confirmer que la tête de loup cadavérique est celle de la planche approuvée.
- **Troll** : `56E54133-57CA-41CB-B514-0D740FE55DD2.jpeg` ; validation des pistes ne suffit pas à confirmer une planche définitive.

**Décision de classement :** les sept fichiers restent `to_review/` tant que leur importation et leur correspondance finale ne sont pas vérifiées ; Kitsune n°26 est le premier candidat au déplacement vers `validated/` après import.

**Blocage technique observé :** l'environnement local ne résout pas `github.com` et le connecteur GitHub disponible pour les modifications de fichiers accepte uniquement le texte UTF-8. Le transfert binaire n'a donc pas été effectué. Ne pas annoncer d'images archivées.


## Reprise après fusion de #610 — état courant

### Réalisé et vérifié

- Main recontrôlé après la fusion `23fabf00` ; #606, #607, #608 et #609 toujours ouverts en brouillon au début de la reprise. Main est intégré à cette branche sans réécriture de l’historique.
- Lecture croisée des trois registres, de l’inventaire des pièces et de l’audit binaire. Un manifeste JSON rapproche les 21 références documentées, leurs noms de fichiers, empreintes **attendues** et sources immuables : `reconciled_bestiary_manifest_20261111.json`.
- La règle permanente du propriétaire prime : toute planche qu’il transmet est officielle, une version plus récente remplace l’ancienne. Aucune revalidation artistique n’est demandée. L’identité des octets et l’ordre des versions restent des vérifications techniques distinctes.
- Le manifeste ne compte pas deux fois Wendigo et Loup décharné ; son entrée n°24 désigne le JPEG à tête de loup, pas le PNG glacé candidat. Kitsune conserve le n°26, Draugr le n°21. La Valkyrie harmonisée est identifiée par l’empreinte de #608. Le Golem n’est plus déclaré artistiquement en attente sur la seule foi d’une mention imprimée ancienne.
- Les 40 créatures de conception (25 classiques + 10 hybrides + 5 boss) ne sont pas assimilées aux 21 planches documentées. La répartition aux quotas reste ouverte ; aucune espèce, morphologie ou statistique n’est modifiée.
- #607 contient aussi des changements d’anatomie, sauvegarde et UI : elle ne sera pas fusionnée comme un simple registre documentaire. #606 reste un chantier gameplay distinct ; aucune de ces deux PR n’est fusionnée ni fermée ici.

### Blocage binaire constaté

L’archive `litd_sources_retrouvees_20261111.zip` est retrouvée (version 5, 13 328 381 octets). La récupération par le mécanisme prescrit échoue : `Library prepare_materialize is not available`. Une première tentative rencontrait un profil utilisateur Windows absent ; une fois ce point corrigé, l’indisponibilité de l’opération de transfert persiste. Le rétablissement de cette opération dans Work permettra de reprendre le téléchargement. Aucune nouvelle autorisation artistique n’est nécessaire.

**Aucune image ennemie importée, aucun SHA-256 d’image ennemie mesuré, aucune ressource ennemie supprimée ou migrée dans cette reprise.** Les empreintes du manifeste proviennent des registres cités ; elles ne constituent pas une nouvelle mesure des fichiers. La présence et l’identité des variantes candidates ne sont pas présentées comme vérifiées.

Les dix cartes de classes et les 39 images ennemis conservées par #610 restent intactes. Les six originaux héros de main ne sont pas modifiés.

### Suite prioritaire

Rétablir le transfert des octets, mesurer les SHA-256, identifier les variantes par leurs empreintes, puis importer les fichiers correspondants sans retouche et vérifier leur récupération GitHub. Les données de gameplay ne recevront aucune correspondance d’espèce supposée. Les tests de cohérence du manifeste sont distincts des tests d’intégrité binaire ; la PR reste en brouillon tant que les originaux ne sont pas archivés et vérifiés.

Chantier : Bibliothèque artistique LITD 1. Statut : 🟠 BLOQUÉ sur le transfert des originaux du bestiaire ; réconciliation documentaire avancée. Avancement du chantier actuel : À évaluer. Avancement du projet global LITD 1 : À évaluer.

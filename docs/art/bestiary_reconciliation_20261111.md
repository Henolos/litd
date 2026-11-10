# LITD 1 — Réconciliation du bestiaire (11 novembre 2026)

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

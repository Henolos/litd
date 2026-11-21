# LITD 1 — Audit des capacités de destin des 39 ennemis — V0.3

**Statut : inventaire vérifié, capacités de destin NON VALIDÉES.** Aucun pouvoir de transformation ne doit être ajouté au jeu sur la seule base de ce tableau.

## Sources effectivement consultées
- `data/enemies.json` sur `main` : 39 entrées, IDs 1–39, noms, HP, dégâts, peur, indicateur boss, ressource artistique ; **aucun champ de capacité de destin**.
- `docs/COMBAT_FAMILLES_ENNEMIES.md` sur `main` : cinq familles tactiques, manœuvres de formation ; ne décrit pas les capacités de destin.
- Documents de décisions et propositions V0.1/V0.2 : séparation des règles validées et des hypothèses.

## Méthode
« Aucune capacité démontrée » signifie **absence de preuve dans les deux sources examinées**, et non preuve d'incapacité. Les pistes marquées « ? » sont des **hypothèses à examiner**, jamais des affectations. La famille tactique n'est pas une preuve de pouvoir de réanimation, conversion, pillage ou corruption. Les deux boss ne gagnent aucun pouvoir de destin par leur statut.

## Inventaire exhaustif des entrées de data/enemies.json
| ID | Ennemi | Type du JSON | Piste de recherche (non attribuée) | Statut de capacité |
|---:|---|---|---|---|
| 1 | Goule affamée | Générique | Aucune capacité démontrée ; à documenter | Non vérifié |
| 2 | Cultiste fanatisé | Générique | convert_living ? (organisation non attestée) | Non vérifié |
| 3 | Chevalier déchu | Générique | loot_equipment ? (intelligence à confirmer) | Non vérifié |
| 4 | Ver des profondeurs | Générique | Aucune capacité démontrée ; à documenter | Non vérifié |
| 5 | Écorcheur | Générique | loot_equipment ? (nature à confirmer) | Non vérifié |
| 6 | Gorgone | Générique | corrupt ? (pouvoir précis à confirmer) | Non vérifié |
| 7 | Minotaure | Générique | Aucune capacité démontrée ; à documenter | Non vérifié |
| 8 | Oni | Générique | convert_living ? (faction à confirmer) | Non vérifié |
| 9 | Tengu | Générique | loot_equipment ? (comportement à confirmer) | Non vérifié |
| 10 | Jorōgumo | Générique | convert_living ? (mythe ≠ pouvoir implémenté) | Non vérifié |
| 11 | Yuki-Onna | Générique | Aucune capacité démontrée ; à documenter | Non vérifié |
| 12 | Anubis | Générique | reanimate_dead ? (nom mythologique insuffisant) | Non vérifié |
| 13 | Prêtre momifié | Générique | reanimate_dead ? (titre religieux insuffisant) | Non vérifié |
| 14 | Scarabée funéraire | Générique | Aucune capacité démontrée ; à documenter | Non vérifié |
| 15 | Nécrophage | Générique | consume_or_destroy_remains ? (nom évocateur) | Non vérifié |
| 16 | Porte-Cierge | Générique | Aucune capacité démontrée ; à documenter | Non vérifié |
| 17 | Veuve du Voile | Générique | Aucune capacité démontrée ; à documenter | Non vérifié |
| 18 | Pèlerin creux | Générique | Aucune capacité démontrée ; à documenter | Non vérifié |
| 19 | Mange-Rêves | Générique | corrupt ? (pouvoir onirique à vérifier) | Non vérifié |
| 20 | Chien d’Os | Générique | Aucune capacité démontrée ; à documenter | Non vérifié |
| 21 | Sangsue royale | Générique | Aucune capacité démontrée ; à documenter | Non vérifié |
| 22 | Gardien aveugle | Générique | Aucune capacité démontrée ; à documenter | Non vérifié |
| 23 | Oracle brisé | Générique | convert_living ? (pouvoir inconnu) | Non vérifié |
| 24 | Enfant de suie | Générique | Aucune capacité démontrée ; à documenter | Non vérifié |
| 25 | Masque hurlant | Générique | Aucune capacité démontrée ; à documenter | Non vérifié |
| 26 | Dévoreur de lumière | Générique | corrupt ? (pouvoir inconnu) | Non vérifié |
| 27 | Porte-Peste | Générique | corrupt ? (peste ≠ conversion) | Non vérifié |
| 28 | Moiré | Générique | Aucune capacité démontrée ; à documenter | Non vérifié |
| 29 | Géant des cryptes | Générique | Aucune capacité démontrée ; à documenter | Non vérifié |
| 30 | Nonne renversée | Générique | convert_living ? (faction inconnue) | Non vérifié |
| 31 | Éclat vivant | Générique | Aucune capacité démontrée ; à documenter | Non vérifié |
| 32 | Charognard cuirassé | Générique | consume_or_destroy_remains ? (charognage à confirmer) | Non vérifié |
| 33 | Loup du Voile | Générique | Aucune capacité démontrée ; à documenter | Non vérifié |
| 34 | Semeur de cendres | Générique | corrupt ? (cendres ≠ corruption) | Non vérifié |
| 35 | Miroir mort | Générique | Aucune capacité démontrée ; à documenter | Non vérifié |
| 36 | Prêtre du Néant | Générique | reanimate_dead ? (prêtre ≠ nécromancien) | Non vérifié |
| 37 | Colosse sans nom | Générique | Aucune capacité démontrée ; à documenter | Non vérifié |
| 38 | Ange inversé | Boss | corrupt ? (boss sans pouvoir confirmé) | Non vérifié |
| 39 | Mère des Souffrances | Boss | convert_living ? (boss sans pouvoir confirmé) | Non vérifié |

## Bilan vérifiable
- **39/39 entrées recensées** dans le JSON (37 non-boss, 2 boss).
- **0/39 capacités de destin prouvées** par les deux fichiers consultés.
- **0 capacité ajoutée au jeu** ; **0 test exécuté**.
- Le document de familles affirme que les 37 ennemis génériques sont classés dans cinq familles tactiques. L'affectation exhaustive par identifiant n'a pas été vérifiée dans les scripts ou données de combat lors de cet audit.

## Conditions minimales avant affectation
Pour chaque ennemi, retrouver sa fiche de lore, ses actions de combat, sa faction et ses interactions persistantes. Ne valider une capacité que si une preuve de conception ou une décision explicite la justifie. Consigner le chemin et la ligne de la preuve ; sinon laisser « À arbitrer ». Ne pas déduire automatiquement `reanimate_dead` du mot « prêtre », `convert_living` de « cultiste » ou `corrupt` de « boss ».

## Prochain travail
Inspecter les définitions de capacités et le lore de chaque ennemi, puis soumettre seulement les correspondances étayées à validation. Éviter toute modification de `data/enemies.json` tant que les règles ne sont pas approuvées.

**Suivi :** chantier audit des capacités de destin, 🟡 À CONSOLIDER. Avancement de l'inventaire du JSON : 100 % (39/39) ; avancement de la validation des capacités : 0 % sur ces 39 entrées dans les sources examinées, ce qui ne préjuge pas des décisions conservées ailleurs. Avancement du chantier actuel : À évaluer. Avancement du projet global LITD 1 : À évaluer.

## Rectificatif prioritaire — divergence avec le bestiaire artistique validé (21 novembre 2026)

**Attention : les 39 noms ci-dessus proviennent uniquement du prototype `data/enemies.json` et ne constituent PAS la liste canonique des créatures artistiquement validées.** L'intitulé « audit des 39 ennemis » doit être compris comme un inventaire du prototype, et non comme une validation du bestiaire. Aucune correspondance automatique ne doit être déduite d'un nom proche.

Sources supplémentaires consultées sur la branche `docs/litd1-regles-fuite-transformations-20261118` : `LITD1_BESTIAIRE_INVENTAIRE_ET_COHERENCE_LORE_V0_1.md`, `LITD1_BESTIAIRE_RECONCILIATION_PLANCHES_20261119.md`, `LITD1_BESTIAIRE_PLANCHES_VALIDEES_EGYPTE_20261119.md`, `LITD1_BESTIAIRE_PLANCHES_VALIDEES_SLAVES_20261119.md` et `LITD1_BESTIAIRE_PLANCHES_VALIDEES_MONSTRES_COMMUNS_20261121.md`.

Exemples de divergences constatées :
- `Écorcheur` (prototype ID 5) **n'est pas une preuve d'identité** avec `Écorcheur des Tempêtes` (créature LITD inspirée de Seth, planche approuvée).
- `Anubis` (prototype ID 12) ne reflète pas à lui seul la référence artistique `Anubis — Le Peseur des Âmes V2` ; correspondance de fiche technique à confirmer.
- `Goule affamée` (ID 1) possède une planche `Goule affamée — La Dévoreuse des Charniers V1` explicitement approuvée artistiquement, mais cela ne valide pas les statistiques ou pouvoirs du JSON.
- `Baba Yaga — La Mère des Seuils`, `Zmey — Le Dévoreur des Orages`, `Vodyanoy — Le Maître des Eaux`, `Rusalka — La Noyée des Saules` figurent dans le registre slave mais pas parmi les 39 noms du JSON.
- `Cerbère`, `Hydre`, `Kitsune`, `Draugr`, `Wendigo`, `Valkyrie spectrale` figurent dans l'inventaire des planches examinées, mais pas dans ces 39 entrées. **Planche reçue n'équivaut pas toujours à validation artistique explicite** : respecter les statuts précis du registre.
- `Golem de pierre runique` est expressément **en attente de validation** dans le registre des 15 planches, ne pas le compter parmi les planches validées.

**Mesure conservatoire :** ne pas renommer `data/enemies.json` ni attribuer de capacités à ces 39 entrées avant une table de correspondance à trois colonnes (ID prototype, ID stable de planche, statut exact et preuve), y compris les absences de correspondance. La présente V0.3 n'est pas une source de vérité canonique.

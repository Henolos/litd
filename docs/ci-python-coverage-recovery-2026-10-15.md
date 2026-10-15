# Rétablissement de la couverture Python — 15 octobre 2026

Révision auditée : `fd785096e6ff4e69a100a5353f8afb9997f7d919`.

La commande CI sans chemin collectait seulement `tests/python` : 1 463 cas
réussissaient, tandis que les 350 cas supplémentaires sous `tests/test_*.py`
comprenaient 32 échecs. La collecte par défaut couvre désormais tout `tests`,
avec le mode d'import `importlib`. Aucun test n'est désactivé ou marqué xfail.
Le job obligatoire `quality` conserve son nom et produit un artefact JUnit,
y compris en cas d'échec. Les suites nocturnes utilisant pytest sans chemin
bénéficient également de la collecte complète.

## Qualification des 32 échecs

| Groupe de tests | Nombre | Cause et correction |
| --- | ---: | --- |
| cinematic_direction | 3 | Ancien quatuor dans les assertions ; attentes alignées sur ADR-0002, vérification conservée des six paires et des actions dramatiques actuelles. |
| complete_pre_pc_workstreams | 2 | Folie du Voile renommée et sections du menu extraites dans le registre ; contrôles conservés sur les thèmes, dimensions et sections réellement utilisés. |
| contextual_exploration_hud | 1 | Recherche de sous-chaînes dépendant des espaces JSON ; lecture structurée des pénalités de peur et du bonus d'espoir. |
| dramatic_voice_direction | 2 | Anciennes identités de lignes ; migration des overrides oubliés vers les IDs canoniques et validation des références inconnues. |
| enemy_body_profiles | 1 | Le profil de la Nonne renversée référence `hexer`, absent du dictionnaire des postures. Définition ajoutée avec les caractéristiques de présentation du debuffer rituel existant, sans modifier les statistiques de combat. |
| first_map_gameplay_completion | 2 | Le boss possède stagger/phase_change plutôt que les animations de panique ordinaires ; le runtime de quête expose accept/refuse. Assertions adaptées aux contrats de chaque famille et aux appels réellement câblés. |
| living_exploration | 1 | Le donjon optionnel dispose d'une carte et de dangers dédiés, contrairement aux 15 zones de surface ; vérification des deux sources et de leur couverture exacte du manifeste. |
| persistent_injuries_and_context_traits | 1 | Variable de boucle typée avant préparation ; la vérification suit maintenant la restauration effective de chaque héros. |
| progressive_system_unlocks | 2 | Ancien vocabulaire et capture traitée comme une capacité tardive ; le contrat courant rend la capture accessible au premier niveau et distingue la Folie du Voile. Les autres capacités restent soumises au verrou progressif. |
| quest_giver_staging | 1 | Libellé de secours non vide ; les textes écrits restent prioritaires et les deux boutons sont vérifiés. |
| runtime_body_staging | 1 | Action ennemie désormais choisie par le directeur ; vérification de ce choix et de sa transmission à la présentation corporelle. |
| skill_production_scope | 3 | Ancien schéma réduisant implicitement le canon aux sous-ensembles de production ; attentes conformes à ADR-0005 et au schéma courant, avec conservation du canon 3×15 et des limites de production temporaires. |
| twelve_reference_gaps | 1 | La borne historique main_v34 est dépassée dans main ; dette explicitée et inventaire exact de la chaîne existante verrouillé, sans autoriser une nouvelle couche. |
| unified_game_menu | 1 | Les titres sont dans ui_section_registry ; vérification des titres et de l'utilisation du registre par le menu. |
| veilleurs_clinical_resolvers | 1 | La scène active main_v52, pas main_v37 ; le test suit les ressources et l'héritage réel pour prouver que la couche clinique est toujours raccordée. |
| veilleurs_developer_selftest_contract | 2 | Ancien quatuor et assertion dépendant d'une liste Python sur une ligne ; canon restauré et contrôle AST des arguments du lanceur, télémétrie comprise. |
| veilleurs_v081_canonical_production_audit | 1 | Le marqueur de réussite de l'audit a été renommé ; le test exige son nom actuel et conserve le contrôle du code de sortie. |
| veilleurs_vs001_legacy_boundary | 3 | Deux faux positifs sur commentaire et une dette de références accumulées hors de l'ancienne allowlist. Voir la portée et la limite ci-dessous. |
| voice_direction | 3 | IDs de démonstration et du quatrième mur encore alignés sur les anciens héros ; assertions migrées vers les lignes actives. |

## Corrections de données et non-régression

La migration de `dramatic_voice_overrides.json` rétablit six correspondances
avec les lignes actuelles. Les directions disparaissaient sinon dans les valeurs
par défaut. Les intentions existantes sont conservées, les identités corrigées.
Le générateur rejette désormais un override sans ligne correspondante ; un test
négatif vérifie ce rejet et un autre vérifie que chaque override atteint le
registre produit. L'audit dramatique utilise également les IDs canoniques.

Le rôle `hexer` existait dans la signature du profil ennemi mais n'avait aucune
définition de présentation. La correction renseigne orientation, espacement et
garde ; elle ne crée pas un nouveau comportement de combat.

## Dette conservée et rendue explicite

La frontière VS001 n'est pas déclarée migrée. L'inventaire
`data/veilleurs/legacy/vs001_reference_baseline.json` capture 139 lignes dans
37 fichiers de la révision auditée, hors espaces de noms historiques :
parcours QA, données/identifiants hérités, sauvegarde et dépendances UI encore
présentes. L'ancienne allowlist de trois fichiers ne décrivait plus l'état de main.

Le nouveau contrôle compare les lignes et leurs occurrences : ajout dans un
nouveau fichier, nouvelle référence dans un fichier existant et duplication
d'une occurrence sont refusés. Les commentaires ne constituent pas une
dépendance exécutable. Les suppressions sont permises ; une migration doit
réduire aussi la baseline. Toute extension de cet inventaire requiert une
revue explicite et ne doit pas servir à contourner le garde-fou. Les critères de
retrait de `vs001_dependency_contract.json` restent applicables, notamment la
compatibilité de sauvegarde et le playtest. Aucun changement de gameplay ou de
sauvegarde VS001 n'est effectué par ce lot.

De même, `main_v2` à `main_v52` et `main_v50_ge01` sont une dette constatée,
pas une approbation de cette architecture. Le test en refuse l'extension ; la
consolidation runtime/visuelle est un chantier distinct.

## Validation et périmètre

- Commande CI par défaut : **1 818 tests réussis en 6,36 s** localement,
  contre 1 463 cas collectés avant correction. Les 350 cas auparavant exclus
  et cinq nouveaux cas de garde-fou sont exécutés.
- Nouveau test vérifiant que la collecte par défaut inclut chaque module de tests.
- Tests négatifs des références VS001 et des overrides vocaux inconnus.
- Les 72 commandes Python de `CI / quality-full` ont été exécutées localement,
  toutes avec un code de sortie nul.
- Audit des SHA d'actions : 77 workflows valides ; `git diff --check` réussi.
- Aucun test Godot lancé localement : les vérifications runtime seront celles
  de la PR. Aucun playtest humain n'est attesté.
- Aucun changement des contrôles obligatoires ou des protections de fusion.
- Les optimisations de temps Godot, la sélection des domaines et les fréquences
  planifiées restent les lots suivants ; ce lot restaure la couverture Python.

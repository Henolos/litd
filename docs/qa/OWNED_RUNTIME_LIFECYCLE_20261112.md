# LITD — durée de vie des auxiliaires de runtime, 12 novembre 2026

## Défaut reproduit

Sur main `14f21427` comme sur la PR artistique #612 (`f29973e3`), les smokes UI/artistiques réussissent mais Godot 4.7.2 conserve **15 objets ObjectDB et 5 ressources GDScript à la fermeture**. Le journal détaillé identifie `content_db.gd`, `veilleurs_content_db_v07.gd`, `veilleurs_content_db_v07_runtime.gd`, `veilleurs_corpse_tactical_runtime.gd` et `combat_position_runtime.gd`.

Les catalogues dérivent de Node et sont créés sans parent par des runtimes RefCounted. Ils ne sont donc pas libérés par le comptage des références de leur propriétaire. Deux constructeurs remplacent aussi le catalogue du constructeur parent sans le libérer. Le helper de positions créé par Main est également un Node sans parent. Aucun portrait n'apparaît parmi les ressources retenues de cette reproduction.

## Correctif

- Libération explicite du catalogue possédé à `NOTIFICATION_PREDELETE` dans les runtimes tactique de base, campagne et génération hybride.
- Libération du catalogue de base avant remplacement dans les runtimes tactique v07 et combat canonique.
- Libération du helper de positions au moment de la destruction de Main.

Les classes restent des Node et les interfaces existantes sont conservées. Les données, règles de combat et références artistiques ne sont pas modifiées. Le test de régression est ajouté au domaine CI `runtime`.

## Contrôles exécutés

| Contrôle | Résultat |
| --- | --- |
| Smoke UI sur main avant correction | OK, 15 objets / 5 ressources retenus |
| Smoke UI sur main corrigé | OK, aucun avertissement ObjectDB / ressource retenue |
| Test de durée de vie sur #612 sans correctif | Échec attendu (code 1), 30 erreurs de nouveaux orphelins |
| Même test avec correctif | OK (code 0), 21 cycles création/destruction, aucun nouvel orphelin |
| Smoke artistique sur #612 + correctif | `CANONICAL_ART_V41_SMOKE_OK`, aucun avertissement ObjectDB / ressource retenue |
| Python, copie Git propre de main + correctif | **1 841 réussites** |
| Rangs / membres amputés | `PRE_PLAYTEST_RANK_EDGECASES_OK`, avertissements audio ci-dessous |

Le premier lancement Python dans une copie déjà importée par Godot rencontre le défaut connu du manifeste qui compte les sidecars `.import` (correction indépendante déjà dans #612). Une tentative de copie sans métadonnées Git fait ensuite échouer deux gardes qui appellent `git ls-files` ; une indexation trop large d'un rapport généré provoque encore un échec de garde. La mesure retenue ci-dessus utilise uniquement les chemins versionnés et modifiés du projet, avec Git disponible, sans sidecars ni rapports générés suivis. Aucun test de garde n'est neutralisé.

## Limites et suivi restant

Le test de rangs et certaines exécutions très courtes du nouveau smoke signalent encore des `AudioStreamWAV` / `AudioStreamPlaybackWAV` retenus au moment de la fermeture (19 objets dans le journal de rangs). Il s'agit d'une observation distincte, non corrigée ici : ne pas déclarer toutes les fuites de tous les scénarios résolues. Les smokes UI et artistique sont exempts des 15 objets / 5 scripts initiaux après ce correctif.

Le test de renouvellement du cache PWA de #612 reste bloqué par le refus de sécurité du navigateur observé dans la session précédente. Il n'est ni réessayé par un autre chemin ni déclaré validé. Ce lot ne fusionne pas #612, ne modifie pas ses images et ne certifie pas un playtest complet.

Sources officielles consultées : [Object et PREDELETE](https://docs.godotengine.org/fr/4.5/classes/class_object.html), [notifications Godot 4.7](https://docs.godotengine.org/en/4.7/tutorials/best_practices/godot_notifications.html), [inspection des Node orphelins](https://docs.godotengine.org/en/stable/classes/class_node.html#class-node-method-get-orphan-node-ids). L'API et le comportement ont également été exécutés avec Godot officiel 4.7.2.

[Journaux de preuve](evidence/owned-runtime-lifecycle-20261112/) : comparaison avant/après, codes de sortie, journaux UI, artistique, Python et rangs. Les journaux d'intégration portent sur `f29973e3` avec le correctif local appliqué ; les validations CI du nouveau commit restent distinctes.

Chantier : ressources retenues à la fermeture Godot — 🟡 À CONSOLIDER (défaut initial corrigé localement ; CI et retenues audio à suivre). Avancement du chantier actuel : **À évaluer**. Avancement du projet global LITD 1 : **À évaluer**.

## Complément : fermeture du test de parité

Le [suivi de la parité tactique](TACTICAL_HIT_PARITY_20261112.md) complète ce lot avec l’installation de fontconfig dans son conteneur CI, une fermeture explicite des lectures audio du test et des contrôles stricts sur les journaux. Six essais locaux corrigés ne retiennent plus d’objets ; les autres scénarios audio restent un suivi distinct. Les validations du commit initial restent identifiées ci-dessus et ne valent pas validation du complément.

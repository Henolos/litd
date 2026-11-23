# Cinq héros associés à la maîtresse d’armes — état de conception

**Source de travail :** addendum du document maître V8.1_WORK fourni dans `LITD1_TRANSFERT_WORK_5_HEROS_2026-11-23.zip`. Le dépôt `main` contient encore le document maître V7.9 ; les PR #619 et #620, ouvertes et non fusionnées, modifient toutes deux `docs/conception/LITD1_DOCUMENT_MAITRE.md`. Ce registre distinct conserve les décisions de l’archive sans dupliquer ni réécrire le document maître en cours de réconciliation.

## Décisions reprises de la source utilisateur

- Les cinq candidats sont **Ysra Nahal, Èffrie, Lya, Zéjé le Désaccordé et Aurélien**.
- Leur accès est lié à l’affinité avec la maîtresse d’armes `maitresse_armes` de `data/guild_npcs.json`.
- À l’enrôlement, leur niveau doit égaler le niveau courant du protagoniste.
- L’arbre de compétences et les compétences évolutives sont vierges au recrutement. Les points attribuables sont calculés par la règle canonique de progression ; les emplacements passifs suivent leurs règles distinctes.
- Les arbres dessinés sur les planches sont des références de conception, pas des choix attribués automatiquement.
- Le recrutement optionnel n’altère pas l’ordre historique des Sept défini dans `universe/lore/legendary_seven_formation.json`.

## Audit des systèmes et limites d’implémentation

- `data/hero_relationships.json` décrit les métriques relationnelles directionnelles entre héros et les événements qui les font évoluer. `data/narrative/legendary_seven_relationship_memory_contexts.json` interdit un nouveau compteur relationnel. Aucun état d’affinité avec la PNJ maîtresse d’armes ni aucun adaptateur d’enrôlement de héros n’a été trouvé dans le runtime Godot conservé sur `main`.
- `data/veilleurs/v07/recruitment_rules.json` concerne le recrutement/captures de créatures. Il n’est pas réutilisé pour enrôler ces héros. `data/veilleurs/v07/progression_1_50.json` décrit la progression des Veilleurs ; ce fichier ne prouve pas la formule active pour LITD 1.
- En conséquence, `data/recruitment/weapon_master_hero_unlocks.json` prépare les identifiants, la source d’accès et les règles de réinitialisation sans inventer de seuil d’affinité, sans créer une jauge de confiance séparée et sans prétendre qu’un déclenchement runtime existe.
- **Points de compétences :** aucune implémentation active LITD 1 n’a permis de vérifier la formule de calcul. L’attribution à l’enrôlement reste donc une référence dynamique à la future règle canonique, non une valeur calculée ou testée.

## Réconciliation nécessaire : Aurélien

La même identité `aurelien` figure dans `data/heroes.json` comme héros canonique du quatuor de départ, tandis que l’addendum V8.1_WORK le liste parmi les héros à débloquer par affinité avec la maîtresse d’armes. Le registre conserve une seule identité et bloque le déclenchement runtime de son recrutement jusqu’à résolution de cette contradiction. Aucun second Aurélien n’est ajouté.

## Références artistiques et doublons

- Èffrie et Aurélien : les SHA-256 de l’archive correspondent exactement aux originaux canoniques déjà enregistrés dans `docs/art/validated_heroes_manifest_20261111.json` ; les fichiers existants sont réutilisés.
- Lya : la planche de l’archive (`a696…bbb6`, 766 251 octets) diffère de la référence runtime existante (`b470…4272`, 744 724 octets). La référence existante reste inchangée ; l’original de l’archive est conservé comme planche de conception complémentaire.
- Ysra Nahal et Zéjé : aucun original de héros correspondant n’a été trouvé dans `art/library/heroes/`. La planche validée exacte est ajoutée sous un identifiant stable propre à chaque héros.
- Pour Zéjé, seul `assets_valides/zeje_planche_validee.jpeg` est utilisé. Aucune variante antérieure n’est copiée ou rendue canonique. Le nom affiché suit la demande utilisateur (« Zéjé ») et l’addendum de l’archive ; l’identifiant existant des relations reste `hero.zeje` / `zeje`.

Les fiches individuelles indiquent les éléments lisibles sur les planches et les informations laissées à confirmer. Les planches et fiches ne sont ni des portraits de combat ni des modèles 3D. Aucun portrait ni gameplay n’est généré par ce chantier.

## Validation de cette préparation

- Fichiers sources vérifiés avant import et binaires de destination comparés par SHA-256.
- La vérification du binaire dans GitHub, l’import Godot, le chargement en jeu, l’affinité runtime et la logique de recrutement restent des contrôles distincts ; seul l’état réellement obtenu doit être consigné dans la PR.

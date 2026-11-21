# LITD 1 — Système de transformation des compagnons perdus — V0.1 (PROPOSITION)

**Statut : hypothèses de conception non validées.** Aucun changement de gameplay, aucune implémentation, aucun test. Source normative : `LITD1_DESTIN_COMPAGNONS_PERDUS_DECISIONS_20261121.md` sur `main`.

## Invariants validés à ne pas modifier
- La mort des héros est permanente.
- Un compagnon vivant abandonné n'est pas automatiquement mort ni ennemi.
- Un compagnon mort peut être réanimé en adversaire ; cela ne restaure jamais son statut jouable.
- Un compagnon vivant peut rejoindre le camp ennemi.
- Tout ancien compagnon **devenu ennemi** est définitivement non sauvable et non récupérable.
- L'équipement perdu ne retourne pas automatiquement au refuge et ne doit pas être dupliqué.
- Le destin dépend des adversaires et des circonstances, non d'un simple tirage aléatoire.

## Modèle d'état proposé
États exclusifs : `ACTIF`, `PERDU_VIVANT`, `CAPTIF`, `MORT`, `HOSTILE_VIVANT`, `HOSTILE_REANIME`. `PILLE` est un attribut de l'inventaire, **pas** un état du héros. `CORROMPU` est un marqueur de cause ou de forme, à ne pas confondre avec l'allégeance.

Transitions proposées :
- `ACTIF -> PERDU_VIVANT` : séparation / abandon sans décès confirmé.
- `PERDU_VIVANT -> CAPTIF` : capture établie.
- `ACTIF|PERDU_VIVANT|CAPTIF -> MORT` : décès confirmé.
- `CAPTIF|PERDU_VIVANT -> HOSTILE_VIVANT` : événement scénarisé ou simulation causale de ralliement, si ennemi compatible.
- `MORT -> HOSTILE_REANIME` : intervention effective d'un réanimateur compatible.
- `HOSTILE_VIVANT -> MORT` : défaite mortelle de l'ancien compagnon ; aucune réintégration.
- `HOSTILE_REANIME -> MORT` : destruction de la forme hostile ; aucune réintégration.
- Les chemins de secours pour `PERDU_VIVANT` et `CAPTIF` sont **à arbitrer**, et ne s'appliquent jamais aux états hostiles.

## Résolution causale proposée
Chaque événement doit enregistrer `hero_id`, `event_id`, `zone_id`, `timestamp_in_game`, `enemy_actor_id`, `cause`, `previous_state`, `new_state`.
1. Constater l'état réel du héros (vivant/mort).
2. Relever les acteurs ennemis présents, leurs capacités et l'accès au héros ou à son corps.
3. Vérifier les conditions de transformation ou de pillage et produire un événement explicite.
4. Mettre à jour le registre persistant des personnages et de l'équipement.
5. Répercuter les conséquences dans le monde, les dialogues et les rencontres ultérieures.

**Exemples de correspondance, non validés :** nécromancien -> réanimation de corps ; faction organisée -> ralliement d'un captif vivant ; pillard intelligent -> équipement ; entité corruptrice -> mutation hostile si état et conditions compatibles ; Némésis -> trophée d'équipement.

## Équipement et identité
- Chaque objet a un identifiant unique et un seul détenteur ou emplacement au même instant.
- La réanimation et le pillage peuvent se cumuler ; ne jamais dupliquer les objets.
- Préserver l'identité de l'ancien compagnon (nom, traits reconnaissables, historique), sans imposer à ce stade quelles compétences ou objets il conserve.
- L'équipement récupérable après défaite est **à arbitrer**.

## Garde-fous et tests futurs
- Un abandon n'entraîne pas automatiquement la mort.
- Un héros mort ne revient jamais jouable.
- Un héros hostile ne redevient jamais allié.
- Un même objet ne peut pas être possédé simultanément par deux acteurs.
- Un ennemi incapable de réanimer ne provoque pas de réanimation sans intervention causale d'un autre acteur.
- Recharger une sauvegarde ne doit pas créer deux copies d'un ancien compagnon ni de ses objets.
- Les conditions de fin de campagne (quatre combattants morts) restent celles du document maître.

## À arbitrer
Déclencheurs et délais exacts ; probabilités éventuelles conditionnelles ; compétence et puissance des anciens compagnons hostiles ; règles de retour et d'évolution ; récupération du butin ; visibilité des informations ; secours des captifs non hostiles.

## Suivi
Chantier : conception des transformations de compagnons. Statut : 🟡 À consolider, proposition écrite non validée. Avancement du chantier : À évaluer. Avancement global LITD 1 : À évaluer.

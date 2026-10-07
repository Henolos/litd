# Premier Accord : passages physiques persistants

Les sceaux et leviers du blockout utilisent `EnvironmentInteractionContract` et
le ciblage de proximité de `ExplorationPartyController`. Le bouton INTERAGIR et
l'action clavier suivent le même chemin. Sans cible, ils conservent la résolution
du lieu ou le lancement du combat canonique.

- Un sceau révèle son passage secret depuis la salle source, une fois résolue.
- Un levier ouvre le raccourci depuis son côté profond, une fois résolu.
- Une interaction distante, dans une autre salle ou pendant le combat est refusée.
- Un passage ouvert permet le retour ; le raccourci devient utilisable des deux côtés.
- Les salles secrètes accordent leurs récompenses par le résolveur canonique,
  une seule fois. Aucun inventaire ou combat parallèle n'est introduit.

La découverte reste dans `discovered_edges`. L'ouverture du raccourci est dans
`node_flags[source].opened_shortcuts`, déjà sérialisé par l'expédition. Les saves
sans ce champ restent lisibles et conservent le raccourci fermé. Le plan et sa
graine ne sont pas régénérés par les interactions ou le chargement.

Le builder identifie chaque couloir par `from>to`, accepte le connecteur masqué
pour une destination secrète et reconstruit les ouvertures à partir du runtime.
Une répétition ne duplique pas les sols. Le couloir de retraite contourne la
colonne des salles principales plutôt que de la traverser. Les liens fermés
restent sans couloir ; le contrôle de progression des capteurs reste autoritaire.
La QA textuelle propose également l'ouverture explicite du raccourci.

## Validation

`first_accord_physical_interactions_smoke` couvre cinq graines (1, 7, 42, 101,
9001), huit secrets et cinq raccourcis : ciblage physique, portée, côté autorisé,
combat, répétitions, sols avec collisions, récompenses uniques, retours et saves
JSON. Les combats de cette fixture utilisent le résolveur pour isoler la
progression ; les commandes de combat joueur restent vérifiées séparément par
`first_accord_physical_combat_smoke`.

Le nouveau smoke est exécuté dans le domaine CI `veilleurs`. Les smokes combat
physique, modules, pipeline jouable et shell joueur passent aussi localement,
ainsi que les 14 contrats Python des données hybrides.

## Périmètre

Les objets et sols restent des proxies. Les variations de dangers et de lore
marquées `definition_only` ne deviennent pas de nouveaux effets de gameplay.
L'entrée joueur principale reste inchangée ; l'essai PC physique et la PR HUD
#551 restent différés. Cette étape ne vaut pas validation visuelle sur appareil.

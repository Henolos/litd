# Contrat canonique — Trieur, états et provenance

## Objet

Ce contrat clarifie les responsabilités déjà présentes dans LITD sans créer une nouvelle autorité ni un nouveau service.

## Deux fonctions, une gouvernance

### Knowledge Router (nom historique : `library_trieur.py`)

Responsabilité : qualifier et router une information vers `GENERAL_LIBRARY`, `LITD_LIBRARY` ou `QUARANTINED`.

Invariants :
- déterministe et conservateur ;
- une source non vérifiée ou une classification ambiguë va en quarantaine ;
- une application LITD d'un savoir général conserve une référence croisée vers sa source canonique ;
- le routeur ne peut jamais autoriser une écriture dans le Core.

Le nom de fichier historique est conservé pour compatibilité. Dans la documentation et les nouveaux contrats, cette fonction est appelée **Knowledge Router** afin de ne pas la confondre avec le Trieur de fichiers.

### File Lifecycle Trieur

Responsabilité : observer et contrôler le canon physique Git/Godot : fichiers canoniques, remplacements, archives, collisions, références runtime et intégrité.

Invariants :
- c'est un capteur et un contrôleur de cycle de vie, pas une autorité de connaissance ;
- il ne décide pas qu'une connaissance est vraie ;
- les suppressions automatiques restent interdites ;
- l'archivage doit rester explicite, vérifiable et réversible selon la politique existante.

## Trois dimensions d'état orthogonales

Un même objet peut porter des états dans plusieurs dimensions. Ces dimensions ne doivent pas être fusionnées en un unique statut.

### 1. Ingestion

Décrit le résultat du passage à l'entrée :
- `accepted`
- `rejected`
- `quarantined`
- `duplicate`

Cet état répond à : **l'information peut-elle entrer dans le registre et sous quelle forme ?**

### 2. Validation / preuve

Décrit le niveau de validation d'une affirmation ou d'un apprentissage :
- `candidate`
- `experimenting`
- `proven`
- `rejected`

Cet état répond à : **que savons-nous réellement et avec quel niveau de validation ?**

### 3. Cycle de vie

Décrit l'applicabilité temporelle d'une connaissance ou d'un artefact :
- `active`
- `experimental`
- `revalidate`
- `superseded`
- `obsolete`
- `rejected`
- `archived` lorsque l'objet concerné possède une phase d'archive explicite

Cet état répond à : **cette connaissance ou cet artefact est-il encore applicable/canonique ?**

Un `accepted` d'ingestion n'implique donc ni `proven` ni `active`. De même, `superseded` ne signifie pas que la preuve historique était fausse.

## Evidence Ledger et Provenance Chain

Ces deux mécanismes sont complémentaires.

### Evidence Ledger

Autorité d'audit pour l'ingestion :
- identité de la preuve ;
- déduplication par identifiant et hash canonique ;
- décision d'ingestion ;
- périmètre projet/route ;
- historique append-only et chaîne de hash.

### Provenance Chain

Autorité de lignée du processus :
- relie les étapes de transformation et de décision ;
- conserve les parents et références externes ;
- impose l'ordre des étapes ;
- interdit notamment qu'un commit contourne `CORE_DECISION`.

### Liaison canonique

Lorsqu'une preuve acceptée poursuit le cycle de gouvernance :
1. son `evidence_id` du Evidence Ledger est réutilisé comme référence stable dans la Provenance Chain ;
2. la chaîne de provenance ne recopie pas le registre de preuve ;
3. le Ledger ne tente pas de représenter toute la lignée du processus ;
4. toute étape dérivée reste traçable jusqu'à la preuve d'origine ;
5. aucune de ces structures n'accorde, seule, le droit de modifier le Core.

Cette séparation suit le principe de provenance « entité → activité → entité » : le registre atteste l'entrée, la chaîne décrit ce qui lui arrive ensuite.

## Relations conceptuelles

La taxonomie conserve les relations conceptuelles directes `broader`, `narrower` et `related`. Les relations métier telles que `contradicts`, `derived_from`, `tested_by` ou `supersedes` restent typées séparément et ne doivent pas être confondues avec une hiérarchie de concepts.

## Compatibilité

Ce contrat est une clarification sémantique. Il ne :
- renomme pas brutalement les fichiers ou workflows historiques ;
- ne change pas les permissions ;
- ne crée pas de nouvelle base de données ;
- ne modifie pas Supabase ;
- ne donne aucun droit d'écriture supplémentaire au Core.

Toute évolution d'implémentation ultérieure doit préserver ces invariants et être couverte par les gates existantes.

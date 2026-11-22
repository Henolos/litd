# LITD 1 — Prologue « La Cueillette » — Dimensionnement des zones V0.1

**Statut : PROPOSITION MÉTRIQUE NON VALIDÉE.** Référence artistique V3 sombre validée par l'utilisateur le 22 novembre 2026 ; son fichier PNG est sauvegardé dans la bibliothèque ChatGPT sous `/LITD 1/Prologue/Cartes validées/LITD1_PROLOGUE_LA_CUEILLETTE_CARTE_CONCEPTUELLE_V3_SOMBRE_VALIDEE.png`. **Ce PNG n'est pas intégré au dépôt par ce commit documentaire.** La carte conceptuelle est une illustration et non un plan topographique à l'échelle : les distances suivantes sont des hypothèses de level design, pas des mesures de l'image.

## Invariants à conserver
- Conserver les sept lieux de la carte : (1) camp de départ, (2) vieux moulin, (3) ruines de la tour de guet, (4) bois des champignons, (5) marais voilé, (6) sanctuaire abandonné, (7) donjon du prologue, ancienne crypte de la montagne.
- Conserver le parcours principal, les chemins secondaires, les falaises, ponts, cours d'eau et raccourcis représentés dans la V3.
- Le Némésis surgit **après la dernière récolte** et non par entrée dans le donjon. La disparition des trois compagnons, la fuite du Némésis et le retour du héros sont des événements narratifs validés ; leur emplacement précis reste à définir.
- La zone doit permettre la navigation et le combat avec une compagnie de quatre, l'apprentissage de la carte, des rencontres de faible difficulté et des dialogues qui développent les trois compagnons.

## Échelle de travail proposée
- Emprise totale extérieure indicative : **600 × 450 m**, soit 270 000 m² (27 ha) ; les falaises, vides, eau et reliefs ne sont pas tous praticables.
- **Aire réellement praticable cible : 25–40 %** de l'emprise, à vérifier avec le terrain et les collisions.
- Largeur du chemin principal : **4–6 m** ; sentiers secondaires : **2–3 m**, avec élargissements pour croisement et combat.
- Espaces de combat initiaux : **18 × 18 à 30 × 30 m** selon la caméra, la formation et les ennemis.
- Déplacements et durée : **non validés** ; aucun temps de traversée ne doit être promis avant prototype.

## Emprises de travail par zone (boîtes englobantes, non surfaces additives)
| Zone | Dimension indicative | Surface du rectangle | Fonction | Contrôle à réaliser |
|---|---:|---:|---|---|
| 1. Camp de départ | 70 × 60 m | 4 200 m² | Introduction, quatre compagnons, tutoriel | Caméra, circulation, dialogue |
| 2. Vieux moulin | 90 × 75 m | 6 750 m² | Carte, exploration, eau, franchissement | Pont et approche du moulin |
| 3. Ruines de la tour de guet | 85 × 75 m | 6 375 m² | Premiers combats et ressources | Arène et lisibilité des obstacles |
| 4. Bois des champignons | 130 × 110 m | 14 300 m² | Récolte, exploration, rencontres | Visibilité des points de collecte |
| 5. Marais voilé | 120 × 100 m | 12 000 m² | Détour optionnel, danger et indices | Cheminements, zones humides |
| 6. Sanctuaire abandonné | 85 × 80 m | 6 800 m² | Découverte, lore, dernière récolte possible | Déclencheur lié à la collecte, pas au lieu |
| 7. Donjon du prologue (extérieur) | 105 × 90 m | 9 450 m² | Monument, entrée de donjon, exploration future | Accès et statut d'ouverture à décider |

Les emprises sont des **enveloppes de conception** pouvant inclure reliefs et obstacles, pas des surfaces entièrement jouables. Elles ne doivent pas être additionnées pour calculer la taille de la carte ; leurs positions, marges, chemins et chevauchements sont à établir dans un plan 2D métrique.

## Étapes techniques avant implémentation
1. Produire un schéma métrique à coordonnées (origine, axes, contours, altitudes, largeur des passages) qui respecte la V3.
2. Vérifier la caméra isométrique, les quatre combattants et la lisibilité de l'exploration sur un blocage gris (« greybox »).
3. Tester collisions, ponts, falaises, eau, zones de combat, navigation et points de récolte.
4. Placer les déclencheurs : le Némésis apparaît lorsque le dernier champignon requis est effectivement récolté, quel que soit l'ordre de visite autorisé.
5. Mesurer les distances et temps de parcours dans le moteur, ajuster les emprises, puis seulement verrouiller les dimensions.
6. Intégrer le **PNG original** à GitHub via un accès capable de transférer des binaires, avec vérification de l'empreinte et du rendu ; ne jamais le remplacer par une reconstruction textuelle.

## Suivi
- Carte V3 : **validée artistiquement et sauvegardée en bibliothèque**, non intégrée en binaire dans GitHub par ce document.
- Dimensions : **proposées, non validées et non testées**.
- Avancement du chantier actuel : **À évaluer**.
- Avancement du projet global LITD 1 : **À évaluer**.

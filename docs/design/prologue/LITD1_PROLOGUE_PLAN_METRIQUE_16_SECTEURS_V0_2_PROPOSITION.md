# LITD 1 — La Cueillette — Plan métrique 16 secteurs V0.2 (PROPOSITION)

**Statut : 🟡 À CONSOLIDER — dimensions et connexions NON VALIDÉES, non testées en jeu.**

## Références et limites
- Carte conceptuelle V3 sombre : **validée artistiquement**, conservée dans la bibliothèque ChatGPT (`/LITD 1/Prologue/Cartes validées/LITD1_PROLOGUE_LA_CUEILLETTE_CARTE_CONCEPTUELLE_V3_SOMBRE_VALIDEE.png`). Non transférée en binaire dans GitHub par ce document.
- Source technique antérieure : `docs/design/prologue/LITD1_PROLOGUE_CARTE_V3_DIMENSIONNEMENT_V0_1.md` (600 × 450 m, remplacé ici uniquement comme hypothèse de dimensionnement, sans supprimer la version historique).
- Inspiration de structure : secteurs denses, connexions et verticalité à la Monster Hunter: World ; **aucune mesure métrique officielle de Capcom n'est revendiquée**.
- Les coordonnées sont un **schéma de production proposé**, pas des mesures extraites de l'illustration ; un réajustement spatial sera nécessaire pour respecter exactement les silhouettes et le placement des lieux de la V3.

## Repère métrique
- Plan horizontal : **900 m est-ouest (X) × 700 m sud-nord (Y)** ; origine (0,0) au coin sud-ouest, Y croissant vers le nord.
- Altitude Z = mètres relatifs au niveau du camp, non altitudes géographiques.
- Enveloppe de 63 ha ; surfaces accessibles et altitudes à mesurer après terrain greybox.
- Trois strates fonctionnelles : basses terres (0–20 m), forêts et ruines (20–50 m), sanctuaire et donjon (65–110 m). **Ce sont des plages de travail, pas trois plateaux strictement plats.**
- Chaque secteur est une **enveloppe de conception** autour d'un centre. Des boîtes peuvent se chevaucher, et des parties peuvent sortir des limites si non ajustées : vérifier les emprises avant modélisation. Les surfaces ne s'additionnent pas.

## 16 secteurs et centres proposés
| ID | Zone majeure | Sous-secteur | Centre (X,Y) m | Z relatif | Enveloppe indicative |
|---|---|---|---|---|---|
| S01 | Camp de départ | Campement | (760, 110) | 0 m | 90 × 80 m |
| S02 | Camp de départ | Sentier des falaises | (650, 165) | 8 m | 105 × 75 m |
| S03 | Vieux moulin | Berges du moulin | (705, 285) | 0 m | 140 × 120 m |
| S04 | Vieux moulin | Passerelle des eaux | (575, 325) | 12 m | 90 × 65 m |
| S05 | Ruines de la tour | Approche des ruines | (480, 245) | 20 m | 110 × 90 m |
| S06 | Ruines de la tour | Cour de la tour | (400, 335) | 32 m | 115 × 100 m |
| S07 | Bois des champignons | Lisière | (295, 280) | 28 m | 120 × 100 m |
| S08 | Bois des champignons | Sous-bois | (195, 375) | 40 m | 140 × 120 m |
| S09 | Bois des champignons | Clairière de récolte | (290, 475) | 34 m | 130 × 115 m |
| S10 | Marais voilé | Gué brumeux | (535, 450) | 8 m | 115 × 105 m |
| S11 | Marais voilé | Îlots noyés | (650, 520) | 3 m | 130 × 110 m |
| S12 | Sanctuaire abandonné | Escalier des pèlerins | (385, 555) | 65 m | 105 × 90 m |
| S13 | Sanctuaire abandonné | Parvis du sanctuaire | (295, 625) | 85 m | 120 × 110 m |
| S14 | Donjon du prologue | Corniche de la crypte | (740, 595) | 80 m | 125 × 100 m |
| S15 | Donjon du prologue | Porte monumentale | (825, 645) | 110 m | 110 × 100 m |
| S16 | Bois des champignons | Ravin des racines | (130, 520) | 20 m | 95 × 85 m |

## Connexions proposées
Les distances ci-dessous sont **des distances horizontales à vol d'oiseau entre centres, calculées** à partir des coordonnées proposées, **pas les longueurs des chemins réels**. Les chemins devront contourner reliefs et obstacles ; leur longueur réelle sera supérieure ou égale à ces valeurs. Les différences de hauteur ne sont pas des pentes de chemin.

| Liaison | Nature | Distance directe arrondie | Dénivelé entre centres | Longueur réelle |
|---|---|---:|---:|---|
| S01–S02 | principal | 123 m | 8 m | À mesurer en greybox |
| S02–S03 | principal | 132 m | 8 m | À mesurer en greybox |
| S03–S04 | principal | 136 m | 12 m | À mesurer en greybox |
| S04–S05 | principal | 124 m | 8 m | À mesurer en greybox |
| S05–S06 | principal | 120 m | 12 m | À mesurer en greybox |
| S06–S07 | principal | 119 m | 4 m | À mesurer en greybox |
| S07–S08 | principal | 138 m | 12 m | À mesurer en greybox |
| S08–S09 | principal | 138 m | 6 m | À mesurer en greybox |
| S09–S12 | principal | 124 m | 31 m | À mesurer en greybox |
| S12–S13 | principal | 114 m | 20 m | À mesurer en greybox |
| S04–S10 | secondaire | 131 m | 4 m | À mesurer en greybox |
| S10–S11 | secondaire | 135 m | 5 m | À mesurer en greybox |
| S11–S14 | secondaire | 117 m | 77 m | À mesurer en greybox |
| S14–S15 | secondaire | 99 m | 30 m | À mesurer en greybox |
| S10–S06 | raccourci à débloquer | 177 m | 24 m | À mesurer en greybox |
| S09–S16 | secondaire | 166 m | 14 m | À mesurer en greybox |
| S16–S07 | raccourci à débloquer | 291 m | 8 m | À mesurer en greybox |
| S13–S14 | liaison haute à étudier | 446 m | 5 m | À mesurer en greybox |
| S03–S10 | secondaire | 237 m | 8 m | À mesurer en greybox |

## Largeurs et espaces de combat à éprouver
- Chemins principaux : **5–8 m** ; sentiers secondaires : **3–5 m** ; étranglements ponctuels sous réserve de navigation des quatre combattants.
- Clairières et cours de combat : **30 × 30 à 50 × 50 m**, selon les tests de caméra, lisibilité et règles du combat.
- Ponts : prévoir au moins une largeur compatible avec la compagnie et les collisions ; chiffre définitif après prototype.
- Raccourcis : S10–S06 et S16–S07 à débloquer, sans empêcher la progression principale.

## Déroulement et verrou narratif
- Progression initiale proposée : S01 → S02 → S03 → S04 → S05 → S06 → S07 → S08 → S09, puis exploration libre et éventuellement S12–S13 ; **aucun ordre fixe de récolte imposé par la carte**.
- La dernière récolte requise déclenche l'apparition du Némésis **dans une zone de confrontation compatible avec la position réelle de la compagnie**, jamais automatiquement à S15 (porte du donjon). Le placement et la mise en scène sont à arbitrer.
- Le donjon S14–S15 reste un lieu monumental ; **son accessibilité intérieure pendant le prologue n'est pas validée**.
- Développer les trois compagnons par dialogues et petites situations avant leur mort ; Némésis tue les trois, évolue et fuit, héros revient seul. Ne pas avancer ces événements par simple entrée dans une zone.

## Contrôles de cohérence avant verrouillage
1. Comparer la position des centres et les silhouettes à la carte V3 ; réviser les coordonnées en conservant la composition artistique.
2. Vérifier que toutes les enveloppes sont dans l'emprise, ou les recadrer : la zone S15 (centre X825, largeur 110) reste à l'intérieur ; S13 (Y625, hauteur 110) aussi.
3. Vérifier les dénivelés et pentes réelles, les ponts, les traversées d'eau, les raccourcis et la navigation à quatre.
4. Construire un greybox à l'échelle dans le moteur retenu, mesurer les **distances réelles**, temps de parcours et lisibilité en caméra isométrique.
5. Tester la collecte libre, le dernier champignon et l'apparition du Némésis quelle que soit la zone de dernière collecte autorisée.
6. Après ajustement, soumettre les dimensions à validation avant intégration définitive.

## Suivi
Chantier : plan métrique et connectivité du prologue ; 🟡 À CONSOLIDER. Avancement du chantier actuel : **À évaluer**. Avancement du projet global LITD 1 : **À évaluer**. Plan documentaire créé, aucun terrain généré, aucun test de gameplay effectué.

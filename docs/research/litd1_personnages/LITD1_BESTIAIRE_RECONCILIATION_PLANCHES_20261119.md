# LITD 1 — Réconciliation des planches du bestiaire (inventaire de référence)

Date : 2026-11-19. Statut : **partiel / à consolider**.

## Source

Archive originale de conversation : `LITD1_Bestiaire_15_planches_originales_2026-11-19.zip`, comprenant 15 JPEG et `MANIFEST_SHA256.json`. Les empreintes ci-dessous proviennent des octets des JPEG de cette archive, pas de fichiers vérifiés dans GitHub.

## Inventaire des originaux

| Créature | SHA-256 du JPEG source |
|---|---|
| Yuki-onna | `9f20397e1b57e76ef4a73a739babb1f1546cac6b6e8b15ed1f8d52c0b0c295fa` |
| Draugr | `fb0acb6a915ec134ee32d583993bf3a97181bf9a4f68baa1aee798a191f0a949` |
| Kitsune | `d6e69dbaaedced4449e51abdd2bf5e4c455fb28fbbbd7507e18b1b21d9ab6f25` |
| Hydre | `23d7e90aca6058a4394135d2eda92ac5d53e0cb3522244e3a583d2185dcc12f6` |
| Cerbere | `f10371084abdc7125824c322a559e8ba560bd468b46ed42edbc5a72851eaf8f6` |
| Troll | `8ce2c11e61f917bce5fb62af2fd2bf762383f60329c3f6ae854ff959c781ad9c` |
| Minotaure | `4b91c4dd1eed8c04e084f5df89976228bb02a3240686069136e771ec601d0283` |
| Golem_de_pierre_runique | `1cec2ce9c55ef7abf20fef8ed83ecaf186957c143fd8fd111a8e3930f331d675` |
| Wendigo | `e24caea7562a701cf61099416f62c62c8f4edb5d1f17df552bffd03e01e1110c` |
| Cyclope_V3 | `831a4008db014a815c65f19c06fcf227f56340d362d30209bad7d1a0f27610fe` |
| Gorgone | `825f35da6bc80f06caa683803d557a653028d139ef102205dcd836556fc0ea82` |
| Valkyrie_spectrale | `7ae59594daa7303c1277f33be0f3621acdc874f42a5be2993a7614ee422644fd` |
| Harpie | `6f22b47843636b63457408c3b92a5b5b6feb7e609f1bd176cac1a3461913df04` |
| Oni_V5 | `9920292ec992c278320feb629ddae83b96193f1d78f5e3d1c4223727599b26be` |
| Tengu | `5fd6c2f5e0cece136bf107f258ce21c67b1fd2d1e0cfa89af421f16749d2903b` |

## Résultat de l'inspection GitHub

- Recherche de code sur la branche par défaut pour `Wendigo`, `Valkyrie`, `bestiaire`, `Gorgone` : aucun résultat renvoyé ; cela ne démontre pas l'absence des images.
- La lecture GitHub de chemins de dossiers via le connecteur ne fournit pas leur contenu : énumération exhaustive des assets et comparaison binaire **non réalisées**.
- **Aucun des 15 JPEG n'a été téléversé dans GitHub par cette intervention.**
- **Aucun fichier existant n'a été écrasé ou supprimé.**

## Réconciliation à terminer

1. Obtenir la liste complète des fichiers binaires de `main` et des branches de travail pertinentes.
2. Calculer SHA-256 sur les binaires GitHub et comparer aux 15 empreintes ci-dessus.
3. Identifier doublons, variantes, références validées et éventuelles collisions de numérotation (notamment fiche n°21 attribuée à plusieurs créatures).
4. Ajouter uniquement les JPEG absents sur une branche dédiée, sans modifier les originaux existants ; vérifier les empreintes après téléversement.
5. Demander validation avant toute suppression, remplacement ou fusion.

Ce document est un **registre de rapprochement**, pas une preuve que les images sont déjà présentes dans le dépôt.

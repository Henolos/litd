# Incident — archive PNG : blobs non rattachés à la branche

- Date : 2026-11-19
- Domaine : GitHub / archivage binaire
- Statut : active
- Confiance : medium
- Connaissances liées : [PR #623](https://github.com/Henolos/litd/pull/623) ; `docs/knowledge/templates/incident.md`

## Symptôme

Les cinq planches PNG avaient été préparées pour l’archive de la PR #623, mais elles n’apparaissaient pas dans l’arbre de fichiers de la branche après une première tentative d’envoi. Une vérification ultérieure a également échoué pendant la lecture des données binaires.

## Portée / impact joueur ou production

Aucune modification de `main` ni perte des originaux n’a été constatée. La PR n’affichait pas les images tant que la référence de branche ne pointait pas vers un commit contenant leur arbre.

## Reproduction

Créer ou téléverser les objets blob PNG puis s’arrêter avant de construire un arbre, de créer un commit qui référence cet arbre et de déplacer la référence de branche. Les blobs peuvent exister sans que les fichiers apparaissent dans la branche.

Pour l’erreur de contrôle secondaire, demander à un outil de lecture texte de décoder un PNG en UTF-8 : le contenu binaire n’est pas du texte UTF-8.

## Cause racine

Le transfert initial a créé des objets blob isolés sans compléter le graphe Git : il manquait l’arbre, le commit et la mise à jour de la référence de branche. GitHub n’avait donc aucun nouveau commit à afficher dans la PR.

Deux défauts distincts ont empêché la vérification : un nom d’argument incorrect dans l’appel de récupération, puis l’utilisation d’une lecture texte pour des PNG binaires. Ces défauts expliquent l’échec du contrôle, pas l’absence des fichiers dans la branche.

## Hypothèses écartées

- Une empreinte ou une taille correcte, à elle seule, ne prouve pas que le fichier est rattaché à la branche.
- Le problème ne venait pas d’une modification de `main`.
- Un blob téléversé n’équivaut pas à un fichier commité et référencé.

## Correction

Compléter l’écriture Git dans l’ordre : blobs → arbre contenant les chemins → commit parenté à la tête attendue → mise à jour de la référence de branche. Pour contrôler les PNG, comparer leurs SHA-256 calculés sur les octets et vérifier les entrées de l’arbre (chemin, blob SHA et taille), sans les décoder comme du texte.

## Preuve de correction

Le suivi de la PR #623 rapporte que les cinq PNG ont ensuite été ajoutés à la branche dédiée et que leurs empreintes SHA-256 correspondent au manifeste. La vérification finale doit toujours confirmer ces fichiers depuis l’arbre de la branche et relire leurs empreintes de destination. Ce rapport ne prétend pas que l’import ni l’affichage en jeu ont été validés.

## Prévention / test anti-régression

Avant d’annoncer un transfert réussi, contrôler que chaque chemin apparaît dans l’arbre du commit de la branche et que le commit est bien la tête de cette branche. Comparer les SHA-256 source/destination des fichiers binaires. Séparer le contrôle de l’intégrité du contenu du contrôle de présence dans la PR.

## Connaissance ou Core à mettre à jour

Ajouter au protocole d’archivage binaire le contrôle explicite du graphe Git (arbre, commit, référence) et le contrôle d’intégrité binaire par SHA-256. Réutiliser ce rapport si un transfert de blobs semble réussi mais que les fichiers restent absents de la PR.

## Risques résiduels

La cause a été identifiée à partir de la séquence d’échec rapportée ; elle n’a pas été reproduite indépendamment dans un dépôt de test. Le succès du transfert ne valide ni l’import Godot ni le rendu en jeu.

## Condition/date de revalidation

Revalider lors du prochain archivage de fichiers binaires via le connecteur GitHub, puis ajuster ce rapport si le même symptôme survient avec un arbre, un commit et une référence effectivement mis à jour.

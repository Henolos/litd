# Tactical hit chance parity — 12 novembre 2026

## Périmètre et critères

Reprendre les exécutions #7/#8 bloquées et traiter les diagnostics de #10, sans changer les règles de combat ni les protections GitHub. Le correctif de catalogues existant dans #614 est réutilisé. Critères : 625 comparaisons avec la formule historique indépendante, code de sortie non nul sur une divergence ou une erreur Godot, aucune ressource retenue dans ce scénario.

## État Actions vérifié

- [#7 / 43095219494](https://github.com/Henolos/litd/actions/runs/43095219494) : aucun job retourné par l’API le 12 novembre.
- [#8 / 43095233129](https://github.com/Henolos/litd/actions/runs/43095233129) : Queued, aucun job ; annulation UI échouée avec `Failed to cancel workflow`. Aucune tentative de force-cancel, non exposée par les outils disponibles.
- [#10 / 43211774629](https://github.com/Henolos/litd/actions/runs/43211774629) : nouvelle exécution manuelle réussie sur main `14f214278b26628e8e9b6d8bdc5b79227d169d02`, avec `TACTICAL_HIT_PARITY_OK cases=625`. Son journal signalait fontconfig absent, 7 objets et 3 ressources retenus.

Le workflow n’a ni groupe de concurrence ni approbation d’environnement et utilise le runner hébergé ubuntu-latest. L’état anormal des anciens runs relève probablement du service Actions ; la cause interne exacte reste inconnue. Une saturation des runners n’est pas démontrée. Le nouveau run au même commit a fonctionné.

## Correction de ce lot

1. Le conteneur CI installe `libfontconfig1` avant l’import Godot.
2. Le test exécute ses assertions après l’initialisation du projet. Il retourne ensuite à une fonction de fermeture, laissant détruire son runtime local et son catalogue par le correctif de #614.
3. Les autoloads audio sont arrêtés avec leurs API existantes. Des références faibles suivent les lectures actives jusqu’à leur libération par le serveur audio ; une limite de 2 secondes fait échouer le test en cas de non-libération. Aucun délai fixe ni masquage des avertissements.
4. Le workflow exige le marqueur complet des 625 cas et rejette les erreurs Godot ainsi que les diagnostics de ressources retenues, à l’import comme au test.

Aucune formule, donnée de gameplay, image, permission ou protection de branche n’est modifiée. Ce nettoyage porte sur le scénario de parité ; il ne résout pas à lui seul les fermetures de tous les autres tests audio.

## Vérifications locales réellement exécutées

Godot officiel 4.7.2, base de travail #614 `e63e31f165a4d6799d9bb647af2936700ba903bf` :

| Contrôle | Résultat |
| --- | --- |
| Test original de #614, 6 essais | 625 cas réussis à chaque essai ; 19 objets audio retenus dans 3 essais sur 6 |
| Test après nettoyage, 6 essais | 625 cas réussis à chaque essai ; aucune erreur ni fuite à la fermeture |
| Contre-épreuve : formule historique temporairement décalée de 75 à 74 | Code 1, divergence legacy/runtime/resolver signalée, aucun marqueur de succès, aucune fuite |
| Test restauré après contre-épreuve | Code 0, 625 cas, aucune erreur ni fuite |
| Syntaxe bash de toutes les étapes du workflow | OK |
| Garde de diagnostics : fontconfig, ObjectDB, ressources, assertion | Les quatre classes de défaut sont rejetées |
| Audit de pinning GitHub Actions | PASS, 80 workflows |

[Preuves locales conservées](evidence/tactical-hit-parity-20261112/) : séries avant/après et journaux positif/négatif. Les journaux de CI du nouveau commit restent une validation distincte ; ne pas réutiliser les 18 workflows verts du commit parent comme preuve du nouveau commit.

## Assistance et reste à faire

Le portail connecté au compte Henolos a été consulté. Les catégories proposées ne comprennent pas Actions ; le formulaire Repositories exige une sous-catégorie Templates/Releases/Insights/Branches qui ne correspond pas à cet incident. Aucun ticket n’a été envoyé et aucune catégorie inexacte n’a été sélectionnée pour soumettre. Le texte de signalement est conservé avec les preuves. Un signalement public à la communauté constitue un canal distinct, non utilisé dans ce lot.

Restant : vérifier la CI du nouveau commit, faire traiter les anciens runs par GitHub, puis revue et fusion selon les protections existantes. Pas de validation visuelle/audio globale revendiquée.

Sources officielles consultées : [dépannage Actions](https://docs.github.com/en/actions/how-tos/troubleshoot-workflows), [création d’un ticket](https://docs.github.com/en/support/contacting-github-support/creating-a-support-ticket), [AudioStreamPlayer](https://docs.godotengine.org/en/stable/classes/class_audiostreamplayer.html), [RefCounted](https://docs.godotengine.org/en/latest/classes/class_refcounted.html), [Dockerfile godot-ci](https://github.com/abarichello/godot-ci/blob/master/Dockerfile).

Chantier : parité tactique et diagnostics — 🟡 À CONSOLIDER. Avancement du chantier actuel : 85 % (estimation ; validation distante et anciens runs à traiter). Avancement du projet global LITD : À évaluer.

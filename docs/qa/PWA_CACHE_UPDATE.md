# Contrôle du renouvellement du cache PWA

Le job `PWA cache update (Chromium)` étend le workflow Builds existant. Il s'exécute sur une pull request quand la sélection habituelle demande les exports, dont Web. Les changements ordinaires qui ne demandent pas ces exports ne déclenchent pas de construction supplémentaire.

## Environnement et protocole

Le runner GitHub isolé exporte la base de la PR et récupère l'export Web candidat produit par le même workflow. Les révisions sont inscrites dans `result.json`. Playwright **1.65.0** et son Chromium utilisent un contexte neuf sans compte connecté. Le serveur dessert uniquement ces exports sur la boucle locale du runner. Les permissions restent `contents: read`. Aucune publication ni donnée utilisateur n'intervient.

Le script `tools/ci/test_pwa_cache_update.cjs` conserve la même origine et le même contexte :

1. Enregistrer le service worker exporté de la base, ouvrir un client sous son contrôle et vérifier le SHA-256 du vrai `index.pck` téléchargé puis mis en cache.
2. Servir l'export candidat, appeler l'API standard `registration.update()` et constater un worker en attente. L'ancien client doit encore recevoir son ancien paquet cohérent.
3. Fermer ce client, attendre l'activation normale du nouveau worker, ouvrir un nouveau client et vérifier le SHA-256 du paquet candidat ainsi que la disparition de l'ancien cache. Une sentinelle du stockage de l'origine doit subsister.

Le worker exporté n'est pas modifié. Le test n'efface pas les caches, ne désenregistre aucun worker et n'utilise ni `skipWaiting` ni message de mise à jour forcée. Le profil est exclusivement celui du test.

## Preuves et limites

L'artefact `pwa-cache-update-evidence` contient le résultat JSON (révisions, empreintes attendues et observées, étapes) et trois captures d'une page de diagnostic identifiée comme QA. `PWA_CACHE_UPDATE_OK` signifie que le contrôle a réellement réussi. Si les paquets sont identiques, le résultat est `not_applicable` avec `PWA_CACHE_UPDATE_SKIPPED`, sans prétendre avoir testé une mise à jour. Un paquet différent accompagné d'un worker identique fait échouer le contrôle.

Ce test utilise le **vrai service worker et le vrai paquet du jeu**, dans Chromium. Une petite page cliente isole le mécanisme de cache du rendu WebGL. Il ne certifie pas le lancement WebAssembly, un combat en navigateur, Safari/iPhone, les sauvegardes Godot (la sentinelle n'est pas une sauvegarde), ni les en-têtes d'un hébergement public. Il vérifie le renouvellement après fermeture des anciens clients ; il n'affirme pas une mise à jour immédiate d'un onglet restant ouvert.

Sources officielles : [Playwright et service workers](https://playwright.dev/docs/service-workers), [Godot 4.7 JavaScriptBridge/PWA](https://docs.godotengine.org/en/4.7/classes/class_javascriptbridge.html), [export Web Godot](https://docs.godotengine.org/en/4.5/tutorials/export/exporting_for_web.html). Les actions GitHub sont épinglées sur leurs SHA vérifiés.

## État au moment de l'ajout

Syntaxe Node, parsing YAML et quatre tests existants du contrat d'export : réussis. Le résultat navigateur doit être lu dans l'exécution GitHub du commit qui ajoute ce test ; sa préparation n'est pas sa validation.

Chantier : cache PWA de #612 — 🟠 EN COURS. Avancement du chantier actuel : **À évaluer**. Avancement du projet global LITD 1 : **À évaluer**.

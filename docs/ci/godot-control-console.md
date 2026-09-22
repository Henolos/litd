# Godot Control Console

La page `godot-status.html` est générée par le workflow `LITD Web Playtest PWA` à partir du log Godot verbose. Elle constitue la couche de présentation du suivi Godot et ne remplace pas le mécanisme temps réel existant.

Le temps réel reste sous la responsabilité du workflow `Godot Live Status` et de `tools/ci/godot_progress_bridge.py`, qui publient le contexte GitHub `godot-progress` avec l’étape, le pourcentage, l’état et le fichier courant. La page interroge ce statut toutes les 15 secondes et l’affiche avec l’état du dernier run Web et son étape de déploiement.

Le rapport statique du dernier export conserve les diagnostics détaillés, les erreurs/warnings et les références `res://`. Si le statut temps réel n’est momentanément pas accessible, la page reste utilisable avec ce dernier état publié.

Les fichiers `godot-status.html` et `godot-status.json` sont également conservés dans l’artefact `godot-web-diagnostics-<run>` afin de rester disponibles pour l’analyse même si un export échoue avant le déploiement Pages.

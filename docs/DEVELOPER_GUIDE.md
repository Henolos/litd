# Guide développeur

## Contrôle local

```bash
./tools/build/run_ci.sh
```

## Ajouter une classe

1. Ajouter l’entrée dans `data/classes.json`.
2. Pour un héros nommé, conserver la planche originale dans `art/library/heroes/{hero}/reference.jpg` et son empreinte dans le manifeste artistique. Les cartes de classes génériques restent dans `assets/heroes/` ; une classe ne détermine pas l’identité d’un héros.
3. Exécuter les tests.
4. Ajouter une entrée au `CHANGELOG.md`.

## Ajouter un ennemi

Même procédure avec `data/enemies.json` et `assets/enemies/`. Les identifiants doivent rester uniques.

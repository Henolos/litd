## Changement et question
Décrire le changement, la question résolue et les critères d'acceptation.

## Preuves et recherche (niveau A / B / C)
- Niveau de risque : A (simple) / B (recherche ou choix technique) / C (risque élevé)
- Sources primaires (URL, version, date de consultation) :
- Sources indépendantes et contradictions recherchées :
- Options comparées, y compris absence de changement si pertinente :
- Raisons de la décision et incertitudes :

## Vérifications réellement exécutées
Indiquer pour chaque vérification : commande/environnement, résultat observé, lien vers le run ou artefact.
Ne jamais cocher une case sur la seule base d'une modification de code.

- [ ] `python tools/qa/validate_project.py` réussit
- [ ] Les tests Python réussissent (CI `quality` inclut `pytest`)
- [ ] Le smoke test Godot réussit
- [ ] Aucun asset ou JSON n’est cassé
- [ ] Tout ajout de lore est déclaré dans `universe/lore/contributions/` et l'audit de continuité réussit
- [ ] Le journal des versions est mis à jour si nécessaire

## Scénarios d'échec et risques résiduels
- Cas négatifs / interruption / corruption / régression :
- Vérifications non réalisées et raison :
- Impact d'un échec, retour arrière et suivi :

## Conclusion
Statut : VALIDÉ / PARTIEL / BLOQUÉ.
Distinguer preuve documentaire, inspection statique, CI, exécution Godot et test matériel.

# Protocole de vérification fondée sur les preuves — v1 (pilote)

## Périmètre et limite
Ce protocole encadre les audits, recherches et décisions techniques documentés dans ce dépôt. Il **ne peut pas** imposer automatiquement une méthode à toutes les réponses d'un assistant dans ChatGPT. Un modèle de PR n'est pas une preuve de recherche effectuée.

## Niveaux proportionnés au risque
- A — édition triviale sans affirmation externe : contrôle de cohérence et vérification locale.
- B — recommandation technique ou recherche : sources primaires datées, au moins une confrontation indépendante lorsque disponible, options et incertitudes.
- C — sécurité, données, déploiement ou décisions difficiles à inverser : niveau B plus scénarios adverses, tests reproductibles, plan de retour arrière et revue humaine avant fusion.

## Démarche obligatoire pour B et C
1. Énoncer la question, le contexte, les critères de réussite et les hypothèses.
2. Rechercher sur Internet quand l'information externe peut changer la décision. Consigner URL, date de consultation, version et portée des sources ; ne pas prétendre avoir recherché si aucun accès n'a été effectué.
3. Confronter les sources, chercher activement les contradictions et comparer au moins deux options pertinentes (dont le statu quo si approprié).
4. Exécuter les tests possibles ; distinguer inspection statique, tests unitaires, CI, exécution Godot et validation matérielle.
5. Étiqueter chaque conclusion : **vérifié**, **inféré**, **non vérifié** ou **contredit** ; associer chaque affirmation déterminante à sa preuve.
6. Déclarer les limites, les risques résiduels, les tests manquants et le statut **VALIDÉ / PARTIEL / BLOQUÉ**.

## Critères de refus d'une validation
- Une affirmation décisive sans preuve ou avec source introuvable.
- Une recherche annoncée mais non réalisée.
- Un test déclaré réussi sans résultat observable.
- Une contradiction importante ignorée.
- Une PR déclarée « validée » alors que la CI ou les tests requis n'ont pas été confirmés.

## Évaluation pilote
Sur dix travaux successifs, mesurer : proportion des affirmations déterminantes sourcées ; citations vérifiables ; recherches déclarées et réellement effectuées ; contradictions recherchées ; résultats de tests traçables ; erreurs détectées par revue indépendante. Comparer au point de départ et réviser les règles si elles produisent des formalités sans améliorer la fiabilité.

## Références méthodologiques à consulter
- NIST AI Risk Management Framework : https://www.nist.gov/itl/ai-risk-management-framework
- OWASP Top 10 for LLM Applications : https://genai.owasp.org/llm-top-10/
- OpenAI Evals : https://platform.openai.com/docs/guides/evals
- Google DeepMind FACTS Grounding : https://deepmind.google/discover/blog/facts-grounding-a-new-benchmark-for-evaluating-the-factuality-of-large-language-models/
- PRISMA 2020 : https://www.prisma-statement.org/prisma-2020

Ces références motivent le protocole ; elles ne démontrent pas son efficacité. Celle-ci doit être mesurée.

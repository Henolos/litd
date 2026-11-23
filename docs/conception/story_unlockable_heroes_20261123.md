# LITD 1 — Héros débloqués par l'histoire

Décision validée : **Anouk → Marec → Mathilde**. Ce sont trois personnages canoniques existants, distincts du quatuor de départ. Les IDs canoniques sont réutilisés.

## Recrutement et progression

- Le niveau de chaque héros est aligné sur le niveau courant du protagoniste au recrutement.
- Les choix des arbres de compétences et les choix de compétences évolutives sont remis à zéro au recrutement. Les arbres de conception eux-mêmes restent des références ; le calcul des points suit la règle canonique LITD 1 lorsqu'elle sera vérifiée.
- Les trois héros sont débloqués dans l'ordre indiqué. Les identifiants exacts des événements/scènes de scénario et leurs conditions restent à définir ; aucun seuil narratif n'est inventé.
- Il s'agit de règles de conception préparées, pas d'un branchement runtime. Aucun déclencheur de recrutement n'est implémenté ici.

## Planches et portraits

- La planche d'Anouk est identique octet pour octet à `art/library/heroes/anouk/reference.jpg` ; cette ressource existante est réutilisée.
- La planche de Marec est identique octet pour octet à `art/library/heroes/marec/reference.jpg` ; cette ressource existante est réutilisée.
- La planche Mathilde fournie dans l'archive diffère de la planche canonique déjà présente. Elle est ajoutée comme référence de conception complémentaire sous `story_unlock/`, sans remplacement de l'original existant.
- Les trois PNG sont des recadrages provisoires. Ils sont archivés avec leur empreinte mais ne sont ni approuvés visuellement ni raccordés au combat.
- Le manifeste conserve les SHA-256 de l'archive et des ressources. Aucun doublon de planche Anouk/Marec n'est ajouté.

## Statut

- Ordre et règles de progression : documentés ; données contractuelles préparées, non raccordées au runtime.
- Binaires : les planches Anouk/Marec sont réutilisées ; la planche distincte de Mathilde et les trois portraits provisoires sont importés.
- Tests automatisés de contrat et d'intégrité : ajoutés dans cette PR.
- Validation visuelle des portraits, intégration runtime, événementiel narratif et essai en jeu : non réalisés.
- Les portraits et tests Godot ne sont pas une condition à la fusion des seules références de conception, mais aucun portrait ne doit servir en combat avant approbation visuelle.

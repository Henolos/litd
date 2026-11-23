# Aurélien — fiche de conception

**Statut :** planche originale vérifiée et identité de héros déjà présente ; enrôlement par la maîtresse d’armes en attente de résolution d’un conflit de roster.

## Source artistique

- Original réutilisé sans copie : `art/library/heroes/aurelien/reference.jpg`.
- SHA-256 : `0d9fff31df8ad2e662b886edb63b47e01d158570e779b3f634d6cc39a66e4670` (538 071 octets, 1122×1402), identique au manifeste `docs/art/validated_heroes_manifest_20261111.json#LITD-HERO-001`.
- La planche le présente comme héros légendaire, originaire de la Cité d’Ebbec, 36 ans, 1,80 m, médecin/diplomate/érudit/guerrier du sang, pilier Politique. Elle décrit trois arbres : **Le Chirurgien de guerre**, **Le Sang comme arme**, **L’Art de gouverner**. Ils ne doivent pas être préalloués au recrutement.

## Conflit de roster

`data/heroes.json` contient déjà l’identifiant canonique `aurelien` dans le quatuor de départ. L’addendum V8.1_WORK le répertorie également parmi les cinq héros à débloquer via affinité avec la maîtresse d’armes. La présente intégration garde une seule fiche/identité et n’ajoute pas un deuxième Aurélien ; aucun déclenchement de recrutement pour cet identifiant ne doit être activé avant réconciliation de ces états.

## Recrutement prévu

Si la contradiction est résolue en faveur d’un enrôlement, le niveau devra égaler celui du protagoniste et les arbres/compétences évolutives être réinitialisés. Le calcul de points et la règle d’affinité restent à confirmer ; aucun changement du quatuor de départ n’est effectué ici.

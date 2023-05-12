# Avancée projets de saisie / consultation Base voie / adresse

## Projet de saisie / consultation Base Voie

### Réalisation :
- projet de saisie simplifié ;
- 

### Problèmes relevés :
1. La mise à jour de la VM des relations tronçons, voies physiques, voies administratives n'est visible qu'après fermeture/réouverture du projet...
--> Solution : changer la VM en table mise à jur toutes les minutes par un job. Une vue aurait été préférable, mais le temps de chargement dans qgis est trop long pour l'instant et ne permettrait pas de l'associer à un projet de saisie / consultation de la base voie.
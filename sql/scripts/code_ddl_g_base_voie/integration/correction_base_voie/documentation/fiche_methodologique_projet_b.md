# Fiche Méthodologique - Projet B
## Création et remplissage de la structure en base du projet B

## Objectif :
Créer une structure permettant de corriger les erreurs de topologie des tronçons de la base voie.

## Méthode :
1. Supprimer la structure existante ;
[suppression_schema_correction_projet_b.sql](../suppression_structures_transitoires/suppression_schema_correction_projet_b.sql)  

2. Création de la structure du projet B ;
2.1 Supprimer le fichier [temp_code_ddl_schema_transitoire_projet_b.sql](../creation_structures_transitoires/temp_code_ddl_schema_transitoire_projet_b.sql)
2.2 Compilation du code : [lanceur_creation_code_ddl_transitoire_projet_b.bat](../creation_structures_transitoires/lanceur_creation_code_ddl_transitoire_projet_b.bat)
2.3 Exécuter le code dans SqlDevelopper (possibilité de le faire directement dans le .bat en supprimant les commentaires) ;

3. Remplissage de la structure du projet B et vérification du bon import des données ;
[remplissage_structure_projet_b.sql](../remplissage_structures_transitoires/remplissage_structure_projet_b.sql)

4. Réactivation des contraintes, index, et séquences
[reactivation_contraintes_index_sequence.sql](../remplissage_structures_transitoires/reactivation_contraintes_index_sequence.sql)

5. Catégorisation des tronçons par type d'erreurs topologiques
[categorisation_troncon_par_type_erreur_topologique.sql](../remplissage_structures_transitoires/categorisation_troncon_par_type_erreur_topologique.sql)
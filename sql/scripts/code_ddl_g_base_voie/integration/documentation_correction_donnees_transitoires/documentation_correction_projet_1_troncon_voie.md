# Documentation : Correction des tronçons affectés à plusieurs voies

## Contexte : 
la base voie présente sur G_SIDU offre la possibilité d'affecter un tronçon à plusieurs voies, ce qui pose un problème lors d'export de données, comme pour celui du projet LITTERALIS où un tronçon doit être affecté à une et une seule voie. Cela peut poser également problème pour des calculs d'itinéraires.  
Ce cas se retrouve beaucoup au niveau des limites communales : une limite pouvant diviser une voie en deux dans le sens de la longueur, cette voie peut s'appeler Rue bidule dans la commune A et Rue trucmuch dans la commune B. L'affectation d'un tronçon à deux voies a donc été volontairement effectuée. Cependant, si les noms peuvent varier, les géométries, elles, ne changent pas. Il a donc été décidé de passer d'une relation tronçon/voies N:N à une relation 1:N au niveau des géométries (que nous gérons).

## Méthode de correction :
Afin de conserver l'existant nous avons décidé de ne pas effectuer les corrections directement sur les données de la base mais sur des données transitoires, ce qui créé une migration en trois temps :

1. Migration des données dans des tables d'import ;

2. Correction des données dans des tables transitoires ;

3. Migration des données des tables transitoires vers les tables de production ;

## Objectif du document :
Expliquer la méthode suivie pour corriger les tronçons affectés à plusieurs voies (cf. étape 2 : Correction des données dans des tables transitoires ci-dessus).

## 1. Création des tables, vues et vues matérialisées transitoires
Cette étape utilise tous les objets préfixés *TEMP_CORRECTION_PROJET_A_* présents dans les dossiers *declencheurs*, *sequences*, *tables*, *vues*, *vues materialisees*, *fonctions*, dont le code ddl est compilé par le fichier ![lanceur_creation_code_ddl_transitoire.bat](../creation_tables_transitoires/lanceur_creation_code_ddl_transitoire.bat) dans le fichier temporaire ![temp_code_ddl_schema_transitoire_projet_a.sql](../creation_tables_transitoires/temp_code_ddl_schema_transitoire_projet_a.sql).  
Cela permet de créer la structure qui va accueillir les données des tables d'import.

## 2. Remplissage des tables transitoires
Exécutez le code du fichier ![import_dans_tables_transitoires.sql](../remplissage_tables_transitoires/import_dans_tables_transitoires.sql).  
Cette étape se fait en désactivant les triggers, important les données et réactivant les triggers.

## 3. Correction des données via des requêtes SQL
Exécutez le code du fichier ![correction_donnees_tables_transitoires.sql](../correction_tables_transitoires/correction_donnees_tables_transitoires.sql), qui va :
- Invalider les doublons de voies absolus ;
- Invalider les relations tronçons/voies où le code INSEE de la voie est différent de celui du tronçon ;

## 4. Création des vues matérialisées distinguant les deux cas d'erreur
Exécutez le code du fichier ![lanceur_temp_vues_materialisees_schema_transitoire_projet_a.bat](../creation_tables_transitoires/lanceur_temp_vues_materialisees_schema_transitoire_projet_a.bat) qui va permettre de compiler le code des VM dans le fichier ![temp_vues_materialisees_schema_transitoire_projet_a.sql](../creation_tables_transitoires/temp_vues_materialisees_schema_transitoire_projet_a.sql), puis exécutez ce code dans SQLDevelopper.  
- La vue matérialisée **creation_vm_temp_correction_projet_a_troncon_doublon_voie_inside_commune** permet d'identifier les relations tronçon/voies dans lesquelles les voies sont complètement contenues dans la commune du tronçon ;
- La vue matérialisée **creation_vm_temp_correction_projet_a_troncon_doublon_voie_overlapbdydisjoint_commune** permet d'identifier les relations tronçon/voies dans lesquelles les voies sont intersectent plusieurs communes ;

## 5. Création des filtres dans QGIS
5.1. ovrez le projet qgis 1_troncon_voie ;
5.2. Sélectionnez les valeurs du champ *ID_TRONCON* de la VM **creation_vm_temp_correction_projet_a_troncon_doublon_voie_inside_commune**, dans excel rajoutez une virgule derrière chaque valeur sauf la dernière et collez ces valeurs dans QGIS, dans le filtre de la table **Troncons à l'intérieur d'une commune** ;
5.3. Sélectionnez les valeurs du champ *ID_VOIE* de la VM **creation_vm_temp_correction_projet_a_troncon_doublon_voie_inside_commune**, dans excel rajoutez une virgule derrière chaque valeur sauf la dernière et collez ces valeurs dans QGIS, dans le filtre de la table **Voies à l'intérieur d'une commune** ;
5.4. Sélectionnez les valeurs du champ *ID_TRONCON* de la VM **creation_vm_temp_correction_projet_a_troncon_doublon_voie_inside_commune**, dans excel rajoutez une virgule derrière chaque valeur sauf la dernière et collez ces valeurs dans QGIS, dans le filtre de la table **Relation tronçons/voies à l'intérieur d'une commune** ;
5.5. Sélectionnez les valeurs du champ *ID_TRONCON* de la VM **creation_vm_temp_correction_projet_a_troncon_doublon_voie_overlapbdydisjoint_commune**, dans excel rajoutez une virgule derrière chaque valeur sauf la dernière et collez ces valeurs dans QGIS, dans le filtre de la table **Tronçons intersectant une limite comunale** ;
5.6. Sélectionnez les valeurs du champ *ID_VOIE* de la VM **creation_vm_temp_correction_projet_a_troncon_doublon_voie_overlapbdydisjoint_commune**, dans excel rajoutez une virgule derrière chaque valeur sauf la dernière et collez ces valeurs dans QGIS, dans le filtre de la table **Voies intersectant une limite comunale** ;
5.7. Sélectionnez les valeurs du champ *ID_TRONCON* de la VM **creation_vm_temp_correction_projet_a_troncon_doublon_voie_overlapbdydisjoint_commune**, dans excel rajoutez une virgule derrière chaque valeur sauf la dernière et collez ces valeurs dans QGIS, dans le filtre de la table **Relation tronçons/voies intersectant une limite communale** ;
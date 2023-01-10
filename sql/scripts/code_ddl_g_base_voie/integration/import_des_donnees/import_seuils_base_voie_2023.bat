@echo off
:: utilisation de ogr2ogr pour exporter des tables de oracle 11g vers oracle 12c
echo Bienvenu dans l'import des seuils de la base voie du schema actuel vers le nouveau ! Ce nouvel import est necessaire puisque la production des seuils a continue en ete 2022.
:: 1. gestion des identifiants Oracle
SET /p USER_D="Veuillez saisir l'utilisateur Oracle de destination : "
SET /p USER_P="Veuillez saisir l'utilisateur Oracle de provenance : "
SET /p MDP_D="Veuillez saisir le mot de passe de l'utilisateur Oracle de destination : "
SET /p MDP_P="Veuillez saisir le mot de passe de l'utilisateur Oracle de provenance : "
SET /p INSTANCE_D="Veuillez saisir l'instance Oracle de destination: "
SET /p INSTANCE_P="Veuillez saisir l'instance Oracle de provenance : "
::SET /p USER_FUSION_SEUIL_P="Fusion des seuils : Veuillez saisir l'utilisateur Oracle de provenance : "
::SET /p MDP_FUSION_SEUIL_P="Fusion des seuils : Veuillez saisir le mot de passe de l'utilisateur Oracle de provenance : "
::SET /p INSTANCE_FUSION_SEUIL_P="Fusion des seuils : Veuillez saisir l'instance Oracle de provenance : "

:: 2. se mettre dans l'environnement QGIS
cd C:\Program Files\QGIS 3.20.3\bin

:: 3. Configurer le système d'encodage des caractères en UTF-8
SET NLS_LANG=AMERICAN_AMERICA.AL32UTF8

:: 4. Rediriger la variable PROJ_LIB vers le bon fichier proj.db afin qu'ogr2ogr trouve le bon scr
setx PROJ_LIB "C:\Program Files\QGIS 3.20.3\share\proj"

:: 5. commande ogr2ogr pour exporter les couches du schéma X@X vers le schéma X@X
:: 5.1. table ILTASEU
::ogr2ogr.exe -f OCI OCI:%USER_D%/%MDP_D%@%INSTANCE_D% OCI:%USER_P%/%MDP_P%@%INSTANCE_P%:ILTASEU -sql "SELECT * FROM G_SIDU.ILTASEU" -nln TEMP_ILTASEU_2023 -nlt POINT -lco SRID=2154 -dim 2

:: 5.2. table TEMP_FUSION_SEUIL
::ogr2ogr.exe -f OCI OCI:%USER_D%/%MDP_D%@%INSTANCE_D% OCI:%USER_FUSION_SEUIL_P%/%MDP_FUSION_SEUIL_P%@%INSTANCE_FUSION_SEUIL_P% -sql "SELECT a.objectid, b.cdcote, SDO_GEOM.SDO_CENTROID(SDO_AGGR_UNION(SDOAGGRTYPE(b.geom, 0.50)),0.005)AS v_centroid FROM GEO.TA_POINT_TOPO_F a, G_SIDU.ILTASEU b WHERE a.cla_inu = 42 AND a.geo_on_valide = 0 AND SDO_WITHIN_DISTANCE(b.geom, a.geom, 'DISTANCE=0.50') = 'TRUE' GROUP BY a.objectid, b.cdcote HAVING COUNT(b.idseui)>1" -nln TEMP_FUSION_SEUIL_2023 -nlt POINT -lco SRID=2154 -dim 2

:: 5.3. table ILTASIT
ogr2ogr.exe -f OCI OCI:%USER_D%/%MDP_D%@%INSTANCE_D% OCI:%USER_P%/%MDP_P%@%INSTANCE_P%:ILTASIT -sql "SELECT * FROM G_SIDU.ILTASIT" -nln TEMP_ILTASIT_2023

:: 6. MISE EN PAUSE
PAUSE
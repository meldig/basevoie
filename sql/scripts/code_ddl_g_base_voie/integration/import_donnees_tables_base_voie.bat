@echo off
:: utilisation de ogr2ogr pour exporter des tables de CUDL vers MULTIT
echo Bienvenu dans l'import des donnees de la base voie du schema actuel vers le nouveau ! 
:: 1. gestion des identifiants Oracle
SET /p USER_D="Veuillez saisir l'utilisateur Oracle de destination : "
SET /p USER_P="Veuillez saisir l'utilisateur Oracle de provenance : "
SET /p MDP_D="Veuillez saisir le mot de passe de l'utilisateur Oracle de destination : "
SET /p MDP_P="Veuillez saisir le mot de passe de l'utilisateur Oracle de provenance : "
SET /p INSTANCE_D="Veuillez saisir l'instance Oracle de destination: "
SET /p INSTANCE_P="Veuillez saisir l'instance Oracle de provenance : "
SET /p USER_FUSION_SEUIL_P="Fusion des seuils : Veuillez saisir l'utilisateur Oracle de provenance : "
SET /p MDP_FUSION_SEUIL_P="Fusion des seuils : Veuillez saisir le mot de passe de l'utilisateur Oracle de provenance : "
SET /p INSTANCE_FUSION_SEUIL_P="Fusion des seuils : Veuillez saisir l'instance Oracle de provenance : "
SET /p CHEMIN_AGENT="Veuillez saisir le chemin d'acces au fichier temp_agent : "
SET /p CHEMIN_INTEGRATION="Veuillez saisir le chemin d'acces au dossier integration : "

:: 2. se mettre dans l'environnement QGIS
cd C:\Program Files\QGIS 3.16\bin

:: 3. Configurer le système d'encodage des caractères en UTF-8
SET NLS_LANG=AMERICAN_AMERICA.AL32UTF8

:: 4. Rediriger la variable PROJ_LIB vers le bon fichier proj.db afin qu'ogr2ogr trouve le bon scr
setx PROJ_LIB "C:\Program Files\QGIS 3.16\share\proj"

:: 5. commande ogr2ogr pour exporter les couches du schéma X@X vers le schéma X@X
:: 5.1. table ILTATRC
ogr2ogr.exe -f OCI OCI:%USER_D%/%MDP_D%@%INSTANCE_D% OCI:%USER_P%/%MDP_P%@%INSTANCE_P%:ILTATRC -sql "SELECT * FROM G_SIDU.ILTATRC" -nln TEMP_ILTATRC -nlt LINESTRING -lco SRID=2154 -dim 2

:: 5.2. table ILTAPTZ
ogr2ogr.exe -f OCI OCI:%USER_D%/%MDP_D%@%INSTANCE_D% OCI:%USER_P%/%MDP_P%@%INSTANCE_P%:ILTAPTZ -sql "SELECT * FROM G_SIDU.ILTAPTZ" -nln TEMP_ILTAPTZ -nlt POINT -lco SRID=2154 -dim 2

:: 5.3. table ILTADTN
ogr2ogr.exe -f OCI OCI:%USER_D%/%MDP_D%@%INSTANCE_D% OCI:%USER_P%/%MDP_P%@%INSTANCE_P%:ILTADTN -sql "SELECT * FROM G_SIDU.ILTADTN" -nln TEMP_ILTADTN

:: 5.4. table VOIEVOI
ogr2ogr.exe -f OCI OCI:%USER_D%/%MDP_D%@%INSTANCE_D% OCI:%USER_P%/%MDP_P%@%INSTANCE_P%:VOIEVOI -sql "SELECT * FROM G_SIDU.VOIEVOI" -nln TEMP_VOIEVOI

:: 5.5. table VOIECVT
ogr2ogr.exe -f OCI OCI:%USER_D%/%MDP_D%@%INSTANCE_D% OCI:%USER_P%/%MDP_P%@%INSTANCE_P%:VOIECVT -sql "SELECT * FROM G_SIDU.VOIECVT" -nln TEMP_VOIECVT

:: 5.6. table TYPEVOIE
ogr2ogr.exe -f OCI OCI:%USER_D%/%MDP_D%@%INSTANCE_D% OCI:%USER_P%/%MDP_P%@%INSTANCE_P%:TYPEVOIE -sql "SELECT * FROM G_SIDU.TYPEVOIE" -nln TEMP_TYPEVOIE

:: 5.7. table ILTASEU
ogr2ogr.exe -f OCI OCI:%USER_D%/%MDP_D%@%INSTANCE_D% OCI:%USER_P%/%MDP_P%@%INSTANCE_P%:ILTASEU -sql "SELECT * FROM G_SIDU.ILTASEU" -nln TEMP_ILTASEU -nlt POINT -lco SRID=2154 -dim 2

:: 5.8. table ILTASIT
ogr2ogr.exe -f OCI OCI:%USER_D%/%MDP_D%@%INSTANCE_D% OCI:%USER_P%/%MDP_P%@%INSTANCE_P%:ILTASIT -sql "SELECT * FROM G_SIDU.ILTASIT" -nln TEMP_ILTASIT

:: 5.9. table ILTAFILIA
ogr2ogr.exe -f OCI OCI:%USER_D%/%MDP_D%@%INSTANCE_D% OCI:%USER_P%/%MDP_P%@%INSTANCE_P%:ILTAFILIA -sql "SELECT * FROM G_SIDU.ILTAFILIA" -nln TEMP_ILTAFILIA

:: 5.10. table ILTALPU
ogr2ogr.exe -f OCI OCI:%USER_D%/%MDP_D%@%INSTANCE_D% OCI:%USER_P%/%MDP_P%@%INSTANCE_P%:ILTALPU -sql "SELECT * FROM G_SIDU.ILTALPU" -nln TEMP_ILTALPU

:: 5.11. table TEMP_FUSION_SEUIL
ogr2ogr.exe -f OCI OCI:%USER_D%/%MDP_D%@%INSTANCE_D% OCI:%USER_FUSION_SEUIL_P%/%MDP_FUSION_SEUIL_P%@%INSTANCE_FUSION_SEUIL_P% -sql "SELECT a.objectid, b.cdcote, SDO_GEOM.SDO_CENTROID(SDO_AGGR_UNION(SDOAGGRTYPE(b.geom, 0.50)),0.005)AS v_centroid FROM GEO.TA_POINT_TOPO_F a, G_SIDU.ILTASEU b WHERE a.cla_inu = 42 AND a.geo_on_valide = 0 AND SDO_WITHIN_DISTANCE(b.geom, a.geom, 'DISTANCE=0.50') = 'TRUE' GROUP BY a.objectid, b.cdcote HAVING COUNT(b.idseui)>1" -nln TEMP_FUSION_SEUIL -nlt POINT -lco SRID=2154 -dim 2

:: 5.12. table TEMP_AGENT
ogr2ogr.exe -f OCI OCI:%USER_D%/%MDP_D%@%INSTANCE_D% %CHEMIN_AGENT%/TEMP_AGENT.csv

:: 5.13. table TEMP_FAMILLE
ogr2ogr.exe -f OCI OCI:%USER_D%/%MDP_D%@%INSTANCE_D% %CHEMIN_INTEGRATION%/TEMP_FAMILLE.csv

:: 5.14. table TEMP_FAMILLE
ogr2ogr.exe -f OCI OCI:%USER_D%/%MDP_D%@%INSTANCE_D% %CHEMIN_INTEGRATION%/TEMP_LIBELLE.csv

:: 5.15. table TEMP_RELATION_CODES_DEP_COMMUNES
ogr2ogr.exe -f OCI OCI:%USER_D%/%MDP_D%@%INSTANCE_D% %CHEMIN_INTEGRATION%/TEMP_RELATION_CODES_DEP_COMMUNES.csv

:: 6. MISE EN PAUSE
PAUSE